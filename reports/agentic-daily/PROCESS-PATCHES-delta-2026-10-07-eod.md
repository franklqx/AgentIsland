# APPEND ONLY — Cursor EOD 2026-10-07 · Δ47–Δ50

粘贴位置：现有 `PROCESS-PATCHES` 末尾，Δ46 之后。不改写 Δ38–Δ46。不替换 Patch 1–6。不替换 Δ7–Δ46。不放宽任何旧门。冲突时更严者生效。

纸面 TRAIN3000 / 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

不回改 2026-10-05、2026-10-06、2026-10-07 的成交价、出场价、已实现盈亏、现金。

C / `T1=SL2COST_RIDE_T2` / `T1_DEFAULT_MODE` 仍是 **PROPOSAL · 未签字 · 不生效**。`NO_OVERNIGHT_MFE_075R_SL_COST` 仍未签字。`RETEST_TOL>0` 在下面也是提案，不是规则。

## 结论

2026-10-07 是 B_SEQ 签字后的第一天。leg1 PENG 45 @72.80 → 75.00，+$99.00 qualified，这笔记账价格不动。三张 leg2 都 VOID，无成交。日 qualified 99.00，目标是 >100，DAY_GOAL MISS。

新规则只做收紧：

- Δ47：HUNG 必须有 `ENTRY_GEOM=`。触发棒写法在带宽窄于 spread 时不得挂。回测必须写 `RETEST_TOL=`。大于 0 不成交。
- Δ48：两腿之外写 `PLAN_B={id|NONE}`。leg2 作废的当跳可以晋升这一张，不得变成 N=3 并发。
- Δ49：VOID 进入当跳三处记账。后一跳缺 ledger 不得 sleep。
- Δ50：扫描表改到 `state/scan-table-YYYY-MM-DD.md`，只追加。

例程门、Δ40 的四段火钟、开盘猎 09:31、11:30 的 VOID_TIME、Δ17、Δ37、Δ41、Δ25，都不新编号。

## Δ47. ENTRY_GEOM_AT_HUNG（HUNG 写下时必须有入场几何行；正数回测容差未签字）

2026-10-07 的 `BKH-GDC-FLAG-BO-1007`：触发是 5 分钟收盘 >76.30，limit ≤76.40，L−X=0.10。票面 flag 75.37–76.29，区间 0.92。挂单报价 bid 75.95 / ask 76.23，spread=0.28。0.10<0.28。票面写「fill only at ≤76.40 on trigger bar」，作废段又写 order 从 10:20 才生效。10:15 这根收 76.58，比 76.40 高 0.18。收盘是触发被确认的那一笔打印。收盘已经高于 limit 时，这根棒上不存在「确认触发之后仍 ≤76.40」的成交。10:20 低 76.57，10:25 低 76.645，都高于 76.40。VOID `TRIGGER_NO_FILL_NO_CHASE` 成立。

`BKH-BO-RETEST-1007`：区间 76.30–76.45，limit ≤76.45，没有容差字段。挂单报价 bid 76.67 / ask 76.81，spread=0.14。挂后最低 76.51，差 0.06。t1 77.40，数量 44。(77.40−76.51)×44 = 39.16，低于 40。99.00+39.16 = 138.16，合计仍大于 100，单腿不过 Δ46。在 t1 与数量不动时，`t1_dollars≥40` 的最高 limit 是 77.40−40/44 = 76.490909…。76.51 在这条线外面。

PENG 不在这条的回溯范围内。09:35 收盘 72.80，limit 72.80，收盘落在 (72.60, 72.80] 里。不改 72.80 / 75.00 / +99.00。

- 适用范围：本跳写下的 TRAIN3000 HUNG，以及本跳把 PLAN 或 PLAN-B 晋升为 HUNG。Sleeve A 不在范围内。已经 CLOSED 或已经 VOID 的 10/7 票不重写。
- IF 本跳写这张 HUNG THEN 状态文件含有这一行字面字段：
  `ENTRY_GEOM= mode={TRIGGER_BAR|RETEST_AFTER_TRIGGER} | L={ } | X={ } | L_minus_X={ } | bar5_range={ } | spread={ }`
  `L` 是写下的 limit。`X` 是收盘触发价；回测票没有收盘触发时 `X=NA`，`L_minus_X=NA`。`bar5_range` 只允许抄这张票已经写下的结构高减结构低。票上没有这段结构则 `bar5_range=UNAVAILABLE`。`spread` 是同棒三价那一笔的 ask−bid。不得用后一跳的报价回填。
- IF 缺这一行，或 `mode` 不是上面两个令牌之一，或 `spread` 空着 THEN `ENTRY_GEOM_MISSING | {id}`。不得挂。不得成交。不得 sleep。
- IF `mode=TRIGGER_BAR` AND 触发条件是某根 K 线的收盘 > X THEN 只有这根收盘落在 (X, L] 时，触发和 limit 才同时成立。收盘 > L 不是成交，也不是把单子挪到下一根的授权。
- IF `mode=TRIGGER_BAR` AND（`L_minus_X≤0` OR `L_minus_X<spread` OR 票面同时写了「只在触发棒成交」和「从下一根才挂单」）THEN `ENTRY_GEOM_INCOHERENT | {id}`。不得挂。改写时只允许改成 `mode=RETEST_AFTER_TRIGGER` 且 L 不变，或者不挂。不得在改写时把 L 抬高。
- IF `mode=TRIGGER_BAR` AND `bar5_range=UNAVAILABLE` THEN 同样 `ENTRY_GEOM_INCOHERENT | {id}`。不得挂。`L_minus_X<bar5_range` 只写在这一行里供核对，单独这一比较不得作为否决。否决用的是上面的 spread 与矛盾句。
- IF `mode=RETEST_AFTER_TRIGGER` THEN 同一张票还要有 `RETEST_TOL={数字}` 和 `zone_hi={ }`。缺了则 `RETEST_TOL_MISSING | {id}`。不得挂。
- IF `RETEST_TOL=0` THEN 休息限价仍是 ≤ `zone_hi`。这是现有的严门，可以挂。0 不是放宽。
- IF `RETEST_TOL>0` THEN 这条 HUNG 不可成交。容差见下方提案。不得把已挂出的 limit 在后一跳调高。
- 10/7 的两张 BKH 保持 VOID。禁止把 76.58、76.51、77.95 或 77.975 写成成交。
- **Do not:** 用容差提案成交。**Do not:** 为了让 L−X 大于 spread 而放宽硬催化、结构或同棒三价。**Do not:** 改 Δ46 的 `t1_dollars≥40` 或合计 >100。**Do not:** 改 PENG。**Do not:** `place_*`。

### PROPOSAL · 未签字 · 不生效 — RETEST_TOL 正数

不得当作生效规则，不得执行。签字前 `RETEST_TOL>0` 的票不可成交。

```
PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=ENTRY_RETEST_TOL | needs=Frank_and_CEO
Scope: a new TRAIN3000 HUNG whose mode is already RETEST_AFTER_TRIGGER.
Does not apply to an order that is already hung. Does not reprice 2026-10-07.
At the hang wake, before any fill, using only numbers already on that ticket:
  spread = ask − bid on the same-bar quote
  bar5_range = the structure high − structure low written on THIS ticket
  room = t1 − (40/qty) − zone_hi
  tol = min(spread, 0.25 × bar5_range, max(room, 0))
  new_limit = zone_hi + tol
  t1_dollars = (t1 − new_limit) × qty
  sum = peer_realized_or_peer_t1 + t1_dollars
IF t1_dollars < 40 OR sum ≤ 100 THEN do not use tol. Keep zone_hi.
IF new_limit > zone_hi THEN this block is a looser fill than the written top.
  It stays unsigned. Do not hang it. Do not fill it.
Do not raise t1 to manufacture room. Do not change qty to manufacture room.
Do not waive Δ46.
```

用 10/7 回测票上已经写下的数做算术，只说明提案即使签字也填不上 76.51。这不是把提案回溯到当天。

回测票自己的区间宽是 76.45−76.30 = 0.15。0.25×0.15 = 0.0375。spread=0.14。room = 77.40−40/44−76.45 = 0.040909…。tol = min(0.14, 0.0375, 0.040909…) = 0.0375。new_limit = 76.4875。t1 美元 = (77.40−76.4875)×44 = 40.15，仍 ≥40。76.51−76.4875 = 0.0225。76.51 仍在容差外面。

若误用前一张旗形票的区间 0.92：0.25×0.92 = 0.23，tol 会被 room 卡成 0.040909…，new_limit = 76.490909…，t1 美元 = 40.00。76.51 仍然在外面。旗形区间不属于这张回测票，正式算法不得借用。

若忽略 room、只用 spread 0.14：new_limit = 76.59，t1 美元 = (77.40−76.59)×44 = 35.64 < 40。Δ46 仍要否决。这个忽略不是提案的一部分。

76.49 的 t1 美元是 40.04。76.50 是 39.60。6 美分这一档过不了单腿 40 美元。

## Δ48. LEG2_PLAN_B_SAME_WAKE（leg2 作废的当跳晋升事先写好的替补；不是第三笔并发）

2026-10-07 leg1 的 t1 美元正好 99.00。(75.00−72.80)×45 = 99.00。日目标是 qualified >100，所以这一天的底线落在 leg2 是否成交。STZ 在 09:45 从 PLAN 晋升为 HUNG。当时 bid 117.83 / ask 118.41，spread=0.58。触发 119.60 离 ask 1.19，1.19/3 = 0.3966…，0.58 大于这个三分之一。离 bid 的 1.77/117.83 = 1.502%，handoff 的「约 1.5%」对的是 bid 这一侧。作废原因不是 spread：09:45–09:50 这根收 116.63 < void 117.20。journal 记到 VOID 的跳是 ~09:53。下一张 leg2 要到 10:07 才挂上。09:50→10:07 = 17 分钟，09:53→10:07 = 14 分钟。09:37 的两腿计划里没有第三张未挂、不占现金的替补。

Δ46 要求第一笔成交前写两腿，并禁止 N=3 并发。两腿都写了。缺的是作废之后同一跳能晋升的那张预先审过的替补。只重说「继续扫描」盖不住「必须等到下一次 10 点复查」。

- IF B_SEQ AND 本跳在第一笔 FILL 之前写两腿 THEN 同一跳再写一行 `PLAN_B={id}` 或 `PLAN_B=NONE`。
- IF `PLAN_B={id}` THEN 这张票的状态是 PLAN-B。不是 HUNG，不是 OPEN，`cash_reserved=0`，不计入并发 N。它要有自己的硬催化、结构、limit、stop、t1、恰好一个 Δ34 令牌、恰好一个 Δ43 令牌、一行 `ENTRY_GEOM=`。`t1_dollars≥40`。它不与两腿同时挂出，所以不把三张票的 t1 美元加在一起当成必须 >100 的第三腿。
- IF 写不出这样一张过门的票 THEN `PLAN_B=NONE`。作废那一跳不得临时编一个标的来填这行。
- IF leg2 在本跳变为 VOID AND leg1 已经 CLOSED AND `PLAN_B` 不是 NONE AND 它的触发仍然有效 AND 本跳能完成硬催化、结构、同棒三价、Δ34、Δ43、`ENTRY_GEOM`、`t1_dollars≥40`、`peer_realized+t1_dollars>100` THEN 本跳把 PLAN-B 晋升为唯一的 leg2 HUNG，并写 leg2 的 `FLOOR_PATH=`。不得把这次晋升留到 10 点复查。10 点复查仍要写 Δ45 / Δ50 的扫描表。
- IF `PLAN_B` 本跳过不了门 THEN 不晋升。继续扫描。不得为了底线差额降低门。
- IF leg2 仍是 PLAN 或仍是 HUNG THEN 不得晋升 PLAN-B。TRAIN3000 同时处于 HUNG 或 OPEN 的腿最多一条。N=3 并发仍然禁止。
- IF 本跳晋升一张 leg2（含 PLAN-B）AND `spread > (trigger−ask)/3` THEN 写 `LEG2_SPREAD_WIDE | {id} | spread={ } | dist_ask={ } | third={ }`。`dist_ask = trigger−ask`，`third = dist_ask/3`。用晋升这一跳的同棒报价，不得用后一跳的报价。
- IF 该标签成立 AND 另一张 PLAN-B 在本跳过门 THEN 晋升那张 PLAN-B，不晋升这张宽 spread 的腿。
- IF 该标签成立 AND `PLAN_B=NONE` 或 PLAN-B 过不了门 THEN 标签仍然要写。标签单独不否决一张已经通过全部旧门的腿。不得用这个标签放宽 void 线。
- 10/7 不补写 PLAN-B，不新挂任何名字，不改 99.00，不改 STZ 的 VOID。
- **Do not:** 把 PLAN-B 挂成与 leg2 同时存在的第二张 HUNG。**Do not:** 为 PLAN-B 锁定现金。**Do not:** 把 N 改成 3。**Do not:** 编一个 10/7 的替补标的。**Do not:** `place_*`。

## Δ49. BOOK_TRIPLE_LEDGER_STICKS（收紧 Δ39 / Δ44；VOID 也要当跳进 ledger，缺 ledger 的后一跳不得 sleep）

Δ39 的范围是 TRAIN3000 的 FILL 和 EXIT。Δ44 把「后一跳不得 sleep」写在 journal 缺节上，并把 HUNG 的写下算进 journal。两句都没有把 VOID 算进当跳的 ledger，也没有把「journal 和状态文件已经有了、ledger 没有」写成后一跳的硬停止。

2026-10-07 09:45 的 journal 有 `PENG-EARN-VWAP-RECLAIM-1007`、数量 45、72.80、75.00、+$99.00。state 有 CLOSED。六段写当时 `ledger.csv` 没有 10/7 的行。09:53 之后每一跳都 sleep 了。EOD 补了 4 行：PENG closed，STZ voided，BKH flag voided，BKH retest voided。本包 csv 里这 4 行已经在，备注写明 EOD backfill。EOD 动手之前的 0 行，和文件现在的 4 行，两句都成立。

STZ、BKH 旗形、BKH 回测是 VOID，没有成交价。Δ39 的 FILL/EXIT 句子盖不住它们。

- 适用范围：TRAIN3000 的 FILL、EXIT，以及 TRAIN3000 的 VOID。Sleeve A 的 GAP_STOP 仍走 Δ7 / Δ12。Δ44 对 HUNG 写下的 journal 要求不变。
- IF 本跳把 FILL 或 EXIT 记成已发生 THEN Δ39 与 Δ44 的三处仍要在 sleep 前写齐。journal 含 id、数量、价格；出场还要含 pnl。
- IF 本跳把 VOID 记成已发生 THEN sleep 前同样三处都在。ledger 这一行：`status=voided`，entry 列是该票写下的 limit，exit 空，pnl 空，notes 含 id 与作废原因。journal 含 id 与作废原因。状态文件是 VOID。不得为了填 exit 而编一个出场价。
- IF 后一跳看见当日某 id 的 FILL、EXIT 或 VOID 已经写在 journal 或状态文件里，而 ledger 没有该 id THEN `BOOK_TRIPLE_MISS | {id} | missing=ledger`。不得 sleep。sleep 前按 journal 与状态文件里已经一致的 id、数量、价格补上 ledger 行。VOID 的 exit 与 pnl 保持空白。不得改用后一跳的 mark。journal 与状态文件不一致时，不挑选一个价格，不得 sleep。
- 写了 paper-capital 或 train3000-hunt，仍不算 ledger 这一处。
- 2026-10-07 的 4 行已经由 EOD 补写。本条不要求再补第五行。禁止改 45 @72.80→75.00、+$99.00、现金 $3,393.57。禁止把三张 VOID 改成成交。
- **Do not:** 用 EOD 回填代替当跳的 ledger。**Do not:** 为了三处一致而改价。**Do not:** 编一笔 fill。**Do not:** `place_*`。

## Δ50. SCAN_TABLE_OWN_FILE（收紧 Δ45；扫描表单独文件，只追加）

Δ45 要求 10:00 仍没有扫描表时，10 点复查在本跳写上：点过名的个数、每个未挂名字的拒绝原因、已 HUNG 的 id 和它过的门。它没有指定文件名，也没有禁止后一跳用仓位表覆盖同一文件。

2026-10-07 ~10:07 写了 `scan-table.md`：点名 12 · HUNG 1 · REJECT 11。1+11=12。六段写这份文件随后被满仓盯的仓位表覆盖。journal 留下计数，没有 11 条拒绝原因。本复盘不编这 11 个名字。

- IF 本跳按 Δ45 写扫描表 THEN 文件是 `state/scan-table-YYYY-MM-DD.md`。不得再写到没有日期的 `scan-table.md`。不得把 Sleeve A、现金、持仓 mark 或满仓盯仓位表写进这个文件。
- 当天第一段以这一行开头：`asof={HHMM} | named={n} | hung={n} | reject={n}`。其后每个名字一行：`{name} | HUNG | {id} | gates={ }` 或 `{name} | REJECT | {reason}`。只追加。后一跳有新的拒绝或新的 HUNG，追加一段新的 `asof=`，不删上面的段。
- IF 这一跳只有计数、没有逐名原因 THEN 仍是 Δ45 的 `SCAN_TABLE_MISSING`。不得 sleep。不得编原因。
- IF 后一跳发现该文件被截断、被仓位表替换、或当日 `asof=` 段不见了 THEN `SCAN_TABLE_CLOBBERED | asof={HHMM}`。不得 sleep。只把 journal 或该文件旧字节里仍然存在的行写回去。已经不在任何附件里的拒绝原因，写 `SCAN_TABLE_REASONS_LOST | named={n} | reject={n}`，然后停止。不得按记忆补名字。
- 2026-10-07 的拒绝原因保持丢失。禁止在复盘、晨报或 10/8 的扫描表里补这 11 个名字。
- **Do not:** 为了让文件非空而降低硬催化、结构或同棒三价。**Do not:** 把已经 REJECT 的名字挂上。**Do not:** 回挂 VKTX 或 SPY-PUT-ORL-PB-0928。**Do not:** 重开 CCL。**Do not:** `place_*`。

## 不新开

### 早盘门与末小时门

后一跳落在 09:35–11:30 的门是 `10m_early`（Δ18）。11:30–15:05 是 `25m_mid`（Δ15）。15:05–16:00 是 `10m_lasthour`（Δ20）。`gap>door` 写 `ROUTINE_GAP`。`gap>door+10` 才写 `HEAL_LATE`（Δ26）。门的分钟不改。

10:09→10:35 = 26 分钟。10:35 在 11:30 之前。六段把它写成超 25 分钟中盘门。应写 `door=10m_early`，并且 26>20，所以还有 `HEAL_LATE`。10:15 的旗形触发落在这段间隔里。10:20 的低点 76.57 已经高于 76.40，这段迟到没有制造一个成交。不把 10 分钟改成 26 分钟或 25 分钟。

同一早盘里，六段没有点名的破门：09:53→10:07 = 14，10:35→10:53 = 18，10:53→11:08 = 15，11:08→11:27 = 19。都是 `10m_early` 的 OVER_DOOR，都 ≤20，都不是 `HEAL_LATE`。10:07 相对 10:00 复查锚是 +7 分钟，仍在 Δ11 的 +10 里。14 分钟是 journal 间隔，不是 10 点复查迟到。

15:09→15:22 = 13，15:36→15:50 = 14。后一跳都在 15:05 之后。OVER_DOOR，不是 `HEAL_LATE`。六段对这两段的 10 分钟门是对的。

11:27→11:45 = 18，后一跳已过 11:30，25 分钟门内。11:45 到 15:05 之间，journal 标题间隔最大是 11:58→12:16 = 18 ≤ 25。14:59→15:09 = 10，10 不大于 10。不新编号。

附件里没有满仓盯的 crontab 原文。不新造一行 cron。父级不要把早盘门改成 25 分钟。

### 开盘猎 09:31

Δ11 的计划锚仍是 09:31 ET。全文应在 09:41 之前出现在约定 chat，否则 `LATE_PING`。六段写实际 ~09:43，晚 12 分钟。journal 标题是 ~09:45，相对 09:31 是 14 分钟。两套钟都晚于 09:41。切片里没有 `LATE_PING`。不把锚改到 09:43 或 09:45。不把 Δ11 的 10 分钟放宽到 12 或 14。PENG 的 72.80 / 75.00 / +99.00 不因晚跑而改。

### Δ40 已经落在窗内

spawn 09:24（`2026-10-07T13:24:26Z`），内容 DONE 09:32（`iso=2026-10-07T09:32:50-0400`）。合格线仍是 spawn≤09:35 且内容 DONE≤09:35。今天两者都在线内。四段计划时刻保持 09:12 / 09:14 / 09:15 / 09:19。不前移，不增加第五个火钟。附件没有把这四段的实际点火分成四行。不编四个实际钟点。

### 11:30 VOID_TIME

`BKH-BO-RETEST-1007` 在 11:30 未成交而作废，是对的。六段、ledger 备注、handoff 写约 13:30 低到 76.435，15:30 低到 75.795，低于 stop 75.85。这两笔低点不在 journal 里。票面风险 (76.45−75.85)×44 = 26.40。若把成交价改成 76.435 再打到 75.85，算术是 25.74。附件写的约 −$26.40 对得上票面风险。两种算法都不是已实现盈亏。不把 prefer 窗延过 11:30。不把 76.435 写成成交。

### 一并看到、同样不新开

- Δ17。收盘 HUNG 空。无 HUNG_TOUCH。无 EXPIRE / REWRITE。
- Δ37。10/7 有完整来回 1 笔。10/8 不触发 Δ37。
- Δ41。全日纸面 `wake_parent_needed=false`。不把 t1 出场加进出声名单，也不从名单里删 `HUNG_TOUCH`。
- Δ25。Mac 离线，`MAC_MIRROR_QUEUE`。box 不是 Desktop 已更新。不新编号。
- 周数字。W/C 10/05 的 raw/qual = 55.64+99.00 = 154.64 / 42.00+99.00 = 141.00，与 ledger 三行一致。paper-capital 写 OPEN。六段写 qualified 已过 100、周五收周。141≥100。周三不把周收成 HIT，不扩大 reason 枚举，不把 t1 出场写成 `reason=early_exit`。
- Sleeve A。AAPL 的 hard ≤7.20 / 股 320 未触。CRWD 已在 COST。10/8 距 10/16 是 8 个日历日，Δ9 的 ≤7 不触发。六段的「7 个交易日」不是这条的单位。不在本 delta 写平仓指令。
- 未签字、继续不生效：C，`T1=SL2COST_RIDE_T2`，`T1_DEFAULT_MODE`，`NO_OVERNIGHT_MFE_075R_SL_COST`，以及本文件的 `ENTRY_RETEST_TOL`。PENG 出场棒 MFE = 112.50/99.00 = 1.136R，0.75R 的价格是 74.45。出场已经按写下的 t1 在 09:41 全平。不用提案回改这笔。
- 真钱。附件全程 $3,064.83，仓空，当日已实现 $0。本复盘未调用券商。

## 粘贴块

```
# DELTA 2026-10-07 EOD — append after Δ46.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ46.
# Paper 7474 only. No place_*. Do not touch account 1429.
# Do not reprice 2026-10-05, 2026-10-06, or 2026-10-07.
# A sentence that raises a resting limit is PROPOSAL · 未签字 · 不生效.
# C / T1=SL2COST_RIDE_T2 / T1_DEFAULT_MODE / NO_OVERNIGHT_MFE_075R_SL_COST stay unsigned.

Δ47 ENTRY_GEOM_AT_HUNG (a HUNG file names its geometry; a positive retest tolerance is not fillable)
Scope: the wake that writes a TRAIN3000 HUNG, or promotes PLAN / PLAN-B to HUNG.
  Sleeve A is out of scope. Do not rewrite a 2026-10-07 CLOSED or VOID ticket.
IF this wake writes that HUNG
THEN the state file contains
  ENTRY_GEOM= mode={TRIGGER_BAR|RETEST_AFTER_TRIGGER} | L={ } | X={ } | L_minus_X={ } | bar5_range={ } | spread={ }
  bar5_range is structure high minus structure low already written on THIS ticket, else UNAVAILABLE
  spread is ask−bid on the same-bar quote. Do not backfill it from a later wake
IF the line, the mode token, or spread is missing
THEN ENTRY_GEOM_MISSING | {id}
  do not hang. do not fill. do not sleep
IF mode=TRIGGER_BAR AND the trigger is a bar close > X
THEN that close qualifies only when it prints inside (X, L]
  a close > L is not a fill and does not move the order onto the next bar
IF mode=TRIGGER_BAR AND (L_minus_X≤0 OR L_minus_X<spread
  OR the ticket says both "fill on the trigger bar" and "order live from the next bar")
THEN ENTRY_GEOM_INCOHERENT | {id}
  do not hang
  a rewrite may set mode=RETEST_AFTER_TRIGGER only with the same L
  do not raise L in that rewrite
IF mode=TRIGGER_BAR AND bar5_range=UNAVAILABLE
THEN ENTRY_GEOM_INCOHERENT | {id}
  do not hang
L_minus_X<bar5_range is recorded on the line and is not, by itself, a veto
IF mode=RETEST_AFTER_TRIGGER AND RETEST_TOL= or zone_hi= is missing
THEN RETEST_TOL_MISSING | {id}
  do not hang
IF RETEST_TOL=0
THEN the resting limit stays ≤ zone_hi
IF RETEST_TOL>0
THEN that HUNG is not fillable
  the formula below is PROPOSAL · 未签字 · 不生效
Do not fill 76.58, 76.51, 77.95, or 77.975 on the 2026-10-07 BKH tickets.
Do not reprice PENG 45 @ 72.80 → 75.00 / +99.00.

PROPOSAL · 未签字 · 不生效
PROPOSAL_NOT_IN_FORCE | id=ENTRY_RETEST_TOL | needs=Frank_and_CEO
  tol = min(spread, 0.25×bar5_range, max(t1−40/qty−zone_hi, 0))
  new_limit = zone_hi + tol
  IF (t1−new_limit)×qty < 40 OR the peer sum ≤ 100 THEN do not use tol
  IF new_limit > zone_hi THEN do not hang and do not fill until this proposal is signed
  Do not raise t1. Do not change qty. Do not waive t1_dollars≥40.
  On the 2026-10-07 retest ticket this tol is 0.0375, new_limit 76.4875, t1_dollars 40.15.
  76.51 is still 0.0225 outside it. Signing would not have filled 76.51.

Δ48 LEG2_PLAN_B_SAME_WAKE (a prewritten replacement can promote on the void wake; N=3 stays out)
IF B_SEQ AND this wake writes the two legs before the first FILL
THEN the same wake also writes PLAN_B={id} or PLAN_B=NONE
IF PLAN_B={id}
THEN status=PLAN-B, not HUNG, not OPEN, cash_reserved=0, not counted in N
  own catalyst, structure, limit, stop, t1, one Δ34 token, one Δ43 token, one ENTRY_GEOM line
  t1_dollars≥40
  do not add its t1_dollars to the two live legs to invent a third concurrent sum
IF no name passes
THEN PLAN_B=NONE
  the void wake must not invent a ticker
IF leg2 becomes VOID on this wake AND leg1 is CLOSED AND PLAN_B is an id
  AND its trigger is still valid AND this wake passes catalyst, structure, same-bar three prices,
  Δ34, Δ43, ENTRY_GEOM, t1_dollars≥40, and peer_realized+t1_dollars>100
THEN promote PLAN-B to the single leg2 HUNG on this wake
  do not wait for the 10:00 review
  the 10:00 review still writes the scan table
IF leg2 is still PLAN or still HUNG
THEN do not promote PLAN-B
  at most one TRAIN3000 leg is HUNG or OPEN
  N=3 concurrent stays out
IF promoting a leg2 AND spread > (trigger−ask)/3
THEN LEG2_SPREAD_WIDE | {id} | spread={ } | dist_ask={ } | third={ }
  use this wake's quote
IF that tag is on AND another PLAN-B passes on this wake
THEN promote the PLAN-B and do not promote the wide leg
IF that tag is on AND PLAN_B is NONE or fails
THEN still write the tag
  the tag alone does not void a leg that already passes the older gates
Do not invent a 2026-10-07 PLAN-B. Do not reprice 99.00. Do not un-void STZ.

Δ49 BOOK_TRIPLE_LEDGER_STICKS (tightens Δ39/Δ44; VOID is in the same-wake triple; a missing ledger row sticks)
Scope: TRAIN3000 FILL, EXIT, and VOID. Sleeve A GAP_STOP stays on Δ7/Δ12.
IF this wake records a FILL or EXIT
THEN Δ39 and Δ44 still apply before sleep
IF this wake records a VOID
THEN before sleep the journal has the id and the void reason,
  the state file is VOID,
  and ledger.csv has status=voided, entry=the written limit, exit blank, pnl blank
  do not invent an exit to fill the blank
IF a later wake sees that FILL, EXIT, or VOID in the journal or the state file
  AND ledger.csv has no row for that id
THEN BOOK_TRIPLE_MISS | {id} | missing=ledger
  do not sleep
  append the row from the id, qty, and prices already agreed by journal and state
  if journal and state disagree, do not pick a price and do not sleep
  do not use a later mark
  do not wait for EOD
paper-capital.md and train3000-hunt.md are still not the ledger place
The four 2026-10-07 rows were backfilled at EOD. Do not add a fifth.
Do not reprice 72.80 / 75.00 / +99.00 / cash 3393.57.
Do not turn the three VOIDs into fills.

Δ50 SCAN_TABLE_OWN_FILE (tightens Δ45; the scan table is its own append-only file)
IF this wake writes the Δ45 scan table
THEN the file is state/scan-table-YYYY-MM-DD.md
  do not write it to an undated scan-table.md
  do not write Sleeve A, cash, or position marks into that file
First block of the day:
  asof={HHMM} | named={n} | hung={n} | reject={n}
  then one line per name: HUNG with id and gates, or REJECT with the reason
Append only. A later wake adds a new asof block and does not delete the earlier block
IF the wake has a count and no per-name reasons
THEN Δ45 SCAN_TABLE_MISSING still applies. Do not invent reasons. Do not sleep
IF a later wake finds the file truncated, replaced by a position table, or missing its asof block
THEN SCAN_TABLE_CLOBBERED | asof={HHMM}
  do not sleep
  restore only lines that still exist in the journal or in the previous bytes
  if a reason is already gone, write SCAN_TABLE_REASONS_LOST | named={n} | reject={n} and stop
The 11 reject reasons from 2026-10-07 stay lost. Do not reconstruct the names.

NO extra delta for the routine doors, the 09:31 hunt clock, Δ40, the 11:30 VOID_TIME,
  Δ17, Δ37, Δ41, Δ25, the week line, Sleeve A, or the unsigned proposals.
  09:35–11:30 = 10m_early. 11:30–15:05 = 25m_mid. 15:05–16:00 = 10m_lasthour.
  10:09→10:35 = 26m is 10m_early and HEAL_LATE. Do not call it the 25m mid door.
  Also OVER_DOOR, not HEAL_LATE: 09:53→10:07 = 14, 10:35→10:53 = 18,
    10:53→11:08 = 15, 11:08→11:27 = 19.
  15:09→15:22 = 13 and 15:36→15:50 = 14 are 10m_lasthour OVER_DOOR, not HEAL_LATE.
  Do not invent a 满仓盯 crontab. Do not widen 10m to 25m. Do not shorten 10m.
  开盘猎 stays 31 9 * * 1-5. 10:00 review stays 0 10 * * 1-5.
  OPEN_AUDIT stays, CRON_TZ=America/New_York, weekdays:
    12 9 * * 1-5
    14 9 * * 1-5
    15 9 * * 1-5
    19 9 * * 1-5
  2026-10-07 spawn 09:24 and content DONE 09:32 are inside 09:30–09:35.
  Do not add a fifth fire. Do not move these four.
  11:30 VOID_TIME on BKH-BO-RETEST stays. Do not extend the prefer window to catch 76.435.
  Written risk at the limit is (76.45−75.85)×44 = 26.40. That loss was not realized.
  EOD HUNG empty. No Δ17 expire.
  2026-10-07 had one complete round. Δ37 does not fire on 2026-10-08.
  Week W/C 10/05 is raw 154.64 / qualified 141.00.
  paper-capital says OPEN. The six-section says qualified is already past 100 and the week closes Friday.
  Do not mark the week HIT on Wednesday.
  2026-10-08 is 8 calendar days before 2026-10-16. Δ9's ≤7 does not fire.
  The six-section's "7 trading days" is not the Δ9 unit.
```
