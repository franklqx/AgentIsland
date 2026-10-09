# PROCESS-PATCHES delta — 2026-10-09 EOD

粘贴位置：现有 `PROCESS-PATCHES` 末尾，Δ61 之后。不改写 Δ38–Δ61。不替换 Patch 1–6。不替换 Δ7–Δ61。不放宽任何旧门。冲突时更严者生效。

纸面 TRAIN3000 / 7474。真钱两确认仍有效。不是选股。不是实盘订单。不碰 ••••1429。不调用 `place_*`。

不回改 2026-10-05、2026-10-06、2026-10-07、2026-10-08 的成交价、出场价、合格标记、已实现盈亏、现金。不给 2026-10-09 补一笔成交。

C / `T1=SL2COST_RIDE_T2` / `T1_DEFAULT_MODE` 仍是 **PROPOSAL · 未签字 · 不生效**。`NO_OVERNIGHT_MFE_075R_SL_COST` 仍未签字。`VOID_TIME_EXTEND_15M`、同一天把触发价改低、正数 `RETEST_TOL` 仍未签字。本文件不新增放宽提案。

Δ61 保持生效。单腿在过完全门之后可以挂。`$200` 仍是结果目标，不是入场门槛。本文件不恢复「单腿且 t1$≤200 不挂」。

## 生效状态索引 · 2026-10-09 EOD（Δ62–Δ66）

- **Δ62 BRIEF_PLAN_AND_OPEN_UNSCANNED — IN FORCE（收紧）。** 简报已在盘上且还没有 PLAN 时，下一跳先写最多 3 条 PLAN，或写明简报里没有价位。09:40 以后扫描表仍是空的，先写 `OPEN_UNSCANNED`。不新造 `PRE_ARMED`。不在这一跳放宽升格条件。
- **Δ63 RETEST_WINDOW_MIN — IN FORCE（收紧）。** 回踩几何挂出时 `TIME_LEFT≥20`，否则不挂。当前 5 分钟棒的收盘已经贴上 VOID_TIME、触发还没打印，当跳作废。20 分钟这一款不拒绝 10/09 的 AMT（当时是 40）。不把回踩改写成突破单。
- **Δ64 HEARTBEAT_UNION_LAST_HOUR — IN FORCE（收紧）。** 盘中每一跳写心跳文件。间隙按全部心跳计算。15:05–15:55 的保底钟在已有 10 分钟内心跳时跳过。不改 `HEAL_LATE` 和 30 分钟上报的阈值。不重写未知的满仓盯 crontab。
- **Δ65 SLEEVE_A_EXPIRY_WATCH — IN FORCE（收紧，只记录）。** Sleeve A 到期不超过 7 个日历日时，每一跳写 `EXPIRY_WATCH`。不新写出场，不改 CRWD 的 14.73，不把 Δ30 / Δ34 套到 Sleeve A 上。
- **Δ66 HEALTH_TOKEN_LATE_IS_NOT_DOWN — IN FORCE（收紧，令牌）。** shell 能执行的晚到写 `BOX_HEALTH_LATE | shell=OK`。三份以上早盘作业一起晚，写 `SCHEDULER_SKEW`。07:48 CST 昨日报没送到，写 `MORNING_BRIEF_MISS`。不把晚到写成 `shell=FAIL`。
- **不新编号：** 11:30 的 VOID_TIME；触发价改低；`RETEST_TOL=0`；日底线 $200；停手 −$100；t1$≥40；1.5×；最多 3 腿；`NO_OVERNIGHT`；Δ61；10/05–10/08 的已入账价格；`gap_min>30` 才上报；开盘猎 `31 9`；10 点复查 `0 10`；开盘审计四行。

## 结论

2026-10-09 TRAIN3000 零成交。合格 $0，差额 $200，最大亏损 $0，腿 0/3，日目标 MISS。

差额的构成：唯一过闸的 AMT，t1$ = 40.68。即便按写下的 t1 出场，仍差 159.32。这 40.68 也没记上，因为回踩触发落在 11:30 那根 bar。流程延迟没有另一笔写在附件里的美元。止损贡献 0。

新规则只做收紧或只做记录：

- Δ62：已到的简报要变成不占现金的计划；开盘没人扫，要有一行令牌。
- Δ63：回踩窗口在数学上没了，就当跳作废。今天这张票的 40 分钟不被 20 分钟门槛拒绝。
- Δ64：心跳文件合并进间隙。末小时有保底钟。
- Δ65：CRWD 到期周每一跳有一行钟。不下单。
- Δ66：晚到和 shell 失败用不同的词。晨报失败要有对账行。

## Δ62. BRIEF_PLAN_AND_OPEN_UNSCANNED（简报落到 PLAN；没扫描要有令牌）

小头狼简报 mtime 09:17 ET，早于 09:25，journal 标了 `LITTLEWOLF_OK`。09:23 满仓盯跑了，写的是盘前 `RESCAN_SKIP`，没有 PLAN。Δ56 的计划写在 09:12 预热上，这天预热 09:43 才跑。第一张扫描表是 09:54。09:30–09:54 没有 asof 行。

桌面建议用一个叫 `PRE_ARMED` 的状态。本条不新造状态。PLAN 已经是「不挂、现金 0、不算成交腿」。多一个名字就会被读成可以成交。

- 适用范围：TRAIN3000 的计划行和扫描表。Sleeve A 不在本条。已经 VOID 的 10/09 AMT 不重写。
- IF 当天小头狼简报文件已在盘上 AND 当前没有 TRAIN3000 PLAN AND 当前没有 HUNG AND 时刻早于 11:30 THEN 本跳在任何从零拒绝之前，写下最多 3 条 PLAN，或写 `BRIEF_NO_LEVELS | plans=0`。
- 每一条 PLAN：标的只能来自简报里已经写了价位的名字。状态是 PLAN，不是 HUNG，不是 OPEN，`cash_reserved=0`，不计入 Δ53。还没有 RTH 同棒三价时写 `PENDING_RTH`。不得把语音转写未核实的数字写入 `ENTRY_GEOM`。简报里没有标的价位，就写 `BRIEF_NO_LEVELS`，计划数是 0。不得从宏观句子里提取名字。
- 09:12 预热仍是 Δ56 的原主。它晚了，不免除已经在跑的那一跳。09:23 这种按时的满仓盯，看见简报在、PLAN 还是 0，就欠这最多 3 行。
- IF 时刻 ≥09:40 ET AND 当天 `state/scan-table-YYYY-MM-DD.md` 没有任何 asof 行 THEN 本跳 sleep 前写 `OPEN_UNSCANNED | asof={HHMM} | scan_rows=0`。
- IF 本跳是满仓盯或开盘猎 THEN 同一跳还要写下扫描表（全门，不强制挂单）。IF 本跳是开盘审计、BOX_HEALTH 或小头狼截止 THEN 只写 `OPEN_UNSCANNED`，不猎票。
- 审计、机器检查、简报截止的 journal 行不能把 `OPEN_UNSCANNED` 清掉。清掉它的是一张真正的扫描表 asof 行。
- IF 之后要把 PLAN 升成 HUNG THEN 在那一跳重过硬催化、结构、同棒三价、恰好一个 Δ34、恰好一个 Δ43、一行 Δ47、`t1_dollars≥40`、`t1_dollars≥1.5×stop_dollars`、`stop_dollars≤RISK_BUDGET`、一次一腿。不足 60 分钟还要有 `TIME_LEFT`。Δ61 允许只剩一腿时挂出，并写 `FLOOR_PATH=SINGLE_OK_SEEK_NEXT`。没过的保持 PLAN 或放弃。不得用 09:12 或简报里的盘前价代替同棒三价。
- 10/09 不补写一套盘前 PLAN，不把 AMT 的挂出时间改到 09:23，不把 40.68 写入 pnl。
- **Do not:** 把 PLAN 或任何新状态当成可以成交。**Do not:** 为了填上 09:30–09:54 而延长 11:30。**Do not:** 没有价位也编一张票。**Do not:** `place_*`。

## Δ63. RETEST_WINDOW_MIN（回踩要留得下窗口；贴上作废时刻就当跳作废）

`AMT-SPCX-RANGE-BO-RT-1009` 10:50 ET 挂出。mode 是 `RETEST_AFTER_TRIGGER`，触发是 5 分钟收盘 >180.44，然后限价 ≤180.44，`RETEST_TOL=0`。`TIME_LEFT=40`。Δ57 的记录义务已经履行。40≥20。

10:45–11:20 的最高 5 分钟收盘是 179.99。180.44−179.99 = 0.45，触发没有打印。11:25 那根收 180.775，收盘时刻是 11:30，等于 VOID_TIME。回踩窗口是 0。11:26 的扫描已经写下这件事，票仍挂到 11:31 的 `EXPIRED_1130`。11:31 last 181.14，没有追。

桌面建议的「不足 20 分钟就不挂回踩」收的是下一次晚挂。它收不到今天这张：40 不小于 20。本条两款都要。第一款管下一次。第二款管「窗口在数学上已经没了还占着唯一的 HUNG」。

第二款若用在 11:26，成交结果仍是没有。不把 40.68 入账。那时只剩 4 分钟，空出来的顺序槽也挂不成下一张要 20 分钟的回踩。本条不把 10/09 收成 HIT。

- 适用范围：本跳要写成 HUNG 的 TRAIN3000 回踩票，以及已经 HUNG、触发还没打印的回踩票。Sleeve A 不在范围内。10/09 的 ledger 行不改。
- IF mode=`RETEST_AFTER_TRIGGER` AND 挂出时刻到写下的 VOID_TIME 不足 20 分钟 THEN `TIME_LEFT_GEOM_FAIL | {id}`。这张回踩不得挂，不得 sleep 在这行之前。`TIME_LEFT` 仍要按 Δ57 写上。两行一起出现时，`TIME_LEFT_GEOM_FAIL` 否决挂出。
- 同一跳若改写为 `TRIGGER_BAR`，必须本跳自己写出 `ENTRY_GEOM`，并且 `L_minus_X>0`、`L_minus_X≥spread`、同棒三价、t1$≥40、1.5×、额度、Δ34、Δ43 全部通过。缺一就不得挂。不得为了接住已经打到的价格，把一张回踩票改成突破票。
- IF 一张回踩 HUNG 的触发尚未打印 AND 当前这根 5 分钟棒的收盘时刻 ≥ 这张票写下的 VOID_TIME THEN 同一跳作废：`VOID | RETEST_WINDOW_GONE | {id}`。不等这根棒收完。不把这根棒的高点或收盘写成触发。不追。ledger 的 VOID 行当跳写，exit 和 pnl 空白。
- 10/09 的已知事实只作例子，不回写：11:26 那跳符合第二款。账上保持 11:31 的 `EXPIRED_1130` voided 行。禁止把 180.775、181.14 或 40.68 写成成交。
- `TIME_LEFT` 本身仍不延长 VOID_TIME。`RETEST_TOL` 仍是 0。正数容差仍是 **PROPOSAL · 未签字 · 不生效**。
- **Do not:** 用 20 分钟去宣称今天的 AMT 本来不该挂、所以可以补一笔别的成交。**Do not:** 把触发改低来让 179.99 打印。**Do not:** 把 11:30 延后去等回踩。**Do not:** `place_*`。

## Δ64. HEARTBEAT_UNION_LAST_HOUR（全部心跳进间隙；末小时保底）

10 点复查 asof=1038，下一跳手动满仓盯 10:50。12 分钟，早盘门 10 分钟。盘中没有 `ROUTINE_GAP`。EOD 写这两跳不写 manchang 文件，间隙只看例程文件。EOD 复算补了这行。本条不把补记改成盘中已报。

15:04→15:19 是 15 分钟，15:36→15:56 是 20 分钟。门是 10 分钟。两段都写了 `ROUTINE_GAP`。15≤20，20 等于 door+10，`HEAL_LATE` 的条文是严格大于，所以没写 `HEAL_LATE`。标签符合现行 Δ26 / Δ58。门仍然破了。Sleeve A 还在持仓。满仓盯的 crontab 原文不在本包，不新造一整张时刻表。

- IF 任一纸面例程在 09:20–16:10 ET 醒来 THEN sleep 前写 `state/YYYY-MM-DD-HHMM-manchang.md`，至少一行：`asof={HHMM} | kind={作业名} | open={n} | hung={id 或 0} | sleeve_a_checked={Y|N}`。10 点复查、手动满仓盯、开盘猎、开盘审计、BOX_HEALTH、小头狼截止都算。
- 间隙的输入是这些文件的并集，加上 journal 里的跳点。只看例程满仓盯文件、因而漏掉另一跳，写成 `HEARTBEAT_BLIND | from={ } | to={ }`。漏看不算已报。
- IF 按并集算出的 gap 大于当时的门 THEN 后一跳先写 `ROUTINE_GAP | {from}→{to} | gap_min={ } | door={ }`，再做别的。门仍是：后一跳落在 09:35–11:30 = 10 分钟；11:30–15:05 = 25 分钟；15:05–16:00 = 10 分钟。`gap>door+10` 仍是 `HEAL_LATE`。`gap_min>30` 仍是 `ROUTINE_GAP_ESCALATE`。两个阈值都不改。
- 没有扫描表的审计行不能用来把猎票间隙清成 0。Sleeve A 的止损若在这一跳查了，`sleeve_a_checked=Y`，这一跳可以清 Sleeve A 的盯盘间隙。TRAIN 的扫描间隙要有扫描表 asof 才清。
- 新 cron：`5,15,25,35,45,55 15 * * 1-5`，`CRON_TZ=America/New_York`。IF 最新心跳文件的年龄 ≤10 分钟 THEN 本跳只写 `LAST_HOUR_RESERVE | SKIP`。ELSE 用只读券商期权报价给 Sleeve A 标价（`MARK_SRC=RH_OPTION`），写心跳文件，并写 `ROUTINE_GAP`。这一跳不挂 TRAIN，不调用 `place_*`，不把缺价编成一个 mark。
- 10/09 的 1038→1050 保持「盘中未报、EOD 补记」。不回溯补一张 10:50 的心跳文件来覆盖这个事实。
- **Do not:** 把 10 分钟门改成 15 或 20 来让这两段看起来合法。**Do not:** 把 `gap>30` 改成 `gap≥29` 去追究 11:40→12:09 那 29 分钟。那一段已经按 25 分钟门写了 `ROUTINE_GAP`，29≤30，不上报。阈值保持。**Do not:** 重写未知的满仓盯 crontab。**Do not:** `place_*`。

## Δ65. SLEEVE_A_EXPIRY_WATCH（到期周每一跳有一行钟；不新写出场）

CRWD Oct16 220C×2，成本 14.73，止损是 SL→COST。收盘 mark 54.625（53.65/55.60），uPnL +7,979，CLEAR。EOD 写到期日 2026-10-16，RH sellout **15:30 ET**。10/09 到 10/16 是 7 个日历日。journal 16:05 的正股 274.65 高于行权价 220，不是 OTM。Δ9 的「≤7 个日历日且 OTM」这一款今天不触发。Δ30 / Δ34 明文不用于 Sleeve A。

附件里没有一行把 15:30 的券商卖出写成每一跳都要看见的钟。本条只加这行。不加出场，不改 14.73，不把 TRAIN 的 −$100 或 $200 套到这张票上。

- 适用范围：Sleeve A 里、到期日减当天 ≤7 个日历日的期权。TRAIN3000 不在范围内。
- IF 该条件成立 THEN 每一跳纸面例程写：`EXPIRY_WATCH | symbol={ } | exp={YYYY-MM-DD} | dte={ } | mark={ } | mark_src=RH_OPTION | stop={写下的止损} | stop_state={CLEAR|HIT|NO_DATA} | broker_sellout={YYYY-MM-DD HH:MM ET 或 NONE}`。
- CRWD 的 `stop` 保持 14.73。`broker_sellout` 写 `2026-10-16 15:30 ET`。10/12 的 dte = 4。10/13 = 3。10/14 = 2。10/15 = 1。10/16 = 0。
- IF 这一跳没有只读期权报价 THEN `mark` 空着，`stop_state=NO_DATA`。这不是止损命中，不是平仓，不是 `DAY_LOSS_STOP`。不得编一个 mark。
- AAPL Nov20 340C 在 2026-10-12 的剩余日历日大于 7，不写 `EXPIRY_WATCH`。它的止损仍是权利金 ≤7.20 或正股 ≤320，每一跳照旧标价。
- 新 cron：`0 15 * * 1-5`，同一时区。IF 当天没有 Sleeve A 合约到期 THEN `EXPIRY_DAY_MARK | SKIP`。IF 有 THEN 15:00 ET 写上面的 `EXPIRY_WATCH`。2026-10-16 这一跳必须跑，在写下的 15:30 卖出之前 30 分钟。它仍然不下单，不改止损，不调用 `place_*`。
- **Do not:** 把本条读成卖出 CRWD。**Do not:** 把 14.73 改紧或改松。**Do not:** 套用 Δ30 的 15:40 强平。**Do not:** 用 Sleeve A 的浮盈去填 TRAIN 的 $200。**Do not:** `place_*`。

## Δ66. HEALTH_TOKEN_LATE_IS_NOT_DOWN（晚到不是 shell 失败；晨报要有对账）

09:20 的作业 09:50 才跑。journal 写 `BOX_DOWN | shell=FAIL(LATE)`，同一段又写 09:50 时 shell 和 journal 读写正常。晚 30 分钟成立。`shell=FAIL` 不成立。

早盘作业的正文有两句汇总：「统一晚 28–31 分钟」，以及更正后的「统一晚 28–37 分钟」。逐项相减：预热 +31，开盘审计 +31，补门 +26，oneshot +31，BOX_HEALTH +30，小头狼截止 +27，开盘猎约 +29（另有一套「无运行记录」），10 点复查 +37。最小值 +26，最大值 +37。+26 和 +27 不在「28」里。09:23 满仓盯不在这组里面。

这次平移发生在重启之前。09:58 ET 的笔记写当时没有重启。重启是下一件事：CEO 写约 10:14 失败、约 10:18 重启；journal 写约 10:18 重启、起机 10:24 ET。三套钟都留着。Δ66 不选一个折中时刻。

10/09 07:48 CST 的昨日报失败。09:20 那跳没有对账行。Δ58 的 16:30 保底继续管六段文件，不在本条改分钟，也不新编号。

- IF 09:20 的 BOX_HEALTH 晚于 09:20 才执行 AND shell 命令能跑完 THEN `BOX_HEALTH_LATE | planned=0920 | actual={HHMM} | shell=OK`。不得写 `shell=FAIL`。IF shell 命令失败 THEN 才写 `BOX_DOWN | {date} | 09:20 ET | shell=FAIL`，并给 CEO。10/09 若按本条重写令牌，应是 `actual=0950 | shell=OK`。不回改已经写下的 journal 行。
- IF 同一跳能看到三份或更多早盘作业、每份都晚了至少 10 分钟 THEN `SCHEDULER_SKEW | min={最小相减} | max={最大相减} | jobs={份数}`。`min` 和 `max` 用逐项相减，不用汇总句。09:23 这种没有晚的作业不要算进 `jobs`。
- IF 07:48 CST 的前一交易日晨报没有送到 THEN 同一跳再写 `MORNING_BRIEF_MISS | planned=0748CST`。10/09 这行当时没有写。10/12 的 09:20 要查本份有没有在 07:48 CST 送到。
- 一次整体的调度平移也会推迟任何新加的早盘 cron。本条不增加 09:40 的火钟，也不声称新钟能在同一次平移里准时。开盘没人扫，由当时已经在跑的那一跳按 Δ62 处理。
- **Do not:** 用 `SCHEDULER_SKEW` 去延长 11:30 或放宽 09:30–09:35 的审计窗。**Do not:** 把 10/09 的 09:45 审计写成窗内通过。**Do not:** 把三套重启钟收成一个数。**Do not:** `place_*`。

## 不新开

### 成交条件

不新编号，也不新提案。以下各项保持未签字、不生效，或保持现行更严的原文：

- `VOID_TIME_EXTEND_15M`。11:25 的收盘贴在 11:30 上，不是「差 0.3% 再延 15 分钟」那种边缘。即便延，回踩也要 11:30 之后的棒。本文件不签。
- 同一天把触发价改低。179.99 距离 180.44 还有 0.45。不得用这个差去改触发。
- `RETEST_TOL>0`。
- C，`T1=SL2COST_RIDE_T2`，`T1_DEFAULT_MODE`，`NO_OVERNIGHT_MFE_075R_SL_COST`。
- 日底线仍是合格严格大于 200。停手仍是 −100。每腿 t1$ 仍 ≥40，仍 ≥1.5×止损。最多 3 腿。一次一腿。`NO_OVERNIGHT`。不为凑数提前平仓。

### Δ61

不新编号。2026-10-09 08:28 CST 已签。AMT 的 `FLOOR_PATH=SINGLE_OK_SEEK_NEXT` 符合这一条。10/08 复盘里「单腿且 t1$≤200 不挂」被 Δ61 取代。10/12 不得把那句写回票上。单腿挂出之后仍要继续找后续腿。后续腿门槛不降。找不到就接受 MISS。

### 已入账的价格

不新编号。10/05 的 ledger 行保持 raw +13.64、qualified=0。10/06 +42.00 qualified。10/07 +99.00 qualified。10/08 两行 voided。10/09 一行 voided。EOD 把周合计 $154.64 叫成「合格已实现」。按 ledger 的合格标记，周合格是 $141.00，周 raw 是 $154.64。两套都留。不改任何一行的 pnl，不改 qualified 标记。

### 间隙阈值与锚点

不新编号。

- 上报仍是 `gap_min>30`。11:40→12:09 的 29 分钟已写 `ROUTINE_GAP`，不上报。不把阈值改成 ≥29 或 ≥30。
- `HEAL_LATE` 仍是 `gap>door+10`。15:36→15:56 的 20 分钟等于 10+10，不写 `HEAL_LATE`。不把「大于」改成「大于等于」来追认这一段。末小时的保底钟在 Δ64，用来减少下一次破门，不用来改门。
- 开盘猎仍是 `31 9 * * 1-5`。10 点复查仍是 `0 10 * * 1-5`。10/09 的晚跑不把锚移到 10:00 或 10:37。
- 开盘审计四行仍是 09:12 / 09:14 / 09:15 / 09:19。内容窗仍是 09:30–09:35。10/09 的 09:45 是 `OPEN_AUDIT_LATE`。不得写 `CRON_REBUILD_VERIFY | status=CLEAR`。不加第五个审计火钟。
- Δ37 的接受行字面是 `DAY_GOAL_MISS_ACCEPT`。10/09 写的是 `ACCEPT_NO_HANG`，同时有 `EMPTY_DAY_CLOCK`。10/12 若接受，写字面那一行，`prior_empty_date=2026-10-09`。不新编号。
- Δ49 / Δ50：10/09 的 VOID 当跳进了 ledger，扫描表只追加。不新编号。
- 真钱。附件全程 $3,064.83，仓空，当日已实现 $0。本复盘未调用券商。

## 交给主 agent 的 cron

时区一行写在 crontab 上。下面除标明「新」的两行，其余都是原样保持。满仓盯的原文不在本包，不要为了本文件去重写它。

```
CRON_TZ=America/New_York

# OPEN_AUDIT · Δ40 · 不改分钟 · 不要标 CLEAR
12 9 * * 1-5
14 9 * * 1-5
15 9 * * 1-5
19 9 * * 1-5

# 开盘猎 / 10点复查 · 不改
31 9 * * 1-5
0 10 * * 1-5

# Δ58 / Δ60 · 已有 · 不改
20 9 * * 1-5
25 9 * * 1-5
30 16 * * 1-5

# 新 · Δ64 LAST_HOUR_RESERVE · 最新心跳 ≤10 分钟则 SKIP
5,15,25,35,45,55 15 * * 1-5

# 新 · Δ65 EXPIRY_DAY_MARK · 当天没有 Sleeve A 到期则 SKIP
0 15 * * 1-5
```

Δ62 不加钟。它绑在已经会跑的那一跳上，包括按时的 09:23 满仓盯和迟到的 09:12 预热。Δ66 不加钟。它改的是 09:20 那跳写出的令牌。

## 粘贴块

```
# DELTA 2026-10-09 EOD — append after Δ61.
# On conflict, stricter wins. Do not loosen Patch 1–6 or Δ7–Δ61.
# Paper 7474 only. No place_*. Do not touch account 1429.
# Do not reprice 2026-10-05 through 2026-10-08, or invent a 2026-10-09 fill.
# C / T1=SL2COST_RIDE_T2 / T1_DEFAULT_MODE / NO_OVERNIGHT_MFE_075R_SL_COST stay unsigned.
# VOID_TIME_EXTEND_15M, any lower trigger, and RETEST_TOL>0 stay unsigned.
# No new loosening proposal in this delta.
# Δ61 stays in force. A single leg that passes every gate may hang.

Δ62 BRIEF_PLAN_AND_OPEN_UNSCANNED
IF the day's littlewolf brief is on disk AND PLAN=0 AND HUNG=0 AND the clock is before 11:30
THEN before a from-scratch reject scan write at most 3 PLAN rows, or BRIEF_NO_LEVELS | plans=0
  status=PLAN, not HUNG, not OPEN, cash_reserved=0, not a Δ53 fill-leg
  names only if the brief already gives a level
  same-bar three prices = PENDING_RTH until an RTH bar exists
  do not copy an unverified transcript number into ENTRY_GEOM
  do not invent a status named PRE_ARMED
IF the 09:12 warmup is late
THEN the first wake that already ran still owes those PLAN rows
IF the clock is ≥09:40 AND today's scan table has no asof row
THEN OPEN_UNSCANNED | asof={HHMM} | scan_rows=0
  满仓盯 and 开盘猎 also write the scan before sleep
  OPEN_AUDIT, BOX_HEALTH, and the littlewolf deadline only write the token
  a non-scan journal line does not clear OPEN_UNSCANNED
IF a later wake promotes a PLAN to HUNG
THEN re-pass catalyst, structure, same-bar three prices, Δ34, Δ43, Δ47,
  t1_dollars≥40, 1.5×, RISK_BUDGET, and one-leg-at-a-time
  Δ61 still allows a single leg
Do not hang on the plan-writing wake unless that same wake is a hunt and every gate passes.
Do not extend 11:30. Do not book 40.68. Do not place_*.

Δ63 RETEST_WINDOW_MIN
IF mode=RETEST_AFTER_TRIGGER AND TIME_LEFT<20
THEN TIME_LEFT_GEOM_FAIL | {id}
  do not hang that retest. do not sleep before the line
  a TRIGGER_BAR rewrite needs its own Δ47 on this wake
  do not flip a retest into a breakout to catch a print
IF a RETEST HUNG is still untriggered AND the current 5m bar closes at or after the written VOID_TIME
THEN VOID | RETEST_WINDOW_GONE | {id} on that same wake
  do not wait for that bar. do not chase. exit and pnl stay blank
2026-10-09 AMT had TIME_LEFT=40, so the 20-minute clause would not have refused the 10:50 hang.
The 11:26 wake already noted that a trigger on the 11:25 bar closes at 11:30.
That wake owed RETEST_WINDOW_GONE. The booked row stays the 11:31 void.
Do not fill 180.775 or 181.14. Do not book 40.68.
TIME_LEFT does not extend VOID_TIME. RETEST_TOL stays 0.

Δ64 HEARTBEAT_UNION_LAST_HOUR
IF a paper wake runs between 09:20 and 16:10 ET
THEN write state/YYYY-MM-DD-HHMM-manchang.md
  asof={HHMM} | kind={job} | open={n} | hung={id or 0} | sleeve_a_checked={Y|N}
Gap input is the union of those files plus journal wake times.
IF the gap script ignores a non-routine file
THEN HEARTBEAT_BLIND | from={ } | to={ }
  a blind gap is not a reported gap
IF the union gap is greater than the live door
THEN ROUTINE_GAP before other work
  doors stay 10m / 25m / 10m
  HEAL_LATE still means gap>door+10
  ROUTINE_GAP_ESCALATE still means gap_min>30
  do not change either threshold
A scan gap clears only when a scan-table asof row exists.
New cron, CRON_TZ=America/New_York, weekdays:
  5,15,25,35,45,55 15 * * 1-5
  IF the newest heartbeat is ≤10 minutes old THEN LAST_HOUR_RESERVE | SKIP
  ELSE mark Sleeve A read-only, write the heartbeat, write ROUTINE_GAP
  do not hang. do not place_*
Do not rewrite the unknown 满仓盯 crontab.
Do not relabel the 10/09 1038→1050 gap as logged live.

Δ65 SLEEVE_A_EXPIRY_WATCH
IF a Sleeve A option expires within 7 calendar days
THEN every paper wake writes
  EXPIRY_WATCH | symbol={ } | exp={ } | dte={ } | mark={ } | mark_src=RH_OPTION | stop={written} | stop_state={CLEAR|HIT|NO_DATA} | broker_sellout={ }
CRWD Oct16 220C keeps stop 14.73 and broker_sellout=2026-10-16 15:30 ET.
A missing quote is NO_DATA. It is not a stop hit and not a flatten.
AAPL Nov20 340C is outside this line on 2026-10-12. Its stop stays 7.20 / stock 320.
New cron, same timezone, weekdays:
  0 15 * * 1-5
  SKIP unless a Sleeve A contract expires that session
  2026-10-16 must write the line at 15:00 ET
Do not sell CRWD. Do not change 14.73. Do not apply Δ30 or Δ34. Do not place_*.

Δ66 HEALTH_TOKEN_LATE_IS_NOT_DOWN
IF the 09:20 BOX_HEALTH wake runs late AND the shell executes
THEN BOX_HEALTH_LATE | planned=0920 | actual={HHMM} | shell=OK
  do not write shell=FAIL
IF the shell command fails
THEN BOX_DOWN | {date} | 09:20 ET | shell=FAIL
IF three or more morning jobs are each ≥10 minutes late
THEN SCHEDULER_SKEW | min={ } | max={ } | jobs={ }
  min and max are the per-job subtractions, not the prose range
  2026-10-09 per-job range is +26 to +37
  the prose said 28–31 and later 28–37
IF the 07:48 CST prior-day brief was not delivered
THEN MORNING_BRIEF_MISS | planned=0748CST
Do not add a 09:40 cron. A uniform scheduler skew would move it too.
Do not widen 09:30–09:35. Do not extend 11:30. Do not place_*.

NO extra delta for VOID_TIME, a lower trigger, RETEST_TOL, the $200 floor,
  the −$100 stop, t1$≥40, 1.5×, the 3-leg cap, NO_OVERNIGHT, or Δ61.
  Do not restore "a single leg with t1$≤200 is not hung".
  Do not reprice 2026-10-05 through 2026-10-08.
  Week raw through 2026-10-09 is $154.64. Week qualified on the ledger marks is $141.00.
  Keep both. 10/05 stays qualified=0.
  gap_min>30 stays the escalate test. gap>door+10 stays HEAL_LATE.
  开盘猎 stays 31 9 * * 1-5. 10:00 review stays 0 10 * * 1-5.
  OPEN_AUDIT stays:
    12 9 * * 1-5
    14 9 * * 1-5
    15 9 * * 1-5
    19 9 * * 1-5
  Do not write CRON_REBUILD_VERIFY status=CLEAR.
  2026-10-12 is a Δ37 day because 2026-10-09 closed qualified 0, zero rounds, MISS.
  An accept line that day includes DAY_GOAL_MISS_ACCEPT | prior_empty_date=2026-10-09.
```
