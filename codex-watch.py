#!/usr/bin/env python3
"""Watch Codex's rollout JSONL and feed real activity + usage into AgentIsland.

Read-only: it tails the newest ~/.codex/sessions/.../rollout-*.jsonl that Codex
writes as it works, maps events to AgentIsland's /event and /usage endpoints
(agent=codex). No change to how you launch Codex.

Run:  python3 codex-watch.py   (leave it running in the background)
"""
import json, os, glob, time, datetime, urllib.request

ISLAND = os.environ.get("AGENTISLAND", "http://127.0.0.1:8787")
SESSIONS = os.path.expanduser("~/.codex/sessions")


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


def newest():
    files = glob.glob(os.path.join(SESSIONS, "*/*/*/rollout-*.jsonl"))
    newest_f, newest_m = None, -1.0
    for f in files:               # tolerate files rotated/removed mid-scan
        try:
            m = os.path.getmtime(f)
        except OSError:
            continue
        if m > newest_m:
            newest_f, newest_m = f, m
    return newest_f


def fmt_time(ts):
    try:
        return datetime.datetime.fromtimestamp(ts).strftime("%-I:%M %p")
    except Exception:
        return ""


def fmt_date(ts):
    try:
        return datetime.datetime.fromtimestamp(ts).strftime("%b %-d")
    except Exception:
        return ""


def handle(o, st):
    pl = o.get("payload") or {}
    t = pl.get("type")
    base = {"session_id": st["sid"], "agent": "codex", "cwd": st["cwd"]}

    if o.get("type") == "session_meta":
        st["sid"] = pl.get("session_id") or st["sid"]
        st["cwd"] = pl.get("cwd") or st["cwd"]
        post("/event?kind=session_start", {"session_id": st["sid"], "agent": "codex", "cwd": st["cwd"]})
    elif o.get("type") == "turn_context":
        st["cwd"] = pl.get("cwd") or st["cwd"]
    elif t == "task_started":
        post("/event?kind=activity", {**base, "text": "Working…"})
    elif t == "user_message":
        post("/event?kind=prompt", {**base, "prompt": pl.get("message") or ""})
    elif t == "agent_message":
        msg = pl.get("message") or ""
        if msg:
            post("/event?kind=activity", {**base, "text": msg})
    elif t == "web_search_call":
        act = pl.get("action") or {}
        q = act.get("query", "") if isinstance(act, dict) else ""
        post("/event?kind=activity", {**base, "text": "Searching: " + q})
    elif t == "exec_command_begin":
        cmd = pl.get("command") or pl.get("cmd") or ""
        if isinstance(cmd, list):
            cmd = " ".join(str(c) for c in cmd)
        post("/event?kind=activity", {**base, "text": cmd or "Running command"})
    elif t == "task_complete":
        post("/event?kind=stop", base)
    elif t == "token_count":
        info = pl.get("info") or {}
        rl = pl.get("rate_limits") or {}
        # Context WINDOW occupancy = the last turn's input side (input + cached),
        # NOT total_token_usage.total_tokens (that's lifetime cumulative → >100%).
        last = info.get("last_token_usage") or {}
        ctx = (last.get("input_tokens", 0) or 0) + (last.get("cached_input_tokens", 0) or 0)
        win = info.get("model_context_window")
        if ctx and win:                 # per-session context
            post("/event?kind=context", {**base, "context_used": ctx, "context_total": win})
        u = {"agent": "codex"}          # 5h/weekly are account-level
        prim = rl.get("primary") or {}
        if prim:
            u["five_hour_pct"] = (prim.get("used_percent") or 0) / 100.0
            u["five_hour_reset"] = fmt_time(prim.get("resets_at", 0))
        sec = rl.get("secondary") or {}
        if sec:
            u["weekly_pct"] = (sec.get("used_percent") or 0) / 100.0
            u["weekly_reset"] = fmt_date(sec.get("resets_at", 0))
        if len(u) > 1:
            post("/usage", u)


def follow(path):
    st = {"sid": os.path.basename(path).split("rollout-")[-1][:36], "cwd": ""}
    with open(path) as f:
        for line in f:                       # catch up existing lines
            try:
                handle(json.loads(line), st)
            except Exception:
                pass
        # If this rollout is already stale (Codex has quit), don't leave it "running".
        try:
            if time.time() - os.path.getmtime(path) > 120 and st["sid"]:
                post("/event?kind=stop", {"session_id": st["sid"], "agent": "codex", "cwd": st["cwd"]})
        except Exception:
            pass
        while True:
            pos = f.tell()
            line = f.readline()
            if line:
                try:
                    handle(json.loads(line), st)
                except Exception:
                    pass
            else:
                if newest() != path:         # a newer session started
                    return
                time.sleep(1.0)
                f.seek(pos)


def main():
    print(f"codex-watch → {ISLAND}  (watching {SESSIONS})")
    cur = None
    while True:
        n = newest()
        if n and n != cur:
            cur = n
            print("following", os.path.basename(n))
            follow(n)
        else:
            time.sleep(2.0)


if __name__ == "__main__":
    main()
