#!/bin/bash
# Build (release) and (re)launch AgentIsland.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "Building…"
swift build -c release >/dev/null

# Kill any previous instance so the port frees up.
pkill -f "AgentIsland" 2>/dev/null || true
sleep 0.3

BIN="$DIR/.build/release/AgentIsland"
echo "Launching $BIN"
"$BIN" >/tmp/agentisland.log 2>&1 &
echo "PID $! — logs at /tmp/agentisland.log"
