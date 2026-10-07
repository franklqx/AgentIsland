# TRAIN3000 日底线方案 · 2026-10-07 · 给 Frank 签字

**状态：PROPOSAL · 未签字 · 不生效。** 本稿不新增 Δ46，不改 Patch 1–6，不改 Δ7–Δ45，不改已入账盈亏，不调用 `place_*`，不碰 ••••1429，不动真钱 ••••7474。三份旧提案继续未签字：`FLOOR_STRUCTURE_CHOICE`、`T1_DEFAULT_MODE`、`NO_OVERNIGHT_MFE_075R_SL_COST`。

纸面 TRAIN3000。袖套约 $3,000。现金用 10/06 收盘入账 **$3,294.57**。日底线是 qualified realized **> +$100**。Prefer 窗 **9:30–11:30 ET**。默认当日收平（Δ34 `NO_OVERNIGHT`）。

签字行（填完即选；不填 = 明天沿用第五节）：

```
FRANK_PICK | date= | choice={A | B_SEQ | NONE} | ride={NO | ONLY_IF_T2_CLEARS} | floor_test={GT_100 | DELTA24_GE_100}
```

`ride=ONLY_IF_T2_CLEARS` 就是在 A 或 B 上加 C。C 单独做默认，本稿不推荐。

---

## 1. 一句话结论

**推荐顺序（仍是提案）：A → B 的顺序满腿两轮 → 不把 C 当默认。** 并发三腿在这笔现金上做不到。并发两腿不降低所需涨幅，被 A 盖过。

A 只挂「写下的 t1 本身 > $100，并且区间或 ATR 够得着」的满腿。B 的顺序两轮是唯一把单轮所需涨幅从约 3.15% 降到约 1.58% 的拆法，但要 Frank 书面放开 Δ31 的残额条件，并且两条硬催化都得在第一笔成交前写完。C（t1 抬到成本、持有到 t2）单独用：10/6 的 t2 只有 $78，照样不挂；10/5 那种 t2 路径 $137 会被放行，而那天 t2 没有打出来。

10/6 的形状（t1=$42，t2=$78，残额约 $80）在 **已经生效的 Δ42** 下就不能再成交。明天即使一张都不签，这种票也不得 FILL。签字改变的是下一类票：10/5 那种「t1 不够、t2 美元过线且当时算得成 reachable=YES」。

---

## 2. 算术

分母用买得动的名义，不用整笔现金。$3,294.57 在 158.60 上是 `floor(3294.57/158.60)=20` 股，名义 **$3,172.00**，残额 **$122.57**。10/06 当时现金是 $3,252.57，同一 20 股，残额 **$80.57**。下面「明天」用 $3,294.57；「10/6 演算」用当天的 $80.57。

正好 $100.00 不够。Frank 的句子是 **> $100**。20 股要过线，每股有利行程得大于 $5.00；下一分钱是 $5.01。

| 路径 | 股数 @158.60 | 名义 | 要合计 >$100 | 占入场价 | 和 micro 样本 $1,469.54 比 |
|---|---|---|---|---|---|
| 1 腿满仓 | 20 | $3,172 | 每股 >$5.00；下一分钱 $5.01 → 价 **163.61** → **$100.20** | **>3.1526%**（100/3172） | 过 |
| 2 腿并发 | 每腿 10 | 每腿 $1,586 | 每腿仍 >$5.00；两腿各 $5.01 → 合计 $100.20 | 每腿仍 **>3.15%** | 每腿 $1,586，只高出 $116 |
| 3 腿并发 | 每腿 6 | 每腿 $951.60 | 只部署 18 股，每股 >$5.56 | **>3.50%** | $951.60 低于 micro。袖套要 > 3×1469.54 = **$4,408.62** 才做得到。现在做不到 |
| 2 腿顺序，出场后现金回来再满腿 | 每轮 20 | 每轮 $3,172 | 每轮 >$2.50；下一分钱 $2.51 → 价 **161.11** → 每轮 $50.20，两轮 **$100.40** | 每轮 **>1.576%**（50/3172） | 每轮都是满腿 |
| 3 腿顺序 | 每轮 20 | 每轮 $3,172 | 每轮 >$1.67（>$33.34） | 每轮 >1.05% | 满腿。9:30–11:30 里要三次独立催化。本稿不作为推荐 |

公式：

- 一次部署（满腿，或并发）：所需涨幅 **> 100 / 本轮实际名义**。把 $3,172 切成两半，百分比不变。
- 顺序满腿、两轮都在 t1 落袋：每轮涨幅 **> 50 / 3172 = 1.576%**。百分比大约减半。任一腿没在写下的 t1 出场，这个减半就不成立。
- 若按现金 $3,294.57 整笔来除、先不管整股：100/3294.57 = **3.035%**，对应正好约 $100，仍不够。158.60 上只能买 20 股，部署名义回到 $3,172，正好 $100 的比例是 **3.1526%**，过线要高于它。

10/6 已入账票的同一道除法：100/3172 = **3.1526%**，20 股要 t1 路径到 $100 得每股 $5.00，价格 158.60+5.00 = **163.60**。当天写下的 t1 160.70 与 t2 162.50 都低于 163.60。这是已平仓票的算术，不是新目标。

近端满腿里，计划 t1 美元已经 >$100 的有：KOD t1 **$142.12**（4.84%，入账 HIT）、CCL 计划 t1 **$117.48**（3.76%）、IONQ 计划 t1 **$117.30**（4.00%）、OXY 计划 t1 **$100.98**（3.40%）。不够的是 10/5 t1 **$69.30**（2.19%）和 10/6 t1 **$42.00**（1.32%）。这是账本对照，不是胜率。

### 10/6 与 10/5 的固定数（下文三案都用这组，不改账）

**VST-PB-RECLAIM-1006（已平，禁止改价）：** 20 @158.60，stop 155.40，t1 160.70，t2 162.50。t1 路径 **$42.00**。t2 路径 **$78.00**。1R **$64.00**。名义 $3,172.00。当时现金 $3,252.57，计划残额 **$80.57**。`SIZE_MODE=ONE_FULL_LEG`。当时打印 high 160.70，low 151.44，区间 **9.26**，t2 高出当时高点 **1.80**，ATR 不可得。1.80≤9.26，但 78.00<100，所以当时若写 `T2_ONLY`，`reachable=NO`。`ROUND2` 在满腿上不存在。入账出场 160.70，**+$42.00 qualified**，现金 $3,294.57。六段日高 162.69 只在六段里，(162.69−158.60)×20 = $81.80，不是入账价。

**VST-PB-OPEN-RECLAIM-1005（已平，禁止改价）：** 22 @144.05，t1 147.20，t2 150.30。t1 路径 **$69.30**。t2 路径 **$137.50**。当时区间 4.88，t2 高出当时高点 4.52，4.52≤4.88，Δ38 下 `reachable=YES`。事后高点 146.90，t1/t2 都没打到，15:53 按 `NO_OVERNIGHT` 在 144.67 平，raw +$13.64，qualified 0。

---

## 3. 三个选项

三案共同保持：硬催化、结构、限价、止损、t1 都在挂单前写上；每张 HUNG 恰好一个 t1 令牌（Δ43）；默认 `NO_OVERNIGHT`；禁止把已挂或已成交的 `ONE_FULL_LEG` 改成 `MULTI_ROUND`；禁止为了多轮把股数改小（Δ31）；禁止用噪声腿凑美元；7474 纸面以外不写单。

### Option A — `T1_FLOOR_ONLY`

只挂 t1 美元本身过线、而且够得着的票。`T2_ONLY` 不再使一张 HUNG 合格。仓位模式仍是 `ONE_FULL_LEG`。

**10/6：不挂。** t1 美元 42.00。区间检验用不上。**10/5：不挂。** t1 美元 69.30，尽管 t2 路径 137.50 在当时算得成 reachable=YES。

猎单变化：先算 `qty=floor(cash/limit)` 和 `(t1−limit)×qty`。结构位自己的 t1 美元 ≤100，这只名字记 `FLOOR_TOO_NARROW`，换名字。10/6 的区间 9.26 够得到 $5，但写下的 t1 是当时高点 160.70，不是 163.61 上的结构位。A 拒绝这条结构。禁止把 t1 从结构位上移去凑 $100。

拒绝率：近端六笔满腿计划里，四笔的 t1 美元已经过线（KOD、CCL、IONQ、OXY），两笔不够（10/5、10/6）。A 每天仍是 0 或 1 张合格挂单。没有 3% 以上结构的日子是 `NO_SETUP`，不是去填一笔 $42。

失败面：t1 过线的日子变少。10/5 这种「t2 纸面过线、当天没打到」的挂单会被提前拿走。把 t1 写成一个没有结构的远价，是不合格票，清单第一条就挡。

不动的：`SIZE_MODE`、Δ23 的出场集合、Δ24 的 HIT 行、Δ31、已入账的 +$42.00 / +$13.64。

挂单清单（全部为真才许 HUNG）：

1. 硬催化、结构、`limit`、`stop`、`t1` 在同一棒上。`t1` 是结构位。
2. `SIZE_MODE=ONE_FULL_LEG`。
3. `t1_dollars=(t1−limit)×qty` **> 100**。
4. `t1_minus_hi=t1−printed_hi`。`reachable=YES` 仅当第 3 条为真，并且（`t1_minus_hi≤printed_range` 或 ATR 是数字且 `t1_minus_hi≤atr`）。没有 ATR 就写 `UNAVAILABLE`，不估。
5. 恰好一个令牌。未另签 C 时，只写 `T1=EXIT_ALL`。
6. 恰好一个 Δ34 条款，默认 `NO_OVERNIGHT`。

```
PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=FLOOR_STRUCTURE_CHOICE | option=A_T1_FLOOR_ONLY | needs=Frank
Scope: the next TRAIN3000 HUNG. Does not reprice 2026-10-05 or 2026-10-06.
Does not change SIZE_MODE. Standing mode stays ONE_FULL_LEG.
Does not change the Δ23 exit set or the Δ24 HIT line.
A HUNG is qualified only if all of these are true:
  t1_dollars > 100
  FLOOR_PATH=T1 | t1_dollars={ } | printed_hi={ } | printed_lo={ } | printed_range={ } | t1_minus_hi={ } | atr={number or UNAVAILABLE} | reachable=YES
  reachable=YES only if t1_dollars>100
    AND (t1_minus_hi<=printed_range OR (atr is a number AND t1_minus_hi<=atr))
  T2_ONLY does not make a HUNG qualified
  ROUND2 is not required and is not invented
IF t1_dollars<=100 OR reachable=NO
THEN the id is not a qualified HUNG and is not fillable
  FLOOR_PATH_NOFILL | {id}
The t1 price is the structure level.
  Do not raise t1 so the dollars clear 100.
  Do not add shares. Do not divide 3000 by 2 or by 3.
  Do not flip SIZE_MODE. Do not cut qty.
Hunt: a name whose structure t1_dollars<=100 is FLOOR_TOO_NARROW. Keep scanning.
  A day with no such name is NO_SETUP.
2026-10-06 VST-PB-RECLAIM-1006: t1_dollars=42.00. This option would not hang it.
  Do not unfill 20 @ 158.60. Do not reprice +42.00.
2026-10-05: t1_dollars=69.30. This option would not hang it.
  The old T2_ONLY reachable=YES line stays a historical fact. Do not reprice +13.64.
Unsigned: do not execute.
```

### Option B — `SPLIT_SLEEVE`（Frank 想拆名义）

数学上留一条：**B-seq，顺序满腿两轮。** 并发两腿放在下面，作为「不想改 Δ31 残额句」的对照，不推荐。并发三腿不提供。

预挂只留一个检查：**成交前已经写完的各腿 `t1_dollars` 之和 > 100。** 不把「可达的 t2 之和」当这个检查。每腿还要 ≥ $40，防止用一笔几美元的腿把和垫过 100。

**10/6：不挂。** 只有一条腿，t1=$42。残额 $80.57 开不出第二条有意义的腿。没有第二份写全的计划。把这 20 股拆成 10+10、同一条 VST 回踩，仍是一条结构，和仍是 $42，不计入两条腿。**10/5：不挂。** 只有 $69.30，没有第二条 ≥$40 的计划。

#### B-seq（推荐的拆法，若 Frank 要拆）

两轮都用满腿。第一轮出场、现金回到账上，才把第二份计划升成 HUNG。每轮所需涨幅约 **1.58%**（每股 >$2.50，下一分钱 $2.51）。

这和现行 Δ31 的 `MULTI_ROUND` 不是同一句。Δ31 要求第一笔成交后的残额仍 ≥ `per_leg_cap`，这样第二轮不必先平掉第一笔。满腿成交后残额只有几十到一百多美元，过不了这句。Δ38 的 `ROUND2` 支路用的是同一句残额条件，所以 **B-seq 在签字前不是 Δ38 的支路 (1)**。签字之后，才允许 `schedule=SEQUENTIAL_AFTER_T1` 这条例外：第一笔可以打满，残额可以小到开不出第二腿；第二腿只在第一腿已经按 Δ23 平掉之后出现。带内的腿仍然不平，不为了开第二腿去腾现金。

第二腿的触发在第一腿平掉时已经不在，就到此为止。11:30 之后新开一腿，仍要硬催化、结构、同棒三价（Δ24）。美元缺口不开这个窗。10/6 的出场在 11:43，过了 prefer 窗；即便当天签了 B-seq，那次出场也不自动产生第二腿。

失败面：第一腿止损，和就断了。第二份催化没出现，当天仍是 MISS。两轮都写在同一名字、同一结构上，清单直接拒绝。顺序两轮把操作面从一张票变成两张票，任一张没走到 t1，减半涨幅就不成立。

#### B-conc（对照，不推荐）

`per_leg_cap=floor(cash/2)=1647`。在 158.60 上每腿 10 股、$1,586。第一笔之后残额 $1,708.57 ≥ 1647，**过得了现行 Δ31**。所需涨幅仍是每腿 >3.15%。两只名字都要有硬催化。名义只比 $1,469.54 的 QQQ×2 micro 样本高 $116；股数取整后名义 ≤1469.54 就写 `SIZE_MODE_CONFLICT`，不成交。三腿的每腿名义约 $952，低于 micro，而且袖套不到 $4,408.62。

B-conc 挡得住 10/6，但一天要两套 3% 结构，样本更少，百分比又没有变好。要这个结果，签 A 更干净。

不动的：已写成 `ONE_FULL_LEG` 的票不翻模式、不改股数；Δ23；Δ24；Δ34 默认不过夜；10/6 与 10/5 的入账数字。

挂单清单（B-seq）：

1. 第一跳写下的模式行就是 `SIZE_MODE=MULTI_ROUND | N=2 | schedule=SEQUENTIAL_AFTER_T1 | per_leg_cap=FULL_SLEEVE`。不是成交后再改。
2. 腿 1 是唯一的活 HUNG。腿 2 是 `status=PLAN`，还不是 HUNG。
3. 两腿各自有硬催化、结构、limit、stop、t1。不同符号，或同一符号的另一套书面结构。同一结构拆股数，拒绝。
4. 每腿 `t1_dollars≥40`，且两腿之和 **> 100**。
5. 两腿都写 `T1=EXIT_ALL`，除非 Frank 在签字行里把 ride 写成 `ONLY_IF_T2_CLEARS`（那是 B+C，检查改到 C 那一节）。
6. 腿 1 按 Δ23 平掉之后，腿 2 的触发仍在，且仍在能通过全套门的时点，才升成 HUNG。不平掉仍在带内的腿 1。

```
PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=FLOOR_STRUCTURE_CHOICE | option=B_SPLIT_SLEEVE | needs=Frank
Scope: the next TRAIN3000 day. Does not reprice 2026-10-05 or 2026-10-06.
Until this block is signed, Δ31 and Δ38 and Δ42 stand.
  A full-size ticket is not ROUND2.
  Do not flip a written ONE_FULL_LEG. Do not cut qty. Do not divide 3000 by 2 or by 3 on a live ticket.
If Frank signs schedule=SEQUENTIAL_AFTER_T1, that signature is the only waiver
  of the Δ31 residual test, and only for a ticket whose first line is already:
    SIZE_MODE=MULTI_ROUND | N=2 | schedule=SEQUENTIAL_AFTER_T1 | per_leg_cap=FULL_SLEEVE
  Leg 1 may use the full sleeve. Residual cash may be dust.
  Leg 2 is a PLAN before any fill, not a second OPEN leg.
  Leg 2 becomes a HUNG only after leg 1 is CLOSED under Δ23.
  Do not flatten an in-band leg to free cash.
  After 11:30 a new leg still needs hard catalyst, structure, and same-bar three prices.
Pre-hang check, one test:
  both legs are fully written before the first fill
  each leg has its own hard catalyst and its own structure
  the same symbol and the same structure counted twice is one leg
  each t1_dollars >= 40
  SUM(t1_dollars) > 100
  ELSE FLOOR_PATH_NOFILL. Do not fill.
N=3 concurrent is not in this proposal.
  3 x 1469.54 = 4408.62. Cash 3294.57 is below that.
CONCURRENT is not the recommended schedule.
  It keeps the required percent near 3.15 and it fits today's Δ31 residual test.
  per_leg_cap = floor(cash/2)
  both legs HUNG before either fill
  fill notional <= per_leg_cap AND residual >= per_leg_cap
  rounded notional > 1469.54 or SIZE_MODE_CONFLICT
  Same SUM(t1_dollars)>100 test. Same ban on splitting one structure.
2026-10-06: one leg, t1_dollars=42, residual 80.57, no second written plan.
  This option would not hang it. Do not reprice +42.00.
2026-10-05: t1_dollars=69.30 and no second plan. This option would not hang it.
Unsigned: do not execute.
```

### Option C — `T1=SL2COST_RIDE_T2`

满腿不动。t1 第一次打印时把止损抬到成本，之后只在成本、写下的 t2、或书面失效出场。这会给 Δ23 的出场集合加上 t2 的打印，所以要 **Frank 和 CEO** 一起签。签字前，写了这个令牌的 HUNG 按 Δ43 不可成交。

C 单独构成底线，只有 **`t2_dollars>100` 且 Δ38 的 reachable=YES**。10/6 的 t2 是 $78，`reachable=NO`。**不挂。** 持有到写下的 162.50 是 +$78；六段日高的 $81.80 仍低于 $100，而且不是入账价。

C 放行 10/5：t2 路径 $137.50，当时 reachable=YES。那天 t2 150.30 没有打到，入账是收盘平、qualified 0。所以 C 挡得住 10/6，挡不住 10/5 那种「纸面 t2 过线、后来没打印」。

KOD-0928 的 HIT 是 t1 全平，+$142.12。同一账本行的 post-fill high 是 82.33，写下的 t2 是 84.5。骑到 t2 的规则不会在 81.0 落袋。82.33 仍低于 84.5。这行没有写 82.33 之后是否回到成本。能确定的是：C 会放弃这种在 t1 落袋的 HIT 形状。

失败面：t2 不打印，成本止损大约是 $0，日目标 MISS。t1 已经 >$100 的票若改骑，等于把已经够到的底线交回去。

不动的：股数、`ONE_FULL_LEG`、Δ24、Δ34、10/6 的 +$42.00。未签字时 Δ23 的出场集合不动。

挂单清单（只签 C、不签 A/B 时）：

1. `SIZE_MODE=ONE_FULL_LEG`。
2. `T1=SL2COST_RIDE_T2` 这一枚令牌。散文「SL→COST at t1」不算。
3. `FLOOR_PATH=T2_ONLY`，`t2_dollars>100`，`reachable=YES`（区间或 ATR，算法与 Δ38 相同，美元门槛用 >100）。
4. 硬催化、结构、同棒三价、`NO_OVERNIGHT`。

**A+C：** 预挂用 A（t1 美元 >100 且 t1 够得着），令牌改成骑 t2。10/6 与 10/5 都不挂。过线之后，落袋点变成 t2。KOD 那种 t1 HIT 会让出去。本稿不把 A+C 当底线方案。

**B+C：** 两腿计划仍要在第一笔成交前写完，令牌都是骑 t2，检查改成 **两腿各自 reachable=YES 的 `t2_dollars` 之和 > 100**，且每腿 t2 美元 ≥40。10/6 只有 78，不挂。两段都得走到 t2，失败面比 B-seq 宽。

```
PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=T1_DEFAULT_MODE | option=C_RIDE_T2 | needs=Frank_and_CEO
Scope: which exit a new TRAIN3000 HUNG may use. Does not reprice 2026-10-06.
Choice C is not the recommended default.
A HUNG that writes T1=SL2COST_RIDE_T2 stays unfillable until this block is signed.
If it is signed alone, a HUNG is fillable only if:
  SIZE_MODE=ONE_FULL_LEG
  T1=SL2COST_RIDE_T2
  FLOOR_PATH=T2_ONLY and t2_dollars>100 and reachable=YES
    under the Δ38 printed-range or ATR test
  at the first t1 print, raise the stop to COST and hold
  later exit only at the cost stop, the written t2, or a written invalidation
  this adds a t2 print to the Δ23 exit set
IF t2_dollars<=100 OR reachable=NO THEN do not fill.
2026-10-06: t2_dollars=78.00, so reachable=NO. This option would not hang it.
  The ride to 162.50 is +78.00 and stays under 100.
  Do not reprice the booked 160.70 / +42.00.
2026-10-05 would have passed this t2 test. t2 did not print. Do not reprice +13.64.
KOD-0928 booked the HIT at written t1. This option would not book that shape.
A+C means Option A's t1 test plus this ride token.
  That gives back a t1 that already cleared the floor. Not the floor plan.
B+C means Option B's two written plans, this ride token on each,
  and SUM of reachable t2_dollars > 100, each t2_dollars>=40.
  2026-10-06 still fails.
Unsigned: do not execute.
```

期权袖套不单列。在同一套硬催化、结构、限价、止损、t1、当日付清下面，这份材料里没有一条权利金路径能在挂单前算出 >$100。Sleeve A 与 ••••1429 不在本稿里。

---

## 4. 对照

| | 日底线（定性） | 一天几笔 | 复杂度 | 和现行 `ONE_FULL_LEG` / Δ31 |
|---|---|---|---|---|
| A | 成交的那笔，t1 纸面已经 >$100。没有这种结构的日子是空仓 MISS。10/6 和 10/5 都不挂 | 0–1 | 低。一个美元门加现成的区间检验 | 不改仓位模式。签字后才改 Δ38：`T2_ONLY` 不再合格 |
| B-seq | 两轮都在 t1 落袋才把所需涨幅降到约 1.58%。少一轮就是 MISS。10/6 和 10/5 都不挂 | 0–2 | 高。两套催化，还要一条 Δ31 残额例外 | **冲突。** 签字前不是合法 `ROUND2` |
| B-conc | 百分比仍约 3.15%，还要两套结构。被 A 盖过 | 0–2 | 高 | 残额条件过得了 Δ31。名义贴着 micro 样本 |
| C | 只有 t2 美元 >100 且打出来才过线。10/6 不挂。10/5 会挂，而且当天没打到 t2 | 0–1 | 中。改的是出场集合 | 不改股数。Δ43 下现在不可成交 |
| A+C | 挂单门槛同 A。落袋改到 t2，KOD 那种 t1 HIT 会让出去 | 0–1 | 中 | 同 A，再加出场集合 |
| B+C | 门槛改成两腿 t2 之和。10/6 仍不挂。两段都要走到 t2 | 0–2 | 最高 | 同 B-seq 的冲突，再加出场集合 |

---

## 5. 今天一张都不签的话，明天照现在的规则做

- `SIZE_MODE=ONE_FULL_LEG`。不拆 $3,000。不把股数改小。成交后再改模式，Δ31 / Δ42 不允许。
- 有 `FLOOR_PATH=` 行，而且是写全的、`reachable=YES` 的，才是合格 HUNG。缺行或 `reachable=NO`，后一跳不 FILL，也不补记（Δ42）。
- 令牌只写 `T1=EXIT_ALL` 的票才可成交，出场按 Δ23 在写下的 t1 全平。`T1=SL2COST_RIDE_T2` 不成交（Δ43）。
- 因此 **10/6 的形状明天挂不上**：t1=$42，t2=$78，满腿没有 `ROUND2`。
- **10/5 的形状仍挂得上**：`T2_ONLY` 且 t2 美元 ≥100、区间或 ATR 为 YES。这是不签字时留下的口子。要关上它，签 A 或 B。
- 没有合格结构，就写 `NO_SETUP` / Δ32 的空仓行。日目标按 Δ24：qualified 未到 100 仍是 MISS。不用一笔不合格的成交去填这个 MISS。
- 默认 `NO_OVERNIGHT`。不追 VST 的同一结构。不重开 CCL。不回挂 VKTX、SPY-PUT-ORL-PB-0928。
- Δ24 的 HIT 行仍是 **≥ $100**。本稿提案里的 **> $100** 在签字前不代替它。

---

## 6. 要 Frank 定的三件事

1. 明天用 **A**，用 **B-seq**，还是 **NONE**（第五节）？并发两腿和并发三腿不在推荐里。
2. t1 维持 `EXIT_ALL`，还是另签「只在 t2 美元 >100 且 reachable=YES 时用 `SL2COST_RIDE_T2`」？后一个要 Frank 和 CEO 一起签。
3. 预挂门槛用 **> $100**，还是继续用已生效的 Δ24 **≥ $100**？不签就不改 Δ24。

---

## 索引（不另立 Δ46，不改 PROCESS-PATCHES 正文）

| 提案 id | 本稿对应 | 生效？ |
|---|---|---|
| `FLOOR_STRUCTURE_CHOICE` option A | Option A | 否 |
| `FLOOR_STRUCTURE_CHOICE` option B | Option B。顺序满腿是新的 `schedule=` 句；并发才是现行 Δ31 残额句 | 否 |
| `T1_DEFAULT_MODE` choice B | Option C | 否 |
| `NO_OVERNIGHT_MFE_075R_SL_COST` | 本稿不采用，继续未签字 | 否 |
