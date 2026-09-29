# DELTA 2026-09-29 — append after Δ33.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ33.
# Paper 7474 only. No place_*. Do not touch account 1429.

只新增一条。另外两个候选核对后**不新编号**。

| 候选 | 判定 |
|---|---|
| (a) 9/28–9/29 独立 OPEN_AUDIT 仍 LATE，Δ33 rebuild-verify 没进窗，cron ~09:42 | **不加。** Δ22 / Δ27 / Δ29 / Δ33 已规定四门、`ONESHOT_LATE`、`failed_door`、`today_actual` 与 `prior_session_actual`。9/29 是这些字段没写全，时钟仍晚。不加第五个开火分钟，不放宽 09:30–09:35 |
| (b) 早盘 10m 被 ~17–20m 打破，带触落在空档，`HUNG_TOUCH_LATE` | **不加。** 这两段的门标签符合 Δ26（>10m 不是 gap-OK；≤ door+10 不是 `HEAL_LATE`）。成交价是带中价 24.575，符合 Δ7。09:44 漏记账是 Δ7 没执行。10:21 / 10:41 / 11:08 误用 25m 门是 Δ26 没执行。不缩短 10m |
| (c) TRAIN 财报 / VWAP-PB 在 HUNG 时必须声明过夜还是不过夜 | **加 Δ34。** Δ23 把「票上没有时间失效句」收成可以过夜。Δ30 只在已经写了 no-overnight 时生效。CCL 两句都没写，沉默就过夜。下一次 HUNG 必须选 |

## Δ34. OVERNIGHT_CLAUSE_AT_HUNG（HUNG 当时写明过夜或不过夜；不改 Δ23 的出场集合）

9/29 ~09:37 `HUNG CCL-PB-VWAP-0929`：Q3 财报硬催化，VWAP-PB，带 24.50–24.65，stop 23.90，t1 25.50，t2 26.20，qty 127，`SIZE_MODE=ONE_FULL_LEG`。同一行没有 `NO_OVERNIGHT`，也没有 `OVERNIGHT_OK_UNTIL_STOP` / `OVERNIGHT_OK_UNTIL_T1`。带在 09:38–09:52 进入，~09:57 按带中价 24.575 成交。stop / t1 全日未打印。EOD last~25.14，uPnL~+$71.76。按 Δ23 过夜 HOLD。日 qualified $0，`DAY_GOAL OPEN`。周 HIT 仍是周一 KOD $142.12。

Δ31 已经要求填单前写 `SIZE_MODE`，因为「多轮」和「满名义」不能靠沉默同时成立。这里是同一结构：「短周期回合」和「带到 stop/t1 才能走」也不能靠沉默同时成立。不默认过夜，不默认当日砍。

- 适用范围：TRAIN3000 的 HUNG，且该票是财报硬催化或 VWAP-PB（含两者都是，9/29 CCL 即此类）。Sleeve A 不适用。已有 OPEN 腿不回头补句。
- IF 该跳写下这张 HUNG THEN 同一行、sleep 之前恰好有一句：`NO_OVERNIGHT`，或 `OVERNIGHT_OK_UNTIL_STOP`，或 `OVERNIGHT_OK_UNTIL_T1`。
- IF sleep 时这句仍缺 THEN 这张 id 不是可成交 HUNG。写 `OVERNIGHT_CLAUSE_MISSING | {id}`。之后的带触不成交、不补记 FILL。禁止自动填上 `NO_OVERNIGHT`。禁止自动填上 `OVERNIGHT_OK_UNTIL_*`。
- IF 句是 `NO_OVERNIGHT` THEN 成交之后只使用已有的 Δ30（15:40 / 15:50 预留，`qualified=0`）。不提前到 15:40 之前。
- IF 句是 `OVERNIGHT_OK_UNTIL_STOP` 或 `OVERNIGHT_OK_UNTIL_T1` THEN 这句只表示过夜被允许。出场仍只是 Δ23 已有的三条：止损已打印；t1 已打印且票上写明减仓或平仓；书面结构失效已打印。`UNTIL_STOP` 不删除已写的 t1。`UNTIL_T1` 不删除已写的止损。prefer 闭窗、RTH 收盘、日 +$100、凑回合，都仍然不是出场。
- 2026-09-29 的 CCL 已经 OPEN。禁止把 Δ34 的句子补进这张票。禁止因此平仓。禁止改 127、24.575、23.90、25.50、26.20、last~25.14、uPnL~+$71.76、现金 $11.22。
- **Do not:** 把 Δ23 的合法出场收窄或加宽。**Do not:** 对 Sleeve A 使用本条。**Do not:** 用本条把已过夜的 CCL 在下一 RTH 开盘砍掉。**Do not:** 改 10m 或 25m 门。**Do not:** 放宽 09:30–09:35。**Do not:** `place_*`。**Do not:** 碰 ••••1429。

## 候选 (a)(b) 保持原条

```
NO extra delta for OPEN_AUDIT.
  2026-09-29 independent spawn actual=09:42, confirm=09:44, content DONE=09:44 LATE.
  oneshot actual=09:45 MIN_SKIP because DONE already existed. 0935 rewake actual=09:48 already_DONE.
  prior independent spawn=09:52 (2026-09-28). 2026-09-25 remains the single ON_TIME (09:34 / 09:35).
  CRON_STILL_LATE separated 09:42 from 09:52. CRON_REBUILD_DUE did not:
    bare prior_actual=09:42 is not the Δ33 field line.
  Missing on that line: failed_door=0930_independent,0931_oneshot | today_actual=09:42 | prior_session_actual=09:52.
  Missing tag: OPEN_AUDIT_ONESHOT_LATE | planned=0931 | actual=09:45 | failed_door=0931_oneshot.
  Do not write fired=0931. Do not redo DONE.
  2026-09-30 reserve already has cron_oneshot=ARMED | fire_at=09:31 | prior_actual=09:42.
  Before 09:28 ET on 2026-09-30 add, under Δ33, not under a new number:
    failed_door=0930_independent,0931_oneshot
    cron_rebuild_verify=ARMED
  prior_actual stays 09:42 (today's spawn), not confirm 09:44, not 09:52.
  An in-window 2026-09-30 is HOLD, not CLEAR.
  Do not add a fifth fire minute. Do not widen 09:30–09:35.

NO extra delta for HUNG_TOUCH_LATE or the early door.
  09:17→09:37 ≈17–20m and 09:37→09:57 ≈20m are ROUTINE_GAP_EARLY | door=10m_early.
  Both are over 10m, so not gap OK. Neither is over door+10, so not HEAL_LATE.
  09:38 close 24.55 and 09:51 close 24.61 printed inside 24.50–24.65.
  The 09:44 OPEN_AUDIT wake did not book the fill. Δ7 already requires same-wake booking.
  09:57 FILL ×127 @24.575 mid-band stands. Do not reprice to last~24.77.
  09:57→10:21 ≈24m, 10:21→10:41 ≈20m, 10:41→11:08 ≈27m were tagged door=25m_mid while the clock was still before 11:30.
  Δ26 already requires door=10m_early until 11:30. 24m and 27m also require HEAL_LATE. 20m does not.
  Do not shorten the 10m early door. Do not change 11:30–15:05 from 25m to 10m.
```

## 粘贴块（Agentic 例程）

```
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
```
