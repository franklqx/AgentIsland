# AgentIsland 🛰️

A macOS **Dynamic Island for your AI coding agents**. A small overlay fused with
the MacBook notch shows what **Claude Code** and **Codex** are doing in real time —
and lets you **approve permission prompts and answer questions right from the
notch**, without switching back to the terminal.

- Hover the notch → it springs down to show live activity + real usage.
- An agent needs permission → **Allow / Deny / Always** slide into the island.
- An agent asks you a question → answer in the island, or **one click jumps you
  straight to the Claude / Codex window**.
- Two pets — Claude's **Clawd** and Codex's cloud — sit on the left; click to
  switch which agent you're looking at.

> Built and battle-tested on a notched MacBook Pro (macOS 14+). Phase 1 (Claude
> Code, full loop) is solid; Codex is read-only monitoring + jump-to-app.

> 🤖 **Don't want to set it up by hand?** Clone the repo, open it in Claude Code
> or Codex, and let the agent install it for you — see [DEPLOY.md](DEPLOY.md) for
> the one-paragraph prompt to paste.

---

## Requirements

- macOS 14+ (a notch is ideal but not required — it pins under the menu bar).
- **Xcode / Swift toolchain** (`swift --version` should work).
- **Claude Code** and/or **Codex** installed (the desktop apps or `claude` CLI).
- `python3` (ships with Xcode Command Line Tools) for the watcher scripts.
- Optional: `ffmpeg` (for nicer cropped pets; without it the full art is used).

## Quick start

```bash
git clone <your-repo-url> AgentIsland && cd AgentIsland
./extract-pets.sh      # pulls Clawd/Codex art from your installed apps (optional)
./build-app.sh         # builds AgentIsland.app
open ./AgentIsland.app # menu-bar 🛰️ appears; the island pins under the notch
./install.sh           # adds Claude Code hooks (backs up settings.json)
```

Then start a **new** Claude Code session and run something. Watch it appear in the
notch. To remove the hooks later: `./install.sh --uninstall`.

## How it works

```
Claude Code ─hook─▶ curl ─▶ AgentIsland (127.0.0.1:8787) ─▶ notch overlay
   resumes ◀── allow/deny ◀──────────  you tap in the island
Codex ─────────▶ codex-watch.py tails ~/.codex/sessions/*.jsonl ─▶ island (read-only)
```

- **Claude Code** — a global `PreToolUse` hook forwards tools that would prompt
  (Bash/Edit/Write/MCP/…) and **blocks** until you decide in the island. Progress
  hooks stream activity. If the app isn't running it returns `ask` and Claude
  falls back to its normal terminal prompt — purely additive.
- **Codex** — `codex-watch.py` (auto-launched by the app) tails Codex's rollout
  JSONL for real activity + usage. Read-only; you launch Codex normally.
- **Usage** — Claude context comes from the session transcript; Claude 5-hour /
  weekly limits from `api.anthropic.com/api/oauth/usage` using your own Keychain
  token; Codex context + limits from its rollout. Only real data is shown.
- **Server** — binds `127.0.0.1` only. No LAN exposure, no firewall prompt.

## Settings

Menu-bar **🛰️ → Settings…** — toggle each agent, show/hide usage rows, pick the
menu-bar icon (Island / Eyes / Filled / Satellite), and turn sound / haptics on
or off. Preferences persist.

## Privacy & security

- The HTTP server is **loopback-only** and **unauthenticated** — any process on
  *your* machine could POST to it. Fine for a personal tool; don't expose the port.
- Your Claude OAuth token is read from the macOS Keychain, used only to call
  `api.anthropic.com`, and is **never logged or written to disk**.
- **Pet artwork is not in this repo** — it's Anthropic/OpenAI art, extracted
  locally from apps you already have. `Assets/pets/` is git-ignored.

## Layout

```
Sources/AgentIsland/   Swift app (notch window, server, store, views, icons)
hooks/                 Claude Code hook scripts (approval bridge + progress)
claude-watch.py        real Claude context + plan limits
codex-watch.py         real Codex activity + usage (read-only rollout tail)
install.sh             merge/unmerge hooks in ~/.claude/settings.json
extract-pets.sh        pull pet art from your installed Claude.app / Codex.app
build-app.sh           package into AgentIsland.app
run.sh                 dev build + relaunch
```

## License

Code: MIT (see LICENSE). The Claude/Codex pet artwork is **not** covered and is
not distributed here — it stays on your machine.
