# 核心架构与内核使用规范

> **用途**：本文是 Colophon 的「内核 / 后端 / 框架」核心层的开发宪法——原生 macOS app 没有传统后端，编辑内核、文档模型、文件层、解析层就是本产品的「后端」。它约定各层的**边界、职责、依赖方向、数据安全底线与内核使用红线**，供人和 AI 编码助手在写任何架构相关代码前对齐。凡实现与本文冲突，以本文为准。
>
> **适用范围**：M0 骨架 + M1 MVP（§5.1）。本文只定「**现在就能定的原则层**」；凡依赖「编辑内核起点」这一 M1 spike 未决决策（PRD §12.4）的**实现细节**，一律进文末「留到实现时再定」，不在此硬写死。
>
> **语言约定**：当前用中文便于团队理解；代码 / API / 术语 / 文件名一律英文。未来搬进真实仓库作为 `AGENTS.md` / `.claude/rules/*.md` 时译为英文。
>
> **依据**：PRD §5.1 / §7、ROADMAP §2–3、`docs/09`（技术栈与 TextKit 2 坑）、`docs/19`（路线 B 蓝图，尤其 §四接口草案）、`docs/03`（停更/重写教训）、`docs/18`（byte-exact 与冲突交互）、`docs/01`（原生阵营数据架构）。

---

## 1. 分层与模块边界

### 1.1 六层结构

Colophon 分为六层。**下表从上到下即依赖允许的方向；依赖只能单向向下，禁止向上、禁止跨层反向。**

| 层 | 名称 | 职责（做什么） | 明确不做（红线） |
|---|---|---|---|
| L1 | **UI 层**（`UI`） | SwiftUI 壳（`NavigationSplitView` 三栏）、编辑区 `NSViewRepresentable` 桥接、预览面板宿主、命令面板 / omnibar、主题与外观（Liquid Glass 门控） | 不含解析逻辑、不含文件读写、不直接持有磁盘状态；不把 UI 事件当真相源 |
| L2 | **文档模型层**（`DocumentModel`） | 内存中的**唯一真相源**：`Library` / `Document` / `Selection` 抽象、文本存储、编辑意图（intents）、`UndoManager` 归属、脏标记与保存调度 | 不知道自己被谁渲染；不引用任何 SwiftUI/AppKit View 类型；不含 WebView |
| L3 | **解析层**（`Parsing`） | 双轨解析：`swift-markdown` 全量 AST（语义 / 导出 / AST 操作）＋ tree-sitter 增量解析（实时高亮）；提供 `SourceRange` ↔ 文本偏移映射 | 不改文本（纯函数式，输入文本 → 输出树/属性）；不碰 UI；不做 I/O |
| L4 | **渲染预览层**（`Preview`） | `WKWebView` 子系统：分屏 HTML 预览、导出 HTML/PDF、Mermaid / KaTeX / Shiki 渲染、滚动同步 | **只读下游**：Model→HTML 单向；预览**永不回写编辑状态**；不做编辑内核 |
| L5 | **文件层**（`Storage`） | 原子写入、byte-exact 保存、UTF-8 严格编解码、`NSFileCoordinator`/`NSFilePresenter` 外部变更协调、FSEvents 监听、基于文件系统的版本历史 | 不含解析、不含 UI；不引入私有格式、不引入数据库当真相源 |
| L6 | **AI 层（未来，仅留缝）**（`AgentBridge`） | 路线 B 的接入点：未来 Skills / MCP / BYOK **通过 L2 暴露的 AST/SourceRange 操作 API** 读写文档 | **MVP 不实现任何 AI**；只定接口边界（见 §7）；永不绕过 L2 直接改文本缓冲 |

### 1.2 依赖方向的硬约定

- **允许**：L1→L2→L3、L1→L2→L5、L4 读 L2+L3 的产物、L6 只经 L2 的公开 API。
- **禁止**：任何层反向依赖上层；L3/L5 引用 View 类型；L4（WebView）成为编辑真相源；L6 触碰 L2 内部字段或 L1/L4/L5。
- **单一真相源**：磁盘上的 `.md` 是**持久真相源**（file over app，PRD §3.2）；L2 的 `Document` 是**内存真相源**。二者之间只由 L5 搬运，其它层一律经 L2 读写，**不得各自去读盘**。
- **why**：路线 B 要求 AI「插进来而非拆开重做」（`docs/19` §3.1 M4）。只有当「文档操作」全部收口到 L2 的 AST 化 API、且 UI/预览/文件/AI 都是它的下游或客户端时，未来才能在不动编辑内核的前提下接上 Skills/MCP。层界一旦被 UI 直接读盘或 WebView 回写状态打穿，这条缝就废了。

### 1.3 模块化打包（借鉴 `docs/09`）

按 `swift-markdown-engine` 的经验（核心 / 代码块 / LaTeX 三产品拆分控依赖），Colophon 的 Swift package/target 也**按层拆 target**，让依赖方向在编译期被强制：`Parsing`、`Storage` 不得 import `SwiftUI`/`AppKit` 的 View 层 target。具体 target 划分留到 M0 工程搭建时定（PRD §12.8）。

---

## 2. 文档与文库模型

### 2.1 决策：「文件夹即文库」，不用 `NSDocument` / `DocumentGroup`

**现在就定**：Colophon 采用「用户自选的本地文件夹 = 一个 `Library`（文库）」模型，**不**采用 AppKit/SwiftUI 的单文档架构（`NSDocument` / `NSDocumentController` / SwiftUI `DocumentGroup`）。

**why（紧扣本项目决策）**：

1. **产品形态是「打开一个文件夹当文库」**（PRD §5.1、成功标准③「能打开 Obsidian vault」）。`DocumentGroup` 是「一个窗口一个文件」的范式，天然对抗「侧栏文件树 + 跨文件搜索 + 文库级规则面板」这些 MVP/V1 能力（omnibar、全文搜索、多文件规则管理）。
2. **路线 B 要求文库级操作**：MCP server 的 `list_notes`/`search_notes`/`get_backlinks`（`docs/19` §四）是「vault 级」而非「单文档级」的；文库必须是一等抽象。
3. **byte-exact + 外部变更协调需要我们自己掌控 I/O**（见 §3）。`NSDocument` 的自动保存/版本/编码管线是黑盒，会和「关智能标点、严格 UTF-8、无磁盘更改弹窗」打架。自建 `Storage` 层反而更可控。
4. **file over app**：文库不是 app 的私有容器，是用户的普通文件夹（iCloud Drive/网盘天然同步，`docs/01` 共识、`docs/03` Laverna 死于自建同步的反例）。`NSDocument` 的沙箱化文档模型与此叙事相悖。

> **保留的系统能力**：不用 `NSDocument` **不等于**放弃系统集成。文件访问权限走 security-scoped bookmark（沙箱下持久化文件夹授权）；Recent、拖拽、QuickLook 等按需单独接。这些属实现细节，留到 M1。

### 2.2 三个核心抽象

**现在就定接口语义，字段与存储细节留到实现**：

- **`Library`（文库）**：一个根文件夹 + 递归 `.md`（及可配置扩展）视图。职责：文件树、文库级搜索索引、Agent 文件识别表（`CLAUDE.md`/`AGENTS.md`/`*.mdc`/`SKILL.md`/`llms.txt`…，做成**数据驱动配置表**而非硬编码，`docs/19` §3.1 M5）。一个 app 可同时开多个 `Library`。
- **`Document`（文档）**：一个 `.md` 文件的内存真相源。持有：源文本（唯一权威表示，**永远是 Markdown 源码字符串**，不是富文本树）、当前 AST（swift-markdown，派生态、可重算）、`SourceRange` 映射、脏标记、该文档的 `UndoManager`、文件编码与行尾风格（保真用，见 §3）。
- **`Selection`（选区）**：`{ documentID, textRange, 结构范围 }`。**结构范围**是选区在 AST 上的定位（所属标题、列表项、代码块等），由解析层从 `textRange` 计算。路线 B 的 `get_selection` / `replace_selection`（`docs/19` §四）就建立在这个双重表示上——**现在就把选区设计成「文本范围 + 结构范围」双表示**，哪怕 MVP 只用到文本范围。

**why 源码为唯一权威表示**：这是与 ProseMirror 系「富文本树为真相、Markdown 是序列化格式」的根本分野（`docs/09` §一）。ProseMirror 往返会丢源码细节（空行、标记风格、非标准语法）——对「源文件即真相」的产品是 dealbreaker。Colophon 的 `Document` **必须以源码字符串为准，AST 永远是可从源码重算的派生态**，保证保存与源文件字节一致（对齐 CM6/Obsidian Live Preview 的数据模型）。

### 2.3 文库/文档生命周期（原则层）

- 打开文库 = 拿到文件夹授权 + 建文件树 + 起 FSEvents 监听（§3）。
- 打开文档 = L5 读盘（记录编码/行尾/BOM）→ L2 建 `Document` → L3 解析出首个 AST。
- **懒加载**：文库可含上万文件（`docs/01` FSNotes「10k+ 文件流畅」是基准线），文件树与搜索索引不得一次性全读进内存全解析。具体索引策略留到实现。

---

## 3. 文件 I/O 与数据安全（重中之重）

> **这一节是产品的生死线。** `docs/03`/`docs/18` 的教训极其一致：**数据丢失 = 口碑死亡**（Mark Text/Muya 的「丢数据 bug」、Laverna 死于同步、Notable 转闭源两头落空）。宁可功能少，绝不丢字节、绝不损坏用户文件。以下每一条都是 MUST。

### 3.1 原子写入（MUST）

- **一切保存走原子替换**：写临时文件 → `fsync` → 原子 rename 到目标路径，绝不「先截断原文件再写」。崩溃/断电时要么是旧完整版、要么是新完整版，**永不留半截文件**。
- macOS 上优先用系统提供的原子写入原语（`Data.write(options: .atomic)` / `NSFileCoordinator` 协调下的写入）；实现选型留到 M1，但**语义是硬要求**。
- **保留文件元数据**：原子替换后要保持原文件的权限、扩展属性（不无故清除 `com.apple.*` 或用户的 xattr）、以及尽量保留 inode 语义以配合外部同步/版本工具。细节留到实现。

### 3.2 byte-exact 保存（MUST，路线 B 核心正确性底线）

对齐 MacMD 的工程取舍（`docs/18`，PRD §5.1、ROADMAP §3.4）：**Agent 配置文件对字节保真极敏感，智能标点会破坏 `.mdc` frontmatter 与代码 fence。**

- **关闭一切「智能」文本替换**：智能引号（`"` `"` `'` `'`）、智能破折号（`--`→`—`）、自动首字母大写、自动句号、自动替换/自动更正、连字（ligature 影响不算，但自动 dash/quote 替换必须关）。在编辑区 `NSTextView` 上：`isAutomaticQuoteSubstitutionEnabled = false`、`isAutomaticDashSubstitutionEnabled = false`、`isAutomaticTextReplacementEnabled = false`、`isAutomaticSpellingCorrectionEnabled = false`、`isAutomaticCapitalizationEnabled = false`（拼写**检查**红线波浪可保留，但**自动纠正**必须关）。
- **严格 UTF-8**：读时若非合法 UTF-8，**报错而非静默损坏/替换字符**（不静默转 Latin-1、不用替换符 `�` 吞掉）。给用户明确提示与「以其它编码打开」的显式选择，绝不静默改字节。
- **保真往返**：保存内容 = 编辑区源码逐字节；**不重排、不规范化空白、不改行尾**。行尾风格（LF/CRLF）、末尾换行有无、BOM 有无，都按**读入时的原样**回写（在 `Document` 上记录这些保真属性）。任何「格式化」都必须是用户显式触发的独立命令，绝不在保存时偷偷做。
- **why 这条独立于其它**：这是「给写 Markdown 的开发者做的编辑器」几乎零成本却直接兑现的差异化（`docs/18` 逐条可抄）。普通写作 App 的默认「智能」行为在这里全是 bug。

### 3.3 外部变更协调 —— 支撑「无磁盘更改弹窗」（MUST）

路线 B 最低门槛（`docs/19` §3.1 M1、§六 6.6）：**Agent 在盘上改文件，编辑器即时反映，无「文件已在磁盘上更改」弹窗。**

- **监听**：用 macOS 原生 **FSEvents**（文库级目录监听）感知外部写入。为单文档编辑一致性，配合 **`NSFilePresenter` / `NSFileCoordinator`**：我们既是 presenter（收到外部协调写入的通知），写入时也用 coordinator（避免与外部工具/同步进程打架）。FSEvents 管「文库里发生了什么」，FileCoordinator 管「我和别人对同一文件的读写不打架」——两者职责不同，**都要**。
- **无脏冲突 → 静默刷新**：外部改了某文件、而我们本地对该文件**无未保存改动**时，直接重载、无弹窗（比 Obsidian「切走再切回才看到」更好，`docs/19` §3.1）。
- **有脏冲突 → 三选项**：外部改了、且我们本地有未保存改动时，给 **Reload / Ignore / Compare** 三选项（`docs/19` §3.1、§六 6.6 MVP 档）。**MVP 只做到这一档**；逐 hunk diff（V1）、三方合并（V2）后置。
- **防抖 / 去重**：我们自己的原子写入会触发 FSEvents，必须能区分「自己写的」和「外部写的」，避免自我刷新循环。机制（如写入前后打标记/比对 mtime+size+内容 hash）留到实现，但**必须防自触发**。

### 3.4 iCloud / 网盘冲突处理（原则层）

- **不自建同步**（PRD §5.4 红线，`docs/03` Laverna 教训）：同步交给 iCloud Drive / 网盘 / Git，我们只做「本地文件夹里的编辑器」。
- **正确参与 iCloud 协调**：文库在 iCloud Drive 内时，走 `NSFileCoordinator` 能正确处理下载占位、协调写入。对 iCloud 产生的冲突副本（`filename 2.md` 之类），MVP 至少**不加剧**（不覆盖、不静默合并），能识别并提示即可。**主动的冲突 UI 留到实现/V1**。
- **网盘**（Dropbox/坚果云等）本质是外部写入，走 §3.3 的同一套协调即可，无需特殊路径。

### 3.5 自动保存 + 基于文件系统的版本历史

- **自动保存**：MVP 做自动保存（PRD §5.1），策略是「防抖 + 失焦即存」之类，但**每次落盘都必须满足 §3.1 原子 + §3.2 byte-exact**。绝不用自动保存换取正确性。
- **版本历史基于文件系统**（对齐 iA Writer / FSNotes，`docs/01`）：不发明私有历史格式。**现在就定方向**：本地快照式历史（每次显著变更/保存前留一份），为路线 B 的 checkpoint 回滚（`docs/19` §六 6.5「每次写前本地快照」）打底。**用本地快照目录还是内置 Git（FSNotes 用 Git）留到实现**——但接口上要能支持「Restore 这一步 / 这个文件」。
- **删除永不硬删**（PRD 红线 / `docs/19` §六）：删除默认进废纸篓（`NSFileManager` trash API），绝不 `unlink` 永久删。

---

## 4. 线程模型

### 4.1 主线程只碰 UI，解析/高亮/IO 放后台（MUST）

- **主线程（MainActor）**：只做 UI 更新、`NSTextView` 文本存储的读写、`UndoManager` 注册、光标/选区。TextKit 的文本存储与布局**必须**在主线程访问。
- **后台**：文件读写（L5）、全量 AST 解析（swift-markdown，L3）、tree-sitter 增量解析、全文搜索索引、导出。结果**跳回主线程**再落到 UI/模型。
- **why**：`docs/09` 的双解析器架构本就为「不阻塞打字」而生；大文档（Bear 55ms 开《白鲸记》是标杆）要求解析不能卡主线程。

### 4.2 双轨解析约定（现在就定分工，实现留到 spike）

**这是 `docs/09` 反复强调的行业共识做法（tree-sitter 管高亮 + 全量 AST 管语义/导出）：**

| 轨道 | 用途 | 特性 | 谁消费 |
|---|---|---|---|
| **tree-sitter（增量）** | 编辑区**实时高亮**、光标处结构感知 | 编辑后毫秒级局部重解析、错误容忍、低延迟 | L1 编辑区（经 Neon 式属性映射） |
| **swift-markdown（全量 AST）** | **语义**（大纲、frontmatter、Agent 文件语义）、**导出**、**AST 操作 API** | 不可变值类型、精确 `SourceRange`、线程安全、写时复制 | L4 预览/导出、L6 AI 缝、L2 结构操作 |

- **约定**：**高亮永不等全量 AST**（否则打字掉帧）；**语义/导出/AI 操作永不用增量高亮树**（tree-sitter markdown 文法「怪癖多」，`docs/09`，不能当语义真相）。两轨都从**同一份源码字符串**派生，源码是唯一真相。
- **失效与节流**：编辑触发增量高亮的局部失效（Neon 式失效区间计算，`docs/09`）；全量 AST 用防抖重算（不必每键一次）。**具体节流阈值、增量失效算法留到实现**。
- **注意**：MVP（M1）不做行内混合渲染，高亮是「源码样式化」（标题变大、粗体变粗、标记符弱化但保留，PRD §5.1）。是否 M1 就引入 tree-sitter、还是先用解析驱动的属性映射顶着，**属于编辑内核 spike 的一部分，留到实现**（见文末）。

---

## 5. Undo / Redo

**现在就定原则，coalescing 细节留到实现：**

- **每个 `Document` 一个 `UndoManager`**，归属在 L2 文档模型层，**不是** L1 View 层。理由：撤销的是「文档内容的变更」，未来 AI 层（L6）对文档做的 AST 操作也必须能被同一个 `UndoManager` 撤销——若 undo 绑在 NSTextView 上，AI 经 API 改文档就绕过了 undo 栈，路线 B 的「checkpoint 回滚」和普通 undo 会割裂。
- **NSTextView 的 undo 整合**：`NSTextView` 自带 undo。约定是**让编辑操作最终收敛到 L2 的编辑意图（intent）上，由 L2 统一注册 undo**，而非任 NSTextView 和模型各记一份导致双重撤销。具体是「用 NSTextView 的 undo 并让模型旁听」还是「关掉 NSTextView 内建 undo、模型全权接管」，**依赖编辑内核起点，留到 spike**。
- **AI 操作是可撤销的一等公民**：未来 `apply_edit`（`docs/19` §四）落盘/改模型必须走同一 undo 栈；MVP 阶段只需保证「undo 的入口在模型层」这条缝不被堵死。
- **coalescing（合并连续输入为一步 undo）、按段/按词分组**：留到实现。

---

## 6. TextKit 2 内核使用防坑清单（引 `docs/09`）

> 依据 `docs/09` §五对 Marcin Krzyżanowski《TextKit 2 – the promised land》四年实战的总结。**架构好评、实现坑多；社区名言「TextKit 1 是着火的房子，TextKit 2 是岩浆池」。** 以下是使用 `NSTextView`(TextKit 2) 时的红线，**现在就定为工程规范**（实现层怎么绕，随内核 spike 细化）。

### 6.1 硬红线（MUST NOT）

1. **禁触 TextKit 1 API 防静默降级**：**绝不访问 `NSTextView.layoutManager`**（以及任何 TextKit 1 的 `NSLayoutManager` 路径）。一旦访问，视图会**静默降级回 TextKit 1**（`docs/09`：macOS 26 仍有此坑），此后所有 TextKit 2 自定义布局（语法隐藏、行内 widget）全部失效且难排查。所有布局操作只经 `NSTextLayoutManager` / `NSTextContentStorage` / `NSTextLayoutFragment`。**Code review 必查这一条。**
2. **打印 / PDF 导出走 WKWebView，不走 TextKit**：`docs/09` 明确 TextKit 2 打印支持 macOS 15 才有且不稳；PRD §7 定「导出 HTML/PDF 走系统 WebKit/PDFKit」。**编辑区 TextKit 只负责屏上编辑，任何「出稿」（PDF/打印/HTML）一律经 L4 的 WKWebView 子系统**。这也让所见（编辑区样式）与所得（导出）解耦，符合分层。

### 6.2 已知坑与对策（现在标注，细则留到实现）

3. **滚动高度靠估算导致跳动**：TextKit 2 视口化布局，文档总高度是估算的，长文档滚动会跳（`docs/09`）。**必须有对策**（如缓存已布局片段高度、稳定的滚动锚点），**具体方案留到内核 spike**——但「大文档滚动稳定」是验收项，不是可选项。
4. **`NSTextList` 自 macOS 14 起损坏**（`docs/09`）：列表相关渲染不依赖 `NSTextList`，自己控制列表缩进/项目符号绘制。细节留到实现。
5. **参考已趟坑实现**：STTextView（**注意：GPLv3，若我们最终 Apache-2.0 发布不得直接依赖其代码，见 §8**）与 `swift-markdown-engine`（Apache-2.0）的源码是 TextKit 2 避坑百科，**读其思路可，抄其 GPL 代码不可**。

### 6.3 与「玻璃」的边界（PRD §7）

- **编辑区（内容层）保持非玻璃、可读**（Apple 官方指导：玻璃只用于导航/控件层）。TextKit 编辑视图**不加** `glassEffect`。
- Liquid Glass 只作用于 chrome（工具栏/侧栏/控件），且显式玻璃 API（`glassEffect` / `GlassEffectContainer` / `.buttonStyle(.glass)`，均 macOS 26+）一律 `if #available(macOS 26, *)` 门控；macOS 15 自动回退。属 UI 层规范，此处只标边界。

---

## 7. 「AI = 语法树上的操作」的接口边界（seam）

> **这是 MVP 最关键的一条缝**（`docs/19` §3.1 M4）：现在**只划边界、不实现任何 AI**。目标是让未来 Skills/MCP/BYOK「插进来而非拆开重做」。所有 AI 对文档的读写，**必须**通过 L2 暴露的、以 AST/`SourceRange` 为一等公民的操作 API，**永不**做裸文本替换、**永不**绕过 `UndoManager`。

### 7.1 seam 的位置与不变量

- **位置**：L6（AgentBridge）是 L2 的**客户端**，只能调用 L2 的公开操作 API；不得访问 L2 内部字段、L1 View、L4 WebView、L5 文件。
- **不变量（MUST）**：
  1. 所有编辑以**结构坐标**（AST 节点 / `SourceRange`）表达，而非行列裸偏移。
  2. 每个写操作落盘前做 **Markdown 合法性 / AST 等价校验**（`docs/19` §四、§六 6.7：`apply_edit` 走 AST 而非盲覆盖）。
  3. 每个写操作**产出可预览 diff**、**可被 `UndoManager` 撤销**（接 §5）。
  4. 读操作基于**全量 AST 轨**（swift-markdown），不用增量高亮树（接 §4.2）。

### 7.2 一页最小接口草案（现在定形状，签名细节留到实现）

> 这是 `docs/19` §四 MCP 接口草案的**内核内投影**——先在 L2 定义与协议无关的文档操作原语，未来 MCP tool / Skill / BYOK 都是它的适配层。**MVP 不实现，仅占位对齐。**

```swift
// L2 文档模型层暴露的文档操作 seam（草案，签名待 spike 后定）
// 设计原则：结构坐标优先、写操作可校验可预览可撤销、读操作走全量 AST。

// —— 结构坐标 ——
struct DocumentAddress   { let documentID: DocumentID }
struct StructuralRange   { /* AST 节点定位：标题路径 / 列表项 / 代码块 / SourceRange */ }

// —— 读（read-only，对应 docs/19 §四 read 类 & Resources）——
protocol DocumentReader {
    func outline(_ doc: DocumentAddress) -> OutlineTree            // get_outline：AST 大纲
    func metadata(_ doc: DocumentAddress) -> FrontmatterMetadata   // get_note_metadata
    func read(_ range: StructuralRange) -> MarkdownSlice           // read_note(range)
    func resolveSelection(_ sel: Selection) -> StructuralRange     // get_selection 的结构范围
}

// —— 写（需 diff + 校验 + undo，对应 docs/19 §四 apply_edit 等）——
enum StructuralEdit {
    case replace(StructuralRange, MarkdownSource)
    case insert(at: StructuralRange, MarkdownSource)
    case delete(StructuralRange)
    case setFrontmatter(key: String, value: FrontmatterValue)
}
protocol DocumentEditor {
    // 返回可预览 diff；落盘前做合法性/AST 等价校验；整体进 UndoManager 一步
    func apply(_ edits: [StructuralEdit], to doc: DocumentAddress) throws -> EditPreview   // apply_edit
    func replaceSelection(_ src: MarkdownSource, in sel: Selection) throws -> EditPreview   // replace_selection
}

// —— 活动编辑器状态（IDE 范本，笔记 app 空白区，docs/19 §四）——
protocol ActiveEditorState {
    var activeDocument: DocumentAddress? { get }   // editor://active（未来可 subscribe）
    var selection: Selection? { get }              // editor://selection
}
```

### 7.3 未来如何对接（引 `docs/19` §四）

- **V1 · Agent Skills（零 server）**：Skill 是 `.claude/skills/` 下的 Markdown，教外部 Agent 认识我们文库约定（frontmatter schema、wiki 链接、附件落盘规则）。它**不调用**上面的 API，而是通过文件系统操作文库——但文库约定由 L2/L5 定义，二者共用同一份「文件名 → schema → glob」配置表（§2.2）。
- **V2 · 内置 MCP server**：MCP tool（`read_note`/`apply_edit`/`get_active_note`…，`docs/19` §四）是上面 `DocumentReader`/`DocumentEditor`/`ActiveEditorState` 的**协议适配层**——MCP 负责「访问权」，Skill 负责「怎么用」（`docs/19` §四附注）。因为内核早已把操作 AST 化，接 MCP 是「加一个适配 target」而非「改编辑内核」。
- **安全**（`docs/19` §六，留到 V1/V2 实现）：写操作强制人在环确认、作用域最小化、审计日志、checkpoint 回滚——这些是 L6/协议层的事，但 §5（undo 入口在模型层）、§3.5（本地快照）现在就为它们打好底。

---

## 8. 编辑内核起点：留到 M1 spike 决策（本规范只定边界，不定实现）

**现在就定**：本规范只约束**接口、边界、数据安全、内核使用红线**，**不选定编辑内核的实现起点**。

三条候选（PRD §12.4）留到 **M1 spike** 对比后决策：

- **(a) fork / 借鉴 `swift-markdown-engine`**（Apache-2.0，架构与我们完全一致，最快到混合渲染；风险：pre-1.0 API 波动、单点维护）。
- **(b) 从零自研 `NSTextView` + TextKit 2 薄封装**。
- **(c) 先用 `CodeEditTextView`（MIT）做源码模式起步**。

**许可红线（现在就定，`docs/09` §五 / PRD §7）**：我们发布协议 **Apache-2.0**。因此：

- **`STTextView` 已改 GPLv3** → **不得直接依赖/内嵌其代码**（读思路可）。
- **`Down` / `Ink` / `SwiftDown` 均停更** → 不引入。
- 候选内核里 `swift-markdown-engine`（Apache-2.0）、`CodeEditTextView`（MIT）许可兼容；选 (a) 建议 fork 锁版本并向上游回馈（`docs/09` §八）。

**无论选哪条，都必须满足本文 §1–§7**：分层与依赖方向、文件夹即文库、byte-exact + 原子写入 + 外部变更协调、双轨解析、undo 入口在模型层、TextKit 2 防坑红线、AST-as-API 的 seam。**内核起点是可替换的实现；这些边界是不可替换的契约。**

---

## 9. 留到实现时再定（M1 spike 后再细化）

以下项**依赖「编辑内核起点」等未决决策或属实现细节**，本规范**刻意不硬写**，避免过早锁死。进入 M1 时在 `planning/M1/` 内定，并回填本文：

1. **编辑内核起点** (a)/(b)/(c) 的最终选择（M1 spike 对比 a 与 c，PRD §12.4）——§8。
2. **TextKit 2 实现细则**：语法隐藏 / 光标处还原的状态机、自定义 `NSTextLayoutFragment`、滚动高度估算稳定方案、列表绘制（不依赖 `NSTextList`）——§6.2。**这些是「岩浆池」的核心，必须 spike 验证后才写细则。**
3. **M1 是否引入 tree-sitter**，还是先用解析驱动的属性映射做「源码样式化」顶着（混合渲染是 M2）——§4.2。
4. **解析节流阈值与增量失效算法**（全量 AST 防抖窗口、Neon 式失效区间计算参数）——§4.2。
5. **原子写入的具体 API 选型**（`Data.write(.atomic)` vs `NSFileCoordinator` 协调写 vs 自定义 temp+rename）与 xattr/权限保留细节——§3.1。
6. **FSEvents 自触发去重的具体机制**（mtime+size vs 内容 hash vs 写入标记）——§3.3。
7. **iCloud 冲突副本的主动 UI**（MVP 只做到「不加剧 + 可识别」，主动合并/选择 UI 属 V1）——§3.4。
8. **版本历史实现**：本地快照目录 vs 内置 Git（FSNotes 用 Git）——§3.5。
9. **`UndoManager` 与 `NSTextView` 内建 undo 的整合方式**（旁听 vs 接管），依赖内核起点——§5。
10. **§7.2 接口的最终签名**（类型、错误模型、diff 表示、结构坐标编码）——MVP 只占位对齐，V1/V2 随 Skills/MCP 落地时定。
11. **Swift package / target 的具体划分**（按层强制依赖方向），M0 工程搭建时定——§1.3。
12. **懒加载 / 搜索索引的具体策略**（支撑「10k+ 文件流畅」）——§2.3。

> 原则复述：**本文定「不可替换的契约」（边界、数据安全、内核红线、AST-as-API 缝）；上表定「可替换的实现」，留到掌握更多信息时再定，避免过早锁死。**
