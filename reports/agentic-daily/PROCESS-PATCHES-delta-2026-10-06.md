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
