#!/bin/bash
# Install (or uninstall) AgentIsland hooks into Claude Code's settings.json.
# Merges in-place: your existing settings and hooks are preserved. Re-running
# is idempotent (our entries are replaced, not duplicated).
#
#   ./install.sh             install/refresh hooks
#   ./install.sh --uninstall remove only AgentIsland's hooks
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS="$DIR/hooks"
SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"

chmod +x "$HOOKS/ai-event.sh" "$HOOKS/ai-approval.sh"
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.agentisland.bak"

MODE="install"
[ "${1:-}" = "--uninstall" ] && MODE="uninstall"

HOOKS_DIR="$HOOKS" MODE="$MODE" python3 - "$SETTINGS" <<'PY'
import json, os, sys

settings_path = sys.argv[1]
hooks_dir = os.environ["HOOKS_DIR"]
mode = os.environ["MODE"]
approval = os.path.join(hooks_dir, "ai-approval.sh")
event = os.path.join(hooks_dir, "ai-event.sh")

with open(settings_path) as f:
    data = json.load(f)

hooks = data.setdefault("hooks", {})

EVENTS = ["PreToolUse", "PostToolUse", "UserPromptSubmit",
          "Notification", "Stop", "SessionStart", "SessionEnd"]

# Remove any previously-installed AgentIsland groups (idempotent).
def strip(event_name):
    groups = hooks.get(event_name, [])
    kept = []
    for g in groups:
        cmds = " ".join(h.get("command", "") for h in g.get("hooks", []))
        if hooks_dir in cmds:
            continue
        kept.append(g)
    hooks[event_name] = kept

for ev in EVENTS:
    strip(ev)

if mode == "install":
    def add(ev, group):
        hooks.setdefault(ev, []).append(group)

    # Blocking approval only for the tools that normally prompt.
    add("PreToolUse", {
        "matcher": "Bash|Edit|Write|MultiEdit|NotebookEdit|WebFetch|mcp__.*",
        "hooks": [{"type": "command", "command": approval, "timeout": 600}],
    })
    # Live progress for everything else.
    add("PreToolUse",      {"matcher": "*", "hooks": [{"type": "command", "command": f'"{event}" pre_tool'}]})
    add("PostToolUse",     {"matcher": "*", "hooks": [{"type": "command", "command": f'"{event}" post_tool'}]})
    add("UserPromptSubmit",{"hooks": [{"type": "command", "command": f'"{event}" prompt'}]})
    add("Notification",    {"hooks": [{"type": "command", "command": f'"{event}" notification'}]})
    add("Stop",            {"hooks": [{"type": "command", "command": f'"{event}" stop'}]})
    add("SessionStart",    {"hooks": [{"type": "command", "command": f'"{event}" session_start'}]})
    add("SessionEnd",      {"hooks": [{"type": "command", "command": f'"{event}" session_end'}]})

# Drop now-empty event keys.
data["hooks"] = {k: v for k, v in hooks.items() if v}

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)

print(f"{mode}: wrote {settings_path}")
PY

echo "Backup saved at $SETTINGS.agentisland.bak"
if [ "$MODE" = "install" ]; then
  echo "Done. Start the app:  $DIR/run.sh    (then start a NEW Claude Code session)"
else
  echo "AgentIsland hooks removed."
fi
