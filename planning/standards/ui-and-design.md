# UI 与设计开发规范

> **用途**：本文是 Colophon 的界面与设计「规则文件」——规定用什么技术栈画界面、遵守哪些 macOS 原生约定、Liquid Glass 怎么用、设计语言与主题如何落地、无障碍底线是什么、布局与交互怎么组织。目标是让任何贡献者（含 AI 编码助手）在动 UI 代码前，就知道**哪些是现在已定的硬约束、哪些留到实现时再细化**，避免各写各的、避免踩已知坑。
>
> **语言约定**：本规范当前用中文便于团队理解；未来搬进真实仓库作 `AGENTS.md` / `.claude/rules/*.md` 时再译成英文。文中所有代码、API、术语、文件名、快捷键一律用英文。
>
> **上位文档**：[PRD.md](../PRD.md)（尤其 §3 设计原则、§7 技术架构与 Liquid Glass）、[ROADMAP.md](../ROADMAP.md)。凡本文与它们冲突，以 PRD/ROADMAP 为准。设计手法的调研依据主要来自 [`docs/12`](../../docs/12-ui-design-patterns.md)，技术坑来自 [`docs/09`](../../docs/09-tech-stack.md)、[`docs/03`](../../docs/03-windows-legacy.md)、[`docs/18`](../../docs/18-agent-editor-competitors.md)。

---

## 0. 三条不可违背的设计红线（先记住这三条）

1. **编辑区（正文内容层）永远非玻璃、可读。** Liquid Glass / 系统材质只用于导航与控件层（chrome），绝不套在正文上（PRD §7，Apple 官方指导）。
2. **优先系统标准组件，少自绘 chrome。** 用标准 SwiftUI/AppKit 组件 → macOS 26 自动获得 Liquid Glass、macOS 15 自动回退经典外观，零分支、零维护（PRD §3.6、ROADMAP §6）。这是相对 Electron 竞品的结构性护城河，别用自绘控件把它丢掉。
3. **克制即差异化。** 界面隐身、正文即界面。每加一个可见 UI 元素先问「iA Writer / MarkEdit 会不会加它」；宁可无工具栏 + 命令面板，也不要图标堆砌（来源：docs/12 §五-E、docs/03）。

---

## 1. 技术栈边界与桥接约定（现在就定）

### 1.1 谁负责画什么

| 层 | 技术 | 职责范围 |
|---|---|---|
| **App 壳 / chrome** | SwiftUI | 窗口、`NavigationSplitView` 三栏、侧栏（文件树/文件列表）、工具栏、设置窗口、命令面板、菜单、状态栏、对话框、AI 侧栏（未来） |
| **编辑区（内容层）** | AppKit `NSTextView`(TextKit 2)，经 `NSViewRepresentable` 薄封装 | 文本输入、光标、选区、样式化渲染、语法着色、（M2）行内混合渲染 |
| **预览 / 导出 / 图表** | `WKWebView` 子系统 | 分屏预览、HTML/PDF 导出、Mermaid、KaTeX/MathJax（仅限这些用途） |

**边界纪律：**
- chrome 一律 SwiftUI + 标准组件；**不要**为了「统一手感」把工具栏/侧栏改成自绘 AppKit。
- **编辑体验相关的一切**（光标、选区、样式、IME、拼写、Writing Tools）都在 `NSTextView` 侧实现，不要试图用 SwiftUI `TextEditor` 替代——它的天花板做不到语法隐藏/行内 widget，迟早返工（PRD §12.4、ROADMAP §2、docs/09 方案 C）。
- `WKWebView` **只做预览/导出/图表**，绝不承担编辑职责（docs/09 §五、§八）。

### 1.2 `NSViewRepresentable` 桥接约定

M0 就要把「SwiftUI 壳 + NSTextView 桥接骨架」搭对，避免后期返工（ROADMAP §2）。约定：

- 用一个 `NSViewRepresentable`（建议命名 `MarkdownTextView`）封装 `NSScrollView` + `NSTextView`；**不要**把 `NSTextView` 直接暴露给 SwiftUI 视图树。
- **状态流向单一**：SwiftUI → AppKit 走 `updateNSView`；AppKit → SwiftUI 的回调（文本变更、选区变更、滚动位置）统一走 `Coordinator`（实现 `NSTextViewDelegate`），不要在 SwiftUI 视图里直接持有 `NSTextView` 引用去调它。
- **防重入**：`updateNSView` 里写回文本前必须比较是否真的变化，避免「SwiftUI 更新 → 触发 delegate → 又更新 SwiftUI」的死循环 / 光标跳动。文档模型的唯一真相源是数据层（`.md` 字节），不是 view。
- **值语义解析**：语义/高亮由 `swift-markdown`（不可变值类型 AST + 精确 `SourceRange`）驱动，解析结果映射为文本属性；不要在 view 里手写正则做结构解析（docs/09 §四 swift-markdown）。

### 1.3 编辑区文本引擎的硬约束（TextKit 2 防坑，来源：docs/09 §五、小结）

这些是「岩浆池」实测坑，直接作为编码规则：

- **禁止触碰 `NSTextView.layoutManager`（TextKit 1 API）**——一旦访问会静默降级回 TextKit 1（macOS 26 仍有此坑）。所有布局操作走 `NSTextLayoutManager` / `NSTextContentStorage`。
- **滚动/文档总高度靠估算会跳动**：长文档滚动条与跳转要有对策（缓存高度、避免频繁全量重排），列为已知风险，M1 spike 验证。
- **打印 / PDF 导出走 `WKWebView` + PDFKit，不走 TextKit**（TextKit 2 打印支持到 macOS 15 才有且不稳）。
- **关闭一切「智能替换」**：`isAutomaticQuoteSubstitutionEnabled` / `isAutomaticDashSubstitutionEnabled` / `isAutomaticTextReplacementEnabled` 等一律默认 **关闭**——智能引号/破折号会破坏 frontmatter 与代码 fence，Agent 配置文件对字节保真极敏感（PRD §5.1、docs/18 MacMD 的 byte-exact 教训）。这既是文件正确性要求，也是编辑区初始化的硬配置。
- **代码块高亮**用 Highlightr 起步；正文语法高亮由解析器驱动，不要用 Highlightr 去高亮正文（docs/09 §六）。

### 1.4 `WKWebView` 预览子系统约定（来源：docs/09 §五）

- 每个 `WKWebView` 进程约数十 MB 内存 + 首次加载延迟——**预览按需创建/复用**，不常驻多个。
- 沙盒下本地资源（图片、离线 KaTeX/Mermaid bundle）访问需正确配 entitlement；Mermaid/KaTeX **离线打包**，不联网 CDN。
- **不引入无头 Chrome 做导出**（docs/09 §七、docs/12 §五 反例）；复杂格式后续接 Pandoc。
- 分屏滚动同步是分屏模式的体验底线，**同步滚动坏了是口碑黑洞**（Remarkable 同步滚动坏多年成反例，docs/03、docs/12 §一-2）：⌘\ 分屏必须 60fps 双向同步（MiaoYan 基准）。

---

## 2. HIG 与系统原生（现在就定）

对标 **MarkEdit**——它是「完全贴合 macOS 规范」的现成标尺（docs/12 §五-D、docs/01 MarkEdit 条）。规则：

- **优先标准组件**：`NSToolbar` / SwiftUI `.toolbar`、标准设置窗口（Settings scene）、完整菜单栏、系统右键菜单、系统拼写检查、系统查找面板。凡系统有的，不自造。
- **SF Symbols 唯一图标来源**：工具栏、命令面板、状态栏、侧栏图标一律用 SF Symbols，随系统字重与深浅色自适应；**禁止**自绘位图图标（会造成「非原生感」，正是 Electron 竞品做不到的细节——docs/12 §五-D）。
- **语义色，不硬编码色值**：用 `NSColor` / `Color` 的语义色（`.labelColor`、`.secondaryLabelColor`、`.controlAccentColor`、`.separatorColor`、`.textBackgroundColor` 等）。禁止在 chrome 里写死 hex 颜色（正文主题 token 例外，见 §5）。
- **自动深浅色**：跟随系统 appearance，深浅两态都是一等公民，都要经得起逐像素检查（docs/12 §三、§六-3）。禁止只做一套配色再「反色」凑另一套。
- **系统材质**：侧栏、浮层用系统材质（如 `.sidebar`、`NSVisualEffectView` 材质 / SwiftUI `.background(.regularMaterial)` 等），随深浅色自动过渡（docs/12 §五-D-19）。
- **系统集成（高感知低成本，按 docs/12 §五 清单）**：Writing Tools（需 TextKit 2）、系统拼写、QuickLook（让 Finder 预览 `.md`）、Spotlight 索引正文（OpenMark 的 importer 范式，docs/18）——这些做进原生集成，强化「原生」卖点。
- **性能即观感**：启动近即时、打字零延迟、大文件流畅滚动（Bear 55ms、MarkEdit 百万行基准）是显性卖点，也是 UI 验收项——「慢是最大的丑」（docs/12 §五-C-17）。

---

## 3. Liquid Glass 策略（现在就定框架，具体元素留到实现）

**总方针（PRD §7）**：用最新 Xcode（macOS 26 SDK）编译、最低目标 macOS 15；chrome 全用标准组件 → macOS 26 自动玻璃、macOS 15 自动回退，**零分支**。

### 3.1 三条执行规则

1. **默认路径 = 标准组件自动适配。** 优先靠标准 SwiftUI/AppKit 组件在 macOS 26 上「免费」拿到 Liquid Glass，macOS 15 上自动回退经典外观——不写任何版本分支代码。这是首选，也是绝大多数 chrome 的做法。
2. **显式玻璃 API 必须 availability 门控。** 一旦要用显式玻璃 API（`glassEffect` / `GlassEffectContainer` / `.buttonStyle(.glass)`，均 `macOS 26+`），**必须** `if #available(macOS 26, *)` 包裹，并提供 macOS 15 的回退分支。禁止无门控直接调用（会在 macOS 15 编译期/运行期出问题）。
3. **编辑区不套玻璃。** 见红线 1——正文内容层保持非玻璃、可读。玻璃只用于导航/控件层。

### 3.2 过渡逃生舱（临时，不作长期方案）

- 可选 `UIDesignRequiresCompatibility` 作为临时过渡（让 app 暂不启用新设计语言），**但它是临时手段、Xcode 27 起失效**，不写进长期架构，只在过渡期短用（PRD §7）。

### 3.3 测试约束

- **玻璃效果必须在 macOS 26 真机/真环境测试**——macOS 无模拟器，玻璃观感与回退行为都要在真实 macOS 26 上验证（PRD §7）。CI 与本地至少各有一台可跑 macOS 26 的机器。
- 同时在 macOS 15 上验证「回退经典外观」正确、不残留半截玻璃。

### 3.4 与无障碍联动（见 §6）

- 系统开启 **Reduce Transparency** 时，标准材质会自动降级为不透明；**用到显式玻璃/自定义材质的地方，必须自己检查并降级**（`NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency`），保证文字可读、对比达标（docs/12 §六-5 强调玻璃需配合 Reduce Transparency）。

---

## 4. 设计语言：极简 / 克制（现在就定原则，数值与字体留到 mockup）

定位句（docs/12 §六）：**iA Writer 的排版克制 + Typora 的实时渲染留白 + Bear 的语法隐藏颗粒度 + Paper 的动效手感 + MarkEdit 的系统感**。对标天花板：**iA Writer**（排版即界面）、**Apostrophe**（零面板极简）。

### 4.1 界面减法（现在就定）

- **首屏 = 单栏纸面**：默认打开即极简单栏编辑区，侧栏可一键收起；管理态（三栏）与写作态（单栏）一键互换（docs/12 §六-1，对标 iA Writer / Ulysses / MiaoYan）。
- **无常驻工具栏堆砌**：格式操作交给快捷键 + 选中浮层（选中文本才出现，学 MarkPad / Notion），不做 Editor.md 式图标墙（docs/12 §五-E-20，反例明确）。
- **不做**：常驻多面板、IDE 式多页签起步、常驻 AI 按钮——这些会把编辑器拖成 IDE（docs/12 §六-1、docs/18 簇 C 教训）。
- **能力藏在悬停/命令面板里**，界面保持灰白极简（Notion 范式）。

### 4.2 正文排版质感（现在就定原则）

- **正文与界面分治**：界面层用系统字体（SF Pro 体系）+ 系统控件；正文层做写作专属排版（限制版心行宽、调校行高、标题字号分级）——「同一编辑器，写作模式换一套视觉」（docs/12 §二、§六-2，Sublime MarkdownEditing 理念）。
- **标题层级必须视觉可辨**：用字号分级（Typora/Apostrophe 式源码内联美化：标题变大、粗体变粗、语法符号保留但淡化），可选色阶。**反例守则**：Zed 预览 h1/h2/h3 字号几乎一样、层级不可见——绝不能这样（docs/12 §二、§五-B-9）。
- **语法标记淡化而非删除**：着色淡化保留标记符（iA Writer/Byword 路线）；M2 上混合渲染时遵循 anti-conceal（只还原光标行，其余保持渲染态），避免「光标一动渲染就消失」的心流打断（docs/12 §四 反面证据、§六-4）。
- **行宽（版心）限制 + 留白**是「纸面感」关键（Apostrophe 合适行宽、Moeditor/Lex 大留白）。
- **默认值即成品**：用户不调任何设置也好看（Craft/UpNote 范式，docs/12 §二、§五-B-12）。

### 4.3 默认字体方向（现在定「方向」，不定具体字体）

- **提供极少档位而非字体列表**：正文 / 衬线（serif）/ 等宽（mono）三档全局切换（Notion 式，docs/12 §六-2），进阶排版参数（行宽/行距/字距）放进设置深处（Paper 模式：可调但不显眼）。
- **默认字体、行高、版心宽度出厂即成品**（Craft/UpNote 基准）。
- 具体选哪款字体、默认到底是等宽还是衬线，**留到实现时再定**（依赖 mockup 定调，PRD §12.7；且 iA Writer 的 Mono/Duo/Quattro 已开源可评估，但先把默认排版参数打磨到 iA 级再谈自研字体——docs/12 §六-2）。

### 4.4 一个品牌色锚点（现在就定策略，色值待定）

- **用光标色或强调色做唯一品牌记忆点**，界面其余保持系统中性色（iA 蓝光标 / Caret 金光标 / Bear 红——docs/12 §五-C-13、§六-2）。
- 强调色**具体色值留到视觉定调**（mockup 阶段），但架构上要 token 化（见 §5），一处改全局生效。

### 4.5 动效与手感

- 打字机滚动、光标/滚动动画按 Byword/Paper 标准打磨——差距在动画曲线而非功能有无（docs/12 §四、§六-4）。克制、不炫技。

---

## 5. 主题：MVP 两套精调 + token 化（现在就定结构，主题文件格式留到 V1）

依据 PRD §5.1（深浅色各一套精调）、ROADMAP §3.3、docs/12 §六-3。

### 5.1 MVP 范围（现在就定）

- **内置少而精**：MVP 做**深 / 浅两套精调主题**，默认跟随系统外观自动切换。深浅两态都是一等公民，都逐像素调过（docs/12 §六-3 反例守则：不追数量，MWeb 32 款没换来精致口碑）。
- （纸感 / sepia 第三套是 Apostrophe 式低成本情绪化设计，可作为早期候选，但不强求进 MVP——见「留到实现时再定」。）

### 5.2 token 化（现在就定，为「主题即文件」留结构）

即使 MVP 只有两套主题，**颜色与间距也必须 token 化**，不散落 hex：

- 定义一套**设计令牌（design tokens）**：颜色（正文/标题各级/强调/背景/选区/代码块背景等）、间距、行高、版心宽度、字号阶梯。chrome 用系统语义色（§2），**正文层用 token**。
- 令牌集中定义、单点可改；主题 = 一组 token 取值。为未来 V1「**主题即一个样式文件 + 官方主题画廊**」（PRD §5.2）留好结构：编辑区主题走数据化描述（NotePlan 的 JSON 定义 / Glow 的「主题=可分发文件」两个先例），预览/导出主题走 CSS（Typora 范式），**两层共享同一套设计令牌**保证编辑与预览观感一致（docs/12 §六-3）。
- **开源免费，主题不设付费墙**（与 Bear 的 Pro 主题做法相反，符合我们定位——docs/12 §六-3）。

### 5.3 留到 V1/实现时

- token 的**具体命名、schema、主题文件格式（JSON/CSS 的确切结构）**留到 V1「主题即文件」时定，现在只保证「有一层 token、不写死 hex」。

---

## 6. 无障碍（硬要求，现在就定）

无障碍是硬性验收项，不是「以后再补」。清单：

- **VoiceOver 全可达**：所有 chrome 控件有正确的 accessibility label/role/value；`NSTextView` 编辑区支持 VoiceOver 朗读与导航（标准文本视图默认支持，自绘/混合渲染时要显式维护无障碍元素）。侧栏、命令面板、浮层都要能被 VoiceOver 走通。
- **键盘全可达**：所有功能都有键盘路径，不存在「只能用鼠标」的操作；焦点顺序合理、焦点环可见；命令面板（⇧⌘P）本身就是键盘可达性的兜底入口。
- **字号 / 可达性文字**：macOS 无 iOS 式 Dynamic Type，正文字号可达性由 **app 自有「正文字号」设置**承担（§4.3 的排版参数）；界面控件用系统字体，尽量尊重系统「辅助功能 > 显示 > 文字大小」。禁止把正文字号写死到不可调。
- **Reduce Transparency（针对玻璃）**：见 §3.4——开启时显式玻璃/自定义材质必须降级为不透明，保证可读（docs/12 §六-5）。
- **对比度**：正文与背景、chrome 文字与材质都要满足 WCAG AA 对比度；深浅两态、玻璃态下都要达标。强调色（品牌色）不能是唯一的信息载体（色盲友好）。
- **Reduce Motion**：尊重系统「减弱动态效果」，动效（打字机滚动、过渡）在开启时降级为无/最小动画。

> 验收基线对标 MarkEdit 的「零学习成本、系统感」（docs/12 §五-D、docs/01）。凡新增 UI，PR 自检：VoiceOver 走一遍 + 全键盘走一遍 + Reduce Transparency/Reduce Motion 各开一次看是否降级正确。

---

## 7. 布局与窗口、交互规范（现在就定）

### 7.1 三栏 `NavigationSplitView`（现在就定）

- 结构：**侧栏（文件夹树 / 文库）→ 文件列表 → 编辑区**（三栏，PRD §7、ROADMAP §2）。
- **可逐级折叠到单栏**：三栏是「管理态」，单栏是「写作态」，两态一键切换（docs/12 §一-3、§六-1，对标 Ulysses/MiaoYan）。
- **状态恢复**：窗口大小/位置、栏宽、折叠状态、当前打开的文件/文库，用系统状态恢复机制持久化并在重启后恢复。
- 反例守则：不做 QOwnNotes/VNote 式多面板高密度 IDE 化布局（docs/12 §一-3、§五-E-21）。

### 7.2 入口双件套（现在就定形态，具体命令清单留到实现）

- **omnibar「搜索即新建」**：一个输入框同时完成搜索/新建（搜不到即回车新建），大纲合入搜索框、不做常驻面板（FSNotes/nvUltra 已验证的最高效入口 + iA Writer 8 范式，docs/12 §一-3、§六-1）。
- **命令面板 ⇧⌘P**：低 UI 成本聚合功能、维持极简（iA Writer 8 范式，PRD §5.1、docs/12 §六-1）。具体命令项清单留到实现时随功能增补。

### 7.3 快捷键体系（现在就定原则与已定键位）

- **已定键位**：`⇧⌘P` 命令面板、`⌘\` 分屏预览切换、Markdown 语义键 `⌘B`/`⌘I`/标题升降/勾选任务（PRD §5.1）。
- **原则**：遵循 macOS 惯例键位，不覆盖系统标准快捷键；所有命令面板项应显示其快捷键；快捷键与菜单项一一对应（菜单是快捷键的可发现性入口）。
- 完整快捷键映射表留到实现时随功能定稿（见「留到实现时再定」）。

### 7.4 右键菜单（现在就定）

- 用**系统右键菜单**（`NSMenu` / SwiftUI `.contextMenu`），不自造浮层菜单；编辑区右键继承系统文本菜单（拼写、Writing Tools、查找等）再按需增补 Markdown 操作（docs/12 §五-D）。

### 7.5 拖拽（现在就定形态）

- **图片粘贴/拖拽自动落盘**（目录规则可配）+ 选中粘贴 URL 自动成链接（PRD §5.1）。
- 侧栏文件树支持标准拖拽移动/组织；拖拽反馈用系统标准高亮。
- 拖拽落盘的**目录规则、命名规则**属实现细节，留到实现时定。

### 7.6 分屏预览（现在就定）

- `⌘\` 一键切换，**按需模式**而非常驻双栏；60fps 双向滚动同步（docs/12 §一-2、§六-1）。编辑区主形态是单栏，分屏只服务对照与导出预览。

---

## 8. 交给 AI 编码助手时的自检清单（dogfood 路线 B）

改动任何 UI 前，逐条核对：

- [ ] 这个元素是 chrome 还是内容层？内容层**不套玻璃**（红线 1）。
- [ ] 有没有用标准组件？能用系统组件就不自绘（红线 2、§2）。
- [ ] 图标是 SF Symbols 吗？颜色是语义色/token 吗？（§2、§5）
- [ ] 显式玻璃 API 有没有 `if #available(macOS 26, *)` 门控 + macOS 15 回退？（§3）
- [ ] 触碰 `NSTextView` 时有没有误用 `.layoutManager`（会降级 TextKit 1）？智能引号/破折号是否已关闭？（§1.3）
- [ ] VoiceOver / 全键盘 / Reduce Transparency / Reduce Motion 四项过了吗？（§6）
- [ ] 深浅两态都逐像素看过吗？（§2、§5）
- [ ] 加的这个东西，iA Writer / MarkEdit 会不会加它？（克制，红线 3）

---

## 9. 留到实现时再定（M1 spike / mockup 后细化）

以下依赖尚未拍板的决策，**现在不硬写死实现细节**：

1. **默认正文字体的具体选择与默认方向**（等宽 vs 衬线 vs sans 谁做默认）——依赖 mockup 定调（PRD §12.7）；是否采用/评估 iA Writer 开源字体（Mono/Duo/Quattro）也留到那时。
2. **精确排版数值**：版心行宽、行高、字号阶梯、间距 token 的具体取值——等 1–2 张界面 mockup 定调后再落数（PRD §12.7、docs/12 §六-2）。
3. **品牌强调色 / 光标色的具体色值**——等视觉定调；现在只保证 token 化、可一处改。
4. **编辑区样式化的实现细节**：取决于编辑内核起点的 spike 结论（fork `swift-markdown-engine` vs 从零 `NSTextView`+TextKit 2 vs `CodeEditTextView`，PRD §12.4、ROADMAP §3.6）；语法隐藏/淡化的具体属性变换方式随之定。
5. **M2 混合渲染的视觉状态机**：anti-conceal 三态（源码/实时/阅读）切换的具体视觉与交互（M2 才做，docs/12 §四、§六-4）。
6. **主题文件格式与 token schema**：编辑区 JSON 主题描述、预览 CSS 主题的确切结构、两层共享令牌的映射——留到 V1「主题即文件」（PRD §5.2、§5.3）。现在只定「有 token 层、不写死 hex」。
7. **纸感 / sepia 第三套主题是否进 MVP**——现在先保证深浅两套精调，第三套按精力决定（docs/12 §六-3）。
8. **玻璃具体用在哪些 chrome 元素上**、回退观感细节——需在 macOS 26 真机测试后逐个确认（§3.3）。
9. **完整快捷键映射表 + 命令面板命令全清单 + 右键菜单增补项**——随功能定稿逐步补齐（§7.2、§7.3）。
10. **拖拽落盘的目录/命名规则、omnibar 的具体搜索/新建行为细节**——实现时定（§7.5、§7.2）。
11. **专注模式粒度（行/句/段）、打字机居中的具体参数**——形态已定（对标 ghostwriter 可配粒度、Typora 当前行居中，docs/12 §四），数值留到实现（PRD §5.1）。

> 说明：以上「留到实现时再定」项，进入对应里程碑（M1/M2/V1）时，按 [planning/README.md](../README.md) 流程固化进 `Mx/plan.md` 与 `Mx/decisions.md`。
