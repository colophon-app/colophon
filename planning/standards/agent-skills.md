# 开发规范 · Agent Skills / Claude Code 插件推荐清单

> **场景**：用 Claude Code 开发 **Colophon**（原生 macOS、SwiftUI 壳 + AppKit `NSTextView`(TextKit 2) 桥接 + swift-markdown 解析 + WKWebView 预览、最低支持 macOS 15、用 macOS 26 SDK 编译）。本文只针对「开发这个 app」这一件事，甄选**可信、用得上**的 skill / 插件，产出推荐清单。
>
> 相关背景与机制细节见 [`../../docs/16-agent-skills.md`](../../docs/16-agent-skills.md)。本文是「装什么」的执行清单，docs/16 是「skill 是什么」的原理篇。

---

## 0. 安全原则（先读，硬约束）

引 [docs/16 §五](../../docs/16-agent-skills.md)：**skill = 在你机器上跑的软件**。一个 skill 通过「指令 + 可执行脚本」赋予 Agent 新能力，恶意 skill 能指使 Agent 以偏离其声明用途的方式读文件、发网络请求、跑代码，导致数据外泄或越权。因此本清单的每一条都服从三条铁律：

1. **只装可信来源。** 优先级：Anthropic 官方 > 业内知名个人/机构（署名、可核实身份、社区口碑）> 其它。**无署名的聚合站列表（mcpmarket、随意的 marketplace 条目）一律不装**，哪怕功能听起来正好。
2. **安装前逐文件审阅源码。** `SKILL.md`、`scripts/`、`references/`、`assets/` 都要看，重点警惕「与声明用途不符」的网络调用 / 文件访问。**会执行本地脚本的 skill 风险更高**（本清单已逐条标注哪些带脚本）。注意攻击可延迟触发（按日期/环境变量/使用次数才发作），测试环境跑一遍干净≠安全——所以要读代码，不能只跑一次。
3. **本文只做推荐，不代为安装。** 所有安装动作（`/plugin install`、`npx skills add`、把文件夹拷进 `.claude/skills/`）都会下载并让 Agent 执行外部代码，**必须由你（Evan）本人确认后手动执行**。Skill 不在 ZDR 覆盖范围内。

> **安装路径提醒（Claude Code 特有的坑）**：`npx skills add`（Vercel Labs `skills.sh` CLI）当前有一个已知 bug——全局装（`-g`）会写到 `~/.agents/skills/`，而 Claude Code 只读 `~/.claude/skills/`，两个目录不互通，装了会「Unknown skill」。对策：加 `--agent claude-code` 定向、装完确认目录、或直接手动把 skill 文件夹拷进项目 `.claude/skills/`。能用 `/plugin marketplace add` 的就优先用插件路径。

---

## 先说结论：Claude Code 已内置的相关能力（零安装）

装任何第三方 skill 之前，先记住这几个**已随 Claude Code 提供、无需安装**的斜杠命令——它们覆盖了「代码审查 / 安全审查 / 精简 / 初始化」这几个维度，很多第三方 skill 是在重复造它们：

- **`/security-review`** —— 官方 AI 安全审查，扫当前分支未提交改动的漏洞。**这是本项目「安全审查」维度的首选，零安装。**
- **`/code-review`** —— 审查当前工作区 diff（找 bug）。
- **`/review`** —— 审查一个 GitHub PR。
- **`/simplify`** —— 对改动做复用/简化/效率清理（只做质量，不找 bug）。
- **`/init`** —— 生成 `CLAUDE.md`。
- **原生 git 集成** —— Claude Code 本就会读 repo、按 diff 写提交信息、开 PR。**因此不需要装第三方 git/commit skill**（见第三档）。

结论：**Swift/macOS 领域知识**是内置能力补不了的短板，也是第三方 skill 最该补的地方；审查/git/精简则基本靠内置 + `CLAUDE.md` 约定即可。

---

## ① 建议安装（高信任、高相关）

### 1. `twostraws/swift-agent-skills` —— Paul Hudson 的 Swift 技能合集

- **来源**：<https://github.com/twostraws/swift-agent-skills>（另有拆出的单技能仓库 `twostraws/swiftui-agent-skill`，内含 `swiftui-pro`）
- **做什么**：40+ 个人工撰写的 agent skill，覆盖 SwiftUI、SwiftData、Swift Concurrency、Swift Testing、Accessibility、App Intents、Architecture、Security、Widgets 等；iOS/macOS 通吃。教 Agent 避开写 Swift 时的常见错误（现代 API、性能、可访问性）。以 Markdown 指令为主。
- **为什么对本项目有用**：Colophon 是纯 Swift 6 + SwiftUI + 现代并发的原生 app，Swift Concurrency（actor/Sendable，桥接 `NSTextView` 时尤其要小心线程）和 Swift Testing 两块直接对口。**按需只装你要的子技能**，不必全装。
- **信任度**：★★★★★。作者 Paul Hudson（Hacking with Swift）是 Swift 社区最知名的教育者之一；仓库明确要求「人写、非 AI 生成、作者 GitHub 已验证、许可证兼容 App Store」，署名可核实。MIT（仓库整体；个别子技能各自许可，注意 GPL 系不兼容 App Store）。约 2.3k stars（以仓库为准）。
- **安全性**：以指令型 Markdown 为主，风险低；仍应对要装的具体子技能过一眼源码。
- **安装（供你确认后手动执行）**：单技能示例 `npx skills add https://github.com/twostraws/swiftui-agent-skill --skill swiftui-pro --agent claude-code`；或浏览合集挑子技能、手动拷进 `.claude/skills/`。

### 2. `AvdLee/SwiftUI-Agent-Skill` —— SwiftLee 的 SwiftUI/macOS 性能技能

- **来源**：<https://github.com/AvdLee/SwiftUI-Agent-Skill>（技能名 `swiftui-expert-skill`）
- **做什么**：SwiftUI 最佳实践 + **专门的 macOS 章节**（scenes、window styling、`Table`、`HSplitView`、**AppKit interop**）、**Liquid Glass（iOS/macOS 26）**、deprecated→modern API 迁移指南。**并自带一套可执行 Python 工具链**（`record_trace.py`/`analyze_trace.py`）包装 `xctrace`，让 Agent 录制并分析 Instruments trace，诊断卡顿/掉帧/昂贵的 SwiftUI 刷新。
- **为什么对本项目有用**：这是清单里**与 Colophon 架构最贴合**的一个——我们正是「SwiftUI 壳 + AppKit `NSTextView` 桥接」，且要「用 macOS 26 SDK 自动适配 Liquid Glass」。它的 AppKit interop / window styling / Liquid Glass 章节直击痛点；trace 工具链对「编辑大文档不卡」这类编辑器核心性能诉求很有价值。
- **信任度**：★★★★☆。作者 Antoine van der Lee（SwiftLee 博客）+ Omar Elsayed，Swift 社区知名，署名可核实。MIT。约 3.3k stars（以仓库为准）。
- **安全性**：**带可执行脚本**（Python 包 `xctrace`）——属「跑代码」类，功能本身是本地性能采样、相对良性，但**安装前必须审阅这两个脚本**，确认没有额外网络/文件访问。
- **安装（供你确认后手动执行）**：`npx skills add https://github.com/avdlee/swiftui-agent-skill --skill swiftui-expert-skill --agent claude-code`。

> **两者取舍（重要）**：`twostraws` 与 `AvdLee` 在「SwiftUI 最佳实践」上**有重叠**。建议：**SwiftUI/macOS/性能审查用 `AvdLee`（最对口本项目的 AppKit 桥接 + Liquid Glass + trace）**，**并发 / Swift Testing / SwiftData 等从 `twostraws` 合集里补装对应子技能**。不要同时开两个 SwiftUI 审查技能，避免给 Agent 相互矛盾的指导。

### 3. `anthropics/skills → skill-creator` —— 官方「造 skill 的 skill」

- **来源**：<https://github.com/anthropics/skills>（子技能 `skill-creator`）
- **做什么**：引导你搭建合规的 `SKILL.md`（frontmatter 约束、渐进披露结构、`scripts/`/`references/` 骨架），并能测试/评估 skill 质量。
- **为什么对本项目有用**：docs/16 的战略是 **Colophon 要为自家 Markdown 格式/工作流附带官方 skill**（`<editor>-markdown`、`-library`、`-themes`、`-publishing`），让任意兼容 Agent 懂我们的文库。写这些 skill 时，`skill-creator` 是官方脚手架。即便近期只写项目级 `.claude/skills/`（教 Agent 操作本仓库约定），它也直接有用。
- **信任度**：★★★★★。Anthropic 官方，Apache-2.0（文档类 skill 为 source-available，但 skill-creator 属示例、开源）。
- **安全性**：官方来源，风险最低。
- **安装（供你确认后手动执行）**：`/plugin marketplace add anthropics/skills` 然后 `/plugin install example-skills@anthropic-agent-skills`（skill-creator 属示例集；以仓库 README 的最新插件名为准），或手动拷 `skill-creator/` 到 `.claude/skills/`。

### 4. `anthropics/claude-code-security-review` —— 官方安全审查 GitHub Action（配 CI）

- **来源**：<https://github.com/anthropics/claude-code-security-review>
- **做什么**：PR 触发的 AI 安全审查 Action——分析 diff、按上下文找漏洞（SQL 注入、XSS、认证/授权缺陷等）、带严重度与修复建议、有误报过滤，把发现以行内评论贴到 PR。
- **为什么对本项目有用**：Colophon 是开源项目，接受外部 PR，且会碰用户文件 + AI/MCP 集成。**本地开发用内置 `/security-review`，CI 上用这个 Action**，两层覆盖。正好配合 M0 阶段搭 CI。
- **信任度**：★★★★★。Anthropic 官方开源。
- **安全性**：作为 GitHub Action 跑在 CI runner（非你本机），是标准的 CI 集成；接入需要配 API key（走 GitHub Secrets，别硬编码）。
- **安装（供你确认后手动执行）**：把官方 workflow 加进 `.github/workflows/`（按仓库 README）。**这不是本机 skill**，无 npx/plugin 安装。

---

## ② 可选 / 观察（有价值，但相关度/信任度需你自己权衡，或适合特定阶段再上）

> 以下都不建议现在无脑装；标注了「何时再考虑」。

### `obra/superpowers` —— Jesse Vincent 的开发方法论框架

- **来源**：<https://github.com/obra/superpowers>；官方 marketplace 亦已收录。
- **做什么**：把一套工程文化打包成 skill——真·红/绿 TDD、四阶段系统化调试（先查根因再改）、苏格拉底式头脑风暴（先澄清需求再写码）、subagent 驱动开发（内建代码审查）、以及造 skill 的能力。三个主命令 `/superpowers:brainstorm`、`:write-plan`、`:execute-plan`。MIT，约 174k stars。
- **为什么可能有用**：其「先头脑风暴→写计划→再执行」的纪律，**与本项目 MEMORY 记录的「research first / 先深思再写码」偏好高度一致**，也和 `planning/` 的 overview→research→plan 流程同构。
- **为什么放这档（不直接建议）**：它是**重量级、会显著改变 Agent 工作方式**的整套方法论，是否采纳是口味/团队约定问题，不是「明显净赢」。建议：**先试用观察**，合拍再固化进工作流。
- **信任度/安全**：作者知名、且已上**官方 marketplace**（分发可信度高）；但框架大、编排逻辑多，仍建议先读其结构再启用。
- **安装**：`/plugin install superpowers@claude-plugins-official`（官方源）。

### `trailofbits/skills` —— Trail of Bits 安全技能集

- **来源**：<https://github.com/trailofbits/skills>
- **做什么**：40+ 安全插件——`static-analysis`（CodeQL/Semgrep/SARIF）、`insecure-defaults`（硬编码凭据、fail-open）、`variant-analysis`、`differential-review`（结合 git 历史的差量安全审查）、`sharp-edges`（易错 API/危险配置）。语言无关为主，另有 C/Rust/Solidity 专项。约 6.2k stars，CC-BY-SA-4.0。
- **为什么可能有用**：`differential-review`、`sharp-edges`、`insecure-defaults` 对任何代码库都通用，可作为周期性安全过一遍的工具。
- **为什么放这档**：(1) **Swift 覆盖有限**，其强项（C/Rust/Solidity、Web 类漏洞）与一个本地 macOS 编辑器相关度一般；(2) **大量 Python + Shell 脚本会在你本机跑**，属高权限工具。日常安全需求，内置 `/security-review` + 上面第①档的 Apple/Swift 审查已基本够用。
- **信任度/安全**：作者 Trail of Bits 是顶级安全公司，来源极可信；但正因它会跑本地静态分析工具链，**启用前审阅脚本**是标准动作。
- **安装**：`/plugin marketplace add trailofbits/skills`。
- **何时再考虑**：接近发布、想做一次系统性安全审计时。

### `rshankras/claude-code-apple-skills` —— 第三方 Apple 平台技能集

- **来源**：<https://github.com/rshankras/claude-code-apple-skills>
- **做什么**：macOS（Tahoe/26 APIs、SwiftData、AppKit bridge）+ SwiftUI（数据流、布局容器、WebKit、文本编辑、toolbars、Charts 3D）等模块，「Review my code / Add [feature]」式触发。MIT，约 544 stars，含 CI 用 shell 脚本。
- **为什么放这档**：macOS 26 / AppKit bridge / 文本编辑 等模块与本项目对口，但**与第①档的 `twostraws`+`AvdLee` 大量重叠**，且**单人维护、star 较低**，可信度不及前两者。作为「补充参考」观察即可，不必与前两者叠加。
- **安装**：`/plugin marketplace add rshankras/claude-code-apple-skills` 然后 `/plugin install apple-skills@indie-apple-stack`。

### `anthropics/skills → mcp-builder`

- **来源**：<https://github.com/anthropics/skills>（子技能 `mcp-builder`）
- **做什么**：帮 Agent 生成 MCP server。
- **为什么放这档**：docs/16 / docs/19 规划把**内置 MCP server 放到 V2**（暴露语法树级工具）。**做那块时**这个官方 skill 直接有用；现在（M0）还用不上。官方来源、低风险。
- **安装**：同 `skill-creator`（`example-skills@anthropic-agent-skills`）。

### `anthropics/skills → webapp-testing`

- **做什么**：官方的 Web 应用测试 skill（Playwright 系，驱动浏览器测网页）。
- **为什么放这档**：Colophon 的预览是 **WKWebView**，渲染的是 HTML/CSS。若要系统性测试预览渲染（主题 CSS、GFM 渲染正确性），这个 skill 的思路可复用。相关度中等、**看预览测试做到多重**再定。官方、低风险。

### markdown-lint 工作流 skill（如 `s2005/markdown-linter-fixer-skill`）

- **来源**：<https://github.com/s2005/markdown-linter-fixer-skill>（底层用 `markdownlint-cli2`）
- **为什么可能有用**：Colophon 本身是 Markdown 编辑器 + `planning/`/`docs/` 全是 Markdown，**dogfood** 一个 markdown 规范化流程有点应景，可保持自家文档整洁。
- **为什么放这档**：作者非知名个人（署名不足以「可信」），且**功能可被「直接配 `markdownlint-cli2` + 一条 `CLAUDE.md` 约定」平替**，未必需要一个第三方 skill。若要用，**先读其 `SKILL.md` 与脚本**（它会调 `markdownlint-cli2`/`prettier`）。

---

## ③ 明确不装（附理由）

- **第三方 git / conventional-commit skill**（mcpmarket、各 marketplace 上的 `commit`/`git-commit-push-pr` 等）——**Claude Code 原生 git 集成 + 一条写进 `CLAUDE.md` 的提交约定**（如 conventional commits、「不直接提交 main」）已完全覆盖；再叠一个会跑 `git` 命令的第三方 skill 是净负担、且多为无署名来源。分支保护放到 GitHub 层面（branch protection）比装 skill 更靠谱。

- **聚合站上无署名的「Swift Code Review」「Apple Code Review」等 skill**（如 mcpmarket 的条目）——功能听起来对口，但**来源不可核实、无法归到已知作者**，违反安全原则第 1 条。用第①档可信的 `AvdLee`/`twostraws` 取代，审查再叠内置 `/code-review`。

- **无署名的 README / 文档生成器 skill**（GLINCKER marketplace、mcpmarket 的 readme-generator 之类）——文档质量靠**内置能力 + 项目 `CLAUDE.md` 里写清「文档怎么写、放哪、什么算好」**更可控；不装来源不可核实的文档 skill。（真要一个团队级模板，用 `skill-creator` 自己写一个项目内 skill。）

- **Anthropic 文档 skills：`pptx` / `xlsx` / `docx` / `pdf`**——(1) 官方明确这四个在 **Claude Code 表面不可用**；(2) 与「开发一个 Swift app」无关。不适用。

- **付费 / 无策展市场的 skill**（Agensi 付费条目、随意的 marketplace 列表等）——除非能把源码归到已知可信作者并审阅，否则一律不装。市场普遍**无策展、无安全审查**（docs/16 §3.4 的硬约束）。

---

## 未发现 / 说明

- **没有**找到 Anthropic 官方出品的、专门面向 Swift/SwiftUI/macOS 的 skill——官方 `anthropics/skills` 里与开发相关的是 `mcp-builder`、`webapp-testing`、`skill-creator`、`claude-api`（通用），Swift 领域知识目前**只能靠社区可信作者**（Paul Hudson、SwiftLee）填补。这也说明第①档 1/2 两项的价值。
- 星标数为调研时的近似值（部分经页面抓取），**以各仓库当前页面为准**；安装前请顺手核对仓库是否仍在维护、最近提交时间。
- 本文所有条目均来自可核实的一手仓库/官方文档；**未收录任何查不到出处或无法署名的 skill**。

---

### 参考来源

- Anthropic 官方 skills 仓库 — <https://github.com/anthropics/skills>
- Anthropic 官方安全审查 Action — <https://github.com/anthropics/claude-code-security-review>
- Paul Hudson / Hacking with Swift 的 Swift Agent Skills — <https://github.com/twostraws/swift-agent-skills>、文章 <https://www.hackingwithswift.com/articles/282/swiftui-agent-skill-claude-codex-ai>
- Antoine van der Lee / SwiftLee 的 SwiftUI Agent Skill — <https://github.com/AvdLee/SwiftUI-Agent-Skill>
- Jesse Vincent (obra) superpowers — <https://github.com/obra/superpowers>
- Trail of Bits skills — <https://github.com/trailofbits/skills>
- rshankras Apple skills — <https://github.com/rshankras/claude-code-apple-skills>
- skills.sh / Vercel Labs `npx skills`（含 `~/.agents/skills` vs `~/.claude/skills` 路径 bug）— <https://www.skills.sh/agent/claude-code>
- markdown-linter-fixer-skill — <https://github.com/s2005/markdown-linter-fixer-skill>
- 原理与安全模型 — [`../../docs/16-agent-skills.md`](../../docs/16-agent-skills.md)
