# M1 · MVP —— 执行计划（plan）

> **怎么用**：这是 M1 的照做清单，逐条勾 `- [ ]`。范围/DoD 在 [`overview.md`](./overview.md)，依据在 [`research.md`](./research.md)（引其 D 号/§号），决策在 [`decisions.md`](./decisions.md)（引 D-M1-x）。
> **顺序哲学**（来自 research §15 批判的 sequencing）：**先把一个人的整个风险预算前置成「关卡（spike）」，再做功能**。M1.0/M1.0.5 三个 spike 不过、就不进对应功能；先冲到「能日用」（M1.1）尽早 dogfooding。
> **贯穿红线**（任何一条违反即该 PR 打回）：源码为唯一真相 · byte-exact + 原子写 · **禁触 `NSTextView.layoutManager`** · **undo 入口在 L2** · 导出走 WKWebView/PDFKit · 编辑区非玻璃 · 不引 GPL/停更库。

---

## 阶段依赖图

```
M1.0  内核(b) + undo模型 + AST缝签名  ─┐  (gates 全部)
M1.0.5 三个并行去风险 spike ───────────┤  着色机制 / swift-cmark可用性 / byte-exact回归扩测
                                        ▼
M1.1  日用核心（样式化+Agent识别+文件树+落盘+自动保存） ← 尽快到这里，开始 dogfooding
M1.2  外部变更重载（FSEvents+协调+哈希去重）           ← 数据安全，早做
M1.3  语义/列表/图片/URL成链          ← 依赖 M1.0 的 undo 模型
M1.4  分屏预览+60fps同步（GFM/KaTeX/Mermaid/代码高亮） ← 依赖 M1.0.5b 的管线分支
M1.5  omnibar+FTS5搜索(CJK硬门)+命令面板              ← 内容索引在 M1.2 管线之后
M1.6  专注模式+打字机                 ← 依赖 M1.0.5a 的着色机制 + caret-rect spike
M1.7  文件系统版本历史/快照           ← 建在 M1.1 原子写 + M1.2 自写去重上
M1.8  两套主题精调 + HTML/PDF 导出    ← 需 macOS 26 真机；导出依赖 M1.0.5b
M1.9  发布自动化 + Sparkle + Homebrew ← 收官（但 EdDSA 私钥/SUFeedURL 在 M1.0 就先办）
```

**跨阶段贯穿件**（research §15 批判补的盲区，散落进各阶段，勿漏）：frontmatter 基本显示、多文档/标签模型、设置持久化、无障碍、测试与验收基线——见文末 [§跨阶段贯穿件](#跨阶段贯穿件must勿当可选)。

---

## M1.0 · 龙头 spike：内核(b) + undo 模型 + AST 缝签名（gate 一切）

> 目标：**一次 hands-on spike 同时钉死三件下游全依赖的事**，别带着 open decision 出关。前置：M0 骨架。依据 research §14（spike 设计 Day0–Day3）、D-M1-1/3。

- [x] **Day 0**：建 spike 分支 + 语料库（[spike/fixtures/](../../spike/fixtures/)：`agent-file.mdc`、`gfm-kitchen-sink.md`、`cjk-emoji.md`、`crlf-bom-no-trailing.md`、1.1MB `large-synthetic.md`〔gitignore〕）。`swift-markdown 0.8.0` 经 SPM 加入（`Markdown` 产品 → Colophon target，upToNextMinor），`Package.resolved` 已提交。✅
- [x] **Day 1（内核样式化切片）**：`SourceRangeMapper`（UTF-8↔UTF-16，CJK/emoji 单测过）+ `MarkdownSyntaxStyler`（AST→run：标题/粗/斜/代码/`#` 弱化）+ `MarkdownTextView` 后台解析 + 大小分档（<20k 同步零闪、大文件长防抖）。验收：标记留源码 ✅、样式正确 ✅、CJK byte-exact ✅、真实文件即时零闪 ✅。**实测：1MB+ 单文件打字慢 → 主因是 M0 桥每键把整篇字符串过 SwiftUI @Binding（→ L2 模型，M1.1）+ 整篇 addAttributes（→ 惰性 delegate 着色，M1.0.5a）。见 [decisions D-M1-1](./decisions.md) spike 结论。** ✅
  - [ ] **遗留小项（M1.3 输入法）**：组字期间（`hasMarkedText`）不重上样式的守卫。
- [ ] **Day 2（分屏 + byte-exact + undo 缝）**：加 `⌘\` WKWebView 预览（swift-markdown→HTML→loadHTMLString，行锚同步 + 反馈环 guard）。跑 byte-exact 回归：每个语料 open→noop-edit→save，断言逐字节相同（对 M0 的 `MarkdownFileIO`）。证 undo 缝：把一条编辑意图路由过一个**持有 UndoManager 的 stub L2 模型**，证明 architecture §5「undo 入口在模型层」可达而不与内核打架。
- [ ] **Day 3（大文档滚动稳定 + a/c 确认探针）**：压 M1 唯一真「岩浆」项——Moby Dick 视口估算滚动跳；跳则试缓存 fragment 高度/稳定锚点，记录能否稳。然后两个**严格限时（各 ~2h）**探针（只为守「换/box-out」判据，不是构建）：(a) clone swift-markdown-engine 跑 demo，查有无 source-only 模式、验 byte-exact + 不碰 `.layoutManager` + Apache-2.0，勾勒 M2 经 L1/L2 缝 drop-in 的样子；(c) 把 CodeEditTextView 丢进 scratch view 样式化，记自绘布局分歧 + 代码编辑器假设，确认它 M2 重写风险更高。
- [ ] **落锤**：结果记进 `decisions.md`（回填 D-M1-1/3、architecture §8/§9）：内核起点、M1 是否引 tree-sitter（预期否 D-M1-2）、undo 整合方式。**(b) 过 → spike 分支即 M1 内核种子**。
- [ ] **顺手办两件发布前置**（M1.9 才用但现在办）：`generate_keys` 生成 **Sparkle EdDSA 私钥并异地离线备份**；把 `SUFeedURL` 定好写进 Info.plist（首个签名构建前）。
- [x] **改 standards**：执行 D-M1-11（Highlightr→HighlighterSwift、加 GRDB.swift、确认 swift-markdown）改 `planning/standards/dependencies-and-licenses.md` §2.2。✅

**坑**：SourceRange 是 UTF-8 行列、NSTextView 是 UTF-16——CJK/emoji 不做转换会错位甚至改错字节（byte-exact 命门）；`.layoutManager` 只读一次即静默降 TextKit 1（Code review 必查，加 grep lint）；别在 Day 3 就去做标记隐藏/自定义 fragment（那是 M2 岩浆池）；swift-markdown **无增量重解析**——全靠防抖+后台+视口化。

## M1.0.5 · 三个并行去风险 spike（建任何依赖功能前）

> 目标：把三件「一失败就级联」的事先证掉。前置：M1.0 进行中即可并行。依据 research §15、D-M1-4/5。

- [x] **a) 前景着色机制单一化**（gates §2 样式化 / §8 专注 / §10 rubric）：**已落锤（2026-07-22）**——机制 = `NSTextContentStorageDelegate` 按需 vend（天然视口化、治大文件性能）+ 逐段落兜底（即时正确）+ `edited(.editedCharacters,0)` 重 vend（选区保存/恢复防跳）。实测证伪 `invalidateLayout` 重 vend。已知边缘:大文件多行代码围栏编辑态背景滞后 → M2 tree-sitter。见 [decisions D-M1-4](./decisions.md)。✅
  - [ ] **遗留(M1.0.5a 未做的)**：「从 AST 节点边界重建 marker 定界符偏移」的通用 helper(`*`/`_`/`**`/反引号/`~~`/`[]()`,含嵌套/多反引号/引用链接/setext)——M1.0 只做了标题 `#` 前缀弱化,其余定界符弱化留到 M1.1 样式产品化。
- [x] **b) swift-cmark C-renderer 是否公开**（gates 预览 + 导出全部）：**源码核实完毕（2026-07-22）**——swift-cmark 0.8.0 公开 `.library` product `cmark-gfm`/`cmark-gfm-extensions`，`cmark_render_html` + `CMARK_OPT_SOURCEPOS`/`FOOTNOTES` + 扩展注册函数均公开;swift-markdown 已把同一 swift-cmark 拉进图 → 加 product 依赖无重复 target 冲突。**取分支① cmark C renderer**([decisions D-M1-5](./decisions.md))。✅
- [~] **c) byte-exact 回归扩测**（在新写路径落地**前**）：已补 **BOM + CRLF + 无末尾**酷刑样本(`roundTripIsByteExact` 绿);emoji-offset 由 `MarkdownStylingTests` 覆盖。剩「智能标点默认/新写路径(原子替换/图片落盘/静默重载)」的矩阵随各阶段落地时补。部分完成。
- [ ] （可选，M1.6 前）**TextKit 2 打字机 caret-rect** 探针：证局部 `ensureLayout` 能拿准 caret 矩形而不全量卡秒级。

**坑**：三处着色各建一套 = 三份互斥实现（本关就是来消矛盾的）；swift-cmark 若不公开而你没先验，预览+导出+GFM+预览图片会**一起**塌（correlated failure）；回归扩测**必须先于**写路径，不然是「先污染再发现」。

## M1.1 · 日用核心（冲刺到 dogfooding）

> 目标：**作者本人能开始每天用它写**（= M1 DoD 的判据）。前置：M1.0 内核过。依据 PRD §5.1 A/B/D、research §1/§12、D-M1-8。

> **进度（2026-07-22）**：✅ Agent 文件识别、自动保存、L2 UI 隔离、`Document` 类型、嵌套文件树（前几轮）。✅ **文本所有权重构（M1.0 Day1 finding 的病根）**——L2 `TextBuffer` 独占一颗 `NSTextStorage` 作唯一真相源（architecture §2.2），编辑器 `contentStorage.textStorage = buffer.storage` 注入共享，**删掉每键整串 @Binding 往返**（`text.wrappedValue = textView.string` → @Published → SwiftUI → updateNSView O(N) 比 → 推预览），**1MB 文件末尾打字终于丝滑**。变更检测放 L2（`NSTextStorageDelegate.didProcessEditing` → payload-free `changed` 信号，预览+自动保存防抖读 `buffer.string`；也为将来程序化/AI 编辑触发）。同轮内建正确性：`undoManager(for:)→buffer.undoManager`（切文件 `load()` 清对的撤销栈，防 Cmd-Z 把旧文件编辑串进新文件损坏字节）、IME 组字抑制+组字结束补发、样式重-vend 防重入 flag、加载文件光标归顶（编辑器/光标/预览一致）、光标行统计换原生扫描（去掉每键 O(N)）。**byte-exact 修复**：句号替换（无 view 属性）经 `set()` 写 app 域强制关（`register()` 被系统全局盖过，双空格曾变句号）。`TextBufferTests` 锁 load byte-exact + 撤销清空 + dirty 比较。前置了一个一次性注入 spike 实测确认 macOS 15 上 `contentStorage.textStorage=自管storage` 是共享（非 @NSCopying 拷贝）+ 两 delegate 均触发。⬜ 本段仍欠：源码样式化产品化（其余定界符弱化）、文件树 10k 懒加载、落盘终态 D-M1-8（`replaceItemAt`+`NSFileCoordinator`+xattr）、frontmatter 显示、IME 深度守卫（M1.3）。

- [ ] **源码样式化**落地（M1.0 切片产品化）：标题变大、粗体变粗、标记弱化保留；rubric red 光标行标记（用 M1.0.5a 定的机制）。
- [ ] **Agent 文件识别表**（research §15 批判点名 M1 品牌一半、零覆盖）：**数据驱动**的 {文件名/glob/路径 → 类型} 表识别 `CLAUDE.md`/`AGENTS.md`/`*.mdc`/`SKILL.md`/`llms.txt`；「特别渲染」在源码样式化态先做轻处理（如顶部标识 + frontmatter 区块着色），与 frontmatter 显示协同。
- [ ] **文件树懒加载**（批判点名，与搜索是**两件事**）：`FileManager.enumerator` 惰性枚举、虚拟化树、security-scope 下遍历、跟踪重命名/移动，撑 10k+ 文件流畅（architecture §2.3）。
- [ ] **落盘终态**：把 M0 的 `Data.write(.atomic)` 升级为 D-M1-8 的 `replaceItemAt` + `NSFileCoordinator` + Cocoa-513 重试兜底 + xattr 保留；严格 UTF-8、BOM/行尾/末尾换行保真。
- [ ] **自动保存**：防抖(~1–2s idle) + 失焦/resignActive/关闭即存；IME marked text 期间不存；每次落盘满足 byte-exact + 原子。自写触发的 FSEvents 要能被 M1.2 的哈希哨兵识别（先埋 hook）。
- [ ] **frontmatter 基本显示**（贯穿件）：YAML frontmatter 识别 + 源码着色（不做表单，表单是 M2）。

**坑**：文件树别一次性全读全解析（10k+ 卡死）；原子替换会剥离 C-flag xattr（写前读、写后贴）；自动保存别在 IME 组字中触发。

## M1.2 · 外部变更重载（无「已在磁盘更改」弹窗）

> 目标：Agent 改盘上文件即时反映、无模态弹窗。前置：M1.1 落盘。依据 architecture §3.3、research §7、D-M1-9。

- [ ] **Tier 1 每个打开的 Document**：其协调对象作 `NSFilePresenter`（`presentedItemURL` + 专用串行 queue），open 时 `addFilePresenter`、close 时 remove；**所有读写**走 `NSFileCoordinator(filePresenter:).coordinate(...)`。
- [ ] **Tier 2 文库级 FSEvents**：`FSEventStreamCreate` 于库根（`WatchRoot|UseCFTypes`，latency~0.05s，在 resolved bookmark 的 `startAccessingSecurityScopedResource` 后启），**目录级**事件（大 vault **别**开 `FileEvents` flag），自加 ~100–200ms 去抖。**手写 ~150 行，不引 FSWatcher。**
- [ ] **自写去重（哈希主判据）**：`lastWrittenHash[path]=SHA-256`（CryptoKit），在协调写块**内**记录；事件到来经 `coordinate(readingItemAt:)` 重读+哈希，等则忽略。presenter 抑制/短时集只当廉价过滤。**绝不 mtime/inode。** 回调幂等。
- [ ] **决策逻辑**：不脏→**静默重载**（重跑严格 UTF-8 + 重测 BOM/行尾/末尾换行；把内容替换进**现有 text storage**保住 TextKit2/高亮订阅者；按 offset 保选区；重载算一个可撤销帧）；脏→**非模态** Reload/Ignore/Compare 横幅（Reload+Ignore 全做，Compare 做最小整文件只读对照，逐 hunk 是 V1）。
- [ ] **可靠性兜底**：窗口聚焦/app 前台时**对账扫描**（比开档 mtime+size vs 记录），防 FSEvents 静默死漏事件。
- [ ] iCloud/网盘：读走 coordinator，冲突副本(`note 2.md`)**至少不加剧**（不覆盖、不静默合并）。

**坑**：去重不严 → 自刷新死循环（MarkText #1261）；**CodeEdit #2075 是 NSDocument 子类且用 mtime 去重**——只抄重载语义，别抄架构和 mtime；presenter 抑制不保证（会双发）；重载路径若假设旧编码 → 下次保存腐蚀文件；presenter 回调在后台 queue，碰 text storage 必跳 MainActor 且**绝不读 `.layoutManager`**。

## M1.3 · 语义快捷键 + 智能列表 + 图片落盘 + URL 成链

> 目标：Markdown 编辑手感。前置：**M1.0 的 undo 模型已落锤**。依据 research §4/§5、D-M1-3。

- [ ] **单一编辑原语**：所有语义/列表操作实现为纯 Swift 函数 `(源码串, 选区)→(替换edits, 新选区)`，全部漏斗过 L2 的 `applyTextEdit(...)`：换行归一到文档行尾风格、注册单步 undo（反向编辑）、`breakUndoCoalescing()`、经 `shouldChangeText→replaceCharacters→didChangeText` 推视图、设选区。**不让内建 undo 与模型各记一份**（双撤销）。
- [ ] **语义命令**：`⌘B`/`⌘I`(空选区扩到词或插空标记)、升降标题(重写行首 ATX run，H1–H6 clamp，永远 hash 后一个空格)、勾选任务(定位 `ListItem.checkbox`，只翻单个 `[ ]`↔`[x]`)。
- [ ] **智能列表**（照抄 CodeMirror lang-markdown 三算法的精神）：`insertNewlineContinueMarkup`(Enter 续标记/自动编号/空项退出)、`deleteMarkupBackward`(Backspace 删一层标记)、`renumberList`(只重排连续 prev+1 段、遇 gap 停)。列表缩进 = **源码里的空格**（**不用 `NSTextList`**，macOS 14 起坏）。
- [ ] **块上下文同步读源码串**（正则/行扫），**不读**防抖 AST（刚敲完键 AST 可能陈旧）。M1 **单光标**（多光标是 Joplin 的坑）。
- [ ] **图片粘贴/拖拽落盘**：`readObjects(forClasses:[NSImage, NSURL])`；文件源**逐字节 copy**（不重编码），剪贴板位图 → `NSBitmapImageRep` 编 PNG；写进 vault 内 note-relative `assets/`（安全 scope 级联子目录）；插**纯文本** `![](相对路径)`（**绝不 NSTextAttachment**——那破 byte-exact + 拉向 TextKit1）；写盘走后台(L5)、回 MainActor 应用文本意图；**整个「写文件+插文本」一个 undo 组**（MVP undo 只删文本、留文件孤儿，记一笔）。
- [ ] **URL 成链**：粘贴内容是单个合法绝对 URL(有 scheme) 且选区非空且不在链接内 → 替换为 `[选区](url)`；否则正常粘贴。Shift-粘贴 = 强制纯文本逃生。

**坑**：换行不按文档 CRLF/LF 归一 = 静默混行尾破 byte-exact；缩进/重排只碰目标字符别 reflow 别的行；UTF-8↔UTF-16 偏移错位；无 `breakUndoCoalescing` 命令会并进打字 undo 组；远程图片(仅 http URL)——MVP 无网络 entitlement，只插 URL 不下载。

## M1.4 · 分屏预览 + 60fps 双向滚动同步

> 目标：`⌘\` 分屏、滚动不晕、GFM/数学/Mermaid/代码在预览正确。前置：**M1.0.5b 管线分支已定**。依据 research §2/§3、D-M1-5/10、security-and-privacy §5。
>
> **进度（2026-07-22）**：✅ **M1.4.a 分屏**——`⌘\` 开 WKWebView 预览；cmark C renderer（safe + SOURCEPOS + GFM + FOOTNOTES，分支①）产 HTML；`loadHTMLString`（scheme-handler 留 M1.4.d）；基础 CSS（New York 衬线）+ CSP（`connect-src 'none'`）。沙箱 network.client 见 [D-M1-13](./decisions.md)。✅ **M1.4.b 跟光标**——编辑器光标行 → 预览 `data-sourcepos` 锚点（`PreviewSync`），放上方 ~1/3。⬜ **精确双向滚动同步**——实测撞 research §3 硬点（编辑器侧 TextKit 2 估算高度漂移 + per-tick `evaluateJavaScript` 卡；块级锚点插值 vs 两侧换行不同），需 fragment 高度缓存 + `postMessage`/rAF + 更细锚点，**记为专门后续**。✅ **M1.4.c 代码高亮**——highlight.js **服务端**跑（进程内 JSCore，[D-M1-14](./decisions.md)），只改 `<code>` 内层、`<pre data-sourcepos>` 一字节不动（跟光标不坏）；GitHub 明/暗主题；JSContext 单串行队列 + 主线程外 + generation token；未知语言（`getLanguage` 判空 + JS `try/catch`）/超 40KB 兜底纯文本；`CodeHighlighter` 6 条黄金测试锁 cmark 形状 + 每条兜底。**CSP 原样不变、零新增网页脚本、零出站保持**。vendored highlight.js 11.11.1（BSD-3）记入 `THIRD-PARTY-LICENSES.md`。⬜ **精确双向滚动同步**（见上，专门后续）、**KaTeX/Mermaid + scheme-handler + 严格 CSP 响应头 + 语言标签/复制按钮** 仍留 **M1.4.d 抛光**。

- [ ] **管线（L4，Model→HTML 单向）**：按 D-M1-5 分支产 body HTML（cmark safe+SOURCEPOS+GFM+FOOTNOTES **或** 自写 MarkupVisitor emit `data-sourcepos`）；保 swift-markdown AST 作语义/大纲/导出。
- [ ] **投递**：注册 `WKURLSchemeHandler`（私有 scheme，如 `colophon-preview://`）——发固定 shell HTML（打包 JS/CSS + **真 CSP 响应头**）+ 内容经 **postMessage** 注入（**不** `evaluateJavaScript` 字符串拼接）。**不用** `file://`。配置：非持久 dataStore、专用 `WKContentWorld` 桥、navigationDelegate 取消初始外的一切导航（外链走 `NSWorkspace.open`）。
- [ ] **CSP**（M1 定稿）：`default-src 'none'; connect-src 'none'; img-src 'self' data:; font-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'`。KaTeX 用 `renderMathInElement()`（**别用 auto-render** 的 inline onload，会逼 script unsafe-inline）；Mermaid `securityLevel:'strict'`；Shiki 若上用 v4 纯 JS 引擎（`@shikijs/engine-javascript`, MIT）**避开** `wasm-unsafe-eval`。
- [ ] **渲染件**（D-M1-10）：KaTeX（预览）+ Mermaid（离线打包、CSP 门控、**懒加载**只在有图时）+ 代码高亮 highlight.js（预览区，起步；Shiki 升级）。编辑区代码围栏 M1 只等宽+淡背景。复制按钮 + 语言标签（来自 fence info string / `CodeBlock.language`）。
- [ ] **滚动同步（60fps 双向、无反馈环）**：块级 `data-sourcepos`→排序锚点数组 {element,startLine,top,height}，**每次预览刷新 + 异步 reflow(图片/字体/KaTeX/Mermaid 完成，ResizeObserver)后重建**（陈旧高度是 #1 漂移源）。
  - 编辑→预览：`boundsDidChange`(每帧最多一次)经 **TextKit 2**(`textViewportLayoutController`/枚举可见 rect 的 fragment，**不读 `.layoutManager`**)取顶部源码行 → postMessage {line,fraction} → JS 在 rAF 里二分+线性插值 `scrollTo`。
  - 预览→编辑：webview scroll(每帧一次) 二分锚点插值出源码行 → postMessage → Swift 滚 NSTextView 使该行 fragment 顶对齐。
  - **驱动权模型**（胜过 VS Code 的 scrollDisabledCount）：从用户手势事件测「物理活动 pane」、~150ms 滑窗内只有 driver 发同步；follower 程序化滚动时置 `isApplyingSync`，其 handler 见该 flag 或非 driver 即早返回。
- [ ] **60fps 纪律**：**绝不**每 scroll tick `evaluateJavaScript`（异步跨进程会卡）；合并成每帧一次 postMessage 只带最新值，DOM 滚动在 webview 的 rAF 里做。

**坑**：cmark 若非 swift-markdown 公开产品需单独锁同 revision 依赖 + 处理「重复 target」冲突（D-M1-5 已 spike）；`data-sourcepos` 只到块级——多行代码块内别假装能平滑插值（snap 到块首/尾）；TextKit 2 视口估算高度令大文档顶行读数跳（用 fragment 稳定锚点、加 10k+ 行同步平滑测）；异步 reflow 不重建锚点 = 漂移；驱动窗口错配/`isApplyingSync` 泄漏 = 死循环回来（要确定性测）。

## M1.5 · omnibar + 全文搜索（CJK 硬门）+ 命令面板

> 目标：三面板。前置：内容索引排在 **M1.2 FSEvents 管线之后**。依据 research §6、D-M1-6。

- [ ] **Surface 1 omnibar（搜索=新建）**：内存索引 {文件名/H1/frontmatter alias/mtime}，随文件树惰性填充；fuzzy + frecency；「无匹配 + Return」建新笔记。**Library 一开即可用**（先于内容索引）。
- [ ] **Surface 2 全文内容搜索**：SQLite FTS5 经 GRDB.swift（MIT），**external-content 表**（不复制源码字节），库存 **Application Support**（**绝不写 .db 进 vault**）；首开后台建索引(显进度、omnibar 已可用)，随 FSEvents 事件经哈希去重后 DELETE+INSERT 单文件；存 per-file 镜像表(path,mtime,size,hash) 令冷启只重建变更文件。
- [ ] **CJK 分词器（硬验收门）**：换掉默认 unicode61，用纯 Swift bigram/逐字 `FTS5WrapperTokenizer`（CJK 逐字/bigram、Latin 词照过）；**在真中文语料上测召回/精度，过了才算「搜索做完」**。
- [ ] **Surface 3 命令面板 ⇧⌘P**：**独立**静态命令表，frecency 排序但**稳定不逐键重排**（VS Code 教训），**不与文件混池**。
- [ ] fuzzy scorer：自写小 fzf 式(可控、可 CJK)或 fuse-swift(MIT)；索引/查询全离主线程(§4.1)，GRDB `DatabasePool` 并发读。

**坑**：默认分词器中文**零结果**（静默全崩，核心受众）；索引漂移(漏/错事件)→查询陈旧，要重建/修复路径 + 周期一致性检查；首索引 10k+ 文件别阻塞 omnibar；内存别塞全文(只塞标题/alias，内容在 FTS5 memory-mapped)；主线程 MATCH 掉帧。

## M1.6 · 专注模式 + 打字机滚动

> 目标：写作心流。前置：**M1.0.5a 着色机制** + caret-rect 探针。依据 research §8、D-M1-4、design-direction §4.4。

- [ ] **打字机滚动**（M1 先发这个，更稳）：上下 `textContainerInset` ~半个 clip 高(随视口 resize 重算)令首尾行可居中；`textViewDidChangeSelection`/编辑时**仅**对 caret 附近小范围 `ensureLayout`、经 TextKit 2 text-segment 取 caret 矩形、滚 NSClipView 使 `caret.midY` 落到偏移(默认 0.5)。**别** `relocateViewport`、**绝不**全量 ensureLayout。只在光标位置变/打字触发，不在鼠标拖选；IME marked text 期间抑制。
- [ ] **专注变暗**（spike-gated 的 M1 stretch，redraw bug 咬人就推 M1.5/M2）：基色 = 暗灰（用 M1.0.5a 定的**同一**机制）、focus 范围 = 全墨；光标移动时刷新。保留 scrim overlay 兜底。dim 只到暖灰、**永不 accent**。
- [ ] **focus 范围算**：行=NSString paragraph/line range；句=`NLTokenizer(unit:.sentence)`(只 tokenize caret 附近窗口，setLanguage)；段=NSString.paragraphRange（想 focus 整块如代码块才用 swift-markdown SourceRange）。
- [ ] 两者默认 **OFF**、各自开关（iA 教训：修订时 focus 打架）；尊重 Increase Contrast / Reduce Transparency（关 dim）；toggle 状态**存模型层**（representable 是值类型会重建）。

**坑**：FB9692714 rendering attributes macOS 26 重绘不可靠(M1.0.5a 已选机制/备好 scrim)；全量 ensureLayout 卡秒级；大 `textContainerInset` 触发 AppKit resize 自动居中漂移(要抵消)；IME 组字期重居中抖；任何读 `.layoutManager` 即降级。

## M1.7 · 文件系统版本历史 / 快照

> 目标：本地历史 + 为路线 B checkpoint 打底。前置：M1.1 原子写 + M1.2 自写去重。依据 research §9、D-M1-7。

- [ ] **快照库**（app 容器 Application Support，非 vault）：`History/<fileKey>/entries.json` + 哈希内容 blob；`<fileKey>` 键**稳定 ID/bookmark**（不用绝对路径）。
- [ ] **触发**：每次保存前对**旧内容**留 pre-write 快照(路线 B 种子) + 防抖 on-change 快照；contentHash 去重；最小间隔(~5min)。
- [ ] **保留/prune**：默认 ~7 天或保留 N 份 + 体积上限；启动 + 每次快照后 prune。APFS 同卷 clone 省空间。
- [ ] **Restore 单文件 UI**：per-doc 时间线 + 对当前的 diff 预览；Restore 先快照当前(令 restore 可撤销)再经 L2 undo 入口载入选中版本。
- [ ] **删除** 走 `FileManager.trashItem`（**永不 unlink**）。manifest 带版本号。

**坑**：全内容快照会涨(hash 去重 + clone + 上限)；绝对路径键 vault 一移就丢历史；容器快照**不是备份**(要明说「本地恢复非备份」)；自写快照/保存的 FSEvents 要被去重(否则快照自己的写)；atomic replace 剥 C-flag xattr。

## M1.8 · 两套主题精调 + HTML/PDF 导出

> 目标：落地 design-direction 的两套精品主题 + 导出。前置：**需 macOS 26 真机**（无模拟器）；导出依赖 M1.0.5b。依据 research §10/§11、D-M1-12。

- [ ] **设计令牌**：Asset Catalog color set（每个编辑层令牌显式 Any/Dark：canvas.bg / ink.body / accent / marker.idle@35–40% / marker.active=accent / selection wash / separator / code bg），dynamic NSColor；令牌名镜像成 CodeMirror/MarkEdit 式 theme 对象令编辑器主题与预览 CSS **共用一套 schema**。chrome 只用系统语义色。
- [ ] **caret + rubric**：terracotta caret 先用 `insertionPointColor`（要 hairline 才 override `drawInsertionPoint`）；选区 `selectedTextAttributes[.backgroundColor]` 暖 accent@12–15%；marker 上色在 `textDidChange` 不在 `processEditing`（会移 caret）；光标行 active marker 用 M1.0.5a 机制。
- [ ] **字体**（D-M1-12）：打包 IBM Plex Mono(OFL) 默认、可选 iA Writer Duospace；**不打包 New York**(预览 `ui-serif`、AppKit `withDesign(.serif)`)；附各 OFL.txt。
- [ ] **贴合 + 玻璃**：标准组件自动 Liquid Glass；显式 `glassEffect` 只在 `if #available(macOS 26,*)` + macOS 15 fallback + 查 Reduce Transparency；出 Tahoe `.icon`。**真机验**暗色 accent(#D2674F 起) + 全部玻璃/fallback。
- [ ] **暗色卫生**：绝不缓存 CGColor；属性 run 显式设 dynamic foregroundColor(不设暗色变黑)；`viewDidChangeEffectiveAppearance` 丢缓存。
- [ ] **PDF 导出**（主路径）：离屏 WKWebView 载 export HTML → 等 `didFinish` **且** Mermaid/KaTeX 渲染完(JS promise/flag 轮询) → `printOperation(with:)`、`jobDisposition=.save`、**先设 `op.view.frame`**、`runOperationModalForWindow`（**不用** `runOperation`、**不用** `createPDF()`——整文档挤一页）；print stylesheet(`@page` size/margin)；可选 PDFKit 注 heading 大纲书签。
- [ ] **HTML 导出**（自包含）：同样等渲染完 → `document.documentElement.outerHTML` 抓全渲染静态 HTML → 内联 CSS(可选图片 data: URI)，离线且与预览一致。
- [ ] 导出 WebView **严格下游**，绝不回写 DocumentModel。

**坑**：rubric 光标行高亮依赖 M1.0.5a（失败退逐 run）；terracotta 近 red=error 语义——严格只限 caret+结构标记+勾选闪(Code review 守)；macOS 26 无模拟器全靠真机；`createPDF()` 单页陷阱(编码成 guardrail + >1 页测)；捕获早于 Mermaid/KaTeX 完成 = 半渲染。

## M1.9 · 发布自动化 + Sparkle + Homebrew（M1 收官，补齐 M0 DoD#5）

> 目标：发首个 public release、`brew install` 可装、Sparkle 能检查更新。前置：M1.0 已生成 EdDSA 私钥并写好 SUFeedURL。依据 research §11、[M0/sparkle-setup.md](../M0/sparkle-setup.md)、D-M0-1/5。

- [ ] 配 GitHub secrets（Developer ID `.p12`、ASC API `.p8`、Homebrew PAT、`SPARKLE_ED_PRIVATE_KEY`）。
- [ ] `release.yml`（`on: push: tags: ['v*']`）：临时 keychain 导证书(`set-key-partition-list`) → `xcodebuild archive`+`-exportArchive`(inside-out 签、**不 `--deep`**) → 签嵌套码 → notarytool submit --wait → stapler → `create-dmg`(8.1.0) → 签+公证 DMG → `generate_appcast --ed-key-file`(EdDSA) → 用 Release body 作 release notes 渲 appcast.xml → 发 Release + 挂 DMG + 发 appcast。
- [ ] 按 [M0/sparkle-setup.md](../M0/sparkle-setup.md) 接 Sparkle（方案 A：`SUEnableDownloaderService=YES`、app 不加 `network.client`；entitlements 加 `-spks`/`-spki` mach-lookup 例外；`SPUStandardUpdaterController` 接线）。
- [ ] Homebrew：建 `colophon-app/homebrew-tap`，cask token `colophon`，`livecheck{strategy :sparkle}` 指 SUFeedURL，**`auto_updates true`**（Sparkle 自更新，现强制）；`brew audit --cask --online` + `brew style`。
- [ ] 另一台 Mac 验：`spctl`(Notarized) + `stapler validate` + 双击开 + `brew install --cask colophon-app/tap/colophon` + Sparkle 检查到更新 → **补齐 M0 DoD#5、M1 发版闭环**。

**坑**：EdDSA 私钥丢=再签不出更新(异地备份)；`createPDF`/`--deep` 陷阱;`printOperation` 未设 frame 会 EXC_BREAKPOINT(macOS 26)；cask 缺 `auto_updates true`/stanza 顺序错会被 audit 拒;DMG 既作 Sparkle enclosure 又作 Homebrew 下载(一件产物两用)。

---

## 跨阶段贯穿件（MUST，勿当可选）

research §15 批判补的盲区，散进上面各阶段，这里汇总盯：

- [ ] **AST-as-API 缝**（DoD#3，M1.0 定签名）：L2 的 `DocumentReader`/`DocumentEditor`/`ActiveEditorState` 占位接口**编译通过 + 有测试**（architecture §7.2）；MVP 不实现 AI，只占位对齐。
- [ ] **多文档/标签模型**（gates M1.2 的 per-tab presenter）：多文件如何打开(标签?窗口?)、状态恢复、侧栏与开档关系——在 M1.1 定形。
- [ ] **设置持久化**（≥5 个功能依赖）：主题/专注开关/附件目录规则/快照保留/字体/防抖窗——一个设置 UI + 持久存储（`UserDefaults`/容器），随各功能增量加。
- [ ] **无障碍**（PRD「完全贴合 macOS」）：自定义 TextKit 2 NSTextView 的 VoiceOver 暴露、全键盘访问、动态字体；对比度/Reduce Transparency 已在 M1.6/M1.8。
- [ ] **测试与验收基线**（整个 DoD 是测试门）：Moby Dick 不掉帧的测法、byte-exact CRLF/BOM/无末尾矩阵、能开 Obsidian vault、CJK 搜索有结果——建统一 harness + 明确 pass/fail 值（别散成风险）。

---

## M1 完成定义（DoD 总核对）

- [ ] #1 **作者本人每天用它写** README/`CLAUDE.md`/本项目所有 `.md`（真 dogfooding）。
- [ ] #2 编辑核心可用：源码样式化 + `⌘\` 分屏且滚动不晕 + GFM/数学/Mermaid/代码在预览正确 + 语义快捷键与智能列表。
- [ ] #3 路线 B 的门：Agent 文件识别 + byte-exact(回归绿) + 外部改盘即时刷新无弹窗 + AST-as-API 缝占位(编译+测试)。
- [ ] #4 发首个 public release：签名公证 `.app` 上 GitHub Releases、`brew install --cask` 可装、Sparkle 能检查更新。
- [ ] #5 性能可靠：大文档打字不掉帧、分屏滚动稳、byte-exact/原子写/无数据丢失回归全绿、能开 Obsidian vault、CJK 搜索有结果。

## 分工

- **Evan**：跑 build / 在 macOS 26 真机验收(玻璃/暗色/PDF/rubric) / 配 GitHub secrets / 生成 & 异地备份 Sparkle EdDSA 私钥 / Xcode GUI(加 package: swift-markdown、GRDB.swift、HighlighterSwift、Sparkle) / 每个阶段的 dogfooding 反馈(哪不顺手)。
- **Claude 可代写**：全部 Swift 源码(内核样式化、L2 模型/编辑原语、L4 预览/同步、L5 文件监听/原子写/快照、搜索、专注/打字机、主题/导出)；`release.yml`；改 `dependencies-and-licenses.md`；扩 byte-exact 测；spike 分支脚手架 + 决策回填。
