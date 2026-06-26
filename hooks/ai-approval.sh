#!/bin/bash
# Blocking approval bridge for Claude Code's PreToolUse hook.
# Forwards the tool request to AgentIsland and waits for the user's tap on
# the island, then emits a PreToolUse permissionDecision on stdout.
#
# If the island is not running or the user doesn't decide in time, this
# returns "ask" so Claude Code transparently falls back to its normal
# terminal permission prompt. That makes the island purely additive.
input="$(cat)"
TOK="$(cat "$HOME/.agentisland-token" 2>/dev/null)"

decision="$(curl -s -m 590 -X POST 'http://127.0.0.1:8787/approval' \
  -H 'Content-Type: application/json' \
  -H "X-AgentIsland-Token: $TOK" \
  --data-binary "$input" 2>/dev/null)"

case "$decision" in
  allow|deny|ask) ;;
  *) decision="ask" ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"AgentIsland"}}\n' "$decision"
exit 0
