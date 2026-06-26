#!/bin/bash
# Extract the agent "pet" artwork from YOUR installed Claude.app / Codex.app into
# Assets/pets/. This art belongs to Anthropic / OpenAI — it is generated locally
# from apps you already have and is never committed to the repo. If an app isn't
# installed, AgentIsland falls back to a built-in pixel sprite, so this is optional.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/Assets/pets"
mkdir -p "$OUT"

have_ffmpeg() { command -v ffmpeg >/dev/null 2>&1; }

# --- Claude: "Clawd" (animated gif) -----------------------------------------
CLAWD=$(find /Applications/Claude.app -name "clawd-magnifier.gif" 2>/dev/null | head -1)
if [ -n "$CLAWD" ]; then
  if have_ffmpeg; then
    ffmpeg -y -i "$CLAWD" \
      -vf "crop=600:420:280:380,split[s0][s1];[s0]palettegen=reserve_transparent=1[p];[s1][p]paletteuse" \
      "$OUT/clawd.gif" >/dev/null 2>&1 || cp "$CLAWD" "$OUT/clawd.gif"
  else
    cp "$CLAWD" "$OUT/clawd.gif"   # uncropped — works, just a bit smaller-looking
  fi
  echo "  ✓ Clawd  ($([ $(command -v ffmpeg) ] && echo cropped || echo full))"
else
  echo "  ⚠ Claude.app not found — Claude pet falls back to a built-in sprite"
fi

# --- Codex: cloud icon ------------------------------------------------------
CODEX=$(find /Applications/Codex.app -name "icon-codex-dark-color.png" 2>/dev/null | head -1)
if [ -n "$CODEX" ]; then
  if have_ffmpeg; then
    ffmpeg -y -i "$CODEX" -vf "crop=600:580:215:235" "$OUT/codex.png" >/dev/null 2>&1 || cp "$CODEX" "$OUT/codex.png"
  else
    cp "$CODEX" "$OUT/codex.png"
  fi
  echo "  ✓ Codex"
else
  echo "  ⚠ Codex.app not found — Codex pet falls back to a built-in sprite"
fi

echo "Done. (Missing pets just use built-in pixel sprites.)"
