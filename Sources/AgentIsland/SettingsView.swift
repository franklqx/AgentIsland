import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: IslandStore

    var body: some View {
        Form {
            Section("Menu-bar icon") {
                HStack(spacing: 8) {
                    ForEach(Array(["Island", "Eyes", "Filled", "Satellite"].enumerated()), id: \.offset) { idx, name in
                        IconChoice(style: idx, label: name,
                                   selected: store.iconStyle == idx) { store.iconStyle = idx }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Alerts") {
                Toggle("Sound", isOn: $store.soundEnabled)
                Toggle("Haptics (trackpad)", isOn: $store.hapticEnabled)
                Text("Plays when an approval or notification slides into the island.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Agents") {
                Toggle("Claude Code", isOn: $store.enableClaude)
                Toggle("Codex", isOn: $store.enableCodex)
            }

            Section("Usage panel") {
                Toggle("Show usage", isOn: $store.showUsage)
                Group {
                    Toggle("Context", isOn: $store.showContext)
                    Toggle("5-hour limit", isOn: $store.showFiveHour)
                    Toggle("Weekly", isOn: $store.showWeekly)
                }
                .disabled(!store.showUsage)
                .padding(.leading, 12)
            }

            Section("Connections") {
                LabeledContent("Claude Code", value: "hooks installed")
                LabeledContent("Codex", value: "watching rollout")
                Text("Live data flows in automatically. Disable an agent above to hide it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Preview") {
                Button("Demo: running") {
                    store.ingestEvent(kind: "pre_tool", payload: [
                        "session_id": "demo-cl", "cwd": "/Users/frank/Desktop/apogee-landing",
                        "agent": "claude", "tool_name": "Bash", "tool_input": ["command": "npm run build"]])
                }
                Button("Demo: approval") {
                    store.requestApproval(payload: [
                        "session_id": "demo-cl", "cwd": "/Users/frank/Desktop/apogee-landing",
                        "agent": "claude", "tool_name": "Bash",
                        "tool_input": ["command": "rm -rf ./dist && supabase db push --prod"]]) { _ in }
                }
                Button("Demo: notification") {
                    store.ingestEvent(kind: "notification", payload: [
                        "session_id": "demo-cl", "cwd": "/Users/frank/Desktop/apogee-landing",
                        "agent": "claude", "message": "Claude needs your permission to run a command"])
                }
                Button("Clear / reset to idle") { store.clearAll() }
            }
        }
        .formStyle(.grouped)
        .frame(width: 340, height: 560)
    }
}

private struct IconChoice: View {
    let style: Int
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(nsImage: menuBarIcon(style: style))
                    .renderingMode(.template)
                    .interpolation(.high)
                    .foregroundStyle(.primary)
                    .frame(height: 18)
                Text(label).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(selected ? Color.accentColor : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
