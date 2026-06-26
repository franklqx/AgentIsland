import AppKit
import SwiftUI
import Combine

// Owns a FIXED-size transparent panel pinned at the top, centered on the notch.
// The window never resizes — SwiftUI draws the black notch shape inside it and
// springs it open/closed. That makes hover read as the shape extending DOWN from
// its current state, not a window popping in. The window is click-through while
// collapsed (so the menu bar still works) and captures clicks while expanded.

// A borderless panel that CAN become key — needed so the choice card's text
// field can receive typing when an agent asks an open question.
final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

@MainActor
final class NotchController {
    private let store: IslandStore
    private let panel: NSPanel
    private var hovering = false
    private var globalMon: Any?
    private var localMon: Any?
    private var cancellable: AnyCancellable?

    private let maxHeight: CGFloat = 300

    init(store: IslandStore) {
        self.store = store

        let hc = NSHostingController(rootView: NotchRootView(store: store))
        hc.view.wantsLayer = true
        hc.view.layer?.backgroundColor = .clear

        let p = KeyablePanel(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                             styleMask: [.borderless, .nonactivatingPanel],
                             backing: .buffered, defer: false)
        p.contentViewController = hc
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = true
        p.level = .statusBar
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        p.ignoresMouseEvents = true
        self.panel = p

        measure()
        p.orderFrontRegardless()
        installMouseMonitors()

        cancellable = store.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.refresh() }
        }
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in MainActor.assumeIsolated { self?.measure() } }
    }

    // MARK: Geometry (published to the store; the window stays fixed)

    private struct Geo { var notchWidth: CGFloat; var band: CGFloat; var centerX: CGFloat; var topY: CGFloat }

    private func geo() -> Geo {
        guard let s = NSScreen.main else { return Geo(notchWidth: 200, band: 32, centerX: 700, topY: 1000) }
        let f = s.frame
        let band = max(f.maxY - s.visibleFrame.maxY, 24)
        var notchW: CGFloat = 200
        if let l = s.auxiliaryTopLeftArea, let r = s.auxiliaryTopRightArea {
            let w = f.width - l.width - r.width
            if w > 80 { notchW = w }
        }
        return Geo(notchWidth: notchW, band: band, centerX: f.midX, topY: f.maxY)
    }

    private func measure() {
        let g = geo()
        store.notchGap = g.notchWidth
        store.topBandHeight = g.band
        store.panelWidth = max(g.notchWidth + 180, 400)
        // expandedHeight is measured live by the SwiftUI view (auto-fits long
        // commands) and published back to the store; the controller only reads it.

        // Fixed window: full panel width, maxHeight tall, top flush with the bezel.
        let size = CGSize(width: store.panelWidth, height: maxHeight)
        let origin = NSPoint(x: (g.centerX - size.width / 2).rounded(), y: (g.topY - size.height).rounded())
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    // MARK: State

    private var notifyTimerScheduled = false

    private func refresh() {
        // IMPORTANT: only write @Published values when they actually change —
        // refresh() runs on every objectWillChange, so an unconditional write
        // here would feed back into itself and spin forever. (expandedHeight is
        // measured/written by the view, never here.)
        if !hovering { store.suppressExpand = false }   // clear once the mouse leaves
        let notifyActive = (store.notifyUntil.map { $0 > Date() } ?? false)
        let shouldExpand = (hovering && !store.suppressExpand) || !store.pending.isEmpty
            || store.pendingChoice != nil || notifyActive
        if store.isExpanded != shouldExpand { store.isExpanded = shouldExpand }
        panel.ignoresMouseEvents = !shouldExpand

        // An open-question choice needs the keyboard → make the panel key.
        if store.pendingChoice?.allowsInput == true {
            if !panel.isKeyWindow {
                NSApp.activate(ignoringOtherApps: true)
                panel.makeKeyAndOrderFront(nil)
            }
        }

        // Schedule a single collapse for when the transient notification expires.
        if notifyActive, !notifyTimerScheduled, let nu = store.notifyUntil {
            notifyTimerScheduled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + max(0.1, nu.timeIntervalSinceNow + 0.05)) {
                [weak self] in
                self?.notifyTimerScheduled = false
                self?.refresh()
            }
        }
    }

    // MARK: Hover

    private func installMouseMonitors() {
        globalMon = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            MainActor.assumeIsolated { self?.updateHover() }
        }
        localMon = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] e in
            MainActor.assumeIsolated { self?.updateHover() }
            return e
        }
    }

    private func updateHover() {
        let g = geo()
        let m = NSEvent.mouseLocation
        let zoneW = max(store.panelWidth + 40, 440)
        let inX = abs(m.x - g.centerX) <= zoneW / 2
        let openDepth: CGFloat = store.isExpanded ? store.expandedHeight + 12 : g.band + 8
        let inY = m.y >= g.topY - openDepth
        let now = inX && inY
        if now != hovering { hovering = now; refresh() }
    }
}
