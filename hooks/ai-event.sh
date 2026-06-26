#!/bin/bash
# Fire-and-forget progress event -> AgentIsland.
# Invoked by Claude Code hooks as:  ai-event.sh <kind>
# <kind> is one of: session_start prompt pre_tool post_tool notification stop session_end
kind="${1:-event}"
input="$(cat)"
TOK="$(cat "$HOME/.agentisland-token" 2>/dev/null)"
curl -s -m 2 -X POST "http://127.0.0.1:8787/event?kind=${kind}" \
  -H 'Content-Type: application/json' \
  -H "X-AgentIsland-Token: $TOK" \
  --data-binary "$input" >/dev/null 2>&1 &
exit 0
