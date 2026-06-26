import AppKit
import SwiftUI
import Combine

let kPort: UInt16 = 8787

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let store = IslandStore()
    var server: HTTPServer?
    var notch: NotchController?
    var statusItem: NSStatusItem?
    var watchers: [Process] = []
    var pruneTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        notch = NotchController(store: store)
        buildStatusItem()
        startServer()
        startWatcher("codex-watch")    // real Codex activity + usage (rollout)
        startWatcher("claude-watch")   // real Claude context usage (transcript)
        // Sweep sessions whose agent quit without a clean stop.
        pruneTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.store.pruneStale() }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        watchers.forEach { $0.terminate() }
    }

    // Auto-launch a read-only python watcher bundled in Resources.
    private func startWatcher(_ name: String) {
        guard let script = Bundle.main.url(forResource: name, withExtension: "py") else {
            NSLog("AgentIsland: \(name).py not bundled"); return
        }
        let py = "/usr/bin/python3"
        guard FileManager.default.isExecutableFile(atPath: py) else {
            NSLog("AgentIsland: python3 not found, skipping \(name)"); return
        }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: py)
        p.arguments = ["-u", script.path]
        do {
            try p.run()
            watchers.append(p)
            NSLog("AgentIsland: \(name) started")
        } catch {
            NSLog("AgentIsland: \(name) failed: \(error)")
        }
    }

    // MARK: Menu-bar item

    private var iconCancellable: AnyCancellable?

    private func buildStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = menuBarIcon(style: store.iconStyle)
        // Live-update the menu-bar glyph when the user picks a style in Settings.
        iconCancellable = store.$iconStyle.sink { [weak item] style in
            item?.button?.image = menuBarIcon(style: style)
        }
        let menu = NSMenu()
        menu.addItem(withTitle: "AgentIsland — :\(kPort)", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Settings…", action: #selector(openSettings), keyEquivalent: ",").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q").target = self
        item.menu = menu
        statusItem = item
    }

    @objc private func quit() { NSApp.terminate(nil) }

    var settingsWindow: NSWindow?

    @objc private func openSettings() {
        if settingsWindow == nil {
            let hc = NSHostingController(rootView: SettingsView(store: store))
            let w = NSWindow(contentViewController: hc)
            w.title = "AgentIsland Settings"
            w.styleMask = [.titled, .closable]
            w.isReleasedWhenClosed = false
            w.delegate = self
            settingsWindow = w
        }
        NSApp.setActivationPolicy(.regular)   // allow the window to take focus
        settingsWindow?.center()
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Drop back to a menu-bar-only accessory app when settings closes.
    func windowWillClose(_ notification: Notification) {
        if (notification.object as? NSWindow) === settingsWindow {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    // MARK: Local server

    // A per-launch secret written to ~/.agentisland-token (0600). Hooks and
    // watchers read it and send it as X-AgentIsland-Token on every request.
    private func installToken() -> String {
        let token = (0..<32).map { _ in "0123456789abcdef".randomElement()! }
        let str = String(token)
        let path = (NSHomeDirectory() as NSString).appendingPathComponent(".agentisland-token")
        try? str.write(toFile: path, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path)
        return str
    }

    private func startServer() {
        let token = installToken()      // shared secret hooks/watchers must present
        let server = HTTPServer(port: kPort)
        server.onRequest = { [weak self] req, respond in
            guard let self else { respond(.text("gone", status: 503)); return }

            // Reject anything without the token (blocks other local processes and,
            // critically, any webpage trying to reach 127.0.0.1). /health is open.
            if req.path != "/health", req.headers["x-agentisland-token"] != token {
                respond(.text("forbidden", status: 403)); return
            }

            switch req.path {
            case "/health":
                respond(.text("ok"))

            case "/event":
                let kind = req.query["kind"] ?? "event"
                let payload = (try? JSONSerialization.jsonObject(with: req.body)) as? [String: Any] ?? [:]
                Task { @MainActor in self.store.ingestEvent(kind: kind, payload: payload) }
                respond(.text("ok"))

            case "/approval":
                let payload = (try? JSONSerialization.jsonObject(with: req.body)) as? [String: Any] ?? [:]
                Task { @MainActor in
                    self.store.requestApproval(payload: payload) { decision in
                        respond(.text(decision))
                    }
                }

            case "/choice":
                let payload = (try? JSONSerialization.jsonObject(with: req.body)) as? [String: Any] ?? [:]
                Task { @MainActor in
                    self.store.requestChoice(payload: payload) { label in
                        respond(.text(label))
                    }
                }

            case "/decide":
                let id = req.query["id"]
                let decision = req.query["decision"] ?? "ask"
                Task { @MainActor in
                    let ok = self.store.decideExternal(id: id, decision: decision)
                    respond(.text(ok ? "ok" : "no-pending", status: ok ? 200 : 404))
                }

            case "/usage":
                let payload = (try? JSONSerialization.jsonObject(with: req.body)) as? [String: Any] ?? [:]
                Task { @MainActor in self.store.ingestUsage(payload) }
                respond(.text("ok"))

            case "/state":
                Task { @MainActor in
                    var r = HTTPResponse(body: self.store.stateJSON())
                    r.contentType = "application/json"
                    respond(r)
                }

            default:
                respond(.text("not found", status: 404))
            }
        }
        do {
            try server.start()
            NSLog("AgentIsland listening on 127.0.0.1:\(kPort)")
        } catch {
            NSLog("AgentIsland failed to start server: \(error)")
        }
        self.server = server
    }
}

// Process entry runs on the main thread; assert main-actor isolation so we
// can touch the @MainActor AppDelegate / NSApplication.
MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
