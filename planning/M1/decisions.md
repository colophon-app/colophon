# M1 · 决策记录（decisions, ADR-lite）

> 本文记录 M1 阶段的跨维度决策及理由（随做随记）。依据是同目录 [`research.md`](./research.md)（13 维调研 + 5 项对抗性验证 + 内核 spike 合成 + 完备性批判）。
> 标「已定」的现在生效；标「方向已锁 · spike 亲验」的先按此方向走，由 M1.0/M1.0.5 的 hands-on spike 落锤终态并回填。欢迎 Evan 事后推翻——但推翻要在本文写明理由。
> **不可变契约**（来自 [architecture.md](../standards/architecture.md) §1–§7，本milestone任何决策都不得违反）：源码字符串为唯一真相、AST 派生；byte-exact + 原子写 + 外部变更协调；双轨解析；**undo 入口在 L2 模型层**；**禁触 `NSTextView.layoutManager`**；导出走 WKWebView/PDFKit；编辑区非玻璃。

---

## D-M1-1 · 编辑内核起点 = (b) 长出 M0 内核；swift-markdown-engine 降为 M2 上游；淘汰 CodeEditTextView

- **背景**：PRD §12.4 / architecture §8 的龙头 spike（(a) fork swift-markdown-engine / (b) 从零 TextKit 2 薄封装 / (c) CodeEditTextView）。这条 gate 住 architecture §9 的大半实现细则。
- **决定**：M1 内核 = **(b)**——在 M0 已交付的 [`MarkdownTextView.swift`](../../Colophon/Colophon/MarkdownTextView.swift) 上，加「swift-markdown 全量 AST → NSRange 属性映射」的源码样式化 + WKWebView 分屏预览。**swift-markdown-engine（Apache-2.0）不作 M1 内核，改当 M2 混合渲染的上游**（同 TextKit 2 底座，M2 是平移不是重写）。**CodeEditTextView 淘汰**。
- **理由**：① M1 只要源码样式化（不要混合渲染，那是 M2）——这不过是标准 TextKit 2 属性映射，进不了「岩浆池」，而 M0 骨架已合规就绪。② 现在 fork (a) 会把它「解析器统一管几何 + 标记隐藏 + **自带 per-document undo/编辑状态**」的强意见栈塞进来，**与我们「源码唯一真相 / AST 派生 / undo 入口在 L2」的契约直接冲突**——对抗性验证抓出单维度调研原本推 (a) 却与 model 层 undo 自相矛盾（因 swift-markdown-engine 自己持有编辑状态和 undo）；且它 pre-1.0、单人、AI 代写，是 ROADMAP 明列的「依赖内核死亡」单点风险，**为 M1 零收益**。③ (c) 非 TextKit、自绘布局、为代码而非散文——选它 = M2 撕掉重来（docs/09 的方案 C 陷阱）。
- **注意**：无论如何，byte-exact 往返必须穿过样式层存活；绝不读 `.layoutManager`（审 (a) 源码时也查）；SourceRange(UTF-8) ↔ NSRange(UTF-16) 映射对 CJK/emoji 必须有测试。
- **M1.0 spike 实测结论（2026-07-22，(b) 通过 → 确认）**：在现有 [`MarkdownTextView.swift`](../../Colophon/Colophon/MarkdownTextView.swift) 上做 swift-markdown 全量 AST → NSRange 属性映射。实测：样式正确；**CJK/emoji byte-exact 正确（`MarkdownStylingTests` 单测 + 肉眼双验，粗体/斜体/代码精确落在中文上）**；**大文档滚动稳定**（1.1MB 合成文件丝滑不跳——spike 的硬门通过）；真实文件（<20k，同步上样式）**即时零闪丝滑**。**内核 = 长出 M0，落锤。**
  - **实测逼出的两条优化**（换 (a)/(c) 也救不了、不改变本决策）：① 超大单文件（1MB+）打字/删除慢的**主因是 M0 桥每键把整篇源码字符串过一遍 SwiftUI `@Binding`**（O(n)/键的拷贝+比较+状态传播）→ 需 **L2 `DocumentModel` 让 `NSTextStorage` 自持真相源**（architecture §2.2，**M1.1**）；② 样式那步是**整篇 `addAttributes`** → 需**惰性 `NSTextContentStorageDelegate`** 按需只给可视段落上样式（见 [D-M1-4](#d-m1-4--前景着色机制单一化源码样式化--专注变暗--rubric-高亮共用一个m105-spike-定选)，**M1.0.5a**）。tree-sitter 增量高亮仍是 **M2**。
  - **未走兜底**：(b) 达标，无需平移 (a)。(c) 在大文件编辑上虽快，但 box out M2 且上面两条优化对任何内核都通用、不足以触发切换判据。
- **状态**：**已通过（M1.0，2026-07-22）**。spike 分支即 M1 内核种子。undo 整合（[D-M1-3](#d-m1-3--undo-归属--l2-模型层拥有入口内建-undo-的整合方式由-m10-spike-落锤)）留 Day-2 验；tree-sitter 不引（[D-M1-2](#d-m1-2--m1-不引-tree-sittertextkit-2-源码样式化--swift-markdown-全量-ast-属性映射防抖)）确认。

## D-M1-2 · M1 不引 tree-sitter；源码样式化 = swift-markdown 全量 AST 属性映射（防抖）

- **决定**：M1 的「源码样式化」用 **swift-markdown 全量 AST + 防抖后台重解析**驱动属性映射，**不引** tree-sitter / SwiftTreeSitter / Neon。
- **理由**：swift-markdown 已是既定依赖（Apache-2.0、官方、线程安全值类型、精确 SourceRange、cmark-gfm 参考方言）；M1 样式化是粗粒度（块级 + 行内强调 + 标记弱化），SourceRange 便宜够用；tree-sitter-markdown 官方自陈「不建议用于正确性要紧处」，且 Neon 作者承认 TextKit 2 无闪烁高亮「尚未找到办法、可能需新 API」，在我们锁定的栈上收益最小。tree-sitter+Neon（均 BSD-3，兼容）**留到 M2** 做代码块 language injection + 混合渲染，那才是它增量/多语言强项真正兑现处。（回填 architecture §4.2 / §9 #3。）
- **状态**：已定（M2 重评）。

## D-M1-3 · undo 归属 = L2 模型层拥有入口；内建 undo 的整合方式由 M1.0 spike 落锤

- **背景**：完备性批判指出 undo 模型在 findings 5/6/9 反复以「open decision」出现却无人拍板，而语义快捷键、列表续行、图片粘贴、静默重载、自动保存**全都依赖它**——不定死会到处冒双重撤销 bug。
- **决定**：**undo 入口在 L2（不可变契约）**；所有编辑意图收口到一个模型层原语（草案名 `applyTextEdit(range:replacement:newSelection:)`），由它统一注册单步 undo（含反向编辑）、`breakUndoCoalescing()` 隔离命令、再经 `shouldChangeText → replaceCharacters → didChangeText` 推给 NSTextView。**具体是「NSTextView 内建 undo + 模型旁听」还是「关掉内建、模型全权接管」——作为 M1.0 spike 的一等输出落锤**（依赖内核起点）。
- **理由**：未来 AI 层（L6）经 AST API 改文档也必须走同一 undo 栈，否则路线 B 的 checkpoint 回滚与普通 undo 割裂。
- **M1.0 结论（2026-07-22）**：选 (b)（自有裸 `NSTextView`）后，undo 控制权**完全在我们手里**——不像 (a) 自带 per-document undo 抢控制权。故 architecture §5「undo 入口在 L2」**可达、无内核阻碍**。整合方式（保留 NSTextView 内建 undo + 模型旁听 vs 关掉内建、模型全权接管）是**小实现细节，随 M1.1 建 L2 `DocumentModel` + M1.3 建编辑原语 `applyTextEdit` 时定**，不构成风险，故不在 spike 写 throwaway 代码验证。
- **状态**：入口在 L2 已定（契约）· 无内核阻碍已确认（M1.0）· 整合方式随 **M1.1/M1.3** 落地。

## D-M1-4 · 前景着色机制单一化（源码样式化 / 专注变暗 / rubric 高亮共用一个），M1.0.5 spike 定选

- **背景**：批判抓出矛盾——finding 2 说「**绝不**用 `NSTextLayoutManager` rendering attributes（FB9692714：macOS 26 重绘不可靠，Apple DTS 证实），改用 `NSTextContentStorageDelegate` 显示属性」；finding 8 却把 rendering attributes 当专注变暗的**主**机制；finding 10 也依赖它做光标行 rubric 高亮。三者不可能同时对，且各建一套 = 同一原语三份互不兼容的实现。
- **决定**：**三处（D2 源码样式化、D8 专注变暗、D10 rubric 光标行）共用同一个前景着色机制**。默认候选 = `NSTextContentStorageDelegate.textContentStorage(_:textParagraphWith:)` 返回带显示属性的 `NSTextParagraph` + `invalidateLayout(for:)` 刷新（不改源码字节、byte-safe、无 storage 抖动）；**不以 `NSTextLayoutManager.addRenderingAttribute` 为主**。兜底 = 当前行逐 run 上色（由 SourceRange 驱动，仅光标行）/ 半透明 scrim overlay。
- **注意**：验证 agent 提醒——「`invalidateLayout(for:)` 会重新触发 delegate」这条是**社区**报告（FossilCoder，非 Apple DTS 确认），是整个动态刷新的命门，**M1.0.5 spike 第一关就要在 macOS 15/26 亲证**；不成立则退兜底。另需一个把 marker 位置从 AST 节点边界重建的 helper（swift-markdown 不给单个定界符的 SourceRange）。
- **M1.0 实测新证**：M1.0 用的「整篇直接 `addAttributes`」在真实文件上零闪流畅，但在 1MB+ 单文件上是整篇上属性的性能悬崖（见 [D-M1-1](#d-m1-1--编辑内核起点--b-长出-m0-内核swift-markdown-engine-降为-m2-上游淘汰-codeedittextview) spike 结论）。这给「惰性 `NSTextContentStorageDelegate` 按需只给可视段落上样式」加了**实测动机**——M1.0.5a 优先验它能否既可靠重绘、又天然视口化（省掉 M1.0 里那个害滚动的独立 scroll 重上色）。
- **M1.0.5a 落锤（2026-07-22，机制验证完成）**：**着色机制 = `NSTextContentStorageDelegate`**（`textContentStorage(_:textParagraphWith:)` 按需 vend 带样式的 `NSTextParagraph`；TextKit 2 懒布局 → **天然视口化,大文件不付整篇上属性代价**,同时治好 M1.0 那个性能悬崖）**+ 逐段落兜底**（全量 runs 陈旧时就地解析本段落 → 标题/行内即时正确、初始与编辑都不失样式）**+ `edited(.editedCharacters, changeInLength:0)` 重 vend（带选区保存/恢复防光标跳）**。三处（源码样式化/专注/rubric）共用这一套。
  - **实测排除的坑**：① `invalidateLayout(for:)` **不**触发 delegate 重 vend（D-M1-4 那条社区传言,证伪）;② `edited(.editedCharacters,0)` 能重 vend 但会挪插入点 → **保存/恢复 `selectedRanges`** 压掉。
  - **已知边缘限制**：**1MB+ 大文件**里编辑**多行代码围栏**时,因大文件走防抖后台重解析、逐段落兜底看不到跨行围栏上下文 → 淡背景在打字期间短暂消失、停手 ~0.4s 自愈。真实小文件（<20k,同步解析）无此问题。**正解 = M2 tree-sitter 增量解析**（打字时即知"在代码块内",无需整篇重解析）。M1 接受此取舍。
- **状态**：**已落锤（M1.0.5a，2026-07-22）**。机制进 M1.1 产品化 + M1.6 专注 + M1.8 rubric 复用。

## D-M1-5 · 预览/导出 HTML 管线 = 优先 swift-cmark C renderer，pending「C API 是否公开」spike；绝不引第二个解析器

- **背景**：**最高优先级待验证声明**——findings 3/4/6/11（预览、GFM、预览内图片、导出）**全押** swift-cmark 公开暴露 `cmark_render_html` + GFM/footnote/sourcepos 扩展 C API。但 Apple 的 swift-cmark 历来只把 cmark 当内部/SPI target 供 swift-markdown 用，**未必**作公开产品。若为假，一次失败**级联**打穿预览+GFM渲染+预览图片+导出四处。
- **决定**：**M1.0.5 先 spike 核实**（看 Package.swift 的 product/target 可见性，别信 README）。① 若公开：预览/导出 HTML 走 **cmark C renderer**（safe 模式、开 `CMARK_OPT_SOURCEPOS` 拿 `data-sourcepos`、注册与编辑器一致的 GFM 扩展、并开 `CMARK_OPT_FOOTNOTES` 补 swift-markdown 默认关掉的脚注）。② 若不公开：退**自写 `MarkupVisitor`** 遍历 swift-markdown AST 直接产 HTML（顺带复用同一次解析、避免重复 target 冲突）。**两种都绝不引 markdown-it 之类第二个解析器**（会与编辑器 cmark-gfm 方言分叉）。滚动同步锚点 = `data-sourcepos` 块级行号 + 二分 + 线性插值；驱动权模型防反馈环。
- **M1.0.5b 核实（2026-07-22，源码级，取分支①）**：读 swift-cmark 0.8.0 的 `Package.swift` + 头文件确认——它**公开暴露 `.library` product `cmark-gfm` 与 `cmark-gfm-extensions`**；`cmark-gfm.h` 里 **`cmark_render_html(...)` 公开声明**、`CMARK_OPT_SOURCEPOS (1<<1)`、`CMARK_OPT_FOOTNOTES (1<<13)` 均定义；扩展注册函数 `cmark_gfm_core_extensions_ensure_registered()` 等齐全。swift-markdown 本身即 `import cmark_gfm`/`import cmark_gfm_extensions`。**批判担心的「swift-cmark 只作内部 SPI、不公开」在 0.8.0 已证伪。** → **取分支①：预览/导出走 cmark C renderer**（safe 模式 + `SOURCEPOS` + `FOOTNOTES` + 注册 GFM 扩展）。
  - **消费法**：给我们的 target **加 `cmark-gfm` + `cmark-gfm-extensions` 两个 product 依赖**。因 swift-markdown 已把**同一** swift-cmark（0.8.0）拉进依赖图，SPM 共用一份 → **无「重复 target」冲突**；`import cmark_gfm`，`cmark_render_html(node, CMARK_OPT_SOURCEPOS | CMARK_OPT_FOOTNOTES, exts)`。每次 bump 复核同 revision（BSD-2）。
- **状态**：**已定分支①（cmark C renderer，M1.0.5b 源码核实）**。落地在 M1.4 预览子系统。回填 architecture §9。

## D-M1-6 · 搜索 = 三面板混合（内存标题索引 + SQLite FTS5/GRDB + 独立命令面板），CJK 分词器是硬验收

- **决定**：① **omnibar**（搜索=新建）用**内存**级 {文件名/H1/frontmatter alias/mtime} 索引，Library 一开就即时可用（先于内容索引完成）；② **全文内容搜索**用 **SQLite FTS5 经 GRDB.swift（MIT）**，external-content 表、库放 **app 容器**（绝不写进用户 vault），随 L5 的 FSEvents 管线增量 DELETE+INSERT；**默认 unicode61 分词器对中文零结果，必须换 CJK-aware（纯 Swift bigram/逐字 `FTS5WrapperTokenizer`）并在真中文语料上测召回——这是和 byte-exact 同级的硬验收门**；③ **命令面板（⇧⌘P）**是**独立**的静态命令表、frecency 排序但**稳定不重排**（VS Code 教训），不与文件混池。
- **理由**：拒绝 CoreSpotlight 当主后端（沙箱/签名脆弱、异步、无排序控制）、拒绝 ripgrep 每键重扫。索引是**派生物**（像 AST）、可无损重建、永在容器。GRDB 7 自带 `SQLITE_ENABLE_FTS5`，SPM 即用、无需自编 SQLite。
- **注意**：内容索引**排在 FSEvents 管线之后**（那条本身是 M1 未建的活，别当已有）；先发标题 omnibar、内容 FTS 紧随；漂移当一等 bug（可重建/修复路径）。
- **状态**：已定（分词器策略上真语料后可微调）。

## D-M1-7 · 版本历史 = 自管本地快照目录（app 容器），不用内置 Git、不用 NSFileVersion

- **决定**：M1 做「自管 Local History 快照库」于 app 容器（Application Support），仿 VS Code Local History / Obsidian File recovery：`History/<fileKey>/entries.json`（{snapshotID, sourcePath, timestamp, contentHash, lineEnding, size, origin}）+ 哈希内容 blob。**不用内置 Git**（libgit2 GPLv2-带链接例外擦红线、不能住 iCloud 文件夹、对单人偏重）、**不用系统 NSFileVersion**（耦合文件身份，我们的原子替换会换 inode 令其失效，且 iCloud 下偶发 Cocoa-513）。
- **要点**：`<fileKey>` 键**稳定 ID / bookmark**（**不用绝对路径**——Obsidian 用绝对路径，vault 一移历史就丢）；每次保存前对**旧内容**留 pre-write 快照（这就是路线 B checkpoint 的种子）；contentHash 去重；保留策略（默认 ~7 天或保留 N 份 + 体积上限）启动时 prune；删除走 `FileManager.trashItem`，**永不 unlink**。manifest 格式**带版本号**，将来接 Git/系统 Versions 不用迁移。
- **状态**：已定（回填 architecture §3.5 / §9 #8）。

## D-M1-8 · 原子写 API 终选 = `replaceItemAt` 包在 `NSFileCoordinator` 内 + Cocoa-513 重试兜底（升级 M0 的 `Data.write(.atomic)`）

- **背景**：architecture §9 #5 / D-M0-4 把终选留到 M1。M1 新开至少 6 条写/变换路径（原子替换、图片落盘、快照 blob、静默重载重编码、语义编辑换行归一、标记弱化属性变换），每条都可能静默破 byte-exact。
- **决定**：保存 = 同目录写 temp（保 BOM/行尾/末尾换行）→ `FileManager.replaceItemAt(dest, withItemAt: temp)` **包在** `NSFileCoordinator.coordinate(writingItemAt:options:.forReplacing)` 内；`replaceItemAt` 比 `Data.write(.atomic)` 更好保留权限/属主/xattr。iCloud/Dropbox 下偶发 **Cocoa-513** 用有界重试、再退协调式 in-place 写；写前读的关键 xattr 写后重贴。外部重载路径**必须重跑严格 UTF-8 解码 + 重测 BOM/行尾/末尾换行**（Agent 可能改了编码，绝不假设旧编码）。
- **状态**：已定（回填 architecture §3.1 / §9 #5）。

## D-M1-9 · 自写去重 = SHA-256 内容哈希哨兵（主判据），绝不 mtime/inode；手写 FSEvents 不引库

- **背景**：完备性验证抓出——旗舰参考 **CodeEdit PR #2075 其实是 NSDocument 子类**、且用 **mtime 比较**去重（正是我们判定的反模式：原子 temp+rename 换 inode、只改 ctime、mtime 1s 精度、iCloud 截断毫秒）；`NSFileCoordinator(filePresenter:)` 的自写抑制**不是保证**（会双发、可能反放松写互斥）。
- **决定**：自写去重的**权威判据 = 记录我们原子写入的确切字节的 SHA-256（CryptoKit），事件到来时重读比对，相等即自己的回声、忽略**；协调式 presenter 抑制 + 短时「最近写过 {path}」集只当第一道**廉价过滤**。哈希在协调写块**内**记录。回调**幂等**、预期双发与跨线程。**FSEvents 目录级手写（~150 行）**，不引 FSWatcher（pre-1.0 单人库，别放可靠性关键路径）；FSEvents 可能静默死 → 窗口聚焦时**对账扫描**兜底。
- **参考取舍**：CodeEdit #2075 只抄**重载语义**（内容替换进现有 text storage 保 TextKit2 订阅者、按 offset 保选区、重载算可撤销帧、无编辑器时清 undo 栈），**不抄**其架构（NSDocument）与 mtime 去重；undo 重新归位到 L2。
- **状态**：已定（回填 architecture §3.3 / §9 #6）。

## D-M1-10 · 两处范围矛盾按 PRD 拍死

- **决定**：① **Mermaid 留在 M1**（PRD §5.1 一等公民；finding 3 想为收紧 CSP/减体积踢出——不采纳，改用离线打包 + CSP 门控 + 懒加载压体积解决其顾虑）。② **编辑区代码围栏**M1 只做「等宽 + 淡背景」，**不引 JSCore（HighlighterSwift）进编辑区**；代码高亮「一等公民」（复制按钮、语言标签、质量）**体现在预览区**（highlight.js 起步，Shiki 升级）；**编辑区增量高亮留到 M2 的 tree-sitter**。
- **理由**：克制第一 + 保编辑区 60fps；预览区上 JS 高亮成本低、效果好。语言标签来自 fence info string（`CodeBlock.language`），复制按钮锚在 fenced-block 的 SourceRange，成本很低。
- **状态**：已定。

## D-M1-11 · 依赖标准修订：Highlightr（停更）→ HighlighterSwift；新增 GRDB.swift

- **背景**：`dependencies-and-licenses.md` §2.2 现把 **Highlightr 列为 M1 approved starter，但它 2026 已停更、README 自己跳转 HighlighterSwift**——违反本项目「不引停更库」硬闸。
- **决定**：**改 `planning/standards/dependencies-and-licenses.md`**：把 Highlightr 降入停更/禁用列表；**HighlighterSwift（MIT，活跃）升为 approved 的原生代码高亮项、取代停更的 Highlightr**——但**M1 编辑区代码围栏只做等宽+淡背景、不接它**（D-M1-10），它是原生高亮的保留选项（M2 或确需时再接）；**M1 预览区代码高亮用 highlight.js 起步**；新增 **GRDB.swift（MIT）** 为 approved（搜索，见 D-M1-6）；确认 **swift-markdown（Apache-2.0）**。每次 bump 复核 LICENSE（STTextView 由宽松改 GPLv3 是先例；本次调研中一度有搜索摘要误标 swift-markdown-engine 为 MIT——**看 LICENSE 文件、别信摘要**）。
- **状态**：已定，**待改 standards 文件**（M1.0 一并做）。

## D-M1-12 · 字体：打包 IBM Plex Mono（OFL）作编辑器默认；New York 绝不打包（走系统）

- **决定**：编辑器默认字体**打包 IBM Plex Mono**（OFL 1.1，允许随 Apache-2.0 app 分发，附 OFL.txt + copyright，改动则改名），可另提供 **iA Writer Duospace**（OFL）为「Duo」选项；**New York 绝不打包**（系统字体）——预览 CSS 走 `ui-serif`、AppKit 走 `NSFontDescriptor.withDesign(.serif)`。启动注册 5 个 `NSAutomatic*SubstitutionEnabled=false` 默认（byte-exact）。
- **状态**：已定（打包前复核 iaolo/iA-Fonts 与 IBM/plex 的版本/许可）。

## D-M1-13 · network.client entitlement：M1 起申请（WKWebView 沙箱需要），CSP 强制零出站（修订红线 R2.3）

- **背景**：M1.4 分屏预览用 WKWebView。**实测(2026-07-22)**：沙箱下 WKWebView 的 WebContent/GPU/Network 辅助进程**起不来**（控制台：`web process failed to launch` + `Sandbox is preventing … reading networkd settings` + Network process crash）→ 预览全白。macOS 已知要求：**沙箱 app 用 WKWebView 必须有 `com.apple.security.network.client`**,哪怕内容全本地。而 security §R2.3 原本禁它——**动手做才撞出的规划疏漏**。
- **决定**：**申请 `com.apple.security.network.client`**（Signing & Capabilities → App Sandbox → Outgoing Connections,存进 `project.pbxproj` 构建设置）+ **修订红线 R2.3**。隐私叙事**不变且可强制**：预览页 CSP `default-src 'none'; connect-src 'none'`（禁一切出站 fetch）+ 仅本地内容 + `allowsContentJavaScript=false` + 零遥测 → **app 持有权限但发零个真实网络请求**。**约束**：app 自身代码不得发 `URLSession`/socket 出站(联网仅限 WKWebView 辅助进程、被 CSP 锁死)。
- **理由**：预览 + 未来 Mermaid/KaTeX/PDF 导出全建在 WKWebView 上,离不开它。先例:MarkEdit(整个编辑器即 WKWebView)沙箱 + network.client + 零遥测。
- **知会**：Sparkle 的 D-M0-1(为避 network.client 而用 Downloader XPC)理由已 moot,但 XPC 方案无害,M1.9 接 Sparkle 时可重评是否简化。
- **状态**：已定;红线 [R2.3](../standards/security-and-privacy.md) 已改。

## D-M1-14 · M1.4.c 预览代码高亮 = highlight.js 服务端跑（进程内 JSCore），不进 WebView — 订正 D-M1-10 ② 的载体

- **背景**：D-M1-10 ② 原设「预览区 highlight.js 起步」默认理解为**在 WebView 里**跑 hljs。M1.4.c 动手设计（2026-07-22，多 agent workflow + 对抗验证）发现进 WebView 的两条路都有代价：**内联**会把 `script-src 'unsafe-inline'` 钉死、每次 0.15s 重载重解析 ~90KB blob，且带 `</script>`-in-blob 截断坑，与 M1.4.d 收紧 CSP 的终局对着干；**WKURLSchemeHandler** 红队实测确认 `loadHTMLString(_, baseURL: nil)` 下文档是 opaque origin，自定义 scheme 子资源**不会**路由到 handler（`start()` 不触发），要让它生效必须先把顶层加载改成自定义 scheme origin——那是 M1.4.d 的活，现在做等于半迁移 + 二次改同一批文件。
- **决定**：**M1.4.c 让 highlight.js 在 Swift 进程内的 JavaScriptCore 里跑**（L4 Model→HTML 单向）。把 cmark 输出的 `<pre data-sourcepos><code class="language-XXX">…</code></pre>` 中 **`<code>` 内层**替换成 hljs 染色后的 `<span>`，**`<pre>`（含 `data-sourcepos`）一字节不动**；WebView 只收到「预染 `<span>` + 内联主题 `<style>`」。**CSP 原样不变**（不加 `script-src`、不碰 `connect-src 'none'`）、**零新增网页脚本**、绕开 baseURL/scheme 坑、跟光标锚点不坏（高亮在 `loadHTMLString` 前同步完成，`build()` 量到的是终态 DOM）。
- **关键约束（load-bearing）**：`JSContext` 建一次、复用、钉在**单一专用串行队列**（JSCore 跨队列不安全，逐键新建上下文要几十 ms 且跨队列用会崩）；高亮全程**主线程外**，只在 `loadHTMLString` 回主线程；单围栏 >~40KB 跳过高亮（纯淡背景兜底）；用 generation token 丢弃过期结果。**未注册语言**先 `hljs.getLanguage(x)` 判空 + `try/catch`（hljs v11 遇未知语言**抛异常**不是返 nil），并装 `exceptionHandler`。UMD 版 hljs 在裸 JSContext 里 `window/self` 均 undefined，需 `var window=this,self=this;` 垫片 + warm() 断言 `hljs` 已挂全局。
- **不触碰**：**编辑区仍只「等宽 + 淡背景」、不引 JSCore**（D-M1-10 ② 编辑区规则不变——本决策只改预览区 L4 单向渲染的载体）。KaTeX/Mermaid/复制按钮/严格 CSP + scheme handler 仍是后续 M1.4.c/d。Shiki 升级（纯 JS 引擎、必进 WebView）时本服务端路径作废，故 `CodeHighlighter` 接口收窄成 `String→String` 以控改动面。
- **依赖/许可**：highlight.js（**BSD-3-Clause**）作 `dependencies-and-licenses.md` §4 的 vendored 静态资源**打包**（非 SPM 包，`Package.resolved` 不动）；JavaScriptCore 为系统框架。记入 `THIRD-PARTY-LICENSES.md`：版本 + 源 URL + 完整 BSD-3 文本 + 构建期 sha256 + 打包语言清单（可复算，遵 D-M1-11「看 LICENSE 文件、别信摘要」）。
- **状态**：已定（订正 D-M1-10 ② 的实现载体；CSP/网络红线不变）。

## D-M1-15 · M1.2 外部改盘重载分阶段：presenter 优先 + 「写前读」防覆盖为载荷；FSEvents 推迟到 M1.5

- **背景**：M1.2 原设两层（architecture §3.3：FSEvents 库级 + NSFilePresenter 单文件，「两者都要」）。M1.2 动手设计（多 agent workflow + 对抗验证）得出一个**重构性判断**：真正的数据安全风险**不是「漏掉变更事件」，而是「app 用陈旧 buffer 覆盖外部改动」**（autosave/save clobber，实测三处未协调写 `LibraryModel.swift` :36/:142/:157，autosave 守卫对外部改动无感）。而这个覆盖的修复是**与监听无关的**——在唯一的 `writeAndRecord` 写入收口处做「写前读 + SHA-256 比对」：磁盘 ≠ 我上次写的 → 中止写、升非模态横幅。一旦「覆盖」由写入路径负责，FSEvents 对 dogfood 的唯一增益（前台时实时重载打开的文件）就退化为 **UX 延迟差、不是数据丢失差**。
- **决定**：**M1.2 Increment 1 = 仅 Tier-1**（单文件 `NSFilePresenter`）+ **写前读防覆盖** + **SHA-256 自写去重** + **聚焦/前台对账扫描**（未协调写者如 sed/echo 的主网）+ **静默保选区重载**（干净文件）/ **脏文件非模态 Reload/Ignore/Compare 横幅**。**vault 级 FSEvents（Tier-2）推迟到 M1.5**——搜索索引才是「库级变更感知」的首个真实消费者；在那之前侧栏对**非打开**文件的增删改不实时刷新（无消费者，推迟干净）。**同一增量内落地 D-M1-8 协调原子写**（`replaceItemAt` 包 `NSFileCoordinator` + Cocoa-513 重试），**绝不让监听跑在裸 `MarkdownFileIO.write` 上**。
- **载荷/红线**：`lastWrittenHash[url]` = 已接受磁盘真相的 SHA-256，在**每个接受磁盘真相的点**推进（初始加载 / 静默重载 / Reload / Ignore），否则重载后首次保存误中止（复审 BLOCKER①）；切文件 flush 若因外部改动中止，**不得静默丢弃离开文件的未存编辑**（复审 BLOCKER②，需否决切换或暂存）；重载在 IME 组字（`hasMarkedText`）中延后、绝不 `replaceCharacters`；写前读把整文件读+哈希放 Q_io（大文件别卡主线程）；**绝不 mtime/inode**、**绝不读 `.layoutManager`**。自刷新死循环结构性关闭（重载无写 + `isLoading` 抑制 `changed` + 快照推进 `isDirty=false`；SHA-256 是纵深防御不是断环器）。
- **spike 实测结论（2026-07-22，step 1，全绿优于悲观预设）**：macOS 15 上，**全部 4 种未协调外部写（`echo >>` / `printf >` / `sed -i` / python open+write+rename）在 Colophon 前台时都触发了 `presentedItemDidChange`** → **单文件 presenter 已给 dogfood 写者实时覆盖，Increment 2 的 `DispatchSource`-vnode 不需要**（对账扫描降为纯兜底/漏事件补网）。我方协调写（`NSFileCoordinator(filePresenter:self)` 建在 presenter 串行队列 + temp + `replaceItemAt`）**自抑制成功**（写完无 FIRED；SHA-256 仍作权威兜底）。外部协调读在独立串行队列（Q_io）**无死锁**。
- **状态**：已定；spike 已过。Increment 1 **步骤 2–7 已实现 + 单测覆盖**（协调写+指纹、写前读防覆盖+切文件否决、`reloadPreservingSelection`、`DocumentPresenter`、聚焦对账、脏文件横幅；`CoordinatedFileIOTests`/`TextBufferTests`/`LibraryModelTests` 共 35 用例绿），**跳过 Increment 2**；FSEvents 仍留 M1.5。**步骤 2–7 已真机验证通过（2026-08-01）**（外部改盘→静默重载/横幅、Reload/Keep-Mine、切文件否决、自写去重、⌘S 无脏检查卡顿已修）。**步骤 8（删除/改名硬化）已实现 + 单测（37 用例；`writeGuarded` `.removed`＝绝不静默重建消失文件、`deletedFileURL` 横幅门控自动保存、`restoreDeleted` 重建），实况删除/改名待验。**剩 Compare 视图（V1）。

---

## M1 待落锤清单（spike 输出，回填本文 + architecture §8/§9）

| # | 待落锤 | 在哪关 | 关联决策 |
|---|---|---|---|
| 1 | ~~内核 (b) 是否达标~~ **✅ 通过（2026-07-22）** | M1.0 | D-M1-1 |
| 2 | undo 内建 vs 模型接管 | M1.0 | D-M1-3 |
| 3 | AST-as-API 缝的接口签名 | M1.0 | architecture §7.2 |
| 4 | ~~前景着色机制 + 动态刷新法~~ **✅ delegate+兜底+edited重vend（2026-07-22）** | M1.0.5a | D-M1-4 |
| 5 | ~~swift-cmark C-renderer 是否公开~~ **✅ 公开→分支①（2026-07-22）** | M1.0.5b | D-M1-5 |
| 6 | CJK 分词器召回（真语料） | M1.5 | D-M1-6 |
| 7 | 默认主题/字体/暗色 accent（macOS 26 真机像素定） | M1.8 | D-M1-12、design-direction |
