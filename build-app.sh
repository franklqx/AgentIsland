#!/bin/bash
# Package the release binary into a proper AgentIsland.app (background agent).
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

swift build -c release >/dev/null
APP="$DIR/AgentIsland.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/pets"
cp ".build/release/AgentIsland" "$APP/Contents/MacOS/AgentIsland"

# Pet art is extracted locally from your installed Claude.app / Codex.app and is
# git-ignored. Auto-extract on first build if missing (falls back to sprites).
if [ ! -f "$DIR/Assets/pets/clawd.gif" ] && [ ! -f "$DIR/Assets/pets/codex.png" ]; then
  [ -x "$DIR/extract-pets.sh" ] && "$DIR/extract-pets.sh" || true
fi
if [ -d "$DIR/Assets/pets" ]; then
  cp "$DIR"/Assets/pets/* "$APP/Contents/Resources/pets/" 2>/dev/null || true
fi

# Bundle the watchers so the app can auto-launch them.
cp "$DIR/codex-watch.py" "$APP/Contents/Resources/" 2>/dev/null || true
cp "$DIR/claude-watch.py" "$APP/Contents/Resources/" 2>/dev/null || true

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>AgentIsland</string>
  <key>CFBundleDisplayName</key><string>AgentIsland</string>
  <key>CFBundleIdentifier</key><string>world.meridianstudio.agentisland</string>
  <key>CFBundleExecutable</key><string>AgentIsland</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# Register with LaunchServices so `open -b` and Login Items can find it.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" 2>/dev/null || true
echo "Built $APP"
