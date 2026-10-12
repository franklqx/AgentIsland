# PROCESS-PATCHES · 2026-10-12 EOD 增量

状态：全部是 **`PROPOSAL · 待 CEO 签字`**。签字前例程不得执行，不得摘进 `RULES-ACTIVE.md`。

来源复盘：`reports/agentic-daily/2026-10-12-cursor.md`。已签字条款止于 Δ66。本文件从 **Δ67** 起。

这些条款只服务一件事：TRAIN3000 纸面更稳定地做出合格利润 > $200，同时当天已实现 + 浮亏不到 −$100。不荐股，不写 `place_*` / `cancel_*` / `exercise_*`，不改 10/05–10/12 已记账数字。真钱 ••••7474 仍只读。

采纳之后的源文件是桌面上的 `reports/agentic-daily/PROCESS-PATCHES.md`。本仓库这份只是提案。

## 索引

| 编号 | 名称 | 对着今天的哪条失败 | 和 $200 / −$100 的关系 |
|---|---|---|---|
| Δ67 | OR 收盘后复扫「5m 未完成」的拒绝 | 09:32 整批 `NO_SETUP`，09:36 只改了两个 PLAN | 硬催化名字在 11:30 前还有一次完整闸门。不放宽任何门槛 |
| Δ68 | `reach_x>2` 时 HUNG 必须带 11:30 时间出场 | t1 要走 $2.12 = 2.30× OR，槽位占到 15:40 | 远目标仍可挂；11:30 未到 +1R 就还槽，下午按全闸门找下一腿。原止损不动 |
| Δ69 | HUNG 同 wake 四件套；例程禁止回溯成交 | 09:36 缺几何、缺心跳；10:05 回溯成交；10:22 账本缺件 | 当时不可成交的票不能占住唯一槽位 |
| Δ70 | `SCHEDULER_SKEW` 必须落字，wake 当场读简报和开盘审计 | 早盘任务各晚 18–34 分钟；09:07 误写 `BRIEF_NO_LEVELS`；token 没写 | 开盘前 ≤3 个 PLAN 不因 cron 漂移整段消失 |
| Δ71 | 心跳带 gap 字段；缺字段由下一 wake 补分类 | 1053→1114 的 21 分钟应 `HEAL_LATE` 未标；0952→1004 的 12 分钟未标 | 有持仓的超时缺口先查止损，避免漏记穿 −$100 的打印 |

签字可以拆开。每一条单独成立。Δ68 和 Δ69 一起才避免「远目标票在缺几何的情况下锁整天」。Δ70 单独不能还槽：简报找回来以后，若错误的 HUNG 还在，一次一腿仍会把新 PLAN 压住。

## 不写入本批的想法

日报 §5 的方向保留，下面几条不立项：

- 所有票可选写 `TIME_EXIT`。可选等于可以再漏。Δ68 把同一条款收成有条件的必填。
- 可行性比较「只记录、不产生任何动作」。Δ68 仍把比较记在 `FLOOR_FEASIBILITY`（Δ55：该行不否决），必填的时间出场写在票上。
- 按收紧后的止损把 t1 重算到 1.5×。今天止损距离 $0.98，1.5 倍是 $1.47，×19 的 t1$ 约 $27.93，过不了现有 $40。票会直接不成交，日目标没有更近。
- 为了 $0.02 滑点把 t1 再抬高。`reach_x` 会更大。挂单时 t1$ $40.28 已过 $40；成交后 $39.71 只作边界记录。
- 新的 15:38 cron。15:40 平仓用的是打印价，15:46 记账晚 6 分钟，pnl 未改。
- 把 Δ47 再抄一遍当新条款。Δ69 加的是「缺件就不是 HUNG」和「例程不得补成交」。
- 放宽 −$100、3 腿、t1$ ≥ $40、1.5×，或允许并发腿。`B-conc` 维持未生效。

---

## Δ67 · OR_CLOSE_RESCAN

**状态：** `PROPOSAL · 待 CEO 签字`

**目的：** 09:32 的拒绝里，有一批理由是首根 5m 还没走完、`ENTRY_GEOM` 不可用。09:36 OR 已经收完，这些名字没有被复看，全天只剩一张从盘前 PLAN 改出来的票。复扫让窗口内还有一次完整闸门，用来寻找能把日合格利润推向 $200 的后续候选。复扫不降低 t1$、$1.5×、止损额、催化、3 腿里的任何一条。

**触发条件：** 当日扫描表里，某一行的拒绝理由含 `bar5_range=UNAVAILABLE`，或写明 OR / 首根 5m 未完成。时钟已经走过 09:35 ET（09:30–09:35 这根 5m 已收盘），并且当天还没有 `OR_RESCAN_DONE`。

**写入：**

- 文件：`state/scan-table-YYYY-MM-DD.md`（只追加）。
- 同一 wake 的 journal 块。
- token（扫描表新块的第一行）：

```text
asof=0936 | OR_RESCAN_DONE | rechecked=<n> | still_reject=<n> | clear_to_plan=<n>
```

每个被复看的名字各一行，闸门与平时相同（硬催化、结构、同柱三价、t1$ ≥ $40、t1$ ≥ 1.5×止损额、`RISK_BUDGET`、Δ34、Δ43、Δ47）。不过闸门就保持拒绝，不挂单。

**动作：**

1. 复扫完成之前，这一 wake 不得把新名字写成 HUNG。只改盘前 PLAN 的价格、不复看未完成 5m 的名字，记 `OR_RESCAN_MISSING`，本 wake 的 HUNG 无效。
2. 复扫可以写出 ≤3 个 `status=PLAN`、`cash_reserved=0`。挂单仍走现有 HUNG 闸门，一次一腿。
3. 若开盘猎 cron 晚到，而且当天已经有一份开盘扫描表：晚到的那次写 `OPEN_HUNT_DUP_SKIP`，不再挂第二张票。若 `OR_RESCAN_DONE` 还没有，这次迟到的 wake 负责把复扫补上，而不是再猎一遍开盘。

**如何验证：**

- 用 2026-10-12 的扫描表回放：asof=0932 的 12 行里，拒绝理由含未完成 5m / `bar5_range=UNAVAILABLE` 的，必须出现在 asof=0936 的复扫块。当天 09:36 块只有 USO、XOM、CVX、OXY、SPY、QQQ，没有 `OR_RESCAN_DONE`。按本条款，09:36 对 XOM 的 HUNG 无效。
- 回放只检查 token 和「HUNG 是否允许」。不补任何成交，不改 ledger。
- 下一张真实交易日：09:36 之后的第一份扫描表能数出 `rechecked`，且 `rechecked` 等于 09:32 里「5m 未完成」的行数。

**今日回放：** 槽位不会在 09:36 被那张 ORB 占住。11:30 前还可以按全闸门看过一遍已经写了硬催化、只是当时没有 5m 的名字。看过以后仍然可以全部拒绝。那样合格利润仍是 $0，但失败方式是「看完了没有票」，不是「没看就锁整天」。

---

## Δ68 · REACH_TIME_EXIT

**状态：** `PROPOSAL · 待 CEO 签字`

**目的：** 日目标高于单腿 $40。一张 t1 远在 OR 之外的票，若只靠 15:40 的 `NO_OVERNIGHT` 出场，会把第 2、第 3 腿的时间全部用掉。本条款在这种票上强制一个 Δ23 已经允许的书面时间出场，11:30 若还没到 +1R 就平仓还槽。止损价不改，`RISK_BUDGET` 不改，−$100 的计算方式不改。未到 −$100 时，下一腿的门槛不降。

**触发条件：** 写 HUNG 时，结构用了当日 OR（ORB，或触发价取 OR 高/低），或者相对当天早先那张 PLAN 改过触发价或止损。

**定义（用票面价，不用成交后的滑点价）：**

- `or_width_pts` = OR 高 − OR 低
- `t1_pts` = t1 − 挂单价
- `reach_x` = `t1_pts / or_width_pts`
- `t1_dist_pct` = `t1_pts / 挂单价`
- `or_pct` = `or_width_pts / OR 高`
- `one_r` = 挂单价 +（挂单价 − 止损）
- 2 倍这条线来自今天的打印：t1 距离 $2.12，OR 宽 $0.92，`reach_x` = 2.30。1.5 已经是盈亏比门槛，不拿来再当距离门槛。

**写入：**

- 文件：当日 journal 的挂单块；同一块里的 `FLOOR_FEASIBILITY` 行（只记录，Δ55 不变）。
- token：

```text
REACH=t1_dist_pct=<x> | or_width_pts=<x> | or_pct=<x> | t1_pts=<x> | reach_x=<x> | t1_src=RECOMPUTED|STALE_CARRY | one_r=<px>
```

- 当 `reach_x>2` 时，同一挂单块还必须有：

```text
TIME_EXIT=11:30_IF_NOT_+1R
```

缺 `REACH`，或 `reach_x>2` 但缺 `TIME_EXIT`：不是 HUNG，记 `REACH_MISSING` 或 `TIME_EXIT_REQUIRED`。

**动作：**

1. t1 沿用改价前的旧目标时，`t1_src=STALE_CARRY`。允许挂，只要 `REACH` 写明，并且在 `reach_x>2` 时带上 `TIME_EXIT`。不要求把 t1 改近。
2. `TIME_EXIT` 只作用于已经 OPEN 的腿。未成交的 HUNG 仍由原有 `VOID_TIME` 11:30 作废。
3. 11:30 ET 那一 wake：若全天没有任何打印 ≥ `one_r`，按当时打印价全平，同一 wake 记账，合格利润 = 0。然后才允许按全闸门找下一腿（Δ24：11:30 后新腿要整闸重过）。若 +1R 已打印，走现有 Δ8（止损抬到成本），本条款不平仓。
4. 时间平仓记入当日已成交腿数（Δ53）。不增加第 4 腿。
5. 比较行不单独否决一张票。否决只来自缺 token，或来自现有的 $40 / 1.5× / 额度 / 催化闸门。

**如何验证：**

- 回放 2026-10-12 XOM 挂单价 171.93、止损 170.95、t1 174.05、OR 宽 0.92：`t1_pts=2.12`，`reach_x=2.30`，`t1_src=STALE_CARRY`（t1 与 09:31 的 174.05 相同），`one_r=172.91`。缺 `TIME_EXIT` 则 09:36 的 HUNG 不成立。
- 当天高点约 172.55，低于 172.91，也低于日报按成交价算的 +1R 172.97。若条款已生效且票上有 `TIME_EXIT`，11:30 的 wake 会平仓还槽。审查不编造 11:30 的成交价，也不把这笔未发生的平仓写进 ledger。
- 下一张交易日抽查：凡 `reach_x>2` 的 HUNG，journal 里能搜到同一 id 的 `TIME_EXIT=11:30_IF_NOT_+1R`。11:30 的 journal 要么写明已打印 +1R，要么写明按打印价平仓且合格 0。

**今日回放：** 这张票要么在 09:36 因缺 `TIME_EXIT` 挂不上去，槽位留在窗口内；要么挂上去，11:30 前若始终没有 +1R 就还槽。两种都给第 2 腿留出 Δ24 的整闸机会。止损额仍是约 $18.62，离 −$100 还有约 $81 的当日额度。

---

## Δ69 · HUNG_ATOMIC_NO_RETRO

**状态：** `PROPOSAL · 待 CEO 签字`

**目的：** 09:36 的 HUNG 缺几何、缺心跳，09:52 已经按规则 `NO_FILL`，10:04–10:05 又把几何和成交补回到 09:41。这张当时不可成交的票占住了全天唯一槽位，合格利润 $0，第 2 腿没有空间。本条款让缺件的挂单保持未挂，例程不能事后补上再成交。槽位留给过了闸门的票，−$100 也不会被一张几何不连贯的持仓占用。

**触发条件：** 任一 wake 要把纸面状态写成 HUNG，或发现 journal 里已有 HUNG 但同分钟的几何 / 心跳 / 扫描表对不齐。

**写入：**

- 文件：当日 journal 挂单块；`state/YYYY-MM-DD-HHMM-manchang.md`；`state/scan-table-YYYY-MM-DD.md`。三处的 `asof` 必须是同一分钟。
- 挂单块必有的 token（缺一则本 wake 不得写 HUNG）：
  - 现有 Δ47：`ENTRY_GEOM= mode=... | L= | X= | L_minus_X= | bar5_range= | spread=`（点差用这一根的 ask−bid，禁止事后补）。
  - 现有 Δ34 / Δ43：`NO_OVERNIGHT` 或另两种过夜条款之一；`T1=EXIT_ALL`。
  - 新增：`CATALYST=<与当日扫描表同一句结论>`。该符号在扫描表上的最新一行若是催化 `REJECT`，不得 HUNG，记 `CATALYST_CONFLICT`。要改口，先追加一行新的扫描结论，再挂。
  - 新增：`HUNG_BUNDLE=geom=Y | heartbeat=Y | scan=Y | journal=Y`。
- 心跳文件就是现有 manchang 行（Δ64），`asof` 等于挂单分钟。

**动作：**

1. 四件套不齐：状态留在 PLAN 或空仓，`cash_reserved=0`，记 `HUNG_INCOMPLETE | missing=<字段>`。下一 wake 只作废这张未完成挂单，不补 `ENTRY_GEOM`，不按更早的 K 线记成交。
2. 例程禁止 `RETRO_FILL`。成交只能来自「完整 HUNG 已经落盘之后」才打印的触发。缺几何期间的 `NO_FILL` 保持有效。
3. CEO 若仍要覆盖，必须另写一行，例程不得代写：

```text
CEO_OVERRIDE_FILL | id=<id> | reason=<一句话> | geom_was=MISSING | fill_px=<打印价> | fill_time=<ET>
```

没有这一行，wake 写 `RETRO_FILL_REFUSED`，ledger 不增行。有这一行时，同一 wake 在睡前写齐 journal、ledger、state，并写：

```text
BOOK_OK | journal=Y | ledger=Y | state=Y
```

缺 ledger 则 journal 不写 `FILL`，改写 `FILL_HELD_FOR_BOOK`。下一 wake 按现有 `BOOK_TRIPLE_MISS` 只从已约定的打印价补账，不新造价格。
4. 覆盖成交不豁免 Δ68。`reach_x>2` 而票上没有 `TIME_EXIT` 时，覆盖 wake 也不得把状态留成 OPEN；写成 VOID，原因 `TIME_EXIT_REQUIRED`。
5. 本条款不新开下单接口。成交仍是记账。

**如何验证：**

- 回放 09:36：无 `ENTRY_GEOM`、无 `0936` 心跳、扫描表最新催化行仍是 `REJECT`。三处都会让 HUNG 不成立。09:52 的 `NO_FILL` 与本条款一致。10:04 补几何、10:05 按 09:41 记账，在没有 `CEO_OVERRIDE_FILL` 的情况下应是 `RETRO_FILL_REFUSED`。
- 价格冲突留在复盘里，不选边：扫描表 5m 收盘 171.93，日报写 172.03，ledger 成交 171.96 @09:41。条款生效后，挂单分钟必须写下同柱三价，避免再出现三个数。
- 下一张交易日：每条 HUNG 都能在同一分钟找到几何行、manchang 文件、扫描表 `asof`。任一 `FILL` 的上一行 HUNG 具备 `HUNG_BUNDLE` 四个 Y，或具备 `CEO_OVERRIDE_FILL` 加同一 wake 的 `BOOK_OK`。

**今日回放：** 例程路径下这张票不成交，1/3 的腿额留着，10:22 的 `BOOK_TRIPLE_MISS` 不会从一笔回溯成交里长出来。合格利润不会因此自动变成 $200；它只是不再被一笔违规持仓堵死。

---

## Δ70 · SKEW_INLINE_BRIEF

**状态：** `PROPOSAL · 待 CEO 签字`

**目的：** 今天早盘任务各晚 18–34 分钟，09:07 在简报已在盘的情况下写了 `BRIEF_NO_LEVELS`，Δ62 的开盘前 ≤3 个 PLAN 没有出现。Δ66 已经定义 `SCHEDULER_SKEW`，今天没有落字，后面的 wake 仍在等迟到的 cron。本条款逼 token 落字，并让已经醒来的例程当场读简报、当场做开盘审计。PLAN 仍是现金 0、全闸门，不靠放宽门槛去凑 $200。

**触发条件（满足其一）：**

- 本次纸面 wake 数得清：早盘任务里至少 3 个各晚 ≥10 分钟。早盘任务指 Δ66 已列的 BOX_HEALTH、08:47 盘前自检、开盘审计各 cron、09:25 LITTLEWOLF、09:31 开盘猎，加上 10:00 复查。
- 或者上述条件显然已成立，而 journal 里还没有当日的 `SCHEDULER_SKEW`。

**写入：**

- 文件：当日 journal。在睡前写，不写进 `RULES-ACTIVE.md`。
- token：

```text
SCHEDULER_SKEW | jobs=<name@plan→actual, 逗号分隔> | late_min=<各任务迟到分钟>
```

- 写 `BRIEF_NO_LEVELS` 的同一行必须带：

```text
BRIEF_STAT=path=<读到的路径> | exists=Y|N | mtime=<ET 或 NA>
```

`exists=Y` 时禁止 `BRIEF_NO_LEVELS`。11:30 前改为 ≤3 个 PLAN（`cash_reserved=0`，`PENDING_RTH`），或写 `BRIEF_LEVELS_QUEUED` 并在本 wake 列出读到的价位。11:30 及之后维持现行 `ARCHIVE_ONLY`，不从旧简报新挂票。

- 若更早的 wake 写过 `BRIEF_NO_LEVELS`，而本 wake 看到 `brief.md` 的 mtime 早于那个戳：写 `BRIEF_FALSE_ABSENT`，并在 11:30 前按上一条把 PLAN 补上。

**动作：**

1. `SCHEDULER_SKEW` 落字之后、11:30 之前，每个纸面 wake 自己做两件已有的检查，不等迟到 cron：开盘审计（隔夜 OPEN 的止损 / `GAP_STOP`，Sleeve A 只按已写止损标记），以及上面的简报读取。做完写 `OPEN_AUDIT_INLINE`。
2. 不新开 cron，不修 crontab。`OPEN_AUDIT_CRON_REBUILD_DUE` 继续留给 CEO 做调度维修。维修完成前以本条款的当场检查为准。
3. 误写的 `BOX_DOWN | shell=FAIL` 若下一分钟 shell=OK：追加 `BOX_DOWN_SUPERSEDED`，开盘猎继续。不把 stub 当成停手。
4. 本条款不把 PLAN 提升为 HUNG。提升仍要过 Δ67–Δ69 和现有闸门。一次一腿。

**如何验证：**

- 回放今天：09:07 的 `BRIEF_NO_LEVELS` 在 `exists=Y`（08:55 已在盘）时不成立，应是 `BRIEF_FALSE_ABSENT`。09:52 看到文件时已过 09:36，若当时已有错误 HUNG，PLAN 只能排队，不能并发。所以本条款要和 Δ68/Δ69 一起才还得了槽。
- 回放今天的迟到表（08:47→09:07、09:12→09:41、09:14→09:46、09:15→09:43、09:19→09:52、09:25→09:52、09:31→09:58、10:00→10:34）已经满足「≥3 个且各 ≥10 分钟」。第一份看全这张表的 wake（最晚是 10:34 的复查）必须已有 `SCHEDULER_SKEW`。当天没有这行独立 token。
- 下一张交易日：若再出现同样的集体迟到，journal 在第一个知情 wake 里有 `SCHEDULER_SKEW`，且 11:30 前没有任何一行 `BRIEF_NO_LEVELS` 配着 `exists=Y`。

**今日回放：** 简报路径会在 09:07 被读到，≤3 个 PLAN 以现金 0 写上。它们能不能成交仍看闸门。本条款不保证这 $200，它去掉「文件在盘上却被写成没有」这一种没票。

---

## Δ71 · HEARTBEAT_GAP_FIELDS

**状态：** `PROPOSAL · 待 CEO 签字`

**目的：** 保护 −$100，不靠放宽止损。今天最大浮亏 −$17.86 落在已经标了的 1035→1053（18 分钟）里，没有穿止损。未标的是另一段：1053→1114 共 21 分钟，门 10 分钟，超过门+10，应 `HEAL_LATE`，1114 手写心跳没有 gap 字段。有 OPEN 时这种洞会让止损打印无人分类。本条款不改门的分钟数，只让现有分类一定发生，并在有持仓时先查止损。

**触发条件：** 每一个纸面 wake 写 manchang 时；以及下一 wake 发现上一份心跳缺字段时。

**写入：**

- 文件：`state/YYYY-MM-DD-HHMM-manchang.md`。
- 在现有 `asof|kind|open|hung|sleeve_a_checked` 上增加必填字段：

```text
prev_asof=<HHMM> | gap_min=<n> | door=<10|25> | heal=<Y|N> | escalate=<Y|N>
```

门沿用 Δ26：09:35–11:30 为 10 分钟，11:30–15:05 为 25 分钟，15:05–16:00 为 10 分钟。`gap_min>door` → 本行同时是 `ROUTINE_GAP`。`gap_min>door+10` → `heal=Y`。`gap_min>30` → `escalate=Y`（现有升级，不改 30）。

缺任一字段：该文件记 `HEARTBEAT_INCOMPLETE`。它仍证明这个分钟醒过，**把下一段缺口的起点放在这个 asof 上**（不把 1053→1114→1128 合成一段 35 分钟去升级）。

**动作：**

1. 下一份字段齐全的心跳，若上一份缺字段，先补分类，不补价格：

```text
GAP_BACKFILL | from=<HHMM> | to=<HHMM> | gap_min=<n> | door=<n> | heal=<Y|N> | escalate=<Y|N>
```

2. `heal=Y` 且当时 `open>0` 或 `hung>0`：本 wake 在做别的事之前先写 `GAP_STOP_CHECK`，按已写止损 / t1 / 结构失效价对照这段时间内的打印。穿了就按 Δ23 用打印价记账。没穿就写 `GAP_STOP_CHECK=CLEAR`。不得用这段补查去新挂票。
3. `escalate=Y` 时，现有 `ROUTINE_GAP_ESCALATE` 照旧，在睡前写给 CEO。`HEAL_LATE` 不取消升级。

**如何验证：**

- 回放 1053→1114：`gap_min=21`，`door=10`，`heal=Y`，`escalate=N`，当时 XOM OPEN。1114 手写行缺字段，则 1128 那份齐全心跳必须带 `GAP_BACKFILL | from=1053 | to=1114 | gap_min=21 | heal=Y`，并先做 `GAP_STOP_CHECK`。当天低点 171.02 在 10:40，早于这段，检查结果应是 CLEAR。不改 −$17.86。
- 回放 0952→1004：`gap_min=12`，`door=10`，`heal=N`，`escalate=N`。只补 `ROUTINE_GAP`，不补 `HEAL_LATE`。
- 已正确分类的 19 分钟与两段 29 分钟保持原判，用来确认门槛没有被本条款改掉。
- 下一张交易日：抽 5 份 manchang，每份都有 `prev_asof` 和 `gap_min`。凡相邻 asof 之差大于门+10 且当时有 OPEN，journal 里有 `GAP_STOP_CHECK`。

**今日回放：** −$17.86 和合格 $0 都不变。变的是下一次持仓遇到 21 分钟空洞时，止损会在补分类的同一 wake 被查到，而不是等到收盘才发现有人写过一行没有 gap 的心跳。
