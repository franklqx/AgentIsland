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

```
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
