# APPEND ONLY — Cursor postmortem 2026-10-02

粘贴位置：现有 `PROCESS-PATCHES` 末尾，2026-10-01「NO Δ37」块之后。  
不替换 Patch 1–6。不替换 Δ7–Δ36。不放宽任何旧门。冲突时更严者生效。

纸面 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

## 结论

四个候选里只收紧一条。

| 候选 | 判定 |
|---|---|
| (a) 连续第二日空仓，10:30 仍 HUNG=0 | **加 Δ37。** Δ32 只要求写 CLOCK / TRAIN_EMPTY_DAY，并禁止为「不要第二天空仓」去挂已 REJECT 的名字。Δ36 的 `DAY_GOAL_MISS_ACCEPT` 只在当日刚平完仓时触发。本日开盘就是 FLAT，两条一起允许从 10:33 静默漂到 11:30。新条只强制决定行。挂单分支仍要未改的结构门 |
| (b) OPEN_AUDIT 内容 09:37、独立 09:39/09:40、CRON_REBUILD_DUE | **不加。** Δ29 已要求 09:31 当分钟 `MIN_OPEN_AUDIT`。09:31 满仓盯写了 PENDING。Δ33 已要求 `OPEN_AUDIT_ONESHOT_LATE \| actual=09:37`。Δ27 已要求独立 spawn 09:39 = LATE。再写一个「重建」标签不会把作业提前 |
| (c) TRAIN_EMPTY_DAY 欠 ~11:40、写于 ~12:09 | **不加。** Δ32 已把这行绑在 11:30 之后第一跳。10/1 复盘写过同一句。晚写是没执行 |
| (d) 早盘 09:31→09:48 = 17m | **不加。** 门已经是 10 分钟。17m 是 OVER_DOOR，不是 HEAL_LATE。不缩短 10m |

## Δ37. SECOND_EMPTY_DAY_HANG_OR_ACCEPT（上一 RTH 已空仓时，10:30 那一跳必须留下决定；不改结构门）

2026-10-01 开盘 FLAT，raw/qual $0/$0，EOD 才把 DAY_GOAL 收成 MISS，当日复盘明确不加大 10:30 强挂，`DAY_GOAL_MISS_ACCEPT` 留在 Δ36 里。2026-10-02 是连续第二日：现金 $3,238.93，SIZE_MODE=ONE_FULL_LEG，OPEN0/HUNG0 全日。~10:33 写了 `EMPTY_DAY_CLOCK | asof=1030 | primary=NKE | primary_state=NO_RECLAIM | alt_scan=REQUIRED`，之后每跳 `NO_NEW_HUNG`。合格结构没出现，拒绝追价是对的。错在 10:30 那一跳可以不留下「门没过，所以接受本日 MISS」的行。

- 适用范围：TRAIN3000；上一已结束 RTH 的 TRAIN3000 是 qualified 已实现 0、完整 round 0、且 DAY_GOAL MISS（日志里的 `TRAIN_EMPTY_DAY` 行可以迟到；2026-10-01 就是欠到 EOD 才把 DAY_GOAL 收成 MISS，本包没有 10/1 原文，不把那一行说成已经按时写过）；本跳是 10:30 ET 及之后的第一跳；OPEN=0；HUNG=0；现金够开一腿有意义的名义；prefer 窗 09:30–11:30 尚未结束。Sleeve A 不适用。11:30 之后本条沉默，沿用 Δ24 / Δ32。已有 HUNG 或已有 OPEN 时本条沉默。
- 上一 RTH 不是上述空仓收场时，本条不触发。第一天空仓日仍只写 Δ32 的 `EMPTY_DAY_CLOCK`，不强制 10:30 接受行。这保留 2026-10-01 的「不加 10:30 强挂」。
- IF 本条触发 THEN 本跳先照 Δ32 写 `EMPTY_DAY_CLOCK` 并做 alt_scan。sleep 前再写且只写下面两支之一：
  1. 一条 HUNG。该名在本跳已经打出硬催化、结构、以及同棒 entry/stop/t1。HUNG 行里已经有手写的恰好一个 Δ34 条款（`NO_OVERNIGHT` 或 `OVERNIGHT_OK_UNTIL_STOP` 或 `OVERNIGHT_OK_UNTIL_T1`）。短周期由写票的人写入 `NO_OVERNIGHT`。本条不自动补条款。缺条款则该 id 仍不可成交（Δ34）。
  2. `DAY_GOAL_MISS_ACCEPT | candidates={整数} | rejects={原因:计数,...} | raw={ } | qual={ } | asof={HHMM} | prior_empty_date={YYYY-MM-DD}`。`candidates` 是本跳点过名的个数，不用「约」或「≥」。`prior_empty_date` 是上一空仓 RTH 的日期。
- IF 本跳结束时只有 `NO_NEW_HUNG`，(1) 与 (2) 都没有 THEN 写 `EMPTY_DAY_SILENT_DRIFT | asof={HHMM}`，不得 sleep。
- 已在本跳或更早跳被标成 REJECT 的名字不能用来满足 (1)。`REJECT_NO_CHASE`、`NO_RECLAIM`、`REJECT_EXTENDED`、`REJECT_STRUCTURE`、`REJECT_NO_HARD_CATALYST`、`REJECT_NO_REOPEN` 都是已 REJECT。
- `DAY_GOAL_MISS_ACCEPT` 只记录「原门没过，所以本日 qualified 目标未完成」。它不把 Δ24 的 MISS 改成 HIT，不是 `ACCEPT_TRAIN_EMPTY`，不清除 `TRAIN_EMPTY_DAY` 或 `TRAINING_FAILURE`，不制造 round，不授权未过门的名字成交。之后的 prefer 跳若有名字新打出全部门，仍可按 Δ31/Δ34 写 HUNG。这一行不锁死余下的 prefer 窗。
- Δ32 的 11:30 行照旧：第一跳 ≥11:30 且 OPEN=0 且 HUNG=0 且当日 CLOSED=0，当跳写 `TRAIN_EMPTY_DAY`。本条不取代那一行。
- 2026-10-02 ~10:33 是本条的实例（`prior_empty_date=2026-10-01`）。该跳只写了 CLOCK 和 NO_NEW_HUNG。禁止把 `DAY_GOAL_MISS_ACCEPT` 补写进 10/2 journal。禁止为补这一行给 NKE 或该跳点过的任何名字编 fill。
- **Do not:** 把「必须挂一条短周期」读成可以挂已 REJECT 的名字。**Do not:** 为了满足 (1) 降低 RVOL、VWAP reclaim 或同棒三价。**Do not:** 自动写 `NO_OVERNIGHT`。**Do not:** 用本条在第一天空仓日强制接受行。**Do not:** 改 Δ23 的出场集合。**Do not:** 改 Δ24 的 HIT 条件。**Do not:** 把 $3,000 除以 2 或 3。**Do not:** 回挂 VKTX 或 SPY-PUT-ORL-PB-0928。**Do not:** 重开 CCL 的同一结构。**Do not:** `place_*`。

## 不新开

### (b) OPEN_AUDIT

事实（只取附件）：

- 内容 DONE ~09:37，source=`OPEN_AUDIT_0931` oneshot，`actual_spawn≈09:37`。晚于 09:35 → `OPEN_AUDIT_LATE`。
- 独立 actual spawn 09:39，confirm 09:40:58 → `OPEN_AUDIT_INDEPENDENT_LATE` · `CRON_STILL_LATE`。
- 09:31 满仓盯：`OPEN_AUDIT=PENDING`，写明本 wake 不假 DONE。open-audit 记了 `OPEN_AUDIT_DEFER_FORBIDDEN`：当时 `cron_oneshot=ARMED`，独立 spawn 仍缺。
- 内容与 oneshot spawn 在同一分钟。不是 Δ35 那种「窗内 spawn、长文把 DONE 拖过 09:35」。
- 附件没有 `OPEN_AUDIT_ONESHOT_LATE | planned=0931 | actual=09:37 | failed_door=0931_oneshot` 这一行。source 名 `OPEN_AUDIT_0931_oneshot` 不是 `fired=0931`。
- `GAP_STOP=NONE`。`held=AAPL,CRWD`。`unaudited=NONE`。

判定：失败的门是 0931_oneshot（实际 09:37）和 0930_independent（实际 09:39）。Δ29、Δ33、Δ27 已经规定这两扇门各自写什么。09:31 那一分钟没有跑已规定的 `MIN_OPEN_AUDIT`。再编号一次「三时钟都要 ≤09:35」或再加一个重建标签，不会产生更早的 spawn。不加第五个火钟。不放宽 09:30–09:35。不把 09:37 的 DONE 改记成 09:35。不写 `CRON_REBUILD_VERIFY | status=CLEAR`。

2026-10-06 09:28 reserve，只向前写：

- `cron_align=REQUIRED | last_independent_actual=09:39`
- `cron_oneshot=ARMED | fire_at=09:31 | prior_actual=09:37`
- `failed_door=0930_independent,0931_oneshot`
- spawn 分钟与 confirm 分钟分开。09:39 是独立 spawn，09:40 是 confirm。09:37 是 oneshot spawn。
- 09:31 独立 spawn 仍缺 → 当分钟 `MIN_OPEN_AUDIT`（Δ29）。actual>09:31 → `OPEN_AUDIT_ONESHOT_LATE`，禁止 `fired=0931`（Δ33）。

### (c) TRAIN_EMPTY_DAY 晚写

Δ32 已规定 11:30 及之后第一跳写入。2026-10-02 第一跳是 ~11:40。~11:40 与 ~11:58 只 REFRESH 了 `EMPTY_DAY_CLOCK`。~12:09 才写 `TRAIN_EMPTY_DAY | reason=NO_QUALIFIED_STRUCTURE | chase=FORBIDDEN`，并标 `TRAIN_EMPTY_DAY_LATE_WRITE`。DAY_GOAL 在 12:09 从 OPEN 改成 MISS。不把这句再编号。下一份若再晚，仍是这一个标签，不是新 Δ。

### (d) 早盘 17 分钟

09:31→09:48 ≈17m。门 = `10m_early`（Δ18）。17>10 → OVER_DOOR。17≤20 → 不是 HEAL_LATE。日志已经这样标了。缺的是破门时的 `MIN_SCAN_TABLE`，不是更短的门。

同一附件里、同样不编号：

- 10:00→10:23 ≈23m：OVER_DOOR + HEAL_LATE，标签对（23>20）。
- 10:33→10:52 ≈19m、10:52→11:04 ≈12m：OVER_DOOR，不是 HEAL_LATE。标签对。
- 11:04→11:16 ≈12m、11:16→11:28 ≈12m：写了 `door25m_mid | GAP_OK`。两跳都早于 11:30，应是 `door=10m_early | OVER_DOOR`，不是 HEAL_LATE。Δ26 已要求按生效门抄。不改 25m，不改 10m。
- 15:44→15:56 ≈12m：`door=10m_lasthour | OVER_DOOR`，不是 HEAL_LATE。不把末小时门改短。
- 15:44 的 prior 写成 ~15:35，附件 journal 在 15:13 与 15:44 之间没有 15:35 节。不为缺节写规则。

### 一并看到、同样不新开

- 周 raw。下一份 EOD 印 `142.12+106.68=248.80`，并注附件 247.53、差额 1.27、本周 ledger 无第三笔。禁止改 KOD 或 CCL 的价。禁止把 248.80 写入 Δ24 的当日 `raw_realized`。2026-10-02 当日管道是 `WEEK_GOAL | raw_realized=0 | qualified_realized=0 | target=100 | MISS | reason=no_setup`。周 HIT 的检验仍是 qualified 142.12。reason 枚举不扩大。
- 周五 `WEEKEND_SWEEP`。Δ20 已要求 15:45–15:50 的 `WEEKEND_SWEEP_DONE`。10/2 附件没有这一行。AAPL 未到 +1R，止损仍是 hard≤7.20 / 股 320，Δ8 不抬；(a) 为假。9/21 的 `WEEKEND_HOLD_OVERRIDE` 按 Δ21 不滚入本周末。CRWD 已 SL→COST；(a) 为真。到期 2026-10-16，距 10/2 为 14 个日历日，Δ9 的「≤7 日则 (b) 默认失败」不适用。不新编号。不在本 delta 写平仓指令。
- Δ17。EOD HUNG 空。无 HUNG_TOUCH。无 EXPIRE / REWRITE。
- Mac。全日 `MAC_MIRROR_QUEUE`，Franks-MacBook-Pro connected=false。EOD 从 box 副本交付。不把 box 路径写成 Desktop 已更新。Δ25 照旧。

## 粘贴块

```
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
```
