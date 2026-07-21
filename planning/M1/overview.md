# M1 · MVP —— Overview

> 依据 [PRD §5.1 / §7 / §8](../PRD.md)、[ROADMAP §3](../ROADMAP.md)、[standards/architecture.md](../standards/architecture.md)（尤其 §8 内核 spike、§9 留到实现的 12 条）、[standards/design-direction.md](../standards/design-direction.md) 与 [standards/ui-and-design.md](../standards/ui-and-design.md) 提炼。
> 本文固化 M1 的目标 / 范围（做·不做）/ 完成定义 / 依赖；调研见同目录 [`research.md`](./research.md)，可照做步骤见 [`plan.md`](./plan.md)，过程决策记入 [`decisions.md`](./decisions.md)。
> **接续 M0**：M0 交付了「能开/编/存一个 `.md`、已签名公证、CI 绿、i18n+隐私就位」的空壳（[M0/summary.md](../M0/summary.md)）。M1 把这个空壳变成**作者本人愿意每天用来写 README / `CLAUDE.md` 的编辑器**。

## 目标

立住四个形容词——**原生、简洁、好看、可靠**——并**留好 AI 的门**（路线 B 的架构缝）。
**唯一判断标准 = dogfooding：作者本人愿意每天用它写东西**（ROADMAP §3）。不是功能齐全，是「顺手到不想切回旧工具」。

## 开局即龙头：编辑内核起点 spike（D1，决定其余一切）

M1 的第一件事不是写功能，是**拍板编辑内核的实现起点**（PRD §12.4、architecture §8）。三候选：
- **(a) fork / 借鉴 `swift-markdown-engine`**（Apache-2.0，架构与我们一致，最快到 M2 混合渲染；风险：pre-1.0、单点维护）。
- **(b) 从零自研 `NSTextView` + TextKit 2 薄封装**（最可控、最慢，「岩浆池」风险自担）。
- **(c) 先用 `CodeEditTextView`（MIT）做源码模式起步**（成熟、快，但为源码编辑器而非 Markdown 混合渲染而生，M2 可能要换）。

**这条决策 gate 住 architecture §9 的绝大多数实现细则**（TextKit 2 细则、是否引 tree-sitter、undo 整合方式…）。`research.md` 的首要任务就是把三候选的 2026 现状查清、给出**带 spike 设计的推荐**；最终以一次**小型 hands-on spike**（PRD §12.4「先 spike 对比 a 与 c」）落锤，记入 `decisions.md`。**契约不变**：无论选哪条，都必须满足 architecture §1–§7（分层、byte-exact+原子写、双轨解析、undo 入口在模型层、TextKit 2 红线、AST-as-API 缝）。

## 范围（做）—— 对齐 PRD §5.1

### A. 编辑核心
- **源码编辑 + 语法样式化**：标题变大、粗体变粗、标记符**保留但视觉弱化**（**不是**混合渲染——混合渲染是 M2）。落地 design-direction 的「rubric red」批注系统（terracotta `#B23A28` 限定在光标 + 光标行标记符）。
- **`⌘\` 一键分屏实时预览 + 60fps 双向滚动同步**（`WKWebView`，L4）。这是混合渲染做出来前的「逃生舱」，让 MVP 立刻可用。
- **GFM 全家桶（表格 / 任务列表 / 删除线 / 脚注）+ LaTeX 数学 + Mermaid + 代码块高亮做成一等公民**（复制按钮、语言标签、质量）。
- **Markdown 语义快捷键**（`⌘B`/`⌘I`/升降标题/勾选任务）+ **列表续行与编号自动修复**——每步都必须满足 byte-exact + undo 入口在模型层。
- **图片粘贴 / 拖拽自动落盘**（目录规则可配）+ **选中后粘贴 URL 自动成链接**。

### B. 文件与组织
- **本地文件夹即文库**（M0 已有基础：security-scoped、无账号、无私有格式）——补齐懒加载、支撑 10k+ 文件流畅（architecture §2.3）。
- **omnibar（搜索与新建合一）+ 全文搜索**；**命令面板（`⇧⌘P`）**。
- **自动保存 + 基于文件系统的版本历史**（存 app 容器，不污染用户文件夹；删除进废纸篓，永不硬删）。

### C. 体验与外观
- **专注模式（行 / 句 / 段可选）+ 打字机滚动**。
- **深浅色主题各一套精调**（落地 design-direction：暖纸 canvas `#F4EDDD` / light `#FBFAF6` / dark `#1C1B19`、typography-state、rubric red）+ **完全贴合 macOS 规范**（原生工具栏、系统控件、自动深浅色、SF Symbols；Liquid Glass 只上 chrome、编辑区非玻璃、显式玻璃 API `if #available(macOS 26,*)` 门控）。
- **导出 HTML / PDF**（走系统 WebKit / PDFKit，不走 TextKit 打印）。

### D. 路线 B 的「门」（MVP 最特别的部分：留缝，不做具体 AI）
- **Agent 文件一等公民 + byte-exact 保存**：byte-exact **M0 已达成**；M1 补**数据驱动的 Agent 文件识别表**（`CLAUDE.md`/`AGENTS.md`/`*.mdc`/`SKILL.md`/`llms.txt`…，特别渲染，architecture §2.2）。
- **文件监听、无「已在磁盘更改」弹窗**：FSEvents（文库级）+ `NSFileCoordinator`/`NSFilePresenter`（单文档协调）+ **自触发去重**；无脏冲突静默刷新，有脏冲突给 Reload / Ignore / Compare（architecture §3.3）。
- **架构缝：AI = 语法树上的操作**：按 architecture §7.2 在 L2 **只划 `DocumentReader`/`DocumentEditor`/`ActiveEditorState` 的边界占位**，对齐 `swift-markdown` 的 SourceRange/AST——**现在只划边界，不实现任何 AI**。

### E. 工程与发布
- **发布自动化 + Sparkle 自更新**（M0 延后的 **D-M0-5**，就近在 M1 收官时补齐：`release.yml` + appcast + Sparkle）——见 [M0/sparkle-setup.md](../M0/sparkle-setup.md)。
- **首个 public release**：GitHub Releases + **Homebrew cask**（自建 tap `colophon-app/tap`）。
- **崩溃即修的小步发版**；季度小发版信号。

## 范围（不做 —— M1 明确排除）

- **行内混合渲染**（太难，**M2**；M1 用「源码样式化 + 分屏预览」顶着，避开「岩浆池」死亡螺旋）。
- **任何具体 AI 功能**（还没想清楚，靠 dogfooding 发现；MVP 只留缝）。
- **wiki 链接 `[[…]]` / 反向链接**（笔记场景，M2）。
- **主题生态 / 主题画廊 / 中文排版 / Pandoc 复杂导出 / 内置 MCP server**（M2/M3）。
- **frontmatter 表单化 / glob 感知 / 逐 hunk diff 审阅**（V1 = M2）。
- **移动端 / 实时协同 / Windows·Linux**（几乎所有竞品差评重灾区，桌面站稳再说）。

## 完成定义（DoD）

1. **作者本人每天用 Colophon 写 README / `CLAUDE.md` / 本项目所有 `.md`**（真·dogfooding，主观但硬——不顺手就没达成）。
2. **§5.1 编辑核心可用**：源码样式化 + `⌘\` 分屏预览且滚动同步不晕 + GFM/数学/Mermaid/代码高亮在预览里正确渲染 + 语义快捷键与列表智能续行работают。
3. **路线 B 的门装好**：Agent 文件识别 + byte-exact（回归测试守住）+ 外部改盘即时刷新无弹窗 + AST-as-API 缝的接口占位已就位（编译通过、有测试）。
4. **发首个 public release**：签名公证的 `Colophon.app` 上 GitHub Releases，`brew install --cask colophon-app/tap/colophon` 可装；Sparkle 能检查到更新（补齐 M0 DoD#5）。
5. **性能与可靠**：大文档（如《白鲸记》级）打字不掉帧、分屏滚动稳定；byte-exact / 原子写 / 无数据丢失回归测试全绿；能打开 Obsidian vault（成功标准③）。

## 关键已定决策（进 M1 即生效，来自 architecture）

分层六层 + 依赖单向向下 · 源码字符串为**唯一权威表示**（AST 是可重算派生态）· 文件夹即文库（不用 `NSDocument`）· byte-exact + 原子写 + 外部变更协调是**生死线** · 双轨解析（tree-sitter 增量高亮 / swift-markdown 全量 AST）· **undo 入口在模型层 L2** · TextKit 2 禁触 `.layoutManager` · 导出走 WKWebView/PDFKit 不走 TextKit · AST-as-API 缝（§7.2 接口形状已定，签名待 spike）· 编辑区非玻璃、chrome 可玻璃。

## 待 M1 内决策（`research.md` 输入、`decisions.md` 落锤）

来自 architecture §9 的 12 条，M1 相关的重点：
1. **编辑内核起点 (a)/(b)/(c)**（龙头，spike 后定）。
2. **M1 是否引入 tree-sitter**，还是先用「swift-markdown 全量 AST 驱动的属性映射」做源码样式化顶着。
3. **代码块高亮方案**（编辑区 vs 预览区分别用什么：Highlightr / tree-sitter / Shiki-in-webview）。
4. **分屏预览的 HTML 管线与滚动同步算法**（sourcepos ↔ DOM 映射、防反馈环、60fps）。
5. **全文搜索 / 懒加载索引策略**（内存 vs SQLite FTS5 vs 系统 CoreSpotlight）。
6. **版本历史实现**（本地快照目录 vs 内置 Git）。
7. **原子写 API 终选**（`Data.write(.atomic)` vs `NSFileCoordinator` 协调写）+ xattr/权限保留。
8. **FSEvents 自触发去重机制**（mtime+size vs 内容 hash vs 写入标记）。
9. **专注模式/打字机滚动在 TextKit 2 上的实现**（rendering attributes 变暗 vs 其它）。
10. **字体与许可**（iA Writer Duo=OFL、New York=系统、IBM Plex Mono=OFL 的**打包与商用授权终核**）。

## 依赖与外部前提

- **一次 hands-on 内核 spike**（M1.0）——落锤 D1，回填 architecture §8/§9。
- **发布自动化的 secrets**（M0.4 计划里已列：Developer ID `.p12`、ASC API key、Homebrew PAT）+ **Sparkle EdDSA 私钥需 `generate_keys` 生成并异地备份**（见 [M0/sparkle-setup.md](../M0/sparkle-setup.md)）。
- **macOS 26 真机**测 Liquid Glass（无模拟器）。
- **字体授权终核**（见待决 #10）——动 UI 前定，避免发布期返工。

## M1 与后续里程碑的接口

- M1 的「源码样式化 + 分屏预览」是 M2 **行内混合渲染**的前身；内核 spike 选 (a) 会让 M2 最省力。
- M1 划好的 AST-as-API 缝（L6 占位）是 M2 **Agent Skills**、M3 **MCP server** 的对接点——「插进来而非拆开重做」。
