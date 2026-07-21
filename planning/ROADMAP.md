# Colophon · 开发路线图（ROADMAP）

> 配套文档：[PRD.md](PRD.md)（做什么 / 为什么 / 给谁 / 范围 / 定位）。
> 本文回答：**分几个阶段、每阶段的目标与「完成定义」、以及每个排期决定背后的理由**。
> 版本 v0.1 · 2026-07-21 · 依据 [`../docs/`](../docs/) 调研（尤其 09/13/19）与 PRD 撰写。

---

## 0. 一句话与阶段总览

**Colophon = 面向开发者的原生 macOS Markdown 编辑器——好看得不像开发者工具；开源免费、专注克制，并成为「人 ↔ AI Agent 的 Markdown 界面」。**

| 阶段 | 目标 | 完成定义（DoD） |
|---|---|---|
| **M0 立项骨架** | 工程地基就位 | 能可靠开/编/存一个 `.md`，且 build 出的 app 已签名公证、能在别人机器上双击打开 |
| **M1 MVP** | 立住「原生、简洁、好看、可靠」，并**留好 AI 的门** | 作者本人每天用它写 README/`CLAUDE.md`；发首个 public release，`brew install` 可装 |
| **M2 V1** | 立住差异化：行内混合渲染 + 路线 B 落地 | 路线 B 至少一环（Agent Skills）被真实用于「让 Claude Code/Cursor 操作自己的文库」；出现第一个第三方主题 |
| **M3 V2** | 生态纵深：内置 MCP server 等 | 按 dogfooding 发现的真实需求排序落地 |

---

## 1. 排期哲学（为什么这样分阶段）

四条贯穿全程的决策逻辑，每条都有调研依据。

**① 难/险的东西渐进增强，不梭哈。**
Markdown 编辑器最难、最险的是**行内混合渲染的编辑内核**（Typora 那种输入即渲染）。原生实现要啃 TextKit 2，调研估从零 **6–12 人月**，业界称其为「岩浆池」（[`../docs/09`](../docs/09-tech-stack.md)），连 Bear 都自研 C++ 内核。一上来就啃它，极易陷入**「推倒重写」死亡螺旋**（WriteMonkey、Caret 4.0、HedgeDoc 2.0 都死在重写上，[`../docs/03`](../docs/03-windows-legacy.md)）。所以采用「**方案 C 先发货、方案 A 做终态**」：先用「源码 + 分屏预览」做出能日用的 MVP，收集用户、开始 dogfooding，**再把混合渲染当"增强"逐步加上**，而不是一次性梭哈。

**② AI 先留门，靠 dogfooding 发现。**
「还不确定 AI 具体做什么」是正确的克制，不是缺陷（[`../docs/19` §8](../docs/19-route-b-blueprint.md)）。硬在 MVP 拍板 AI 功能，容易掉进 **Trilium 那种「内置多供应商 AI 后维护不可持续、只能整个移除」的黑洞**（[`../docs/04`](../docs/04-open-source-knowledge-bases.md)）。正解：把 AI 设计成**语法树上的操作**、与编辑内核解耦，MVP 只留架构缝，功能靠 dogfooding 慢慢长出来。

**③ 路线 B 先做 Skills，再做 MCP server。**
Agent Skill 就是 `.claude/skills/` 下一个 Markdown 文件夹——**零 server、零 API、零后端，还能被 30+ Agent 复用**（[`../docs/16`](../docs/16-agent-skills.md)）。它用最低成本兑现路线 B。内置 MCP server 重得多，且 Clearly「加了 9 个工具又全删」的教训提示需求可能被高估，留到 V2 用真实需求验证。

**④ 范围克制是第一功能。**
不做终端/RAG/PKM/白板/同步/私有格式（[`../docs/13` §7](../docs/13-product-opportunities.md)、[`../docs/19` §7](../docs/19-route-b-blueprint.md)）。**功能膨胀是这类产品的头号死法**（Clearly 加满又删光是活体教训）。克制本身就是相对那一整簇臃肿新品的最大差异化。

---

## 2. M0 · 立项骨架

**目标**：不追求功能好用，只追求「地基正确」。

**做什么**
1. 建仓库结构：GitHub org `colophon-app` + repo `colophon`（public），第一个 commit 就带 **Apache-2.0** LICENSE。
2. README（含产品宣言 + 两条不可回撤承诺：永久开源、本地 `.md` 唯一真相源）、`.gitignore`（Xcode/Swift）、CONTRIBUTING、多维护者治理声明。
3. 仓库自己的 `AGENTS.md` / `CLAUDE.md`（第一天就 dogfood 路线 B）。
4. Xcode 工程：SwiftUI App 生命周期，最低目标 **macOS 15.0**，用**最新 Xcode（26 SDK）**编译；`NavigationSplitView` 三栏骨架；编辑区用 `NSViewRepresentable` 桥接一个空 `NSTextView`，能开/编/存 `.md`；深浅色跟随系统。
5. CI（GitHub Actions：每 PR build + test）+ **签名公证流水线**，趁 app 还是空壳时跑通。
6. 把 `../docs/`（20 份调研）与 `planning/` 归位进仓库。

**完成定义**：能可靠打开、编辑、保存一个 Markdown 文件，且 build 出的 app 已签名公证、能在别人机器上双击打开。

**为什么这些、这个顺序**
- **先把不可回撤的承诺（开源、数据格式）和最烦的工程流水线（签名公证、CI）在成本最低时锁死**，再写功能。开源承诺一旦公开不可回撤（Notable 转闭源两头落空，[`../docs/13` §7.2](../docs/13-product-opportunities.md)）；**没签名公证的 Mac app 对普通用户等于打不开**（MarkFlowy 的 `xattr` 劝退，[`../docs/02`](../docs/02-cross-platform.md)）；CI 早搭是几分钟、晚搭是噩梦（CuteMarkEd 被打包压垮，[`../docs/03`](../docs/03-windows-legacy.md)）。
- **M0 就引入 `NSTextView` 而非图快用 SwiftUI `TextEditor`**：后者天花板太低（做不到语法隐藏/行内 widget），迟早要换；先把「原生文本视图 + SwiftUI 壳」的桥接骨架搭对，避免返工（[`../docs/09`](../docs/09-tech-stack.md)）。

---

## 3. M1 · MVP

**目标**：立住「原生、简洁、好看、可靠」，并留好 AI 的门。**判断标准 = 作者本人愿意每天用它写东西（dogfooding）。**

### 3.1 编辑核心
- **源码编辑 + 语法样式化**（标题变大、粗体变粗，标记符保留但视觉弱化）。为什么是这个形态而非直接上混合渲染：体验已不错但原生成本可控，**回避完整混合渲染的深坑**（妙言放弃、Bear 为此自研内核，[`../docs/01`](../docs/01-apple-native.md)）；「语法可见的就地渲染」对程序员本就有吸引力。
- **`⌘\` 一键分屏实时预览 + 双向滚动同步**。它是混合渲染做出来前的「逃生舱」，让 MVP 立刻可用；技术走 `WKWebView`（也是 Mermaid/公式唯一能跑的地方）。
- **GFM 全家桶 + LaTeX + Mermaid + 代码块高亮（做成一等公民）**。这套「技术写作全家桶」2015 年就是标配预期（[`../docs/03`](../docs/03-windows-legacy.md)）；代码块因用户是开发者，做到一等公民（复制按钮、语言标签、质量）。

### 3.2 文件与组织
- **本地文件夹即文库**（自选文件夹，无账号、无私有格式），靠 iCloud/网盘天然同步。为什么不自建同步：Laverna 死于自建同步（[`../docs/03`](../docs/03-windows-legacy.md)）；数据主权是核心卖点。
- **omnibar（搜索与新建合一）+ 全文搜索 + 命令面板（`⇧⌘P`）**。笔记型编辑器最高效入口；命令面板用极低 UI 成本聚合功能、维持极简。

### 3.3 体验与外观
- **专注模式 + 打字机滚动**。写作心流功能，原生成本低、差异化感知强。
- **深浅色主题各一套精调 + 完全贴合 macOS 规范**。先做两套精品胜过堆主题；用标准 SwiftUI/AppKit 组件，**macOS 26 上自动获得 Liquid Glass、macOS 15 上自动回退**（详见 [PRD.md](PRD.md) §7）。编辑区（内容层）保持非玻璃、可读（Apple 官方指导）。
- **导出 HTML / PDF**（系统 WebKit/PDFKit）。不自研复杂导出（[`../docs/07`](../docs/07-ide-terminal.md) 结论）；DOCX/EPUB 以后接 Pandoc。

### 3.4 路线 B 的「门」（MVP 最特别的部分：留缝，不做具体 AI）
- **Agent 文件一等公民 + byte-exact 保存**：识别 `CLAUDE.md`/`AGENTS.md`/`.mdc`/`SKILL.md`，**关闭智能引号/破折号替换**。这是核心用户故事——智能标点会破坏 `.mdc` frontmatter 与代码围栏，Agent 配置文件对字节保真极敏感。几乎零成本却直接兑现「给写 Markdown 的开发者做的编辑器」。
- **文件监听、无「已在磁盘更改」弹窗**：Agent 改盘上文件即时刷新（macOS FSEvents）。这是路线 B 的最低门槛——缺它，Agent 一改文件就弹窗打断，整个循环不成立。
- **架构缝：所有文档操作设计成「语法树上的操作」**（`swift-markdown` 的 AST/SourceRange）。现在只划 API 边界、不实现任何 AI；未来 Skills/MCP/BYOK 都对齐这套语法树 API，是「插」进来而非「拆」开重做。

### 3.5 明确不进 MVP（以及为什么）
混合渲染（太难，M2；先用分屏顶着）；任何具体 AI 功能（还没想清楚，靠 dogfooding 发现）；wiki 链接/反链（笔记场景，M2）；主题生态、中文排版、Pandoc、MCP server（M2/M3）；移动端（几乎所有竞品的差评重灾区，桌面站稳再说，[`../docs/05`](../docs/05-note-apps.md)）。

### 3.6 M1 技术栈（依据 [`../docs/09`](../docs/09-tech-stack.md)）
SwiftUI 壳（`NavigationSplitView`）＋ `NSTextView`(TextKit 2) 薄封装编辑区 ＋ `swift-markdown` 解析 ＋ `WKWebView` 分屏预览/导出 ＋ 代码块 Highlightr 起步。**编辑内核起点（fork `swift-markdown-engine` vs 从零 vs 用 CodeEditTextView）留到 M1 内做 spike 再定**（[PRD.md](PRD.md) §12.4）。

---

## 4. M2 · V1（立住差异化）

**目标**：把结构性差异化立起来——行内混合渲染 + 路线 B 落地 + 主题生态。

**范围**（详见 [PRD.md](PRD.md) §5.2）
- **行内混合渲染**（anti-conceal 三态：源码/实时/阅读），评估以 `swift-markdown-engine`（Apache-2.0）为起点或上游。
- **随产品自带官方 Agent Skills**——零 server 兑现路线 B（先做这个，不做 MCP server）。
- frontmatter 表单化 + glob 感知 + 多文件规则管理；外部 Agent 改动内联 diff + 逐 hunk accept/reject + 统一审批；spec/tasks 渲染 + 任务复选框 + checkpoint。
- 主题即一个样式文件 + 官方主题画廊；`[[wiki 链接]]` + 反向链接。

**完成定义**：路线 B 至少一环（Agent Skills）被真实用户用于「让外部 Agent 操作自己的文库」；社区出现第一个第三方主题。

**为什么在这里**：差异化功能重、且依赖 MVP 的用户反馈来校准；混合渲染是「增强」而非「重写」，风险集中在编辑器内核一个点上，尽早原型验证。

---

## 5. M3 · V2（生态纵深）

**目标**：把最重的东西留到需求被验证后再做。

**范围**（详见 [PRD.md](PRD.md) §5.3、[`../docs/19` §四](../docs/19-route-b-blueprint.md)）
- **内置 MCP server**（stdio 为主）：基线七件套 + **`apply_edit` AST 结构化编辑（独占）** + 暴露活动编辑器状态 + 三原语齐用。
- 三方合并；本地被动「相关笔记推荐」（轻量 RAG）；Skill 画廊（装前强制源码审阅）；`llms.txt` 生成；AI 文本标注（Authorship）；JSON Canvas 互操作。

**完成定义**：按 dogfooding 发现的真实需求排序落地（[`../docs/19` §8](../docs/19-route-b-blueprint.md) 的 8 个开放问题逐个验证）。

---

## 6. 贯穿全程的原则

- **Dogfooding**：自己用 Colophon 写本项目所有 `.md`；每次「要是编辑器能帮我做这个就好了」的瞬间 = 一条真实需求。
- **季度小发版**：向社区传递「项目活着」的信号（[`../docs/03`](../docs/03-windows-legacy.md) 教训）。
- **最难点尽早原型**：TextKit 2 混合渲染在 M1 就做 spike，别拖到 M2 才发现做不动。
- **系统原生组件免费继承 Apple 设计演进**：Liquid Glass 自动适配（macOS 26 生效 / 15 回退）是 Electron 结构上做不到的护城河——多用标准组件、少自绘 chrome。
- **窗口期意识**：`swift-markdown-engine` 已把原生混合渲染门槛打下来，同类新品在扎堆（[`../docs/18`](../docs/18-agent-editor-competitors.md)）；结构性差异化（原生 + 开源 + 路线 B）要在 V1 完整立起来。

---

## 7. 本路线图如何与每个里程碑文件夹配合

进入某个里程碑时，在 `planning/` 下建 `Mx/`，把该阶段信息固化进去（`overview.md` / `research.md` / `plan.md` / `decisions.md`）。**调研按需、逐阶段做，不一次性全做**。完整约定与流程见 [README.md](README.md)。
