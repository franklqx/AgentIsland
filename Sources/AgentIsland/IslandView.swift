import SwiftUI

// The window is FIXED; this view springs the black notch shape from its
// collapsed height down to the expanded height. The body is always laid out and
// simply revealed by the growing clip — so hovering reads as the shape extending
// DOWN from its current state, never a window popping in.

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

struct NotchRootView: View {
    @ObservedObject var store: IslandStore
    @State private var measured: CGFloat = 60   // real content height (auto-fits long commands)

    var body: some View {
        let mode = store.mode
        let w = (mode == .bare) ? store.notchGap : store.panelWidth
        let h = store.isExpanded ? max(measured, store.topBandHeight) : store.topBandHeight
        let shape = NotchShape(top: 8, bottom: store.isExpanded ? 28 : 14)

        VStack(spacing: 0) {
            NotchTopStrip(store: store)
            ExpandedBody(store: store)
                .padding(.horizontal, 18)
                .padding(.top, 2)
                .padding(.bottom, 16)       // fixed gap from the last row to the bottom
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(store.isExpanded ? 1 : 0)
        }
        .frame(width: w)                    // constrain width so long commands wrap
        .background(GeometryReader { g in
            Color.clear.preference(key: ContentHeightKey.self, value: g.size.height)
        })
        .onPreferenceChange(ContentHeightKey.self) { v in
            measured = v
            if abs(store.expandedHeight - v) > 0.5 { store.expandedHeight = v }  // for hover zone
        }
        .frame(height: h, alignment: .top)
        .background(shape.fill(Color.black))
        .overlay(shape.stroke(Color.white.opacity(store.isExpanded ? 0.08 : 0), lineWidth: 1))
        .clipShape(shape)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.40, dampingFraction: 0.82), value: store.isExpanded)
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: w)
        .animation(.easeOut(duration: 0.22), value: h)
    }
}

// MARK: - Notch body shape (top flush with the bezel, only bottom corners round)

// The macOS notch silhouette: top edge flush with the bezel, small CONCAVE
// fillets at the top-left/right that flare outward into the menu bar (so the
// panel looks grown-out-of the notch), and large CONVEX rounded bottom corners.
struct NotchShape: Shape {
    var top: CGFloat = 12      // concave fillet radius
    var bottom: CGFloat = 24   // convex bottom-corner radius

    func path(in rect: CGRect) -> Path {
        let t = max(0, min(top, rect.height / 2, rect.width / 2))
        let b = max(0, min(bottom, rect.height - t, (rect.width - 2 * t) / 2))
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // top-left concave fillet
        p.addQuadCurve(to: CGPoint(x: rect.minX + t, y: rect.minY + t),
                       control: CGPoint(x: rect.minX + t, y: rect.minY))
        // left side down
        p.addLine(to: CGPoint(x: rect.minX + t, y: rect.maxY - b))
        // bottom-left convex
        p.addQuadCurve(to: CGPoint(x: rect.minX + t + b, y: rect.maxY),
                       control: CGPoint(x: rect.minX + t, y: rect.maxY))
        // bottom edge
        p.addLine(to: CGPoint(x: rect.maxX - t - b, y: rect.maxY))
        // bottom-right convex
        p.addQuadCurve(to: CGPoint(x: rect.maxX - t, y: rect.maxY - b),
                       control: CGPoint(x: rect.maxX - t, y: rect.maxY))
        // right side up
        p.addLine(to: CGPoint(x: rect.maxX - t, y: rect.minY + t))
        // top-right concave fillet
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.maxX - t, y: rect.minY))
        p.closeSubpath()
        return p
    }
}


// MARK: - Collapsed: pet peeks left, activity peeks right

// Shared top strip used by BOTH collapsed and expanded states, so the pet is
// drawn exactly once and at exactly the same size in both. Expanding just grows
// the panel downward beneath this strip.
private struct NotchTopStrip: View {
    @ObservedObject var store: IslandStore
    var body: some View {
        // Pets pinned hard-left, activity pinned hard-right, camera gap in the
        // middle. Fixed positions → nothing shifts when you click between agents.
        ZStack {
            HStack(spacing: 0) {
                PetCluster(store: store, height: store.topBandHeight - 9)
                Spacer(minLength: 0)
            }
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                if let s = store.activeSessions.first(where: { $0.agent == store.displayedAgent }) {
                    if s.status == .waiting {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(SessionStatus.waiting.color)
                    } else {
                        EqualizerBars(color: s.tintColor)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(width: store.panelWidth, height: store.topBandHeight)
    }
}

// One pet per distinct active agent (primary first). Just Claude → one pet.
private struct PetCluster: View {
    @ObservedObject var store: IslandStore
    var height: CGFloat
    // Expanded → every enabled agent (dim if not running). Collapsed → only the
    // active ones peek out. Stable order so clicking to focus doesn't reshuffle.
    private var agents: [AgentKind] {
        if store.isExpanded { return store.enabledAgents }
        return store.enabledAgents.filter { store.status(of: $0) != .idle }
    }

    var body: some View {
        let displayed = store.displayedAgent
        HStack(spacing: 7) {
            ForEach(Array(agents.enumerated()), id: \.offset) { _, agent in
                let active = store.status(of: agent) != .idle
                PetBadge(agent: agent, status: store.status(of: agent), height: height)
                    .opacity(agent == displayed ? 1 : (active ? 0.6 : 0.3))
                    .contentShape(Rectangle())
                    .onTapGesture { store.focus(agent) }   // click a pet to select/brighten it
            }
        }
    }
}

// MARK: - Body revealed when the panel extends down

// Usage rings are ALWAYS present; activity or an approval sits above them.
private struct ExpandedBody: View {
    @ObservedObject var store: IslandStore
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let choice = store.pendingChoice {
                // Agent asked a multiple-choice question — answer it right here.
                ChoiceCard(store: store, choice: choice)
            } else if let approval = store.pending.first {
                // Needs-approval: show ONLY the decision card, no usage below.
                ApprovalDetail(store: store, approval: approval)
            } else {
                // Everything = the SELECTED agent only.
                let agent = store.displayedAgent
                let mine = store.activeSessions.filter { $0.agent == agent }
                let sel = store.selectedSession(in: mine)   // which chat's context
                if mine.count > 1 {
                    SessionList(store: store, sessions: mine, selectedID: sel?.id)
                } else if let s = mine.first {
                    ActivityDetail(session: s)
                }
                if store.showUsage {
                    UsageBars(store: store, agent: agent, session: sel)
                }
            }
        }
    }
}

// When several agent sessions are active, list them all (one line each) so every
// open page is visible. The primary is brightest; tap a row to focus its agent.
private struct SessionList: View {
    @ObservedObject var store: IslandStore
    let sessions: [AgentSession]
    let selectedID: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(sessions) { s in
                HStack(spacing: 7) {
                    Circle().fill(s.tintColor).frame(width: 6, height: 6)
                    Text(s.project)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize()
                    Text(s.activity)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer(minLength: 0)
                }
                .opacity(s.id == selectedID ? 1 : 0.55)   // selected chat is brightest
                .contentShape(Rectangle())
                .onTapGesture { store.selectSession(s.id) }   // click a chat → its context below
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityDetail: View {
    let session: AgentSession
    var body: some View {
        let s = session
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Circle().fill(s.tintColor).frame(width: 7, height: 7)
                Text("\(s.agent.display) · \(s.project)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            Text(s.activity)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(3)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            if s.status == .running {
                BarberPole(color: s.tintColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ChoiceCard: View {
    @ObservedObject var store: IslandStore
    let choice: PendingChoice
    @State private var typed = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("\(choice.agent.display) · \(choice.project)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer(minLength: 8)
                Text(choice.openApp != nil ? "needs you" : (choice.allowsInput ? "answer" : "choose"))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(choice.agent.tint)
            }
            Text(choice.question)
                .font(.system(size: 12.5, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let target = choice.openApp {
                // Jump mode: don't try to answer here — take the user to the agent.
                HStack(spacing: 8) {
                    IslandButton(title: "Open \(choice.agent.display)", kind: .allow) {
                        store.openTarget(target); store.decideChoice("open")
                    }
                    IslandButton(title: "Dismiss", kind: .deny) { store.decideChoice("dismiss") }
                }
            } else {

            VStack(spacing: 6) {
                ForEach(Array(choice.options.enumerated()), id: \.offset) { i, opt in
                    Button { store.decideChoice(opt) } label: {
                        HStack(spacing: 8) {
                            Text("\(i + 1)")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(choice.agent.tint)
                                .frame(width: 16)
                            Text(opt)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 11).padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(.white.opacity(0.08)))
                    }
                    .buttonStyle(.plain)
                }
            }

            if choice.allowsInput {
                HStack(spacing: 8) {
                    TextField("Type your answer…", text: $typed)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .focused($inputFocused)
                        .onSubmit(submit)
                        .padding(.horizontal, 11).padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(.white.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(choice.agent.tint.opacity(0.4), lineWidth: 1))
                    Button(action: submit) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(typed.isEmpty ? .white.opacity(0.3) : choice.agent.tint)
                    }
                    .buttonStyle(.plain)
                    .disabled(typed.isEmpty)
                }
                .onAppear { inputFocused = true }
            }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func submit() {
        let t = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty { store.decideChoice(t) }
    }
}

private struct ApprovalDetail: View {
    @ObservedObject var store: IslandStore
    let approval: PendingApproval

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Text("\(approval.agent.display) · \(approval.project)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer(minLength: 8)
                Text("needs approval")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(SessionStatus.waiting.color)
                if store.pending.count > 1 {
                    Text("+\(store.pending.count - 1)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 5).padding(.vertical, 1)
                        .background(Capsule().fill(.white.opacity(0.12)))
                }
            }
            Text(approval.summary)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(3)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 7) {
                IslandButton(title: "Deny", kind: .deny) { store.decide(approval, "deny", always: false) }
                IslandButton(title: "Allow", kind: .allow) { store.decide(approval, "allow", always: false) }
                IslandButton(title: "Always", kind: .subtle) { store.decide(approval, "allow", always: true) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Pieces

private struct PetBadge: View {
    let agent: AgentKind
    let status: SessionStatus
    var height: CGFloat

    // Size by height; width follows the art's natural aspect (clamped).
    private var width: CGFloat {
        height * min(max(PetAsset.aspect(for: agent), 0.7), 1.9)
    }

    var body: some View {
        Group {
            if let url = PetAsset.url(for: agent) {
                PetImageView(url: url)
            } else {
                PixelArtView(sprite: Pets.sprite(for: agent))
            }
        }
            .frame(width: width, height: height)
            .clipped()
    }
}

private struct EqualizerBars: View {
    var color: Color
    @State private var on = false
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<4, id: \.self) { i in
                Capsule().fill(color)
                    .frame(width: 3, height: on ? 13 : 4)
                    .animation(.easeInOut(duration: 0.45).repeatForever().delay(Double(i) * 0.11), value: on)
            }
        }
        .frame(height: 14)
        .onAppear { on = true }
    }
}

private struct BarberPole: View {
    var color: Color
    @State private var phase: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let seg = w * 0.42
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.10))
                Capsule().fill(color)
                    .frame(width: seg)
                    .offset(x: phase * (w + seg) - seg)   // sweeps fully across, continuously
            }
            .clipShape(Capsule())
            .onAppear {
                withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Usage bars (always shown when expanded) — Context / 5-hour / Weekly
// Calm palette: soft blue, clay accent, white. Thin capsules, generous spacing.

private struct UsageBars: View {
    @ObservedObject var store: IslandStore
    let agent: AgentKind
    var session: AgentSession? = nil          // the selected chat → its own Context
    private let softBlue = Color(red: 0.43, green: 0.58, blue: 0.84)
    private let plain = Color.white.opacity(0.85)

    private func pct(_ p: Double) -> String { "\(Int((p * 100).rounded()))%" }
    private func tok(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000 { return "\(n / 1000)k" }
        return "\(n)"
    }

    var body: some View {
        let u = store.usage(for: agent)
        VStack(alignment: .leading, spacing: 10) {
            // Attribution: these numbers belong to THIS agent.
            HStack(spacing: 6) {
                Circle().fill(agent.tint).frame(width: 5, height: 5)
                Text(agent.display).font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                Text("usage").font(.system(size: 10)).foregroundStyle(.white.opacity(0.3))
            }
            // Context = the SELECTED chat session's own window (each chat differs).
            // Only shown when a session is selected; 5-hour / weekly are account-level.
            if store.showContext, let s = session, s.contextUsed > 0 {
                UsageBar(label: "Context",
                         right: "\(tok(s.contextUsed)) / \(tok(s.contextTotal)) · \(pct(s.contextPct))",
                         frac: s.contextPct, color: agent.tint)
            }
            if store.showFiveHour && u.fiveHourPct >= 0 {
                UsageBar(label: "5-hour limit",
                         right: "\(pct(u.fiveHourPct)) · resets \(u.fiveHourReset)",
                         frac: u.fiveHourPct, color: softBlue)
            }
            if store.showWeekly && u.weeklyPct >= 0 {
                UsageBar(label: "Weekly",
                         right: "\(pct(u.weeklyPct)) · resets \(u.weeklyReset)",
                         frac: u.weeklyPct, color: plain)
            }
            if (session?.contextUsed ?? 0) == 0 && u.fiveHourPct < 0 && u.weeklyPct < 0 {
                Text("Waiting for live usage…")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct UsageBar: View {
    let label: String
    let right: String
    let frac: Double
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer(minLength: 10)
                Text(right)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.10))
                    Capsule().fill(color)
                        .frame(width: max(4, geo.size.width * min(max(frac, 0), 1)))
                }
            }
            .frame(height: 4)
        }
    }
}

struct IslandButton: View {
    enum Kind { case allow, deny, subtle }
    let title: String
    let kind: Kind
    let action: () -> Void
    @State private var hover = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(fg)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(bg))
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
    }

    private var fg: Color {
        switch kind {
        case .allow: return .black
        case .deny: return Color(red: 1.0, green: 0.5, blue: 0.5)
        case .subtle: return .white.opacity(0.75)
        }
    }
    private var bg: Color {
        switch kind {
        case .allow: return hover ? .white : .white.opacity(0.92)
        case .deny: return .white.opacity(hover ? 0.16 : 0.10)
        case .subtle: return .white.opacity(hover ? 0.16 : 0.08)
        }
    }
}
