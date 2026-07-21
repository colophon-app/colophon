# 编辑器作为「人-Agent Markdown 界面」：竞品与功能拆解

> 调研日期：2026-07-21 ｜ 第二阶段·路线 B 专题 ｜ 一手来源：各产品官网 / GitHub·Codeberg README / 官方文档 / 发布说明（本文所有数字与接口名均来自当次核对，凡未核实处标「未知」）。
>
> **总体观察**：路线 B（编辑器 × AI Agent 深度集成）在 2025–2026 已经从「设想」变成「拥挤的新赛道」——本文详细拆解的就有十余款编辑器把「人和 Agent 一起读写同一批 `.md` 文件」当作核心命题。集成方式高度收敛为**两条协议主线加一个接收态**：① **MCP**（编辑器把 vault 暴露成 Agent 可读写的数据源，编辑器当「后端」）；② **ACP / 内嵌运行时**（编辑器把 Claude Code、Codex 等 CLI Agent 接进来当「宿主」，编辑器当前端）；③ **纯接收端**（编辑器不接 Agent，只把 Agent 产出的 Markdown 渲染得好看）。真正稀缺、值得抄的不是某个炫技点，而是一批**「人机并发编辑」的冲突交互**：内联红绿 diff 逐条 accept/reject、以共同祖先为基准的三方合并、文件监听实时同步——这是任何「可接入 AI」的编辑器几乎必然要解决的问题。同时有清晰的**复杂度警报**：Clearly 把内置 MCP server（一路做到 9 个工具）连同双链、标签一起加上，又在下一个大版本**全部删除**，退回「刻意无聊」的极简编辑器——提示 Route B 的功能边界极易失控。结论先行：我们应抄「**协议接入 + diff/合并 UI + 规则文件的编辑体验**」，避开「**内嵌终端 + 自建 RAG + 多编辑器工作台**」这类把简洁编辑器拖成 IDE 的陷阱。

---

## 〇、先厘清两条协议主线（细节归 15 号，本文只做产品级区分）

理解后面所有竞品，先抓住这三种「编辑器 ↔ Agent」的接法。它们决定了「由此带来哪些编辑器功能」，也直接决定我们该抄哪条：

| 接法 | 谁主动 | 编辑器角色 | 代表协议 / 实现 | 典型产品 | 对我们的取舍 |
|---|---|---|---|---|---|
| **A. 编辑器当数据源** | 外部 Agent 连进来读写 | 后端 / vault | **MCP**（编辑器内置 MCP server） | VMark、Clearly(旧版)、SoloMD、MarkMorph、Obsidian Local REST API | **首选**：零推理成本、零隐私责任、复用用户已付费的 Claude/Cursor |
| **B. 编辑器当 Agent 宿主** | 编辑器把 CLI Agent 拉进来跑 | 前端 / GUI | **ACP**（Agent Client Protocol）或内嵌终端 | Ritemark、Nimbalyst、Zed、cmux | **谨慎**：能力强但把编辑器推向 IDE，与「简洁」冲突；我们倾向不内嵌终端 |
| **C. 纯接收端** | 无 Agent 集成 | 渲染器 | 无（人工粘贴 / 外部 Agent 改盘上文件） | OpenMark、MacMD、markjason | **兜底**：把 Agent 产出的 `.md` 显示得好看，配合文件监听即可 |

- **MCP（Model Context Protocol）**：编辑器起一个 server，暴露 `read_note` / `search` / `patch` 等工具，外部 Agent（Claude Desktop、Claude Code、Cursor、Codex）当 client 连进来操作 vault。**「编辑器不自建 AI，把 AI 交互外包给用户已付费的客户端」的最轻实现。**
- **ACP（Agent Client Protocol）**：Zed 于 2025 年联合 Google 推出、Apache 协议的开放标准，定位「AI Agent 界的 LSP」——让任意 CLI Agent（作为子进程用 ACP JSON-RPC 通信）接进任意支持 ACP 的编辑器 GUI，从而拿到实时编辑可视化、multi-buffer diff review 等终端里做不到的体验。2025 年底 **JetBrains 全家桶宣布采纳 ACP**，2026-01 Zed 与 JetBrains 合launch **ACP Agent Registry**（可在编辑器内浏览接入 Claude Code / Gemini CLI / Codex / OpenCode / Goose / Cline / Copilot CLI 等）。Claude Code 经 Zed 自建的 `@zed-industries/claude-code-acp` 适配器接入（Anthropic 官方尚未采纳 ACP）。
- **Agent Skills（`SKILL.md`）**：不是连接协议而是「教程包」——用结构化 `SKILL.md` 教 Agent 如何使用某个工具/格式（见 MacMD 的 `skills/macmd/SKILL.md`、kepano/obsidian-skills）。

> 一句话记忆：**MCP = 让 Agent 进来读写我的文库；ACP = 让 Agent 的运行时住进我的界面；Agent Skills = 教 Agent 认识我的格式。** 我们路线 B 的重心应压在 MCP + Agent Skills（轻、协议化），ACP/内嵌终端只做观察。

---

## 一、新物种簇 A：内置 MCP server（编辑器即 Agent 的可读写数据源）

> 这是与我们定位最契合的一簇：编辑器自己不生成内容，只把「打开的文件夹」变成 Agent 能安全读写的 vault。共同架构：本地 `.md` 文件 + 编辑器进程内跑一个 MCP server + 一个开关 + （最好有）审批。

### VMark（xiaolai/vmark）— 原生内置 MCP server 的标杆

- **基本信息**：李笑来个人项目｜macOS 等桌面｜ISC 开源｜github.com/xiaolai/vmark 约 **417 star、66 fork**｜TypeScript 83.8% / Rust 10.6%｜v0.9.5（2026-07-19），活跃；「vibe-coded」只收 Issue 不收 PR。
- **如何集成 Agent**：**原生内置 MCP server**（仓库内 `vmark-mcp-server` 目录）。启用方式极简：`Settings → Integrations → Install`，**每个助手一键装**；支持 Claude Desktop、Claude Code、Codex CLI、Gemini CLI 直接连入读写「当前文档 / 同一批纯文本」。README 未公开逐个 MCP 工具清单与显式审批框架（这部分归 15 号深挖）。
- **由此带来的编辑器功能**：三态编辑 **WYSIWYG（Tiptap/ProseMirror）/ Source Peek（F5 源码浮窗）/ Source Mode（F6，CodeMirror 6）**；双内核 = 人机都能选自己舒服的视图看同一份 `.md`。技术栈 Tauri v2 + React 19。
- **可借鉴**：1）**「编辑器自带 MCP server + 每助手一键安装」是把 AI 集成做成「协议开关」而非「聊天框」的范式**，零 AI 成本、零隐私责任；2）双内核三态切换的架构（即便我们用原生 TextKit，概念可移植：源码态 / 混合渲染态 / 纯预览态）。
- **不足**：MCP 工具面与审批策略文档化不足（用户难判断 Agent 能改什么）；Tauri 文本编辑性能与 IME 处理仍是社区常提的坑；非原生 UI。

### Clearly（Shpigford/clearly）— 「加了 MCP 又删掉」的关键复杂度案例

- **基本信息**：Josh Pigford｜macOS 15+ / iOS 17+｜**FSL-1.1-MIT**（两年后转 MIT）｜github.com/Shpigford/clearly 约 **1.1k star**｜Swift 78.1%｜v3.2.0（2026-05-17）｜依赖 cmark-gfm / Sparkle / KeyboardShortcuts。
- **如何集成 Agent（一条完整的演化弧，最有价值）**：早期版本**内置 MCP server**，把 vault 暴露给 Agent 检索——且 `clearly` CLI 可从 `Settings → Command Line` 安装，供终端与 MCP client 访问。据 changelog，其 MCP server 从 3 个工具**成长到 9 个**：读类 `read_note` / `list_notes` / `get_headings` / `get_frontmatter`，写类 `create_note` / `update_note`，每个工具返回结构化 JSON、经 MCP 发布 input/output schema、带稳定 error 标识。**然后在后续大版本里把 vault 索引、chat、wiki、CLI/MCP 集成全部移除**，退回「专注、无干扰」的极简编辑器；其 `CLAUDE.md` 现在明确声明：刻意不做 vault 索引、同步、AI、MCP server、侧栏、wiki 链接、标签、反向链接、命令面板，并叮嘱「想加这些基础设施时要往回推」。
- **由此带来的编辑器功能（现状）**：源码 + 语法高亮，一键切预览或 side-by-side 同步滚动；⌘B/⌘I/⌘K 快捷格式；⌘F 正则查找；标题树大纲跳转。（旧版还有 `[[wiki 链接]]`、反向链接、`#tag`——已删。）
- **可借鉴**：1）**它的 MCP 工具设计（读写分离的 6–9 个工具 + 结构化 JSON + published schema + 稳定错误码）是一份现成的、原生 Swift 的 MCP server 规格**，可直接对标；2）`clearly` CLI + MCP 双通道（终端脚本 / Agent 皆可驱动）的分发思路。
- **不足 / 教训（这是本条最大价值）**：**Clearly 是「Route B 功能会失控」的活体警报**——一个原生 Swift 精品编辑器把「内置 MCP + 双链知识库」做全，又判断这偏离了「简洁」而**主动删光**。对我们的直接启示：MCP server 值得做，但要把它做成**可选、可关、边界清晰的一层**，不要顺势把双链/RAG/索引一起堆进来，否则迟早要像 Clearly 一样回撤。

### SoloMD（zhitongblog/solomd）— MCP server 可脱离 App 独立驱动任意文件夹

- **基本信息**：macOS / Windows / Linux / iPad / iOS / Android｜**MIT**｜github.com/zhitongblog/solomd 约 **451 star**｜Tauri 2 + Vue 3 + CodeMirror 6｜macOS universal dmg 约 32MB（Win/Linux 约 10MB）｜v4.9.5（2026-07-19）。
- **如何集成 Agent**：**双面接入**——① 编辑器内 **Agent Panel（v4.0）**：streamed chat-with-vault、inline tool-call cards、`Insert/Copy` 按钮把回答直接落进当前笔记；② 独立 **`solomd-mcp` server**：经 stdio、**无需网络端口**，暴露 **13 个工具（8 个通用 + 5 个 SoloMD 专属）**，**且不装 SoloMD App 本体也能对任意 `.md` 文件夹跑**，供 Claude / Cursor / Cline / Continue / Zed 从外部驱动。定时任务以 YAML「recipe」存 `<workspace>/.solomd/agents/`，配 **AutoGit 分支沙箱 + accept/reject** 后再并回 main。BYOK **14 家 provider**（OpenAI·Claude·Gemini·DeepSeek·Qwen·GLM·Kimi·Doubao·SiliconFlow·OpenRouter·Mistral·Groq·xAI·Ollama），OS keychain 存 key。
- **可借鉴**：1）**「MCP server 可独立于 App 运行、驱动任意文件夹」是极聪明的分发策略**——用户不装你的编辑器也能先用你的 MCP，降低尝试门槛、扩大生态入口；2）**定时 Agent 任务跑在 AutoGit 分支沙箱 + accept/reject 合并**，是「后台 Agent 不污染主线」的安全范式；3）Insert/Copy 把 chat 结果**落进当前笔记而非停留在对话框**。
- **不足**：Tauri WebView 非原生手感；14 provider + Agent Panel + 定时 recipe 概念偏重；小团队可持续性待观察。

### MarkMorph（Lukasz Raczylo）— opt-in MCP + 力导向 Thought Map

- **基本信息**：Lukasz Raczylo｜macOS 原生｜**闭源**（App Store，v1.4.1）｜local-first，打开任意 `.md` 文件夹为 vault。
- **如何集成 Agent**：**opt-in（可选开启）的 MCP server for Claude and Cursor**——「让 Claude Code 或 Cursor 真正读写你的知识库，而不只是聊」。另有应用内 **AI side panel**。
- **由此带来的编辑器功能**：`Cmd+P` quick switcher、backlinks 面板、Mermaid（点击放大）、`[[wikilinks]]` + **力导向 Thought Map**、custom note types、frontmatter。
- **可借鉴**：1）**「MCP 默认关、用户显式 opt-in」的隐私姿态**（比默认开更符合我们的隐私叙事）；2）AI side panel 与 MCP server 并存 = 「近处轻改写 + 远处 Agent 驱动」双通道。
- **不足**：闭源、生态早期；力导向图谱等偏 PKM 功能与「简洁」有张力。

### OpenKnowledge（Inkeep）— YC 背景团队的开源入场（一句话+）

- **基本信息 / 集成**：Inkeep（YC 背景文档 AI 公司）于 **2026-06-27** 发布的**免费开源 WYSIWYG Markdown 编辑器**，把 **Claude Code / OpenAI Codex / Cursor 的集成直接内建进 App**，让 Agent 读写本地 `.md` 而不经云端。原生桌面**仅 Apple Silicon**，Intel/Win/Linux 需经 CLI 以 Web 应用形式运行。（其为「直接集成」而非明确 MCP，接法细节归 15 号；协议归属未完全公开。）
- **对我们的意义**：**有 VC 背景的团队已经入场**这条赛道——竞争窗口在收窄，且「仅 Apple Silicon 原生、其余走 Web」正反衬出「**全 macOS 原生**」仍是可占的差异点。

**簇 A 小结**：这簇是我们的直接参照系。**要抄的是「内置 MCP server + 显式开关 + 读写分离的少量工具 + 结构化返回」这一层**；要警惕的是 Clearly 式的「顺手把双链/RAG/索引都加上」。SoloMD 的「MCP 可独立驱动任意文件夹」、MarkMorph 的「默认 opt-in」、Clearly 的「9 工具规格 + 主动删除」三点各值一抄/一戒。

---

## 二、新物种簇 B：人机并发编辑的冲突解法（内联 diff / 三方合并 / 实时同步）

> 一旦「人在 GUI 改、Agent 在盘上改同一个文件」，就必然撞上冲突。这簇产品给了三种成熟范式，是本文**最该抄**的交互。

### Nimbalyst（Nimbalyst/nimbalyst）— 内联红/绿 diff 逐条 accept/reject 的标杆

- **基本信息**：macOS（Apple Silicon + Intel）/ Windows / Linux + iOS/Android 伴侣｜**MIT**｜github.com/Nimbalyst/nimbalyst 约 **1.3k star、173 fork**｜v0.68.1｜**Electron / TypeScript monorepo**（TS 92.3%，含少量 Swift/Kotlin 供移动端）。（注：属「web 技术打包」，非原生。）
- **如何集成 Agent**：定位「**Claude Code 与 Codex 的可视化工作区**」，另支持 Opencode（alpha）、Copilot（alpha）经 **ACP** 接入；多会话并行、单界面监控。**每个会话跑在隔离的 git worktree**；内嵌 **ghostty 终端**；git 状态管理 + AI 生成 commit message。
- **由此带来的编辑器功能（核心范式）**：**AI 的每处改动 = 内联红/绿 WYSIWYG diff，可逐条 approve / edit / annotate / reject 后再落盘**；WYSIWYG ↔ 原始 Markdown 随时切换；自动版本历史（时间戳浏览 + 一键回滚）；**7+ 种可视化编辑器**（Markdown / Monaco 代码 / CSV / Mockup 标注 / Excalidraw / Data Model / Mermaid）均支持 AI 辅助；kanban 任务板（Agent 可增删移执行任务）。内容与元数据全部纯 Markdown / 标准文件本地存、可 git 版本化。
- **可借鉴**：1）**「AI 改动 = 内联红/绿 diff + 逐 hunk 接受/拒绝」是路线 B 的头号必抄交互**——远胜「聊天框里贴新版本让你自己对比」；2）**会话跑在隔离 git worktree**，天然解决「多个 Agent / 人机同时改不打架」；3）自动版本历史 + 一键回滚作为 AI 编辑的安全网。
- **不足**：更像「AI 文档/编码工作台」而非纯写作工具，对不写代码者偏重；7+ 编辑器 + 多会话 + 终端 = 典型的「越做越像 IDE」，正是我们要避的方向。

### SideMark（avanrossum/sidemark）— 以共同祖先为基准的三方合并

- **基本信息**：avanrossum｜macOS 12+（Apple Silicon）｜**MIT**｜github.com/avanrossum/sidemark 约 **3 star**、35 个 release、v1.0.7（2026-03-30）｜**Electron 33 + React 18 + CodeMirror 6 + marked**。**⚠️ 更正 10 号文档**：SideMark 是 **Electron**，并非「原生 macOS（Swift）」——其价值在「三方合并交互范式」，不在技术栈。
- **如何集成 Agent**：架构专为「人 + AI Agent 并发编辑同一文件」而设计，本身不含模型。用 **chokidar 监听文件系统**检测外部改动；**三方合并（three-way merge）**：以「上次已知版本」为共同祖先，人改引言、Agent 改结论时后台静默合并、**仅一个 toast 提示**，没有「文件已在磁盘上更改」弹窗、无覆盖丢失；只有当两边改到同一行才弹出**逐 hunk 可 accept/reject 的交互式 diff**，并有 **Smart hunk grouping**（把「标题 + 正文」这类相关改动并成一次决定，而非逐行轰炸）。另有 `sidemark://` **深链协议**（Agent 可用终端命令/可点链接直接打开文件）、**Copy with Context（⌘⌥C）**（复制时前置文件路径与行号，专为粘进 AI 对话窗口设计）、可配 1–10 秒自动保存、git gutter 增/改/删标记。
- **可借鉴**：1）**三方合并 + 「file changed on disk」老痛点被后台合并优雅化解**——所有编辑器的经典弹窗，被它变成一个 toast，是明确的差异化体验点；2）**Smart hunk grouping**（按语义分组的 diff 决策）优于逐行；3）`sidemark://` 深链 + Copy-with-Context 让「Agent → 编辑器」「编辑器 → Agent 对话」双向都顺。
- **不足**：极小众（3 star）、功能面窄（专注单文件协作，无文库/双链）；Electron。

### markjason（markjason.sh）— 只做 `.md/.json/.env` 的实时监听同步

- **基本信息 / 集成**：原生 macOS，只处理 `.md / .json / .env`｜**0.3 秒打开、约 100MB 内存**｜闭源（未见公开源码）。核心是 **live file sync**：把 `AGENTS.md` 开着让 Claude Code 干活，Agent 一改文件**即时刷新、无刷新按钮、无「file changed on disk」弹窗**（监听外部改动自动更新视图）。附 `⇧⌘I` 看 token 数、JSON 实时校验 + 可折叠树、`.env` 一键复制、「渲染后 Markdown 复制成图」给非技术同事。**dark mode only**（面向开发者的刻意取舍）。
- **可借鉴**：1）**「Agent 改盘上文件、编辑器无弹窗即时同步」是纯接收态的最小刚需**——比三方合并轻，是我们文件监听的第一优先级；2）**把作用域收到 `.md/.json/.env` 三种 Agent 相关文件**，是「给开发者读改 Agent 上下文文件」的极窄清晰定位；3）`⇧⌘I` token 计数对「写给 Agent 看的文件」很实用（用户在乎 CLAUDE.md 吃多少 context）。
- **不足**：闭源；能力极窄（阅读/轻改为主）；dark-only。

**簇 B 小结**：三条范式按「重 → 轻」= **三方合并（SideMark）> 内联红绿 diff 逐条接受（Nimbalyst）> 文件监听即时同步无弹窗（markjason）**。我们至少要做 markjason 级（**文件监听 + 无「已在磁盘更改」弹窗**）作 MVP，V1 补 Nimbalyst 级（**外部 Agent 改动以 diff 呈现、逐 hunk 接受/拒绝**），SideMark 的三方合并 + Smart hunk grouping 作为「人机真并发」时的进阶目标。**这簇是本文对路线图最硬的输入。**

---

## 三、新物种簇 C：内嵌 Agent 运行时 / 侧栏 / 终端（我们倾向不走，但要看懂）

### Ritemark（jarmo-productory/ritemark-public）— 统一审批策略 + 多运行时侧栏

- **基本信息**：jarmo-productory｜macOS（Apple Silicon/Intel）/ Windows｜**MIT**｜github.com/jarmo-productory/ritemark-public 约 **7 star**、30+ release、v1.8.x（2026；技术栈 Electron/Tauri 未标明）｜官网 ritemark.app。
- **如何集成 Agent（本条重点）**：**AI Sidebar 里放多个运行时**——内置 Ritemark Agent（快速文本编辑）+ Claude Code（深度重构）+ OpenAI Codex（代码感写作）+ **OpenCode（v1.7.3，BYOK，经 ACP 接入）**；**「浏览器登录，无需装终端/CLL」**（三个 agent 一个侧栏）。**v1.8.0 起把三个运行时收进一套内部架构 + 单一审批策略 `Auto · Ask · Plan`**，并给 Codex/OpenCode 补上文件附件。**v1.8.3 加评论**：选中文本 → Comment 生成高亮锚点 + Google-Docs 式页边批注，`///` 快速独立批注；**在评论里 `@claude` / `@codex` / `@opencode` 再 Send to AI，把该段精确转给侧栏 Agent；评论存进 Markdown 文件本身、可持久化**。另有「完整 CLI 终端也内置，想用才用」（即终端是可选、非主路径——**更正 10 号「内嵌终端直接运行」的印象：主路径是侧栏运行时，终端是选配**）。
- **可借鉴**：1）**统一审批策略 `Auto · Ask · Plan` 管住所有运行时**——「一套权限模型覆盖多个 Agent」是必抄的安全设计；2）**评论内 `@agent` + Send to AI，把「选中某段 → 交给某个 Agent」做成文档内交互，且评论落进 `.md`**（这条极妙：@ 引用上下文 + 评论持久化，全在纯文本里）；3）「浏览器登录、无需 CLI 安装」降低非开发者门槛。
- **不足**：内嵌多运行时 + 可选终端 = 明确的「编辑器 IDE 化」；7 star、生态早期；技术栈未原生。

### cmux（cmux.com，一句话）

- macOS 的「**AI coding agent 专用终端**」，任何能在终端跑的 Agent（Claude Code / Codex / OpenCode / Gemini CLI / Kiro / Aider / Goose / Cline / Cursor Agent…）开箱即用。**它是「内嵌终端」这条路的纯粹形态**——正好反证：一旦要「跑 Agent 运行时」，最终会长成一个终端多路复用器，而不是一个漂亮的 Markdown 编辑器。

**簇 C 小结（我们的立场）**：内嵌 Agent 运行时/终端能力最强，但**代价是把编辑器推成 IDE**（Nimbalyst 7+ 编辑器、Ritemark 多运行时 + 终端、cmux 干脆就是终端）。**我们倾向不内嵌终端**：同样的「让外部 Agent 干活」需求，用**簇 A 的 MCP server**（我们当数据源）实现得更轻、更符合「简洁好看」。**唯一值得从这簇搬走的是 Ritemark 的「统一审批策略」和「评论内 @agent」两个交互**，与终端本身无关。

---

## 四、新物种簇 D：捕获→整理→成文 / 本地 RAG（差异化主线，但重）

### NoteGen（codexu/note-gen）— 「捕获 → AI 整理 → 成文」三段式 + 内置 RAG

- **基本信息**：codexu｜Windows / macOS / Linux / Android / iOS **全五端**｜**GPL-3.0**（⚠️ **更正 10 号「MIT」**）｜github.com/codexu/note-gen 约 **12.3k star**（本簇最高）｜**Tauri 2 + Next.js 15 + React 19**（TS 92.5% / Rust 4.6%）｜v0.32.0（2026-07-20），极活跃｜安装包约 20MB。
- **如何集成 Agent**：**AI 原生**。核心范式「**先记录 → 后整理 → 再成文**」：先无脑捕获（文字/语音/截图/图片/链接/文件/待办），再按标签/时间/类型筛选后**让 AI 把碎片生成结构化 Markdown 笔记/周报/草稿/摘要**；内置**知识库 = RAG + 向量索引 + 混合检索**，可「与自己的记录对话」；支持 **MCP + Agent 工作流 + 自定义模型/提示词/记忆**；多模型（ChatGPT / Gemini / Ollama / LM Studio / Grok…含本地）；同步走 GitHub/Gitee/GitLab/Gitea/S3/WebDAV；笔记原生 Markdown 本地存。
- **可借鉴**：1）**「捕获→AI 整理→成文」是不同于「边写边补全」的另一条 AI 主线**，对「碎片多、成稿难」人群是清晰差异化定位；2）内置 RAG（向量 + 混合检索 + 本地模型）是完整、可读的参考实现。
- **不足**：功能繁多（捕获/整理/知识库/Agent），上手门槛高于纯编辑器；非原生（Tauri WebView）；**自建 RAG = 我们要小心的复杂度（见 13 号「AI 是维护黑洞」的 Trilium 教训）**。

### HelixNotes（ArkHost/HelixNotes）— 本地优先知识库 + 内置 AI 写作 + 现代 Rust 选型

- **基本信息**：ArkHost 社区｜Linux/Windows/macOS/Android｜**AGPL-3.0**｜托管在 **Codeberg**（非 GitHub）｜v1.3.3，活跃｜**Rust + Tauri 2.0 + SvelteKit(Svelte 5) + TipTap v3 + Tantivy + Notify**。
- **如何集成 Agent**：内置 **AI 写作工具**（改写/摘要/翻译），接 **Ollama / OpenAI-compatible / Anthropic / OpenAI**。（无 MCP server，属「编辑器内自带 AI」而非「暴露给外部 Agent」。）
- **由此带来的编辑器功能**：`[[wiki 链接]]` + 图谱视图；**Tantivy 全文搜索（CJK 优化）**；每笔记快照版本历史 + diff；Obsidian 导入；**跨笔记聚合 `- [ ]` 到统一任务视图 + 日历、拖拽改期**；`/secret` **加密块以可移植 `helix-secret` md fence 存储**（加密但不破坏纯文本可移植性）；KaTeX、Mermaid（PNG/SVG 导出）；WebDAV 同步；14 套配色 + 可分享 JSON 主题 + 80–200% 缩放。
- **可借鉴**：1）**技术选型样本**：`Tantivy`（Rust 全文搜索，CJK 友好）+ `Notify`（Rust 文件监听）+ 版本快照 diff 的组合，是「本地优先知识库」的现代答案（我们原生对应：Spotlight/自建索引 + FSEvents）；2）**加密块「以可移植 md fence 存储」**——加密而不牺牲纯文本可移植性；3）跨笔记 checklist 聚合到日历。
- **不足**：Windows/macOS 构建**未签名公证**（首启告警）；AGPL 对商业集成较严；新项目生态浅。

**簇 D 小结**：这簇提供的是「**AI 主线的另一种形态**」（捕获成文、全库 RAG）与「**现代本地知识库选型**」（Tantivy/Notify/快照 diff）。但**两者都偏重**：自建 RAG/向量库是 13 号明确点名的「AI 维护黑洞」风险区。**建议**：RAG/相关笔记推荐放到 V2 之后，且优先「本地 embedding 被动推荐」这种零配置轻形态（Smart Connections 范式），不做 NoteGen 式全套捕获-整理-Agent 工作流。

---

## 五、新物种簇 E：极简「给 Agent 写/读文件」的编辑器（离我们最近）

### MacMD（sleetcrash/MacMD）— 专编 `CLAUDE.md` / `AGENTS.md` + 自带 `SKILL.md`

- **基本信息**：sleetcrash｜macOS 14+｜**MIT**｜github.com/sleetcrash/MacMD 约 **2 star**、132 commit｜**Swift 96.8%、<3MB**｜v2.2.0（2026-07-17）。
- **定位 / 如何「面向 Agent」**：**「一个干净的地方来编辑 `README.md`、`CLAUDE.md`、`AGENTS.md` 及 Agent 配置文件」**。关键工程取舍：**byte-exact plain-text saves（字节级精确保存，UTF-8）**——不做智能引号/破折号替换/自动更正、遇非 UTF-8 直接报错而非静默损坏（**因为 Agent 配置文件对字节保真极敏感**）。**Zero telemetry**（无任何网络连接/更新检查/分析），预览用 bundled 引擎离线渲染（Mermaid 12 种图型沙箱内离线）。**自带 `skills/macmd/SKILL.md`**：提供能力映射与配置键，「让 Agent 无需翻源码就能打开、配置、验证 MacMD」。
- **可借鉴（对我们几乎逐条）**：1）**「编辑 Agent 上下文/配置文件」作为独立入口场景**——这正是我们路线 B 的核心用户故事（写 CLAUDE.md/AGENTS.md/规则/spec）；2）**byte-exact 保存 + 关掉一切智能替换 + 非 UTF-8 报错**，是「写给 Agent 看的文件」必须的正确性底线（普通写作 App 的智能标点会破坏 `.mdc` frontmatter、代码 fence）；3）**为自家 App 写 `SKILL.md`**，让 Agent 认识我们——低成本的「AI 功能外包」。
- **不足**：2 star、能力弱（偏轻编辑）；单人可持续性待观察。

### OpenMark（openmarkapp.com）— Agent 产出 Markdown 的「美化接收端」

- **基本信息**：Ryan McDonald｜macOS Tahoe（macOS 26+）/ iOS 18+ / iPadOS｜**$9.99 一次性买断**（Universal Purchase）、无订阅无账户无追踪｜**闭源**（App Store）｜**原生 SwiftUI、8MB**、内置 KaTeX + mermaid.js 离线渲染。
- **定位 / 如何「面向 Agent」**：标语即路线 B 的接收端宣言——**「AI agents write markdown. OpenMark makes it beautiful.」**（AI Agent 写 Markdown，OpenMark 让它变好看）；「Not Obsidian. Not VS Code. Just Markdown.」**明确不做 MCP/Agent 能力，只负责「把 Claude/ChatGPT 产出的 `.md` 渲染阅读得漂亮」**。功能：Document View（渲染阅读）↔ Markdown View（源码）双视图、Mermaid/LaTeX 内联零配置、**Spotlight importer（让系统搜索命中 `.md` 正文）**、Focus/Typewriter/Zen 模式、导出 PDF/HTML/RTF/md。（据 10 号记录，开发者称整个 App 用 Claude Code 从想法到上架仅 7 天。）
- **可借鉴**：1）**「Agent 产出 → 人来阅读/美化」是一个独立且清晰的入口场景**，配合文件监听即可（不需要任何 AI 集成就能吃到路线 B 的一半价值）；2）**Spotlight importer 让 `.md` 正文可被系统搜索**——低成本高感知的原生集成，强化「原生」卖点；3）双视图（渲染阅读 / 源码）的极简形态。
- **不足**：闭源、偏阅读轻编辑（无文库/双链/AI）；**要求 macOS 26+** 放弃老系统用户。

**簇 E 小结**：**MacMD + OpenMark 是与我们定位最近的两块拼图**——一个证明「专编 Agent 配置文件」是清晰入口且需要 byte-exact 正确性，一个证明「只做 Agent 产出的美化接收端」也能成立且原生轻量。**我们应把两者合一**：既是写 CLAUDE.md/AGENTS.md/spec 最舒服的地方（byte-exact + frontmatter 友好 + 规则文件语义），又是 Agent 产出 Markdown 的漂亮渲染 + 文件监听接收端，再叠加簇 A 的 MCP server。

---

## 六、IDE / Agent 前端里的「Markdown × Agent」

> 这些不是我们的直接竞品，但它们**定义了「开发者用 Markdown 指挥 Agent」的事实标准文件与交互**——我们要「让开发者写这类文件最舒服」，就必须原生支持它们。

### Cursor — `.cursor/rules/*.mdc` 四种激活模式 + `@` 引用 + memories

- **规则文件**：现代方案是 **`.cursor/rules/` 目录下的 `.mdc` 文件**（`.cursorrules` 旧单文件将弃用）。每个 `.mdc` = **YAML frontmatter（控制何时激活）+ Markdown 正文（指令）**；三个 frontmatter 字段 `description` / `globs` / `alwaysApply` 驱动**四种激活模式**：Always（`alwaysApply:true`）、Auto Attached（按 `globs` 文件模式）、Agent Requested（Agent 读 `description` 自行判断）、Manual（仅当 `@rule-name` 被显式提及）。递归读取；规则来源优先级 **Team → Project → User**。
- **AGENTS.md**：Cursor **原生读 `AGENTS.md`**（含子目录嵌套、更具体路径优先），作为 `.cursor/rules` 的**可移植纯 Markdown 替代**——代价是无 globs/无分模式激活（永远全局生效）。
- **`@` 引用**：`@file` / `@codebase` / `@Docs` / `@rule-name` 显式注入上下文；最佳实践是**用 `@file` 引用而非把代码复制进规则**（粘贴的代码会过期，引用随文件演进）。
- **memories vs rules**：rules 是你手写维护的静态文本；**memories 是 Cursor 自动从聊天里抽取、per-project per-user 存的偏好**，需手动「提升」为 rules 文件才能进版本库。规则**只作用于 Agent Chat**，不影响 Tab 补全 / Cmd+K inline edit。
- **可借鉴**：**规则文件 = 带 YAML frontmatter 的 `.md`** 这一事实，直接决定我们的编辑器要**为 `.mdc`/frontmatter 提供一等编辑体验**（见「可借鉴清单」的 frontmatter 表单）；`@file` 引用而非复制的理念也适用于我们的上下文注入。

### Windsurf → Devin Desktop — 规则字数上限 + memories 分离

- **重要变更**：2026-06-02 **Cognition 把 Windsurf 更名为 Devin Desktop**，windsurf.com 跳转 devin.ai，Cascade 折进 Devin Local。规则格式不破：`.windsurfrules`（旧）、`.windsurf/rules/*.md`，**现首选 `.devin/rules/`**（`.windsurf/` 作后备）。
- **规则**：**硬字数上限**（区别于 Cursor 无上限）——全局规则 6,000 字符、每 workspace 规则 12,000 字符，超出截断；四种激活模式经单个 `trigger` frontmatter 字段（Always On / Manual / Model Decision / Glob）。官方强调「**所有规则文件与项目文档都应是 Markdown**」，用 bullet/编号/XML 标签比长段落更易被 Cascade 遵循。
- **memories**：自动捕获、存 `~/.codeium/windsurf/memories/`、不进版本库、**不消耗 credits**；建议把有用的 memory「提升」为 rules 或写进 repo 的 `AGENTS.md`。
- **可借鉴**：**规则有 token 预算**这一现实——我们若做「规则文件编辑器」，应像统计字数一样**显示规则文件的字符/token 占用**（呼应 markjason 的 `⇧⌘I`）。

### Zed — Rules → Skills / Instructions，AGENTS.md 命令，Markdown 预览与「导出对话为 Markdown」

- **指令体系重构**：Zed 把「可复用 Rules」换成 **Skills**、「常驻 Rules」并入 **Instructions**（含个人与项目 `AGENTS.md`）。新增**打开全局/项目 `AGENTS.md` 的专用命令**（`agent::OpenGlobalAGENTS.mdRules` / `agent::OpenProjectAGENTS.mdRules`）。
- **Markdown 相关能力（值得抄的细节）**：`markdown_preview_font_size` 独立于编辑器缩放；**部分选中的富文本能复制成结构良好的 Markdown**（单个 inline code span 内选中则复制为纯文本）；Project Panel 右键「Open Markdown Preview」；代码块 wrap/unwrap 控件。**`Open Thread as Markdown`：把整个 Agent 对话导出成一个 Markdown 文件/标签页**（也用于贴到 GitHub issue）。
- **Agent 接入**：Zed 是 **ACP 的发源地**，agent panel 可并行跑多个 ACP Agent（Claude Code / Codex / Gemini CLI…各自独立线程，Zed 1.0 于 2026-04-29 以「parallel agents」为头牌）；每个外部 Agent 自管认证与账单，Zed 不对其计费。
- **可借鉴**：1）**「导出 Agent 对话为 Markdown」**——把 chat 变成可归档、可版本化的 `.md`，与「一切皆本地纯文本」自洽（我们的 AI 侧栏应支持一键导出对话为 md）；2）**为 `AGENTS.md` 设专用「打开」命令**（我们可做「打开本项目的 CLAUDE.md/AGENTS.md/规则目录」的命令面板项）；3）「选中富文本复制为规范 Markdown」是细腻的粘贴体验。

### Kiro — spec-driven：`requirements.md` / `design.md` / `tasks.md` + steering + hooks

- **基本信息**：AWS 的 agentic IDE，2026-03 GA，基于 Code OSS，经 Amazon Bedrock 用 Claude。
- **把 Markdown 当「工作单元」**：描述功能后不直接写码，而是**顺序生成三份 Markdown 文档**作为单一真相源——`requirements.md`（用 **EARS** 语法写 user story + 验收标准）、`design.md`（架构/组件/数据模型/时序图）、`tasks.md`（可勾选任务清单，**Kiro 提供 tasks.md 的任务执行界面：实时状态、in-progress/completed、按依赖并发跑**）；三阶段都**在执行前由人审阅修正**（planning 与 execution 解耦）。
- **steering 文件**：`.kiro/steering/` 下的 `product.md` / `tech.md` / `structure.md` + 自定义（如 `security.md`），**每次交互自动作为上下文注入**；可 `~/.kiro/steering/` 全局或 repo 级。**Agent Hooks**：文件系统事件（保存/新建/删除）→ 后台跑 AI prompt。
- **可借鉴**：1）**「spec = 三份 Markdown（需求/设计/任务）+ 人在执行前审阅」是「用 Markdown 指挥 Agent」最成体系的范式**——我们要成为「写 spec 最舒服的地方」，就该对这种**多文件 spec 工作流**（含 `tasks.md` 的勾选/状态）有一等支持；2）`tasks.md` 的**可勾选 + 实时状态**提示我们把任务列表渲染成交互式 checklist（勾选即改盘上 `- [ ]`）。

### Claude Code — 既是「产出 Markdown 的 Agent」，也是「CLAUDE.md 的消费者」

- **作为产出 Markdown 的 Agent**：**7 种指令方法**（CLAUDE.md 常驻上下文 / rules 硬约束 / skills 可复用流程 / subagents 委派 / hooks 确定性自动化 / output styles 全局风格）。**Plan Mode**（Shift+Tab 循环）：先出计划、人审、再执行；常先起一个 **Explore 子 agent** 扫仓库返回**蒸馏过的相关文件地图**——即 Agent 大量产出的正是 Markdown（计划、探索报告、调研）。子 agent 各有独立 context、可 `isolation: worktree` 跑隔离 worktree。
- **作为 CLAUDE.md 消费者（我们要支持编辑的文件）**：`CLAUDE.md` 是纯 Markdown，会话启动全量载入、**经 `/compact` 后从盘上重读重注入**。层级（从宽到窄载入）：**Managed policy（`/Library/Application Support/ClaudeCode/CLAUDE.md` 等）→ User(`~/.claude/CLAUDE.md`) → Project(`./CLAUDE.md` 或 `./.claude/CLAUDE.md`) → Local(`./CLAUDE.local.md`，应进 .gitignore)**；沿目录树向上逐层拼接。**`@path/to/import` 导入**（相对/绝对路径、最多 4 跳、跳过代码 span/fence、反引号包住可只提不导）。**AGENTS.md 关系（关键）：Claude Code 只读 `CLAUDE.md` 不读 `AGENTS.md`**；共享做法是在 `CLAUDE.md` 里写 `@AGENTS.md` 导入（下方再加 Claude 专属指令），或 `ln -s AGENTS.md CLAUDE.md` 软链。**块级 HTML 注释 `<!-- -->` 在注入前被剥离**（留给人看、不费 token）。目标每文件 <200 行。另有 **auto memory**（Claude 自己写，存 `~/.claude/projects/<project>/memory/`，`MEMORY.md` 作索引，前 200 行 / 25KB 载入）与 `.claude/rules/*.md`（可 `paths:` frontmatter 做路径域限定）。
- **可借鉴（这是我们产品的规格书）**：1）**我们要把「编辑 CLAUDE.md / AGENTS.md / `.mdc` / steering / rules」做成一等体验**——理解它们的层级、`@import`、frontmatter 语义、块级注释剥离规则，才能给出「智能」编辑（如：识别 `@import` 目标并可点击跳转、警告 CLAUDE.md 超 200 行、frontmatter 表单、`<!-- -->` 折叠）；2）**Agent 产出的计划/报告/记忆本身就是 `.md`**——我们做它们的漂亮渲染 + 文件监听 + 版本历史即可承接「Agent 也产出 Markdown」这半边。

---

## 七、Obsidian 作为 Agent 记忆 / 后端

> Obsidian 官方零 AI，却因「本地 `.md` vault + 开放格式」成为社区把「vault 当 Agent 读写对象」的头号后端。三条现成路径 + 一个官方 Agent Skills 包。

### 路径一：Local REST API with MCP（官方推荐，2026 的大变化）

- **coddingtonbear/obsidian-local-rest-api** 插件**自 v4.0（2026-05）起自带 MCP server**（v4.1.1 更名「Local REST API with MCP」明示），**不再需要第三方 bridge**；server 跑在 Obsidian 进程内、直接访问 vault 实时元数据/当前文件/periodic notes/命令面板。
- **暴露能力**：工具如 `vault_read` / `vault_patch` / `search_query`；**对任意文件全 CRUD**（含二进制），**外科式 patch**（针对某 heading / block reference / frontmatter key 做 append/prepend/replace，不动其余）、full-text 或 **JsonLogic 结构化查询**、periodic notes（日/周/月/季/年）。端点 `https://127.0.0.1:27124/mcp/` + Bearer token；Claude Desktop 需经 `mcp-remote` 桥接，**Claude Code 原生支持 HTTP MCP 可直连**。
- **⚠️ 安全教训（我们必须记住）**：**v4.1.3（2026-06）修了一个已认证的路径穿越漏洞（GHSA-62gx-5q78-wrvx）**——「把本地文库经 HTTP 暴露给 Agent」是**真实攻击面**，我们若做 MCP server，鉴权/路径校验/最小权限必须第一天做对。

### 路径二 / 三：mcp-obsidian（旧）与 filesystem MCP（零插件）

- **MarkusPfundstein/mcp-obsidian**（约 4k+ star）：独立 stdio server（`uvx mcp-obsidian` + `OBSIDIAN_API_KEY/HOST/PORT`），仍最多人装，但现在是「插件自己能干的多余一跳」。
- **Anthropic 官方 filesystem MCP** 指向 vault 目录：零插件、直接读写裸 `.md`，简单但丢掉「懂标签/链接」的 Obsidian 语义搜索。
- **启示**：三条路径对应「**懂格式的 server（重、强）↔ 通用 filesystem server（轻、弱）**」的权衡。我们做原生 MCP server 时，可先做 filesystem 级（读写 + 全文搜索），再逐步加「懂 wiki 链接/frontmatter/标题锚点」的语义工具。

### 官方 Agent Skills：kepano/obsidian-skills

- **Steph Ango（kepano，Obsidian CEO）** 维护、MIT、2026-01 建、含约 5 个 `SKILL.md`：**obsidian-markdown**（教 Agent wikilinks/callouts/frontmatter/tags/embeds 等 Obsidian 方言）、**obsidian-bases**（结构化数据层）、**json-canvas**（JSON Canvas 白板）、**obsidian-cli** 等；遵循 Agent Skills 规范，Claude Code / Codex CLI / OpenCode 皆可 `npx skills add kepano/obsidian-skills` 装。**被视为首个由主流工具官方维护的 Agent Skills 实现。**
- **可借鉴（与 MacMD 的 SKILL.md 呼应）**：**为自家格式/CLI 写 `SKILL.md`，让外部 Agent「免学习」地正确读写你的文库**——这是 08 号「让 Claude Code 成为免费高级 AI 功能」的具体落地。我们应随产品发一套 Agent Skills（教 Agent 用我们的 MCP 工具、认识我们支持的语法/frontmatter 约定）。

**第七节小结**：Obsidian 生态把「vault = Agent 后端」跑通了三种接法 + 官方 Skills，且用一个 CVE 给我们上了安全课。**我们的原生 MCP server 可直接对标 Local REST API 的工具面（read/patch/search/periodic），但要从第一天做对鉴权与路径校验。**

---

## 八、跨产品的「Agent 相关文件 / 协议」速览（细节归 15 号）

| 文件 / 目录 | 谁读它 | 格式要点 | 我们要做的编辑支持 |
|---|---|---|---|
| `CLAUDE.md` / `CLAUDE.local.md` | Claude Code | 纯 md；层级载入；`@import`（≤4 跳）；`<!-- -->` 剥离；<200 行更佳 | `@import` 可点跳转、超长告警、注释折叠 |
| `AGENTS.md` | 20+ 家 Agent（Codex/Cursor/Copilot/Zed/JetBrains…） | **标准 Markdown 无必填字段**；子目录嵌套更具体优先；**60k+ 项目在用**，由 Agentic AI Foundation（Linux Foundation）托管 | 识别为「Agent 指令文件」、模板、与 CLAUDE.md 的 `@import`/软链提示 |
| `.cursor/rules/*.mdc` | Cursor | **YAML frontmatter（`description`/`globs`/`alwaysApply`）+ md 正文**；四激活模式 | **frontmatter 表单**、glob 校验、激活模式可视化 |
| `.devin/rules/` `.windsurf/rules/*.md` | Devin Desktop(Windsurf) | md + `trigger` frontmatter；**字数上限 6k/12k** | 字符/token 计数、超限告警 |
| `.kiro/steering/*.md` + spec `requirements/design/tasks.md` | Kiro | steering 常驻上下文；`tasks.md` 可勾选 + 状态 | 多文件 spec 工作流、`tasks.md` 交互式 checklist |
| `SKILL.md`（Agent Skills） | Claude Code / Codex / OpenCode | 结构化「能力说明书」教 Agent 用某工具/格式 | 随产品自带 `SKILL.md`；识别/校验 frontmatter |
| `.claude/rules/*.md` | Claude Code | `paths:` frontmatter 做路径域限定 | 同 frontmatter 表单 |

**三种协议一句话区分**：**MCP**（编辑器暴露 vault 给 Agent 读写）｜**ACP**（Zed 系，把 CLI Agent 运行时接进编辑器 GUI）｜**Agent Skills / `SKILL.md`**（教 Agent 认识你的格式/工具）。**我们押 MCP + Agent Skills，观望 ACP。**

---

## 可借鉴 vs 该避免

> 收束为两栏。左栏进路线图（并标注建议阶段 MVP/V1/V2）；右栏是复杂度陷阱，明确不做或降级。

### ✅ 该抄进路线图（借鉴）

| 功能 | 抄自 | 建议阶段 | 一句话理由 |
|---|---|---|---|
| **文件监听 + 无「已在磁盘更改」弹窗，Agent 改盘上文件即时同步** | markjason、SideMark(chokidar)、HelixNotes(Notify) | **MVP** | 路线 B 的最低门槛；缺它，Agent 一改就弹窗打断 |
| **专编 `CLAUDE.md`/`AGENTS.md`/规则文件的一等体验 + byte-exact 保存（关智能标点、非 UTF-8 报错）** | MacMD | **MVP** | 我们的核心用户故事；智能标点会破坏 frontmatter/代码 fence |
| **Agent 产出 `.md` 的漂亮渲染 + Spotlight 索引正文** | OpenMark | **MVP** | 不接任何 AI 就能吃到路线 B 一半价值；强化「原生」 |
| **外部 Agent 改动以内联 diff 呈现、逐 hunk accept/reject/编辑后落盘** | Nimbalyst | **V1** | 路线 B 头号必抄交互，远胜「聊天框贴新版本」 |
| **frontmatter 表单编辑**（`.mdc` 的 `description`/`globs`/`alwaysApply`、`SKILL.md`、`.claude/rules` 的 `paths:`、Kiro/博客 front matter） | Cursor/Kiro/Front Matter CMS | **V1** | 规则/skill 文件全靠 YAML frontmatter；表单化是独占差异点 |
| **`@` 引用上下文 + 评论内 `@agent` 且评论落进 `.md`** | Cursor(@file/@rule)、Ritemark(评论 @claude) | **V1** | 上下文注入与「选中段落交给 Agent」全在纯文本里 |
| **内置 MCP server + 显式开关 + 读写分离的少量工具（read/list/search/patch）+ 结构化返回** | VMark、Clearly(9 工具规格)、Obsidian(vault_read/patch/search) | **V1→V2** | 「编辑器即数据源」的最轻 AI 集成；工具面直接对标 Clearly/Obsidian |
| **统一审批策略（`Auto·Ask·Plan` 式一套权限管所有 Agent 动作）** | Ritemark、SoloMD(accept/reject) | **V1** | 安全刚需；一套模型覆盖多来源 |
| **导出 AI 对话为 Markdown / `tasks.md` 交互式 checklist / 多文件 spec 工作流** | Zed(Open Thread as md)、Kiro | **V1→V2** | 与「一切皆本地纯文本」自洽 |
| **随产品自带 `SKILL.md`（教外部 Agent 用我们的格式/MCP）** | MacMD、kepano/obsidian-skills | **V1** | 让 Claude Code 成为「免费高级 AI」；零推理成本 |
| **规则/上下文文件的 token/字符计数与超长告警；`@import` 可点跳转；`<!-- -->` 折叠** | Windsurf(字数上限)、Claude Code(200 行/@import/注释剥离)、markjason(⇧⌘I) | **V1** | 「写给 Agent 看的文件」独有的贴心度，别家编辑器不会做 |
| **三方合并（共同祖先基准）+ Smart hunk grouping** | SideMark | **V2** | 人机真并发时的进阶；先有 diff 再上合并 |
| **本地被动「相关笔记推荐」（本地 embedding，零配置）** | HelixNotes(Tantivy)、Smart Connections | **V2** | RAG 的轻形态，避开重型向量库 |

### ⛔ 该避免 / 降级（复杂度陷阱）

| 陷阱 | 反例 / 教训 | 我们的处置 |
|---|---|---|
| **内嵌 CLI Agent 终端 / 多运行时宿主** | Ritemark（侧栏多运行时 + 终端）、Nimbalyst（ghostty）、cmux（干脆是终端） | **不内嵌终端**。同样需求用 MCP server（我们当数据源）实现；只搬「统一审批」「评论 @agent」两个交互，不搬运行时 |
| **自建 RAG / 向量索引 / 全套「捕获→整理→Agent」工作流** | NoteGen（重）、13 号 Trilium「AI 维护黑洞」教训 | RAG 降级为 V2 之后的「本地 embedding 被动推荐」；不做捕获-整理-Agent 全家桶 |
| **顺手把「MCP + 双链 + 标签 + 索引 + chat」一起堆上** | **Clearly 加到 9 个 MCP 工具 + 双链，又整体删除，回归「刻意无聊」** | MCP 做成**可选、可关、边界清晰的一层**；双链/标签是独立取舍，不因为做了 MCP 就顺势全上 |
| **7+ 种内嵌可视化编辑器（代码/CSV/Excalidraw/ERD…）把编辑器变工作台** | Nimbalyst | 只做 Markdown（+ 预览 Mermaid/KaTeX）；Excalidraw/CSV/ERD 交给外部工具 |
| **把「MCP server 经 HTTP 暴露」做得不设防** | Obsidian Local REST API 的路径穿越 CVE（GHSA-62gx-5q78-wrvx） | 鉴权 + 路径校验 + 最小权限 + 默认 localhost/可关，**第一天做对** |
| **要求 macOS 26+ / 未签名公证 / 闭源** | OpenMark(仅 26+)、HelixNotes(未公证首启告警)、多款闭源 | 支持尽量低的 macOS 版本；首发即签名公证；坚持开源（与簇内多数一致，是信任优势） |
| **默认开启、静默上传的 AI** | 精品阵营（iA/Ulysses/Bear）都不默认云 AI | MCP/AI 默认 opt-in（MarkMorph 姿态）、可整体关闭、发送前可视化将上传内容 |

### 结语：我们的落点（一句话）

**把簇 E（专编 Agent 文件 + 美化接收）作骨架、簇 B（文件监听 + 内联 diff）作交互护城河、簇 A（内置 MCP server + 自带 SKILL.md）作 AI 集成层，坚决绕开簇 C（内嵌终端）与簇 D（自建 RAG）的复杂度**——做成一个「写 CLAUDE.md/AGENTS.md/spec 最舒服、且让你已在用的 Claude Code/Cursor 能安全读写你 Markdown 文库」的原生 macOS 开源编辑器。Clearly 的「加了又删」和 cmux 的「终端终局」已经替我们把两条歧路走了一遍：**克制，就是我们相对这一整簇新物种的最大差异化。**
