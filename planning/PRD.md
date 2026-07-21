# Colophon · 产品需求文档（PRD）

> **产品名称：Colophon**（本次对话选定；寓意「书末记录文档如何造成的版本页」，与本产品把 frontmatter / Agent 元数据当一等公民的理念暗合）。App Store 名称 / 域名 / GitHub org 可用性核对中（见 §12）。
> 版本 v0.1 ｜ 2026-07-21 ｜ 依据 `docs/` 两阶段调研撰写（关键来源：09 技术栈、13 产品机会、19 路线 B 蓝图）。
> 本文是「决策文档」：研究在 `docs/`，决定在这里。凡与研究冲突处，以本文为准并注明理由。

---

## 0. 一句话

**一款面向开发者的原生 macOS Markdown 编辑器——好看得不像开发者工具。开源免费、专注克制，并成为「人 ↔ AI Agent 的 Markdown 界面」。**

---

## 1. 背景与要解决的问题

调研（`docs/13`、`docs/10`）交叉验证出一个市场空白：「**原生 macOS + 开源 + 好看 + 会 Agent 语义**」四要素叠加目前无人占据——Typora 闭源收费无 AI、Mark Text 停摆失信、MacDown/Mou 已死、MarkEdit 刻意极简（无预览/无文库）、妙言无 AI。

但有一个**反直觉的前提**必须写进 PRD：2025–26 涌现了一簇用 AI 快速拼出来的「原生+开源+AI」小工具（OpenMark、Clearly、SideMark、NoteGen…，见 `docs/10`、`docs/18`）。所以「原生/开源/好看/AI」这四个形容词**已是入场券，不是差异化**。

> **本产品真正的护城河 = 一个 7 天 AI 拼不出来的东西：审美（taste）+ 克制（focus）+ 原生手感 + 路线 B 里别人没有的 AST 能力。**

目标用户的具体痛点：写大量 Markdown 的开发者，长期被迫在「**原生但丑**」（MarkEdit、终端）和「**好看但 Electron 臃肿**」（Typora、Obsidian）之间二选一。

---

## 2. 目标用户

**主用户：写大量 Markdown 的开发者。** 典型文档：README、技术文档、API 文档、`CLAUDE.md` / `AGENTS.md` / 规则文件、技术博客、开发笔记、spec/todo。

**非目标用户（暂不服务，避免范围失控）：**
- 重度 PKM / 双链知识管理用户 → 那是 Obsidian/Logseq 的战场（§5.4 不做）。
- 纯写作者 / 小说家 → iA Writer/Ulysses 的地盘。
- 中文公众号排版者 → 后续可选差异化（`docs/13` V1 提及），**不是 MVP 方向**。

---

## 3. 产品信念与设计原则

1. **心流优先，AI 是仆人不是主角。** 编辑器自己不生成内容。
2. **文件属于你的文件夹，不属于 app（file over app）。** 本地 `.md` 是唯一真相源，永不引入私有格式，导出零门槛。
3. **原生优先。** 启动速度、内存、打字延迟、系统集成（Writing Tools、QuickLook、快捷指令）是 Electron 阵营结构性给不了的，做成显性卖点。
4. **克制即差异化。** 只做「编辑器」这一件事，做少而精；每加一个功能先问「这会不会让它变成 IDE / PKM」。
5. **AI 解耦、可选、可关。** 默认本地优先，可整体关闭；AI 能力设计为「语法树上的操作」，独立于编辑内核。
6. **优先用系统原生组件，免费继承 Apple 设计演进。** 用标准 SwiftUI/AppKit 组件，macOS 26 上自动获得 Liquid Glass、macOS 15 上自动回退经典外观，零分支零维护——这是 Electron 结构上做不到的又一条护城河。编辑区（正文内容层）保持非玻璃、可读，符合 Apple 官方指导（详见 §7）。

---

## 4. 定位与差异化

**定位句：** 「Typora 级的编辑体验 + iA Writer 级的排版审美 + Obsidian 级的数据主权，做成一个开源免费、且**天然懂 AI Agent**的原生 macOS 应用。」

| 对手 | 它的强项 | 我们的打点 |
|---|---|---|
| Typora | 实时渲染标杆、口碑 | 开源免费、原生性能与系统集成、路线 B 的 Agent 能力、版本历史 |
| MarkEdit | 同为原生开源、系统感好 | 它刻意不做预览/文库/AI；我们「开箱即完整」并接管 Agent 场景 |
| Obsidian | 生态之王、Live Preview | **不做全功能 PKM**；轻快美 + 原生手感 + 可直接打开其 vault 降低迁移成本 |
| 新生代 AI 编辑器（SideMark/VMark/OpenMark…） | 同做「开源+AI」、迭代快 | 它们是 Electron/Tauri/Web 壳且粗糙；**原生 AppKit 手感 + 审美 + AST 结构化编辑**是护城河 |

---

## 5. 功能范围与分层

> 分层总原则（`docs/13` §4.0、`docs/19` §三）：**范围克制第一**。MVP 把编辑器一件事做到能日用；路线 B 的重功能一律后置；**MVP 阶段不做任何具体 AI，只留架构缝**。

### 5.1 MVP —— 立住「原生、简洁、好看、可靠」+ 留好 AI 的门

**编辑核心**
- 源码编辑 + 语法样式化（标题变大、粗体变粗，标记符视觉弱化但保留）。
- `⌘\` 一键分屏实时预览，60fps 双向滚动同步。
- GFM 全家桶（表格、任务列表、删除线、脚注）+ LaTeX 数学 + Mermaid + **代码块高亮做成一等公民**（质量、复制按钮、语言标签）。
- Markdown 语义快捷键（`⌘B`/`⌘I`/升降标题/勾选任务）+ 列表续行与编号自动修复。
- 图片粘贴/拖拽自动落盘（目录规则可配）+ 选中粘贴 URL 自动成链接。

**文件与组织**
- 本地文件夹即文库（用户自选，无账号、无私有格式），iCloud Drive/网盘天然同步。
- omnibar（搜索与新建合一）+ 全文搜索；命令面板（`⇧⌘P`）。
- 自动保存 + 基于文件系统的版本历史。

**体验与外观**
- 专注模式（行/句/段可选）+ 打字机滚动。
- 深浅色主题各一套精调 + 完全贴合 macOS 规范（原生工具栏、系统控件、自动深浅色、SF Symbols）。
- 导出 HTML / PDF（走系统 WebKit/PDFKit）。

**路线 B 的「门」（不做具体 AI，只留缝——`docs/19` §3.1）**
- **Agent 文件一等公民 + byte-exact 保存**：识别 `CLAUDE.md`/`AGENTS.md`/`*.mdc`/`SKILL.md`/`llms.txt` 等，特别渲染；**关闭智能引号/破折号替换**（否则破坏 frontmatter 与代码 fence），非 UTF-8 报错而非静默损坏。
- **文件监听、无「已在磁盘更改」弹窗**：外部（Agent）改盘上文件即时刷新（macOS FSEvents），有冲突给 Reload/Ignore/Compare。
- **架构缝：AI = 语法树上的操作**：基于 `swift-markdown` 的 SourceRange/AST 划好文档操作 API 边界，供未来 Skills/MCP/BYOK 对接——**现在只划边界，不实现任何 AI**。

**工程底线**
- 首发即代码签名 + 公证；GitHub Releases + Homebrew 分发；崩溃即修的小步发版。

### 5.2 V1 —— 差异化（混合渲染 + 路线 B 落地 + 主题生态）

- **行内混合渲染**（anti-conceal：全文渲染态、仅光标行/选区还原源码），与源码模式、阅读模式三态切换。评估以 `swift-markdown-engine`（Apache-2.0）为起点或上游。
- **随产品自带官方 Agent Skills**（教外部 Agent 认识我们文库的约定）——**零 server 兑现路线 B**（`docs/19` §3.2、`docs/16`）。
- frontmatter 表单化编辑 + **glob 感知**（实时校验 + 匹配预览）+ 多文件规则管理面板（作用域/优先级/冲突高亮）。
- **外部 Agent 改动以内联 diff 呈现，逐 hunk accept/reject** + 统一审批策略（Auto·Ask·Plan）。
- 把 spec/计划/报告渲染好（Given-When-Then/EARS 着色、`[NEEDS CLARIFICATION]` 聚合、引用回溯）+ **任务复选框一等交互** + checkpoint 回滚。
- 模板库（AGENTS.md/CLAUDE.md/.mdc/spec/PRD/CHANGELOG）+ **Skill 作者工作台**。
- 主题即一个样式文件 + 官方主题画廊；`[[wiki 链接]]` + 反向链接。
- （可选）中文排版细节；复制为公众号/知乎格式。

### 5.3 V2 —— 生态 / 纵深

- **内置 MCP server**（stdio 为主）：基线七件套 + **`apply_edit` AST 结构化编辑**（独占）+ 暴露活动编辑器状态 + 三原语齐用（接口草案见 `docs/19` §四、`docs/15`）。
- 三方合并（SideMark 式）+ Smart hunk grouping。
- 本地被动「相关笔记推荐」（本地 embedding，零配置）；Skill 画廊/市场（装前强制源码审阅）。
- 从文库生成 `llms.txt`；AI 文本标注（Authorship）；JSON Canvas 读取/渲染互操作。
- 发布管线（博客/静态站）；QuickLook 插件；笔记加密；iOS 伴侣版评估。

### 5.4 明确不做（同样是承诺）

- **不内嵌 CLI 终端 / Agent 运行时**（Ritemark/cmux 的路；我们当数据源，让外部 Agent 去跑）。
- **不自建 RAG / 向量库 / 「捕获→整理→Agent」全家桶**（V2 前）。
- **不做块编辑器 / 数据库 / 白板 / 全功能 PKM**（Notion/AFFiNE 战场）。
- **不搞全家桶式 AI 军备竞赛**（Trilium 的维护黑洞教训）。
- **不自建同步服务器**（交给 iCloud/网盘/Git）；**不做私有存储格式、不把导出设为付费墙**。
- 首版**不做 Windows/Linux、不做实时协同**。

---

## 6. AI / 路线 B 策略（摘要，全文见 `docs/19`）

- **两条路线**：路线 A（AI 只做机械活：粘贴转表格、清洗格式、代码示例，**不生成内容**）；**路线 B（主赌注）**：编辑器 = 人↔Agent 的 Markdown 界面。
- **顺序**：MVP 只留门 → **V1 先做 Agent Skills（零 server，当天可验证）** → V2 才做内置 MCP server。
- **独占牌**：`apply_edit` 基于 `swift-markdown` AST/SourceRange 的结构化编辑 + 暴露活动编辑器状态——全行业笔记类 MCP server 无人做。
- **押注标准**：AGENTS.md、MCP、Agent Skills、llms.txt、JSON Canvas（前三者同归 Linux Foundation AAIF，治理风险可控）。
- **8 个开放问题靠 dogfooding 解决**（`docs/19` §八），不在 MVP 拍板。

---

## 7. 技术架构（依据 `docs/09`）

- **总路线**：**方案 A（全原生混合渲染）为终态、方案 C（SwiftUI 快速路线）为首发**的渐进路线——先发布分屏版收集用户，同期开发混合渲染内核。
- **M1 架构**：SwiftUI 壳（NavigationSplitView 三栏）＋ 编辑区 `NSTextView`(TextKit 2) 薄封装（经 `NSViewRepresentable` 桥接）＋ `swift-markdown` 解析 ＋ `WKWebView` 分屏预览/导出。
- **M2 架构**：引入/借鉴 `swift-markdown-engine` 落地行内混合渲染。

**组件清单**

| 层 | 选型 | 备注 |
|---|---|---|
| 编辑区 | AppKit `NSTextView` + TextKit 2 | 原生混合渲染唯一官方地基；Writing Tools 也需 TextKit 2 |
| 解析（语义/导出） | `swift-markdown` + `swift-cmark`(gfm) | Apple 官方、SPM 一行、SourceRange 精确 |
| 实时高亮 | tree-sitter + SwiftTreeSitter + Neon | 「增量高亮 + 全量 AST」双解析器 |
| 代码块高亮 | Highlightr/HighlighterSwift 起步 | 快速出效果 |
| 行内数学 | SwiftMath | 原生 CoreText |
| 预览/导出/图表 | WKWebView 子系统（KaTeX/Mermaid/Shiki） | 仅限预览/导出/图表；PDF 走 PDFKit，**不引入无头 Chrome** |
| 复杂格式导出 | 外接 Pandoc | 不自研导出 |

**关键取舍与红线**
- **不用 Electron，不用 Tauri**（`docs/09` §七）。
- **许可雷区**：`STTextView` 已改 GPLv3 —— 若选 MIT/Apache 发布需绕开（见 §12 编辑内核决策）；`Down`/`Ink`/`SwiftDown` 均停更，不引入。
- **TextKit 2 防坑进工程规范**：禁触 `.layoutManager` 防降级、滚动估算跳动要有对策、打印/PDF 走 WKWebView。
- **AI 层 = 语法树操作**，独立于编辑内核，云端/本地/协议三通路皆可插。
- **Liquid Glass / 系统原生外观**：用最新 Xcode（macOS 26 SDK）编译、最低目标 macOS 15；chrome 全用标准 SwiftUI/AppKit 组件 → macOS 26 上自动玻璃、macOS 15 上自动回退，**零分支**；显式玻璃 API（`glassEffect` / `GlassEffectContainer` / `.buttonStyle(.glass)`，均 `macOS 26+`）一律 `if #available(macOS 26, *)` 门控；**编辑区（内容层）保持非玻璃、可读**（Apple 官方指导：玻璃只用于导航/控件层）；玻璃效果需 macOS 26 环境测试（macOS 无模拟器）。可选过渡逃生舱 `UIDesignRequiresCompatibility`（临时，Xcode 27 起失效，不作长期方案）。

---

## 8. 开发里程碑（回答「分几个阶段」）

> 工作量为粗估（`docs/09`：从零编辑器核心约 6–12 人月，WebView 路线 2–4 人月，基于 `swift-markdown-engine` 可砍一半以上）。单人 + AI 辅助节奏，重在顺序而非绝对工期。

- **M0 · 立项与骨架**：建 repo、选 License、CI/CD、签名公证跑通、SwiftUI 三栏壳 + 空 `NSTextView` + 打开/编辑/保存单个 `.md` + 深浅色。
  **完成定义**：能可靠打开、编辑、保存一个 Markdown 文件，且已签名公证。
- **M1 · MVP**（§5.1 全部）。**完成定义**：作者能每天用它写 README/`CLAUDE.md`；能打开一个文件夹当文库；发布首个 public release。
- **M2 · V1**（§5.2）：混合渲染 + Agent Skills + diff 审阅 + frontmatter/glob。**完成定义**：路线 B 的结构性差异化立起来（哪怕只有 Skills 那一环）。
- **M3 · V2**（§5.3）：内置 MCP server 等生态纵深，按 dogfooding 发现的真实需求排序。

**贯穿全程**：dogfooding（自己用它写本项目的所有 `.md`）、季度小发版、核心难点（TextKit 2 混合渲染）尽早原型验证。

---

## 9. 开源项目运营（依据 `docs/13` §七可持续性教训）

- **License**：**Apache-2.0**（已定）——与 `swift-markdown`/`swift-markdown-engine` 一致且含专利授权。
- **治理**：第一天建立多维护者可能性（合并权限、CONTRIBUTING、BDFL 声明）；避免单点维护者故障（Mark Text 教训）。
- **不可回撤的承诺**（写进 README/宣言）：永久开源、本地 `.md` 唯一真相源永不引入私有格式、数据可随时导出。
- **分发**：GitHub Releases + Homebrew（免费）；首发即签名公证；未来 MAS 付费支持版回血（FSNotes/妙言模式）。
- **可持续**：GitHub Sponsors/捐赠起步；像 Markdown Monster 那样持续内容营销。
- **节奏**：季度小发版传递「项目活着」信号。
- **风险清单**：见 `docs/13` §七（推倒重写、依赖内核死亡、安全架构、AI 维护黑洞、窗口期紧迫）。

---

## 10. 成功标准

- **MVP（M1）**：① 作者本人每天 dogfooding；② 首个 release 通过签名公证、`brew install` 可装；③ 能打开 Obsidian vault；④ 启动速度与内存显著优于 Electron 竞品（可量化对比 Typora/Obsidian）。
- **V1（M2）**：路线 B 至少一环（Agent Skills）被真实用户用于「让 Claude Code/Cursor 操作自己的文库」；社区出现第一个第三方主题。
- **定性北极星**：一个开发者打开它写 `CLAUDE.md`，会觉得「这比我原来的工具舒服，而且它懂我在跟 Agent 打交道」。

---

## 11. 已解决的关键决策（本次对话锁定）

- 目标用户 = 写大量 Markdown 的开发者。
- AI 策略 = 路线 A 只做机械活 + 路线 B 为主赌注；AI 解耦、MVP 只留门。
- 技术总路线 = 方案 C 首发、方案 A 终态；不用 Electron/Tauri。
- 范围克制 = 不做终端/RAG/PKM/白板/同步/私有格式。
- 工程基线 = **Apache-2.0** 开源协议、最低 **macOS 15 Sequoia**、界面**英文优先**（i18n 预留）。

---

## 12. 动笔前待决清单（Open Decisions —— 建 repo 前一起解决）

> 标 ★ 为「建仓库即需要」；其余可在 M0 内定。每条附我的建议。

1. ★ **产品名称** ✅ **已定：Colophon**（经 12 个备选的可用性核查确认：**无同类 Markdown 编辑器同名**——这是致命轴，Colophon 通过；备选里 9/12 恰恰栽在此轴，唯 Marrow 可作「离开出版词族」的替代但寓意更弱）。
   - **资产命名**：GitHub org `colophon-app` + repo `colophon`；Homebrew cask token `colophon`（初期用自建 tap `colophon-app/tap`：`brew install --cask colophon-app/tap/colophon`）；App Store 显示名 `Colophon`；域名首选 `colophon.app`（停放待售约 $2,490）或 `colophon.dev`/`colophon.md`（疑可注册，需 whois 终核）。
   - **风险备注**：Colophon Foundry（现为 Monotype 商标，字体/排版邻接）＋「colophon」为常用出版词（搜索稀释）——免费开源阶段可控；商业化/融资前做一次软件类目（Nice 9/42）正式商标检索。
2. ★ **开源协议** ✅ **已定：Apache-2.0**（与 swift-markdown / swift-markdown-engine 一致、含专利授权）。
3. **最低 macOS 版本** ✅ **已定：macOS 15 Sequoia**（可用 Writing Tools 15.1+，TextKit 2 坑相对少）。
4. **编辑内核起点**：(a) **借鉴/fork `swift-markdown-engine`**（最快到混合渲染，但 pre-1.0 依赖风险）；(b) 从零自研 `NSTextView`+TextKit 2；(c) 先用成熟组件（CodeEditTextView，MIT）做源码模式起步。**建议先做 spike 对比 (a) 与 (c) 再定**。
5. **MVP 编辑模式**：**建议 staged**——M1 先「源码样式化 + 分屏预览」，M2 再上行内混合渲染（避免一上来啃最难的坑）。
6. **App UI 语言** ✅ **已定：英文优先**（i18n 架构预留、后补中文）。
7. **视觉设计方向**：尚无 mockup。默认字体方向（等宽/衬线可切换）、单栏排版对标 iA Writer——**建议动 UI 代码前先出 1–2 张界面 mockup 定调**。
8. **仓库与工程**：Bundle ID、App 图标、目录结构、测试策略、CI 选型（GitHub Actions）——M0 内定。
9. **AI「门」的接口定义**：把 §5.1 的「语法树操作 API 边界」写成一页最小接口草案（轻量，M0/M1 定）。

---

> 下一步：解决 §12 待决项 → 建 Xcode 仓库 → 进入 M0。
