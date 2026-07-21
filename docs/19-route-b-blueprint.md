# 路线 B 综合：Markdown × AI Agent 产品设计蓝图

> 本文是第二阶段（路线 B 专题）的综合收束文档，只依据 docs/ 目录下 14–18 号（本阶段五份路线 B 调研）与 08、09、13 号（第一阶段已有结论）撰写，不引入这些文档之外的信息。文中括号内的（14）（15）等编号指向对应调研文档，便于回溯核对。撰写日期 2026-07-21。
>
> 分工回顾：14 号＝写给 Agent 的静态文件格式（CLAUDE.md / AGENTS.md / rules / llms.txt）；15 号＝MCP 协议与我们的 server 接口草案；16 号＝Agent Skills（技能即 Markdown）；17 号＝人机协作工作流（spec / 计划 / 报告审阅）；18 号＝竞品与功能拆解。08＝AI 交互形式清单与三层 AI 架构；09＝技术栈（swift-markdown 的 AST/SourceRange 红利）；13＝产品机会与 MVP/V1/V2 分层。
>
> 一句话主线：**编辑器自己不生成内容（那是 Agent 的活），而是成为「人 ↔ AI Agent 的 Markdown 界面」——写「给 Agent 看的东西」最舒服的地方，读「Agent 产出的东西」最好看的地方，以及让你已经在用的 Agent 能安全读写你 Markdown 文库的那层协议。**

---

## 一、路线 B 命题重述：编辑器作为人 ↔ Agent 的 Markdown 界面

2025–2026 年出现了一个新事实：**Markdown 已经不只是「写文档的格式」，而是人与 AI Agent 之间的协作协议本身**（17）。开发者用 Markdown 写「给 Agent 看的东西」——项目记忆（`CLAUDE.md`）、跨工具指令（`AGENTS.md`）、规则（`.cursor/rules/*.mdc`）、技能（`SKILL.md`）、规格（`spec.md` / `requirements.md`）、任务清单（`tasks.md`）；Agent 也用 Markdown 回吐「给人看的东西」——计划（`plan.md`）、调研报告（`final_report.md`）、决策记录（ADR/MADR）、变更说明（`CHANGELOG.md`）。双方在同一批**纯文本、可 diff、可版本控制、人机双可读**的 `.md` 文件上来回交接状态（17）。这批文件恰好全是纯 Markdown（外加可选 YAML frontmatter）——**正是我们编辑器的主场**（14、16）。

路线 B 的命题就是：**不做内容生成（AI 原生工具与 Agent 的活），而是把编辑器做成这套人机循环里「最舒服的那一环」**。它由三件事定义：

1. **写「给 Agent 看的 Markdown」最舒服的地方**：把 `CLAUDE.md` / `AGENTS.md` / rules / `SKILL.md` / spec 当一等公民——理解它们的层级、`@import`、frontmatter 语义、glob 作用域、字符预算、块级注释剥离，并用 byte-exact 保存保证不破坏字节保真（14、18）。
2. **读「Agent 产出的 Markdown」最好看、最好审的地方**：把计划/报告/任务清单渲染好、把 Agent 的改动以 diff 呈现、感知 Agent 在盘上的外部写入、备好模板与回滚（17、18）。
3. **让你已在用的 Agent 能安全读写你文库的那层协议**：内置 MCP server + 为自家格式撰写 Agent Skills，让 Claude Code / Cursor / Codex 等**用户已经付费**的 Agent 直接操作文库——我们零推理成本、零隐私责任（15、16）。

**为什么这是我们独有的差异化**（交叉验证于 13、18）：

- 精品原生阵营（iA Writer、Ulysses、Bear、Obsidian）**集体拒绝内置云 AI**，恰好把这个位置留空（08、13）。
- 「原生 macOS + 开源 + 好看 + 会 Agent 语义」四要素叠加**目前无人占据**：MacMD 证明「专编 Agent 配置文件」是清晰入口但能力弱（2 star）、OpenMark 证明「美化 Agent 产出」也能成立但只读、VMark/Clearly/SoloMD 把 MCP 做了但全是 Tauri/Electron/Web 壳（18）。
- 我们手里有一张别人没有的牌：**swift-markdown 的不可变值类型 AST + 精确 SourceRange**（09）。全行业的笔记类 MCP server **没有一个**做基于语法树的结构化编辑（全是整篇覆盖或行级替换），也**没有一个**暴露活动编辑器状态——这两块空白正好是「原生编辑器」区别于「一堆 .md」的独占资产（15）。

一句话：**别人把 AI 做成聊天框或内容生成器；我们把编辑器做成协议界面——让人写给 Agent 的、Agent 写给人的 Markdown 都在这里最顺手，并用原生 AST 能力把「Agent 安全读写文库」做得比任何裸文本方案更精确。**

---

## 二、人机 Markdown 循环全景

把 14–18 号叠起来看，路线 B 的世界是一个闭环：**人写规范 → Agent 读规范、干活、产出 → 人审产出 → 修正规范**，编辑器坐在正中间承接每一次交接。

### 2.1 文字示意

```
                    ┌───────────────────────────────────────────────┐
                    │                 我们的编辑器                    │
                    │        （人 ↔ Agent 的 Markdown 界面）          │
                    └───────────────────────────────────────────────┘
                          ▲                               │
      人写给 Agent 的 .md  │                               │  编辑器暴露给 Agent
      （14：常驻指令/规则） │                               ▼  （15：MCP server / 16：Skills）
   ┌──────────────────────┴────────┐          ┌───────────────────────────────┐
   │ CLAUDE.md / AGENTS.md          │          │ 内置 MCP server                │
   │ .cursor/rules/*.mdc            │          │  · 文库读写（基线七件套）       │
   │ .github/*.instructions.md      │          │  · 活动文档/选区（IDE 范本）    │
   │ SKILL.md（技能即 Markdown）     │  ──────▶ │  · AST 级结构化编辑（独占）      │
   │ spec.md / requirements.md      │          │ + 自带 Agent Skills（教格式）   │
   │ tasks.md / constitution.md     │          └───────────────┬───────────────┘
   │ llms.txt（喂知识不喂指令）      │                          │
   └────────────────────────────────┘                          ▼
                          ▲                          ┌──────────────────┐
                          │                          │  外部 Agent       │
      人审 Agent 的产出    │                          │  Claude Code      │
      （17：diff / 审阅）  │                          │  Cursor / Codex   │
   ┌──────────────────────┴────────┐                 │  （用户已付费）    │
   │ plan.md（计划，批准后执行）     │  ◀────────────  └──────────────────┘
   │ research.md / final_report.md  │       Agent 产出的 .md（17）
   │ tasks.md（边做边勾 [x]）        │
   │ ADR / MADR（决策记录）          │
   │ CHANGELOG.md（变更说明）        │
   └────────────────────────────────┘
```

### 2.2 三段拆解

**（A）人写哪些 Markdown 给 Agent（依据 14、16、17）**

分三类，共同点是「纯 Markdown + 可选 YAML frontmatter」：

- **常驻指令（每次会话载入）**：`CLAUDE.md`（Claude Code 的项目记忆，层级：企业 → 用户 → 项目 → 本地，`@import` ≤4 跳，块级 `<!-- -->` 剥离，目标 <200 行）、`AGENTS.md`（被 24+ 工具原生读取、Linux Foundation AAIF 托管、60,000+ 仓库采用的跨工具最大公约数，纯 Markdown 无 frontmatter，就近覆盖）、各家 rules（`.cursor/rules/*.mdc` 三字段 frontmatter、`.github/instructions/*.instructions.md` 的 `applyTo`、`.windsurf/rules` 的 `trigger` + 字符上限 12k/6k、`.claude/rules` 的 `paths`）（14）。
- **按需操作手册（description 匹配才触发）**：`SKILL.md`——一段带 `name`/`description` frontmatter 的 Markdown + 可选 `scripts/`/`references/`/`assets/`；渐进披露三级（metadata ~100 tokens 常驻、正文 <5k 触发时载入、附件按需读取）；开放标准 agentskills.io，一份写好可跨 30+ Agent 复用（16）。
- **工作流产物（人机共用的持久状态）**：`spec.md`（User Scenarios / MUST 需求 / Given-When-Then / `[NEEDS CLARIFICATION]`）、`requirements.md`（EARS 记法 `WHEN … THE SYSTEM SHALL …`）、`tasks.md`（可勾选 + 需求编号回溯）、`constitution.md` / steering（不可协商原则）（17）。
- 另有一类本质不同：**`llms.txt`**——喂知识不喂指令，站点/文库的策展索引（H1 项目名 + blockquote 摘要 + H2 文件列表），主要被 IDE/编码 Agent 消费（14）。

**（B）Agent 产出哪些 Markdown 给人（依据 17）**

- **计划**：`plan.md`（Claude Code / Cursor 的 Plan Mode 先出可审阅计划、批准后执行；「通往 spec 的路径永远经过文件系统」）。
- **报告**：`research.md` / `final_report.md`（deep research 的结构化带引用报告：Executive Summary → Key Findings → Sources；必须当「初稿」审，引用要可点回溯）。
- **任务状态**：`tasks.md`（`- [ ]` → `- [x]` 边做边勾，磁盘文件是跨会话/跨 Agent 的持久记忆）。
- **决策与变更**：ADR/MADR（`docs/decisions/nnnn-title.md`）、`CHANGELOG.md`（Keep a Changelog 六分类 + Unreleased）、`milestone-log.md`。

**（C）编辑器坐在中间做什么（依据 15、17、18）**

- **渲染好**：把 spec/plan/report/tasks 的语义渲染出来（Given-When-Then 着色、P1/P2/P3 徽章、`[NEEDS CLARIFICATION]` 高亮聚合成待办、需求编号可点跳转、引用可回溯、`- [ ]` 可点勾选）（17）。
- **审得动**：Agent 写入以 diff 呈现、逐 hunk 接受/拒绝、可在 diff 里直接手改；每次写前打检查点、可回滚（17、18）。
- **感知得到**：用 OS 原生 watcher（macOS FSEvents）监听 Agent 在盘上的改动，无脏改动时静默刷新、有冲突给 Reload/Ignore/Compare 三选项——**无「文件已在磁盘上更改」弹窗**（17、18）。
- **暴露得出去**：内置 MCP server 把「文库 + 活动编辑器状态」以标准接口暴露给外部 Agent；自带 Agent Skills 教 Agent 认识我们的格式与约定（15、16）。

---

## 三、功能蓝图（分层）：MVP 的「门」→ V1 落地 → V2 纵深

**分层总原则**（呼应 13 的范围克制与 18 的复杂度警报）：路线 B 的功能边界**极易失控**——Clearly 把内置 MCP 一路做到 9 个工具、连同双链/标签/索引一起加上，又在下一个大版本**全部删除**、退回「刻意无聊」（18）。因此我们的分层刻意保守：

> **MVP 只留「门」，不进「房间」。** 用户此刻「还不确定 AI 具体做什么」是真实约束——所以 MVP 阶段**不承诺任何具体 AI 功能**，只把「架构缝」留好：让 AI 能力设计为**语法树上的操作而非文本替换**、独立于编辑内核、云端/本地/协议三条通路未来皆可插入而不必重写（09、13）。这样当我们（或用户）想清楚 AI 到底做什么时，能「插」进来而不是「拆」开重做。

### 3.1 MVP：留好接口与架构缝（不做具体 AI，只保证未来能接）

| # | 功能 / 缝 | 依据文档 | 理由 |
|---|---|---|---|
| M1 | **文件监听 + 无「已在磁盘更改」弹窗**：Agent 改盘上文件即时同步，无脏改动静默刷新、有冲突给 Reload/Ignore/Compare | 17、18（markjason / SideMark chokidar / HelixNotes Notify） | 路线 B 的**最低门槛**；缺它，Agent 一改文件就弹窗打断，整个循环不成立。用 macOS FSEvents 原生实现，比 Obsidian 的「不切走再切回就看不到外部改动」更好 |
| M2 | **专编 Agent 文件的一等体验 + byte-exact 保存**：识别 `CLAUDE.md`/`AGENTS.md`/`*.mdc`/`SKILL.md`/rules 全家族并特别渲染；关掉智能引号/破折号替换、非 UTF-8 报错而非静默损坏 | 14、18（MacMD） | 我们的**核心用户故事**；写作 App 的智能标点会破坏 `.mdc` frontmatter 与代码 fence——Agent 配置文件对字节保真极敏感 |
| M3 | **Agent 产出 `.md` 的漂亮渲染 + Spotlight 索引正文** | 18（OpenMark） | 不接任何 AI 就能吃到路线 B 一半价值（「Agent 写 Markdown，我们让它变好看」）；强化「原生」卖点 |
| M4 | **架构缝：AI 层设计为「语法树上的操作」，独立于编辑内核** | 09、13、15 | 这是**最关键的一条缝**：swift-markdown 的 SourceRange + Visitor/Rewriter 让文档操作以 AST 暴露，未来 MCP/Skills/BYOK 都对齐这同一套语法树 API；现在只需把 API 边界划好，不实现任何具体 AI |
| M5 | **识别整族 Agent 相关文件名**（数据驱动的可配置表）：`AGENTS.md`/`CLAUDE.md`/`GEMINI.md`/`*.mdc`/`*.instructions.md`/`.windsurfrules`/`CONVENTIONS.md`/`llms.txt`/`SKILL.md` | 14 | 格式仍在洗牌（Roo Code 停运、Zed 退役 Rules）——把「支持哪些格式」做成「文件名 → frontmatter schema → glob 语义 → 上限」的配置表，新增工具只改配置不改代码 |

### 3.2 V1：真正落地的路线 B 功能

**顺序判断（依据 16）**：路线 B 最轻、可最先做的一环是 **Agent Skills**——在 Claude Code 表面，skill 就是 `.claude/skills/` 下一个文件夹，**无需上传、无需 API、无需我们跑任何后端**。所以 V1 先靠「写 skill 文件」兑现「让外部 Agent 安全读写我的文库」，**把更重的内置 MCP server 放到 V2**。

| # | 功能 | 依据文档 | 理由 |
|---|---|---|---|
| V1-1 | **随产品自带官方 Agent Skills**（`<editor>-markdown` / `<editor>-library`：教 Agent 我们文库的文件夹约定、frontmatter schema、wiki 链接规则、附件落盘规则），作为一个 plugin 发布到 marketplace | 16、18（kepano/obsidian-skills、MacMD） | **路线 B 最低成本落地**：零 server、零 API、零推理成本；因是开放标准，一份资产同时服务 30+ Agent；`/plugin marketplace add <我们>` 近零成本分发 |
| V1-2 | **frontmatter 表单化编辑**：检测文件类型后把 YAML 渲染成表单（`.mdc` 的 `description`/`globs`/`alwaysApply`、`SKILL.md` 的 `name`/`description`、`.claude/rules` 的 `paths`、Copilot 的 `applyTo`/`excludeAgent`），源码与表单双向同步 | 14、18 | 规则/skill 文件全靠 frontmatter；编辑器要读懂的元数据面**很小**（一个 description、一个 glob 字段、一个 always/trigger 开关），完全可做成表单——独占差异点 |
| V1-3 | **glob 感知（杀手级细节）**：对 `globs`/`paths`/`applyTo` 做实时校验 + 匹配预览（「这条规则当前匹配到仓库里的这 N 个文件」live 列表），配路径补全，把 Claude 的 `[` 转义、大括号展开等易错点做成即时提示 | 14 | 「懂 Markdown 也懂 Agent 语义」最直观的体现；别家编辑器不会做 |
| V1-4 | **多文件规则管理面板 + 有效指令预览**：侧栏聚合展示各级 `CLAUDE.md`/`.claude/rules`/`.cursor/rules`/嵌套 `AGENTS.md`，标出作用域、触发条件、合并后加载顺序与优先级，**高亮相互冲突的规则**；做「给定某文件，Agent 实际会看到的有效指令集」预览（图形化的 `/context`、`/memory show`） | 14 | 官方痛点「两条规则冲突 Claude 会任选」；碎片化的复杂度正好是编辑器用 UI 吸收的价值面 |
| V1-5 | **外部 Agent 改动以内联 diff 呈现、逐 hunk accept/reject/编辑后落盘** | 17、18（Nimbalyst） | 路线 B **头号必抄交互**，远胜「聊天框贴新版本让你自己对比」 |
| V1-6 | **统一审批策略（`Auto · Ask · Plan` 一套权限管所有 Agent 动作）** | 18（Ritemark、SoloMD accept/reject） | 安全刚需；一套模型覆盖多来源 Agent |
| V1-7 | **把 spec / 计划 / 报告渲染好**：Given-When-Then 与 EARS 着色、P1/P2/P3 徽章、`[NEEDS CLARIFICATION]`/Open Questions 高亮聚合成侧栏待办、需求编号可点跳转、引用可点回溯原文 | 17 | 「写 spec / 审报告最舒服的地方」；deep research 报告「精确率可低至 4.6%」，引用回溯是核验刚需 |
| V1-8 | **任务清单/复选框一等交互**：`- [ ]`/`- [x]` 可点勾选、完成进度、识别 `tasks.md`/`todo.md`/`plan.md`，Agent 后台改 `[ ]→[x]` 时实时反映 | 17、18（Kiro `tasks.md`） | Claude Code Tasks、Kiro、`ai-dev-tasks` 三段式的共同刚需 |
| V1-9 | **checkpoint / 本地版本历史**：Agent 每次写入前打本地快照，时间线式回滚（Restore 这一步/这个文件），定位「本地 undo」，与 git 互补而非替代 | 17（Claude Code Checkpoints / Cursor Checkpoints） | 「在编辑器里看着 Agent 干活」的安全网 |
| V1-10 | **规则/上下文文件的贴心度**：token/字符计数与超长告警（Windsurf 12k/6k、CLAUDE.md ~200 行、`MEMORY.md` 200 行/25KB）、`@import` 可点跳转 + >4 跳警告、`<!-- -->` 折叠 | 14、17、18（markjason `⇧⌘I`、Windsurf 字数上限） | 「写给 Agent 看的文件」独有的贴心度，别家编辑器不会做 |
| V1-11 | **模板库**：`AGENTS.md`/`CLAUDE.md`（含 `@AGENTS.md` 桥接段）/`.cursor/rules/*.mdc`/`llms.txt`/spec/PRD/MADR/`CHANGELOG.md`（Keep a Changelog）脚手架；模板本身就是最好的格式教学，且要精简（呼应「<200 行」「最小规格严格度」的一手忠告） | 14、17 | 新建即完整；不做又长又空的模板（LLM 生成的臃肿 AGENTS.md 反而让成功率降 2%） |
| V1-12 | **Skill Author's Workbench**：New Skill 向导（合规 frontmatter + 标准 body + 三目录骨架）、frontmatter 实时校验（`name` ≤64/仅小写字母数字连字符/禁保留词 `anthropic`/`claude`；`description` 非空 ≤1024/必检「做什么+何时用」）、渐进披露结构可视化（标注每级加载时机与 token 预算）、多目标打包（zip / `.claude/skills/` / plugin manifest） | 16 | 「技能即 Markdown」最自然、目前无人认真占据的落点；把渐进披露这个抽象机制「在编辑器里看得见」是纯文本编辑器给不了的 |
| V1-13 | **导出 AI 对话为 Markdown**（AI 侧栏一键导出对话为 `.md`） | 18（Zed `Open Thread as Markdown`） | 与「一切皆本地纯文本」自洽；对话变可归档、可版本化 |
| V1-14 | **AGENTS.md ↔ CLAUDE.md 桥接助手**：一键在 `CLAUDE.md` 顶部生成 `@AGENTS.md` 导入 stub 或建 symlink（提示 Windows 需开发者模式），把「一个真相源 + 各工具薄壳」的社区最佳实践产品化 | 14 | Claude Code 是唯一坚持 `CLAUDE.md` 的大 holdout，桥接是高频刚需 |

### 3.3 V2：生态 / 纵深

| # | 功能 | 依据文档 | 理由 |
|---|---|---|---|
| V2-1 | **内置 MCP server（stdio launcher 为主路径）**：同一 server 同时暴露「无头文库访问（基线七件套 + 结构化编辑）」与「活动编辑器状态（active file/selection，改动即时渲染）」；**核心差异化 = `apply_edit` 基于 swift-markdown 的 AST/SourceRange 结构化编辑，落盘前做合法性/AST 等价校验** | 15、13、09 | 全行业没人做 AST 级结构化编辑、没人暴露活动编辑器状态——这是原生编辑器的独占资产；接口草案见第四章 |
| V2-2 | **三原语齐用**：不像同行只堆 Tools——用 **Resources**（`editor://active`/`editor://selection` 可 `subscribe`，随用户操作推送 `updated`）+ **Prompts**（`/spec-from-notes`、`/weekly-digest` 等 slash 命令，参数经 completion 补全） | 15 | Resources 用得极少、Prompts 几乎全行业闲置——零竞争的空白 |
| V2-3 | **三方合并（共同祖先基准）+ Smart hunk grouping** | 18（SideMark） | 人机真并发时的进阶（先有 diff 再上合并）；把经典「file changed on disk」弹窗后台合并优雅化为一个 toast |
| V2-4 | **本地被动「相关笔记推荐」**（本地 embedding，零配置无 API key） | 18、13（Smart Connections、HelixNotes Tantivy） | RAG 的**轻形态**；避开 NoteGen 式重型向量库与全套「捕获→整理→Agent」（13 号点名的「AI 维护黑洞」风险区） |
| V2-5 | **Skill 画廊/市场（安装前强制源码审阅）**：浏览/安装/更新社区 skills，可 fork 到本地编辑，托管我们自家 skills 的官方画廊 | 16 | skill 会在你机器上跑代码——**安装前必须展示源码审阅视图 + 「此 skill 会运行代码」提示**，绝不静默安装 |
| V2-6 | **MCP Apps 渲染 diff 预览卡片 / 大纲导航 / 表格编辑器**（沙箱 iframe，逐块接受） | 15 | 把「diff 预览后应用」做成协议级、跨客户端的一等体验；但它是可选扩展、需协商，属加分项 |
| V2-7 | **从文库生成 `llms.txt` / `llms-full.txt`**：按目录 + 每个文件的 frontmatter `description` 自动生成规范索引并拼接全文 | 14 | 既然我们本就管理一个 `.md` 文件夹，把 Mintlify 对托管文档做的事下放给本地文库作者 |
| V2-8 | **AI 文本标注（Markdown Annotations / Authorship）**：凡经本产品 AI 生成/改写的文字自动标注来源，与 skill/Agent 生成内容联动 | 08、13、16 | iA Writer 已开源的规范，目前没有第二家开源编辑器实现——「透明 AI」品牌立场 |
| V2-9 | **JSON Canvas 读取/渲染互操作**（`.canvas` 纯 JSON 文件） | 18、第五章 | 与 files-over-apps 自洽的开放格式；kepano/obsidian-skills 已教 Agent 写 json-canvas。**注意克制**：只做读取/渲染/互操作，**不**建全功能白板编辑器（见第七章） |

---

## 四、我们 MCP server 的接口草案

> 直接整合 15 号文档的接口草案。设计原则：①**三原语齐用**（不像同行只用 Tools）；②所有 tool 打全 **annotations**（`readOnlyHint`/`destructiveHint`/`idempotentHint`/`openWorldHint`，照 Basic Memory FastMCP 3.0）；③读多篇/列结构类返回 `structuredContent` + `outputSchema`；④搜索结果用 `resource_link` 指向 `note://` 省 token；⑤写类默认走确认 + diff + 可回滚；⑥**编辑写操作一律基于 swift-markdown 的 AST/SourceRange，而非裸文本替换**（09、13）。传输以 **stdio launcher 为主路径**（随 app 分发轻量 helper，Agent 以子进程 stdio 启动，helper 经本地 IPC 拿活动状态，app 未开时退化为直接读 vault 文件）、**localhost Streamable HTTP + 本地 bearer token 为可选备胎**；stdio 权限不上 OAuth，靠 app 原生同意 + 文件作用域把关（15）。

### Tools（模型可调用的动作）

**发现 / 读取（read-only）**
- `search_notes(query, scope?, tags?, path?, limit?)` — 全文/文件名/标签范围检索，返回命中片段 + `resource_link`。
- `read_note(path|id, range?)` — 读整篇或指定行/节范围。
- `read_multiple_notes(paths[])` — 批量读取（filesystem 的效率教训）。
- `get_outline(path)` — 返回文档标题层级树/TOC（`outputSchema` 结构化，基于 AST；**填补行业空白**，省 token）。
- `list_notes(folder?, recursive?, sort?)` — 列目录/文库结构。
- `list_recent(timeframe?, limit?)` — 按最近修改列出。
- `get_backlinks(path)` — 反向链接列表（wiki 链接图）。
- `get_note_metadata(path)` — frontmatter / 标签 / 字数 / 时间戳（`outputSchema`）。
- `semantic_search(query, limit?)` — 本地 embedding 语义检索（V2，本地向量库如 LanceDB）。

**写入 / 编辑（需确认 + diff）**
- `create_note(path, content, frontmatter?)` — 新建；已存在则报错防误覆盖。
- `append_to_note(path, content, section?)` — 追加，可指定到某标题节末尾。
- **`apply_edit(path, edits[])`** — **核心差异化**：基于语法树节点/SourceRange 的结构化替换/插入/删除；落盘前做 Markdown 合法性/AST 等价校验；返回 diff。
- `insert_at_heading(path, heading, content, position)` — 在指定标题下插入（Obsidian `patch_content` 的语义化、AST 化版本）。
- `set_frontmatter(path, kv)` / `add_tags(path, tags)` / `remove_tags(path, tags)` — 元数据/标签管理。
- `move_note(from, to)` / `rename_note(path, newName)` — 移动/重命名并**自动修复全库 wiki 链接引用**。
- `delete_note(path, toTrash=true)` — 删除，默认进废纸篓（`destructiveHint`，不硬删）。

**机械转换（路线 A 的轻量能力，深入归 14 号）**
- `format_note(path)` — 保存即格式化（表格对齐、列表规整），AST 等价校验。
- `convert_to_markdown(source)` — 粘贴/文件转 Markdown。

**活动编辑器（IDE 范本，笔记 app 空白区）**
- `get_active_note()` — 当前正在编辑的文档路径 + 内容。
- `get_selection()` — 当前选区文本 + 结构范围（含所属标题/行号）。
- `replace_selection(content)` — 替换选区（diff 预览 + 确认，即时渲染）。
- `apply_edit_to_active(edits[])` — 对活动文档做结构化编辑并即时渲染。
- `open_note(path, reveal_heading?)` — 在编辑器中打开/定位到某文档或标题。

### Resources（应用提供的、可订阅的只读上下文）

- `note://{path}`（**resource template**，路径可经 completion 补全）— 单篇文档内容。
- `editor://active` — 当前活动文档；**可 `subscribe`**，随用户切换/编辑推送 `updated`。
- `editor://selection` — 当前选区；**可 `subscribe`**，随选择变化推送。
- `vault://structure` — 当前文库的目录/大纲树（供宿主自动注入上下文）。
- `vault://recent` — 最近文档列表。
- `vault://tags` — 标签索引。
- `outline://{path}` — 某文档的结构化大纲。
- （用 `file://` 或自定义 scheme；`annotations` 带 `lastModified`/`priority`/`audience`。）

### Prompts（用户触发的模板化 slash 命令，全行业空白）

- `/summarize-note` — 总结当前/指定文档。
- `/polish-selection` — 按项目写作规范润色选区。
- `/make-toc` — 为当前文档生成目录。
- `/extract-tasks` — 从文档抽取待办为任务清单。
- `/weekly-digest` — 汇总本周笔记（Logseq/Bear 的按日聚合语义）。
- `/spec-from-notes` — 把散记整理成规格文档（面向开发者：CLAUDE.md/AGENTS.md/spec 场景，**路线 B 的招牌用例**）。
- `/turn-into-table` — 选中文本转 Markdown 表格（路线 A 机械活）。

> **配套 Skill（V2，与 15/16 分工）**：MCP 上线时配一个 Agent Skill 教 Agent「何时、以何顺序、注意哪些坑」来用这些工具——*MCP 给「访问权」，skill 给「怎么用」；skill 是 MCP 的说明书*（16）。二者合璧才安全好用。

---

## 五、要支持 / 采纳的标准（各一句话说清为什么）

| 标准 | 一句话为什么 | 依据 |
|---|---|---|
| **AGENTS.md** | 被 24+ 工具原生读取、Linux Foundation AAIF 托管、60,000+ 仓库采用的**跨工具最大公约数**，纯 Markdown 无 schema——把它当一等公民、当文库的单一真相源，是路线 B 最稳的收敛面。 | 14 |
| **MCP（Model Context Protocol）** | 把「编辑器 ↔ 外部 Agent」做成**协议而非聊天框**的关键；当前正式版 **2025-11-25**（下一版处候选阶段），已捐给 Linux Foundation AAIF；以 stdio 为主暴露「文库 + 活动编辑器状态」给用户已付费的 Agent，我们零推理成本、零隐私责任。 | 15 |
| **Agent Skills（`SKILL.md`）** | **技能即 Markdown**（frontmatter + 正文 + 附件），恰是我们的主场；开放标准 agentskills.io（2025-12 起，AAIF 托管），一份写好可跨 30+ Agent 复用，且在 Claude Code 里只是 `.claude/skills/` 一个文件夹——**路线 B 最轻、可最先落地**的一环。 | 16 |
| **llms.txt / llms-full.txt** | 「便宜的基础设施」：既然我们本就管理一个 `.md` 文件夹，就能按 frontmatter `description` 自动生成规范索引，让 IDE/编码 Agent 准确理解文库——价值在「减少 RAG 的 token」而非 SEO（Google 已明确不支持）。 | 14 |
| **JSON Canvas** | Obsidian 发起的无限画布开放格式（spec v1.0、MIT、`.canvas` 为纯 JSON、能在 git 里干净 diff、node/edge 结构可扩展），与我们「本地纯文本、文件优先、可版本化」的数据主权叙事一致；kepano/obsidian-skills 已教 Agent 读写它——我们**采纳为读取/渲染/互操作格式**（非自建白板，见第七章）。 | 18；jsoncanvas.org 一手核对 |

> 治理观察：MCP、AGENTS.md、Agent Skills **三者现均归 Linux Foundation 旗下 Agentic AI Foundation（AAIF）托管**——押注这三个标准即押注同一个中立治理体，风险相对可控（14、15、16 交叉一手核对）。

---

## 六、安全 / 权限 / 版本模型

> 综合 15 号的 MCP 安全模型、17 号的审阅/回滚工作流、18 号的冲突合并范式与 CVE 教训，以及 13 号的隐私红线。核心立场：**人在环路是硬要求而非 SHOULD**——规范只说「SHOULD 有人在环」，我们把敏感/不可逆操作的人工确认设为**强制**。

### 6.1 威胁模型（2026 共识，依据 15）

- **Lethal trifecta（Simon Willison）**：Agent 同时具备①访问私有数据②接触不可信内容③对外通信，即构成数据外泄原语。**我们的 server 提供的正是①（整个 vault）**——管不住另两项，就必须把①的爆炸半径压到最小。
- **Prompt injection via 笔记内容**：vault 里的 Markdown（尤其网上剪藏的）本身可能含注入指令，喂给 Agent 等于把不可信内容送进②。
- **Confused deputy**：Agent 在合法权限内被诱导做部署者没打算的事——最难防，只能靠最小权限 + 逐操作确认 + 审计。
- **我们天然免疫的一条**：tool poisoning / rug pull——因为 server 由本体 app 分发、tool 定义静态可控（前提是**不动态从网络拉 tool 描述**）。

### 6.2 确认（Agent 写你的文件前）

- **读写分级**：给每个 tool 打 annotations；读类在作用域内可默许，**写/移动/删一律要确认**。
- **确认通道**：走 MCP **Elicitation**（server 侧发起结构化确认，显示是哪个操作、影响哪篇、diff 摘要，提供拒绝/取消）或 app 原生对话；进阶用 MCP Apps 在对话里渲染沙箱 diff 卡片逐块接受（15）。
- **一套审批策略**：`Auto · Ask · Plan` 式的统一权限模型覆盖所有 Agent 动作与来源（18 Ritemark），外加全局「AI 只读」总闸。

### 6.3 范围（Agent 能看到/改到什么）

- **作用域最小化**：server 只在用户**显式选定的 vault 文件夹**内工作；尊重 client 传来的 **Roots**；提供文件夹级 allowlist/denylist 与标签级 exclude（照抄 Bear 的 Only-tags/Exclude-tags、Joplin 的 notebook allowlist）。
- **默认排除**：`.git`、`.env`、密钥类文件与**加密/受保护笔记**（Bear：加密笔记可列不可读）（15）。
- **逐 tool 开关**：每个 tool 可单独禁用（Joplin `JOPLIN_TOOL_<NAME>` 模式）。
- **默认不跨机远程暴露**，远程访问为显式 opt-in 的高级项；MCP/AI 默认 **opt-in**（MarkMorph 姿态）、可整体关闭、发送前可视化将上传内容（08、18）。

### 6.4 审计（记录发生了什么）

- **全量审计日志**：记录每一次 `tools/call`（谁、何时、改了哪篇、diff 摘要）——规范也建议为审计而 log（15）。

### 6.5 撤销 / 回滚

- **会话级 checkpoint**：一次 Agent 会话开始前打检查点，整段会话可**一键回滚**（对接 13 的版本历史/内置 Git）。
- **每次写前本地快照**：定位「本地 undo」，与 git 互补而非替代（17 Claude Code/Cursor Checkpoints）；删除**默认进废纸篓不硬删**（13 红线：绝不永久删）。

### 6.6 冲突合并（人机真并发，依据 18）

按「重 → 轻」三档，分阶段落地：
- **MVP**：文件监听 + 无「已在磁盘更改」弹窗（markjason 级）。
- **V1**：外部 Agent 改动以 diff 呈现、逐 hunk 接受/拒绝（Nimbalyst 级）。
- **V2**：**三方合并**——以「上次已知版本」为共同祖先，人改引言、Agent 改结论时后台静默合并、仅一个 toast；只有改到同一行才弹逐 hunk 交互式 diff，并有 **Smart hunk grouping**（把「标题 + 正文」这类相关改动并成一次决定）（SideMark 级）。

### 6.7 结构化编辑降低误伤 + HTTP 暴露的硬教训

- **`apply_edit` 走 AST 而非盲覆盖**，落盘前做合法性/等价校验；每次写都产出可预览 diff（15）。
- **若开 localhost HTTP**：鉴权 + 路径校验 + 最小权限 + 默认 localhost/可关，**第一天做对**——Obsidian Local REST API 在 2026-06 修过一个已认证路径穿越 CVE（GHSA-62gx-5q78-wrvx），「把本地文库经 HTTP 暴露给 Agent」是真实攻击面（18）。不做 token passthrough、localhost token 短时有效（15）。

---

## 七、克制原则：保持「简洁 Markdown 编辑器」而不膨胀成 IDE

路线 B 的功能边界**极易失控**，18 号文档给了两条活体警报：**Clearly** 把内置 MCP 做到 9 个工具、连同双链/标签/索引一起加上，又判断这偏离「简洁」而**主动删光**、退回「刻意无聊」，其 `CLAUDE.md` 现在明确叮嘱「想加这些基础设施时要往回推」；**cmux** 则证明——一旦要「跑 Agent 运行时」，最终会长成一个终端多路复用器，而不是一个漂亮的 Markdown 编辑器。**克制，就是我们相对这一整簇新物种的最大差异化。**

### 明确的「不做」清单（依据 18、13）

| 不做 | 反例 / 教训 | 我们的处置 |
|---|---|---|
| **不内嵌 CLI Agent 终端 / 多运行时宿主** | Ritemark（侧栏多运行时 + 终端）、Nimbalyst（ghostty）、cmux（干脆是终端） | 同样「让外部 Agent 干活」的需求，用**簇 A 的 MCP server**（我们当数据源）实现更轻；只搬「统一审批」「评论 @agent」两个交互，**不搬运行时** |
| **不自建 RAG / 向量索引 / 全套「捕获→整理→Agent」工作流** | NoteGen（重）、Trilium「AI 是维护黑洞」教训 | RAG 降级为 V2 之后的「本地 embedding 被动推荐」轻形态；不做捕获-整理-Agent 全家桶 |
| **不顺手把「MCP + 双链 + 标签 + 索引 + chat」一起堆上** | Clearly 加到 9 工具 + 双链又整体删除 | MCP 做成**可选、可关、边界清晰的一层**；双链/标签是独立取舍，不因为做了 MCP 就顺势全上 |
| **不做 7+ 种内嵌可视化编辑器**（代码/CSV/Excalidraw/ERD…） | Nimbalyst 把编辑器变工作台 | 只做 Markdown（+ 预览 Mermaid/KaTeX）；JSON Canvas 只做**读取/渲染/互操作**，不建全功能白板 |
| **不做块编辑器 / 数据库 / 全功能 PKM** | Notion/AFFiNE 的战场，功能广而不深 | 守住「编辑器」的定义力；不做全功能知识管理 |
| **不做全家桶式 AI 军备竞赛** | Trilium 内置多供应商 AI 后因维护不可持续移除 | 薄封装 + 协议化（MCP/Skills），不在核心内置重型 AI 管线 |
| **不把 MCP 经 HTTP 暴露做得不设防** | Obsidian Local REST API 路径穿越 CVE | 鉴权 + 路径校验 + 最小权限 + 默认 localhost/可关，第一天做对 |
| **不默认开启、静默上传的 AI** | 精品阵营（iA/Ulysses/Bear）都不默认云 AI | MCP/AI 默认 opt-in、可整体关闭、发送前可视化 |

**一条判断准则**：编辑器对 MCP / Skills / 工作流的角色是「**舒服地编写其配套的 Markdown/frontmatter，并感知/审阅其产出**」，而非「内置运行时」（14）。凡是要「在编辑器里跑 Agent / 跑模型 / 建向量库 / 建白板」的，都往协议那一侧推——让用户已付费的 Agent 去跑，我们只当界面。

---

## 八、待验证的开放问题（靠 dogfooding 发现，而非现在拍板）

用户「还不确定 AI 具体做什么」是**正确的克制**，不是缺陷。下列问题应靠「自己用自己的工具」（我们本就要用编辑器写 `CLAUDE.md`/spec、用 Claude Code 读写本仓库的 `.md`——17 号文档本身就是一个「Agent 产出 → 人审阅」的样例）去发现，而非在 MVP 就拍死：

1. **MCP server 到底要不要做、做到多深？** 15 号给了完整接口草案，但 Clearly「加了 9 工具又删光」提示需求可能被高估。**待验证**：先只发 Agent Skills（V1，零 server）观察——如果「skill 教 Claude Code 操作文库」已覆盖多数场景，MCP server 的 AST 结构化编辑是否还值得那份工程量？（16 明确 skill 可先行、MCP 留 V2）

2. **`apply_edit` 的 AST 级结构化编辑，用户/Agent 真的会用吗？** 这是我们相对全行业的独占差异化（09、15），但也是最重的一块。**待验证**：在真实任务里，Agent 用「第 2 个二级标题下那段列表的第 3 项」这种结构坐标，比裸文本 diff 到底省多少错、值不值那份复杂度。

3. **活动编辑器状态（active file/selection）暴露给 Agent，高频到什么程度？** IDE 侧有、笔记 app 全无（15）。**待验证**：「润色我选中的这段」「在光标处插入表格」这类活动态交互，是日常刚需还是偶发——决定它是 V1 还是 V2。

4. **哪些 Prompts（slash 命令）是真高频？** 15 号列了 7 个候选（`/spec-from-notes`、`/weekly-digest`…），但全行业 Prompts 原语闲置、无先例数据。**待验证**：自己用一段时间，看哪几个真被反复触发，再固化——而非一次性堆一堆。

5. **规则冲突高亮、有效指令预览（V1-4）值不值得做重？** 官方说「两条规则冲突 Claude 会任选」（14），但用户实际有几条规则、冲突多不多？**待验证**：先做轻量的「多文件规则列表 + 加载顺序」，观察用户是否真需要图形化 `/context` 那种深度。

6. **本地 embedding 相关笔记推荐，是加分还是「AI 维护黑洞」的入口？** 13/18 都警告 RAG 的复杂度。**待验证**：先上零配置的被动推荐（Smart Connections 范式），用数据决定要不要往「全库问答」深入——而非一上来就建向量库。

7. **AI 文本标注（Authorship）在「编辑器不生成内容」的路线 B 下，标注对象是谁？** 路线 B 里内容多来自外部 Agent 而非本编辑器（08、16）。**待验证**：当生成发生在 Claude Code 而非我们的侧栏时，怎么把「这段是 AI 写的」的归属信息落进 `.md`——是不是要扩展 Markdown Annotations 规范去覆盖「外部 Agent 产出」。

8. **格式支持表要多大？** 14 号列了一整族文件名与 frontmatter schema，但工具在洗牌（Roo Code 停运、Zed 退役 Rules、Windsurf 归 Cognition）。**待验证**：把支持范围做成数据驱动配置表后，实际只需覆盖哪几个「活着且高频」的格式——用真实使用频率裁剪，而非追全。

**方法论**：这些问题的共同解法是「盯住一个真实任务反复迭代，成功后再把做法固化成功能/skill」（16 的评估驱动开发）——我们边用边发现，而不是现在就把 AI 功能面锁死（呼应 13 号「防止 AI 功能面失控」的 Trilium 教训）。

---

## 附：核心结论一页纸

1. **命题**：编辑器 = 人 ↔ Agent 的 Markdown 界面——写给 Agent 的、Agent 写给人的 Markdown 都在这里最顺手，并用原生 swift-markdown 的 AST/SourceRange 把「Agent 安全读写文库」做得比任何裸文本方案更精确；这是精品原生阵营集体留白、且无人用原生技术占据的空位（08、09、13、18）。
2. **循环**：人写常驻指令/规则/spec（14、16、17）→ Agent 读、干活、产出计划/报告/变更（17）→ 编辑器渲染好、审得动、感知得到、暴露得出去（15、17、18）。
3. **分层**：MVP 只留「架构缝」（文件监听 + byte-exact + AST-as-API，不做具体 AI）；V1 靠 **Agent Skills（零 server）** 兑现路线 B + frontmatter 表单 + diff 审阅 + spec/tasks 渲染；V2 上**内置 MCP server（AST 结构化编辑 + 活动状态 + 三原语）** 与三方合并、被动 RAG。
4. **标准**：押 AGENTS.md / MCP / Agent Skills（三者同归 Linux Foundation AAIF）+ llms.txt + JSON Canvas。
5. **安全**：作用域最小化 + 逐操作强制确认（人在环路是硬要求）+ 全量审计 + checkpoint 回滚 + 三方合并 + HTTP 暴露第一天做对；MCP/AI 默认 opt-in、可整体关闭。
6. **克制**：不内嵌终端、不自建 RAG、不做块编辑器/白板/全功能 PKM、不搞 AI 军备竞赛——克制就是最大差异化。
7. **开放问题**：MCP 深度、AST 编辑的实用性、活动态频率、高频 Prompts、规则冲突深度、被动 RAG 边界、Authorship 归属、格式表大小——全靠 dogfooding 发现，不在 MVP 拍板。
