# APPEND ONLY — Cursor postmortem 2026-10-01

粘贴位置：现有 `PROCESS-PATCHES` 末尾，Δ36 之后。  
不替换 Patch 1–6。不替换 Δ7–Δ36。不放宽任何旧门。冲突时更严者生效。

纸面 ••••7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

## 结论

三个候选都核对过。**没有需要新收紧的规则。** 再写 Δ37 只会把「没执行」收成另一条同义门。

| 候选 | 判定 |
|---|---|
| (a) 10:30 若 HUNG=0 且现金够满腿，则挂一条 `NO_OVERNIGHT` 短周期，或写 `DAY_GOAL_MISS_ACCEPT` | **不加。** 「必须挂」会放宽 Δ32 / Δ23 / Δ36：没过硬催化+结构+同棒三价的名字不得为了空仓日成交。`DAY_GOAL_MISS_ACCEPT` 仍只用于 Δ36（prefer 窗内刚平仓、现金重聚的下一跳）。今日开盘已是 FLAT，Δ36 不触发。10:30 第一跳（~10:36）欠的是已有 `EMPTY_DAY_CLOCK`；11:30 第一跳（~11:38）欠的是已有 `TRAIN_EMPTY_DAY`。照写，不新编号 |
| (b) spawn、内容、独立确认都 ≤09:35 | **不加。** 内容 09:37 = Δ14 / Δ35 未在 ≤09:35:00 先落 DONE/BLOCKED 行（与 9/30 同分钟）。spawn≈09:35 只记 `SPAWN_EDGE`，不是过窗。独立例程 09:40 = Δ27。oneshot 确认 09:37:43 不是 `fired=0931`（Δ33）。文件里的 `independent_confirm=09:37` 不覆盖正文 09:40。不加第五个火钟，不放宽 09:30–09:35 |
| (c) early 门 ≤10m；09:23→09:44 ≈21m OVER_DOOR | **不加。** 门保持 10m。21m 的 OVER_DOOR 是对的；同一跳应另写 `HEAL_LATE`（21>20，Δ26），journal 写了不要当成 HEAL_LATE。11:30 前若干 12–19m 被记成 25m mid，15:10 的 15m 也被记成 mid。都是 Δ18 / Δ20 / Δ26 / Δ28 的当跳门，不缩短 10m，不把 25m 改成 10m |

一并维持、不编号：周 raw 下一行写 `142.12+106.68=248.80`，并注明附件 247.53、差额 1.27、ledger 无第三笔。禁止改 KOD / CCL 已记账价格。Δ24 的 `WEEK_GOAL` 管道行照写。Mac 在 ~11:43–~12:54 有 SYNC，不是全日 offline。

## 粘贴块

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
```
