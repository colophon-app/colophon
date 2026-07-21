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
- **状态**：机制单一化已定 · **M1.0.5 spike 定具体选与刷新法**（大文件性能是硬验收点之一）。

## D-M1-5 · 预览/导出 HTML 管线 = 优先 swift-cmark C renderer，pending「C API 是否公开」spike；绝不引第二个解析器

- **背景**：**最高优先级待验证声明**——findings 3/4/6/11（预览、GFM、预览内图片、导出）**全押** swift-cmark 公开暴露 `cmark_render_html` + GFM/footnote/sourcepos 扩展 C API。但 Apple 的 swift-cmark 历来只把 cmark 当内部/SPI target 供 swift-markdown 用，**未必**作公开产品。若为假，一次失败**级联**打穿预览+GFM渲染+预览图片+导出四处。
- **决定**：**M1.0.5 先 spike 核实**（看 Package.swift 的 product/target 可见性，别信 README）。① 若公开：预览/导出 HTML 走 **cmark C renderer**（safe 模式、开 `CMARK_OPT_SOURCEPOS` 拿 `data-sourcepos`、注册与编辑器一致的 GFM 扩展、并开 `CMARK_OPT_FOOTNOTES` 补 swift-markdown 默认关掉的脚注）。② 若不公开：退**自写 `MarkupVisitor`** 遍历 swift-markdown AST 直接产 HTML（顺带复用同一次解析、避免重复 target 冲突）。**两种都绝不引 markdown-it 之类第二个解析器**（会与编辑器 cmark-gfm 方言分叉）。滚动同步锚点 = `data-sourcepos` 块级行号 + 二分 + 线性插值；驱动权模型防反馈环。
- **状态**：方向已锁（优先 cmark、否则 visitor、单解析器）· **M1.0.5 spike 定分支**。回填 architecture §9。

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

---

## M1 待落锤清单（spike 输出，回填本文 + architecture §8/§9）

| # | 待落锤 | 在哪关 | 关联决策 |
|---|---|---|---|
| 1 | ~~内核 (b) 是否达标~~ **✅ 通过（2026-07-22）** | M1.0 | D-M1-1 |
| 2 | undo 内建 vs 模型接管 | M1.0 | D-M1-3 |
| 3 | AST-as-API 缝的接口签名 | M1.0 | architecture §7.2 |
| 4 | 前景着色具体机制 + 动态刷新法 | M1.0.5 | D-M1-4 |
| 5 | swift-cmark C-renderer 是否公开 → 管线分支 | M1.0.5 | D-M1-5 |
| 6 | CJK 分词器召回（真语料） | M1.5 | D-M1-6 |
| 7 | 默认主题/字体/暗色 accent（macOS 26 真机像素定） | M1.8 | D-M1-12、design-direction |
