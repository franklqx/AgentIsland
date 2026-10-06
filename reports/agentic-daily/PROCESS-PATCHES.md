# Agentic Paper Trading Process Patches — 2026-09-14

## TLDR for Frank (10 lines)

1. Paper week 7474: full book + overnight OK; morning prefer open; daily prior-day brief mandatory.
2. Live money still two-confirm; Cursor teaches process; Agentic executes paper only; no CEO hands-on.
3. Patch 1: after if-then fire, force paper entry path — block 1429/overlap false veto (AAPL-style).
4. Patch 2: strong-name scan → always dual hang (pullback + breakout); never scan-only (HPQ miss).
5. Patch 3: near t1 / +1R → raise stop to cost before EOD (AVAV −$35 lesson).
6. Patch 4: parallel full book → per-trade size cut + total exposure caps; overnight allowed under caps.
7. Patch 5: HPE-style catalyst → stock shallow+deep dual path OR options hang-order template; choose one path explicitly.
8. Patch 6: EOD + morning brief must land in chat; failed send → retry ladder (9/11 evening fail).
9. Not stock picks, not live orders, not long backtests — process patches only.
10. File: `/workspace/agentic-paper-patches-2026-09-14.md` — paste sections into Agentic routines/playbook.

---

## 1. 触发后保证纸面入场执行（防 AAPL 式 1429 overlap 假否决）

- IF 书面 if-then 触发已开火（条件、标的、方向、价格带已满足）THEN 立即进入「纸面下单强制路径」，不得再做二次主观否决。
- IF 系统/扫描返回 veto、overlap、1429、重复仓、同名冲突 THEN 先核对：是否同一标的+同一方向+同一到期/行权的**已挂纸面单**；仅当真重复才跳过。
- IF veto 原文含 overlap / 1429 / session-lock / duplicate 但**无已成交或已挂同向纸面仓** THEN 视为假否决 → 强制补挂纸面单（同触发参数）。
- IF 触发发生在盘后或盘前 THEN 纸面单挂「次日开盘优先执行」；不得因「等开盘再想」而取消触发。
- IF 触发被杀后标的仍满足原 if-then（如 AAPL 11/20 340C 类）THEN 在下一可交易窗口按原参数 reopen，并在日志写明「假否决补入」。
- IF 同一触发 2 分钟内连续 veto ≥2 次 THEN 走手工纸面补单模板：标的 / 方向 / 限价或市价纸面 / 数量 / 止损 / 触发 ID。
- IF 补入成功 THEN 在 chat 发一行：`PAPER ENTRY FORCED | {ticker} | {reason} | veto_cleared`。
- IF 真已有同向纸面仓 THEN 不叠仓；仅记录「触发已覆盖」。
- **Do not:** 因 overlap/1429 字样自动作废已开火触发而不核对是否真有仓/单。

---

## 2. 强名扫描：强制双挂模板（回撤 + 突破）

- IF 扫描将某名列入「强名 / strong-name」THEN 必须同时准备两条纸面路径：① pullback 挂单 ② breakout 挂单。
- IF 只完成扫描或只写了 watchlist 条目 THEN 视为未完成；必须挂出至少一条可执行纸面单，优先双挂。
- IF pullback 路径：THEN 挂单语言含：入场带（回撤至 MA/前低/触发价）、失效价、目标 t1、数量（已按 Patch 4 缩仓）。
- IF breakout 路径：THEN 挂单语言含：突破确认价、失效（假突破收回）、目标 t1、数量（已按 Patch 4 缩仓）。
- IF 两条路径互斥（只能成交其一）THEN 在备注写 `OR_ENTRY | cancel_other_on_fill`；成交一条即撤另一条。
- IF 扫描命中但无法定双挂价 THEN 用模板默认：pullback = 最近支撑 ± 缓冲；breakout = 当日/近高 + 缓冲；并标注 `template_default`。
- IF 强名已双挂 THEN chat 一行：`DUAL HUNG | {ticker} | PB@{px} | BO@{px}`。
- IF 仅扫描未挂（HPQ 类）THEN 当日缺陷记录：`SCAN_NO_HANG | {ticker}`，并在收盘前补挂或显式写「放弃原因」。
- **Do not:** 强名只扫不挂；禁止「先观察再决定挂不挂」代替双挂模板。

---

## 3. 接近 t1 / +1R：止损抬至成本 — 可执行规则

- IF 纸面仓浮动 ≥ +1R（按入场到初始止损的 R）OR 价格触及/进入 t1 带 THEN 当日盘中将止损抬至成本（breakeven），优先于继续博扩展。
- IF 已抬至成本 THEN 在订单/日志写 `SL→COST | {ticker} | {time} | R={x}`。
- IF 接近 t1（距离 t1 ≤ 0.25R 或进入 t1 区）但尚未 +1R 记账 THEN 仍执行抬成本；以「近 t1」与「+1R」任一先到为准。
- IF 抬成本时原止损为期权价/股票价 THEN 用同单位改写：股票→成本价；期权→入场权利金成本（含已付）。
- IF EOD 前仍持仓且曾触及 +1R/t1 却未抬止损 THEN 强制补操作：收盘前抬至成本或减仓至规定残仓，并记缺陷（AVAV 类）。
- IF 抬至成本后回撤触及成本止损 THEN 接受出场；不得把止损再降回原位「给空间」。
- IF 隔夜持仓且盘中已满足抬成本条件 THEN 隔夜前必须已是成本止损或更优（trail）；不得隔夜仍用初始宽止损。
- IF 多腿/双路径中一条已 +1R THEN 对该条执行抬成本；另一条未触发则保持原挂。
- **Do not:** 近 t1 / +1R 后仍用初始止损过夜或拖到次日再改（禁止 AVAV 式未抬）。

---

## 4. 纸面全簿并行：单笔缩仓 + 总暴露上限

- IF 纸面周允许 full book 并行 THEN 单笔名义/风险 = 常规单笔的 1/N（建议 N= 同时最大仓位数，默认 N≥3 时单笔 ≤ 常规 40%）。
- IF 新开纸面仓前 THEN 检查：`sum(open_risk) + new_risk ≤ total_risk_cap`（总风险上限，建议 ≤ 常规单笔风险的 2.0–2.5×）。
- IF 总暴露（绝对值名义或 delta 名义，按簿记一致口径）将超 `exposure_cap` THEN 拒绝开新仓或先减最弱仓再开。
- IF 隔夜允许 THEN 隔夜总暴露 ≤ 日内暴露上限；隔夜单笔仍用缩仓后的 size。
- IF 同主题/同因子（同催化剂、同板块高相关）已有 ≥2 纸面仓 THEN 相关组合计风险计入同一预算桶，禁止「按不相关」叠加满额。
- IF 开仓时 size 未按并行规则缩减 THEN 下单前自动改写数量并 chat：`SIZE CUT | {ticker} | {old}→{new}`。
- IF 已超 cap 仍想加仓 THEN 只允许「替换」：平/减一笔后再开，不得净增超 cap。
- IF 晨间优先开盘执行 THEN 开盘一批挂单也必须逐笔通过 cap 检查，按优先级排队，满 cap 后剩余转 watch 不挂。
- **Do not:** 全簿并行时仍用单笔满仓 size，或相关仓按独立预算叠满。

---

## 5. HPE 类催化剂：股票浅/深双路径 vs 期权路径 — 挂单模板语言

- IF 催化剂事件（财报/指引/分拆/大单等）列入交易计划 THEN 先显式二选一主路径：`PATH=STOCK_DUAL` 或 `PATH=OPTIONS`；写入计划头，不得混用未声明。
- IF `PATH=STOCK_DUAL` THEN 必须双挂：① shallow pullback 入场带 + 失效 ② deep pullback 入场带 + 失效；成交浅则深单改条件或撤，备注 `shallow_fill→manage_deep`。
- IF `PATH=OPTIONS` THEN 挂单模板必须含：标的、到期、行权价、权利仓方向、限价、数量（已缩仓）、失效条件、t1、初始止损。
- IF 股票浅路径纸面已大浮盈（HPE 浅回撤类）THEN 当日 EOD 前执行 Patch 3（抬成本/锁利规则）；周末前不得用初始止损裸奔隔周末。
- IF 周末/长假前仍持催化剂仓 THEN 要么：抬止损至成本或更优，要么减仓至隔夜 cap，要么平仓；三者择一写进 chat。
- IF 开盘跳空不利（HPE/SMCI 开盘止损类）THEN 按预设止损执行，不盘中改宽；事后记 `GAP_STOP | {ticker} | {pnl}`。
- IF 选择期权路径但流动性差/价差过大 THEN 回退 `PATH=STOCK_DUAL` 或放弃，禁止无挂单干等。
- 挂单模板句式（可直接贴）：  
  `HANG | {PATH} | {ticker} | SHALLOW@{px}/invalid@{px} | DEEP@{px}/invalid@{px} | OR OPT {expiry}{strike}{C/P} @{limit} | size={n} | SL={ } | t1={ } | catalyst={ }`
- **Do not:** 催化剂只写观点不挂双路径/期权模板；禁止浅路径大盈后周末不抬止损。

---

## 6. EOD / 晨间 brief 必须送达 chat — 失败重试

- IF 每个交易日 EOD 例程跑完 THEN 必须在约定 chat 频道发出当日纸面简报（仓位、盈亏、缺陷、次日挂单）；无回执 = 失败。
- IF 每个交易日早晨 THEN 必须发出「前日 brief」（prior-day summary）+ 当日开盘偏好执行清单；晨间 brief 与 EOD 是两条独立送达。
- IF 发送失败 / 超时 / 无 bot 回执 / 频道拒绝（9/11 晚间类）THEN 立即进入重试梯：① 同频道重发 1 次 → ② 备用频道/线程 → ③ 私聊 Frank/Agentic 告警一行 → ④ 本地落盘 `/workspace/paper-briefs/{date}.md` 并贴路径。
- IF 重试间隔 THEN 即时、+2 分钟、+5 分钟，最多 3 次主动重发；仍失败则告警人工，不得静默。
- IF brief 内容最小集 THEN 必须含：日期、开平仓列表、未平仓与隔夜暴露、当日已实现/浮动盈亏、缺陷标签（假否决/未抬止损/只扫不挂/超 cap）、次日挂单状态。
- IF EOD 例程本身崩溃 THEN 先发 `EOD ROUTINE FAIL | {time} | {error}`，再跑最小简报（仅仓位+盈亏），再走重试梯。
- IF 晨间 brief 迟到超过开盘后 15 分钟（用户时区 Asia/Shanghai）THEN 标 `LATE_BRIEF` 并仍补发；开盘执行不因 brief 缺失而跳过已挂纸面单。
- IF 送达成功 THEN 日志一行：`BRIEF_OK | EOD|AM | {date} | {channel}`。
- **Do not:** EOD/晨间 brief 失败后不重试、不告警、不落盘（禁止 9/11 式静默失败）。

---

# Appended from Cursor postmortem 2026-09-14

# PROCESS-PATCHES delta — 2026-09-14

相对 `Agentic Paper Trading Process Patches — 2026-09-14`（Patch 1–6）的**仅新增 / 收紧**。不要整份替换旧文。粘贴到 Agentic 例程/playbook 时：保留 1–6，追加下列 Δ7–Δ10；与 Patch 3、Patch 5 冲突时以本文件更严者为准。

纸面 7474。真钱两确认仍有效。不是选股。

触发证据（9/14 PAPER）：`GAP_STOP HPE67 −1200`；`GAP_STOP SMCI −1260`；`补记成交 COIN_PB`（10:25 触发 / 11:00 落账）；`CRWD 迟 SL→COST`（10:11 才改）；`ARMED_VOID HPE`（hold 破，正确作废）。累计已实现 −2437.40；EOD 浮 AAPL −236 + CRWD +1939 + COIN +51.52；账面约 −683。真钱 7474 flat。

---

## Δ7. 同 wake 强制成交记账（收紧 Patch 1 的「入场后」空洞）

Patch 1 只管触发后必须挂单，不管成交已发生却等下一轮 wake 才记账。COIN PB ~10:25 ET 成交、11:00 才落账。

- IF 本 wake 内纸面入场条件已满足（限价触及、pullback/breakout 确认、书面「强制纸面成交」）THEN 在**本 wake 返回/休眠之前**完成全部：ledger 写入 fill（时间、价格、数量）、状态→OPEN、`OR_ENTRY` 对手腿 VOID/cancel、初始 SL 与 t1 落单、chat `FILL_BOOKED | {ticker} | {px} | {et_time}`。
- IF 下一计划 wake 间隔 > 15 分钟 OR 下一 wake 跨 premarket/RTH/afterhours/隔夜 THEN 禁止把已满足的 fill 留到下一 wake。
- IF 本 wake 结束前无法完成记账 THEN 不得 sleep；降级为最小记账（ticker、side、qty、px、time、status=OPEN）后再告警 `BOOKKEEP_BLOCKED | {ticker}`。
- IF 后续 wake 发现价格早已成交但账本仍 ARMED/pending/空行 THEN 立即 force fill 补记（用触发时刻价格，不反向用当前价美化），缺陷 `LATE_BOOKKEEP | {ticker} | trigger={hhmm} | booked={hhmm}`。
- IF 补记时对手互斥腿仍 ARMED THEN 同时 VOID，补 `MUTEX_LATE_CANCEL | {ticker}`。
- **Do not:** 用「等下一心跳再对账」代替本 wake 落账。**Do not:** 补记时改用后见价格。

覆盖：成交、开盘强制纸面成交、GAP_STOP 出场。出场同样本 wake 落 `exit/pnl/status`。

---

## Δ8. 每个 wake 自动扫 +1R / 近 t1 → 当场 SL→COST（收紧 Patch 3）

Patch 3 已规定近 t1 / +1R 抬成本，但时间窗是「当日盘中 / EOD 前补」。CRWD 早盘已应抬，10:11 才 SL→COST。

- IF 任意 wake 启动 THEN **第一步**扫描全部 OPEN 纸面腿（含隔夜带过来的），再做新扫描、新挂、新 if-then。扫描未完成 = 本 wake 未完成。
- IF 扫描频率 THEN 每个 wake 一次全量，不少扫；开盘 wake、盘中 wake、EOD 前 wake 都跑。不是「一天一次」。
- 命中定义（沿用 Patch 3，任一先到）：  
  ① 浮盈 ≥ +1R，R = |入场 − 初始止损|（股票用股价；期权用权利金，与开仓书面一致）；  
  ② 距 t1 ≤ 0.25R；  
  ③ 已进入 t1 价格带（含正股 t1 已打印、即使期权 mark t1 未到——与 CRWD 正股 t1 233 已过、mark t1 32 未到的处理一致：正股 t1 打印也算近 t1）。
- IF 命中且现行止损宽于 COST THEN **本 wake 内**改写止损为 COST（股票=入场价；期权=入场权利金），日志 `SL→COST | {ticker} | {wake_time} | R={x} | reason=+1R|near_t1|stock_t1`。
- IF 历史 wake 已应命中、本 wake 发现仍宽于 COST THEN 立即补抬，缺陷 `LATE_SL_COST | {ticker} | should_have={hhmm}`。
- IF 已 SL→COST THEN 后续 wake 扫描只确认未被改回初始止损；禁止「给空间」降回。
- IF EOD wake 仍发现应抬未抬 THEN 先执行再记缺陷；EOD 是漏网审计，不是主路径。
- **Do not:** 把抬成本排到「收盘前再说」。**Do not:** 只扫当日新开仓、漏扫隔夜腿。

对 Patch 3 的显式修订：删除「EOD 前补操作」作为合格标准；合格 = **命中条件出现后的第一个 wake 已 SL→COST**。

---

## Δ9. 周末浮仓硬门：SL→COST 或周五收盘前砍（收紧 Patch 5）

Patch 5：周末/长假「抬成本 **或** 减到隔夜 cap **或** 平仓」。HPE67 周五浮 +1160 仍用初始止损隔周末 → 周一 GAP_STOP −1200。SMCI 周五浮 −225、从未到 +1R，带着 mark 0.50 / 正股 38.50 隔周末 → 周一 −1260。对短到期 OTM 看涨，SL→COST 也会被跳空打穿（HPE 权利金 0.64→0.05），只改 COST 不够。

**取代** Patch 5 中「减到 overnight cap 但止损仍为初始宽止损」这一合法支路。Patch 5 其余（PATH 二选一、开盘 GAP_STOP 不改宽、模板句式）保留。

- IF 日历为该市场周五 RTH（或长假前最后一节 RTH）且该腿状态为 OPEN 并将跨休市 THEN 标记 `WEEKEND_GATE | {ticker}`。Patch 4「隔夜允许」**不**自动授权隔周末。
- IF `WEEKEND_GATE` THEN 仅当下列 **全部** 为真，才允许持过休市：  
  (a) 止损已是 COST 或更优（trail）；  
  (b) **止损在下周一（或休市后开盘）跳空后仍可按 ≥ 书面止损价成交**：正股用市价/可执行限价视为可执行；期权若权利金可被跳空打到显著低于 COST（近零、或低于 COST 的一半）则 (b)=失败；到期日 ≤ 7 个日历日的 OTM 权利仓默认 (b)=失败，除非书面写明「跳空后仍有可成交 bid ≥ COST」的证据；  
  (c) 隔周末暴露 ≤ overnight cap（口径同 Patch 4）。
- IF (a) 为假 THEN 周五收盘前必须完成其一：Δ8 已命中 → SL→COST 然后**重新评估 (b)**；Δ8 未命中 → **cut**。无第三选项。
- IF (b) 为假 THEN 即使 (a) 已真，周五收盘前仍 **flatten**。HPE Sep67 类走这里。
- IF (a)(b)(c) 全真 THEN 允许隔周末，chat `WEEKEND_HOLD_OK | {ticker} | SL=COST_OR_BETTER | cap_ok`。
- IF 周五 RTH 收盘前 15 分钟仍有 `WEEKEND_GATE` 未清的腿 THEN 自动 flatten 剩余不合格腿，`WEEKEND_FORCE_FLAT | {ticker} | {pnl}`，不得拖进 afterhours「再看」。
- IF 周一（休市后）开盘价已穿越书面止损（含 COST）THEN 按可成交价执行 GAP_STOP，不改宽、不撤止损等收回；`GAP_STOP | {ticker} | {pnl}`。（执行面与 Patch 5 相同；本条只禁止用「隔周末」制造更多 GAP_STOP。）
- **Do not:** 初始宽止损隔周末。**Do not:** 用「已缩仓 / 仍在 cap 内」代替 (a)(b)。**Do not:** 对 (b) 失败的期权把 SL→COST 当成周末保护。

周五 EOD 检查清单（可直接进例程）：

```
FRIDAY_CLOSE | for each OPEN:
  run Δ8 scan
  set WEEKEND_GATE
  if not (SL_at_or_better_than_COST): CUT unless Δ8 just raised and (b) recheck passes
  if option and (expiry<=7d or OTM or bid_through_COST_possible): FLATTEN
  if still OPEN: require (a)(b)(c) else WEEKEND_FORCE_FLAT
  chat WEEKEND_HOLD_OK | WEEKEND_FORCE_FLAT per leg
```

---

## Δ10. ARMED 失效必须同 wake VOID（补漏洞，非纠错 9/14 判定）

HPE Oct16 60C：hold 55.55 于 ~15:56–15:59 ET 破，收 55.409，无 reclaim ≥57.20。VOID、$0，判定正确。需要的是状态机与 Δ7 同一标准：失效也不得留到下一 wake。

- IF 腿状态为 ARMED 且失效条件已打印（hold 破且无 reclaim、入场窗口截止、确认价超时、mutex 对手已成交）THEN 本 wake 将状态改为 VOID，fill qty=0，chat `ARMED_VOID | {ticker} | {reason}`。
- IF 失效发生在 RTH 最后 5 分钟 THEN 必须在当次 EOD wake 落 VOID，次日开盘不得仍显示 ARMED。
- IF 次日发现仍 ARMED 但失效价已在昨日打印 THEN 立即 VOID 并记 `LATE_VOID | {ticker}`。
- **Do not:** 把正确 VOID 记成漏挂。**Do not:** 失效后继续用 ARMED 作为可成交挂单。

---

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-14 — append after Patches 1–6; on conflict, delta wins.

Δ7 SAME_WAKE_FILL
IF fill/stop/force-paper condition prints in this wake
THEN before sleep: ledger fill/exit + status + mutex cancel + chat FILL_BOOKED|GAP_STOP
IF next wake >15m or cross-session THEN do not defer
IF book still ARMED after trigger THEN force fill at trigger px; tag LATE_BOOKKEEP
Do not: wait for the next scheduled wake to book a fill that already happened

Δ8 +1R_SCAN_EVERY_WAKE
IF wake starts THEN scan ALL OPEN legs for +1R OR dist(t1)<=0.25R OR in t1 band OR stock t1 printed
IF hit AND stop > COST THEN SL→COST this wake; log SL→COST | time | R
IF should have raised earlier THEN raise now; tag LATE_SL_COST
EOD is audit only
Do not: leave raise-to-cost for EOD; do not skip overnight legs

Δ9 WEEKEND_HARD_GATE (tightens Patch 5)
IF Friday RTH (or last RTH before holiday) AND OPEN into weekend THEN WEEKEND_GATE
Patch 4 overnight-OK does not grant weekend-OK
Hold weekend ONLY if ALL: (a) SL already COST or better (b) that stop is still executable after a gap (stock yes; short-dated/OTM option premium can gap through COST → fail) (c) overnight cap
IF not (a): SL→COST if Δ8 hit then recheck (b); else CUT
IF not (b): FLATTEN before Friday close even if already COST
IF 15m to Friday close and gate open THEN WEEKEND_FORCE_FLAT
Monday gap through written stop (incl COST): GAP_STOP at tradeable px; do not widen
Do not: weekend-hold on initial wide stop; do not use size-cut/cap as substitute; do not treat option SL→COST as gap protection

Δ10 ARMED_VOID_SAME_WAKE
IF ARMED invalidation prints THEN VOID this wake; chat ARMED_VOID | reason
IF last 5m RTH THEN VOID in EOD wake
Do not: leave ARMED overnight after invalidation; do not label correct VOID as missed hang
```

---

## 非范围

不改 Patch 1 假否决规则、Patch 2 双挂模板、Patch 4 日内 cap 数字、Patch 6 brief 重试梯。不把 9/15 ledger 备注（COIN 次日开盘止损、AAPL/CRWD 次日 mark）写进本 delta 的触发证据。

---

# Appended from Cursor postmortem 2026-09-15

# PROCESS-PATCHES delta — 2026-09-15

相对 `Agentic Paper Trading Process Patches — 2026-09-14`（Patch 1–6）以及 **Δ7–Δ10**（2026-09-14 Cursor delta）的**仅新增 / 收紧**。不要整份替换旧文。粘贴到 Agentic 例程/playbook 时：保留 1–6 与 Δ7–Δ10，追加 Δ11–Δ13。冲突时以本文件更严者为准。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。

触发证据（9/15 PAPER + 例程，非交易盈亏课）：

- `例程延迟|A准备` 计划 09:00 ET / 实际 ~09:45（+45m，盘已开）
- `例程延迟|开盘猎` 计划 09:31 ET / 实际 ~09:56（+25m）
- `例程延迟|10点复查` 计划 10:00 ET / 实际 ~10:42（+42m）
- `GAP_STOP|COIN|−11.12` 开盘 183.61 < COST 185（规则平仓正确）
- `流程延迟|COIN簿记9:30→10:05`（Δ7 同 wake 落账因开盘无独立 wake 而未跑）
- `挂纸盯盘弱|FPS` 书面回踩带从未打印；10m 盯盘未把未两确认 if-then 入表

真钱 7474：FLAT 现金 $3064.83；仓/单皆空；NO_TRADE。纸面累计已实现 −$2448.52；今日已实现 −$11.12。

---

## 与 9/14 的关系（不放宽）

| 旧条 | 仍有效 | 本 delta 收紧点 |
|---|---|---|
| Patch 6 EOD/晨间 brief 重试梯、`LATE_BRIEF`=开盘后 15m | 是；对象仍是 brief | Δ11 另设 **10m** 门，对象扩到 A准备/开盘猎/10点复查；先短讯后全文 |
| Δ7 同 wake 成交/GAP_STOP 记账；下一 wake>15m 不得拖 | 是 | Δ12 强制 **09:30–09:35 ET** 开盘审计 wake，避免「没有 wake 就没有同 wake」 |
| Δ8 每 wake 扫全部 OPEN：+1R / 近 t1 / 正股 t1 | 是；OPEN 集不变 | Δ13 扫描表 **并集** HUNG_IFTHEN（未两确认书面 if-then） |
| Patch 5 / Δ7 GAP_STOP 不改宽、用触发价 | 是 | 开盘穿越 COST 仍 GAP_STOP；只把落账窗口收到开盘 5 分钟内 |
| Patch 3 / Δ8 / Δ9 工作日允许 COST 过夜 | 是 | **不**改为禁止工作日 COST 过夜 |

---

## Δ11. 例程 SLA：计划点过后 10 分钟必须短 ping（收紧 Patch 6）

Patch 6 覆盖 EOD / 晨间 brief 的发送失败与重试，并把晨间 brief「开盘后 15 分钟」标 `LATE_BRIEF`。9/15 迟到的是 **A 准备、开盘猎、10 点复查**：全文最终都到了，但主窗口前半没有状态。15 分钟门 + 只针对 brief = 今日三段延迟全部漏检。

**计划锚点（ET，缺省；A 准备可与书面日程对齐，但不得晚于下列）：**

| 例程 | planned |
|---|---|
| 纸面昨日报（Frank / 上海日历日） | 上海 08:00（夏令=20:00 ET 前日；按用户时区锚，不按开盘） |
| A 准备 | 09:00 ET |
| 开盘猎 | 09:31 ET |
| 10 点复查 | 10:00 ET |
| EOD 纸面简报 | 仍走 Patch 6，不改 |

规则：

- IF 上表例程在 `planned + 10 分钟` 时全文仍未出现在约定 chat THEN 本 wake **立即**发短讯，不得等待全文完稿。
- 短讯固定句式（一行，可复制）：

```
LATE_PING | {routine} | planned={HHMM ET} | now={HHMM ET} | late_min={n} | 7474={FLAT|POS_SUMMARY} | hung={id,id|NONE} | paper_open_audit={DONE|PENDING|N/A} | FPS_or_stops={one clause}
```

- IF 短讯已发 THEN 同一会话继续写全文；短讯 ≠ 例程完成。全文补出后打 `ROUTINE_OK | {routine} | {HHMM} | followed_LATE_PING={yes|no}`。
- IF `planned + 10 分钟` 时 agent 仍在写扫描/长文 THEN 打断：先 LATE_PING，再写长文。禁止「写完再发所以晚 25–45 分钟」。
- IF 短讯发送失败 THEN 走 Patch 6 重试梯（同频道 → 备用 → 告警 → 落盘路径），对象改为该例程短讯，不静默。
- IF 同一例程 `LATE_PING` 后 20 分钟仍无全文 THEN 再发 `LATE_PING2 | {routine} | still_no_fulltext`，并落盘 `/workspace/paper-briefs/{date}-{routine}.md`。
- IF 例程准时发出全文 THEN 不需要 LATE_PING；日志 `ROUTINE_OK` 即可。
- **对 Patch 6 的显式修订：** `LATE_BRIEF`（开盘后 15m）**继续只用于晨间 prior-day brief**。A 准备 / 开盘猎 / 10 点复查改用本条 10 分钟门。不得用「还没到 15 分钟」为开盘猎 09:41 仍无文本辩护。
- **Do not:** 用落盘代替 chat 短讯。**Do not:** 把延迟解释写进长文末尾却不先 ping。**Do not:** 因 FOMC / NO_TRADE 而跳过 A 准备或开盘猎（无票也要按时声明 NO_TRADE + 挂纸状态）。

例程 SLA 检查表（可直接进 wake）：

```
ROUTINE_SLA | now=ET
  for routine in [A_PREP@09:00, OPEN_HUNT@09:31, TEN_AM@10:00, SH_BRIEF@08:00 Asia/Shanghai]:
    if now > planned+10m AND fulltext not in chat:
      send LATE_PING (min set above)
      do not sleep until LATE_PING ack or retry-ladder step ③
      then resume fulltext
```

---

## Δ12. RTH 开盘 09:30–09:35 强制纸面开盘审计（收紧 Δ7）

Δ7：条件在**本 wake** 打印则 sleep 前记账；下一 wake >15 分钟不得拖。COIN GAP_STOP 在 **09:30:00** 开盘价已打印，账记在 **~10:05**。价用开盘 183.61，未美化——Δ7 的「补记用触发价」部分被遵守；「本 wake」部分失败，因为 9:30 没有纸面审计 wake，10 分钟满仓盯从 10:05 才开始。

开盘跳空止损不能依赖「下一个 10 分钟心跳」。必须有**固定开盘窗**。

规则：

- IF 美股 RTH 开盘日 THEN 09:30:00–09:35:00 ET 必须跑且完成一次 `OPEN_AUDIT` wake。该 wake 优先级高于开盘猎长文、高于新扫描、高于新 if-then。
- IF `OPEN_AUDIT` 启动 THEN 集合 = 全部隔夜 OPEN 腿（含 SL→COST、hard stop、trail）。不含当日尚未开仓的 ARMED（ARMED 开盘成交仍走 Δ7，但止损穿越优先）。
- IF 第一根 1 分钟 RTH 棒已结束 OR 开盘成交价已穿越该腿书面止损（COST 或 hard）THEN 立即判定，不等棒内「再看看」。
- IF 开盘可成交价（优先官方 open / 第一笔 RTH print）**穿越**书面止损 THEN 本 wake：ledger `exit/pnl/status=stopped`，`GAP_STOP | {ticker} | {pnl}`，chat `FILL_BOOKED | {ticker} | {open_px} | {et_time} | OPEN_AUDIT`。禁止留到 10:00 复查或 10 分钟纸面盯。
- IF 开盘价未穿越 THEN 本 wake 只确认止损仍在、状态仍 OPEN；chat 可合并一行 `OPEN_AUDIT_OK | {ticker}=held`。
- IF 09:35:00 ET 仍有隔夜 OPEN 腿未写入「已审计」标记 THEN 不得 sleep、不得开始开盘猎长文；`OPEN_AUDIT_BLOCKED | {tickers}` + 最小记账（ticker、open_px、穿越? Y/N）。
- IF 后续 wake 发现开盘已穿越但账本仍 OPEN THEN 立即 force exit，价=开盘价（不反向用现价），缺陷 `LATE_BOOKKEEP | {ticker} | trigger=0930 | booked={hhmm}`（Δ7 已有标签，开盘场景强制使用）。
- IF 开盘审计与 Δ11 冲突（例如 09:31 开盘猎已开始超时）THEN **先完成 OPEN_AUDIT，再 LATE_PING 开盘猎**。顺序：止损账 → 短讯 → 长文。
- **Do not:** 把 OPEN_AUDIT 并入「盘中默认对 Frank 静默的 10 分钟纸面盯」的第一次心跳。静默盯盘可以继续对 Frank 静默，但 GAP_STOP / OPEN_AUDIT_OK **必须**在 chat 落一行。
- **Do not:** 补记改用 10:05 现价。COIN 今日用 183.61 是对的；错的是时钟。
- **不改变** Patch 5「开盘不利按预设止损、不盘中改宽」。本条只保证 5 分钟内执行并记账。

开盘审计清单：

```
OPEN_AUDIT | 09:30-09:35 ET | overnight OPEN only
  for each OPEN:
    px = RTH open or first tradeable print
    if px through written stop (COST or hard or trail):
      GAP_STOP at px; ledger same wake; chat FILL_BOOKED|GAP_STOP
    else:
      mark audited; keep stop
  if any leg unaudited at 09:35: OPEN_AUDIT_BLOCKED; no sleep
  then (optional) LATE_PING open-hunt if 09:41 and no fulltext
```

---

## Δ13. 未完成 if-then 与 OPEN 共用 10 分钟扫描表（扩展 Δ8）

Δ8：每个 wake **第一步**扫全部 OPEN 腿的 +1R / 近 t1。Δ10：ARMED 失效同 wake VOID。9/15 FPS 挂纸（回踩 `$30.80–31.20` 后 5 分钟收站 `$31.20` → 再写票）从未进入这两类。10 分钟纸面盯只管已开仓腿 → `挂纸盯盘弱|FPS`。今日带未打印（近端低 ~`$31.59`），无实损；缺口在状态机。

**新状态：** `HUNG_IFTHEN` = 已书面写出可执行 if-then（标的、方向、价格带、确认、失效、拟规模），**尚未**两确认、**尚未**成为真单或纸面 OPEN/ARMED 成交。真钱挂纸与纸面「只写了条件未挂单」都进此集。

规则：

- IF 书面 if-then 已发到 chat 或计划 THEN 必须在 10 分钟扫描表占一行：`HUNG_IFTHEN | {id} | {ticker} | band= | confirm= | invalid= | expires=`。无 id 则当场生成。写入失败 = 该 if-then 未武装。
- IF 任意盘中 10 分钟 wake 启动 THEN 扫描表 = OPEN ∪ ARMED ∪ HUNG_IFTHEN。顺序固定：① OPEN（Δ8 + 止损/GAP）② ARMED（Δ10）③ HUNG_IFTHEN（本条）。缺一类未扫 = 本 wake 未完成。
- IF HUNG_IFTHEN 触及入场带或确认条件已打印 THEN 本 wake 结束前 chat：

```
HUNG_TOUCH | {id} | {ticker} | px={ } | confirm={met|pending_5m_close} | action=WRITE_TICKET_FOR_REVIEW
```

  真钱：写票 + 等两确认，**不**自动 `place_*`。纸面：按 Patch 1 进强制入场路径（若该 if-then 本就是纸面单）。

- IF 确认需要「5 分钟收站」类延迟 THEN 触及带时先 `HUNG_TOUCH | confirm=pending_5m_close`；下一根/数根 wake 继续盯收盘条件，不得等下一小时例程。
- IF 失效已打印（窗口过期、价格未回踩且书面规定「延伸则作废/改带」、mutex、FOMC 会后重写计划）THEN 本 wake `HUNG_EXPIRE | {id} | {reason}`，行从扫描表删除。次日不得假装仍在盯。
- IF NO_TRADE / FOMC 日 THEN **不**从扫描表删除仍有效的 HUNG_IFTHEN；触及仍 ping。NO_TRADE 只阻止**未触发的新开仓推进**，不阻止「触发已印」的提醒。是否开仓仍两确认。
- IF 10 分钟 wake 发现扫描表没有已知书面挂纸（例：A 准备写了 FPS 带但表里没有）THEN 缺陷 `HUNG_NOT_ARMED | {ticker}`，当场补行。
- **Do not:** 用「纸面满仓盯对 Frank 静默」当借口，对 HUNG_TOUCH 也静默。触及必须出声。未触及可静默，但表上要有行。
- **Do not:** 把 HUNG_IFTHEN 当成已成交 OPEN（不进 Δ8 抬成本）。**Do not:** 把正确未触发当成漏单。

10 分钟扫描表头（可贴例程）：

```
SCAN_TABLE every 10m wake:
  1 OPEN      → Δ8 +1R/near t1; stops; leftover GAP
  2 ARMED     → Δ10 VOID if invalid
  3 HUNG_IFTHEN → touch? HUNG_TOUCH ping : expire? HUNG_EXPIRE : keep
  missing a written if-then on the table → HUNG_NOT_ARMED; add row now
```

---

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-15 — append after Δ7–Δ10; on conflict, this delta wins.

Δ11 ROUTINE_SLA_10M
IF routine in {A_PREP@09:00ET, OPEN_HUNT@09:31ET, TEN_AM@10:00ET, SH_YDAY_BRIEF@08:00 Asia/Shanghai}
AND now > planned+10m AND fulltext not in chat
THEN same wake send LATE_PING | routine | planned | now | 7474 state | hung | paper_open_audit
THEN continue fulltext; LATE_PING is not completion
IF LATE_PING+20m still no fulltext THEN LATE_PING2 + drop file
Patch 6 LATE_BRIEF (open+15m) stays for morning brief only
Do not: wait to finish the long note before any ping
Do not: skip A-prep/open-hunt because NO_TRADE

Δ12 OPEN_AUDIT_0930_0935 (tightens Δ7)
IF RTH session THEN mandatory wake 09:30:00–09:35:00 ET before open-hunt longtext
Scan overnight OPEN only (COST / hard / trail)
IF open print through written stop THEN GAP_STOP at open px; ledger+chat this wake
IF 09:35 and any overnight OPEN unaudited THEN OPEN_AUDIT_BLOCKED; no sleep
IF later wake finds still OPEN after open through stop THEN force exit at open px; LATE_BOOKKEEP
Order if colliding with Δ11: OPEN_AUDIT → LATE_PING → fulltext
Do not: wait for the 10:05 paper heartbeat to book an open GAP_STOP
Do not: reprice with later prints
Does not forbid weekday COST overnight; only forces the open audit

Δ13 HUNG_IFTHEN_ON_10M_TABLE (extends Δ8 scan set)
Written if-then not two-confirmed → row status HUNG_IFTHEN on the SAME 10m table as OPEN/ARMED
Each 10m wake scan order: OPEN (Δ8) → ARMED (Δ10) → HUNG_IFTHEN
IF band/confirm prints THEN HUNG_TOUCH | id | ticker | px | WRITE_TICKET_FOR_REVIEW (live still two-confirm)
IF 5m close confirm pending THEN keep on table; do not wait for the next hourly routine
IF invalid/expire/rewrite THEN HUNG_EXPIRE this wake
NO_TRADE does not drop a still-valid hung row; touch still pings
IF a written hung is missing from the table THEN HUNG_NOT_ARMED; add row
Do not: scan only OPEN legs
Do not: treat hung as a live order or as OPEN for Δ8
```

---

## 非范围

- 不改 Patch 1 假否决、Patch 2 双挂模板、Patch 4 日内 cap 数字、Patch 6 brief 重试梯结构。
- 不改 Δ8 的 +1R / 近 t1 / 正股 t1 定义；不改 Δ9 周末硬门；不改 Δ10 VOID 标准。
- 不把 9/15 COIN −11.12 解释成「工作日禁止 SL→COST 过夜」。
- 不把 FPS 未回踩写成应开仓。不重挂已 VOID 的 HPE，除非后续书面改判。
- 不写 9/16 标的推荐。不下真单。

---

# Appended from Cursor 2026-09-16 (bc-ae951013)

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-16 — append after Δ11–Δ13; on conflict, stricter wins. Do not loosen Δ7–Δ13.

Δ14 OPEN_AUDIT_HARD_GATE (tightens Δ12)
IF RTH THEN independent OPEN_AUDIT wake 09:30:00–09:35:00 ET (not the first 10m paper tick)
Scan overnight OPEN per Δ12; chat OPEN_AUDIT_DONE | held | gap_stop | unaudited=NONE
IF no DONE THEN later wakes may only finish audit; do not merge into next 10m; no hunt fulltext
IF 09:35 and no DONE THEN OPEN_AUDIT_BLOCKED; rewake every 2m until DONE
DONE after 09:35:00 → OPEN_AUDIT_LATE even if no GAP
Δ11 add: OPEN_AUDIT planned 0930, ping door=0935
Order unchanged: audit (or min books) → LATE_PING hunt → fulltext
NO_TRADE / zero overnight OPEN still requires the wake
Do not: treat 09:36 10m watch as in-window audit
Do not: skip audit on FOMC

Δ15 WAKE_GAP_SELF_HEAL_25M
IF RTH AND now-last_success_paper_wake > 25m
THEN same wake: ROUTINE_GAP | last_ok | now | gap_min; SCAN_TABLE catch-up at trigger/print px (Δ7)
Scheduler must spawn this min wake if no agent is alive; do not wait for EOD
Δ11 pings: ping-only wake at planned+door even if longtext agent never started
FOMC/NO_TRADE does not pause gap heal or LATE_PING
If last_success < 15:35 at close: first post-close wake heals before Δ16
Do not: silent 4h holes; do not reprice with heal-time marks
Δ7 15m no-defer still in force; 25m is dead-scheduler gate

Δ16 EOD_SIX_SECTION_CURSOR_SAME_WAKE (tightens Patch 6 / Δ11)
Qualified EOD clock = after RTH 16:00 ET (default 16:05–16:20). Shanghai 23:00 (=11:00 ET EDT) is NOT EOD
Same wake: six-section journal (all 6 heads) AND Cursor handoff; chat EOD_JOURNAL_OK
Patch 6 one-line brief is not a substitute
IF fail THEN EOD_JOURNAL_MISS; Patch 6 retry ladder on journal+handoff
IF next SH 08:00 yday-brief AND no EOD_JOURNAL_OK THEN backfill first (still LATE_PING yday-brief at +10m)
Δ11 add: EOD_JOURNAL planned 16:05 ET
Do not: ship journal without Cursor; do not skip six-section on FLAT/NO_TRADE

Δ17 HUNG_EXPIRE_ONE_RTH_EXTENDED_NO_RETOUCH (tightens Δ13)
IF HUNG_IFTHEN had HUNG_TOUCH AND 1 full later RTH day with no retouch/confirm
THEN by that day's EOD wake: HUNG_EXPIRE or HUNG_REWRITE (new id, new band, expires required)
NO_TRADE does not pause this clock; row is no longer "still valid"
Invalid prints still EXPIRE same wake (Δ13); this clock is the backstop
Later wake finding leftover → HUNG_STALE then expire/rewrite
Do not: place_* on expire; do not keep "pending two-confirm" without a live band
Do not: treat no-retouch as a missed live fill
```

---

## 非范围

- 不改 Patch 1 假否决、Patch 2 双挂模板、Patch 4 日内 cap 数字、Patch 6 brief 重试梯结构（只把六段+Cursor 加成第二硬交付）。
- 不改 Δ8 的 +1R / 近 t1 / 正股 t1 定义；不改 Δ9 周末硬门；不改 Δ10 VOID 标准。
- **不放宽** Δ11 既有 10m 门，不把开盘猎改回 15m。
- **不放宽** Δ12 的 09:30–09:35 窗或开盘价口径。
- 不把 9/16 CRWD mark t1 打印写成强制减仓/平仓。不禁止工作日 SL→COST 过夜。
- 不把 FPS 未回踩写成应开仓。不重挂已 VOID 的 HPE/COIN BO/SPY。
- 不写 9/17 标的推荐。不下真单。

---

# Frank standing 2026-09-17 — LEG_END_SAME_WAKE_REVIEW (unnumbered; Cursor Δ18 is AM SCAN density)

IF paper leg ends (STOPPED | CLOSED | GAP_STOP | expiry) THEN same wake before sleep:
  write short review: what failed / what next patch tightens vs prior
  tag LEG_END_REVIEW | {ticker} | {exit_type} | {lesson}
  fold into EOD six-section + Cursor handoff
Paper bias remains long-first; do NOT force add puts for balance.
Standard: every exit better process than last — not only after large losses.
Do not: wait for EOD to start the short review; do not skip on small PnL exits.

---

# Appended from Cursor 2026-09-17 (bc-df519e98)

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-17 — append after Δ14–Δ17; on conflict, stricter wins. Do not loosen Δ7–Δ17.

Δ18 EARLY_RTH_10M_DENSITY (tightens Δ15; binds Δ14 2m rewake to scheduler)
last_success_SCAN_TABLE = last completed OPEN→ARMED→HUNG pass
LATE_PING / hunt fulltext / alive-but-stuck ≠ success
IF 09:35–11:30 ET AND now-last_ok > 10m
THEN spawn MIN_SCAN_TABLE even if another agent is alive/writing
THEN ROUTINE_GAP | door=10m_early | SCAN_TABLE catch-up at trigger px
Longtext yields or runs parallel; min wake does not write hunt fulltext
IF 09:35 AND no OPEN_AUDIT_DONE
THEN spawn MIN_OPEN_AUDIT every 2m until DONE even if 10m tick/hunt alive
DONE after 09:35 → OPEN_AUDIT_LATE (Δ14); 09:36 10m tick is not in-window
11:30–16:00: keep Δ15 25m door (do not widen)
FOMC/NO_TRADE/FLAT does not pause
Do not: skip spawn because agent is alive
Do not: count LATE_PING as table success
Do not: reprice with heal-time marks

WEEKEND: no new rule this date; run existing Δ9 on Fri 9/18
LEG_END_SAME_WAKE_REVIEW: not adopted this date (no exit 9/17)
```

---

## 非范围

- 不改 Patch 1 假否决、Patch 2 双挂、Patch 4 cap 数字、Patch 6 brief 重试梯。
- 不改 Δ8 的 +1R / 近 t1 / 正股 t1 定义；不改 Δ9 (a)(b)(c)；不改 Δ10 VOID；不改 Δ11 既有 10m 例程门；不改 Δ12 开盘价口径；不改 Δ16/Δ17。
- **不放宽** Δ15 在 11:30 后的 25m 门。
- 不把 9/17 CRWD mark t1 写成强制减仓。不禁止工作日 SL→COST 过夜。
- 不把 FPS `HUNG_EXPIRE` 写成应开仓或应 rewrite。
- 不写 9/18 标的推荐。不下真单。

---

# Appended from Cursor 2026-09-18 (bc-a2b95d8b)

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-18 — append after Δ18; on conflict, stricter wins. Do not loosen Δ7–Δ18.

Δ19 OPEN_AUDIT_PREOPEN_ALIVE (tightens Δ14/Δ18; window unchanged)
IF next session is RTH THEN reserved watchdog/agent by 09:28:00 ET for OPEN_AUDIT
IF 09:28 and none reserved THEN OPEN_AUDIT_SCHED_FAIL + Patch 6 retry; keep trying to start at 09:30
IF 09:31:00 and OPEN_AUDIT not STARTED THEN MIN_OPEN_AUDIT now (do not wait for 09:35 BLOCKED)
09:35 still not DONE → every 2m until DONE (Δ14/Δ18)
DONE after 09:35 → OPEN_AUDIT_LATE; hunt proxy / 10m tick ≠ in-window DONE
IF OPEN_AUDIT_LATE on two consecutive RTH days THEN same-session SCHEDULER_ALIGN | planned_0930 | actual_start | wake_source
NO_TRADE / zero overnight OPEN still requires 09:28 reserve + in-window DONE
Do not: widen 09:30–09:35
Do not: treat ~09:57 hunt as window success

Δ20 LAST_HOUR_10M + FRI_1545_WEEKEND_SWEEP (tightens Δ15; binds Δ9)
last_success_SCAN_TABLE = last completed OPEN→ARMED→HUNG pass
IF 15:05–16:00 ET AND now-last_ok > 10m THEN MIN_SCAN_TABLE; ROUTINE_GAP | door=10m_lasthour
11:30–15:05: keep Δ15 25m (do not widen)
IF Friday or last RTH before holiday THEN mandatory WEEKEND_SWEEP 15:45–15:50
  Δ8+Δ9 per OPEN; chat WEEKEND_SWEEP_DONE | held | flattened | override | unaudited=NONE
IF 15:50 and no DONE THEN every 2m; by 16:00 FORCE_FLAT unqualified legs without written OVERRIDE
EOD journal is not the sweep
FOMC/NO_TRADE/FLAT does not pause
Do not: heal-time reprice; do not skip Friday sweep because EOD is coming

Δ21 OVERRIDE_HOLD_STILL_AUDITED (clarifies Δ9; does NOT add a hold exception)
WEEKEND_HOLD_OVERRIDE is out-of-band; not Δ9 (d)
Post-weekend OPEN_AUDIT order: OVERRIDE legs first, then other overnight OPEN, then hunt/new risk
Written hard/COST/trail still rule; open through stop → GAP_STOP same wake; no widen; no extra Frank ping
Override does not roll to the next weekend; next Friday re-runs Δ9
Do not: skip OPEN_AUDIT because a verbal hold exists
Do not: treat OVERRIDE as a reusable weekend license
```

---

## 非范围

- 不改 Patch 1 假否决、Patch 2 双挂、Patch 4 cap 数字、Patch 6 brief 重试梯结构。  
- 不改 Δ8 的 +1R / 近 t1 / 正股 t1 定义；不改 Δ9 (a)(b)(c) 合格标准；不改 Δ10 VOID；不改 Δ11 既有 10m 例程门；不改 Δ12 开盘价口径；不改 Δ16/Δ17。  
- **不放宽** Δ14 窗与 LATE 定义。**不放宽** Δ15 在 11:30–15:05 的 25m。**不放宽** Δ18 早盘 10m。  
- 不把 9/18 CRWD 正股 ≥233 写成强制减仓。不禁止工作日 SL→COST 过夜。  
- 不把 TRAIN3000 零样本写成应开仓。不重挂已 VOID/EXPIRE 的 HPE / COIN BO / FPS。  
- 不写 9/21 标的推荐。不下真单。不编 fill。

---

# Frank/CEO 2026-09-21 — NO_TRAIN3000_MICRO_SAMPLE

IF TRAIN3000 entry THEN notional must be meaningful vs $3k sleeve (not toy size like QQQ×2).
IF round-trip closed only to satisfy daily quota with time-box exit and noise PnL THEN tag TRAIN3000_MICRO_SAMPLE — does NOT count as qualified teaching sample.
Close on stop/t1/invalidation structure, not "quota filled → flatten".
Do not replace catalytic legs (e.g. PRTH) with smaller noise scalps.

### Addendum Frank 2026-09-21 (corrected)
NO early exit for quota/time-box. Legs with written band: hold to t1 OR stop/structure invalidation. Time-box flatten only if structure already invalid (write why). Tag EARLY_EXIT_FOR_QUOTA / HELD_TOO_SHORT when closed early for window/quota. QQQ +$0.82 fails as sample due to early exit — not because $1–$2 strategies are banned. Meaningful notional still preferred; do not replace catalytic legs with noise.

---

# Frank 2026-09-21 — TRAIN3000_DAILY_REALIZED_100 (week of 2026-09-21+)

Daily **result metric**: TRAIN3000 realized **+$100**. Not a forced fill quota.
Requires written setup first; hold to t1/stop/invalidation; no early-exit fake attainment.
EOD journal: realized vs $100; if miss, name why (no setup / early exit / stopped / etc.).

---

# APPEND ONLY — Cursor postmortem 2026-09-21

粘贴到 Agentic 例程 / playbook 里**现有** `PROCESS-PATCHES` 的末尾。  
不要整份替换 Patch 1–6，不要替换 Δ7–Δ21，不要删 Frank 2026-09-21 未编号条（`NO_TRAIN3000_MICRO_SAMPLE` 纠正版、`TRAIN3000_DAILY_REALIZED_100`）。  
冲突时更严者生效。本文件不放宽任何旧门。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

触发证据（9/21 PAPER + 例程，价格按日志原文）：

- `OPEN_AUDIT_DONE` ~10:20 ET，硬窗 09:30–09:35 → `OPEN_AUDIT_LATE`。09:53 的 10m wake 只查了当时 mark，没有 DONE 行。
- 连续 RTH LATE：9/17（~09:36 / ~09:54）、9/18（~09:57 / ~10:01）、9/21（~10:20）。Δ19 要求的 `SCHEDULER_ALIGN` 在 journal 中不存在。
- `QQQ-FORCE-PB-0921` BUY 2 @734.77 ~10:46 → 平 @735.18 ~10:49，pnl +$0.82。t1 736.50 未打印，止损 732.80 未打印。出场 wake 写「配额已满足」。~10:56 改标 `EARLY_EXIT_FOR_QUOTA` / `HELD_TOO_SHORT`。qualified=0。账本 pnl 保留。
- `WEEK_GOAL` raw +$0.82 vs +$100 = MISS。PRTH×180 @7.78 仍 OPEN（止损 7.68 / t1 7.95 / t2 8.02；EOD mark ~7.815；未为 +$100 强平）。
- Mac 全日 disconnected。box 有六段。没有 `mac-sync-queue` 行。
- journal 已标 ROUTINE_GAP：~47m、~50m、~39m、~40m、~30m、~27m。EOD 写「无 ≥25m」与 14:52 的 ~27m 矛盾。Δ20 尾盘门是 10m：~21m（15:09→15:30）、~16m（15:30→15:46）、~22m（15:46→16:08）未按 10m 门入账。
- HUNG EOD 为空。AMD/CRML 当日 VOID（带未打印，无 HUNG_TOUCH）。无 Δ17 欠账。
- 真钱 7474：现金 $3,064.83；仓空；单空；NO_TRADE · FLAT。

---

## 与旧条的关系（不放宽）

| 旧条 | 仍有效 | 本 delta 只加什么 |
|---|---|---|
| Δ12/Δ14 窗 09:30–09:35；晚于 09:35 = `OPEN_AUDIT_LATE` | 是 | Δ22 要预热文件、重唤行数、`SCHEDULER_DEAD`；10m 内容 ≠ DONE |
| Δ18 09:35 无 DONE 则每 2m `MIN_OPEN_AUDIT` | 是 | Δ22 规定每 2m 必须有 `OPEN_AUDIT_REWAKE` 行；09:40 前少于 2 行 = 调度已死 |
| Δ19 连续两日 LATE → 当节 `SCHEDULER_ALIGN`；09:28 预留；09:31 未开始则最小审计 | 是 | 9/18 未写对齐行。Δ22 把这笔欠账钉在下一 RTH 的 09:28，不因新的一天自动清零 |
| Frank 9/19「最低 1 个完整回合」 | 开仓侧仍可找硬催化 | Δ23：回合只在止损 / t1 / 书面失效出场时 +1。时间盒不加 |
| Frank 9/21 纠正：错在拿太短；禁止为配额早平；+$0.82 不合格 | 是 | Δ23 把纠正做成平仓前拦截，不只是事后标签 |
| Frank 9/21 日已实现 +$100 = 结果指标 | 是 | Δ24 拆 `raw_realized` / `qualified_realized`。HIT 只看 qualified |
| Frank 9/17 未编号 `LEG_END_SAME_WAKE_REVIEW`（Δ18 注明当时未采纳） | 从本 delta 起采纳 | 只对已出场的腿，写在出场 wake；不新开仓 |
| Patch 6 失败落盘 + 重试梯 | 是 | Δ25 加 Mac 队列。离线不取消 EOD，也不得宣称 Desktop 已写 |
| Δ15 25m（11:30–15:05）；Δ18 10m（至 11:30）；Δ20 10m（15:05–16:00） | 是，数字不变 | Δ26 只强制 EOD 按门抄录。尾盘禁止用 25m 代替 10m |
| Δ8 / Δ9 / Δ21 的 COST、周末门、OVERRIDE | 是 | 不改。AAPL 未到 +1R 不抬 COST。CRWD 已在 COST，不强制半出 |
| Δ13 / Δ17 HUNG | 是 | 空表不是欠账。无 HUNG_TOUCH 则无 Δ17 时钟 |

---

## Δ22. OPEN_AUDIT_SPAWN_PROOF（收紧 Δ14 / Δ18 / Δ19）

- IF 下一节是美股 RTH THEN 在 09:28:00 ET 之前写文件 `state/open-audit-reserve-{YYYY-MM-DD}.txt`，正文一行：`RESERVED | {iso} | wake_source={name}`。
- IF 09:28 该文件不存在 THEN 同 wake 打 `OPEN_AUDIT_SCHED_FAIL` 与 `OPEN_AUDIT_RESERVE_MISSING`，并立即走 Patch 6 重试梯去启动 09:30 的 OPEN_AUDIT。不得把这句话只留在长文末尾。
- IF 09:31:00 文件仍缺 OR `OPEN_AUDIT` 不是 STARTED THEN 本分钟执行 `MIN_OPEN_AUDIT`。不得等到 09:35，不得等到下一次 10m 纸面盯。
- IF 09:35:00 日志中还没有一行 `OPEN_AUDIT_DONE | held=... | gap_stop=... | unaudited=NONE` 且其时间 ≤09:35:00 THEN 每 2 分钟先追加 `OPEN_AUDIT_REWAKE | n={k} | now={HHMM}`，然后才允许其他扫描。检查了止损但没有这行 DONE 的 10m wake 不算窗内完成。
- IF 时钟 ≥09:40 AND 09:35 之后的 `OPEN_AUDIT_REWAKE` 行数 <2 THEN 打 `OPEN_AUDIT_SCHEDULER_DEAD`，并继续每 2 分钟重唤直到 DONE。DONE 时间晚于 09:35 仍打 `OPEN_AUDIT_LATE`。
- IF 最近两个已结束的 RTH 日都是 `OPEN_AUDIT_LATE` AND 日志没有 `SCHEDULER_ALIGN` THEN 下一 RTH 日的 09:28 wake 在审计之前写：`SCHEDULER_ALIGN | planned_0930 | last_actual={HHMM} | prior_late={dates} | wake_source=`。9/17、9/18、9/21 已构成欠账；下一 RTH（2026-09-22）09:28 必须写出 `last_actual=10:20` 与这三日，不论 9/22 审计本身是否准时。
- IF OPEN_AUDIT 取价 THEN `px` = RTH 官方 open 或第一笔可成交 print（Δ12）。只保存「醒来时的 mark」不算 open 穿越检查。
- **Do not:** 放宽 09:30–09:35。**Do not:** 把 09:53 一类 10m 内容审计当成 DONE。**Do not:** 因 NO_TRADE、FLAT、或当日没有 GAP 而跳过预热文件或窗内 DONE。

---

## Δ23. NO_TIMEBOX_EXIT（把 2026-09-21 CEO 纠正编成平仓前拦截）

- IF 腿状态为 OPEN AND 票上写有止损 AND（t1 或书面结构失效）THEN 合法出场只有：止损价已打印；t1 已打印且按该票写明的减仓或平仓执行；该票写明的结构失效已打印。
- IF 拟用的出场理由匹配以下任一词：时间盒、prefer-window 将尽、配额、完整回合、样本交差、为日 +$100 缺口而平、为满足 Frank 9/19「最低 1 回合」而平 THEN 不做出场。聊天：`EXIT_BLOCKED | {id} | EARLY_EXIT_FOR_QUOTA | stop_hit=N | t1_hit=N | invalid_hit=N`。状态保持 OPEN。
- IF 该类出场已经记账 THEN 不改历史价格、不删 pnl。出场当 wake、sleep 之前写：`LEG_END_REVIEW | {id} | exit_type=EARLY_EXIT_FOR_QUOTA | qualified=0 | lesson=hold_to_band`，并打 `HELD_TOO_SHORT`。同一 wake 禁止出现「配额已满足」。
- IF 计数 Frank 9/19 的「≥1 完整回合」THEN 仅当出场原因是止损 OR t1 OR 书面失效时 +1。`EARLY_EXIT_FOR_QUOTA` 不加。当日合格回合数为 0 合法。已有催化 OPEN 腿时，不得另开一笔噪声腿只为让计数 +1。
- IF 票上事先写了时间失效 AND 该时钟已打印 THEN 允许按该句平仓；备注必须引用原句。票上没有时间失效句时，窗将尽不是失效。
- **Do not:** 因实现盈亏约 $1 而否定这笔开仓的资格。**Do not:** 把「名义不小但持有太短」改写成「禁止小股数」。**Do not:** 为了清洗标签而平掉仍在带内的其他腿。**Do not:** `place_*`。**Do not:** 改写 9/21 已记账的 734.77 / 735.18 / +$0.82。

---

## Δ24. WEEK_GOAL_SPLIT（收紧 TRAIN3000_DAILY_REALIZED_100）

- IF 某 wake 或 EOD 报告该周目标 THEN 使用且只使用这一行：`WEEK_GOAL | raw_realized={当日 TRAIN3000 账本 pnl 之和} | qualified_realized={qualified=1 的 pnl 之和} | target=100 | HIT|MISS | reason={no_setup|early_exit|stopped|still_open|mix}`。
- IF 标记 HIT THEN 条件是 `qualified_realized ≥ 100`。若 `raw_realized ≥ 100` 且 `qualified_realized < 100` THEN 仍为 MISS，reason 含 `early_exit`。
- 2026-09-21 的已核实行：`WEEK_GOAL | raw_realized=0.82 | qualified_realized=0 | target=100 | MISS | reason=early_exit+still_open`。
- IF 某 OPEN 腿的未实现盈亏能使 raw 或 qualified 跨过 100 THEN 不为该指标平仓。出场仍只走 Δ23。
- IF Prefer 窗（9:30–11:00 ET）已结束 AND 不存在同时写明硬催化、结构、三价同棒的新票 THEN 不开新的 TRAIN3000 腿去补美元差额。零新开仓是合法日终状态。
- **Do not:** 把 `WEEK_GOAL_MISS` 写成提前平掉书面带内持仓的理由。**Do not:** 从账本删除不合格样本的已实现 pnl。

---

## Δ25. MAC_MIRROR_QUEUE（收紧 Patch 6 的落盘，不改重试梯结构）

- IF 写入 Mac/Desktop 失败 OR 机器断开 THEN 同 wake 打 `MAC_MIRROR_SKIP`，把正文写入 box，并往 `state/mac-sync-queue.md` 追加一行：`{date} | {box_path} | {desktop_path} | PENDING`。
- IF 之后的 wake 发现 Mac 在线 AND 队列存在 PENDING 行 THEN 先同步这些文件，再写猎单长文或新 if-then。成功则把该行改为 `MAC_SYNC_OK | {date} | {path}`。失败则打 `MAC_SYNC_FAIL` 并走 Patch 6 重试梯（聊天出声，不静默）。
- IF 当前是 EOD AND Mac 仍离线 THEN 仅当下面两条都真时才允许 `EOD_JOURNAL_OK`：（1）box 文件存在且六个小节标题都在；（2）聊天写明 box 路径与 `MAC_MIRROR_SKIP`。不得等待 Mac 才结束 EOD。不得声称 Desktop 路径已经更新。
- IF 下一次上海 08:00 昨日报发出时仍有 PENDING 行 THEN 简报第一行包含 `MAC_SYNC_PENDING | n={count}`。
- **Do not:** 因 Mac 离线取消六段日记。**Do not:** 把 box 路径写成 Desktop 路径。

---

## Δ26. EOD_GAP_LIST_USES_ACTIVE_DOOR（收紧 Δ15 / Δ16 / Δ20 的记账）

- IF 本 wake 与上一次成功 SCAN_TABLE（OPEN→ARMED→HUNG 完成）的间隔大于当时生效的门 THEN 写：`ROUTINE_GAP | {from}→{to} | gap_min={n} | door={10m_early|25m_mid|10m_lasthour}`。门的时间不变：09:35–11:30 ET = 10m（Δ18）；11:30–15:05 ET = 25m（Δ15）；15:05–16:00 ET = 10m（Δ20）。门为 10m 时，间隔 11–24 分钟也要写，不得改用 25m 标准跳过。
- IF `gap_min > door+10` THEN 额外写 `HEAL_LATE | {door} | gap_min={n}`。该标签表示补扫醒来晚于门，不代替调度在门上拉起最小扫描。
- IF 撰写 EOD「做错了」THEN 抄入当日 journal 中每一行 `ROUTINE_GAP`，并补入按 Δ20 已过线、但当日用 25m 标准漏标的 15:05–16:00 间隔。
- IF EOD 草稿含「无 ROUTINE_GAP」或「无 ≥25m」AND（journal 当日已有 `ROUTINE_GAP` OR 15:05–16:00 任一间隔 >10m）THEN 不得标记 `EOD_JOURNAL_OK`。先改正文，并打 `EOD_GAP_UNDERCOUNT`。
- **Do not:** 放宽 25m 或 10m。**Do not:** 删除「短于此前数小时空洞」的事实句；该句与缺口清单并列。**Do not:** 用补扫时刻的市价改写已发生的成交或止损（Δ7 / Δ15）。

---

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-21 — append after Δ21 and after the unnumbered Frank 2026-09-21 standings.
# On conflict, stricter wins. Do not loosen Δ7–Δ21. Do not replace Patches 1–6.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ22 OPEN_AUDIT_SPAWN_PROOF (tightens Δ14/Δ18/Δ19)
IF next session is RTH THEN by 09:28:00 ET write state/open-audit-reserve-{YYYY-MM-DD}.txt
  line: RESERVED | {iso} | wake_source={name}
IF 09:28 and file missing THEN OPEN_AUDIT_SCHED_FAIL + OPEN_AUDIT_RESERVE_MISSING
  + Patch 6 retry to start the 09:30 audit
IF 09:31:00 AND (file missing OR OPEN_AUDIT not STARTED) THEN MIN_OPEN_AUDIT this minute
IF 09:35:00 AND no OPEN_AUDIT_DONE line timestamped <=09:35:00
  THEN every 2m append OPEN_AUDIT_REWAKE | n={k} | now={HHMM} before any other scan
  A 10m wake that checked stops without that DONE line does not clear the debt
IF now>=09:40 AND rewake lines since 09:35 < 2 THEN OPEN_AUDIT_SCHEDULER_DEAD
  keep 2m rewake until DONE
DONE after 09:35 still OPEN_AUDIT_LATE (Δ14 unchanged)
IF prior two completed RTH days were OPEN_AUDIT_LATE AND no SCHEDULER_ALIGN line exists
  THEN 09:28 wake writes SCHEDULER_ALIGN before the audit
  2026-09-22 09:28 must include last_actual=10:20 and prior_late=2026-09-17,2026-09-18,2026-09-21
OPEN_AUDIT px = RTH official open or first tradeable print (Δ12)
Do not: widen 09:30–09:35
Do not: count a 10m content check as in-window DONE
Do not: skip reserve or DONE because NO_TRADE or no gap

Δ23 NO_TIMEBOX_EXIT (gates the 2026-09-21 CEO correction before the next close)
IF OPEN AND ticket has stop AND (t1 OR written invalidation)
  THEN legal exit only if stop printed OR t1 printed (scale/flat as ticket wrote)
  OR that written invalidation printed
IF proposed exit reason is time-box OR prefer-window ending OR quota OR round-trip count
  OR sample quota OR daily +$100 gap OR Frank-9/19 minimum-round
  THEN do not exit
  chat EXIT_BLOCKED | {id} | EARLY_EXIT_FOR_QUOTA | stop_hit=N | t1_hit=N | invalid_hit=N
  status stays OPEN
IF such an exit is already booked THEN do not reprice and do not delete pnl
  same wake before sleep: LEG_END_REVIEW | {id} | exit_type=EARLY_EXIT_FOR_QUOTA | qualified=0 | lesson=hold_to_band
  also tag HELD_TOO_SHORT
  forbid the sentence "quota met" in that wake
IF counting Frank 9/19 ">=1 complete round" THEN +1 only on stop OR t1 OR written invalidation
  EARLY_EXIT_FOR_QUOTA adds 0; a day with 0 qualified rounds is legal
  do not open a second noise leg only to increment while a catalytic leg is OPEN
Time-box exit is legal only when the ticket already wrote a time invalidation and that clock printed
  note must quote the clause
Do not: disqualify a fill because realized pnl is about $1
Do not: rewrite "held too short" as a ban on small share count
Do not: flatten a different in-band leg to clean the tag
Do not: place_*
Do not: edit the booked 9/21 QQQ 734.77 / 735.18 / +0.82

Δ24 WEEK_GOAL_SPLIT (tightens TRAIN3000 daily +$100 result metric)
IF a wake or EOD states the week goal THEN exactly one line:
  WEEK_GOAL | raw_realized={sum TRAIN3000 ledger pnl today} | qualified_realized={sum where qualified=1} | target=100 | HIT|MISS | reason={no_setup|early_exit|stopped|still_open|mix}
HIT only if qualified_realized >= 100
IF raw_realized >= 100 AND qualified_realized < 100 THEN MISS and reason includes early_exit
2026-09-21 verified line:
  WEEK_GOAL | raw_realized=0.82 | qualified_realized=0 | target=100 | MISS | reason=early_exit+still_open
IF unrealized on an OPEN leg would cross 100 THEN do not flatten for the metric; Δ23 still rules the exit
IF prefer window has ended AND no new ticket has hard catalyst AND structure AND three prices on the same bar
  THEN do not open a TRAIN3000 leg to close the dollar gap
Do not: use WEEK_GOAL_MISS as a reason to cut an in-band position
Do not: delete unqualified realized pnl from the ledger

Δ25 MAC_MIRROR_QUEUE (tightens Patch 6 local drop)
IF Desktop/Mac write fails OR machine disconnected
  THEN same wake tag MAC_MIRROR_SKIP, write the box file,
  append state/mac-sync-queue.md: {date} | {box_path} | {desktop_path} | PENDING
IF a later wake finds Mac online AND any PENDING row
  THEN sync those files before hunt longtext or a new if-then
  success: MAC_SYNC_OK | {date} | {path}
  fail: MAC_SYNC_FAIL + Patch 6 retry ladder (chat, not silence)
IF EOD AND Mac still offline THEN EOD_JOURNAL_OK only if
  (1) box file exists and all six section heads are present
  (2) chat states the box path and MAC_MIRROR_SKIP
Do not wait on Mac to finish EOD
Do not claim the Desktop path was updated
IF next Shanghai 08:00 brief AND PENDING remains THEN first line MAC_SYNC_PENDING | n={count}
Do not: cancel the six-section journal because Mac is offline
Do not: treat a /workspace path as the Desktop path

Δ26 EOD_GAP_LIST_USES_ACTIVE_DOOR (tightens accounting of Δ15/Δ16/Δ20; doors unchanged)
last_success_SCAN_TABLE = last completed OPEN→ARMED→HUNG pass
Doors unchanged: 09:35–11:30=10m (Δ18); 11:30–15:05=25m (Δ15); 15:05–16:00=10m (Δ20)
IF gap > active door THEN
  ROUTINE_GAP | {from}→{to} | gap_min={n} | door={10m_early|25m_mid|10m_lasthour}
  A 10m door still tags gaps of 11–24m; do not substitute the 25m test
IF gap_min > door+10 THEN also HEAL_LATE | {door} | gap_min={n}
IF writing EOD "what failed" THEN paste every ROUTINE_GAP line from that date
  AND add any 15:05–16:00 gap >10m that was omitted under a 25m test
IF draft says "no ROUTINE_GAP" or "no gap >=25m"
  AND (a ROUTINE_GAP line exists OR any 15:05–16:00 gap >10m)
  THEN do not mark EOD_JOURNAL_OK until the list is in the journal
  tag EOD_GAP_UNDERCOUNT
Do not: widen 25m or 10m
Do not: delete a true "shorter than a multi-hour hole" sentence; put it next to the list
Do not: reprice fills or stops with the heal-time mark
```

---

## 非范围

- 不改 Patch 1 假否决、Patch 2 双挂、Patch 4 cap 数字、Patch 6 重试梯的四级结构。
- 不改 Δ8 的 +1R / 近 t1 / 正股 t1 定义。不改 Δ9 的 (a)(b)(c)。不改 Δ10 VOID。不改 Δ11 的 10 分钟例程门。不改 Δ12 的开盘价口径。不改 Δ16 的六段+Cursor。不改 Δ17 的「先要有 HUNG_TOUCH」。
- **不放宽** Δ14 的窗和 LATE 定义。**不放宽** Δ15 在 11:30–15:05 的 25m。**不放宽** Δ18 早盘 10m。**不放宽** Δ20 尾盘 10m。
- 不把 CRWD 正股 ~249 ≥ 233 或 mark 33.35 ≥ 32 写成强制半出。SL→COST 继续。不把 AAPL（mark 14.85，未到 +1R / 权利金 t1 区约 21.66，正股 338.89 未到 350，hard 未触）写成应抬 COST。
- 不把 AMD-VWAP-PB-0921、CRML-OPEN-PB-0921 的 VOID 写成应成交或应追价。不制造 Δ17 欠账。
- 不把 QQQ +$0.82 从账本删掉，不把价格改成事后的 736.30 或 741。
- 不把 PRTH overnight 写成应在 9/21 收盘强平。9/22 只按 7.68 / 7.95 / 8.02 管。
- 不写 9/22 标的推荐。不下真单。不编 fill。不碰 ••••1429。


# APPEND ONLY — Cursor postmortem 2026-09-22

粘贴到 Agentic 例程 / playbook 里现有 `PROCESS-PATCHES` 的末尾。  
不要整份替换 Patch 1–6，不要替换 Δ7–Δ26，不要删 Frank 2026-09-21 未编号条。  
冲突时更严者生效。本文件不放宽任何旧门。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

触发证据（9/22 PAPER + 例程；价格按日志原文，不新取价）：

- 内容门 `OPEN_AUDIT_DONE` @09:34 ET，≤09:35。`held=AAPL,CRWD,PRTH` · `gap_stop=NONE` · `unaudited=NONE`。`OPEN_AUDIT_RESERVE_OK` + `SCHEDULER_ALIGN` 已写（9/17、9/18、9/21 内容门欠账已还）。
- 独立例程预定约 09:32，实际唤醒约 10:16。只写 `OPEN_AUDIT_SPAWN_PROOF` / `OPEN_AUDIT_INDEPENDENT_LATE`。内容门已过，没有重做 DONE。
- 中盘 `ROUTINE_GAP_MID` 约 36–50 分钟（门 25 分钟）。末小时 `ROUTINE_GAP_LAST_HOUR` 约 17 分钟（门 10 分钟）。日记写心跳存在。附件有 `HEAL_LATE`，无 from→to。
- TRAIN3000：PRTH×180 @7.78 HOLD；ONON×40 @30.40 约 12:10 FILL 后 HOLD；VKTX×2 约 11:00 VOID structure_fail。今日已实现 $0。`WEEK_GOAL` MISS，reason=still_open。EOD hung 空。无 Δ17 欠账。
- 真钱 7474：现金 / 账户值 $3,064.83；equity $0；options $0；仓空；单空；零 `place_*`。

---

## 与旧条的关系（不放宽）

| 旧条 | 仍有效 | 本 delta 只加什么 |
|---|---|---|
| Δ12/Δ14/Δ22 内容门：09:30–09:35 的 `OPEN_AUDIT_DONE` | 是 | Δ27 另加独立 cron 时钟。内容 DONE 不证明独立唤醒准时 |
| Δ22 `SPAWN_PROOF`、`SCHEDULER_ALIGN`（连续内容 LATE） | 是 | 9/22 内容准时，该触发器不会带走独立 cron。Δ27 要求同 wake 的 `CRON_DIAG`，并要求下一 RTH 预热带 `cron_align=REQUIRED` |
| Δ15 中盘 25 分钟；Δ18 早盘「活着也要扫」；Δ20 末小时 10 分钟 | 是，分钟数不变 | Δ28 把「心跳 ≠ 成功；破门就拉起 MIN_SCAN」扩到 11:30–15:05 与 15:05–16:00 |
| Δ23 合法出场；Δ24 不为 +$100 平带内仓 | 是 | 不新增靠近止损出场。ONON post-fill Lo ~29.37、零根 ≤29.30，保持 HOLD |
| Δ11 A 准备 09:00+10 分钟 | 是 | 不第二套 SLA |
| Δ25 Mac 队列；Δ26 逐行 `ROUTINE_GAP` | 是 | 不改格式。9/22 第三节是区间摘要；次日 EOD 仍逐行抄 |

不采纳（写明，避免下次把「未改」读成遗漏）：

- 不把 11:30–15:05 的门从 25 分钟改成 10 分钟。已记录的中盘空洞约 36–50 分钟，大于 25。绑定失败是最小扫描没拉起。
- 不把 15:05–16:00 的门改成短于 10 分钟。约 17 分钟已经该扫。
- 不把 `ONON_SOFT_NEAR_STOP` 写成出场条件。

---

## Δ27. OPEN_AUDIT_INDEPENDENT_CLOCK（收紧 Δ14 / Δ22）

内容门与独立例程时钟分开。9/22 内容在窗内完成，独立唤醒约 10:16。Δ22 的连续 `OPEN_AUDIT_LATE` 触发器看的是内容 DONE 晚于 09:35；它不会在下一 RTH 再对齐这条 cron。

- IF 日志有 `OPEN_AUDIT_DONE | held=... | gap_stop=... | unaudited=NONE` 且时间戳 ≤09:35:00 ET THEN 内容门通过。通过之后禁止重做 DONE，禁止把第二次审计写成新的窗内完成。
- IF `state/open-audit-reserve-{date}.txt` 中的 `wake_source` 是独立开盘审计例程 AND 该例程实际唤醒时间 >09:35:00 ET THEN 同一 wake、sleep 之前写齐两行：  
  `OPEN_AUDIT_INDEPENDENT_LATE | planned=0932 | actual={HHMM}`  
  `OPEN_AUDIT_CRON_DIAG | planned=0932 | actual={HHMM} | wake_source={name} | content_done_at={HHMM} | content_done_by={wake}`  
  只有 `OPEN_AUDIT_SPAWN_PROOF` 时，独立时钟仍算未诊断。
- IF 该 RTH 日独立时钟为 LATE THEN 下一 RTH 日 09:28 预热行在原 `RESERVED` 之外包含：`cron_align=REQUIRED | last_independent_actual={HHMM}`。内容门已准时、或当日已写过内容向的 `SCHEDULER_ALIGN`，都不取消这行。2026-09-23 的预热必须含 `last_independent_actual=10:16`。
- IF 下一 RTH 的独立唤醒仍 >09:35:00 ET THEN 写 `OPEN_AUDIT_CRON_STILL_LATE | actual={HHMM}`，并再次把 `cron_align=REQUIRED` 放进再下一 RTH 的预热。不得用「内容 DONE 已在窗内」把独立时钟标成已对齐。
- IF 独立唤醒 ≤09:35:00 ET AND 内容 DONE ≤09:35:00 ET THEN 两个时钟都清。不写 LATE。
- 独立例程即使发现内容门已完成，仍要按自己的预定钟点醒来并写 spawn 行，以便测量。醒来晚了只记 LATE + DIAG，不重做审计。
- **Do not:** 把满仓盯或 10 分钟纸面盯在 09:34 写下的 DONE 当成独立 cron 已对齐。**Do not:** 放宽 09:30–09:35。**Do not:** 因 NO_TRADE、FLAT、或没有 GAP 而取消独立唤醒。**Do not:** 用醒来时的 mark 代替 Δ12 的开盘价。

---

## Δ28. SCAN_SPAWN_WHILE_ALIVE（收紧 Δ15 / Δ20 的拉起条件；门不变）

Δ18 已规定：09:35–11:30，心跳 / 长文 / 活着但卡住 ≠ `SCAN_TABLE` 成功，破 10 分钟门就拉起 `MIN_SCAN_TABLE`。Δ15 中盘自愈仍写成「没有 agent 活着才拉起」。9/22 日记写心跳存在，同时有中盘约 36–50 分钟（门 25）和末小时约 17 分钟（门 10）。

- `last_success_SCAN_TABLE` = 最近一次做完 OPEN→ARMED→HUNG 的扫描。心跳、`LATE_PING`、猎单长文、agent 仍占用，在 09:35–11:30、11:30–15:05、15:05–16:00 三段都不是成功。Δ18 的这一定义不再只用于早盘。
- IF 11:30–15:05 ET AND now − last_success > 25 分钟 THEN 拉起 `MIN_SCAN_TABLE`，即使另一个 agent 活着或本时段已有心跳。写 `ROUTINE_GAP | {from}→{to} | gap_min={n} | door=25m_mid`。门保持 25 分钟。
- IF 15:05–16:00 ET AND now − last_success > 10 分钟 THEN 拉起 `MIN_SCAN_TABLE`，即使另一个 agent 活着或本时段已有心跳。写 `ROUTINE_GAP | {from}→{to} | gap_min={n} | door=10m_lasthour`。门保持 10 分钟。
- IF `gap_min > door+10` THEN 另写 `HEAL_LATE | {door} | gap_min={n}`（Δ26 已有）。末小时约 17 分钟只满足 `ROUTINE_GAP`，不满足 `HEAL_LATE`（door+10 = 20）。不要把没有钟点的 `HEAL_LATE` 记到这笔上。
- `MIN_SCAN_TABLE` 只跑扫描表：OPEN 的 Δ8 与止损、ARMED 的 Δ10、HUNG 的 Δ13。止损或成交若已打印，按 Δ7 用触发价在本 wake 记账。最小扫描不写猎单长文，不开新的 TRAIN3000 腿，不调用 `place_*`。
- IF 拟因「间隔太长 / 靠近止损 / 日 +$100 未达标」出场 THEN 不做出场。出场仍只适用 Δ23。
- EOD「做错了」仍按 Δ26 抄当日每一行 `ROUTINE_GAP`（含 door）。区间摘要不能代替 from→to。
- **Do not:** 把 11:30–15:05 改成 10 分钟门。**Do not:** 把 15:05–16:00 改成短于 10 分钟。**Do not:** 用补扫时刻的市价改写已打印的成交或止损。**Do not:** 因 ONON 距 29.30 约 $0.07 且没有 ≤29.30 的棒而新增提前出场。

---

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-22 — append after Δ26 and after the unnumbered Frank 2026-09-21 standings.
# On conflict, stricter wins. Do not loosen Δ7–Δ26. Do not replace Patches 1–6.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ27 OPEN_AUDIT_INDEPENDENT_CLOCK (tightens Δ14/Δ22; content window unchanged)
Content clock and independent-cron clock are separate.
IF OPEN_AUDIT_DONE timestamp <=09:35:00 ET THEN content clock passes; do not redo DONE
IF the reserve file wake_source is the independent open-audit routine
  AND that routine's spawn >09:35:00 ET
THEN same wake, before sleep, write both:
  OPEN_AUDIT_INDEPENDENT_LATE | planned=0932 | actual={HHMM}
  OPEN_AUDIT_CRON_DIAG | planned=0932 | actual={HHMM} | wake_source= | content_done_at= | content_done_by=
SPAWN_PROOF alone does not satisfy CRON_DIAG
IF independent clock was LATE THEN next RTH 09:28 reserve includes
  cron_align=REQUIRED | last_independent_actual={HHMM}
  even if content DONE was in-window and even if SCHEDULER_ALIGN already exists
  2026-09-23 reserve must include last_independent_actual=10:16
IF the next independent spawn is again >09:35 THEN OPEN_AUDIT_CRON_STILL_LATE
  and carry cron_align=REQUIRED to the following RTH
The independent routine still spawns on its clock after content DONE, so the clock can be measured
Late spawn tags LATE+DIAG only; it does not redo a finished DONE
Do not: treat a 09:34 DONE written by the 10m book-watch as independent-cron alignment
Do not: widen 09:30–09:35
Do not: skip the independent spawn because NO_TRADE, FLAT, or no gap
Do not: replace Δ12 open-px with the wake-time mark

Δ28 SCAN_SPAWN_WHILE_ALIVE (tightens spawn rule of Δ15/Δ20; door minutes unchanged)
last_success_SCAN_TABLE = last completed OPEN→ARMED→HUNG pass
Heartbeat, LATE_PING, hunt longtext, alive-but-stuck are not success in any of:
  09:35–11:30, 11:30–15:05, 15:05–16:00
IF 11:30–15:05 ET AND now-last_success > 25m
THEN spawn MIN_SCAN_TABLE even if another agent is alive or a heartbeat already fired
  ROUTINE_GAP | from→to | gap_min | door=25m_mid
  door stays 25m
IF 15:05–16:00 ET AND now-last_success > 10m
THEN spawn MIN_SCAN_TABLE even if another agent is alive or a heartbeat already fired
  ROUTINE_GAP | from→to | gap_min | door=10m_lasthour
  door stays 10m
IF gap_min > door+10 THEN HEAL_LATE (Δ26)
  a ~17m last-hour gap is ROUTINE_GAP only (door+10=20); do not assign an untimed HEAL_LATE to it
MIN_SCAN_TABLE scans the table only; books a printed stop/fill at trigger px (Δ7)
  no hunt longtext; no new TRAIN3000 leg; no place_*
Exit still only under Δ23
Do not: change 11:30–15:05 from 25m to 10m
Do not: shorten 15:05–16:00 below 10m
Do not: reprice with the heal-time mark
Do not: add a near-stop exit (ONON post-fill lo ~29.37, zero bars <=29.30, stays HOLD)
```

---

## 非范围

- 不改 Patch 1 假否决、Patch 2 双挂、Patch 4 cap 数字、Patch 6 重试梯的四级结构。
- 不改 Δ8 的 +1R / 近 t1 / 正股 t1 定义。不改 Δ9 的 (a)(b)(c)。不改 Δ10 VOID。不改 Δ11 的 10 分钟例程门。不改 Δ12 的开盘价口径。不改 Δ16 的六段加 Cursor。不改 Δ17 的「先要有 HUNG_TOUCH」。
- 不改 Δ23 的合法出场集合。不改 Δ24 的 HIT 条件与 reason 枚举。不改 Δ25 的队列行格式。不改 Δ26 的 door 标签和 `EOD_GAP_UNDERCOUNT` 触发句。
- **不放宽** Δ14 的窗和 LATE 定义。**不放宽** Δ15 在 11:30–15:05 的 25 分钟。**不放宽** Δ18 早盘 10 分钟。**不放宽** Δ20 尾盘 10 分钟。**不放宽** Δ22 的内容门预热、2 分钟重唤、`OPEN_AUDIT_SCHEDULER_DEAD`。
- 不把 CRWD mark ~33.7、正股 ~250.07 写成强制半出。SL→COST 继续。不把 AAPL（mark ~15.0，未到 +1R，hard ≤7.20 / 股 320 未触）写成应抬 COST。
- 不把 VKTX-VWAP-RC-0922、VKTX-BO-0922 的 VOID 写成应成交或应回挂。不制造 Δ17 欠账。
- 不把 PRTH 或 ONON 在 9/22 收盘写成应强平。9/23 只按票上已写的止损 / t1 / t2 管。
- 不改 9/21 QQQ 的 734.77 / 735.18 / +$0.82。不把这笔 +$0.82 算进 9/22 的 raw_realized。现金 $384.42 = 3000 + 0.82 − 2616.40，只作核对。
- 不写 9/23 标的推荐。不下真单。不编 fill。不碰 ••••1429。


---

# APPEND 2026-09-23 — Cursor postmortem (Δ29–Δ31)

# APPEND ONLY — Cursor postmortem 2026-09-23

粘贴到 Agentic 例程 / playbook 里现有 `PROCESS-PATCHES` 的末尾。  
不要整份替换 Patch 1–6，不要替换 Δ7–Δ28，不要删 Frank 2026-09-21 未编号条。  
冲突时更严者生效。本文件不放宽任何旧门。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

触发证据（9/23 PAPER + 例程；价格按日志原文，不新取价）：

- 真钱 7474：现金 / 账户值 $3,064.83；equity $0；options $0；仓空；单空；零 `place_*`。六段与 handoff 写最近真钱 equity 成交仍为 2026-09-02 GTLB；纸面 ledger 无此行。
- Sleeve A 仍 OPEN：AAPL Nov20 340C×2 @14.43，16:04 mark 13.325，uPnL −221；CRWD Oct16 220C×2 @14.73，mark 44.3，uPnL +5914。累计已实现 −2,448.52。浮盈亏 −221+5914 = +5693。账面 −2448.52+5693 = +3244.48。没有 GAP_STOP。AAPL 未到 +1R，没有抬 COST。CRWD 维持 SL→COST。
- TRAIN3000：`FRANK_FLAT_RESET_0923` ~10:07 平 PRTH×180 @7.805 pnl +4.50、ONON×40 @29.6421 pnl −30.32。现金归位 $2,975。`FRANK_CAPITAL_RESET_3000` 顶仓 +$25（不算 P&L）至本金 $3,000。IONQ×69 @42.55 ~10:11，名义 $2,935.95；填后现金 $39.05，顶仓后现金 $64.05。~16:04 `NO_OVERNIGHT_SESSION_END` @42.54 pnl −0.69，qualified=0。收盘现金 $2,999.31。raw −26.51，qualified 0。`WEEK_GOAL` MISS。
- IONQ 填后 hi ~43.97（t1 44.25，差 0.28），收盘记 lo ~42.30（stop 41.50 未触）。stop / t1 / structure 都没打印。
- 开盘审计：9/22 独立唤醒约 10:16，内容 DONE 在 09:34。9/23 reserve 含 `cron_align=REQUIRED`。独立 spawn 行 `actual=10:13`（六段与 handoff 写 10:12；字段用 spawn 行）。内容 DONE 也是这一跳才落地，09:43 写了 `OPEN_AUDIT_CONTENT_LATE_SO_FAR` 并把 DONE 让给独立例程。`OPEN_AUDIT_REWAKE` 自 09:35 起 0 行，`OPEN_AUDIT_SCHEDULER_DEAD`。
- 末小时：15:31 写 `LATE_RTH_FLATTEN_PENDING`，指向 15:40/15:50。两跳未发生。15:31→16:04 ≈33m，`ROUTINE_GAP_LAST_HOUR`。flatten 落在 16:04。
- HUNG 全日空。VKTX stay VOID。无 Δ17 欠账。EOD wake Mac offline，box 副本；盘中有几跳写过 mirror OK，不把全日记成全程离线。

---

## 与旧条的关系（不放宽）

| 旧条 | 仍有效 | 本 delta 只加什么 |
|---|---|---|
| Δ12/Δ14/Δ22 内容门 09:30–09:35；晚于 09:35 = `OPEN_AUDIT_LATE`；09:31 未开始则 `MIN_OPEN_AUDIT`；09:40 前 rewake <2 = `SCHEDULER_DEAD` | 是 | Δ29 禁止在 `cron_align=REQUIRED` 时把内容审计让给还没醒的独立 cron |
| Δ27 独立时钟 ≠ 内容时钟；LATE 则下一 RTH 带 `cron_align=REQUIRED`；再晚则 `CRON_STILL_LATE` | 是 | 9/23 旗已经在，时钟仍晚。Δ29 加一条不同的 09:31 oneshot。oneshot 或满仓盯的 DONE 不能把独立时钟标成准时 |
| Δ20 末小时 10 分钟；Δ28 破门拉 `MIN_SCAN_TABLE`，且最小扫描不许因间隔出场 | 是，分钟数不变 | Δ30 只给「票上已经写了 no-overnight」的 TRAIN3000 腿预留 15:40/15:50。不改 10 分钟门，不把最小扫描改成出场程序 |
| Δ23 合法出场；事先写明的时间失效才允许按该句平；qualified 只计 stop / t1 / 书面结构失效 | 是 | Δ30 不新增出场理由。执行的是票上已有的 no-overnight 句。session-end 仍 qualified=0 |
| Δ24 HIT 只看 qualified ≥100；不为 +$100 平带内仓 | 是 | 不改。9/23 reason 自由文本是没执行枚举，不新开 |
| Frank 9/21 `NO_TRAIN3000_MICRO_SAMPLE`：名义相对 $3,000 要有意义，QQQ×2 那种不作样本；禁止为配额早平 | 是 | Δ31 只要求填单前写明 `SIZE_MODE`。做不到「多轮 + 仍有意义」就不成交。不自动砍成小名义 |
| Δ23：催化腿 OPEN 时不得另开一笔噪声腿来凑回合 | 是 | Δ31 的 `MULTI_ROUND` 若要第二轮现金，必须在填单后就留下，不准事后平掉第一腿来腾现金 |
| Patch 4 的 1/N、≤40%、2.0–2.5× | 是，数字不动 | Δ31 不引用、不改这些数字 |
| Δ25 Mac 队列；Δ26 from→to 与 `HEAL_LATE` | 是 | 不改格式。9/23 六段仍是区间摘要，且 11:30 前两段被标成 25m。明日 EOD 逐行抄，不新开 |

不采纳（写明，避免下次把「未改」读成遗漏）：

- 不把 11:30–15:05 的门从 25 分钟改成 10 分钟。已记录的中盘空洞大于 25。缺的是 `MIN_SCAN_TABLE` 行，不是更短的门。
- 不把 15:05–16:00 的门改成短于 10 分钟。
- 不把 $3,000 自动切成 2 或 3 等份。该公式不在票上，而且会撞上 `NO_TRAIN3000_MICRO_SAMPLE`。
- 不把 `CASH_CONSTRAINED_ONE_LEG` 从 9/23 的标签里删掉。Δ31 只约束下一张票。
- 不把 IONQ lo ~42.30、ONON 止损 29.30 写成提前出场。
- 不把六段里的 10:12 写进 `last_independent_actual`。spawn 行是 10:13。

---

## Δ29. OPEN_AUDIT_CRON_ONESHOT（收紧 Δ27；内容窗与 Δ22 的 REWAKE 不变）

Δ27 把独立时钟和内容时钟拆开，LATE 的下一步是标签，加上下一 RTH 预热里的 `cron_align=REQUIRED`。9/23 这面旗已经在 reserve 里。独立例程仍在 09:35 之后才醒（spawn 行 10:13；六段写 10:12）。09:43 的满仓盯写明不做 DONE、等独立例程。两条时钟一起晚。再写一行 DIAG 不会产生 ≤09:35 的 spawn。

- IF 上一已结束 RTH 写有 `OPEN_AUDIT_CRON_STILL_LATE` THEN 下一 RTH 的 09:28 预热在 Δ27 原句之外还必须有：`cron_oneshot=ARMED | fire_at=09:31 | prior_actual={spawn 行的 HHMM}`。`cron_align=REQUIRED` 单独存在不算 oneshot 已武装。2026-09-24 这行的 `prior_actual=10:13`。禁止用六段摘要的 10:12 填这个字段。
- oneshot 必须是另一条唤醒，不是打出上一笔 LATE 的那条独立例程本身。
- IF 09:31:00 ET 还没有独立例程的 spawn 行且时间 ≤09:31 THEN 这一分钟写 `OPEN_AUDIT_CRON_ONESHOT | fired=0931`。若此时还没有 `OPEN_AUDIT_DONE`，同一分钟执行 Δ22 的 `MIN_OPEN_AUDIT`。DONE 时间晚于 09:35 仍是 `OPEN_AUDIT_LATE`（Δ14）。这一行 DONE 不把独立时钟标成准时。
- IF `cron_oneshot=ARMED` AND 09:31 独立 spawn 仍缺 AND 满仓盯或 10 分钟盯写「独立例程负责 / 本例程不做 DONE」THEN 该句非法。改为同分钟 `MIN_OPEN_AUDIT`，并写 `OPEN_AUDIT_DEFER_FORBIDDEN`。
- IF 09:35:00 ET 仍没有时间 ≤09:35 的独立 spawn 行 THEN 同一分钟写 `OPEN_AUDIT_CRON_REBUILD_DUE | prior_actual={HHMM}`。独立时钟保持 LATE。内容 DONE 若已经存在，禁止重做 DONE（Δ27）。Δ22 的 2 分钟 `OPEN_AUDIT_REWAKE` 继续，直到内容 DONE 落地；09:40 前少于 2 行仍是 `OPEN_AUDIT_SCHEDULER_DEAD`。
- IF 独立 spawn ≤09:35:00 ET AND 内容 DONE ≤09:35:00 ET THEN 两个时钟都清。不写 LATE。沿用 Δ27。
- **Do not:** 把 oneshot、满仓盯或 10 分钟盯写出的 DONE 当成独立 cron 已对齐。**Do not:** 放宽 09:30–09:35。**Do not:** 因 NO_TRADE、FLAT 或没有 GAP 取消 oneshot。**Do not:** 用醒来时的 mark 代替 Δ12 的开盘价。**Do not:** 用六段分钟覆盖 spawn 行。

---

## Δ30. NO_OVERNIGHT_FLATTEN_RESERVE（给已写明的 session-end 条款预留唤醒；不新增出场理由）

IONQ 票和 CEO hard-manage 在持仓期间已经写了 no overnight / flatten by band before RTH close。15:31 把执行点放在随后的 15:40/15:50 满仓盯上。两跳都没来。Δ28 的 `MIN_SCAN_TABLE` 只扫表，并禁止因「间隔太长」出场，所以末小时自愈不会执行这句。平仓落到 16:04 的 RTH last 42.54，qualified=0。

- 适用范围：TRAIN3000 的 OPEN 腿，且该票在入场时已经写有 no-overnight 或 session-end flatten 句子。Sleeve A 不适用。没有这句的腿不适用。
- IF 15:05 ET 该腿仍 OPEN THEN 15:05 及之后的第一跳、sleep 之前写：`FLATTEN_RESERVE | {id} | clause=NO_OVERNIGHT | primary=15:40 | backup=15:50`。引用原句，不改写止损和 t1。
- IF 15:40 ET 该腿仍 OPEN AND 止损未打印 AND t1 未打印 AND 书面结构失效未打印 THEN 在这一跳按该句平仓。成交价用这一跳的可成交 print（Δ7），不用之后的 mark。写 `NO_OVERNIGHT_FLATTEN | {id} | planned=1540 | actual={HHMM}`。`qualified=0`。
- IF 15:40 的唤醒没有发生 THEN 15:50 的唤醒做同一件事，并写 `FLATTEN_RESERVE_BACKUP | {id} | actual=1550`。
- IF 15:40 与 15:50 都没有发生 AND 下一跳该腿仍 OPEN THEN 在下一跳按同一句平仓，并写 `FLATTEN_RESERVE_MISS | {id} | planned=1540,1550 | actual={HHMM}`。9/23 的实例是 actual=16:04、价 42.54。禁止回改这笔价。
- IF 在预留唤醒之前，止损或 t1 或书面结构失效已经打印 THEN 取消预留：`FLATTEN_RESERVE_CANCEL | {id} | reason=band_printed`。出场改走 Δ23。不要再做一次 session-end 平仓。
- **Do not:** 把 15:05–16:00 的门改短于 10 分钟。**Do not:** 让 `MIN_SCAN_TABLE` 承担这次平仓。**Do not:** 把 session-end 记成 qualified。**Do not:** 用 `WEEK_GOAL`、配额、或「腾现金做第二轮」当理由。**Do not:** 对 Sleeve A 或没有 no-overnight 原句的腿使用本条。**Do not:** 在 15:40 之前按本条平仓。

---

## Δ31. TRAIN3000_SIZE_MODE_BEFORE_FILL（填单前消解多轮与单笔满名义；不自动缩仓）

10:07 的站立同时写了反复短周期和满仓。10:11 的票写了 `FULL_SIZE_SHORT_CYCLE`、69 @42.55、名义 $2,935.95，并写 one TRAIN3000 leg。顶仓后现金 $64.05。Δ23 不允许为了第二轮去平仍在带内的腿，也不允许在催化腿 OPEN 时另开一笔凑回合。`NO_TRAIN3000_MICRO_SAMPLE` 不允许把名义砍到 QQQ×2 那种样本（ledger：2 @734.77，名义 $1,469.54）去制造回合。所以缺的是填单前的二选一，不是事后改 size。

- IF 当日站立同时含「多轮 / 反复短周期」和「满仓 / full notional」THEN 在 TRAIN3000 成交之前，票上必须有且只有一行：`SIZE_MODE=ONE_FULL_LEG`，或 `SIZE_MODE=MULTI_ROUND | N={整数≥2} | per_leg_cap={美元}`。
- IF 没有 `SIZE_MODE` THEN 不成交。写 `SIZE_MODE_MISSING`。禁止默认满名义。禁止默认改小数量。
- IF `SIZE_MODE=ONE_FULL_LEG` THEN 这笔可以把现金用到不足以再开一笔有意义名义的残额。`CASH_CONSTRAINED_ONE_LEG` 只是状态，不是流程失误。这笔 OPEN 期间禁止再开第二笔 TRAIN3000。
- IF `SIZE_MODE=MULTI_ROUND` THEN 成交名义 ≤ `per_leg_cap`，且成交后剩余现金 ≥ `per_leg_cap`，这样下一轮不需要先平掉这笔。`per_leg_cap` 仍须满足 `NO_TRAIN3000_MICRO_SAMPLE`（相对 $3,000 有意义；不得为了凑 N 而落到 QQQ×2 那种名义）。三条里有一条做不到 THEN 不成交，写 `SIZE_MODE_CONFLICT`。禁止自动改数量。禁止为腾现金而平掉 OPEN 腿。
- 9/23 的 IONQ 69 @42.55 已经按当时写明的 `FULL_SIZE` 记账。禁止回写 `SIZE_MODE`，禁止改 69、42.55、42.54、−0.69。
- **Do not:** 改 Patch 4 的比例和上限数字。**Do not:** 改 Δ23 的出场集合。**Do not:** 改 Δ24 的 HIT 条件。**Do not:** 把 $3,000 自动除以 2 或 3。**Do not:** 把 9/23 的 `CASH_CONSTRAINED_ONE_LEG` 从当日标签删除。

---

## 粘贴块（Agentic 例程）

```
# DELTA 2026-09-23 — append after Δ28 and after the unnumbered Frank 2026-09-21 standings.
# On conflict, stricter wins. Do not loosen Δ7–Δ28. Do not replace Patches 1–6.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ29 OPEN_AUDIT_CRON_ONESHOT (tightens Δ27; content window and Δ22 rewake unchanged)
IF the prior completed RTH has OPEN_AUDIT_CRON_STILL_LATE
THEN the next RTH 09:28 reserve includes, in addition to Δ27:
  cron_oneshot=ARMED | fire_at=09:31 | prior_actual={HHMM from the spawn line}
  cron_align=REQUIRED alone does not arm the oneshot
  2026-09-24 prior_actual=10:13
  Do not write the digest minute 10:12 into that field
The oneshot is a different wake from the routine that printed the prior LATE
IF 09:31 and no independent spawn timestamped <=09:31
THEN write OPEN_AUDIT_CRON_ONESHOT | fired=0931
  IF content DONE does not exist yet THEN MIN_OPEN_AUDIT in that same minute (Δ22)
  A DONE after 09:35 is still OPEN_AUDIT_LATE
  That DONE does not clear the independent clock
IF cron_oneshot=ARMED AND 09:31 independent spawn is absent
  AND a book-watch says the independent routine will do DONE
THEN that deferral is forbidden
  run MIN_OPEN_AUDIT the same minute and write OPEN_AUDIT_DEFER_FORBIDDEN
IF 09:35 and still no independent spawn <=09:35
THEN write OPEN_AUDIT_CRON_REBUILD_DUE the same minute
  independent clock stays LATE
  do not redo DONE if content DONE already exists (Δ27)
  keep Δ22 2m OPEN_AUDIT_REWAKE; <2 lines before 09:40 is still SCHEDULER_DEAD
IF independent spawn <=09:35 AND content DONE <=09:35 THEN both clocks clear (Δ27)
Do not: treat oneshot or book-watch DONE as independent-cron alignment
Do not: widen 09:30–09:35
Do not: skip the oneshot because NO_TRADE, FLAT, or no gap
Do not: replace Δ12 open-px with the wake-time mark
Do not: overwrite the spawn-line minute with the digest minute

Δ30 NO_OVERNIGHT_FLATTEN_RESERVE (reserves a wake for an already-written session-end clause)
Applies only to an OPEN TRAIN3000 leg whose ticket already wrote no-overnight or session-end flatten
Sleeve A is out of scope. A leg with no such clause is out of scope
IF that leg is still OPEN at 15:05 ET
THEN the first wake at or after 15:05 writes, before sleep:
  FLATTEN_RESERVE | {id} | clause=NO_OVERNIGHT | primary=15:40 | backup=15:50
  quote the original clause; do not rewrite stop or t1
IF 15:40 and the leg is still OPEN AND stop not printed AND t1 not printed AND structure invalidation not printed
THEN flatten under that clause on this wake
  print at this wake (Δ7); do not use a later mark
  NO_OVERNIGHT_FLATTEN | {id} | planned=1540 | actual={HHMM}
  qualified=0
IF the 15:40 wake did not run THEN the 15:50 wake does the same
  FLATTEN_RESERVE_BACKUP | {id} | actual=1550
IF both 15:40 and 15:50 did not run AND the next wake still finds the leg OPEN
THEN flatten under the same clause and write
  FLATTEN_RESERVE_MISS | {id} | planned=1540,1550 | actual={HHMM}
  2026-09-23 instance actual=16:04 px=42.54; do not reprice it
IF stop or t1 or written structure invalidation prints before the reserved wake
THEN FLATTEN_RESERVE_CANCEL | {id} | reason=band_printed
  exit under Δ23; do not also session-end flatten
Do not: shorten the 15:05–16:00 door below 10m
Do not: make MIN_SCAN_TABLE perform this flatten
Do not: mark a session-end exit qualified
Do not: flatten for WEEK_GOAL, quota, or to free cash for a second round
Do not: apply this to Sleeve A or to a leg without the written clause
Do not: flatten under this rule before 15:40

Δ31 TRAIN3000_SIZE_MODE_BEFORE_FILL (disambiguate multi-round vs one full leg before fill; no auto-cut)
IF the live standing says both multi-round / repeated short cycle AND full notional
THEN before a TRAIN3000 fill the ticket has exactly one line:
  SIZE_MODE=ONE_FULL_LEG
  or SIZE_MODE=MULTI_ROUND | N={integer>=2} | per_leg_cap={usd}
IF SIZE_MODE is absent THEN do not fill
  SIZE_MODE_MISSING
  do not default to full notional and do not default to a smaller qty
IF SIZE_MODE=ONE_FULL_LEG
THEN residual cash that cannot fund another meaningful leg is the chosen mode
  CASH_CONSTRAINED_ONE_LEG is status, not a process miss
  do not open a second TRAIN3000 leg while this one is OPEN
IF SIZE_MODE=MULTI_ROUND
THEN fill notional <= per_leg_cap AND residual cash after the fill >= per_leg_cap
  per_leg_cap must still satisfy NO_TRAIN3000_MICRO_SAMPLE
  (meaningful vs the $3000 sleeve; not a QQQ×2-style print, ledger 2 @734.77 notional 1469.54)
  if any of those fails THEN do not fill
  SIZE_MODE_CONFLICT
  do not auto-cut qty and do not flatten an OPEN leg to free cash
The booked IONQ 69 @42.55 / exit 42.54 / pnl -0.69 stays as written under FULL_SIZE
  do not add SIZE_MODE retroactively
Do not: change Patch 4 ratios or caps
Do not: change the Δ23 exit set or the Δ24 HIT test
Do not: auto-divide $3000 by 2 or by 3
Do not: delete the 2026-09-23 CASH_CONSTRAINED_ONE_LEG tag
```

---

## 非范围

- 不改 Patch 1 假否决、Patch 2 双挂、Patch 4 cap 数字、Patch 6 重试梯的四级结构。
- 不改 Δ8 的 +1R / 近 t1 / 正股 t1 定义。不改 Δ9 的 (a)(b)(c)。不改 Δ10 VOID。不改 Δ11 的 10 分钟例程门。不改 Δ12 的开盘价口径。不改 Δ16 的六段加 Cursor。不改 Δ17 的「先要有 HUNG_TOUCH」。
- 不改 Δ23 的合法出场集合。不改 Δ24 的 HIT 条件与 reason 枚举。不改 Δ25 的队列行格式。不改 Δ26 的 door 标签和 `EOD_GAP_UNDERCOUNT` 触发句。不改 Δ27 的「内容 DONE 不等于独立时钟」。不改 Δ28 的门分钟和「最小扫描不开新腿、不因间隔出场」。
- **不放宽** Δ14 的窗和 LATE 定义。**不放宽** Δ15 在 11:30–15:05 的 25 分钟。**不放宽** Δ18 早盘 10 分钟。**不放宽** Δ20 尾盘 10 分钟。**不放宽** Δ22 的内容门预热、2 分钟重唤、`OPEN_AUDIT_SCHEDULER_DEAD`。
- 不把 CRWD mark 44.3、正股 ~262.5 写成强制半出。SL→COST 继续。不把 AAPL（mark 13.325，未到 +1R，hard ≤7.20 / 股 320 未触）写成应抬 COST。
- 不把 VKTX 的 VOID 写成应成交或应回挂。不制造 Δ17 欠账。
- 不改 9/23 已记账的 IONQ 42.55 / 42.54 / −0.69、PRTH 7.805 / +4.50、ONON 29.6421 / −30.32。40×(29.6421−30.40)=−30.316 与记账 −30.32 的 $0.004 差额不回写。
- 不把 IONQ 票面 t1 路径 +$117.30 写成已实现。不把 `WEEK_GOAL` MISS 写成应在带内提前平仓。
- 不写 9/24 标的。不下真单。不编 fill。不碰 ••••1429。

---

# APPEND ONLY — Cursor postmortem 2026-09-24

粘贴位置：现有 `PROCESS-PATCHES` 末尾，Δ31 之后。  
本文件**不新增 Δ32**。不替换 Patch 1–6。不替换 Δ7–Δ31。不放宽任何旧门。冲突时更严者生效。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

## 结论

三个候选都核对过。**没有需要新收紧的规则。** 9/24 的缺口是既有 if-then 没有被执行，或是规则按原文已经做对。再写一条同义的编号只会在下次把「未改」读成遗漏。

## 候选 1 — OPEN_AUDIT 第三日 LATE，重建已为 9/25 武装

事实（只取附件）：

- 内容 DONE 10:02，`parent_MIN_OPEN_AUDIT_heal`，晚于 09:35 → `OPEN_AUDIT_LATE`。
- 独立 spawn 10:03（planned 09:32）→ `OPEN_AUDIT_INDEPENDENT_LATE` + `OPEN_AUDIT_CRON_STILL_LATE`。只 CONFIRM，没有重做 DONE。
- 独立时钟 LATE 的序列：9/22 ≈10:16，9/23 spawn 10:13，9/24 spawn 10:03。内容门 9/22 在 09:34 窗内，内容 LATE 不是三日。
- 09:28 reserve 不存在，`cron_oneshot` 没有 ARMED。`OPEN_AUDIT_REWAKE` 自 09:35 起 0 行 → `SCHEDULER_DEAD`。
- `CRON_REBUILD` 约 10:08 才写入，日程是下一 RTH 2026-09-25：独立 09:30、09:28 预热、09:31 oneshot、09:35 补门。
- `open-audit-reserve-2026-09-25.txt`：`cron_align=REQUIRED`，`cron_oneshot=ARMED | fire_at=09:31 | prior_actual=10:03`。10:03 是当日独立 spawn，不是内容 10:02，也不是 9/23 的 10:13。

判定：Δ22 / Δ27 / Δ29 已经规定缺文件、09:31 无 spawn、09:35 仍无 spawn、09:40 前 REWAKE<2 时各自写什么。9/24 是这些句子没有在窗内跑，因为调度没醒。10:08 的重建是给 9/25 的，9/24 的 LATE 不是「重建之后仍然失败」。在 9/25 四门有实际 spawn 记录之前，不加 Δ32。

9/25 若仍 LATE，下一份复盘只针对没响的那一扇门写句子（0928 文件缺、0930 独立缺、0931 oneshot 缺、或 0935 补门缺）。不要预写「再 LATE 就升级」这种不指向某一扇门的规则。

## 候选 2 — Δ30 主窗 15:43 相对 9/23 的 16:04

事实：

- 票面入场即写 `no-overnight=YES`。stop 57.40、t1 60.20、书面结构失效全日未打印。post-fill hi ~58.755，lo ~57.53。
- 15:10、15:16 只写了 `NO_OVERNIGHT_WINDOW_PENDING`。精确行 `FLATTEN_RESERVE | OXY-VWAP-0924 | clause=NO_OVERNIGHT | primary=15:40 | backup=15:50` 出现在 15:28，并在 15:32 复述。15:32 没有提前平。
- 15:43 是 15:40 之后、15:50 之前的第一跳。纸面卖 51 @58.04。标签 `NO_OVERNIGHT_FLATTEN_PRIMARY_1540`。pnl 51×(58.04−58.22)=−9.18。`qualified=0`。现金 30.09→2990.13。
- 15:56 last 58.0 只确认已平，没有改价。
- 9/23 的实例仍是 `FLATTEN_RESERVE_MISS` actual=16:04、价 42.54。禁止回改。

判定：15:43 用主窗标签是对的。`FLATTEN_RESERVE_MISS` 只在 15:40 与 15:50 两跳都没发生时使用。3 分钟后的第一跳仍在 backup 之前，不是 MISS。

15:10 没写出精确 `FLATTEN_RESERVE` 行，违反的是 Δ30 已有的「15:05 后第一跳、sleep 前写」。结果仍在主窗内平掉。不把这句再编号一次，也不把「第一跳」改成更短的分钟门。

保持：

- IF 15:40 该腿仍 OPEN 且 stop / t1 / 书面结构失效都未打印 THEN 当跳按票面 no-overnight 平，价用当跳 print，`qualified=0`。
- IF 只有 15:50 醒了 THEN `FLATTEN_RESERVE_BACKUP`。
- IF 两跳都没来 THEN 下一跳 `FLATTEN_RESERVE_MISS`。
- Do not: 把 15:43 / 58.04 / −9.18 改成 MISS 或 qualified。Do not: 用 15:56 的 58.0 回写。Do not: 在 15:40 之前按本条平仓。Do not: 把末小时门改到短于 10 分钟。

## 候选 3 — `ONE_FULL_LEG` 锁死现金，DAY_GOAL MISS，合格回合 0

事实：

- 票上在成交前写了 `SIZE_MODE=ONE_FULL_LEG | N=1 | per_leg_cap≈$2969`。名义 51×58.22=2969.22。残现金 $30.09。
- 唯一平仓是 no-overnight，qualified=0。raw −9.18。日目标 qualified >+$100 → MISS。`WEEK_GOAL_MISS` 同数。
- 持仓期间没有为配额、+$100、或腾第二腿现金而平。结构失效未确认，所以也没有走 Δ23 的结构出场。

判定：这是 Δ31 允许的选择，加上 Δ23 / Δ24 禁止的「为指标出场」没有发生。`CASH_CONSTRAINED_ONE_LEG` 保持为状态，不升格为流程失误，不从标签里删除。

保持：

- IF 站立同时要多轮和满仓 THEN 成交前恰好一行 `ONE_FULL_LEG` 或 `MULTI_ROUND | N≥2 | per_leg_cap`。缺行则不成交。
- IF `ONE_FULL_LEG` THEN 残现金可以不足以再开一笔有意义名义的腿；OPEN 期间不开第二笔。
- IF `MULTI_ROUND` THEN 成交名义 ≤ cap 且成交后现金 ≥ cap，cap 仍须过 `NO_TRAIN3000_MICRO_SAMPLE`。做不到则 `SIZE_MODE_CONFLICT`，不自动改数量。
- Do not: 把 $3,000 除以 2 或 3。Do not: 改 Patch 4 的比例和上限。Do not: 改 Δ24 的 HIT 条件（qualified≥100）。Do not: 回写 51 / 58.22 / 58.04 / −9.18。

## 一并看到、同样不新开

- 早盘 09:26→10:04（38m）、10:04→10:31（27m）、10:31→10:56（25m）、10:56→11:18（22m）在 10 分钟门内，日志用了 25m 中段门或未标。Δ26 已要求按当时的门写 `door=10m_early`，gap>door+10 时写 `HEAL_LATE`。门的分钟数不改。
- 六段「做错了」只举了 10:04→10:31 一例，并把门写成 25m。Δ26 已要求逐行抄。9/23 的 delta 写过「明日 EOD 逐行抄，不新开」。此次仍不新开。
- `WEEK_GOAL` 只有标签，没有 Δ24 管道行。原句已要求那一行。reason 枚举不扩大。
- 10:02 journal 的 AAPL uPnL −26、CRWD `+,550` 与公式及 `open-audit-done`（−226 / +5550）不符。不回写 journal，不为此加核对规则。EOD 用的是 15:56 的 −351 / +5454，这两格是对的。

## 粘贴块

```
# 2026-09-24 — no new delta.
# Append after Δ31. On conflict, stricter wins.
# Do not loosen Patch 1–6 or Δ7–Δ31.
# Paper 7474 only. No place_*. Do not touch account 1429.

NO Δ32.
OPEN_AUDIT: 2026-09-24 independent spawn actual=10:03 (third consecutive independent LATE).
  Content DONE 10:02 by parent heal. Oneshot was not armed: 09:28 reserve missing.
  CRON_REBUILD at ~10:08 applies to RTH 2026-09-25, not to the 09:24 window already missed.
  2026-09-25 reserve already has cron_oneshot=ARMED | fire_at=09:31 | prior_actual=10:03.
  Execute Δ22/Δ27/Δ29 on those four doors. Do not add a rule before 2026-09-25 prints which door failed.
Δ30 primary flatten at 15:43 px 58.04 pnl -9.18 qualified=0 is the correct reading.
  First wake inside [15:40, 15:50) is PRIMARY, not FLATTEN_RESERVE_MISS.
  2026-09-23 MISS stays actual=16:04 px=42.54.
  The 15:10 wake omitted the literal FLATTEN_RESERVE line; Δ30 already requires that line on the first wake after 15:05. Do not restate it as a new number.
SIZE_MODE=ONE_FULL_LEG with residual cash 30.09 and DAY_GOAL MISS (qualified 0) matches Δ31/Δ23/Δ24.
  Do not split 3000. Do not mark the session-end exit qualified. Do not reprice 51 @ 58.22 → 58.04.
Do not: shorten 10m or 25m doors. Do not: treat LOST_ENTRY_VWAP without a fail-reclaim bar as an exit.
```


---

# APPEND ONLY — Cursor postmortem 2026-09-25

粘贴位置：现有 `PROCESS-PATCHES` 末尾，2026-09-24「NO Δ32」块之后。  
不替换 Patch 1–6。不替换 Δ7–Δ31。不放宽任何旧门。冲突时更严者生效。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

## 结论

三个候选里只收紧一条。

| 候选 | 判定 |
|---|---|
| (a) `TRAIN_EMPTY_DAY` 与不追 | **加 Δ32 `EMPTY_DAY_CLOCK`。** 站立「每日 ≥1 完整 round」没有时钟；「禁止第二空仓日」若被读成必须成交，就会编 fill。不采用降栏，也不用 `ACCEPT_TRAIN_EMPTY` 把 MISS 涂成过关 |
| (b) 09:55→10:13 ≈18m 标成 mid / gap OK | **不加。** Δ18/Δ26 已规定 09:30–11:30 用 `door=10m_early`。18m > 10m，所以不是 gap OK。18m ≤ door+10（20m），所以不是 `HEAL_LATE`。同窗还有 13m / 14m / 15m 被写成 mid OK，性质相同：没执行，不新编号，不改分钟 |
| (c) OPEN_AUDIT 重建后 ON_TIME | **不加，保持四门。** 独立 09:34，内容 DONE 09:35，oneshot actual 09:38（主审计已覆盖，MIN 跳过），0935 补门 09:39 already_DONE。late streak 清掉。胜仗日不加门 |

9/25 不回写 journal，不给 AKAM 补一笔成交。

## Δ32. EMPTY_DAY_CLOCK（把「至少 1 个完整 round」绑在原结构门上；不授权成交）

9/25 prefer 窗内 TRAIN3000 现金 $2,990.13，`SIZE_MODE=FLAT_CASH_READY`，OPEN/HUNG/ARMED/CLOSED 皆无。AKAM 硬催化成立，但 09:34 起 LOST_VWAP；~10:50 hi 120.69 未 hold；收盘 last 114.66 ≤ VWAP 118.67。AESI RVOL 薄。VKTX 维持 VOID。拒绝追是对的。错在 10:30 后第一跳（~10:37）和 11:30 后第一跳（~11:32）都没有把「同门备选」或「结构不足所以本日无 round」写成一行，空仓一直拖到 EOD 才叫 `TRAIN_EMPTY_DAY`。

- 适用范围：prefer 窗 09:30–11:30 ET 的 TRAIN3000，且现金够开一腿，且 OPEN=0 且 HUNG=0。Sleeve A 不适用。已有 HUNG 或已有 OPEN 时本条沉默，沿用原 chase / Δ17 / Δ23。VKTX VOID 不回挂。
- round 配额不打印价格。
- IF 10:30 ET 及之后的第一跳仍 FLAT，且本场没有任何名字打出硬催化 AND reclaim+hold（或该票已写明的结构门）AND 同棒 entry/stop/t1 THEN sleep 前写：`EMPTY_DAY_CLOCK | asof=1030 | primary={symbol} | primary_state={LOST_VWAP|NO_RECLAIM|THIN_RVOL} | alt_scan=REQUIRED`。同一跳用**未改**的门扫一个备选。
- IF 该备选在 11:30 前打出全部门 THEN 成交前必须有 Δ31 的 `SIZE_MODE` 一行，然后才允许 HUNG。没打出则不挂。
- IF 11:30 ET 及之后的第一跳仍是 OPEN=0 且 HUNG=0 且当日 CLOSED=0 THEN 当跳写：`TRAIN_EMPTY_DAY | reason=NO_QUALIFIED_STRUCTURE | chase=FORBIDDEN`。qualified < 100 时 DAY_GOAL 仍是 MISS（Δ24）。这行记录站立未完成。它不清除 `TRAINING_FAILURE`，不制造 round。
- 9/25 实例保持为空仓。禁止把 `EMPTY_DAY_CLOCK` 补写进 9/25 journal。禁止给 AKAM 编 fill。hi 120.69 且随后 last 回到 VWAP 下，不是 hold。
- **Do not:** 为了凑 round 降低 RVOL、VWAP reclaim 或同棒三价。**Do not:** 在 LOST_VWAP 上挂，包括未 hold 的 probe。**Do not:** 编 entry、stop、t1 或 fill。**Do not:** 用 `ACCEPT_TRAIN_EMPTY` 抹掉 `TRAIN_EMPTY_DAY` 或 `TRAINING_FAILURE`。**Do not:** 开 micro sample，或把 $3,000 除以 2 或 3。**Do not:** 为 qualified +$100、配额或「禁止第二空仓日」进仓或平仓。**Do not:** 改 10m 或 25m 门。**Do not:** 加 OPEN_AUDIT 门，或放宽 09:30–09:35。

## 粘贴块

```
# DELTA 2026-09-25 — append after the 2026-09-24 NO-Δ32 block.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ31.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ32 EMPTY_DAY_CLOCK (bind the ≥1 complete-round standing to the unchanged structure gate; no manufactured fill)
Scope: TRAIN3000 inside prefer 09:30–11:30 ET, cash can fund a leg, OPEN=0 and HUNG=0.
Sleeve A out of scope. If a HUNG or an OPEN already exists, this delta is silent.
VKTX VOID stays VOID. The round quota does not print a price.

IF the first wake at or after 10:30 ET is still FLAT
AND no name has printed hard-catalyst AND reclaim+hold (or the ticket's written structure gate) AND same-bar entry/stop/t1
THEN before sleep write:
  EMPTY_DAY_CLOCK | asof=1030 | primary={symbol} | primary_state={LOST_VWAP|NO_RECLAIM|THIN_RVOL} | alt_scan=REQUIRED
AND scan one alternate under those same gates.
IF that alternate prints the full gate before 11:30
THEN SIZE_MODE (Δ31) is on the ticket before any fill, then HUNG is allowed.
IF it does not print THEN do not hang it.

IF the first wake at or after 11:30 ET still has OPEN=0 and HUNG=0 and CLOSED today=0
THEN write on that wake:
  TRAIN_EMPTY_DAY | reason=NO_QUALIFIED_STRUCTURE | chase=FORBIDDEN
  DAY_GOAL stays MISS when qualified<100 (Δ24)
  This line does not clear TRAINING_FAILURE and does not create a round.

2026-09-25: AKAM catalyst OK, LOST_VWAP all session, probe hi 120.69 did not hold, no HUNG, cash 2990.13, raw/qual 0/0.
  Do not backfill EMPTY_DAY_CLOCK into the 2026-09-25 journal.
  Do not invent an AKAM fill.

Do not: lower RVOL, VWAP reclaim, or the three-price bar to manufacture a round.
Do not: hang LOST_VWAP, including a probe that does not hold.
Do not: invent entry, stop, t1, or fill.
Do not: let ACCEPT_TRAIN_EMPTY erase TRAIN_EMPTY_DAY or TRAINING_FAILURE.
Do not: open a micro sample or divide 3000 by 2 or by 3.
Do not: enter or flatten to hit qualified 100, a quota, or "no second empty day".
Do not: change the 10m or 25m doors.
Do not: add an OPEN_AUDIT door or widen 09:30–09:35.

NO extra delta for the gap-door mis-tag.
  09:55→10:13 ≈18m is ROUTINE_GAP_EARLY / door=10m_early.
  18m is over 10m, so not gap OK. 18m is not over door+10 (20m), so not HEAL_LATE.
  Δ26 already requires the live door. Do not restate it as a new number.

NO extra delta for OPEN_AUDIT.
  2026-09-25 independent spawn 09:34, content DONE 09:35, oneshot actual 09:38 with MIN skipped, 0935 rewake 09:39 already_DONE.
  Keep the four doors. First ON_TIME after the 2026-09-24 rebuild is not a reason to add a fifth.
```

# DELTA 2026-09-28 — append after Δ32.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ32.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ33 OPEN_AUDIT_REBUILD_VERIFY (name the door that missed; no new fire minute)
2026-09-25 was the one ON_TIME after the 2026-09-24 rebuild:
  independent spawn 09:34, content DONE 09:35.
2026-09-28 reserve was present:
  cron_oneshot=ARMED | prior_actual=09:34
  independent planned 09:30, spawn actual 09:52, confirm 09:53
  oneshot actual 09:50 wrote fired=0931 and MIN_SKIP because content DONE already existed at 09:46
  content DONE 09:46 was a book-watch LATE heal
Doors that missed their own minute: 0930_independent, 0931_oneshot.
0928 reserve existed. The 0935 rewake at 09:54 is still Δ22, not this number.

IF oneshot fire_at=09:31 AND that wake's actual > 09:31
THEN write:
  OPEN_AUDIT_ONESHOT_LATE | planned=0931 | actual={HHMM} | failed_door=0931_oneshot
  Do not write OPEN_AUDIT_CRON_ONESHOT | fired=0931
  IF content DONE already exists THEN MIN_OPEN_AUDIT=SKIP and do not redo DONE
  That line does not clear independent LATE and does not satisfy Δ29's 09:31 sentence
  2026-09-28 instance actual=09:50. Do not rewrite it to 09:31.

IF writing OPEN_AUDIT_CRON_REBUILD_DUE
THEN the same line includes:
  failed_door=0930_independent | today_actual={today's spawn HHMM} | prior_session_actual={prior RTH independent spawn HHMM}
  IF the oneshot was also late THEN also failed_door=0931_oneshot
  2026-09-28: today_actual=09:52, prior_session_actual=09:34, confirm 09:53 does not replace the spawn
  Do not use a bare prior_actual that is 09:34 on one line and 09:52 on the next
  A later rewake line saying independent_spawn=MISSING does not erase spawn actual 09:52

IF exactly one RTH after the latest CRON_REBUILD / CRON_REBUILD_DUE had independent spawn <=09:35 AND content DONE <=09:35
THEN the next RTH 09:28 reserve also has:
  cron_rebuild_verify=HOLD | last_ontime_independent={HHMM} | watch_doors=0930_independent,0931_oneshot
  HOLD adds no fire minute and does not widen 09:30–09:35
  2026-09-25 last_ontime_independent=09:34 was that single ON_TIME
  It did not authorize CLEAR before 2026-09-28
  Do not backfill HOLD into the 2026-09-25 or 2026-09-28 files

IF the HOLD session's independent actual > 09:35
  OR (oneshot is still ARMED AND oneshot actual > 09:31)
THEN write CRON_REBUILD_DUE again with the fields above and reset HOLD

IF the immediately following RTH also has independent <=09:35 AND content DONE <=09:35
  AND (oneshot is not ARMED OR oneshot actual <=09:31)
THEN write CRON_REBUILD_VERIFY | status=CLEAR | independent_actual={HHMM}
  Do not write CLEAR before that second in-window RTH

2026-09-29 09:28 reserve, forward only:
  cron_oneshot=ARMED | fire_at=09:31 | prior_actual=09:52
  failed_door=0930_independent,0931_oneshot
  cron_rebuild_verify=ARMED
  prior_actual is the spawn line 09:52, not confirm 09:53, not 09:34
  fired=0931 is allowed only if oneshot actual <=09:31
  An in-window 2026-09-29 is HOLD, not CLEAR

Do not: widen 09:30–09:35
Do not: treat the 09:46 heal, the 09:50 MIN_SKIP, or the false fired=0931 token as independent-cron alignment
Do not: disarm an oneshot because 2026-09-25 was ON_TIME
Do not: add a fifth fire minute
Do not: replace the spawn minute with the confirm minute or the digest minute
Do not: reclassify the 2026-09-25 oneshot at 09:38 as LATE
Do not: shorten the 10m or 25m doors
Do not: reprice KOD 38 @ 77.26 → 81.0 pnl +142.12, or use 82.33 or ~89.97

NO extra delta for the 30m early gap.
  09:16→09:46 = 30m, door=10m_early, door+10=20, HEAL_LATE already required by Δ26.
  Do not shorten the 10m early door.

NO extra delta for the t1-inside-gap.
  11:12→11:30 = 18m is ROUTINE_GAP_EARLY / door=10m_early, and 18m is not HEAL_LATE.
  11:30→11:41 = 11m does not breach the 25m mid door.
  Booked exit stays written t1 81.0. Do not chase 82.33 or ~89.97.
  Do not change 11:30–15:05 from 25m to 10m or 15m.

NO extra delta for SCHEDULER_DEAD, Δ17, Δ30, Δ31, or Δ32.
  0 rewake lines before 09:40 is the existing Δ22 tag. Write it; do not renumber it.
  EOD HUNG was empty. No HUNG_EXPIRE.
  No TRAIN OPEN at 15:05. SIZE_MODE was on the ticket before the fill.

# DELTA 2026-09-29 — append after Δ33.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ33.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ34 OVERNIGHT_CLAUSE_AT_HUNG (declare overnight or not when the HUNG is written; Δ23 exit set unchanged)
Scope: a TRAIN3000 HUNG that is an earnings hard-catalyst or a VWAP-PB, including a leg that is both.
Sleeve A is out of scope. An already-OPEN leg is not rewritten.

IF this wake writes that HUNG
THEN the same line, before sleep, contains exactly one of:
  NO_OVERNIGHT
  OVERNIGHT_OK_UNTIL_STOP
  OVERNIGHT_OK_UNTIL_T1
IF that clause is still absent at sleep
THEN the id is not a fillable HUNG
  OVERNIGHT_CLAUSE_MISSING | {id}
  a later band touch does not fill and is not late-booked
  do not auto-write NO_OVERNIGHT
  do not auto-write OVERNIGHT_OK_UNTIL_STOP or OVERNIGHT_OK_UNTIL_T1
IF the clause is NO_OVERNIGHT
THEN after the fill, only existing Δ30 applies (15:40 / 15:50, qualified=0)
  do not flatten under Δ30 before 15:40
IF the clause is OVERNIGHT_OK_UNTIL_STOP or OVERNIGHT_OK_UNTIL_T1
THEN the clause only records that overnight hold is allowed
  exits stay inside Δ23: stop printed; t1 printed and the ticket already says scale or close; written structure invalidation printed
  UNTIL_STOP does not delete a written t1
  UNTIL_T1 does not delete a written stop
  prefer close, RTH close, day +$100, and round-count are still not exits

2026-09-29 CCL-PB-VWAP-0929 is already OPEN without the clause.
  Do not add the clause retroactively. Do not flatten it for the missing clause.
  Do not change 127 @ 24.575, stop 23.90, t1 25.50, t2 26.20, last~25.14, uPnL~+71.76, cash 11.22.

Do not: narrow or widen the Δ23 exit set.
Do not: apply this to Sleeve A.
Do not: flatten the already-open CCL on the next RTH open because the clause was missing.
Do not: change the 10m or 25m doors.
Do not: widen 09:30–09:35.
Do not: place_*. Do not: touch account 1429.

NO extra delta for OPEN_AUDIT.
  Execute Δ33 on the 2026-09-30 reserve before 09:28 ET:
    keep cron_oneshot=ARMED | fire_at=09:31 | prior_actual=09:42
    add failed_door=0930_independent,0931_oneshot
    add cron_rebuild_verify=ARMED
  2026-09-29 oneshot actual=09:45 is OPEN_AUDIT_ONESHOT_LATE, not fired=0931.
  In-window 2026-09-30 is HOLD, not CLEAR.
  Do not add a fifth fire minute.

NO extra delta for the 17–20m early gaps or HUNG_TOUCH_LATE.
  Door stays 10m_early until 11:30. gap<=20 is not HEAL_LATE. Fill stays 24.575.
  The 09:44 wake owed a Δ7 book. The 10:21 / 10:41 / 11:08 lines owed door=10m_early.
  Do not shorten 10m.


============================================================
# APPEND ONLY — Cursor postmortem 2026-09-30

粘贴位置：现有 `PROCESS-PATCHES` 末尾，Δ34 之后。  
不替换 Patch 1–6。不替换 Δ7–Δ34。不放宽任何旧门。冲突时更严者生效。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

## 结论

| 候选 | 判定 |
|---|---|
| (a) spawn 09:34 已在窗内，内容 DONE 09:37 | **加 Δ35。** LATE 标签已有。缺的是窗内 spawn 必须先落一行 DONE/BLOCKED，长清单不得把时间戳拖过 09:35 |
| (b) FRANK_FLAT ~10:09 收回现金后，prefer 仍开到 11:30，只有重复的 `NO_NEW_HANG` | **加 Δ36。** Δ32 的 11:30 空仓行要求当日 CLOSED=0，隔夜腿一平就不响。下一跳要 HUNG 或显式接受 MISS |
| (c) TRAIN 在 HUNG 默认 `NO_OVERNIGHT` | **不加。** 这是 Δ34 的执行。静默默认会放宽「缺句不可成交」 |

另外三件只执行旧条，不编号：

- 10:17–11:30 误用 25m mid 门。Δ18/Δ26 已规定 11:30 前是 `door=10m_early`。不缩短 10m。
- ~10:30 仍 FLAT 且没有名字过门，欠 `EMPTY_DAY_CLOCK`。照 Δ32 写，不新编号。
- 周 raw 写 $247.53，两笔账本之和是 142.12+106.68=248.80。不改价，不新开核对规则。下一份 EOD 写出加项。

## Δ35. OPEN_AUDIT_CONTENT_LINE_BEFORE_PROSE（收紧 Δ14/Δ27；窗与火钟不变）

9/30 独立 spawn 09:34，在 09:30–09:35 内。内容 `OPEN_AUDIT_DONE` 的时间是 09:37，已标 `OPEN_AUDIT_LATE`。`SPAWN_IN_WINDOW` 没有被当成内容时钟通过。标签符合 Δ14/Δ27。同一跳仍把逐腿清单写完才盖 DONE，所以窗内醒来仍晚 2 分钟。

- IF 独立开盘审计的 spawn 时间在 09:30:00–09:35:00 ET THEN 该跳在逐腿长文之前先写一行，且这一行的时间戳 ≤09:35:00：  
  `OPEN_AUDIT_DONE | held=... | gap_stop=... | unaudited=NONE`  
  若此时还有隔夜 OPEN 腿未判定，则改为  
  `OPEN_AUDIT_BLOCKED | {tickers}`  
  然后才写逐腿 prose。
- IF 时钟到达 09:35:00 时长文还在写 THEN 立即停笔，先写上面这一行，再继续长文。晚于 09:35 的 DONE 仍是 `OPEN_AUDIT_LATE`。
- IF spawn ≤09:35 但 DONE 时间戳 >09:35 THEN 内容时钟不通过。`SPAWN_IN_WINDOW`、`NOT_INDEPENDENT_LATE`、`NOT_CRON_STILL_LATE` 都不清除 `OPEN_AUDIT_LATE`。
- 两个时钟都清的条件不变（Δ27）：独立 spawn ≤09:35 且内容 DONE ≤09:35。今日不满足。禁止写 `CRON_REBUILD_VERIFY | status=CLEAR`。禁止重做已写出的 DONE。
- 2026-09-30 实例保持 spawn=09:34、content_DONE=09:37、`OPEN_AUDIT_LATE`。禁止把 DONE 改记成 09:34 或 09:35。
- **Do not:** 加第五个火钟。**Do not:** 放宽 09:30–09:35。**Do not:** 用醒来时的 mark 代替 Δ12 的开盘价。**Do not:** 因 NO_TRADE、FLAT 或没有 GAP 跳过这一行。

## Δ36. POST_FLAT_HANG_OR_ACCEPT（prefer 窗内现金重聚后的下一跳；不改出场集合）

CCL 在 ~10:09 按 Frank 指令平掉。现金 $11.22→$3,238.93，OPEN=0，HUNG=0，prefer 仍开到 11:30。之后每一跳都是 `NO_NEW_HANG`。qualified 保持 $0，EOD 日目标 MISS。Δ23 禁止为配额或 +$100 把仍在带内的腿平掉；这次平仓是指令，qualified=0 是对的。Δ32 在 11:30 写 `TRAIN_EMPTY_DAY` 的前提是当日 CLOSED=0，所以「已经平过一笔隔夜腿」的日子可以空转到 11:30 而不留接受行。

- 适用范围：TRAIN3000，prefer 窗 09:30–11:30 ET 尚未结束，刚刚记完一笔平仓（含 `FRANK_FLAT`），现金够开一腿有意义的名义，OPEN=0，HUNG=0，当日 qualified <100。Sleeve A 不适用。11:30 之后不适用。
- IF 满足上一句 THEN 下一跳在 sleep 之前写且只写下面两支之一：  
  (1) 一条 HUNG。该名在本跳已经打出硬催化、结构、以及同棒 entry/stop/t1。HUNG 行里已经有手写的恰好一个 Δ34 条款（`NO_OVERNIGHT` 或 `OVERNIGHT_OK_UNTIL_STOP` 或 `OVERNIGHT_OK_UNTIL_T1`）。缺条款则该 id 仍不可成交（Δ34）。短周期由写票的人写入 `NO_OVERNIGHT`，本条不自动补。  
  (2) `DAY_GOAL_MISS_ACCEPT | candidates={整数} | rejects={原因:计数,...} | raw={ } | qual={ } | asof={HHMM}`。`candidates` 是本跳点过名的个数，不用「约」。
- IF 该跳结束时只有 `NO_NEW_HANG`，(1) 与 (2) 都没有 THEN 写 `POST_FLAT_SILENT_DRIFT | asof={HHMM}`，不得 sleep。
- `DAY_GOAL_MISS_ACCEPT` 只记录「门没过，所以本日 qualified 目标未完成」。它不把 Δ24 的 MISS 改成 HIT，不是 `ACCEPT_TRAIN_EMPTY`，不清除 `TRAIN_EMPTY_DAY` 或 `TRAINING_FAILURE`，不制造 round，不授权未过门的名字成交。
- Δ32 照旧。10:30 及之后第一跳若仍 FLAT、且没有名字打出原门，仍写 `EMPTY_DAY_CLOCK`。本条不取代那一行。已有 HUNG 时 Δ32 继续沉默。
- 11:30 之后若仍无合格票，不开新腿去补美元差额（Δ24）。本条不把 prefer 收盘后的 FLAT 说成失误。
- 2026-09-30：~10:17 是平仓后的下一跳，点名 14 个（FDS、JBL、CAG、CALM、MU、PRGS、BSET、SMMT、ASTS、NVTS、KMX、KOD、CCL、YRD），只写了 `NO_NEW_HANG`。禁止把 `DAY_GOAL_MISS_ACCEPT` 补写进 9/30 journal。禁止为补这一行给其中任何一个编 fill。
- **Do not:** 为了凑 (1) 去挂一个已经 REJECT 的名字。**Do not:** 为 qualified +$100、空仓配额或「腾样本」出场或进场。**Do not:** 改 Δ23 的合法出场集合。**Do not:** 自动写 Δ34 条款。**Do not:** 改 127 @24.575→25.415、raw +106.68、qualified 0、现金 3238.93。**Do not:** 回挂 VKTX 或 SPY-PUT-ORL-PB-0928。**Do not:** `place_*`。

## 不新开

候选 (c) 不加 Δ37。

Δ34 已规定：写下 HUNG 的那一跳，sleep 前同一行必须有且只有 `NO_OVERNIGHT`、`OVERNIGHT_OK_UNTIL_STOP`、`OVERNIGHT_OK_UNTIL_T1` 之一；缺了就不是可成交 HUNG，并禁止自动写成其中任何一句。

若把 `NO_OVERNIGHT` 收成静默默认，缺句会变成可成交，这是放宽 Δ34，不采用。

执行句（不是新编号）：

- IF 下一张 TRAIN3000 HUNG 是短周期 THEN 写票的人在该行写入 `NO_OVERNIGHT`。
- IF 该票要隔夜 THEN 同一行手写 `OVERNIGHT_OK_UNTIL_STOP` 或 `OVERNIGHT_OK_UNTIL_T1`。不自动选择。
- 2026-09-29 已 OPEN、2026-09-30 已 FRANK_FLAT 的 CCL 不补条款，不改价。

门与周 raw 同样不编号：

- 10:17→10:30 ≈13m、10:40→10:51 ≈11m、10:51→11:10 ≈19m 在 11:30 前，门是 `10m_early`，不是 25m mid。都未超过 20m，所以不是 `HEAL_LATE`。Δ26 已要求按生效门抄进 EOD。不改分钟。
- ~11:19 的 prior ~11:08、~15:39 的 prior ~15:21 在 journal 标题中没有对应节。不把不存在的跳写进规则。
- 周 raw：下一份 EOD 写 `142.12+106.68=248.80`，并注明附件曾写 247.53、差额 1.27、本周 ledger 无第三笔。禁止改 CCL 或 KOD 的已记账价格去消除差额。

## 粘贴块

```
# DELTA 2026-09-30 — append after Δ34.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ34.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ35 OPEN_AUDIT_CONTENT_LINE_BEFORE_PROSE (tightens Δ14/Δ27; window unchanged)
IF the independent OPEN_AUDIT spawn is inside 09:30:00–09:35:00 ET
THEN before the per-leg prose, write one line timestamped <=09:35:00:
  OPEN_AUDIT_DONE | held= | gap_stop= | unaudited=NONE
  or, if any overnight OPEN leg is still unjudged:
  OPEN_AUDIT_BLOCKED | {tickers}
IF the clock hits 09:35:00 while prose is still being written
THEN stop, write that line, then resume prose
DONE timestamped after 09:35 remains OPEN_AUDIT_LATE
SPAWN_IN_WINDOW does not clear the content clock
Both clocks clear only when spawn <=09:35 AND content DONE <=09:35 (Δ27)
2026-09-30 stays spawn=09:34 content_DONE=09:37 OPEN_AUDIT_LATE
  Do not rewrite that DONE onto 09:34 or 09:35
  Do not write CRON_REBUILD_VERIFY status=CLEAR off this session
Do not: add a fifth fire minute
Do not: widen 09:30–09:35
Do not: replace the Δ12 open print with the wake-time mark
Do not: skip the line because NO_TRADE, FLAT, or no gap

Δ36 POST_FLAT_HANG_OR_ACCEPT (next wake after cash reunites inside the prefer window)
Scope: TRAIN3000, prefer 09:30–11:30 still open, a flatten (including FRANK_FLAT)
  just booked, cash can fund one meaningful leg, OPEN=0, HUNG=0, day qualified <100
Sleeve A is out of scope. After 11:30 this delta is silent (Δ24)
IF that is true THEN the next wake, before sleep, writes exactly one of:
  (1) a HUNG whose name has already printed hard catalyst AND structure
      AND same-bar entry/stop/t1
      AND the HUNG line already contains exactly one hand-written Δ34 clause
      A short-cycle ticket writes NO_OVERNIGHT by hand
      This delta does not auto-write the clause
      A missing clause is still not fillable (Δ34)
  (2) DAY_GOAL_MISS_ACCEPT | candidates={integer} | rejects={reason:count,...} | raw= | qual= | asof={HHMM}
      candidates is the count of names named on that wake, not "about"
IF the wake ends with only NO_NEW_HANG and neither (1) nor (2)
THEN POST_FLAT_SILENT_DRIFT | asof={HHMM}
  do not sleep
DAY_GOAL_MISS_ACCEPT does not flip a Δ24 MISS to HIT
  It is not ACCEPT_TRAIN_EMPTY
  It does not clear TRAIN_EMPTY_DAY or TRAINING_FAILURE
  It does not create a round and does not authorize a rejected name
Δ32 still applies: the first wake at or after 10:30 that is still FLAT
  with no name through the gate still writes EMPTY_DAY_CLOCK
  This delta does not replace that line
  Δ32 stays silent when a HUNG already exists
2026-09-30 ~10:17 owed (1) or (2). It named 14 symbols and wrote only NO_NEW_HANG
  Do not backfill DAY_GOAL_MISS_ACCEPT into the 2026-09-30 journal
  Do not invent a fill for any name on that list
Do not: hang a name that already failed a gate in order to satisfy (1)
Do not: enter or exit for qualified +100, an empty-day quota, or a sample count
Do not: change the Δ23 exit set
Do not: auto-write a Δ34 clause
Do not: reprice 127 @ 24.575 → 25.415, raw +106.68, qualified 0, cash 3238.93
Do not: rehang VKTX or SPY-PUT-ORL-PB-0928
Do not: place_*

NO Δ37. Candidate (c) is Δ34 execution.
  The next TRAIN3000 HUNG line hand-writes one of:
    NO_OVERNIGHT | OVERNIGHT_OK_UNTIL_STOP | OVERNIGHT_OK_UNTIL_T1
  A short-cycle ticket hand-writes NO_OVERNIGHT
  Do not auto-write NO_OVERNIGHT. A silent default would make a missing clause fillable.
  Do not add a clause to the already-closed CCL-PB-VWAP-0929

NO extra delta for the door mis-tag.
  Until 11:30 the live door is 10m_early (Δ18/Δ26)
  10:17→10:30 ≈13m, 10:40→10:51 ≈11m, 10:51→11:10 ≈19m are ROUTINE_GAP_EARLY
  None of those exceed door+10=20, so none is HEAL_LATE
  Do not shorten 10m. Do not change 11:30–15:05 from 25m to 10m
  Priors ~11:08 and ~15:21 have no journal section. Do not write a rule for a wake that is not in the file

NO extra delta for the week-raw gap.
  Next EOD prints 142.12+106.68=248.80 and notes the attachment figure 247.53, gap 1.27, no third ledger row this week
  Do not reprice KOD or CCL to close the gap

NO extra delta for the missing 10:30 EMPTY_DAY_CLOCK.
  Write the existing Δ32 line. Do not renumber it.
```


# 2026-10-01 — no new delta.
# Append after Δ36. On conflict, stricter wins.
# Do not loosen Patch 1–6 or Δ7–Δ36.
# Paper 7474 only. No place_*. Do not touch account 1429.

NO Δ37.

TRAIN_EMPTY_DAY: execute Δ32. Do not add a 10:30 forced hang.
  First wake at or after 10:30 still FLAT, cash can fund a leg, no name through
  hard-catalyst AND structure AND same-bar entry/stop/t1:
    EMPTY_DAY_CLOCK | asof=1030 | primary= | primary_state= | alt_scan=REQUIRED
    then one alternate under the same gates. No print → do not hang.
  First wake at or after 11:30 with OPEN=0 HUNG=0 CLOSED today=0:
    TRAIN_EMPTY_DAY | reason=NO_QUALIFIED_STRUCTURE | chase=FORBIDDEN
    DAY_GOAL stays MISS while qualified<100 (Δ24).
  2026-10-01: ~10:36 owed EMPTY_DAY_CLOCK; ~11:38 owed TRAIN_EMPTY_DAY.
  Journal left DAY_GOAL OPEN through ~15:54. EOD MISS is the right close, late.
  DAY_GOAL_MISS_ACCEPT stays inside Δ36 (next wake after a same-day flatten).
  This session opened FLAT. Δ36 does not fire.
  Do not hang a rejected name. Do not auto-write NO_OVERNIGHT.
  Do not backfill either line into the 2026-10-01 journal.

OPEN_AUDIT: execute Δ14/Δ27/Δ33/Δ35. No fifth fire minute.
  content DONE 09:37 stays OPEN_AUDIT_LATE. Do not rewrite it to 09:35.
  spawn≈09:35 is SPAWN_EDGE, not an in-window pass. No seconds in the file.
  If spawn is inside 09:30:00–09:35:00 inclusive, the DONE or BLOCKED line
  is timestamped <=09:35:00 before prose (Δ35). EDGE does not clear LATE.
  Independent routine actual=09:40 (journal body). Section head ~09:41 is not the clock.
  open-audit-done independent_confirm=09:37 is the parent/oneshot confirm.
  It does not clear the independent clock (Δ27/Δ29).
  Oneshot CONFIRM 09:37:43 is OPEN_AUDIT_ONESHOT_LATE, not fired=0931 (Δ33).
  2026-10-02 09:28 reserve:
    cron_align=REQUIRED | last_independent_actual=09:40
    cron_oneshot=ARMED | fire_at=09:31 | prior_actual=09:40
    failed_door=0930_independent,0931_oneshot
  Do not write CRON_REBUILD_VERIFY status=CLEAR off this session.
  Do not widen 09:30–09:35.

DOORS unchanged.
  09:35–11:30 = 10m_early (Δ18). 11:30–15:05 = 25m_mid (Δ15). 15:05–16:00 = 10m_lasthour (Δ20).
  09:23→09:44 ≈21m is ROUTINE_GAP_EARLY OVER_DOOR and HEAL_LATE (21>20).
  Do not write "do not treat as HEAL_LATE" on 21m.
  Before 11:30, 12m/12m/19m/18m gaps are OVER_DOOR on 10m_early, not mid GAP_OK.
  None of 12/14/18/19 is HEAL_LATE (door+10=20).
  14:55→15:10 ≈15m is 10m_lasthour OVER_DOOR, not 25m mid. 15<=20, so not HEAL_LATE.
  09:07→09:23 ≈16m ends before 09:35. Do not score it on the 10m_early door.
  Do not shorten 10m. Do not change 25m to 10m.

NO extra delta for week raw.
  Next line prints 142.12+106.68=248.80 and notes attachment 247.53, gap 1.27, no third ledger row.
  qualified 142.12 stays the HIT test. Do not reprice KOD or CCL.
  Print the addition next to the week figure. Do not stuff 248.80 into Δ24 raw_realized.
  Δ24 raw_realized / qualified_realized are that day's ledger sums. 2026-10-01 day is 0/0.
  Write the WEEK_GOAL pipe. Do not widen the reason enum.

NO extra delta for Mac.
  ~11:43–~12:54 journal rows are MAC_MIRROR_SYNC. From ~13:08, MAC_MIRROR_QUEUE.
  Do not write "offline all day". Box path is not a Desktop update.


============================================================
# APPEND 2026-10-02 Δ37 paste
# The uploaded rulebook body ended at the 2026-10-01 NO-Δ37 block.
# This paste is the operational block from PROCESS-PATCHES-delta-2026-10-02.md, copied unchanged.
# It is not a rewrite and it does not loosen Patch 1–6 or Δ7–Δ36.

# DELTA 2026-10-02 — append after the 2026-10-01 NO-Δ37 block.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ36.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ37 SECOND_EMPTY_DAY_HANG_OR_ACCEPT (a decision line at 10:30 after a prior empty RTH; structure gate unchanged)
Scope: TRAIN3000. The prior completed RTH ended qualified realized 0, zero complete rounds, and DAY_GOAL MISS.
  The TRAIN_EMPTY_DAY line on that prior day may itself have been late.
  2026-10-01 owed the line and closed EOD MISS; this pack does not contain the 10/1 journal, so do not treat that line as written on time.
  2026-10-02's six-section calls today the second consecutive empty day.
  This wake is the first at or after 10:30 ET. OPEN=0. HUNG=0.
  Cash can fund one meaningful leg. Prefer 09:30–11:30 is still open.
Sleeve A is out of scope. After 11:30 this delta is silent (Δ24/Δ32).
If a HUNG or an OPEN already exists, this delta is silent.
If the prior completed RTH was not that empty close, this delta does not fire.
  A first empty day still writes only Δ32 EMPTY_DAY_CLOCK.
  That preserves the 2026-10-01 refusal of a 10:30 forced hang.

IF this delta fires
THEN this wake still writes EMPTY_DAY_CLOCK and runs the Δ32 alt_scan
AND before sleep writes exactly one of:
  (1) a HUNG whose name has already printed, on this wake,
      hard catalyst AND structure AND same-bar entry/stop/t1
      AND the HUNG line already contains exactly one hand-written Δ34 clause
      A short-cycle ticket hand-writes NO_OVERNIGHT
      This delta does not auto-write the clause
      A missing clause is still not fillable (Δ34)
  (2) DAY_GOAL_MISS_ACCEPT | candidates={integer} | rejects={reason:count,...} | raw= | qual= | asof={HHMM} | prior_empty_date={YYYY-MM-DD}
      candidates is the count of names named on that wake
      prior_empty_date is the prior empty RTH
IF the wake ends with only NO_NEW_HUNG and neither (1) nor (2)
THEN EMPTY_DAY_SILENT_DRIFT | asof={HHMM}
  do not sleep
A name already tagged REJECT on this wake or an earlier wake cannot satisfy (1).
  REJECT_NO_CHASE, NO_RECLAIM, REJECT_EXTENDED, REJECT_STRUCTURE,
  REJECT_NO_HARD_CATALYST, REJECT_NO_REOPEN all count as REJECT.
DAY_GOAL_MISS_ACCEPT does not flip a Δ24 MISS to HIT.
  It is not ACCEPT_TRAIN_EMPTY.
  It does not clear TRAIN_EMPTY_DAY or TRAINING_FAILURE.
  It does not create a round and does not authorize a rejected name.
  A later prefer-window wake may still HUNG if a name then prints the full gate.
Δ32's 11:30 line is unchanged.
2026-10-02 ~10:33 is the instance. prior_empty_date=2026-10-01.
  That wake wrote CLOCK and NO_NEW_HUNG only.
  Do not backfill DAY_GOAL_MISS_ACCEPT into the 2026-10-02 journal.
  Do not invent a fill for NKE or for any name named on that wake.
Do not: read "hang one short-cycle" as permission to hang a rejected name.
Do not: lower RVOL, VWAP reclaim, or the three-price bar to satisfy (1).
Do not: auto-write NO_OVERNIGHT.
Do not: force this accept line on a first empty day.
Do not: change the Δ23 exit set or the Δ24 HIT test.
Do not: divide 3000 by 2 or by 3.
Do not: rehang VKTX or SPY-PUT-ORL-PB-0928.
Do not: reopen the CCL structure.
Do not: place_*.

NO extra delta for OPEN_AUDIT.
  2026-10-02 content DONE 09:37, oneshot spawn≈09:37, independent spawn 09:39, confirm 09:40.
  09:31 book-watch wrote PENDING. Δ29 already required MIN_OPEN_AUDIT that minute.
  Write OPEN_AUDIT_ONESHOT_LATE | planned=0931 | actual=09:37 | failed_door=0931_oneshot.
  Do not write fired=0931. The source name OPEN_AUDIT_0931_oneshot is not that token.
  Content and oneshot spawn share a minute. This is not a Δ35 prose delay.
  Do not rewrite DONE onto 09:35. Do not write CRON_REBUILD_VERIFY status=CLEAR.
  Do not add a fifth fire minute. Do not widen 09:30–09:35.
  2026-10-06 09:28 reserve, forward only:
    cron_align=REQUIRED | last_independent_actual=09:39
    cron_oneshot=ARMED | fire_at=09:31 | prior_actual=09:37
    failed_door=0930_independent,0931_oneshot
  09:39 is the independent spawn. 09:40 is the confirm. 09:37 is the oneshot spawn.

NO extra delta for TRAIN_EMPTY_DAY_LATE_WRITE.
  Δ32 already binds the first wake at or after 11:30.
  2026-10-02 ~11:40 and ~11:58 only refreshed EMPTY_DAY_CLOCK.
  Written ~12:09. Tag TRAIN_EMPTY_DAY_LATE_WRITE. Do not renumber it.

NO extra delta for the 17m early gap.
  09:31→09:48 ≈17m is ROUTINE_GAP_EARLY / door=10m_early / OVER_DOOR.
  17m is not over door+10=20, so not HEAL_LATE.
  11:04→11:16 ≈12m and 11:16→11:28 ≈12m were tagged door25m_mid.
  Both are before 11:30, so both are 10m_early OVER_DOOR, not HEAL_LATE.
  15:44→15:56 ≈12m is 10m_lasthour OVER_DOOR, not HEAL_LATE.
  Do not shorten 10m. Do not change 11:30–15:05 from 25m to 10m.
  The 15:44 prior ~15:35 has no section in the uploaded journal. Do not write a rule for it.

NO extra delta for week raw, WEEKEND_SWEEP, Δ17, or Mac.
  Next EOD prints 142.12+106.68=248.80 beside attachment 247.53, gap 1.27, no third ledger row.
  Day pipe: WEEK_GOAL | raw_realized=0 | qualified_realized=0 | target=100 | MISS | reason=no_setup.
  Week HIT test stays qualified 142.12. Do not reprice KOD or CCL.
  2026-10-02 has no WEEKEND_SWEEP_DONE line. Execute Δ20/Δ9/Δ21. Do not add an exit sentence here.
  EOD HUNG empty. No HUNG_TOUCH. No Δ17 expire.
  Mac offline all day. Box copy is not a Desktop update.

# APPEND ONLY — Cursor postmortem 2026-10-05

粘贴位置：现有 `PROCESS-PATCHES` 末尾。上传的规则正文停在 2026-10-01 的「NO Δ37」块，Δ37 的条文在 `PROCESS-PATCHES-delta-2026-10-02.md`。本次先把那份 Δ37 粘贴块按原样补进规则正文，再追加本文件。不改写 Δ37。

不替换 Patch 1–6。不替换 Δ7–Δ37。不放宽任何旧门。冲突时更严者生效。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

## 结论

五个候选里收紧四条。第五个只留提案。

| 候选 | 判定 |
|---|---|
| (a) HUNG 时 t1×股数 = $69.30 < $100，只有一句「needs t2 or multi-round」 | **加 Δ38。** Δ34 使未成交挂单在 11:30 作废，成交后的合格出场仍是止损或 t1。Δ31 的 `ONE_FULL_LEG` 使成交后残额不能再开一腿。没有任何一条要求把「底线走 t2」写成可检验的行 |
| (b) NO_OVERNIGHT 的 t1 只用了 ~1R；评估 MFE≥0.75R 则 SL→COST | **不加。** 把 t1 收到 09:47 已打出的高点 145.78 只有 $38.06，更低于底线。0.75R 的成本止损与 Δ8 的近 t1 在今天打在同一个上午，而且接不住 MFE。提案附后，未签字不生效 |
| (c) 15:53 出场只写了 paper-capital 与 hunt；journal 停在 14:20；ledger exit 到 EOD 才回填；状态文件 EOD 才 CLOSED | **加 Δ39。** Δ7 点了 ledger，没有把 journal 和该 id 的状态文件算进同一跳。只重说 Δ7 盖不住这种分裂 |
| (d) 0928/0930/0931/0935 都响了，实际 09:41–09:51，滞后 11–16 分钟 | **加 Δ40。** 四段都不是没醒。再写一个重建标签不会把 spawn 提前。前移计划时刻，不放宽 09:35，不增加第五个火钟 |
| (e) 09:47 纸面 HUNG 把 `wake_parent_needed=true` | **加 Δ41。** Frank 10/05 站立：纸面挂单 / 成交 / 管理不叫交易桌。Δ13 的 `HUNG_TOUCH` 出声保持不变 |

## Δ38. FLOOR_PATH_AT_HUNG（t1 美元低于日底线时，HUNG 必须写明底线走哪条；不改合格定义）

2026-10-05 09:47 的 `VST-PB-OPEN-RECLAIM-1005`：22 股，entry 144.05，t1 147.20，t2 150.30，stop 140.85。t1 路径 (147.20−144.05)×22 = $69.30。t2 路径 = $137.50。1R = $70.40。票上写了「day +$100 needs t2 or multi-round」，并手写了 Δ34 `NO_OVERNIGHT`。`SIZE_MODE=ONE_FULL_LEG`，计划成交后现金 $69.83。日目标 qualified >+$100 在开局就只剩一条没写清楚的 t2。随后 FILL ~10:00，高点 146.90 距 t1 0.30，15:53:53 按 NO_OVERNIGHT 在 144.67 平掉，raw +$13.64，qualified 0，DAY_GOAL MISS。

- 适用范围：写下 TRAIN3000 HUNG 的那一跳。Sleeve A 不适用。已经 OPEN 的腿不回写本条。
- IF 本跳写这张 HUNG THEN 同一行、sleep 之前先写下 `t1_dollars`。多头：`(t1−entry)×qty`。空头：用有利方向的绝对值。日底线是 100，与 Δ24 的 qualified 目标同一数字。本条不把未达 t1 的平仓改成 qualified。
- IF `t1_dollars≥100` THEN 写 `FLOOR_PATH=T1 | t1_dollars={ }`。本条到此结束。
- IF `t1_dollars<100` THEN 同一行再写且只写下面两支之一：
  1. `ROUND2 | after={t1|stop|flat} | where={本跳已经打出的价位或 if-then} | qty={整数} | t1_dollars_round2={ } | sum_path={ }`。仅当票上在任何成交之前已经写有 `SIZE_MODE=MULTI_ROUND | N={整数≥2} | per_leg_cap={美元}`，且按该 `per_leg_cap` 计算，这笔计划成交后的剩余现金 ≥ `per_leg_cap`。第二轮是计划，不是 fill。它日后要成为 HUNG 时，仍要硬催化、结构、同棒 entry/stop/t1，以及手写的恰好一个 Δ34 条款。已 REJECT 的名字不能出现在 `where` 里。
  2. `FLOOR_PATH=T2_ONLY | t2={ } | t2_dollars={ } | printed_hi={ } | printed_lo={ } | printed_range={ } | t2_minus_hi={ } | atr={数字或 UNAVAILABLE} | reachable={YES|NO}`。数字只用本跳已经打出的打印。没有 ATR 就写 `UNAVAILABLE`，不得临时估一个。`printed_range=printed_hi−printed_lo`。`t2_minus_hi=t2−printed_hi`。`reachable=YES` 当且仅当 `t2_dollars≥100` 并且（`t2_minus_hi≤printed_range`，或者 `atr` 是数字且 `t2_minus_hi≤atr`）。
- IF `t1_dollars<100` 且 (1)(2) 都没有 THEN `FLOOR_PATH_MISSING | {id}`。这张 id 不是合格 HUNG。继续扫。不得 sleep。
- IF 写了 (2) 且 `reachable=NO` THEN `FLOOR_PATH_UNREACHABLE | {id}`。这张 id 不是合格 HUNG。继续扫。不得用它成交。
- `ONE_FULL_LEG` 的残额按 Δ31 不够再开一腿有意义的名义。此时支路 (1) 不存在。不得把 `SIZE_MODE` 改成 `MULTI_ROUND` 来制造支路 (1)。不得把第一笔数量改小来腾现金。
- 散文「needs t2 or multi-round」不等于 (2)。
- 从下一张 HUNG 起（2026-10-06 及之后），缺本条合格行的 HUNG 不能充当 Δ37 的分支 (1)。Δ37 的其余句子不变。2026-10-05 的 `HUNG_WRITTEN` 按当时条文解除了 Δ37，不回溯成 `EMPTY_DAY_SILENT_DRIFT`。
- 2026-10-05 若当时写 (2)，可检验的数是：`t1_dollars=69.30`，`t2_dollars=137.50`，`printed_hi=145.78`，`printed_lo=140.90`，`printed_range=4.88`，`t2_minus_hi=4.52`，`atr=UNAVAILABLE`。4.52≤4.88，所以 `reachable=YES` 当时写得出来。禁止把这行补写进 10/5 的 journal 或 hunt。禁止把 144.05 的成交改成未成交。禁止改 144.67、+13.64、qualified 0、现金 3252.57。
- **Do not:** 把 `FLOOR_PATH=T1` 写在 `t1_dollars<100` 的票上。**Do not:** 为了让 t1 美元过 100 而放宽结构门或加大股数。**Do not:** 把 $3,000 除以 2 或 3。**Do not:** 改 Δ23 的出场集合或 Δ24 的 HIT 条件。**Do not:** 自动写 `NO_OVERNIGHT`。**Do not:** 用本条在 15:40 之前平掉仍在带内的腿。**Do not:** 回挂 VKTX 或 SPY-PUT-ORL-PB-0928。**Do not:** 重开 CCL 的同一结构。**Do not:** 为补这行去追 VST 的同一结构。**Do not:** `place_*`。

## Δ39. SAME_WAKE_BOOK_TRIPLE（收紧 Δ7；出场或成交要在同一跳落三处）

2026-10-05 ~15:53:53 的 VST 出场写进了 `paper-capital.md` 和 `train3000-hunt.md`（144.67，+$13.64，qualified 0）。上传的 `journal.md` 最后一节是 14:20，状态仍是 OPEN。`ledger.csv` 的 2026-10-05 VST 行在 EOD ~16:15 才把 exit / pnl 从那份 15:53 记录回填。六段写该 id 的 HUNG 状态文件在 EOD 才改为 CLOSED。Δ7 要求看见 fill / stop / force-paper 的那一跳睡前写 ledger。ledger 没在出场跳写上。journal 和状态文件不在 Δ7 的点名清单里，所以两份摘要更新、三处账落后，可以同时发生。

- 适用范围：TRAIN3000 的 FILL，以及 TRAIN3000 的 EXIT（含 Δ30 / Δ34 的 NO_OVERNIGHT 平仓、止损、t1）。Sleeve A 的 GAP_STOP 仍走 Δ7 / Δ12，本条不改那两句。
- IF 本跳把一笔 TRAIN3000 FILL 或 EXIT 记成已发生 THEN sleep 之前下面三处都存在，并且 id、数量、价格一致。出场跳还要 pnl 一致：
  1. `state/journal.md` 有本跳的一节，节内有这笔 FILL 或 EXIT。
  2. `ledger.csv` 里该 id 的行有 entry。若本跳是 EXIT，exit 与 pnl 已经写入，不是空着留到 EOD。
  3. 该 id 已经在用的那份 HUNG / leg 状态文件，状态与本跳一致：HUNG、OPEN 或 CLOSED。没有这份文件的新 id，本跳创建它。
- IF 三处缺一 THEN `BOOK_TRIPLE_MISS | {id} | missing={journal|ledger|state}`。不得 sleep。不得把 EXIT 留到 EOD 回填再当作本跳已经记账。
- 写了 `paper-capital.md` 或 `train3000-hunt.md` 不算三处已齐。
- 价格用本跳的可成交 print（Δ7）。不得用后一跳的 mark 回填来「补齐」三处。
- 2026-10-05 15:53 是本条的实例。禁止在复盘里再回填一次。禁止改 22 @144.05→144.67、+$13.64、qualified 0、现金 $3,252.57。10:00 的 FILL 由 ~10:07 的 10 点复查写入 ledger，10:11 的 journal 引用了它。相对 10:00 的棒晚约 7 分钟，仍在 Δ11 对 10:00 例程的 +10 分钟门内。不把这笔 FILL 改成 10:00 的另一价格。
- **Do not:** 用 EOD 回填代替当跳的三处。**Do not:** 为了让三处一致而改价。**Do not:** 编一笔 fill 去填平账。**Do not:** `place_*`。

## Δ40. OPEN_AUDIT_FIRE_SHIFT（只前移四个已有火钟的计划时刻；合格窗不变）

2026-10-05 四段 cron 都有实际点火，没有一段是没排上：

| 作业 | 计划 | 实际 | 滞后 |
|---|---|---|---|
| 0928 预热 | 09:28 | 09:43（`2026-10-05T13:43:01Z`） | 15 分钟 |
| 0930 独立 | 09:30 | 09:41（`fired_at=2026-10-05T13:41:12Z`，正文 `actual_spawn=09:41`） | 11 分钟 |
| 0931 oneshot | 09:31 | 09:43（`2026-10-05T13:43:19Z`，`ts=09:43:40-0400`） | 12 分钟 |
| 0935 补门 | 09:35 | 09:51（正文 `actual=09:51`；文件写入 `09:52:11-0400`） | 16 分钟 |

内容 DONE 09:42。独立行另有 `iso=2026-10-05T09:42:12-0400`，与 `fired_at` 差 1 分钟。spawn 用 09:41，内容用 09:42。不把 iso 当作 spawn。最大滞后 16 分钟。09:43 的 oneshot 写了 `NOT_CRON_REBUILD_DUE`，09:51 的补门写了 `OPEN_AUDIT_CRON_REBUILD_DUE`。spawn 09:41 并不 ≤09:35，已有的 DUE 标签仍然该写；`NOT_` 那一行是错的。oneshot 还写了 `fired=0931 | actual=09:43`，Δ33 禁止这个令牌。

- 四段计划时刻改为（ET）：预热 **09:12**，独立 **09:14**，oneshot **09:15**，补门 **09:19**。前移量 16 分钟，等于上表最大滞后。作业仍是这四段。
- reserve 里的 `fire_at` 从 09:31 改为 **09:15**，与新的 oneshot 计划时刻相同。`cron_oneshot=ARMED` 和 `cron_align=REQUIRED` 保留。09:31 不再写入 `fire_at`，只留作检查钟。
- 合格条件不变（Δ27）：独立 spawn 的时间 ≤09:35:00 且内容 `OPEN_AUDIT_DONE` 或 `OPEN_AUDIT_BLOCKED` 的时间 ≤09:35:00。计划时刻提前不构成合格。
- IF 前移后的作业在 09:30:00 ET 之前醒来 THEN 不得用盘前价写 `OPEN_AUDIT_DONE`。不得再睡去等下一段 cron。停在本跳，直到第一笔 RTH open print，然后在本跳执行 `MIN_OPEN_AUDIT`。DONE 晚于 09:35 仍是 `OPEN_AUDIT_LATE`。
- 09:31:00 与 09:35:00 仍是检查钟，不是新加的作业。09:31 仍没有 ≤09:31 的独立 spawn 时，Δ29 / Δ33 的句子照旧。09:35 仍没有 ≤09:35 的独立 spawn 时，只写已有的 `OPEN_AUDIT_CRON_REBUILD_DUE`。不发明同义词。不写 `CRON_REBUILD_VERIFY | status=CLEAR`。
- `fired=0931` 仅当 oneshot 实际运行在 09:31:00 或更早（Δ33）。source 名里的 `0931` 不是这个令牌。
- IF 实际滞后大于 16 分钟 THEN 结果仍按 Δ14 / Δ27 记 LATE。本条不保证永远准时。
- 2026-10-06 的 reserve 用 10/05 正文时钟，不用 iso，也不退回 10/02 模板里的 09:39 / 09:37：`last_independent_actual=09:41`；oneshot `prior_actual=09:43`；预热实际 09:43；补门实际 09:51。`failed_door=0928_warmup,0930_independent,0931_oneshot,0935_rewake`。
- 若 10/6 开盘前调度改不到这些时刻，Δ22 的 09:28 reserve 文件仍然要在 09:28 前存在。晚到的 spawn 仍然 LATE。不得把「计划时刻还没改」写成窗内通过。
- **Do not:** 增加第五个火钟。**Do not:** 放宽 09:30–09:35。**Do not:** 把 09:42 的 DONE 改记成 09:35。**Do not:** 用醒来 mark 代替 Δ12 的开盘价。**Do not:** 用 `NOT_CRON_REBUILD_DUE` 清除一个 >09:35 的 spawn。**Do not:** 因 NO_TRADE、FLAT 或没有 GAP 取消这四段。

## Δ41. PAPER_PARENT_WAKE_OFF（纸面挂上、成交、普通管理不叫交易桌；不撤已有的触及出声）

2026-10-05 09:47 的 hunt 与 journal 写 `wake_parent_needed=true`，理由是 HUNG 已写下、要 parent 向 Frank 报一行。当时 last~142.23，5m 尚未收在 144 之上，不是 `HUNG_TOUCH`。09:56 起写成 false，并写了 NO_TOUCH。Frank 10/05 的站立是纸面 fill / manage 不向交易桌报流水。

- IF 事件只是纸面 HUNG 的写下、纸面 FILL 的记账，或纸面持仓的管理 AND 本跳没有 `HUNG_TOUCH`、没有止损打印、没有 t1 打印、没有 `GAP_STOP`、没有 `BLOCKED`、没有 `EXIT_BLOCKED` THEN `wake_parent_needed=false`。不为这一行 ping Frank。
- IF 本跳有 `HUNG_TOUCH` 或 `GAP_STOP` 或 `BLOCKED` 或 `EXIT_BLOCKED` THEN 出声规则仍是 Δ13 与 Δ12。本条不把这些改成静音。
- 真钱任何状态不走本条。
- 2026-10-05 09:47 是实例。禁止回改那一行的 flag。其后各跳的 false 保持。
- **Do not:** 用「给 Frank 一行」把纸面 HUNG 或 FILL 设成 `wake_parent_needed=true`。**Do not:** 用本条跳过 `HUNG_TOUCH`。**Do not:** `place_*`。

## 不新开

### (b) t1 改按已实现区间，以及 0.75R 的 SL→COST

t1 147.20 相对 1R（3.20 点）是 3.15 点，约 0.98R。09:47 已打出的高点是 145.78。若把 t1 收到这个高点，(145.78−144.05)×22 = $38.06，比 $69.30 更低于 $100。`ONE_FULL_LEG` 不允许为了底线去加股数。这条改法不产生合格的 +$100 路径。不加。

Δ8 的中文条：每个 wake 扫全部 OPEN；命中 +1R，或距 t1 ≤0.25R，或进入 t1 带，或正股 t1 已打印；且现行止损宽于 COST；则本 wake 抬到 COST。0.25R = 0.80 点。11:07 的 11:00 棒高 146.74，距 t1 0.46。他们写的 last gap 0.625 也 ≤0.80。止损 140.85 宽于成本 144.05。这一跳标了 `T1_NEAR`，没有抬。标签是 `LATE_SL_COST`。不新编号。

英文粘贴 `IF hit AND stop > COST` 对多头初值止损字面不成立。冲突时中文「宽于 COST」更严，生效。不得用英文不等式跳过抬成本。不另开一条去改 Δ8 的触发集合。

0.75R 的价格是 144.05+2.40 = 146.45。11:00 棒已经过高，最终 MFE = 62.70/70.40 = 0.891R。这条触发和 Δ8 的近 t1 落在同一个上午。成本止损不保留 MFE。14:38 manchang 记录 14:34 的 1 分钟低点 144.03，比成本低 0.02。若当时已经抬到成本，这根低点有资格碰到止损，指向大约 0，而不是 +62.70，也不是已入账的 +13.64。不回改 144.67。

提案（不是规则。Frank/CEO 书面签字之前不得执行）：

**PROPOSAL · 未签字 · 不生效** — MFE≥0.75R SL→COST；不得当作生效规则，不得执行。


```
PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=NO_OVERNIGHT_MFE_075R_SL_COST | needs=Frank_and_CEO
Scope: TRAIN3000 OPEN leg whose ticket already says NO_OVERNIGHT. Sleeve A out of scope.
IF MFE >= 0.75R AND the current stop is still wider than COST
THEN SL→COST on this wake
  log SL→COST | time | R | reason=proposal_075R
Do not half-out. Do not add an exit to the Δ23 set.
Do not flatten before 15:40 under this proposal.
Do not apply it to the booked 2026-10-05 VST 144.67 / +13.64.
Unsigned: do not execute.
```

### 一并看到、同样不新开

- 11:30 前的门。09:56→10:11 = 15m，10:11→10:28 = 17m，10:28→10:39 = 11m，10:39→10:53 = 14m，10:53→11:07 = 14m，11:07→11:21 = 14m。这些跳写了 `door25m_mid | GAP_OK`。生效门是 `10m_early`。都是 OVER_DOOR。都 ≤20，都不是 HEAL_LATE。11:21→11:34 = 13m 的后一跳已过 11:30，25 分钟门，GAP_OK，这节是对的。不改 10 分钟，不改 25 分钟。
- 09:56 声称 09:35→09:56 ≈21m，门标成了 `10m_early`，没有 `HEAL_LATE`。21>20。上传的 manchang 没有 09:35 那一节，09:47 的 hunt 在中间。不为缺节写规则。
- 末小时。14:55→15:12 = 17m，门 `10m_lasthour`，OVER_DOOR，不是 HEAL_LATE。六段没列这一节，manchang 标了 `ROUTINE_GAP_LAST_HOUR`。15:33→15:45 = 12m，同样 OVER_DOOR，不是 HEAL_LATE，`ROUTINE_FIRE_LATE_4M` 与「15:41 槽约 15:45」一致。不把末小时门改短。
- Δ30。15:12 欠 `FLATTEN_RESERVE | VST-PB-OPEN-RECLAIM-1005 | clause=NO_OVERNIGHT | primary=15:40 | backup=15:50`。15:45 是 15:40 之后的第一跳，仍 HOLD，把平仓推到 15:51。实际 15:53:53，满足票上的 ≤15:55，不满足 primary 15:40。不把 15:40 改成 15:55。不把出场价改成 15:45 的 144.986。qualified 维持 0。
- 周数字。09:47 仍印 247.53/142.12。加法仍是 `142.12+106.68=248.80`，与附件 247.53 差 1.27，上周 ledger 无第三笔。10/5 新周是 13.64/0，等于当日唯一 ledger 行。禁止把 248.80 写入 10/5 的 `raw_realized`。禁止改 KOD 或 CCL。当日管道：`WEEK_GOAL | raw_realized=13.64 | qualified_realized=0 | target=100 | MISS | reason=early_exit`。reason 枚举不扩大。这不是 `no_setup`。
- 拒绝表行数。journal / 六段写扫 26、过 1、拒 25。09:47 表有 26 行拒绝。差 1。STNE/PAGS/INTR 是一行三个代码。不改计数。
- Δ17。收盘 HUNG 空。无 HUNG_TOUCH。无 EXPIRE / REWRITE。
- Δ37 的下一跳。10/5 不是空仓日（完整来回 1，尽管 qualified 0）。10/6 不触发 Δ37。第一天若再空仓，仍只写 Δ32。
- Sleeve A。AAPL 未进 +1R / 近 t1。CRWD 已在 COST。10/6 距 10/16 为 10 个日历日，Δ9 的 ≤7 不触发。不在本 delta 写平仓指令。
- Mac。10:11 曾 `MAC_MIRROR_SYNC`。其后队列。EOD offline。box 不是 Desktop 已更新。

## 粘贴块

```
# DELTA 2026-10-05 — append after the 2026-10-02 Δ37 paste.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ37.
# Paper 7474 only. No place_*. Do not touch account 1429.

Δ38 FLOOR_PATH_AT_HUNG (a sub-$100 t1 path is not a qualified HUNG until the floor path is written)
Scope: the wake that writes a TRAIN3000 HUNG. Sleeve A is out of scope.
  Do not rewrite an already-OPEN leg.
IF this wake writes that HUNG
THEN the same line, before sleep, states t1_dollars
  long: (t1-entry)*qty
  short: absolute favorable dollars
  the floor is 100, the same number as the Δ24 qualified target
  this delta does not turn a non-t1 exit into qualified
IF t1_dollars >= 100
THEN FLOOR_PATH=T1 | t1_dollars={ }
  and this delta is done
IF t1_dollars < 100
THEN the same line also contains exactly one of:
  (1) ROUND2 | after={t1|stop|flat} | where={a level or if-then already printed this wake} | qty={integer} | t1_dollars_round2={ } | sum_path={ }
      legal only if the ticket already says SIZE_MODE=MULTI_ROUND with a per_leg_cap
      AND cash left after the planned fill is still >= per_leg_cap
      ROUND2 is a plan, not a fill
      a later HUNG still needs hard catalyst, structure, same-bar entry/stop/t1,
      and exactly one hand-written Δ34 clause
      a name already REJECT cannot appear in where=
  (2) FLOOR_PATH=T2_ONLY | t2={ } | t2_dollars={ } | printed_hi={ } | printed_lo={ } | printed_range={ } | t2_minus_hi={ } | atr={number|UNAVAILABLE} | reachable={YES|NO}
      use prints already on this wake
      if no ATR is printed, write UNAVAILABLE; do not invent one
      printed_range = printed_hi - printed_lo
      t2_minus_hi = t2 - printed_hi
      reachable=YES only if t2_dollars>=100 AND (t2_minus_hi<=printed_range OR (atr is a number AND t2_minus_hi<=atr))
IF t1_dollars < 100 AND neither (1) nor (2)
THEN FLOOR_PATH_MISSING | {id}
  that id is not a qualified HUNG
  keep scanning
  do not sleep
IF (2) is written AND reachable=NO
THEN FLOOR_PATH_UNREACHABLE | {id}
  that id is not a qualified HUNG and is not fillable
ONE_FULL_LEG leaves a residual that Δ31 already says cannot fund another meaningful leg
  branch (1) does not exist on that ticket
  do not flip SIZE_MODE to MULTI_ROUND to unlock (1)
  do not cut the first qty to free cash
The sentence "needs t2 or multi-round" is not branch (2)
From the next HUNG on, a HUNG missing a qualified floor line cannot satisfy Δ37 branch (1)
  Δ37's other sentences stay
  2026-10-05 HUNG_WRITTEN still disarmed Δ37 under the text in force that morning
  do not retcon EMPTY_DAY_SILENT_DRIFT
2026-10-05 instance, not backfilled:
  t1_dollars=69.30 t2_dollars=137.50 printed 140.90-145.78 range=4.88 t2_minus_hi=4.52 atr=UNAVAILABLE
  4.52<=4.88 so reachable=YES was writable
  Do not write that line into the 2026-10-05 journal
  Do not unfill 144.05
  Do not reprice 144.67 / +13.64 / qualified 0 / cash 3252.57
Do not: tag FLOOR_PATH=T1 when t1_dollars<100
Do not: widen the structure gate or add shares to push t1 dollars over 100
Do not: divide 3000 by 2 or by 3
Do not: change the Δ23 exit set or the Δ24 HIT test
Do not: auto-write NO_OVERNIGHT
Do not: flatten an in-band leg before 15:40 to satisfy this line
Do not: rehang VKTX or SPY-PUT-ORL-PB-0928
Do not: reopen the CCL structure
Do not: rehang the VST structure to repair this line
Do not: place_*

Δ39 SAME_WAKE_BOOK_TRIPLE (tightens Δ7; fill or exit lands in three places before sleep)
Scope: a TRAIN3000 FILL, or a TRAIN3000 EXIT including a NO_OVERNIGHT flatten, a stop, or a t1
Sleeve A GAP_STOP stays on Δ7/Δ12
IF this wake books that FILL or EXIT as having happened
THEN before sleep all three agree on id, qty, and price
  an exit wake also agrees on pnl:
  (1) state/journal.md has a section for this wake that contains the FILL or EXIT
  (2) ledger.csv has the entry on that id
      an EXIT wake has exit and pnl filled in
      do not leave them blank for the EOD
  (3) the HUNG/leg state file already used for that id shows HUNG, OPEN, or CLOSED matching this wake
      a new id creates that file on this wake
IF any of the three is missing
THEN BOOK_TRIPLE_MISS | {id} | missing={journal|ledger|state}
  do not sleep
  do not treat an EOD backfill as this wake's book
paper-capital.md and train3000-hunt.md do not clear the triple
Price is this wake's tradeable print (Δ7)
  do not use a later mark to make the three match
2026-10-05 15:53 is the instance
  journal stops at 14:20
  ledger exit was backfilled at the EOD from paper-capital
  the HUNG state file was marked CLOSED at the EOD
  Do not backfill again
  Do not reprice 22 @ 144.05 → 144.67, +13.64, qualified 0, cash 3252.57
The 10:00 FILL was booked ~10:07 and cited by the 10:11 journal
  about 7 minutes after the bar, inside the Δ11 +10 minute door for the 10:00 routine
  Do not reprice that fill
Do not: replace the same-wake triple with an EOD backfill
Do not: reprice so the three files match
Do not: invent a fill to close a gap
Do not: place_*

Δ40 OPEN_AUDIT_FIRE_SHIFT (move the four existing planned fires earlier; the pass window stays)
2026-10-05 all four jobs fired. None was absent.
  warmup planned 09:28 actual 09:43 (2026-10-05T13:43:01Z) lag 15m
  independent planned 09:30 actual 09:41 (fired_at 13:41:12Z) lag 11m
  oneshot planned 09:31 actual 09:43 (13:43:19Z, ts 09:43:40-0400) lag 12m
  rewake planned 09:35 actual 09:51 (file ts 09:52:11-0400) lag 16m
  content DONE 09:42
  iso=09:42:12-0400 is not the spawn clock. Spawn is 09:41. Content is 09:42.
Shift planned fires by 16 minutes, the max lag above. ET:
  warmup 09:28 → 09:12
  independent 09:30 → 09:14
  oneshot 09:31 → 09:15
  rewake 09:35 → 09:19
  still four jobs
The reserve token fire_at changes from 09:31 to 09:15
  cron_oneshot=ARMED and cron_align=REQUIRED stay
  09:31 remains a check clock, not the planned fire
Pass test unchanged (Δ27): independent spawn <=09:35:00 AND content DONE or BLOCKED <=09:35:00
  an earlier plan time is not a pass
IF a shifted job wakes before 09:30:00 ET
THEN do not write OPEN_AUDIT_DONE from premarket prices
  do not sleep and wait for a later cron
  hold in this wake until the first RTH open print
  then MIN_OPEN_AUDIT in this same wake
  DONE after 09:35 is still OPEN_AUDIT_LATE
09:31 and 09:35 stay clocks, not new jobs
  Δ29/Δ33 still apply at 09:31
  at 09:35 with no independent spawn <=09:35 write the existing OPEN_AUDIT_CRON_REBUILD_DUE only
  do not invent a synonym
  do not write CRON_REBUILD_VERIFY status=CLEAR
fired=0931 only if the oneshot actually ran at or before 09:31 (Δ33)
  the source name OPEN_AUDIT_0931_oneshot is not that token
IF lag exceeds 16 minutes the result is still LATE
2026-10-06 reserve uses 2026-10-05 body clocks, not the iso, and not the 2026-10-02 template 09:39/09:37:
  last_independent_actual=09:41
  oneshot prior_actual=09:43
  warmup actual=09:43
  rewake actual=09:51
  failed_door=0928_warmup,0930_independent,0931_oneshot,0935_rewake
IF the scheduler cannot be edited before the 2026-10-06 open
THEN the Δ22 reserve file is still due before 09:28
  a late spawn is still LATE
  do not mark the window clear because the plan was not edited
Do not: add a fifth fire minute
Do not: widen 09:30-09:35
Do not: rewrite the 09:42 DONE onto 09:35
Do not: replace the Δ12 open print with the wake-time mark
Do not: let NOT_CRON_REBUILD_DUE clear a spawn later than 09:35
Do not: skip the four jobs because NO_TRADE, FLAT, or no gap

Δ41 PAPER_PARENT_WAKE_OFF (paper HUNG write, paper fill, and ordinary manage do not page the desk)
IF the event is only a paper HUNG being written, a paper FILL being booked, or paper management
AND this wake has no HUNG_TOUCH, no stop print, no t1 print, no GAP_STOP, no BLOCKED, no EXIT_BLOCKED
THEN wake_parent_needed=false
  do not ping Frank for that line
IF this wake has HUNG_TOUCH or GAP_STOP or BLOCKED or EXIT_BLOCKED
THEN Δ13 and Δ12 still page
  this delta does not silence those
Real-money state is out of scope
2026-10-05 09:47 set wake_parent_needed=true because the HUNG was written. Last was ~142.23. Not a touch.
  09:56 set false and wrote NO_TOUCH
  Do not edit the 09:47 flag
Do not: set wake_parent_needed=true to send Frank a paper HUNG or FILL one-liner
Do not: use this delta to skip HUNG_TOUCH
Do not: place_*

NO extra delta for t1-from-realized-range or for MFE>=0.75R SL→COST.
  Pinning t1 to the 09:47 printed high 145.78 is (145.78-144.05)*22 = 38.06, further under 100.
  ONE_FULL_LEG cannot add shares to clear the floor. Do not add that rule.
  Δ8 already fires when dist(t1)<=0.25R and the stop is still wider than COST.
  0.25R = 0.80. At 11:07 the 11:00 bar high 146.74 was 0.46 from t1.
  The written last-gap 0.625 is also <=0.80. Stop 140.85 was wider than cost 144.05.
  They tagged T1_NEAR and did not raise. That is LATE_SL_COST. Do not renumber it.
  The English paste "stop > COST" is false for a long whose stop price is still under entry.
  The Chinese sentence "wider than COST" is stricter and wins.
  Do not skip the raise because of the English inequality.
  0.75R price = 146.45. MFE = 62.70/70.40 = 0.891R. Same morning as the Δ8 hit.
  A cost stop does not keep the MFE.
  The 14:38 manchang records a 14:34 1m low 144.03, 0.02 under cost 144.05.
  A cost stop would have been eligible there. That points near 0, not at +62.70.
  Do not reprice the booked 144.67 / +13.64.
  PROPOSAL_NOT_IN_FORCE below. Do not execute it unsigned.

PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=NO_OVERNIGHT_MFE_075R_SL_COST | needs=Frank_and_CEO
  Scope: TRAIN3000 OPEN leg whose ticket already says NO_OVERNIGHT. Sleeve A out of scope.
  IF MFE >= 0.75R AND the current stop is still wider than COST
  THEN SL→COST on this wake
  Do not half-out. Do not add an exit to Δ23. Do not flatten before 15:40 under this proposal.
  Do not apply it to the booked 2026-10-05 VST.
  Unsigned: do not execute.

NO extra delta for the door mis-tags, Δ30, week raw, the reject-row count, Δ17, Δ37's next day, Sleeve A, or Mac.
  Before 11:30 the door is 10m_early.
  15m, 17m, 11m, 14m, 14m, 14m tagged door25m_mid are OVER_DOOR, not HEAL_LATE.
  11:21→11:34 = 13m is after 11:30, so 25m GAP_OK.
  09:35→09:56 = 21m was tagged 10m_early and not HEAL_LATE. No 09:35 section is in the uploaded manchang. Do not write a rule for the missing section.
  14:55→15:12 = 17m and 15:33→15:45 = 12m are 10m_lasthour OVER_DOOR, not HEAL_LATE.
  Do not shorten 10m. Do not change 11:30-15:05 from 25m to 10m.
  Δ30 primary stays 15:40. The 15:55 clause on the ticket does not move it.
  2026-10-05 flattened at 15:53:53. Do not reprice to the 15:45 print 144.986.
  Week addition, if 247.53 is reprinted: 142.12+106.68=248.80, gap 1.27, no third prior-week row.
  New week W/C 10/05 is 13.64/0. Do not stuff 248.80 into raw_realized.
  Day pipe: WEEK_GOAL | raw_realized=13.64 | qualified_realized=0 | target=100 | MISS | reason=early_exit.
  Do not widen the reason enum. Do not call it no_setup.
  Reject table has 26 data rows. Journal says scanned 26, pass 1, reject 25. Off by 1. Do not pick a row to delete.
  EOD HUNG empty. No Δ17 expire.
  2026-10-05 was not an empty day. Δ37 does not fire on 2026-10-06.
  AAPL was not at +1R or near t1. CRWD is already COST.
  2026-10-06 is 10 calendar days before 2026-10-16. Δ9's <=7 does not fire. Do not add an exit sentence.
  Mac was connected at 10:11, then queued, offline at EOD. Box copy is not a Desktop update.
```


# APPEND ONLY — Cursor postmortem 2026-10-06

粘贴位置：现有 `PROCESS-PATCHES` 末尾，Δ41 之后。不改写 Δ38–Δ41。不替换 Patch 1–6。不替换 Δ7–Δ41。不放宽任何旧门。冲突时更严者生效。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

## 结论

五个候选里收紧四条。第五个只重申，不新编号。凡是改 Frank 的日目标或出场方式的句子，都标 **PROPOSAL · 未签字 · 不生效**。

| 候选 | 判定 |
|---|---|
| (a) 今日 HUNG 文件没有 `FLOOR_PATH=` 行，t1 = $42.00，t2 = $78.00，两路都低于 $100，11:05 仍补记成交 | **加 Δ42。** Δ38 已把缺行写成「不是合格 HUNG、不得 sleep」。缺行那一支没有写「后一跳不得成交、不得补记」。`reachable=NO` 那一支才写了不得成交。今天走的是缺行，然后成交了 |
| (b) 票面写「SL→COST at t1 · t2 162.50」，账上按 Δ23 + KOD 先例做了 T1_EXIT 全平。出场后 t2 162.50 被六段记为已印，持有到 t2 是 +$78.00，仍低于 $100 | **加 Δ43。** 每张 HUNG 必须写且只写一个令牌：`T1=EXIT_ALL` 或 `T1=SL2COST_RIDE_T2`。缺令牌不可成交。哪一个当默认、以及 `SL2COST_RIDE_T2` 能否执行，是提案。签字前 Δ23 的出场集合不动 |
| (c) 11:44 的 T1_EXIT 在 ledger、HUNG 状态文件、11:44 manchang 里，journal.md 没有这一节。10/06 的 journal 也没有 09:15–10:47，HUNG 的 10:28 写下和 10:38 / 10:47 检查只在状态文件里 | **加 Δ44。** Δ39 已要求出场跳的 journal 含这笔 EXIT。11:54 及之后只写了现金和 42.00/42.00，没有 id、没有 160.70。后一跳照样 sleep。Δ39 的范围是 FILL / EXIT，不覆盖 HUNG 的写下 |
| (d) 「Agentic 开盘猎」09:31 运行失败，10/06 没有扫描表，也没有候选数。10 点复查留下一条 VST 计划 | **加 Δ45。** Δ11 的迟到短讯和 Δ18 的「长文不等于扫描表」都没有把补表交给 10 点复查 |
| (e) 10:51 / 11:01 槽缺失，FILL 在 11:05 补记；末小时三段；Δ40 的四个火钟仍未改到例程上，OPEN_AUDIT 连续 LATE | **不加。** 早盘 18 分钟和末小时破门是 Δ18 / Δ20 / Δ26 没执行。Δ40 的时刻已经写过。父级持有改例程的工具，本文件把时刻再抄一遍 |

## Δ42. FLOOR_PATH_FIELD_BLOCKS_FILL（收紧 Δ38；缺 `FLOOR_PATH=` 行的 HUNG 后一跳也不得成交）

2026-10-06 ~10:28 的 `VST-PB-RECLAIM-1006`：20 股，entry 158.60，stop 155.40，t1 160.70，t2 162.50。`SIZE_MODE` 按满额单腿用，计划名义 158.60×20 = $3,172.00，计划成交后现金 3,252.57−3,172.00 = $80.57。t1 路径 (160.70−158.60)×20 = $42.00。t2 路径 (162.50−158.60)×20 = $78.00。1R = (158.60−155.40)×20 = $64.00。HUNG 文件有 Δ34 的 `NO_OVERNIGHT`，没有 `FLOOR_PATH=` 这一行。

同一文件上当时已经打出的打印：open 151.635，HOD 160.70，lo 151.44。若当时写 Δ38 的支路 (2)，可检验的数是 `printed_hi=160.70`，`printed_lo=151.44`，`printed_range=9.26`，`t2_minus_hi=1.80`，`atr=UNAVAILABLE`（文件里没有 ATR）。1.80≤9.26，区间这一半过得去。`t2_dollars=78.00<100`，所以 `reachable=NO`。支路 (1) 的 `ROUND2` 在 `ONE_FULL_LEG` 上不存在，残额 $80.57 也开不出下一腿。这张票在 Δ38 下只可能是 `FLOOR_PATH_MISSING` 或 `FLOOR_PATH_UNREACHABLE`。两支都不合格。11:05 仍把 10:50 的限价补记成 FILL。

Δ38 对缺行的句子是「不是合格 HUNG，继续扫，不得 sleep」。对 `reachable=NO` 的句子才是「不得用它成交」。缺行的那张票睡过了，后一跳成交了。合格定义不改：写全了的 `FLOOR_PATH=T1`（仅当 t1 美元≥100）、合法的 `ROUND2`、或 `reachable=YES` 的 `FLOOR_PATH=T2_ONLY`，仍是合格 HUNG。Δ23 / Δ24 的合格出场定义不改。已经入账的 +$42.00 仍是 t1 出场的 qualified。

- 适用范围：写下 TRAIN3000 HUNG 的那一跳，以及之后看见这张 id 仍是 HUNG 的每一跳。Sleeve A 不适用。已经 OPEN 的腿不回写本条。
- IF 本跳写这张 HUNG THEN 状态文件里必须有一行，且该行含字面字段 `FLOOR_PATH=`。Δ38 的哪一支、怎么算 `reachable`，句子不变。
- IF `t1_dollars≥100` AND 该行不是 `FLOOR_PATH=T1 | t1_dollars={ }` THEN 这张 id 不是合格 HUNG。
- IF `t1_dollars<100` AND 该行不是 Δ38 的支路 (1) 或支路 (2) THEN `FLOOR_PATH_MISSING | {id}`。这张 id 不是合格 HUNG。
- IF 支路 (2) 写成 `reachable=NO` THEN 仍是 Δ38 的 `FLOOR_PATH_UNREACHABLE | {id}`。本条不改这个判定。
- IF 上两支任一成立 THEN 这张 id 不可成交。后一跳即使打出触发，也不 FILL，也不按限价补记。`FLOOR_PATH_NOFILL | {id}`。不得 sleep。不得把 `SIZE_MODE` 改成 `MULTI_ROUND`。不得把第一笔数量改小。
- 散文「needs t2 or multi-round」仍不等于支路 (2)。Δ38 的这句保留。
- 2026-10-06 的 FILL 已经入账。禁止改 20 @158.60、出场 160.70、+$42.00、qualified、现金 $3,294.57。禁止把这张票改成未成交。禁止把 `FLOOR_PATH=` 行补写进 10/06 的 HUNG 文件来洗掉缺行。
- **Do not:** 改 Δ38 里「写全且 `reachable=YES` 才是合格 HUNG」的定义。**Do not:** 为了让 t1 美元过 100 而放宽结构门或加大股数。**Do not:** 把 $3,000 除以 2 或 3。**Do not:** 改 Δ23 的出场集合或 Δ24 的 HIT 条件。**Do not:** 自动写 `NO_OVERNIGHT`。**Do not:** 回挂 VKTX 或 SPY-PUT-ORL-PB-0928。**Do not:** 重开 CCL 的同一结构。**Do not:** 为补这行去追 VST 的同一结构。**Do not:** `place_*`。

### 提案（不是规则。Frank 书面签字之前不得执行）

`ONE_FULL_LEG` 下这张票的名义是 $3,172.00。日底线 $100 对这个名义的比例是 100/3172 = 3.1526%。20 股要让 t1 路径达到 $100，每股有利行程是 $5.00，价格是 158.60+5.00 = 163.60。今天的 t1 160.70 和 t2 162.50 都低于 163.60。这是这张已平仓票的算术，不是新目标，也不是选股。

下面两支会改「什么样的 HUNG 算合格」或改 Δ31 的下单前规模。因此不生效。

**PROPOSAL · 未签字 · 不生效** — 底线结构二选一；不得当作生效规则，不得执行。

```
PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=FLOOR_STRUCTURE_CHOICE | needs=Frank
Scope: the next TRAIN3000 HUNG. Does not reprice 2026-10-06.
Does not change the Δ24 qualified-exit test. A booked t1 exit stays qualified.
Option A — t1 itself must clear the floor:
  a HUNG is qualified only if t1_dollars>=100
  AND the same printed-range test Δ38 already uses for t2:
    t1_minus_hi = t1-printed_hi
    reachable=YES only if t1_dollars>=100
      AND (t1_minus_hi<=printed_range OR (atr is a number AND t1_minus_hi<=atr))
  T2_ONLY would no longer make a HUNG qualified
  That changes Δ38. Unsigned: do not execute.
Option B — MULTI_ROUND written before any fill:
  the ticket already says SIZE_MODE=MULTI_ROUND | N>=2 | per_leg_cap={ }
  residual cash after the planned fill is still >= per_leg_cap
  per_leg_cap still clears NO_TRAIN3000_MICRO_SAMPLE
  round 2 is a later HUNG after the first leg ends, and still needs the full gate
  Do not flip an already-written ONE_FULL_LEG ticket
  Do not cut the first qty to free cash
  Do not divide 3000 by 2 or by 3
  That changes the standing ONE_FULL_LEG choice. Unsigned: do not execute.
Until one option is signed, Δ38 and Δ42 stand as written.
Do not apply either option to VST-PB-RECLAIM-1006.
Unsigned: do not execute.
```

## Δ43. T1_MODE_AT_HUNG（HUNG 必须写明 t1 的一种处理；默认值未签字则 Δ23 不动）

2026-10-06 的 HUNG 行写的是「SL→COST at t1 · t2 162.50」。11:44 的状态文件、ledger、11:44 manchang 记的是 T1_EXIT：1 分钟 11:43 高 160.80，按写下的 t1 160.70 全平，+$42.00 qualified，不追。交易员的理由是 Δ23 的回合定义加上 KOD-0928 的先例。

ledger 里两笔旧行不是同一种出场。KOD-0928 是 T1_EXIT，按写下的 t1 81.0 全平，+$142.12 qualified。QQQ 2026-09-11 的 `long-reclaim-full` 备注是 t1 716.50 之后 stop→BE，再在 t2 717.50 出场，+$58.00。本包没有这两张票的原始票面。不能从账本行推出它们当时写了哪个令牌。今天的票用散文写了抬成本，账上走了 KOD 那种全平。令牌缺失，交易员当场选了一边。

若按票面散文持有到写下的 t2 162.50：(162.50−158.60)×20 = $78.00，仍低于 $100。六段写日高 162.69，窗口 13:00–13:30 ET。这个日高只出现在六段，journal、manchang、ledger、HUNG 文件都没有。用六段的日高做算术：(162.69−158.60)×20 = $81.80，仍低于 $100。两笔都不是入账数字。禁止改 160.70 / +$42.00。

Δ23 的合法出场仍是：止损已打印；t1 已打印且按该票写明的减仓或平仓执行；该票写明的结构失效已打印。散文「SL→COST at t1」既不是减仓也不是平仓。Δ8 仍是近 t1 就抬成本，不把 t2 加进出场集合。

- 适用范围：写下 TRAIN3000 HUNG 的那一跳。Sleeve A 不适用。已经 OPEN 的腿不回写本条。
- IF 本跳写这张 HUNG THEN 同一行、sleep 之前含有且只含下面两个令牌之一：`T1=EXIT_ALL` 或 `T1=SL2COST_RIDE_T2`。
- IF 两个都没有，或两个都有 THEN `T1_MODE_MISSING | {id}`。这张 id 不是合格 HUNG，不可成交。后一跳的触发不 FILL，不补记。不得 sleep。不得自动写成其中任何一个令牌。散文「SL→COST at t1」不算令牌。
- IF 令牌是 `T1=EXIT_ALL` THEN 出场仍是 Δ23：t1 首次打印，按写下的 t1 全平，不追。这不扩大出场集合。
- IF 令牌是 `T1=SL2COST_RIDE_T2` THEN 见下方提案。签字之前这张 id 不可成交，写 `PROPOSAL_NOT_IN_FORCE | id=T1_DEFAULT_MODE`。不得按这个令牌持有到 t2。
- 2026-10-06 已经按 T1_EXIT 入账。禁止改成持有到 162.50。禁止改 +$42.00、qualified、现金 $3,294.57。
- **Do not:** 改 Δ23 的出场集合。**Do not:** 改 Δ24 的 HIT 条件。**Do not:** 用本条半出。**Do not:** 用本条在 15:40 之前平掉仍在带内的腿。**Do not:** 执行未签字的 MFE≥0.75R 提案。**Do not:** `place_*`。

### 提案（不是规则。Frank/CEO 书面签字之前不得执行）

交接写明 Frank 9/17 的偏好是抬到成本，而不是在 t1 强制全平。书面里已生效的抬成本是 Patch 3 和 Δ8。把「t1 只抬成本、持有到 t2」写成默认出场，会给 Δ23 增加一条 t2 出场。所以默认选择不生效。

**PROPOSAL · 未签字 · 不生效** — t1 默认令牌；不得当作生效规则，不得执行。

```
PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=T1_DEFAULT_MODE | needs=Frank_and_CEO
Scope: which single token a new TRAIN3000 HUNG may leave as the default.
Sleeve A out of scope. Does not reprice 2026-10-06.
Choice, exactly one, unsigned:
  A) default T1=EXIT_ALL
     first t1 print flats the leg at the written t1
     this is the Δ23 exit already in force, and the KOD-0928 booked shape
  B) default T1=SL2COST_RIDE_T2
     at the first t1 print, raise the stop to COST and hold
     later exit only at the cost stop, at the written t2, or at a written invalidation
     Frank 9/17 preference as stated in the 2026-10-06 handoff
     this adds a t2 print to the exit set
Until one choice is signed:
  do not auto-write either token
  do not execute B
  a HUNG that writes B is not fillable
  a HUNG that writes A exits under Δ23
  a HUNG that writes neither is T1_MODE_MISSING and is not fillable
Do not half-out. Do not add an exit to Δ23 under this proposal.
Do not apply B to the booked 20 @ 158.60 → 160.70 / +42.00.
The ride counterfactual (162.50-158.60)*20 = 78.00 stays a counterfactual and stays under 100.
Unsigned: do not execute.
```

## Δ44. BOOK_TRIPLE_JOURNAL_STICKS（收紧 Δ39；journal 缺节会粘到后一跳，HUNG 的写下也要进 journal）

2026-10-06 ~11:43 的 T1_EXIT 写进了三处里的两处，以及两份不算三处的摘要：

- ledger 的 2026-10-06 VST 行：exit 160.70，pnl 42.00，状态 closed。备注写明 T1_EXIT ~11:43。
- `state/HUNG-VST-PB-RECLAIM-1006.txt` 的 11:44 行：status=CLOSED，pnl +42.00，cash 80.57→3294.57。
- manchang 的 11:44 快照有同样的 T1_EXIT。manchang 不是 `state/journal.md`。
- `paper-capital.md` 与 `train3000-hunt.md` 是 11:44 的摘要。Δ39 已写明这两份不算三处。
- `journal.md` 没有 11:44 节。下一节是 11:54，写了 FLAT、现金 $3,294.57、当日 42.00/42.00。这一节没有 id `VST-PB-RECLAIM-1006`，没有出场价 160.70，没有数量 20。

Δ39 要求记账的那一跳在 sleep 前写上 journal 节。这一跳没有。从 11:54 到 15:56 的每一跳都 sleep 了，缺节留到了 EOD 的缺陷标签。

另一处：上传的 journal 在 10/05 EOD 之后，下一节就是 10/06 11:05。10/06 的 09:15–10:47 没有 journal 节。HUNG 的写下在 ~10:28，检查在 10:38 和 10:47，这三行只在 HUNG 状态文件里。Δ39 的范围是 FILL 和 EXIT，不包含 HUNG 的写下，所以只重说 Δ39 盖不住 10:28 这行。

11:05 的 FILL 三处是齐的：journal 有这一节，ledger 有 entry，状态文件改为 OPEN。晚 15 分钟是槽位问题，不是 FILL 的三处缺失。不把这笔 FILL 改价。

- 适用范围：TRAIN3000 的 FILL、TRAIN3000 的 EXIT，以及 TRAIN3000 HUNG 的写下。Sleeve A 的 GAP_STOP 仍走 Δ7 / Δ12。
- IF 本跳把 FILL 或 EXIT 记成已发生 THEN Δ39 的三处仍要在 sleep 前写齐。journal 这一处要含 id、数量、价格。出场跳还要含 pnl。只写现金和当日合计、不含 id 与价格的后一节，不算这一处已经写上。
- IF 后一跳看见 ledger 与该 id 的状态文件已经一致，而 journal 仍没有含 id 与价格的那一节 THEN `BOOK_TRIPLE_MISS | {id} | missing=journal`。不得 sleep。sleep 前追加一节 journal，原文引用 ledger 与状态文件里已经一致的 id、数量、价格、pnl。不得改用后一跳的 mark。ledger 与状态文件不一致时，不挑选一个价格，不得 sleep。
- IF 本跳写下 TRAIN3000 HUNG THEN 同一跳的 `state/journal.md` 有一节，节内有该 id 以及 entry、stop、t1、t2。只有状态文件 THEN `JOURNAL_HUNG_MISS | {id}`。不得 sleep。10:38 / 10:47 这种后续检查不另要求各写一节；欠的是写下那一跳。
- 写了 manchang、paper-capital 或 train3000-hunt，仍不算 journal 这一处。
- 2026-10-06 是实例。本复盘不补写 journal。禁止改 20 @158.60→160.70、+$42.00、现金 $3,294.57。禁止用 162.50 或六段的 162.69 去「补齐」journal。
- **Do not:** 用 EOD 改价代替当跳的 journal。**Do not:** 为了让三处一致而改价。**Do not:** 编一笔 fill。**Do not:** `place_*`。

## Δ45. SCAN_TABLE_ON_HUNT_FAIL（开盘猎没有扫描表时，10 点复查在本跳写上）

2026-10-06「Agentic 开盘猎」09:31 例程运行失败。六段写当日没有扫描表，候选数无法核实。10 点复查 ~10:05 写出了 VST 这一条计划，没有候选数，也没有逐名拒绝原因。Δ11 管的是计划点之后 10 分钟的短讯。Δ18 写明猎单长文不等于 `SCAN_TABLE` 成功。两条都没有指定谁在 10:00 把表补上。

- IF 美股 RTH 日 AND 到 10:00:00 ET 仍没有一份 10/06 这种日期的扫描表（候选数，加上每个未挂名字的拒绝原因）THEN 10 点复查这一跳在 sleep 前写上这张表。表含：本跳点过名的个数、每个未挂名字的拒绝原因、若有 HUNG 则该 id 和它过了的门。
- IF 这一跳只写了一条计划、没有个数 THEN `SCAN_TABLE_MISSING | asof={HHMM}`。不得把这一条计划当成扫描表。不得 sleep。不得临时编一个个数。
- 例程运行失败不是「候选数为 0」。0 只在表上真有零行时才写。
- 2026-10-06 没有这张表。禁止在复盘或次日晨报里补一个候选数。
- **Do not:** 为了让表非空去降低硬催化、结构或同棒三价。**Do not:** 把已经 REJECT 的名字挂上。**Do not:** 回挂 VKTX 或 SPY-PUT-ORL-PB-0928。**Do not:** 重开 CCL。**Do not:** `place_*`。

## 不新开

### 早盘门、缺槽、FILL 补记的 15 分钟

10:47→11:05 = 18 分钟。11:05 仍在 11:30 之前，生效门是 `10m_early`。18>10，所以是 OVER_DOOR。18≤20，所以不是 `HEAL_LATE`。journal 把这 18 分钟标成 `door25m_mid | GAP_OK`。Δ18 / Δ26 已要求写 `door=10m_early`。不新编号，不把 10 分钟改成 18 分钟或 25 分钟。

10:51 与 11:01 两个槽在 journal 里写明未见。FILL 的打印在 ~10:50，记账在 11:05，相隔 15 分钟。11:05 用的是限价 158.60，不是后一跳的 mark。Δ7 的价格这跳守住了。缺的是槽，不是第三套成交价。不新编号。

六段写的 10:05 计划到 10:28 HUNG 相差 23 分钟。10:05 这一节不在上传的 journal 里。不为缺节新写一条规则，也不把 `HEAL_LATE` 回填进 10/06。

### 末小时

15:04→15:17 = 13 分钟，15:36→15:49 = 13 分钟。后一跳都在 15:05 之后，门是 `10m_lasthour`。13>10，13≤20，OVER_DOOR，不是 `HEAL_LATE`。journal 的 `ROUTINE_GAP_LAST_HOUR` 与这个门一致。不把 10 分钟改短。

14:44→14:59 = 15 分钟。后一跳 14:59 仍在 15:05 之前，生效门是 25 分钟。15≤25，GAP_OK。六段把这段和上面两段一起写成「超 10 分钟门」。15:05 这条界不前移。不新编号。

11:54→12:16 = 22 分钟，后一跳已过 11:30，门是 25 分钟。22≤25，GAP_OK。12:01 / 12:11 槽未见，间隔仍在中盘门内。不把中盘门改成 10 分钟。

### Δ40 已经写过，10/06 的火钟仍是旧时刻

四个实际点火对得上旧计划，对不上 Δ40 的新时刻：

| 作业 | Δ40 计划 | 10/06 实际 | 相对旧计划 |
|---|---|---|---|
| 预热 | 09:12 | 09:42（`2026-10-06T13:42Z`） | 旧 09:28，滞后 14 分钟 |
| 独立 | 09:14 | 09:38（`fired_at=2026-10-06T13:38:26Z`） | 旧 09:30，滞后 8 分钟 |
| oneshot | 09:15 | 09:40（`2026-10-06T13:40:26Z`） | 旧 09:31，滞后 9 分钟 |
| 补门 | 09:19 | 09:49（`2026-10-06T13:49:02Z`） | 旧 09:35，滞后 14 分钟 |

内容 DONE 09:39（`iso=2026-10-06T09:39:38-0400`）。iso 不是 spawn。spawn 用 09:38。合格线仍是 spawn≤09:35 且内容 DONE≤09:35。今天两者都在线外。

oneshot 行写了 `fired=0931`，实际 09:40。Δ33 / Δ40 已禁止这个令牌。应写 `OPEN_AUDIT_ONESHOT_LATE | planned=0931 | actual=09:40`。不新编号。

上传的 10/07 reserve 仍是 `fire_at=09:31`、`independent_planned=0930`、`planned_window=0930-0935`，并把 `prior_actual=09:38` 放在 oneshot 字段里。09:38 是独立 spawn，oneshot 的实际是 09:40。不新编号。父级要改的时刻抄在粘贴块末尾。本复盘没有改例程的工具。

`CRON_STILL_LATE_5D` 这枚标签的括号里列出的是四条钟：10/01 09:40、10/02 09:39、10/05 09:41、10/06 09:38。不补第五天的钟点。

### Δ8 在 11:36 已经近 t1

R = 3.20，0.25R = 0.80。11:36 的检查写了 11:25 这根 5 分钟高 160.15。160.70−160.15 = 0.55 ≤ 0.80。止损 155.40 仍宽于成本 158.60。Δ8 的中文条要求这一跳抬到 COST。这一跳没有抬。英文粘贴 `stop > COST` 对多头初值止损字面为假。10/05 已写明冲突时用中文「宽于 COST」。不另开一条去改 Δ8 的触发集合。

11:44 t1 已经打印并按写下的 160.70 全平。这次没抬，没有改到已入账的 +$42.00。不回抬。

MFE = 44.00/64.00 = 0.6875R。0.75R 的价格是 158.60+2.40 = 161.00。持仓高 160.80 低于 161.00。10/05 那条未签字的 MFE≥0.75R 提案在这笔出场之前也不会触发。提案继续不生效。不把 0.6875R 写成已经达到 0.75R。

### 一并看到、同样不新开

- Δ41。全日纸面各跳都是 `wake_parent_needed=false`。出声名单仍是 `HUNG_TOUCH`、`GAP_STOP`、`BLOCKED`、`EXIT_BLOCKED`。t1 打印不在这份名单里。不把纸面 t1 出场加进名单，也不从名单里删。10/06 的 false 保持。
- Δ17。收盘 HUNG 空。无 HUNG_TOUCH。无 EXPIRE / REWRITE。
- Δ37。10/06 有完整来回 1 笔，qualified +$42.00，不是空仓日。10/07 不触发 Δ37。第一天空仓仍只写 Δ32。
- 周数字。W/C 10/05 的 raw/qual = 13.64+42.00 = 55.64 / 0+42.00 = 42.00，与 10/05 和 10/06 两行 ledger 一致。周目标仍 OPEN。出场是 t1，不写 `reason=early_exit`。不扩大 reason 枚举。不把 248.80 写进这一周。
- Sleeve A。AAPL 未进 +1R，未进权利金 t1 的 0.25R。CRWD 已在 COST。10/07 距 10/16 是 9 个日历日，Δ9 的 ≤7 不触发。六段的「8 个交易日」不是这条的单位。不在本 delta 写平仓指令。
- Mac。盘中队列。EOD 推送时掉线。六段写 Mac 上的 agentic-daily 仍停在 09/30。box 不是 Desktop 已更新。
- 真钱。附件全程 $3,064.83，仓空，当日已实现 $0。本复盘未调用券商。

## 粘贴块

```
# DELTA 2026-10-06 — append after the 2026-10-05 Δ41 paste.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ41.
# Paper 7474 only. No place_*. Do not touch account 1429.
# A sentence that changes Frank's target or the exit set is PROPOSAL · 未签字 · 不生效.

Δ42 FLOOR_PATH_FIELD_BLOCKS_FILL (tightens Δ38; a HUNG file with no FLOOR_PATH= line is not fillable later)
Scope: the wake that writes a TRAIN3000 HUNG, and any later wake that still sees that id as HUNG.
  Sleeve A is out of scope. Do not rewrite an already-OPEN leg.
IF this wake writes that HUNG
THEN the state file contains a line with the literal field FLOOR_PATH=
  which branch, and how reachable is computed, stay on Δ38
IF t1_dollars>=100 AND that line is not FLOOR_PATH=T1 | t1_dollars={ }
THEN that id is not a qualified HUNG
IF t1_dollars<100 AND that line is not Δ38 branch (1) or branch (2)
THEN FLOOR_PATH_MISSING | {id}
  that id is not a qualified HUNG
IF branch (2) says reachable=NO
THEN Δ38's FLOOR_PATH_UNREACHABLE still applies
IF the id is FLOOR_PATH_MISSING or FLOOR_PATH_UNREACHABLE
THEN the id is not fillable
  a later trigger does not FILL and is not late-booked
  FLOOR_PATH_NOFILL | {id}
  do not sleep
  do not flip SIZE_MODE to MULTI_ROUND
  do not cut the first qty
The sentence "needs t2 or multi-round" is still not branch (2)
A completed Δ38 line that is legal and reachable=YES stays a qualified HUNG
  this delta does not change that definition
  this delta does not change the Δ23 exit set or the Δ24 HIT test
2026-10-06 VST-PB-RECLAIM-1006 had no FLOOR_PATH= line
  t1_dollars=(160.70-158.60)*20=42.00
  t2_dollars=(162.50-158.60)*20=78.00
  printed 151.44-160.70 range=9.26 t2_minus_hi=1.80 atr=UNAVAILABLE
  1.80<=9.26 but 78.00<100 so a written branch (2) would have been reachable=NO
  ONE_FULL_LEG residual cash 80.57, so branch (1) does not exist
  Do not write the line back into the 2026-10-06 HUNG file
  Do not unfill 20 @ 158.60
  Do not reprice 160.70 / +42.00 / qualified / cash 3294.57
Do not: widen the structure gate or add shares to push t1 dollars over 100
Do not: divide 3000 by 2 or by 3
Do not: auto-write NO_OVERNIGHT
Do not: rehang VKTX or SPY-PUT-ORL-PB-0928
Do not: reopen the CCL structure
Do not: rehang the VST structure to repair this line
Do not: place_*

PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=FLOOR_STRUCTURE_CHOICE | needs=Frank
  Notional on the 2026-10-06 ticket was 158.60*20=3172.00
  100/3172=3.1526 percent
  On 20 shares, t1_dollars reaches 100 only at 158.60+5.00=163.60
  Today's t1 160.70 and t2 162.50 are both under 163.60
  This arithmetic is not a new target and not a new order
  Option A: qualify a HUNG only when t1_dollars>=100 AND the printed-range test passes for t1
    That removes T2_ONLY as a qualifying path. It changes Δ38. Unsigned: do not execute.
  Option B: MULTI_ROUND already written before the fill, with per_leg_cap, residual cash still >= per_leg_cap
    Round 2 is a later HUNG and still needs the full gate
    Do not flip ONE_FULL_LEG. Do not cut qty. Do not divide 3000 by 2 or by 3.
    Unsigned: do not execute.
  Until one option is signed, Δ38 and Δ42 stand.
  Do not apply either option to the booked 2026-10-06 VST.

Δ43 T1_MODE_AT_HUNG (the HUNG names exactly one t1 handling; the default stays unsigned)
Scope: the wake that writes a TRAIN3000 HUNG. Sleeve A is out of scope.
  Do not rewrite an already-OPEN leg.
IF this wake writes that HUNG
THEN the same line, before sleep, contains exactly one of:
  T1=EXIT_ALL
  T1=SL2COST_RIDE_T2
IF neither token is present, or both are present
THEN T1_MODE_MISSING | {id}
  that id is not a qualified HUNG and is not fillable
  a later trigger does not FILL and is not late-booked
  do not sleep
  do not auto-write either token
  the prose "SL→COST at t1" is not a token
IF the token is T1=EXIT_ALL
THEN the exit stays inside Δ23: first t1 print flats the leg at the written t1
IF the token is T1=SL2COST_RIDE_T2
THEN PROPOSAL_NOT_IN_FORCE | id=T1_DEFAULT_MODE
  that id is not fillable until Frank and the CEO sign
  do not hold it to t2 under this delta
2026-10-06 wrote the prose and booked T1_EXIT at 160.70, +42.00 qualified
  A ride to the written t2 is (162.50-158.60)*20=78.00, still under 100
  The six-section day high 162.69 is only in that file
  (162.69-158.60)*20=81.80, still under 100, and it is not a booked price
  Do not reprice 160.70 / +42.00 / cash 3294.57
Ledger already contains both shapes. KOD-0928 booked T1_EXIT at written t1 81.0.
  QQQ 2026-09-11 booked t1 then stop→BE then t2.
  This pack has no original ticket for either. Do not infer a token from the row.
Do not: change the Δ23 exit set or the Δ24 HIT test
Do not: half-out
Do not: execute the unsigned MFE>=0.75R proposal
Do not: place_*

PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=T1_DEFAULT_MODE | needs=Frank_and_CEO
  Choice A: default T1=EXIT_ALL. First t1 print flats at the written t1. This is Δ23.
  Choice B: default T1=SL2COST_RIDE_T2. At t1 raise the stop to COST and hold for the cost stop, the written t2, or a written invalidation.
    The 2026-10-06 handoff states this as the Frank 9/17 preference.
    Choice B adds a t2 print to the exit set.
  Until one choice is signed: do not auto-write a token; do not execute B; a HUNG that writes B is not fillable; a HUNG that writes A exits under Δ23; a HUNG that writes neither token is T1_MODE_MISSING and is not fillable.
  Do not apply B to the booked 2026-10-06 VST.
  Unsigned: do not execute.

Δ44 BOOK_TRIPLE_JOURNAL_STICKS (tightens Δ39; a missing journal section sticks, and the HUNG write has a journal section)
Scope: a TRAIN3000 FILL, a TRAIN3000 EXIT, and the wake that writes a TRAIN3000 HUNG.
  Sleeve A GAP_STOP stays on Δ7/Δ12.
IF this wake books a FILL or an EXIT
THEN Δ39's three places still agree before sleep
  the journal section contains the id, the qty, and the price
  an exit section also contains pnl
  a later section that states only cash and the day total does not clear the journal place
IF a later wake finds the ledger and the state file already agree
  AND no journal section contains that id and that price
THEN BOOK_TRIPLE_MISS | {id} | missing=journal
  do not sleep
  before sleep, append a journal section that quotes the id, qty, price, and pnl already agreed by the ledger and the state file
  do not use a later mark
  if the ledger and the state file disagree, do not pick a price and do not sleep
IF this wake writes a TRAIN3000 HUNG
THEN this same wake's state/journal.md has a section with that id and entry, stop, t1, t2
IF the HUNG exists only in the state file
THEN JOURNAL_HUNG_MISS | {id}
  do not sleep
  a later check line does not each need its own section; the write wake owed the section
manchang, paper-capital.md, and train3000-hunt.md do not clear the journal place
2026-10-06 11:44 has the exit in the ledger, the HUNG file, and the 11:44 manchang
  journal.md has no 11:44 section
  the 11:54 section states cash 3294.57 and 42.00/42.00 and does not state the id or 160.70
  The 11:05 FILL is in the journal, the ledger, and the state file. Do not reprice that fill.
  10:28, 10:38, and 10:47 are in the HUNG file and not in journal.md
  Do not backfill the 2026-10-06 journal in this review
  Do not reprice 20 @ 158.60 → 160.70 / +42.00 / cash 3294.57
  Do not use 162.50 or the six-section 162.69 to fill the journal
Do not: replace the journal line with an EOD reprice
Do not: invent a fill
Do not: place_*

Δ45 SCAN_TABLE_ON_HUNT_FAIL (if the 09:31 hunt produced no scan table, the 10:00 review writes it)
IF it is an RTH day AND at 10:00:00 ET there is no scan table for that date
  (a candidate count, plus a reject reason for each name not hung)
THEN the 10:00 review wake writes that table before sleep
  count of names named on that wake
  reject reason for each name not hung
  the hung id, if any, and the gate it passed
IF that wake writes only one plan and no count
THEN SCAN_TABLE_MISSING | asof={HHMM}
  do not treat the single plan as the table
  do not sleep
  do not invent a count
A failed routine run is not a zero-candidate day.
  Write 0 only when the table truly has zero rows.
2026-10-06: the 09:31 hunt failed. No scan table was written. The ~10:05 wake left one VST plan.
  The candidate count is unverifiable.
  Do not invent a count in the review or in the next morning brief.
Do not: lower the hard-catalyst, structure, or same-bar three-price gate to fill the table
Do not: hang a name already marked REJECT
Do not: rehang VKTX or SPY-PUT-ORL-PB-0928
Do not: reopen the CCL structure
Do not: place_*

NO extra delta for the 18m early gap, the missing 10:51 and 11:01 slots, or the 15m fill book.
  10:47→11:05 = 18m is before 11:30, so door=10m_early.
  18m is OVER_DOOR. 18m is not over door+10=20, so not HEAL_LATE.
  The journal tagged door25m_mid | GAP_OK. Δ18/Δ26 already require 10m_early.
  Do not change 10 minutes.
  The ~10:50 fill was booked at 11:05 at the limit 158.60. Do not reprice it.
  ~10:05 to ~10:28 is 23m and the 10:05 section is not in the uploaded journal.
  Do not write a rule for that missing section. Do not backfill HEAL_LATE.

NO extra delta for the last hour, and do not move 15:05.
  15:04→15:17 = 13m and 15:36→15:49 = 13m are 10m_lasthour OVER_DOOR, not HEAL_LATE.
  14:44→14:59 = 15m ends before 15:05, so the live door is 25m. 15<=25, so GAP_OK.
  The six-section grouped that 15m with the two 13m gaps under the 10m door.
  Do not shorten 10m. Do not move the 15:05 boundary earlier.
  11:54→12:16 = 22m is after 11:30, so 25m, and 22<=25 is GAP_OK.
  Do not change 11:30–15:05 from 25m to 10m.

NO extra delta for OPEN_AUDIT. Δ40 is already the schedule. The parent applies it.
  2026-10-06 actuals, old plan still in force:
    warmup planned old 09:28 actual 09:42 (2026-10-06T13:42Z) lag 14m
    independent planned old 09:30 actual 09:38 (fired_at 13:38:26Z) lag 8m
    oneshot planned old 09:31 actual 09:40 (13:40:26Z) lag 9m
    rewake planned old 09:35 actual 09:49 (13:49:02Z) lag 14m
    content DONE 09:39 (iso 09:39:38-0400)
    iso is not the spawn. Spawn is 09:38. Content is 09:39.
  Pass test unchanged: independent spawn <=09:35:00 AND content DONE or BLOCKED <=09:35:00
  The oneshot line wrote fired=0931 with actual 09:40. That token stays forbidden (Δ33/Δ40).
  Write OPEN_AUDIT_ONESHOT_LATE | planned=0931 | actual=09:40
  Do not write fired=0931. Do not write CRON_REBUILD_VERIFY status=CLEAR.
  Do not add a fifth fire. Do not widen 09:30–09:35.
  CRON_STILL_LATE_5D lists four clocks: 10/01 09:40, 10/02 09:39, 10/05 09:41, 10/06 09:38.
  Do not invent a fifth clock.
  Parent cron, CRON_TZ=America/New_York, weekdays:
    warmup  12 9 * * 1-5
    independent  14 9 * * 1-5
    oneshot  15 9 * * 1-5
    rewake  19 9 * * 1-5
  2026-10-07 reserve, written before 09:28, replaces the uploaded draft that still says fire_at=09:31:
    fire_at=09:15
    cron_oneshot=ARMED
    cron_align=REQUIRED
    last_independent_actual=09:38
    oneshot prior_actual=09:40
    warmup actual=09:42
    rewake actual=09:49
    content DONE=09:39
    failed_door=0928_warmup,0930_independent,0931_oneshot,0935_rewake
  09:38 is the independent spawn. Do not put 09:38 in the oneshot prior_actual field.
  IF the scheduler is still on the old minutes at the open
  THEN a late spawn is still LATE
  Do not mark the window clear because the plan was not edited.
  IF a shifted job wakes before 09:30:00 ET
  THEN do not write OPEN_AUDIT_DONE from premarket prices
    hold in that wake until the first RTH open print, then MIN_OPEN_AUDIT

NO extra delta for Δ8, the unsigned 0.75R proposal, Δ41, Δ17, Δ37, the week line, Sleeve A, or Mac.
  At 11:36 the 11:25 bar high 160.15 was 0.55 from t1 160.70. 0.25R=0.80.
  Stop 155.40 was still wider than cost 158.60. That wake owed SL→COST. It did not raise.
  That is LATE_SL_COST. Do not renumber it. The Chinese "wider than COST" wins over the English stop>COST.
  Do not reprice the booked 160.70 / +42.00.
  MFE=44.00/64.00=0.6875R. The 0.75R price is 161.00. Post-fill high 160.80 is under 161.00.
  The unsigned MFE>=0.75R proposal would not have fired before this exit. Do not execute it.
  Paper t1 exit stayed wake_parent_needed=false. Do not add t1 to the Δ41 page list. Do not remove HUNG_TOUCH.
  EOD HUNG empty. No Δ17 expire.
  2026-10-06 had one complete round. Δ37 does not fire on 2026-10-07.
  Week W/C 10/05 is raw 55.64 / qualified 42.00 and stays OPEN.
  Do not write reason=early_exit on a t1 exit. Do not widen the reason enum. Do not write 248.80 into this week.
  AAPL was not at +1R or within 0.25R of the premium t1. CRWD is already COST.
  2026-10-07 is 9 calendar days before 2026-10-16. Δ9's <=7 does not fire. Do not add an exit sentence.
  The six-section's "8 trading days" is not the Δ9 unit.
  Mac dropped during the EOD push. Box copy is not a Desktop update.
```
