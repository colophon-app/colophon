# 人机协作工作流：规格驱动、计划文件与报告审阅

> 总体观察：在 2025–2026 的 AI Agent 编程实践里，Markdown 已经不只是「写文档的格式」，而是**人与 Agent 之间的协作协议本身**——开发者用 Markdown 写「给 Agent 看的东西」（规格、计划、规则、记忆），Agent 也用 Markdown 回吐「给人看的东西」（计划、任务清单、调研报告、变更说明），双方在同一批纯文本文件上来回交接。之所以是 Markdown 而不是别的，原因高度一致且反复出现：**纯文本**（任何工具都能读写、Agent 生成/解析成本极低、无专有格式锁定）、**可 diff**（逐行比对，天然适配「逐块接受/拒绝」的审阅动作）、**可版本控制**（进 git，随代码一起 review、回溯、blame）、**人机双可读**（人能直接扫读和手改，LLM 又能把标题层级当大纲、把 `- [ ]` 当状态机、把表格当结构化数据）、**可移植跨 Agent**（同一份文件被 Claude Code / Cursor / Codex / Kiro 共享）。本文按「Markdown 在协作中承担的角色」逐类拆解真实工作流；具体文件格式的字段级规范交给 14 号文档，MCP 协议细节交给 15 号，竞品的完整产品拆解交给 18 号，这里只聚焦「工作流长什么样、Markdown 在其中是什么」。
>
> 说明：本调研文档本身就是一个「Agent 产出 → 人审阅」的样例——一个 Agent 用 Markdown 写出结构化报告，交由人类逐节 review，正是下文第三节所描述的那类工作流。

---

## 一、规格驱动开发（Spec-Driven Development, SDD）

### 1.1 范式反转：规格是真相源，代码是产物

SDD 的核心主张是把「规格」与「代码」的传统关系倒过来：**规格是 source of truth，代码是服务于规格的、可再生成的产物**。GitHub Spec Kit 官方文档的原话是「Specifications don't serve code—code serves specifications」——PRD 不再是实现的参考指南，而是「生成实现的源头」；技术计划不是「指导写代码的文档」，而是「产生代码的精确定义」。这个反转带来一个直接的副产品价值：**规格可复用**——因为规格只描述「用户视角要什么」、不含实现细节，同一份 spec 可以配不同的 plan/tasks 跑出不同技术栈的实现。

谁在用：GitHub（Spec Kit）、AWS（Kiro）、Tessl，以及大量把 `spec.md` / `SPEC.md` 手写进仓库的团队。文件形态：一组结构化 Markdown（外加少量目录约定）。下面拆三个代表。

### 1.2 GitHub Spec Kit —— 把 SDD 做成一套斜杠命令 + 模板

**Spec Kit** 是 GitHub 开源的 SDD 工具包，兼容 30+ 种 AI 编程 Agent（Copilot、Claude Code、Gemini CLI、Cursor 等，CLI 与 IDE 都行）。它用一个 `Specify CLI`（`uv tool install specify-cli`，`specify init <项目> --integration copilot`）把脚手架铺进仓库，之后整个流程由斜杠命令驱动，每个命令产出特定的 Markdown 文件：

- **`/speckit.specify`**（喂一句功能描述）→ 自动扫描已有编号决定下一个（001、002、003…）、创建语义分支（如 `003-chat-system`）、生成 `specs/003-chat-system/spec.md` 并按模板填充结构化需求。
- **`/speckit.plan`**（喂技术栈选择）→ 产出技术蓝图 `plan.md`，并生成支撑设计件：`research.md`（库选型对比，Phase 0）、`data-model.md`（数据模型，Phase 1）、`contracts/`（API 端点，Phase 1）、`quickstart.md`（验证场景，Phase 1）。
- **`/speckit.tasks`** → 产出 `tasks.md`（从 plan 派生的、可执行的编号任务清单，Phase 2）。注意 `tasks.md` **不是**由 plan 命令生成，而是这一步单独生成。
- **`/speckit.analyze`**（只读）→ 跨 `spec.md` / `plan.md` / `tasks.md` 检查冲突、缺口、歧义，官方建议「实现前必跑」，它能抓出会导致运行期失败的逻辑漏洞和「宪法违规」。
- **`/speckit.implement`** → 按 `tasks.md` 的依赖顺序执行，可一次全建或按 phase 分批。
- **`/speckit.checklist`** → 生成质量清单（被形容为「给需求写的单元测试」），在拆分前确认规格完整、清晰、一致。

一个有辨识度的设计是 **`constitution.md`**（放在 `.specify/memory/`）：项目的**不可协商原则**，比如「所有应用一律 CLI-first」「Web 应用的测试必须走某种方式」。它在任何 SDD 迭代开始前就定好，`analyze` 会拿它当校验基准。

**`spec.md` 模板长什么样**（据官方 `spec-template.md`）：顶部有元数据（`Feature Branch`、`Created` 日期、`Status`）；主体是三个「mandatory」大节 + 若干可选节——
- **User Scenarios & Testing**：每条用户故事带优先级标签（P1/P2/P3）、纯语言描述、「Why this priority」、「Independent Test」（独立可测性）、以及 **Given/When/Then** 格式的验收场景。
- **Requirements**：用「System MUST [具体能力]」的祈使句 + 编号书写（如「System MUST allow users to create accounts」）。
- **Success Criteria**：含「Measurable Outcomes」可量化结果。
- 可选：**Edge Cases**、**Key Entities**（数据密集型特性用）、**Assumptions**。
- 关键的**歧义标记** `[NEEDS CLARIFICATION: ...]`：规格没写清楚的地方显式插桩，例如「System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]」。这让「未决问题」成为文件里可被检索、可被 `analyze` 抓取的一等公民，而不是散落在对话里。

### 1.3 AWS Kiro —— 「让规格成为工作的单元」的 agentic IDE

Kiro 把 SDD 结构化成三个阶段、三份 Markdown（存在 `.kiro/specs/` 下）：

- **`requirements.md`**：用户故事 + **EARS 记法**（Easy Approach to Requirements Syntax）的验收标准，模式是 `WHEN [条件/事件] THE SYSTEM SHALL [预期行为]`。例：「WHEN a user submits a form with invalid data THE SYSTEM SHALL display validation errors next to the relevant fields」。（bug 修复场景对应 `bugfix.md`。）
- **`design.md`**：技术架构、时序图（sequence diagrams）、实现考量。
- **`tasks.md`**：离散、可追踪的任务，用**复选框**书写，且**每个任务附带一串相关需求编号做可追溯（traceability）**——任务不是单纯待办，而是能回溯到具体需求的实现计划。

Kiro 对 `tasks.md` 提供**实时执行界面**：任务状态实时更新为 in-progress / completed；它还会给任务建**依赖图**并分「波（waves）」并发执行——Wave 1 是所有无依赖的任务（并发跑），Wave 2 是依赖被 Wave 1 满足的任务，以此类推，「波与波之间串行，波内任务并发」。

与 spec 并列的是 **steering files**（`.kiro/steering/*.md`）——给 Kiro 提供**跨会话的持久项目上下文**：项目级放「本服务是多租户 SaaS，tenant ID 总是从请求上下文取」，全局级（`~/.kiro/steering/`）放「一律 TypeScript strict 模式」「优先 AWS CDK 而非裸 CloudFormation」「所有 Lambda 必须带 correlation ID 的结构化日志」。还可自定义，如 `security.md` 专管安全要求。其价值被官方总结为**上下文稳定性**：「Kiro 的上下文不会在会话间被重置，也不取决于最后写 prompt 的人是否周全」。保存文件时还能触发 hooks（linter、测试、安全扫描）。

### 1.4 Tessl —— 「spec-as-source」的激进押注与 2026 转向

Tessl 由 Snyk 创始人 Guy Podjarny 创立，两个产品：
- **Spec Registry**（公开 beta，先行产品）：一个持有 **10,000+ 条 usage spec** 的库，专门解释「如何正确使用某个外部开源库」，用来消除 Agent 对库 API/版本的幻觉。被类比为「**给 Agent 上下文用的 npm**」——`tessl install` 装一条 usage spec，它就成为任何 MCP 兼容 Agent 的项目上下文；也能装团队私有规则（内部库、API、安全策略、技术栈约定）。
- **Tessl Framework**（私有 beta）：更激进的愿景——**spec 才是你维护的产物，代码退化为可再生成的输出**，生成的代码打上 `// GENERATED FROM SPEC - DO NOT EDIT`，理想态是「你不再改代码，只改意图（spec），机器重新编译整个应用」。

现实校准：据 2026 年 6 月的评测，Framework 到年中仍未 GA，私有 beta 约九个月，被 ThoughtWorks 的 Birgitta Böckeler 描述为比公开 Registry「更面向未来」。核心技术批评很尖锐：spec-as-source 相当于「完全依赖一个**非确定性编译器**」——同一份 spec 跑两次会得到不同实现。值得注意的是，**2026 年 1 月 29 日 Tessl 重新定位**为「Skills on Tessl：agent skills 的包管理器」，自称「Agent Enablement Platform」，主页 tagline 变成「Skills are the new code」，三大支柱转为安全治理、标准化复用、持续优化——从纯 spec-centric 转向更可落地、更好卖给企业的「治理 Agent 蔓延」问题。这条转向本身对我们是重要信号：**纯粹的 spec-as-source 还太前沿，而「结构化的 Agent 上下文文件」是当下真正被买单的东西。**

### 1.5 「规格文件」到底长什么样（跨工具综合）

把三家对齐，一份典型的 SDD 规格集合在仓库里的形态是：

```
specs/003-<feature>/
├── spec.md          # 要什么、为什么（用户故事 + MUST 需求 + Given/When/Then + [NEEDS CLARIFICATION]）
├── plan.md          # 怎么做（技术蓝图）
├── research.md      # 选型对比
├── data-model.md    # 数据模型
├── contracts/       # API 契约
├── tasks.md         # - [ ] 可勾选任务，逐条回溯到需求编号
└── (constitution/steering/CLAUDE.md 等规则文件在仓库更高层)
```

共同特征：**分离「what/why」（spec）与「how」（plan/tasks）**、需求用祈使句 + 编号 + 可追溯、验收标准用 Given/When/Then 或 EARS、未决问题显式插桩、任务用复选框表达状态。这套东西之所以全是 Markdown：需求要能被人 review（产品/QA 读得懂）、被 Agent 精确解析（标题和编号是天然锚点）、随分支进 git（和代码一起走 PR、一起回溯）。

### 1.6 争议与边界：SDD 不是银弹

一手材料里对 SDD 的批评同样强烈，写进来以免我们过度神化：
- **Kent Beck** 的核心反对：「我见到的 SDD 描述都强调在实现前写完整份规格，这内含一个（在我看来很怪的）假设——你在实现过程中不会学到任何能改变规格的东西。」
- **overhead 翻倍**：让 spec 与 code 保持同步会随系统复杂度增长成「维护税」，常常不是减少而是**加倍**工作量；对小任务尤甚——Nearform 的实战结论是「SDD 不总能向下缩放」，简单重构/UI 微调上，「管理 AI 的时间超过了交付价值的时间」。
- **陈旧的 spec 比陈旧的 doc 更危险**：过时的设计文档只误导下一个读它的工程师；过时的 spec 会误导「不知情的 Agent」——它们会**自信地执行一个已经不符现实的计划，且不会报警**。
- **「规格即官僚主义」**（AIWare 2026 论文命名的失败模式）：当 spec 变成「要填的表格」而非「澄清工具」，团队会钻空子或直接弃用；AI 生成的一堆 plan/task/中间产物还会让团队「淹没在生成的文档里」。
- **黄金法则**：用「能消除歧义的最小规格严格度」，按任务复杂度匹配严格度；抛弃型原型、单人短命项目、探索性编码、需求显而易见的 CRUD，都可能是 SDD 的 overkill。

对我们的意义：编辑器要支撑 SDD，但**不能强推**——把规格/计划/清单渲染好、让「未决问题」和「陈旧」可见，比强迫用户先写完整 spec 更有价值。

---

## 二、计划与任务文件：Markdown 作为「跨多次运行的持久状态」

这是 Markdown 在人机协作里最日常、最高频的角色：**Agent 的短期记忆（上下文窗口）会随会话消失，而磁盘上的 `.md` 文件不会**——所以把「计划」和「任务清单」落成文件，就等于给 Agent 造了一个跨运行、跨会话、甚至跨不同 Agent 的持久状态。一句被反复引用的话点破了本质：「`.md` 文件是永久的（persistent），而 Claude 对这些任务的记忆只活在当前交互（session-scoped）。」

### 2.1 Plan mode：先出「可审阅的计划」，批准后再动手

**Claude Code 的 Plan Mode**：`Shift+Tab` 连按两次进入（状态栏显示 `⏸ plan mode on`），这是一个**只读权限态**——Claude 能读文件、搜索、跑只读命令、上网查，但**在你批准前一个字都不能改**。它的工作循环是 Read → Map（列出所有将受影响的文件）→ Propose（起草实现计划）→ Review（你检查）→ Approve（你确认或要求修改）→ Edit → Apply → Verify → Report。批准即退出 plan mode 并「精确按计划执行」。一个关键实现细节：**进入/退出 plan mode 本身是一个工具（`ExitPlanMode`），退出时它会读取自己写到磁盘的 plan 文件再开始干活——「通往 spec 的路径永远经过文件系统」**。你还能按 `Ctrl+G` 把 plan 文件在编辑器里直接改（增删步骤、加约束），比在对话里描述改动舒服得多。Claude Code 作者 Boris Cherny 本人的工作流就是「大多数会话从 Plan Mode 开始，来回改到计划对了，再切 Auto-Accept 让它执行」，对应 Anthropic 的四段式 Explore → Plan → Implement → Commit。

**Cursor 的 Plan Mode**：同样 `Shift+Tab` 进入，先研究代码库、找相关文件、**主动问澄清问题**，然后**产出一个 Markdown 计划文件**（持久化存到 `.cursor/plans/`，「就是一个写成人类可读指令的 markdown 文件」），可选保存进仓库。计划里的 **to-dos 完全可编辑**——官方建议「审阅 to-dos，如果多了就说『去掉 build/verify 这些，我们手动验』」；细节多寡由你决定，「细节越少，给实现 Agent 的自由度越大」。规划期间**不改任何文件**。

要点：两家的「计划」都落成**可编辑的 Markdown 文件**，而不是一次性的聊天气泡。计划文件成了「人审 → 改 → 批准 → Agent 执行」这条链的物理载体。

### 2.2 复选框任务清单 & 「边做边勾」

Markdown 的 GFM 任务列表（`- [ ]` / `- [x]`）是 Agent 表达进度的通用语言：

- **Claude Code 的两套机制**：`TodoWrite`（**会话内、易失**，终端里实时刷新的清单，状态 pending / in_progress / completed，被形容为 Claude「把我听到的复述一遍」的确认动作）；以及 **Task 系统**（**磁盘持久、跨会话**）——据一手资料，Todo 系统在 **v2.1.16（2026-01-22）被 Tasks 取代**，任务持久化到 `~/.claude/tasks/`（在 home 而非项目里）、支持依赖追踪、跨会话广播更新、终端里 `Ctrl+T` 切换显示，工具为 `TaskCreate` / `TaskUpdate` / `TaskGet` / `TaskList`（可用 `CLAUDE_CODE_ENABLE_TASKS=0` 退回旧 TodoWrite）。决策规则很干净：**工作是否跨会话边界**——不跨用 TodoWrite（开终端、干活、关终端的一次性活），跨就用 Tasks（多天特性、有阶段顺序的重构、可能周五放下周一继续的活）。
- **Kiro 的 `tasks.md`**：如前所述，复选框任务 + 需求编号回溯 + 实时状态界面 + 依赖波并发。
- **手写 `todo.md` / `plan.md` 的民间做法**：在 Tasks 出现前，大量用户手动让 Claude「把所有任务列进 `todo.md`，完成就勾掉」，然后关掉对话、开新会话、从同一份清单继续——机制上就是「把状态从模型记忆写回磁盘，原 Markdown 文件被覆盖/追加成任务的新状态，供下次会话读」。缺点是「很啰嗦」（得反复叫它读清单、挑下一项、标完成），这正是原生 Task 系统要替代的痛点。

无论哪种，Markdown 复选框的好处是：**人扫一眼就知道进度**，Agent 一次 `Edit` 就能把 `[ ]` 改成 `[x]`，且这份进度进 git 后，团队里任何人（或任何 Agent）接手都能读到「做到哪了」。

### 2.3 PRD → 任务清单 → 逐条处理：三段式 Markdown 流水线

一个被广泛复制的开源工作流（snarktank/`ai-dev-tasks`）把「需求 → 实现」拆成三个 Markdown 指令文件驱动的阶段：

1. **`create-prd.md`**：引导 Agent 基于一句初始 prompt 生成一份 Markdown PRD。先问 **3–5 个最关键的澄清问题**（用「1A / 2C」式编号+字母选项方便快速回答），再落盘到 `/tasks/prd-[feature-name].md`。PRD 结构：Introduction/Overview、Goals、User Stories、Functional Requirements、Non-Goals (Out of Scope)、Design Considerations（可选）、Technical Considerations（可选）、Success Metrics、Open Questions。**目标读者明确写成「junior developer」**——要求显式、无歧义、少术语，这是让「字面理解的」Agent 少犯错的关键技巧。
2. **generate-tasks**：把 PRD 拆成分层的、可勾选的实现任务清单。
3. **process-task-list**：指示 Agent **一次只做一个任务、每步等你批准再继续**，并负责把完成的任务标 `[x]`。

进阶版（buildermethods 的 PRD Creator，作为 agent skill，工具无关、纯 Markdown）把它做成**里程碑制**：`prd.md` 是唯一真相源，每个 `prompt.md` 是薄触发器（叫 Agent 读 PRD、读之前的里程碑日志、规划、构建、记录），而 **`milestone-log.md` 记录每个里程碑「建了什么、做了什么决策、引入了什么约定、偏离 PRD 之处」**；后续里程碑连同 PRD 一起读这些日志，从而「在既有工作上继续建，而不是重新争论一遍」——这正是让多会话构建保持连贯的机制。

为什么全是 Markdown：PRD 要给人（产品、reviewer）读、给 Agent 解析、随功能分支进版本控制当「living document」；「一次一任务 + 等批准」把审阅点切碎成小块，每块都是一次 diff review。

---

## 三、Agent 产出 → 人审阅：Markdown 作为交接与评审载体

Agent 越来越多地把「调研、计划、变更」写成 Markdown 交给人审——本文本身就是一例。这里 Markdown 的两个属性变成刚需：**可 diff**（评审动作 = 逐块接受/拒绝）与**可被解析的结构**（下游系统/人靠标题定位内容）。

### 3.1 Agent 写「报告」给人审：deep research 的 handoff 形态

研究型 Agent 产出的标准形态是**结构化、带引用的 Markdown 报告**。一个被推荐的模板要求 Agent 产出这些节：Executive Summary（3–5 条 bullet）、Background and Context、Key Findings（每个主题一个子节）、Contradictions and Gaps in the Evidence、Practical Implications、Sources Referenced，并明确「用 H2 做节、H3 做子节」——「显式的格式指令能稳定提升各类模型的输出结构」。LangChain 的 deep research agent 甚至把流程也文件化：把用户问题写进 `/research_request.md`，最终报告写进 `/final_report.md`。

两条硬结论对编辑器有直接含义：
- **报告必须当「初稿」审**：一手评述反复强调「所有 AI 研究产出都应作为需人工核验的初稿，尤其是引用和具体主张」——在需要深度解读的任务上，精确率可低至 **4.6%**（会塞进不相关/错误陈述）。所以「引用可点、可回溯原文」的审阅交互极其关键。
- **handoff pattern**：Agent 之间/Agent 到下游工具的交接，靠「返回可预测、机器可解析的 Markdown（按 header 抽节）」完成——这也是「同一份报告既给人读、又给机器 parse」双重用途的来源。

### 3.2 diff 审阅：逐块接受/拒绝

**Cursor** 的审阅是评审流的教科书：Agent 执行完把改动以**可审阅的 diff** 呈现，你**逐文件 accept/reject**，且**不是全有全无**——可以只接受部分改动、可以在 diff 视图里直接手改（不是只读）、也可以整块接受后再自己改；快捷键 `Cmd+Enter` 接受全部、`Cmd+Backspace` 拒绝/取消。多文件时通常逐文件接受。核心价值：「AI 代码可能看着对其实微妙地错」，所以「读 diff、接受你要的、拒绝或改你不要的」是必备纪律。

### 3.3 checkpoint / rewind：把「回滚」做成一等能力

审阅之外还要能**反悔**。两家的做法：
- **Claude Code Checkpoints**：**每次 Claude 编辑前自动快照**，`/rewind` 或空输入框连按两次 `Esc` 打开回滚菜单，列出本会话每条 prompt，可选 Restore code / Restore conversation / Restore both / Summarize from here。默认开启、随会话持久（30 天清理，`cleanupPeriodDays` 可配），v2.1.191+ 甚至能跨 `/clear` 回滚。**重要边界**：只追踪 Claude 文件编辑工具的直接改动，**不追踪 bash 命令改的文件**（`rm`/`mv`/`cp` 无法回滚），也不替代 git——定位是「本地 undo」，git 才是「永久历史」。
- **Cursor Checkpoints**：Composer 里为多步会话维护检查点，「每次 AI 迭代改动都标记状态」，可回退到之前的检查点，「Agent 走歪了就回滚换个路子」。

### 3.4 异步云 Agent → Pull Request 审阅

另一条评审流是**把 PR 当交接单位**。OpenAI **Codex Cloud** 是异步云 Agent：描述任务后，它在隔离沙箱里 clone 仓库、跨文件写代码、跑测试、迭代，**最后开一个 PR 给你审**（带 diff + 终端日志可逐步追溯）；因为异步，可**并行排多个任务，各自回来是独立的 PR**。它也能反过来当 reviewer：`@codex review` 自动在 PR 上标出回归、缺测试、文档问题，`@codex fix it` 起新任务修好并更新 PR（OpenAI 内部「100% 的 PR 都过 Codex review」）。评审行为本身由 Markdown 的 `AGENTS.md` 里的「## Review guidelines」小节调（如「把拼写/语法标为 P0、缺文档标为 P1、缺测试标为 P1」），并按「离改动文件最近的 `AGENTS.md`」生效。

这里 Markdown 的角色是双份的：**变更说明/审阅规则是 Markdown**，而 PR 的 diff 本身就是「Agent 产出 → 人审」的经典载体，天然可逐块 comment、accept、request changes。

---

## 四、项目记忆与知识库：Agent 长期读取的 Markdown

前三节是「一次任务」尺度，这一节是「跨任务的长期上下文」尺度——Agent 每次启动都读的记忆文件、团队沉淀的决策记录。

### 4.1 记忆文件：CLAUDE.md 与 AGENTS.md

**CLAUDE.md**（Claude Code）被精准地定义为「**不是文档，是写给 AI Agent 的行为契约（behavioral contract）**」，区别于给人读的 README。它是一套有优先级的层级，启动时全部加载、更具体者覆盖更宽泛者：
- 企业/受管策略（如 `/etc/claude-code/CLAUDE.md`）
- 用户级 `~/.claude/CLAUDE.md`（个人全局偏好）
- 项目级 `./CLAUDE.md` 或 `./.claude/CLAUDE.md`（进 git、全队共享：构建命令、测试要求、代码规范、架构决策、命名约定）
- 项目规则 `./.claude/rules/*.md`（模块化，可用 YAML frontmatter 的 `paths:` 做路径域限定）
- 项目本地 `./CLAUDE.local.md`（个人、自动 gitignore）

配套 **`@path` import**（相对/绝对路径皆可，最多 4 跳递归，首次引入外部路径需批准，代码块内的 `@` 不解析）。最佳实践高度一致：**保持精简**（官方建议单文件 <200 行、根文件理想 50–100 行，越具体越精简 Claude 越照做）；**是行为契约不是知识倾倒场**（只写「能改变 Claude 决策」的信息，代码能推断的不写）；**祈使句 + 谨慎使用 `IMPORTANT`/`YOU MUST`**（官方确认能提升遵从度，但只留给一两条最关键规则）；**写反向规则**（「绝不 commit .env」「不用 class 组件」）；**构建/测试命令是最高价值节**（Claude 不知道你用 `pnpm vitest` 还是 `npm test`）；**HTML 注释会被剥离**（给人看的维护者备注塞这里，不进 Claude 上下文）。此外 Claude Code 现在有**双记忆系统**：CLAUDE.md（你写的「要求」）+ auto memory / `MEMORY.md`（Claude 根据你的纠正自己记的「它观察到的你」），两者启动都加载。

**AGENTS.md** 是**跨工具开放标准**：2025 年 8 月由 OpenAI、Google、Cursor、Factory、Sourcegraph 共同发起，现由 Linux Foundation 下的 Agentic AI Foundation 治理，据 OpenAI 已被 **60,000+ 开源项目**采用、30+ 种 Agent 读取。它解决的问题是「一个工具一个指令文件」的碎片化（`.cursorrules`、`CLAUDE.md`、`.github/copilot-instructions.md`……）——「一个文件，所有 Agent」。格式**刻意极简**：纯 Markdown、无必填字段、无 frontmatter、无特殊语法，常见节为项目概览、构建与测试命令、代码风格、测试说明、安全考量、提交/PR 规范。**monorepo 用嵌套文件**（Agent 读最近的那个，就近覆盖；OpenAI 主仓库有 88 个 AGENTS.md，建议单文件超 150–200 行就拆子目录）。注意：Claude Code 不读 AGENTS.md（用 CLAUDE.md，可 symlink 打通）；Codex 支持 `AGENTS.override.md` 覆盖、单文件默认 32 KiB 上限（超出静默截断）。一条冷静提醒：有研究发现 **LLM 自动生成的 AGENTS.md 反而让成功率降 2%、成本升 23%**（因为重复了代码里已有的信息）——人手写的、含「非显而易见信息」的才有效。

### 4.2 决策记录：ADR / MADR

**Architecture Decision Record (ADR)** 记录一个「有架构意义的设计选择及其理由」。经典结构来自 Michael Nygard（2011）：**Title、Status、Context、Decision、Consequences**。**MADR**（Markdown Architectural Decision Records，后来扩义为「Markdown **Any** Decision Records」）是其精简 Markdown 模板，特色是**强调选项分析**——「Considered Options 及各自 pros/cons」是理解「为何选它」的关键；典型节为 Context and Problem Statement、Considered Options、Decision Outcome（含「Chosen option: X, because …」）。模板有全/精简 × 带注解/裸四种变体，放 `docs/decisions/nnnn-title.md`，最新是 **MADR 4.0（2024-09-17）**，双 MIT/CC0 授权；2026 年 3 月还出了 YAML 版（YADR）。为什么 Markdown：「作为纯文本，对版本控制和协作友好，且逼你专注内容与逻辑而非排版」。

谁在用：几乎所有把「决策历史」纳入仓库的工程团队；文件形态是 `docs/decisions/` 或 `docs/adr/` 下一串按序号命名的 `.md`，随代码一起 review、一起演进——对 Agent 而言，这是「为什么当初这么设计」的可检索长期记忆。

### 4.3 规则/引导文件（steering / rules / constitution）

前面散见的 `constitution.md`（Spec Kit）、`.kiro/steering/*.md`（Kiro）、`.cursor/rules/*.mdc`（Cursor）、`.claude/rules/*.md` 是同一类角色：**项目级、纯文本、进版本控制的「给 Agent 的规范」**，约束 Agent 的技术选型、风格、边界。它们与「记忆文件」的差别更多是命名与加载机制，共性是——**规范本身就是文库里的 Markdown 文件，可 diff、可 PR、可社区分享**，与「一切皆本地纯文本」自洽。（这类文件的字段级规范归 14 号；此处只强调其工作流角色。）

---

## 五、其他常见 Markdown 协作产物

- **PRD / 需求文档**：见 §2.3。趋势是从「三个月前写完就没人更新的静态大文档」转向**轻量、决策聚焦、living 的 `prd.md` / `SPEC.md`**，与 AI 原型工具并行。一条警示：ChatGPT 之后 PM 常用 LLM 生成「又长又空」的 PRD，反而有害——「用能消除歧义的最小信息量」。
- **变更说明 / Changelog**：`CHANGELOG.md` + **Keep a Changelog** 约定（事实标准）：按版本倒序、每版按 **Added / Changed / Deprecated / Removed / Fixed / Security** 分组、日期用 ISO 8601、维护一个 **Unreleased** 段作为「管道预览」、配合 SemVer。更严的 **Common Changelog** 要求祈使现在时（Add/Fix/Bump…）。也可由 **Conventional Commits**（`feat:` / `fix:` / `BREAKING CHANGE:`）经 `conventional-changelog` / `git-cliff` 自动生成——即「commit 是结构化输入、changelog 是 Markdown 输出」。这类文件天生适合 Agent 起草、人审定稿。
- **需求/设计/研究的中间产物**：`research.md`、`data-model.md`、`design.md`、`milestone-log.md`、`/final_report.md` 等（散见于前文）——它们的共同角色是「Agent 多步工作的可审阅落点」，让长任务的每个阶段都有一份人能读、能改、能回溯的纯文本。

---

## 横切结论：为什么协作的每一环都收敛到 Markdown

把上面所有类别叠起来看，Markdown 反复被选中的原因是同一组，且相互加强：

1. **纯文本 = 通用接口**：人、任意编辑器、任意 Agent（Claude Code / Cursor / Codex / Kiro）、CI 脚本都能读写，无专有格式锁定；LLM 对它 token 化友好。
2. **可 diff = 可评审**：几乎所有「人审 Agent」的动作（逐块 accept/reject、PR review、checkpoint 回滚）都建立在「两个纯文本版本可逐行比对」之上。
3. **可版本控制 = 与代码同源治理**：spec/plan/tasks/记忆/决策随分支进 git，和代码一起 review、blame、回溯；「陈旧」也因此可被 diff 发现。
4. **结构轻但足够 = 人机双读**：标题层级=大纲/可抽节 handoff，`- [ ]`=状态机，表格=结构化数据，`[NEEDS CLARIFICATION]`/Open Questions=待办插桩，链接=交叉引用；人扫读、机 parse 两不误。
5. **文件即持久状态 = 跨会话/跨 Agent 记忆**：磁盘文件不随上下文窗口消失，这是「多次 Agent 运行仍连贯」的物理基础。

---

## 对我们编辑器的启示

要成为「人 ↔ AI Agent 的 Markdown 界面」，编辑器应把下列工作流做成一等体验（均直接对应上文的真实实践）：

- **把任务清单/复选框做成一等交互**：GFM `- [ ]` / `- [x]` 可点击勾选、显示完成进度条、支持嵌套与分组；能识别 `tasks.md` / `todo.md` / `plan.md` 并给「勾选态」高亮与统计；当 Agent 在后台把 `[ ]` 改成 `[x]` 时实时反映。这是 §2 里 Claude Code Tasks、Kiro `tasks.md`、`ai-dev-tasks` 三段式的共同刚需。
- **把「规格 / 计划 / 报告」渲染好**：为 SDD/审阅文档做专门的可读性——Given/When/Then 与 EARS（`WHEN … THE SYSTEM SHALL …`）语法着色、优先级标签（P1/P2/P3）徽章化、`[NEEDS CLARIFICATION: …]` 与「Open Questions」高亮并可聚合成侧栏待办、需求编号（FR-1、REQ-3）可点击跳转、大纲/TOC 与「Executive Summary → Findings → Sources」结构导航、**引用可点回溯原文**（deep research 报告的核验刚需）。
- **内置 diff 审阅面板**：当 Agent 写入/改写文件时，先以 diff 呈现，支持**逐 hunk 接受/拒绝**、在 diff 里直接手改、「接受全部/拒绝全部」快捷键；对「Agent 产出的新报告/新计划」也走同一评审入口。这是 Cursor 审阅流的核心。
- **监听文件变更并热重载**：Agent 在磁盘上改的正是用户可能开着的文件——必须用 OS 原生 watcher（macOS FSEvents）做到「文件无脏改动时静默刷新缓冲区」，有未保存冲突时给 **Reload / Ignore / Compare（diff）** 三选项（对标 VS Code 的成熟做法，避免 Obsidian「不切走再切回就看不到外部改动」的坑）；刷新时保留光标/滚动位置。这是本路线区别于普通编辑器的硬功能。
- **规格 / PRD / ADR / Changelog / 记忆文件模板**：新建即可选模板——spec（User Scenarios / Requirements(MUST) / Success Criteria / Assumptions）、PRD（Overview / Goals / User Stories / Functional Requirements / Non-Goals / Open Questions）、MADR（Context / Considered Options+pros&cons / Decision Outcome）、`CHANGELOG.md`（Keep a Changelog 六分类 + Unreleased）、以及 `CLAUDE.md` / `AGENTS.md` / `constitution.md` / steering 脚手架；模板要精简（呼应「<200 行」「最小规格严格度」的一手忠告，不做又长又空的模板）。
- **checkpoint / 本地版本历史**：在 Agent 每次写入前做本地快照，提供时间线式回滚（Restore 这一步 / 这个文件），定位为「本地 undo」，与 git 互补而非替代——把 Claude Code Checkpoints、Cursor Checkpoints 的能力带给「在编辑器里看着 Agent 干活」的用户。
- **记忆/规则文件当一等公民**：识别并特别渲染 `CLAUDE.md` / `AGENTS.md` / `.claude/rules/*.md` / `.cursor/rules/*.mdc`；可视化其**层级与加载顺序**、解析并可跳转 `@import`、给出「行数预算」提示（超 200 行提醒拆分）、HTML 注释以「人类备注」样式弱显。让用户舒服地写「给 Agent 看的东西」正是本产品的定位核心。
- **跨文件交叉引用与「Agent 工作区」视图**：把 `spec.md → plan.md → tasks.md → 代码` 的引用链、需求编号回溯、`[[wiki 链接]]` 做成可点跳转；提供一个把 `specs/`、计划、报告、记忆、决策（`docs/decisions/`）聚合展示的侧栏，让「文库当 Agent 知识库」这件事一目了然。
- **「批准计划 / 接受报告」作为编辑器动作（进阶）**：既然「计划文件」「审阅」是工作流的物理节点，可探索把「批准这份 plan」「把这份报告标为已审」做成编辑器级动作（写状态回文件或触发外部 Agent 继续）——与内置 MCP（15 号文档）天然衔接，但保持简洁、不喧宾夺主。

一句话：这些工作流的最大公约数是「**人和 Agent 在同一批可 diff、可版本控制的 Markdown 文件上交接状态**」。编辑器只要把「渲染好这些文件 + 审阅这些改动 + 感知外部写入 + 备好模板与回滚」这四件事做到原生级顺手，就成了这套人机协作流水线里**最舒服的那一环**。
