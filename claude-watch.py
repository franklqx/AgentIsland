#!/usr/bin/env python3
"""Feed REAL Claude Code usage into AgentIsland.

Two sources, both your own data, used locally only:
  • Context  — the most-recently-active session transcript's token usage
               (~/.claude/projects/<proj>/<session>.jsonl), polled every 4s.
  • 5-hour / weekly limits — the same endpoint Claude Code's /usage uses,
               https://api.anthropic.com/api/oauth/usage, authenticated with your
               OAuth token read fresh from the macOS Keychain ("Claude Code-
               credentials"). Polled every ~60s. The token never leaves this
               machine and is only sent to api.anthropic.com.

The first time it reads the Keychain, macOS may ask you to allow access — click
Always Allow.

Run:  python3 claude-watch.py   (the app launches it automatically)
"""
import json, os, glob, time, subprocess, datetime, urllib.request, urllib.error

ISLAND = os.environ.get("AGENTISLAND", "http://127.0.0.1:8787")
PROJECTS = os.path.expanduser("~/.claude/projects")
USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
TAIL_BYTES = 300_000


def _token():
    try:
        return open(os.path.expanduser("~/.agentisland-token")).read().strip()
    except Exception:
        return ""


def post(path, obj):
    try:
        req = urllib.request.Request(
            ISLAND + path, data=json.dumps(obj).encode(),
            headers={"Content-Type": "application/json", "X-AgentIsland-Token": _token()})
        urllib.request.urlopen(req, timeout=2).read()
    except Exception:
        pass


# ---- Context (from transcript) -------------------------------------------

def active_transcripts(max_age=900):
    now = time.time()
    out = []
    for f in glob.glob(os.path.join(PROJECTS, "*", "*.jsonl")):
        try:
            if now - os.path.getmtime(f) < max_age:
                out.append(f)
        except Exception:
            pass
    return out


def context_from(path):
    try:
        size = os.path.getsize(path)
        with open(path, "rb") as f:
            if size > TAIL_BYTES:
                f.seek(size - TAIL_BYTES); f.readline()
            data = f.read().decode("utf-8", "ignore")
    except Exception:
        return None
    used = None
    for line in data.splitlines():
        try:
            m = json.loads(line).get("message")
        except Exception:
            continue
        if isinstance(m, dict) and isinstance(m.get("usage"), dict):
            u = m["usage"]
            used = (u.get("input_tokens", 0) or 0) + (u.get("cache_creation_input_tokens", 0) or 0) \
                + (u.get("cache_read_input_tokens", 0) or 0)
    return used


# ---- 5-hour / weekly limits (from the oauth/usage endpoint) ---------------

def oauth_token():
    try:
        raw = subprocess.run(
            ["security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
            capture_output=True, text=True, timeout=5).stdout.strip()
        return json.loads(raw)["claudeAiOauth"]["accessToken"]
    except Exception:
        return None


def fmt_time(iso):
    try:
        dt = datetime.datetime.fromisoformat(iso).astimezone()
        return dt.strftime("%-I:%M %p")
    except Exception:
        return ""


def fmt_date(iso):
    try:
        dt = datetime.datetime.fromisoformat(iso).astimezone()
        return dt.strftime("%b %-d")
    except Exception:
        return ""


_next_fetch = 0.0   # the usage endpoint is strict — poll slowly and back off on 429


def fetch_limits():
    global _next_fetch
    now = time.time()
    if now < _next_fetch:
        return
    _next_fetch = now + 300            # at most once every 5 minutes
    tok = oauth_token()
    if not tok:
        return
    try:
        req = urllib.request.Request(USAGE_URL, headers={
            "Authorization": f"Bearer {tok}",
            "anthropic-beta": "oauth-2025-04-20",
            "anthropic-version": "2023-06-01",
            "User-Agent": "claude-cli/2.1.187"})
        d = json.loads(urllib.request.urlopen(req, timeout=8).read())
    except urllib.error.HTTPError as e:
        if e.code == 429:
            _next_fetch = now + 1800   # rate limited → back off 30 min
        return
    except Exception:
        return
    u = {"agent": "claude"}
    fh = d.get("five_hour") or {}
    if fh.get("utilization") is not None:
        u["five_hour_pct"] = float(fh["utilization"]) / 100.0
        u["five_hour_reset"] = fmt_time(fh.get("resets_at", ""))
    sd = d.get("seven_day") or {}
    if sd.get("utilization") is not None:
        u["weekly_pct"] = float(sd["utilization"]) / 100.0
        u["weekly_reset"] = fmt_date(sd.get("resets_at", ""))
    if len(u) > 1:
        post("/usage", u)


def main():
    print(f"claude-watch -> {ISLAND}")
    i = 0
    while True:
        for path in active_transcripts():        # per-session context (each chat differs)
            sid = os.path.splitext(os.path.basename(path))[0]
            used = context_from(path)
            if used:
                total = 1_000_000 if used > 200_000 else 200_000
                post("/event?kind=context", {"session_id": sid, "agent": "claude",
                                              "context_used": int(used), "context_total": total})
        if i % 15 == 0:                           # account limits ~every 60s
            fetch_limits()
        i += 1
        time.sleep(4.0)


if __name__ == "__main__":
    main()
