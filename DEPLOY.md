# Setting up AgentIsland

You can set this up by hand, or just **let Claude Code or Codex do it for you**.

## Option A — Let your AI agent install it (easiest)

1. Clone the repo and `cd` into it:
   ```bash
   git clone <repo-url> AgentIsland && cd AgentIsland
   ```
2. Open the folder in **Claude Code** (`claude`) or **Codex**, and paste this:

   > Read README.md in this repo. Set up AgentIsland on my Mac end to end:
   > run `./extract-pets.sh`, then `./build-app.sh`, then `open ./AgentIsland.app`,
   > then `./install.sh`. After each step, check it worked (the menu-bar 🛰️ icon
   > appears, `curl -s http://127.0.0.1:8787/health` returns `ok`). Explain what
   > the hooks do before running install.sh, and tell me to start a NEW Claude
   > Code session afterwards so the hooks load. If `swift` or `ffmpeg` is missing,
   > tell me how to install them. Don't change any source files.

3. The agent will run the steps, verify each, and tell you when it's ready.

## Option B — Manual

```bash
# 0. Prerequisites: macOS 14+, Xcode/Swift, Claude Code and/or Codex installed,
#    python3 (Xcode CLT). Optional: ffmpeg (brew install ffmpeg) for nicer pets.

./extract-pets.sh        # pull Clawd/Codex art from your installed apps (optional)
./build-app.sh           # build AgentIsland.app
open ./AgentIsland.app   # menu-bar 🛰️ appears; island pins under the notch
./install.sh             # add Claude Code hooks (backs up ~/.claude/settings.json)
```

Then **start a new Claude Code session** and run something — watch the notch.

## Verify it works

- Menu bar shows the 🛰️ icon → click it for **Settings**.
- `curl -s http://127.0.0.1:8787/health` returns `ok`.
- In a new Claude Code session, have it run a shell command → an **Allow / Deny /
  Always** card should slide down in the notch.
- Hover the notch → live activity + real usage (Context / 5-hour / Weekly).

## Notes for whoever you share this with

- **Notch optional.** Without a notch it pins under the menu bar; it just looks best on a notched Mac.
- **Purely additive.** If the app isn't running, Claude Code falls back to its normal terminal prompts. Remove everything with `./install.sh --uninstall`.
- **Privacy.** The server is loopback-only and token-protected (`~/.agentisland-token`). The Claude usage limits use *your own* Keychain token, sent only to `api.anthropic.com`.
- **Codex** is read-only monitoring today (it tails Codex's session logs). Approvals/questions for Codex use the "Open Codex" jump button rather than in-island answering.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Island never reacts | App not running, or session started **before** `install.sh`. Open the app, start a new session. |
| `swift: command not found` | Install Xcode or the Command Line Tools (`xcode-select --install`). |
| Pets look like little pixel blobs | Couldn't find Claude.app/Codex.app — run `./extract-pets.sh` (or just enjoy the sprites). |
| 5-hour / weekly missing for Claude | First Keychain access may prompt — click **Always Allow**. The endpoint is also rate-limited; it refreshes every few minutes. |
| Port 8787 busy | Quit any old AgentIsland instance (`pkill -f AgentIsland`) and relaunch. |
