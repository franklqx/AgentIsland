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
