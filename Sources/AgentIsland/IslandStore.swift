import Foundation
import SwiftUI
import AppKit

enum AgentKind: String {
    case claude, codex, unknown

    var display: String {
        switch self {
        case .claude: return "Claude Code"
        case .codex: return "Codex"
        case .unknown: return "Agent"
        }
    }

    var tint: Color {
        switch self {
        case .claude: return Color(red: 0.851, green: 0.467, blue: 0.353) // Claude clay
        case .codex: return Color(red: 0.36, green: 0.78, blue: 0.92)      // Codex cyan
        case .unknown: return Color.white.opacity(0.7)
        }
    }
}

enum SessionStatus {
    case running, waiting, done, idle

    var color: Color {
        switch self {
        case .running: return Color(red: 0.851, green: 0.467, blue: 0.353) // clay accent
        case .waiting: return Color(red: 1.0, green: 0.62, blue: 0.13)      // amber (attention)
        case .done:    return Color.white.opacity(0.5)
        case .idle:    return Color.white.opacity(0.3)
        }
    }
}

struct AgentSession: Identifiable {
    let id: String
    var agent: AgentKind
    var cwd: String
    var status: SessionStatus
    var activity: String
    var updatedAt: Date
    var contextUsed: Int = 0                 // this session's own context window usage
    var contextTotal: Int = 1_000_000
    var contextPct: Double { contextTotal > 0 ? Double(contextUsed) / Double(contextTotal) : 0 }

    var project: String {
        let name = (cwd as NSString).lastPathComponent
        return name.isEmpty ? "~" : name
    }

    // The accent for this session: the active agent's colour while running,
    // amber while waiting, muted otherwise. One accent on screen at a time.
    var tintColor: Color {
        switch status {
        case .running: return agent.tint
        case .waiting: return Color(red: 1.0, green: 0.62, blue: 0.13)
        case .done:    return .white.opacity(0.5)
        case .idle:    return .white.opacity(0.3)
        }
    }
}

final class PendingApproval: Identifiable {
    let id = UUID().uuidString
    let sessionId: String
    let agent: AgentKind
    let toolName: String
    let summary: String
    let cwd: String
    let createdAt: Date
    let respond: (String) -> Void

    init(sessionId: String, agent: AgentKind, toolName: String, summary: String,
         cwd: String, respond: @escaping (String) -> Void) {
        self.sessionId = sessionId
        self.agent = agent
        self.toolName = toolName
        self.summary = summary
        self.cwd = cwd
        self.createdAt = Date()
        self.respond = respond
    }

    var project: String {
        let name = (cwd as NSString).lastPathComponent
        return name.isEmpty ? "~" : name
    }
}

// A multiple-choice question an agent is asking (e.g. Claude's AskUserQuestion).
final class PendingChoice: Identifiable {
    let id = UUID().uuidString
    let sessionId: String
    let agent: AgentKind
    let question: String
    let options: [String]
    let allowsInput: Bool                  // also offer a free-text answer field
    let openApp: String?                   // jump mode: app to bring to front (term program / bundle id)
    let cwd: String
    let respond: (String) -> Void          // returns the chosen/typed answer ("" = dismissed)
    init(sessionId: String, agent: AgentKind, question: String, options: [String],
         allowsInput: Bool, openApp: String?, cwd: String, respond: @escaping (String) -> Void) {
        self.sessionId = sessionId; self.agent = agent; self.question = question
        self.options = options; self.allowsInput = allowsInput; self.openApp = openApp
        self.cwd = cwd; self.respond = respond
    }
    var project: String {
        let n = (cwd as NSString).lastPathComponent
        return n.isEmpty ? "~" : n
    }
}

@MainActor
final class IslandStore: ObservableObject {
    @Published private(set) var sessions: [String: AgentSession] = [:]
    @Published private(set) var order: [String] = []        // most-recently-active first
    @Published private(set) var pending: [PendingApproval] = []
    @Published private(set) var pendingChoice: PendingChoice?

    func requestChoice(payload: [String: Any], respond: @escaping (String) -> Void) {
        let sid = (payload["session_id"] as? String) ?? "unknown"
        let cwd = (payload["cwd"] as? String) ?? ""
        let agent = AgentKind(rawValue: (payload["agent"] as? String) ?? "claude") ?? .claude
        let question = (payload["question"] as? String) ?? "Choose an option"
        let options = (payload["options"] as? [String]) ?? []
        let allowsInput = (payload["allow_input"] as? Bool) ?? false
        let openApp = payload["open_app"] as? String
        guard !options.isEmpty || allowsInput || openApp != nil else { respond(""); return }
        let c = PendingChoice(sessionId: sid, agent: agent, question: question,
                              options: options, allowsInput: allowsInput,
                              openApp: openApp, cwd: cwd, respond: respond)
        pendingChoice = c
        alertFeedback()
        // Safety valve: dismiss if THIS choice is untouched before the hook times out.
        DispatchQueue.main.asyncAfter(deadline: .now() + 480) { [weak self, weak c] in
            guard let self, let c, self.pendingChoice === c else { return }
            self.decideChoice("")
        }
    }

    // Jump mode: bring the agent's window (terminal app or Codex) to the front.
    func openTarget(_ t: String) {
        let map = ["Apple_Terminal": "com.apple.Terminal", "iTerm.app": "com.googlecode.iterm2",
                   "vscode": "com.microsoft.VSCode", "cursor": "com.todesktop.230313mzl4w4u92",
                   "WarpTerminal": "dev.warp.Warp-Stable", "ghostty": "com.mitchellh.ghostty",
                   "kitty": "net.kovidgoyal.kitty",
                   "Codex": "com.openai.codex", "codex": "com.openai.codex",
                   "Claude": "com.anthropic.claudefordesktop", "claude": "com.anthropic.claudefordesktop"]
        let target = map[t] ?? t
        let ws = NSWorkspace.shared
        if let url = ws.urlForApplication(withBundleIdentifier: target) {
            ws.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
            return
        }
        for app in ws.runningApplications where app.localizedName == target || app.bundleIdentifier == target {
            app.activate(options: [.activateAllWindows]); return
        }
    }

    func decideChoice(_ label: String) {
        let c = pendingChoice
        pendingChoice = nil
        suppressExpand = true
        isExpanded = false
        c?.respond(label)
    }

    // Notch geometry + state, driven by NotchController.
    @Published var isExpanded = false
    @Published var notchGap: CGFloat = 200      // physical notch width (camera gap)
    @Published var topBandHeight: CGFloat = 32  // menu-bar / notch band height
    @Published var panelWidth: CGFloat = 400    // expanded/active width
    @Published var expandedHeight: CGFloat = 180
    @Published var notifyUntil: Date?           // auto-expand window for notifications
    var suppressExpand = false                  // after resolving an approval, don't re-expand on hover until the mouse leaves

    // User settings (persisted in UserDefaults). didSet is NOT called for these
    // when assigned inside init(), so loading on launch won't re-save.
    @Published var showUsage = true     { didSet { UserDefaults.standard.set(showUsage, forKey: "showUsage") } }
    @Published var showContext = true   { didSet { UserDefaults.standard.set(showContext, forKey: "showContext") } }
    @Published var showFiveHour = true  { didSet { UserDefaults.standard.set(showFiveHour, forKey: "showFiveHour") } }
    @Published var showWeekly = true    { didSet { UserDefaults.standard.set(showWeekly, forKey: "showWeekly") } }
    @Published var enableClaude = true  { didSet { UserDefaults.standard.set(enableClaude, forKey: "enableClaude") } }
    @Published var enableCodex = true   { didSet { UserDefaults.standard.set(enableCodex, forKey: "enableCodex") } }
    @Published var iconStyle = 3        { didSet { UserDefaults.standard.set(iconStyle, forKey: "iconStyle") } }
    @Published var soundEnabled = true  { didSet { UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled") } }
    @Published var hapticEnabled = true { didSet { UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled") } }

    init() {
        let d = UserDefaults.standard
        func b(_ k: String, _ def: Bool) -> Bool { d.object(forKey: k) == nil ? def : d.bool(forKey: k) }
        showUsage = b("showUsage", true)
        showContext = b("showContext", true)
        showFiveHour = b("showFiveHour", true)
        showWeekly = b("showWeekly", true)
        enableClaude = b("enableClaude", true)
        enableCodex = b("enableCodex", true)
        iconStyle = d.object(forKey: "iconStyle") == nil ? 3 : d.integer(forKey: "iconStyle")
        soundEnabled = b("soundEnabled", true)
        hapticEnabled = b("hapticEnabled", true)
    }

    // Sound + trackpad haptic when something needs attention (gated by settings).
    func alertFeedback() {
        if hapticEnabled {
            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        }
        if soundEnabled {
            NSSound.beep()   // the user's own system alert sound — Apple-native, respects their volume
        }
    }

    // Active sessions (running/waiting, enabled) — so all your open pages show.
    var activeSessions: [AgentSession] {
        order.compactMap { sessions[$0] }
            .filter { ($0.status == .running || $0.status == .waiting) && isEnabled($0.agent) }
    }

    func isEnabled(_ a: AgentKind) -> Bool {
        switch a {
        case .claude: return enableClaude
        case .codex: return enableCodex
        case .unknown: return true
        }
    }

    enum NotchMode { case bare, active, expanded }
    var mode: NotchMode {
        if isExpanded { return .expanded }
        if let s = primarySession, s.status == .running || s.status == .waiting { return .active }
        return .bare
    }

    // Account/usage snapshot shown when idle. Seeded with sample values so the
    // dashboard is visible before a real feed is wired; update via POST /usage.
    struct Usage {
        // Real values arrive from the watchers. -1 means "no data" → bar hidden.
        var contextUsed = 0
        var contextTotal = 1_000_000
        var fiveHourPct = -1.0
        var fiveHourReset = "—"
        var weeklyPct = -1.0
        var weeklyReset = "—"
        var creditsUsed = 0.0
        var creditsTotal = 0.0
        var contextPct: Double { contextTotal > 0 ? Double(contextUsed) / Double(contextTotal) : 0 }
    }
    // Usage is PER AGENT — context window is each agent's own, and rate limits
    // belong to different accounts (Claude plan vs OpenAI). Keyed by agent.
    // Real values flow in from the watchers; start empty (no fake data).
    @Published var usageByAgent: [String: Usage] = ["claude": Usage(), "codex": Usage()]
    func usage(for agent: AgentKind) -> Usage { usageByAgent[agent.rawValue] ?? Usage() }

    // Agents that quit/were killed never send a clean stop — sweep sessions that
    // have gone quiet so they stop showing as "running" and eventually drop off.
    func pruneStale() {
        let now = Date()
        for id in Array(sessions.keys) {
            guard let s = sessions[id] else { continue }
            let age = now.timeIntervalSince(s.updatedAt)
            if age > 360 {                                   // 6 min → forget it
                sessions[id] = nil
                order.removeAll { $0 == id }
            } else if age > 90, s.status == .running || s.status == .waiting {
                var ns = s; ns.status = .done; ns.activity = "Idle"   // 90s quiet → no longer active
                sessions[id] = ns
            }
        }
    }

    // Reset to idle: clear all sessions and resolve any pending approvals.
    func clearAll() {
        for a in pending { a.respond("ask") }
        pending.removeAll()
        sessions.removeAll()
        order.removeAll()
        focusedAgent = nil
    }

    func ingestUsage(_ p: [String: Any]) {
        let key = (p["agent"] as? String) ?? "claude"
        var u = usageByAgent[key] ?? Usage()
        if let v = p["context_used"] as? Int { u.contextUsed = v }
        if let v = p["context_total"] as? Int { u.contextTotal = v }
        if let v = p["five_hour_pct"] as? Double { u.fiveHourPct = v }
        if let v = p["five_hour_reset"] as? String { u.fiveHourReset = v }
        if let v = p["weekly_pct"] as? Double { u.weeklyPct = v }
        if let v = p["weekly_reset"] as? String { u.weeklyReset = v }
        if let v = p["credits_used"] as? Double { u.creditsUsed = v }
        if let v = p["credits_total"] as? Double { u.creditsTotal = v }
        usageByAgent[key] = u
    }

    private var autoAllow: Set<String> = []                 // "session|tool|summary"

    // User-pinned focus: click a pet to focus that agent. nil = auto (most recent).
    @Published var focusedAgent: AgentKind?

    func focus(_ agent: AgentKind) {
        focusedAgent = (focusedAgent == agent) ? nil : agent
        focusedSessionID = nil   // switching agent clears any pinned session
    }

    // User-pinned session: click a session row to see ITS context (each chat
    // window has its own). nil = the agent's most-recently-active session.
    @Published var focusedSessionID: String?

    func selectSession(_ id: String) { focusedSessionID = id }

    // The session whose context to show, among the given candidate sessions.
    func selectedSession(in candidates: [AgentSession]) -> AgentSession? {
        if let id = focusedSessionID, let s = candidates.first(where: { $0.id == id }) { return s }
        return candidates.first
    }

    // The agent whose details (pet bright, usage, activity) the island shows.
    // A clicked pet wins; else the running one; else the first enabled agent —
    // so both pets are always selectable, even when nothing is running.
    var displayedAgent: AgentKind {
        if let fa = focusedAgent, isEnabled(fa) { return fa }
        if let s = primarySession { return s.agent }
        if enableClaude { return .claude }
        if enableCodex { return .codex }
        return .claude
    }

    // Enabled agents in a stable order (for the always-present pet row).
    var enabledAgents: [AgentKind] { [.claude, .codex].filter { isEnabled($0) } }

    func status(of agent: AgentKind) -> SessionStatus {
        activeSessions.first(where: { $0.agent == agent })?.status ?? .idle
    }

    var primarySession: AgentSession? {
        // A pending approval/notification owns the spotlight, so the pet, colour
        // and (hidden) usage all correspond to the agent that needs you.
        if let p = pending.first, let s = sessions[p.sessionId] { return s }
        // Then a user-focused agent, if it still has a session.
        if let fa = focusedAgent {
            for id in order { if let s = sessions[id], s.agent == fa, isEnabled(s.agent) { return s } }
        }
        for id in order {
            if let s = sessions[id], isEnabled(s.agent) { return s }
        }
        return nil
    }

    var activeCount: Int {
        sessions.values.filter { $0.status == .running || $0.status == .waiting }.count
    }

    // MARK: - Event ingestion (fire-and-forget progress)

    func ingestEvent(kind: String, payload: [String: Any]) {
        let sid = (payload["session_id"] as? String) ?? "unknown"
        let cwd = (payload["cwd"] as? String) ?? ""
        let agent = AgentKind(rawValue: (payload["agent"] as? String) ?? "claude") ?? .claude

        if kind == "session_end" {
            sessions[sid] = nil
            order.removeAll { $0 == sid }
            return
        }

        if kind == "context" {     // per-session context update; never creates a session
            guard var s = sessions[sid] else { return }
            if let v = payload["context_used"] as? Int { s.contextUsed = v }
            if let v = payload["context_total"] as? Int { s.contextTotal = v }
            sessions[sid] = s
            return
        }

        var s = sessions[sid] ?? AgentSession(id: sid, agent: agent, cwd: cwd,
                                              status: .idle, activity: "Session started",
                                              updatedAt: Date())
        if !cwd.isEmpty { s.cwd = cwd }
        s.agent = agent
        s.updatedAt = Date()

        let toolName = (payload["tool_name"] as? String) ?? ""
        let toolInput = (payload["tool_input"] as? [String: Any]) ?? [:]

        switch kind {
        case "session_start":
            s.status = .idle; s.activity = "Ready"
        case "prompt":
            s.status = .running
            s.activity = (payload["prompt"] as? String).map { trim($0) } ?? "Working…"
        case "activity":   // free-text activity (used by the Codex watcher)
            s.status = .running
            s.activity = trim((payload["text"] as? String) ?? s.activity)
        case "pre_tool":
            s.status = .running
            s.activity = summarize(toolName: toolName, toolInput: toolInput)
        case "post_tool":
            s.status = .running
            s.activity = "Ran \(toolName.isEmpty ? "tool" : toolName)"
        case "notification":
            s.status = .waiting
            s.activity = (payload["message"] as? String) ?? "Waiting for you"
            notifyUntil = Date().addingTimeInterval(4.5)   // slide the island down to show it
            alertFeedback()
        case "stop":
            s.status = .done; s.activity = "Finished"
        default:
            break
        }

        sessions[sid] = s
        touch(sid)
    }

    // MARK: - Approval (blocking long-poll)

    func requestApproval(payload: [String: Any], respond: @escaping (String) -> Void) {
        let sid = (payload["session_id"] as? String) ?? "unknown"
        let cwd = (payload["cwd"] as? String) ?? ""
        let agent = AgentKind(rawValue: (payload["agent"] as? String) ?? "claude") ?? .claude
        let toolName = (payload["tool_name"] as? String) ?? "Tool"
        let toolInput = (payload["tool_input"] as? [String: Any]) ?? [:]
        let summary = summarize(toolName: toolName, toolInput: toolInput)
        let key = "\(sid)|\(toolName)|\(summary)"

        if autoAllow.contains(key) {
            respond("allow")
            return
        }

        let approval = PendingApproval(sessionId: sid, agent: agent, toolName: toolName,
                                       summary: summary, cwd: cwd, respond: respond)
        pending.append(approval)
        alertFeedback()

        if var s = sessions[sid] {
            s.status = .waiting
            s.activity = "Needs approval: \(summary)"
            s.updatedAt = Date()
            sessions[sid] = s
        } else {
            sessions[sid] = AgentSession(id: sid, agent: agent, cwd: cwd, status: .waiting,
                                         activity: "Needs approval: \(summary)", updatedAt: Date())
        }
        touch(sid)

        // Safety valve: if the user never decides, fall back to the terminal
        // prompt before the hook's own 600s timeout fires.
        DispatchQueue.main.asyncAfter(deadline: .now() + 480) { [weak self, weak approval] in
            guard let self, let approval, self.pending.contains(where: { $0.id == approval.id }) else { return }
            self.decide(approval, "ask", always: false)
        }
    }

    /// Resolve a pending approval from outside the UI (local control API / CLI).
    /// Targets the given id, or the oldest pending approval if id is nil.
    @discardableResult
    func decideExternal(id: String?, decision: String) -> Bool {
        let target = id.flatMap { wanted in pending.first { $0.id == wanted } } ?? pending.first
        guard let target else { return false }
        decide(target, decision, always: false)
        return true
    }

    /// A JSON snapshot of current state for the menu-bar / CLI / debugging.
    func stateJSON() -> Data {
        let sess = order.compactMap { sessions[$0] }.map { s -> [String: Any] in
            ["id": s.id, "agent": s.agent.rawValue, "project": s.project,
             "status": "\(s.status)", "activity": s.activity, "contextUsed": s.contextUsed]
        }
        let pend = pending.map { p -> [String: Any] in
            ["id": p.id, "agent": p.agent.rawValue, "tool": p.toolName,
             "summary": p.summary, "project": p.project]
        }
        let obj: [String: Any] = ["sessions": sess, "pending": pend]
        return (try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted])) ?? Data("{}".utf8)
    }

    func decide(_ approval: PendingApproval, _ decision: String, always: Bool) {
        if always && decision == "allow" {
            autoAllow.insert("\(approval.sessionId)|\(approval.toolName)|\(approval.summary)")
        }
        approval.respond(decision)
        pending.removeAll { $0.id == approval.id }

        // Collapse straight up the instant the last approval is resolved — set
        // synchronously here so SwiftUI never renders the usage page first.
        if pending.isEmpty {
            suppressExpand = true
            isExpanded = false
        }

        if var s = sessions[approval.sessionId] {
            switch decision {
            case "allow": s.status = .running; s.activity = "Approved · \(approval.summary)"
            case "deny":  s.status = .running; s.activity = "Denied · \(approval.summary)"
            default:      s.status = .waiting; s.activity = "Sent to terminal"
            }
            s.updatedAt = Date()
            sessions[approval.sessionId] = s
        }
    }

    // MARK: - Helpers

    private func touch(_ sid: String) {
        order.removeAll { $0 == sid }
        order.insert(sid, at: 0)
    }

    private func trim(_ s: String, _ n: Int = 120) -> String {
        let one = s.replacingOccurrences(of: "\n", with: " ")
        return one.count > n ? String(one.prefix(n)) + "…" : one
    }

    private func summarize(toolName: String, toolInput: [String: Any]) -> String {
        func base(_ p: String) -> String { (p as NSString).lastPathComponent }
        switch toolName {
        case "Bash":
            return trim((toolInput["command"] as? String) ?? "shell command")
        case "Edit", "Write", "MultiEdit":
            return "\(toolName) \(base((toolInput["file_path"] as? String) ?? "file"))"
        case "NotebookEdit":
            return "Edit \(base((toolInput["notebook_path"] as? String) ?? "notebook"))"
        case "Read":
            return "Read \(base((toolInput["file_path"] as? String) ?? "file"))"
        case "WebFetch":
            return "Fetch \((toolInput["url"] as? String) ?? "url")"
        case "Grep":
            return "Grep \((toolInput["pattern"] as? String) ?? "")"
        default:
            return toolName.isEmpty ? "tool" : toolName
        }
    }
}
