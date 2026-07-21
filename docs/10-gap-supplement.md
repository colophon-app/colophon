# 查漏补缺：其他值得关注的 Markdown 编辑器

> 调研日期：2026-07-21 ｜ 本文是对 01–09 号分类文档的查漏补缺补充，编号补齐目录中缺失的 10 号位。

## 本次核查的榜单来源与结论

为确认「已尽可能覆盖全市场」，本次逐条比对了以下来源，找出已收录清单之外仍值得记录的条目：

- **GitHub 合集**：`mundimark/awesome-markdown-editors`（在线/桌面/Linux/Windows/macOS/移动端全量表，逐条比对）、`tehtbl/awesome-note-taking`、`tauri-apps/awesome-tauri`。
- **AlternativeTo.net**：Typora alternatives、Obsidian 系替代品列表。
- **"best markdown editors 2026" 评测**：unmarkdown、markdowntools、mdclaudy、merge-json-files、docsio、openmark 等十余篇。注意其中相当一部分是 SEO / AI 生成的内容农场（甚至是某产品自家博客给自己引流），因此**只从中提取产品名，再回官网 / GitHub / App Store 原始来源逐一核实**，不采信其评测结论与数字。
- **少数派 sspai**：《7 款优秀 Markdown 编辑工具》《11 款好用的 Markdown 编辑器》《15 款本地优先 markdown app》《开源、高颜值、功能强大的 Markdown 编辑器（共5款）》等多篇合集。
- **移动端榜单**：maketecheasier、tipsmake 等 Android / iOS 榜单。
- **原始来源核对**：各产品官网、GitHub 仓库，并用 GitHub API 核对 star 数与最近提交时间（维护状态）。

**结论**：09 个分类文档去重后已收录约 **179 个 `###` 词条**（README 口径：产品/工具 145 项、去重约 130 款，另加 40 项技术组件与 54 项综合归纳，主条目合计 239）。对**主流、经典、活跃**的 Markdown 编辑器覆盖已相当完整——少数派 / AlternativeTo / awesome 榜单上的大热门（Typora、Obsidian、iA Writer、Ulysses、Bear、MWeb、VNote、Notable、MarkText、Simplenote、Byword、1Writer、Editorial 提及者等）**几乎都已在册**，sspai 合集未暴露任何主流级遗漏。

本次查漏补缺的**真正价值集中在两处**：

1. **2025–2026 涌现的「原生 macOS + 开源 + 面向 AI Agent 协作」新生代小工具**——它们与我们的产品定位（原生 macOS、简洁好看、开源免费、可接入 AI）**几乎完全重合**，且共同指向一个刚成形的新趋势：把 Markdown 编辑器做成 AI Agent 的「可视化前端 / 数据源」（内置 MCP server、人机三方合并、内联 diff）。这是现有文档尚未充分展开的窗口，最值得重点跟进。
2. **几款 star 数不低却漏收的跨平台 / 移动端产品**：NoteGen（12.3k）、Yank Note（6.6k）、Markor（5.9k）、Tangent、Deepdwn、Beaver Notes、JotterPad 等。

本文新增**详细收录 22 款**（另附一句话次要清单）。为避免与 01、09 号重复：`MarkEdit`、`swift-markdown-engine`(nodes-app)、`SwiftUIMarkdownEditor`、`MacDown`、`SwiftDown`、`Neon`、`CodeEdit`、`Runestone`、`STTextView` 等原生 Swift 编辑器/组件已在册，本文不再重复。

---

## 一、原生 macOS 新生代编辑器（与我们定位最贴合）

> 类别观察：这是本次最有价值的发现。2025–2026 出现了一小群**纯 Swift / 原生 macOS、开源或独立、体量极小**的 Markdown 编辑器，很多明确把「和 AI Agent 一起编辑同一批 `.md` 文件」当作核心命题（编辑 `README.md` / `CLAUDE.md` / `AGENTS.md`、内置 MCP server、人机三方合并）。它们 star 数普遍很低（1–1000 不等）、有的还是实验品，但**方向正是我们要做的事**，参考价值高于其当前成熟度。

### OpenMark

- **基本信息**：开发者 Ryan McDonald（独立开发者）｜平台 macOS + iOS｜价格 $9.99 一次性买断（Universal Purchase，一次付费覆盖 Mac 编辑器 + iOS 阅读器），无订阅、无账户、无追踪；**闭源**（上架 Mac App Store）｜官网 https://openmarkapp.com ｜维护状态：活跃（2025 年发布，v1.2 已加入 iOS 端）
- **编辑模式**：所见即所得渲染阅读为主——双击 `.md` 直接看到排版后的文档（标题、代码块、表格、链接均渲染），而非源码；面向「打开即读 + 轻编辑」
- **核心功能**：Mermaid 图（流程图/时序/甘特/思维导图，Mermaid.js 内置）与 KaTeX 数学**内联渲染、零配置**；导出 PDF / HTML（保留渲染后的图表与公式）；**Spotlight 导入器**让系统级搜索能命中 `.md` 正文；Quick Look 预览、拖拽；无遥测、无网络请求
- **UI 设计**：SwiftUI 原生，遵循系统外观、支持 Stage Manager，适配 macOS Tahoe 的 Liquid Glass 设计语言；启动 < 1 秒、内存约 60MB、安装包约 9MB——「原生轻量」是其核心卖点
- **技术栈**：**SwiftUI 原生二进制**（非 Electron、非 WebView 套壳）；开发者公开表示**「整个 App 用 Claude Code 构建，从想法到上架仅 7 天」**
- **AI 能力**：产品本身无内置 AI 功能；但其「AI 时代的 Markdown 编辑器」定位与「用 Claude Code 造 App」的故事，正是我们这套技术路线（SwiftUI + AI 辅助开发）的现成案例
- **可借鉴点**：1）**它几乎就是我们目标形态的一个已上架样本**——SwiftUI、原生轻量、内置 Mermaid+KaTeX、Spotlight 导入器、Universal Purchase，值得逐项对标其取舍；2）「double-click 即渲染阅读」把「Markdown 阅读器」这个细分需求单独产品化，是一个清晰的入口场景；3）用 Claude Code 快速搭 SwiftUI App 的可行性验证
- **不足**：闭源；编辑能力相对弱（偏阅读 + 轻编辑，无文库/双链/插件）；单人独立开发的可持续性待观察

### Clearly（clearly.md）

- **基本信息**：开发者 Josh Pigford（@Shpigford）｜平台 macOS + iOS/iPadOS｜**免费、开源**（Mac App Store + 官网直接下载 + 源码）｜官网 https://clearly.md ｜GitHub https://github.com/Shpigford/clearly，约 **1,076 star**｜维护状态：活跃（最近提交 2026-05，版本已到 v2.9.x）；要求 macOS Sequoia 或更高
- **编辑模式**：源码 + 语法高亮编辑，一键切换渲染预览，或**并排（side-by-side）同步滚动**双栏
- **核心功能**：标题/粗斜体/链接/代码块/表格边写边高亮；⌘B/⌘I/⌘K 快捷格式 + 完整 Format 菜单；扩展语法（高亮、上标等）；拖拽粘贴图片、Mermaid 图、LaTeX 数学实时渲染；导出/打印 PDF；**近版已扩展为轻量知识库**：`[[wiki 链接]]` 自动补全、反向链接（linked / unlinked mentions 一键成链）、`#tag` 标签侧栏浏览、按相关度排序的全文搜索
- **UI 设计**：原生 macOS/iOS，克制干净；无 Electron、无订阅、无遥测
- **技术栈**：原生 Swift（源码用 XcodeGen + `project.yml` 生成工程，仓库含 `CLAUDE.md`，本身即 AI 辅助开发项目）
- **AI 能力**：**内置 MCP server**，把你的笔记库（vault）暴露给 AI Agent 做搜索与检索——这正是「编辑器即 AI 数据源」范式的直接实现
- **可借鉴点**：1）**最值得直接抄的一点：内置 MCP server 让外部 AI Agent 安全读检索笔记库**，与 QOwnNotes 的 MCP 思路殊途同归，且是原生 Swift 实现的现成参考；2）「一个原生编辑器同时是 side-by-side 预览器 + 轻量双链知识库」的功能爬升路径清晰；3）免费开源 + 上架 App Store 的分发组合（既开源又能在商店触达普通用户）
- **不足**：知识库能力相较 Obsidian 仍浅；生态与主题系统尚不成熟；iOS 端能力弱于桌面

### SideMark

- **基本信息**：开发者 avanrossum｜平台 macOS｜**免费、MIT 开源**｜GitHub https://github.com/avanrossum/sidemark，约 **3 star**（很新/极小众）｜维护状态：活跃（最近提交 2026-04）
- **编辑模式**：源码编辑 + 预览；**主打「人 + AI Agent 同时编辑同一文件」的并发工作流**
- **核心功能（重点看其独特命题）**：**三方合并（three-way merge）**——你改引言、AI Agent 改结论，SideMark 在后台以共同祖先为基准静默合并两边改动，仅用一个 toast 提示，无「文件已在磁盘上更改」弹窗、无覆盖丢失；当人与 Agent 改到同一行时，弹出**逐条可接受/拒绝的交互式 diff**（非全有或全无的重载）；另有自动保存、专注模式、Git gutter 变更标记、PDF/HTML 导出
- **UI 设计**：原生 macOS、干净快速；无账户、无遥测、无订阅
- **技术栈**：原生 macOS（Swift）
- **AI 能力**：本身不含模型，但**架构专为「与 AI Agent 协作改文件」而设计**——填补了「AI 在终端里改 Markdown、人在 GUI 里改，二者如何不打架」的空白
- **可借鉴点**：1）**三方合并 + 逐条 diff 是解决「AI Agent 与用户并发编辑」冲突的关键交互，非常值得我们借鉴**——我们若定位「可接入 AI」，这类冲突几乎必然出现，SideMark 给了一个原生实现范式；2）「file changed on disk」这个所有编辑器的老痛点，被它用后台合并优雅化解，是差异化体验点
- **不足**：极其小众（3 star）、功能面窄（专注单文件协作，无文库/双链/插件）；成熟度与可持续性存疑

### Nota（nota.md）

- **基本信息**：开发者未公开团队信息｜平台 macOS｜价格**未知**（当前为**邀请制内测**，官网 nota.md 放出 waitlist）；授权协议未知（疑似闭源商业）｜官网 https://nota.md ｜维护状态：内测中
- **编辑模式**：面向本地 `.md` 文件的「Pro 笔记」编辑（具体渲染模式内测未完全公开，未知）
- **核心功能**：笔记即普通 Markdown 文件（可放 Dropbox、Finder 管理、任意 app 打开）；**核心卖点是可脚本化扩展**——用多种脚本语言写自定义命令挂到命令面板（⇧⌘P）、在 paste/save 等 app 事件上跑事件脚本；写作辅助（按词性着色、给「浮夸词」加下划线）；自定义补全（Coming Soon）
- **UI 设计**：命令面板驱动、克制的 Pro 写作界面（细节内测未公开）
- **技术栈**：未知（原生 macOS 定位）
- **AI 能力**：未见内置 AI；但「事件脚本 + 命令面板」是接 AI 的天然扩展点
- **可借鉴点**：1）**「命令面板 + 事件钩子（onPaste/onSave）+ 多语言脚本」这套扩展模型**，对原生应用做插件生态很有参考价值（对应我们可用 JavaScriptCore / Swift 插件）；2）「写作辅助」类小功能（词性着色、浮夸词提示）是低成本高感知的差异化点
- **不足**：邀请制内测、信息少、价格与协议未知；可持续性无法评估

### The Archive（zettelkasten.de）

- **基本信息**：开发者 Christian Tietze（zettelkasten.de 团队，Sascha 负责产品方向）｜平台 **仅 macOS**｜价格约 **$19–20 一次性买断**（+税），**60 天试用**，偶有大促（曾限时 $4.99）；**闭源**商业软件｜官网 https://zettelkasten.de/the-archive/ ｜维护状态：活跃（2017 起，2025 年已到 v1.9.x）
- **编辑模式**：纯文本 / Markdown 源码编辑（非所见即所得），以「快速检索」为核心交互而非渲染
- **核心功能**：纯文本 `.md` 存储 + 任意云盘同步（iCloud/Dropbox/GDrive/Box）；**Omnibar 即时搜索**作为主导航方式，侧栏专设「已保存搜索」（可自定义图标 + 热键触发）；`#标签` 与 `[[双链]]` 均以「点击即跳到该词的搜索结果」实现的**伪 wiki 链接**（无需硬链接）；系统级快速录入框；自定义主题；MultiMarkdown C 引擎解析，自建索引做毫秒级全文搜索，宣称可扛 10,000+ 笔记
- **UI 设计**：极简、以搜索为中心；被广泛视为 **Notational Velocity / nvALT 的精神续作**（「持续开发版的 nvALT」）
- **技术栈**：原生 macOS（Cocoa/AppKit），MultiMarkdown C 解析引擎
- **AI 能力**：无
- **可借鉴点**：1）**「搜索即导航」+ 已保存搜索侧栏 + 系统级快速录入**，是 nvALT 一脉「零层级、纯检索」笔记法的成熟范本，对我们做「大量小笔记」场景很有参考；2）`#标签`/`[[链接]]` 用「跳转到搜索结果」实现，工程量远小于真正的双链图谱，却够用——低成本双链的一种解法；3）60 天超长试用 + 小额买断的信任建立方式
- **不足**：仅 macOS、无官方移动端（靠 iCloud + 第三方 md app 迂回）；闭源；非渲染式编辑，界面偏「工具」而非「漂亮」

### mxMarkEdit

- **基本信息**：开发者 maxnd｜平台 macOS｜**免费**（协议见仓库）｜GitHub https://github.com/maxnd/mxMarkEdit，约 **27 star**｜维护状态：活跃（最近提交 2026-07）
- **编辑模式**：源码 + 样式化编辑（standard Mac app，享受系统拼写检查与标准快捷键）
- **核心功能**：受 **Org-mode 深度影响**——除写 Markdown 与 todo 外，每个文档内嵌一个 **Excel 式表格 / 简单数据库**用于管理数据集；内置文件管理器可跨文件夹全文检索句子/表格；样式化文本、任务、参考文献、**演示（presentations）**；经 Pandoc 导出多格式（需系统装 Pandoc）
- **UI 设计**：标准 macOS 应用观感，朴素务实
- **技术栈**：原生 AppKit（Mac app），导出后端 Pandoc
- **AI 能力**：无
- **可借鉴点**：1）**「文档内嵌表格/简单数据库」**把 Notion 式结构化数据以轻量方式带进纯 Markdown 文件，是「Markdown + 轻结构化」的一种低成本实现；2）Org-mode 式「一个文件里混排文本/任务/数据/演示」的信息整合思路
- **不足**：小众；强依赖 Pandoc；UI 偏朴素、非设计驱动

### 一批新生代实验性原生 macOS 开源小工具（面向 AI Agent 编辑）

以下几款体量极小、star 个位数到几十，多为 2025–2026 新建，**成熟度不足以单列详表，但方向高度契合我们的命题**（原生 macOS + 开源 + 编辑 AI 相关文件），一并记录：

- **MacMD**（`sleetcrash/MacMD`，约 2 star，MIT）：轻量原生 macOS 编辑器，实时语法高亮、**字节级精确保存（byte-exact plain-text saves）**、零遥测；定位明确——「一个干净的地方来编辑 `README.md`、`CLAUDE.md`、`AGENTS.md` 及 Agent 配置文件」。**可借鉴**：把「编辑 AI Agent 配置/上下文文件」当作独立入口场景。
- **Marky**（`detherington/Marky`，约 1 star）：原生 macOS，**raw / split / WYSIWYG 三种编辑模式一键切换**。**可借鉴**：三模式切换是「源码党 vs 所见即所得党」都照顾到的稳妥设计。
- **mdnb**（native Swift macOS，免费）：原生 Swift（非 Electron/Tauri），支持 `[[wikilinks]]`；细节资料少（多字段未知）。**可借鉴**：又一个「原生 Swift + 双链」的最小实现参照。
- **LitSquare Ink MD**：原生 macOS（SwiftUI/AppKit，**TextKit 2**）样式化编辑 + 工作区浏览，预览走 markdown-it + highlight.js + KaTeX，富文本复制/导出、主题、可选「显示不可见字符」叠层。**可借鉴**：TextKit 2 自绘样式化编辑 + WebView 预览的混合架构，正对应我们 09 号文档「方案 A」的思路，是个活体参照。

> 小结：这批工具的共同信号是——**「原生 macOS Swift 编辑器」的门槛正在被 AI 辅助开发（Claude Code 等）快速拉低，且新玩家不约而同把 AI Agent 协作当作切入点**。对我们既是竞争提示，也是路线验证。

---

## 二、AI 原生 / AI-Agent 协作型编辑器

> 类别观察：区别于「老编辑器后加 AI 插件」，这几款从架构起点就围绕 AI（内联 diff、RAG 知识库、Agent 工作区）设计，是 08 号文档「AI 写作」类别的最新增量。

### Nimbalyst

- **基本信息**：开发者 Nimbalyst 团队｜平台 macOS（Apple Silicon + Intel）/ Windows / Linux + iOS 伴侣 App｜**免费、MIT 开源**（自带订阅或 API Key，BYO）｜官网 https://nimbalyst.com ｜GitHub https://github.com/Nimbalyst/nimbalyst，约 **1,278 star**｜维护状态：活跃（最近提交 2026-07）
- **编辑模式**：WYSIWYG Markdown 富文本，可随时在「富文本 ↔ 原始 Markdown」间切换；**AI 的改动以内联红/绿 diff 呈现**
- **核心功能**：定位「**Claude Code 与 Codex 的可视化工作区**」——同时支持 Anthropic Claude Code 与 OpenAI Codex 两种 Agent 并行跑会话；AI 修改文档时每处改动都是高亮内联 diff，可**逐条接受/拒绝/手改后再落盘**；Agent 编辑时能看到整个文档 + 相关文件 + 项目结构（可让它重写某节、从代码生成表格、重构全文）；自动版本历史（时间戳浏览、一键回滚）；文档内生成 Mermaid / Excalidraw 图、内嵌任务/状态追踪；**7+ 种可视化编辑器**（Markdown / Monaco 代码 / CSV / UI 原型 / Excalidraw / 数据模型 ERD / Mermaid）均支持 AI 辅助；多会话跑在**隔离的 Git worktree**里，单界面监控
- **UI 设计**：可视化工作区 + 多编辑器切换；内容与元数据全部以纯 Markdown / 标准文件存本地，无私有格式，可用 git 版本化
- **技术栈**：桌面 App（web 技术栈打包，多编辑器集成 Monaco/Excalidraw 等）
- **AI 能力**：**这是它的全部核心**——把 Claude Code / Codex 从终端搬进可视化界面，用「内联 diff + 逐条接受」替代「终端里看纯文本改动」
- **可借鉴点**：1）**「AI 改动 = 内联红/绿 diff + 逐条接受/拒绝」是 AI 写作交互的关键范式**，比「聊天框里贴新版本」体验好得多，强烈建议纳入我们的 AI 功能设计；2）「Agent 会话跑在隔离 Git worktree、单界面监控」的工程模式；3）同时支持多家 Agent（Claude/Codex）、BYO Key 的开放姿态
- **不足**：更偏「AI 编码/文档工作台」而非纯写作工具，对不写代码的普通写作者偏重；依赖用户自带 AI 订阅/Key

### NoteGen（note-gen）

- **基本信息**：开发者 codexu｜平台 Windows / macOS / Linux / Android / iOS（**全五端**）｜**免费、MIT 开源**｜GitHub https://github.com/codexu/note-gen，约 **12,310 star**（本文新收录中 star 最高，超过许多已收录产品）｜维护状态：极活跃（最近提交 2026-07）
- **编辑模式**：Markdown 编辑器（表格、图表、数学、大纲、搜索、导出俱全）+ 前置的「捕获收件箱」
- **核心功能**：核心范式是 **「先记录 → 后整理 → 再成文」**——先无脑捕获（文字/语音/截图/图片/链接/文件/待办），再按标签/时间/类型筛选后**让 AI 把选中的碎片生成结构化 Markdown 笔记/周报/草稿/摘要**；内置**知识库（RAG + 向量索引 + 混合检索）**，可「与自己的笔记/记录对话」；支持 MCP、自定义模型/提示词/记忆/Agent 工作流；同步走 GitHub/Gitee/GitLab/Gitea/S3/WebDAV；笔记以原生 Markdown 存储、本地优先、可移植
- **UI 设计**：捕获收件箱 + Markdown 编辑器 + AI 助手三合一；安装包约 20MB（Tauri 优势）
- **技术栈**：**Tauri（Rust 后端 + TypeScript 前端）**，用系统 WebView，体积远小于 Electron
- **AI 能力**：**AI 原生**——可配 ChatGPT / Gemini / Ollama / LM Studio / Grok 等多模型（含本地模型），RAG 知识库 + chat-with-notes + MCP + Agent 工作流，被评价为「Obsidian 遇上 GPT」
- **可借鉴点**：1）**「捕获→AI 整理→成文」的三段式工作流**是把 AI 嵌入写作的另一条主线（不同于「边写边补全」），非常适合「碎片记录多、成稿难」的人群，是清晰的差异化定位；2）**内置 RAG 知识库 + 与笔记对话**的完整实现（向量索引 + 混合检索 + 多模型 + 本地模型）是我们做 AI 的高价值参考；3）Tauri 20MB 安装包印证「非 Electron 也能全端」
- **不足**：功能繁多、概念偏重（捕获/整理/知识库/Agent），上手门槛高于纯编辑器；非原生 macOS（Tauri WebView）；重度依赖 AI 配置

### HelixNotes

- **基本信息**：开发者 ArkHost（社区）｜平台 Linux（AppImage）/ Windows / macOS / Android｜**免费、AGPL-3.0 开源**｜官网 https://helixnotes.com ｜源码 https://codeberg.org/ArkHost/HelixNotes（托管在 Codeberg，非 GitHub）｜维护状态：活跃（新兴项目）
- **编辑模式**：富文本工具栏 + 斜杠命令 + 源码模式（三者切换）
- **核心功能**：本地标准 `.md` 文件；`[[wiki 链接]]`、**图谱视图**、**Tantivy 驱动的全文搜索**；每笔记快照版本历史 + diff 视图；zip 自动库备份；内联 PDF 预览；**Obsidian 导入**（wiki 链接转标准 Markdown）；表格/代码高亮/KaTeX；**任务视图**（跨笔记聚合所有 checklist，设优先级/截止日，可列表或拖到日历）；每日笔记（日历式）；加密秘密块（以可移植 md fence 存储）；可选 WebDAV 同步到自建服务器（Nextcloud/ownCloud/NAS）；多窗口；数十种内置配色（Solarized/Nord/Catppuccin/Gruvbox/Synthwave/One Dark）+ 可分享 JSON 主题；界面缩放 80–200%
- **UI 设计**：目标是「UpNote 般干净的编辑器 + Obsidian 般的本地文件，去掉臃肿与锁定」；配色主题丰富
- **技术栈**：**Rust + Tauri 2.0 + SvelteKit**（非 Electron，系统 WebView，体积小）
- **AI 能力**：内置 **AI 写作工具**（改写/摘要/翻译等，接 Anthropic / OpenAI）
- **可借鉴点**：1）**Tantivy（Rust 全文搜索引擎）+ 图谱视图 + 版本快照 diff** 的组合，是「本地优先知识库」的现代技术选型样本；2）「跨笔记聚合 checklist 到统一任务视图 + 日历」是 Markdown 任务管理的好设计；3）加密块「以可移植 md fence 存储」，加密但不破坏纯文本可移植性
- **不足**：Windows/macOS 构建**尚未签名/公证**（首启有告警）；不直接支持 Obsidian wiki 链接语法（需转换）；AGPL 对商业集成较严格；新项目、生态浅

---

## 三、跨平台桌面遗漏（活跃维护）

### Tangent（Tangent Notes）

- **基本信息**：开发者 suchnsuch｜平台 macOS / Windows / Linux｜**免费、Apache-2.0 开源**｜官网 https://www.tangentnotes.com ｜GitHub https://github.com/suchnsuch/Tangent，约 **526 star**｜维护状态：活跃（最近提交 2026-07）
- **编辑模式**：所见即所得——笔记边写边完整样式化，Markdown 符号按需隐藏/显现；用 `[[Wiki 链接]]` 与轻定制方言
- **核心功能**：本地 Markdown 文件；招牌是 **「滑动面板（Sliding Panels）+ 二维导航/链接地图」**——把你的浏览与链接历史画成可交互的二维连接图，面板横向滑动在笔记间穿行（灵感来自 Andy Matuschak 的笔记法）；写作专注模式（高亮当前段/行/句）；**带自动补全的自定义查询语言**做复杂检索；笔记集可看作卡片或无限动态加载的信息流；支持内嵌图片/链接预览/PDF/音视频（含 YouTube 链接）
- **UI 设计**：滑动面板式导航是最大视觉特色，鼓励「顺着链接横向探索」而非树状浏览
- **技术栈**：Electron + TypeScript（含 html→md 解析器、查询语言解析器等模块）
- **AI 能力**：无
- **可借鉴点**：1）**「滑动面板 + 二维连接地图」**是双链笔记的一种新颖导航范式，与 Obsidian 的图谱不同，更强调「阅读/思考路径」，值得作为差异化交互研究；2）带自动补全的自定义查询语言，把「保存的搜索」升级为可组合查询
- **不足**：Electron；生态与插件不及 Obsidian；滑动面板范式有学习成本

### Yank Note（yn）

- **基本信息**：开发者 purocean（国人）｜平台 Windows / macOS / Linux｜**免费、AGPL-3.0 开源**｜官网 https://yank-note.com ｜GitHub https://github.com/purocean/yn，约 **6,662 star**｜维护状态：极活跃（最近提交 2026-07）
- **编辑模式**：源码编辑（**Monaco 内核**，即 VS Code 编辑器核心）+ 渲染预览；定位「为程序员打造的可 hack 的 Markdown 笔记」
- **核心功能**：数据存本地 `.md`、扩展尽量用原生 Markdown 语法实现；**版本控制**（记录每次修改、随时回滚）；**逐文件加密**（前端加解密，可给单个文件设独立密码）；**代码块可运行**、**集成终端**；内嵌 PlantUML / drawio / ECharts / Mermaid / Luckysheet 图表；HTML 小程序内嵌、Reveal.js 幻灯片、宏替换、TOC、可编辑表格单元格；**插件系统 + 扩展市场**；导出多格式（后端用 Pandoc）；支持 **CLI 与 MCP**（可编程交互）
- **UI 设计**：功能密集、偏 IDE 风；面向懂 Markdown 的程序员
- **技术栈**：Electron + **Monaco** 编辑器内核，导出后端 Pandoc
- **AI 能力**：**AI Copilot 扩展**（接 OpenAI / Google AI，做智能补全与文本改写，需自备 API Token 并装启用扩展）；且支持 **MCP**
- **可借鉴点**：1）**版本控制 + 逐文件加密 + 可运行代码块 + 集成终端**这套「程序员向」功能组合，说明「Markdown 笔记 = 轻量开发环境」是有真实需求的方向；2）**同时提供 CLI 与 MCP**，与 QOwnNotes / Clearly 一样把编辑器做成 AI/脚本可编程的对象；3）扩展市场 + 原生语法优先（扩展不污染 md 兼容性）的取舍
- **不足**：官方明确提示**「为扩展性牺牲了安全防护（可执行命令、任意读写文件）」**，打开不可信的外来 md 文件有风险；Electron；UI 偏重、非设计驱动；文档社区以中文为主

### Deepdwn

- **基本信息**：开发者 Billiam（美国 Minnesota，独立开发者）｜平台 Windows / macOS / Linux｜价格 **$14.99 一次性买断**（itch.io，可多付支持作者）；**闭源**｜官网 https://www.deepdwn.com ｜维护状态：活跃（前身 2019 年名为 JotDown，2021 更名 Deepdwn，持续按用户反馈迭代）
- **编辑模式**：源码编辑 + 实时预览（LaTeX/KaTeX 实时渲染），另有全屏与「无干扰（Distraction Free）」模式
- **核心功能**：文件以标准 Markdown 存本地（YAML front matter 里存标签 + 分类），支持**反向链接**连接文档；侧栏显示分类/标签/收藏夹/文档大纲（可跳章节）；**离线专属**（无云、无移动端——自行用 Syncthing/Dropbox 等同步）；表格自动格式化、Vim/Emacs 键位、列表自动续排、章节持久折叠、图片拖拽 + 编辑内预览；渲染流程图/时序图/**乐谱（sheet music）/ 吉他谱（guitar tabs）**；每文件与全局字数历史、**写作连胜（streak）特效**
- **UI 设计**：干净现代、组织功能丰富，暗色模式（默认关）；无干扰模式只留正文
- **技术栈**：桌面应用（Electron 系，具体未公开）
- **AI 能力**：无
- **可借鉴点**：1）**乐谱/吉他谱渲染**是极少见的细分渲染能力，服务音乐类写作者，是「按人群做专属渲染扩展」的例子；2）「写作连胜特效 + 字数历史」的游戏化激励；3）明确「离线专属、无云」作为卖点而非缺陷的定位表达
- **不足**：闭源；刻意无云同步、无移动端（高频用户抱怨点）；Electron

### MindForger

- **基本信息**：开发者 Martin Dvorak 及贡献者｜平台 Linux / FreeBSD / macOS / Windows｜**免费、GPL-2.0 开源**｜官网 https://www.mindforger.com ｜GitHub `dvorka/mindforger`（仓库近期迁移/重定向，star 数未核实，历史上为知名项目）｜维护状态：活跃
- **编辑模式**：Markdown 源码编辑 + 可切换实时 HTML 预览
- **核心功能**：定位「**思考笔记本 + Markdown IDE**」——**IDE 式章节重构**（笔记可克隆/升级/降级/移动/提取/在文件间重构）；大纲器（Outliner）分层组织；**知识图谱导航 + 知识自动链接（autolinking）**；「联想（associations）」——搜索/浏览/阅读/书写时自动带出相关内容，边写边提醒已有相关笔记；Organizer（艾森豪威尔矩阵 + Kanban）；数学/图表/图片/TOC；搜索（名称/标签/文本/正则）；导出 HTML、CSV（含 one-hot 编码供机器学习）；本地存储、隐私优先，可用 Git/云盘自行同步加密
- **UI 设计**：C++/Qt，功能密集偏工具型；大文件性能好（数千章节/数百文件即时解析索引）
- **技术栈**：C++ / Qt（原生）
- **AI 能力**：**Wingman** —— 基于 LLM（OpenAI）的助手，可扩写笔记、起草博客、拟计划、生成想法
- **可借鉴点**：1）**「知识自动链接 + 边写边联想」**——无需手动建双链，系统自动发现并提示相关笔记，是降低双链维护成本的思路；2）IDE 式「章节可跨文件重构」把编程重构带进写作；3）Wingman 展示了传统原生笔记 App 接 LLM 的一种形态
- **不足**：Qt 工具型 UI 偏老气、非设计驱动；概念多、上手陡；star/维护数据因仓库迁移未完全核实

### KeenWrite

- **基本信息**：开发者 Dave Jarvis（源自 Karl Tauber 的 Markdown-Writer-FX 分支演化）｜平台 Windows / macOS / Linux｜**免费、开源（BSD 2-clause）**｜官网 https://keenwrite.com ｜GitHub 有多个分支仓库（canonical 归属不完全确定，star 数未核实/较少）｜维护状态：见仓库（部分分支 2023 后趋缓）
- **编辑模式**：左编辑右预览分栏，实时预览
- **核心功能**：主打两大差异化——**字符串插值/变量**（文档内定义并复用插值变量、按变量值自动补全，更像开发环境而非编辑器）与 **R Markdown 支持**（在 `.Rmd` 里嵌 R 代码块，导出时启动 R 环境执行、把 ggplot2 图/CSV 计算结果织入 PDF，服务可复现研究）；**XHTML→TeX 管线做像素级精排 PDF**（内容与呈现分离）；JS/Lua 脚本做条件文本/自动元数据；`diagram-` 前缀标记图表（经服务渲染，新图表类型无需升级软件即可用）；标签页文档 + 批量导出合并 PDF；CLI 批处理；GFM/CommonMark 兼容
- **UI 设计**：编辑器 + 预览 + 变量/设置侧栏，干净可定制
- **技术栈**：**Java / JavaFX**（需 JRE 21 完整版，含 JavaFX，如 BellSoft Full）
- **AI 能力**：无
- **可借鉴点**：1）**字符串插值/变量**在纯文本写作里很罕见，对「模板化/参数化文档」（合同、报告、批量个性化）是杀手锏，可作为差异化功能候选；2）R Markdown / 可复现研究导向的学术定位；3）XHTML→TeX 的高质量排版导出思路
- **不足**：依赖 Java 运行时（JRE 21 + JavaFX，安装门槛高）；canonical 仓库归属与维护活跃度不清晰；面向学术/数据的小众定位

### Beaver Notes

- **基本信息**：开发者 Beaver-Notes 社区｜平台 macOS / Windows / Linux / Android / iOS（全五端）｜**免费、开源（MIT）**，宣称「永久免费」｜官网 https://beavernotes.com ｜GitHub https://github.com/Beaver-Notes/Beaver-Notes，约 **1,310 star**｜维护状态：活跃（最近提交 2026-07）
- **编辑模式**：所见即所得的块式富文本编辑（Markdown 原生存储）
- **核心功能**：隐私/离线优先，全部存本地；Markdown、笔记互链、文件附件、LaTeX 数学；**内置绘图 + 录音笔记**（应用内直接录音）、图片/表格/视频；专注模式（隐藏菜单 + 全屏）；**标题树（Headings Tree）**导航长笔记；标签/全文搜索/按多维度排序；笔记可加书签/归档/密码锁/删除；内置分享（连同内嵌绘图与文件一起发送）；自带同步或自托管
- **UI 设计**：简洁直观、干净；定位「快速、无干扰、隐私优先」，明确不做团队协作/AI 工作区
- **技术栈**：Electron + Vue（块编辑器）
- **AI 能力**：无（刻意不做 AI，强调隐私与专注）
- **可借鉴点**：1）**内置绘图 + 应用内录音笔记**把「手写草图/语音」纳入 Markdown 笔记，是多模态记录的轻量实现；2）「标题树」长文导航；3）「永久免费 + 隐私优先 + 自托管同步」的开源定位表达清晰
- **不足**：Electron；刻意不做 AI 与协作，功能面偏个人向；生态不及 Obsidian/Joplin

---

## 四、移动端遗漏

> 类别观察：01 号已收录 iOS 系（iA Writer、1Writer、Byword、Taio、Drafts 等），但 **Android 开源阵营与部分移动写作 App 是空白**。以下三款是移动端榜单常客。

### Markor

- **基本信息**：开发者 gsantner｜平台 **仅 Android**｜**免费、GPL-3.0 开源**，无广告无多余权限｜GitHub https://github.com/gsantner/markor，约 **5,870 star**｜分发：**F-Droid / GitHub 独占**（已主动退出 Google Play，作者称「Play 上架耗时，宁可把时间用来改代码」）｜维护状态：极活跃（最近提交 2026-07）
- **编辑模式**：源码 + 语法高亮编辑 + 预览（转/预览/分享为 HTML、PDF）
- **核心功能**：轻量、离线、完全无账户；支持 **Markdown + todo.txt + AsciiDoc + Org-Mode + CSV/ics/ini/json/toml/txt/vcf/yaml** 多种纯文本格式；Notebook / QuickNote / To-Do 三大入口；**AES-256 文件加密**（需设密码，Android 6+）；自动保存 + 撤销/重做；黑色暗主题、多语言；与任意同步 App 协作（官方推荐 Syncthing，也支持 Nextcloud/Dropbox/Seafile 等）
- **UI 设计**：极简轻量，可高度自定义；黑色暗主题
- **技术栈**：原生 Android（Java/Kotlin）
- **AI 能力**：无
- **可借鉴点**：1）**「一个编辑器吃下 Markdown/todo.txt/Org/CSV 等一堆纯文本格式」**的通用纯文本编辑器定位，适合极客人群；2）「退出应用商店、只走 F-Droid/GitHub」是硬核开源分发的极端案例（对我们 macOS 直分发 vs App Store 的取舍有参考）；3）「与外部同步 App 解耦、自己不做同步」的极简策略
- **不足**：仅 Android；非渲染式所见即所得；界面偏工具、非设计驱动

### JotterPad

- **基本信息**：开发者 JotterPad 团队｜平台 Android + iOS + Web（Chrome 扩展）｜**闭源、freemium**（免费版功能受限，Pro 约 **$29.99/年**，跨平台通用）｜官网 https://jotterpad.app ｜维护状态：活跃
- **编辑模式**：**所见即所得（WYSIWYG）**——写 Markdown / Fountain 时自动转富文本，点按即可套用格式，无需记语法
- **核心功能**：同时支持 **Markdown 与 Fountain（剧本格式）**，面向作家/编剧；字数统计 + 阅读时长 + 可读性评分；打字机滚动、短语搜索；云同步（Google Drive / Dropbox / OneDrive）；导出 Word / PDF / HTML / RTF / **Final Draft (.fdx)** / Fountain / Markdown
- **UI 设计**：面向专业写作者的干净 WYSIWYG，移动端优化
- **技术栈**：移动原生 + Web
- **AI 能力**：有 AI 写作辅助（各版本演进中）
- **可借鉴点**：1）**Markdown + Fountain 双语法**把「剧本写作」这个细分刚需纳入，是清晰的垂直定位；2）导出到 Final Draft (.fdx) 等专业格式，服务真实创作流水线；3）阅读时长 + 可读性评分等「写作者关怀」指标
- **不足**：闭源、订阅制；剧本向定位对普通 Markdown 用户偏窄

### Editorial

- **基本信息**：开发者 Ole Zorn（omz-software）｜平台 **仅 iOS**｜付费一次性买断（App Store）｜官网 https://omz-software.com/editorial ｜维护状态：**已不再积极开发**（公共工作流目录已转只读）
- **编辑模式**：纯文本编辑 + 精美内联预览（Markdown / TaskPaper / Fountain）
- **核心功能**：**招牌是自动化**——50+ 文本处理动作可拼成自定义工作流（workflow），更进阶可用**内置 Python 脚本 + UI 编辑器**做任意自动化；Fountain 剧本预览（含页码）、导出可打印 PDF
- **UI 设计**：iOS 上精致的编辑 + 预览；工作流/脚本面板
- **技术栈**：iOS 原生 + Python 解释器
- **AI 能力**：无（其自动化理念早于 AI 时代）
- **可借鉴点**：1）**「可视化工作流（动作拼装）+ 底层脚本（Python）」的双层自动化**，被誉为「领先时代 6 年」，是 Apple Shortcuts 的思想先驱——这套「低门槛可视化 + 高上限脚本」的扩展分层，对我们设计插件/自动化体系极具启发；2）内联预览多格式（md/TaskPaper/Fountain）
- **不足**：已停更、仅 iOS；工作流公共目录关闭；作为历史/理念参照价值 > 实用价值

> 另记一款移动端开源项目：**ArveleaWriter**（iOS/iPadOS，开源，所见即所得 Markdown 编辑器，可打开 iOS Files 中的文件）——体量小、资料少，作为 iOS 开源候选记录。

---

## 五、次要 / 邻接项目一句话清单（已核查，不单列详表）

以下条目经核查后判断为**次要、邻接、或 Markdown 只是其众多功能之一**，不单独展开，附一句话原因：

**macOS 邻接（Markdown 非核心）**
- **DEVONthink**：老牌 Mac 文档管理器，3.7 起支持 Markdown 的 WYSIWYG 编辑 + 文件转录（transclusion）+ 兼容 Roam/Obsidian/iA 语法、MathJax/Prism 扩展——但 Markdown 只是其一项能力，主体是文档库/AI 分类，且闭源重型。
- **Agenda**：以「日期/时间线」为轴的笔记 App（macOS/iOS），支持 Markdown 风格标记，但非纯 `.md` 文件、定位是项目日志而非编辑器。

**wiki / 知识库 / 文档平台（偏协作，非编辑器本体）**
- **TiddlyWiki**：经 `markdown-it` 插件可支持 Markdown，但其原生格式是 WikiText，Markdown 属次要选项；本质是单文件个人 wiki。
- **Nuclino / GitBook / BookStack / Wiki.js**：团队 wiki / 文档站平台，接受 Markdown 输入，但重心在协作/发布/托管，不属「编辑器」品类。

**Web / 在线（多为轻量工具或 SEO 站，非独立强产品）**
- **Taskade**（协作 + AI 工作区）、**Umo Editor**（Vue3/Tiptap 可嵌入组件 + AI）、**Markwhen**（文本转时间线）、**Markups**（Monaco 在线编辑器）、**MarkTwo**（PWA + Google Drive 同步）、**321Markdown / Typo / Reprose / Holocron（GitHub+AI）/ Markvim / Classeur（StackEdit 团队）**：功能与已收录的 StackEdit/Dillinger/HackMD/Vditor 等高度重叠或更轻，无显著独特点。
- **Word2md / PDF2MD / MdToPdf**：格式转换器，非编辑器（转换枢纽已由 06/09 号的 Pandoc 覆盖）。

**其他桌面小工具（小众 / 早期 / 与已收录重叠）**
- **Ferrite**（Rust）、**Inkwell**（Rust/Tauri）、**GeekDown**（Milkdown 套壳）、**Scratch**（离线 + 本地 AI）、**Octarine**、**Stik**（macOS 速记）、**Splitmark**、**Kindling**（小说写作）、**IWE**（Rust PKM + Markdown LSP，思路可与 07 号 Marksman 对读）、**Marknote**（KDE，GPL-2.0，偏富文本笔记）、**MarkMyWords / MDLook（WebView2）/ MarkdownObserver / Trudido**：均为小众或早期项目，无超出已收录产品的独特价值点。

**已在 01 / 09 号覆盖，出现在榜单中但不重复收录**
- **MarkEdit**、**swift-markdown-engine**(nodes-app)、**SwiftUIMarkdownEditor**、**MacDown**、**SwiftDown**、**Neon**、**CodeEdit**、**Runestone**、**STTextView**、**Milkdown**、**Reor** 等——已在原生编辑器/技术栈文档在册。

---

## 本类别小结

- **覆盖度确认**：主流市场已被 01–09 号文档充分覆盖，本次跨 6 类榜单核查未发现「主流级」遗漏，说明既有调研基本达成「覆盖全市场」的目标。
- **真正的增量在新生代**：最值得关注的是**「原生 macOS Swift + 开源 + 面向 AI Agent 协作」这一 2025–2026 新物种簇**（OpenMark、Clearly、SideMark、MacMD、Marky、LitSquare Ink MD，加上 Nimbalyst、NoteGen、HelixNotes）。它们体量虽小、有的还很粗糙，但**与我们的定位几乎逐条重合**，且共同验证了一个方向：**AI 辅助开发正把「造一个原生 Swift Markdown 编辑器」的门槛快速拉低，而新玩家不约而同把「编辑器作为 AI Agent 的可视化前端 / 数据源」当作切入点**（内置 MCP server、人机三方合并、内联 diff、编辑 `CLAUDE.md`/`AGENTS.md`）。
- **对我们的直接启示**：
  1. **MCP server 内置**（Clearly、QOwnNotes、Yank Note、NoteGen 均已做）——让编辑器成为 AI 的数据源，是比「对话框」更高级的 AI 集成，建议纳入路线图。
  2. **AI 改动 = 内联红/绿 diff + 逐条接受/拒绝**（Nimbalyst）+ **人机三方合并**（SideMark）——这是「可接入 AI」编辑器几乎必然要解决的并发冲突交互，已有现成范式可借鉴。
  3. **「捕获→AI 整理→成文」的三段式工作流**（NoteGen）是不同于「边写边补全」的另一条 AI 主线，差异化定位清晰。
  4. **竞争提示**：OpenMark 已用「SwiftUI + Claude Code 7 天上架 App Store」跑通了与我们几乎相同的技术路线——市场窗口正在快速被独立开发者填入，需在「简洁好看的设计 + 可持续的开源运营 + 扎实的原生体验」上建立差异，而非仅拼「又一个原生 Markdown 编辑器」。
