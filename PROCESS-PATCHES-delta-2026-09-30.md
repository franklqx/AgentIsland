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
