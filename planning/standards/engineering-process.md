# 工程流程规范

> **用途**：本文是 Colophon 的「工程流程 single source of truth」——代码风格、Git 协作、版本与变更、测试、CI、社区文件的硬约定。目标是让**人和 AI 编码助手都能照着直接干活**：所有规则用祈使句写、可执行、可核对。
>
> **两条使用说明**
> 1. 本文当前用中文，便于团队理解。搬进真实仓库时，把「代码风格 / Git / 测试 / CI」这几节译成英文，作为仓库根的 `AGENTS.md` 与 `.claude/rules/*.md`（社区文件如 CODE_OF_CONDUCT/SECURITY 本就该是英文）。**用规范文件驱动 Agent、再让 Agent 照着改代码——这本身就是在 dogfood 路线 B**（见 [`../../docs/17`](../../docs/17-human-agent-workflows.md)）。
> 2. 全文用 **【现在就定】/【M1 spike 后再定】** 标注每条规则的确定度。凡依赖「编辑内核起点」（fork `swift-markdown-engine` vs 从零 `NSTextView` vs `CodeEditTextView`，见 [PRD §12.4](../PRD.md)）等未决决策的实现细节，一律不在此硬写死，收进文末「留到实现时再定」。

---

## 0. 适用范围与既定前提

本文默认以下 PRD 已锁定决策，不再论证，只据此定流程：

- **License = Apache-2.0**；**最低 macOS 15 Sequoia**；用**最新 Xcode（macOS 26 SDK）**编译。
- 架构 = **SwiftUI 壳 + `NSViewRepresentable` 桥接 `NSTextView`(TextKit 2) + `swift-markdown` 解析 + `WKWebView` 预览/导出**。
- **AI 走路线 B**：编辑器不生成内容，只做「人 ↔ Agent 的 Markdown 界面」；MVP 只留架构缝。
- **分发 = GitHub Releases + Homebrew（自建 tap `colophon-app/tap`）**；**首发即代码签名 + 公证**。
- **治理 = 第一天建立多维护者可能性**，避免单点维护者故障（Mark Text 教训，[`../../docs/03`](../../docs/03-windows-legacy.md)）。

---

## 1. Swift 代码风格

### 1.1 选型：swift-format（不用 SwiftLint）　【现在就定】

在 `swift-format` 与 `SwiftLint` 中**选 `swift-format`**，理由紧扣本项目：

- 它是 **swiftlang 官方项目、随 Swift 工具链发布**，与「优先用系统/官方组件、免费继承 Apple 演进」的产品信念一致（PRD §3.6）——和我们选 `swift-markdown`、WKWebView 是同一逻辑，避免再引入一个会先于产品死掉的第三方依赖（`Down`/`Ink`/`SwiftDown` 停更之鉴，[`../../docs/09`](../../docs/09-tech-stack.md)）。
- **一个工具同时管格式化 + lint**（`format` 与 `lint` 两个子命令），少一套配置、少一层 CI；SwiftLint 侧重规则告警但不改格式，还得再配 formatter。
- 能作为 **SPM Build Tool Plugin** 接进 Xcode，且随 macOS 26 SDK 的工具链走，版本对齐零心智负担。

> 不因此排斥未来按需加 SwiftLint 的少量自定义规则，但**基线只维护一套 `swift-format` 配置**。

### 1.2 基线配置方向（`.swift-format`，仓库根）　【方向现在定，数值 M0 内定稿】

放一份 `.swift-format`（JSON）在仓库根，方向如下（具体数值 M0 建仓后跑一遍全量代码再定稿）：

- `lineLength`: 100（偏宽，适配 SwiftUI 声明式 + AppKit 长 API 名）
- `indentation`: 4 空格；`tabWidth`: 4；`spacesAroundRangeFormationOperators`: true
- `respectsExistingLineBreaks`: true；`maximumBlankLines`: 1
- `lineBreakBeforeEachArgument`: 按 Xcode 默认，交给格式化器
- 打开的 lint 规则（rules）至少含：`AlwaysUseLowerCamelCase`、`OrderedImports`、`ReturnVoidInsteadOfEmptyTuple`、`UseEarlyExits`、`NoAccessLevelOnExtensionDeclaration`、`OneVariableDeclarationPerLine`

**红线规则（写进 `.claude/rules`，Agent 必须遵守）**：

- **格式化只作用于 `.swift` 源码，绝不作用于用户的 `.md` 文档。** 用户文档走 byte-exact 保存路径（§4.4），任何「保存即格式化 Markdown」都是 bug，会破坏 frontmatter / 代码围栏。
- `swift-format` 的运行位置：**pre-commit（可选）+ CI 强制 + Xcode Build Tool Plugin**。CI 用 `lint --strict`，有 diff 即失败（见 §5）。

### 1.3 命名与文件组织　【原则现在定，目录树 M1 spike 后定稿】

**命名** —— 遵循 [Swift API Design Guidelines]，另加本项目约定：

- 类型 `UpperCamelCase`，成员/变量 `lowerCamelCase`；协议用名词或 `-able/-ing`。
- 缩写只允许业内公认词并整体大小写一致：`URL`、`ID`、`HTML`、`PDF`、`AST`、`MCP`、`GFM`、`FSEvents`。禁止自造缩写（`docMdl`、`txtVw` 一律拒绝）。
- 桥接层类型显式点名技术，避免歧义：如 `MarkdownTextView`（`NSViewRepresentable`）、`MarkdownTextKitCoordinator`。
- **一个文件一个主类型，文件名 = 主类型名。**

**文件组织** —— **按领域/模块分组，不按类型分组**（不要 `Views/`+`Models/`+`Controllers/` 一刀切）。建议的顶层模块边界（**具体拆分依赖 M1 编辑内核 spike 结果，先给方向**）：

| 模块 | 职责 | 备注 |
|---|---|---|
| `App/` | SwiftUI App 生命周期、`NavigationSplitView` 三栏壳 | |
| `Editor/` | `NSTextView`(TextKit 2) 薄封装 + `NSViewRepresentable` 桥接 | TextKit 2 防坑集中在此（§4.5） |
| `Parsing/` | `swift-markdown` 封装、**AST/SourceRange 文档操作 API 边界** | 路线 B 的「架构缝」，未来 Skills/MCP 对齐这里 |
| `Document/` | 文档模型、文件 IO、编码探测、**byte-exact 保存** | 数据安全核心，测试重点（§4.4） |
| `FileSystem/` | FSEvents 文件监听、文件夹即文库 | 外部变更协调逻辑 |
| `Preview/` | `WKWebView` 预览/导出子系统（KaTeX/Mermaid） | 内容隔离与沙箱（§7 SECURITY） |
| `AgentFiles/` | 识别与特别渲染 `CLAUDE.md`/`AGENTS.md`/`*.mdc`/`SKILL.md`/`llms.txt` | 路线 B 门 |
| `DesignSystem/` | 主题、SF Symbols、Liquid Glass 门控（`if #available(macOS 26, *)`） | 编辑区内容层保持非玻璃 |

> **测试 target 目录结构镜像源码结构**（`ParsingTests/` 对 `Parsing/`，依此类推）。最终目录树在 M1 编辑内核选型定案后固化进 `planning/M1/decisions.md`。

---

## 2. Git 协作

### 2.1 分支模型：main 保护 + 短命特性分支　【现在就定】

- **`main` 永远可发布、永远受保护**：禁止直接 push，一切经 PR 合入；必须 CI 全绿（build + test + lint）才能合并；采用 **squash merge** 保持线性历史（每个 PR = 一个语义化 commit，天然喂给 Keep a Changelog）。
- **短命特性分支**：命名 `type/scope-short-desc`（如 `feat/editor-split-preview`、`fix/fs-watch-conflict`）。**开出来几天内就合掉或关掉**——避免 Mark Text 那种 PR 长期堆积无人合的死法（[`../../docs/03`](../../docs/03-windows-legacy.md)）。
- **呼应多维护者治理**：现在虽是单人，但**第一天就开启分支保护 + 要求 PR + 要求 CI 通过**，并**尽早把 merge 权限授予第二位维护者**。Mark Text 的直接死因正是「作者全职后 PR 无人有权限合并」——权限下放是 governance 硬要求，不是等有人再说。分支保护的「required approvals」当前设 0（单人）、**一旦有第二位维护者立即上调到 1**。

### 2.2 Conventional Commits　【现在就定】

提交信息遵循 [Conventional Commits]：`type(scope): summary`。

- **type**：`feat` / `fix` / `docs` / `refactor` / `perf` / `test` / `build` / `ci` / `chore`。
- **scope**（本项目约定，与 §1.3 模块对齐）：`editor` / `parser` / `document` / `fs` / `preview` / `agentfiles` / `ui` / `theme` / `export` / `ci` / `build`。
- **破坏性变更**：footer 写 `BREAKING CHANGE: …` 或 type 后加 `!`。破坏性变更要克制——Memos 版本间破坏性变更让社区反弹（[`../../docs/13` §7.2](../../docs/13-product-opportunities.md)）。
- Agent 生成的 commit 也必须守此格式（写进 `AGENTS.md` 的「commit 规范」节）。

### 2.3 PR 模板与评审规则　【现在就定】

**PR 模板**（`.github/PULL_REQUEST_TEMPLATE.md`）至少含：

- **What / Why**（一句话 + 背景），关联 issue（`Closes #NN`）。
- **Test plan**：怎么验的；UI 改动附前后截图/录屏。
- **Checklist（勾选项，兼作 Agent 自检清单）**：
  - [ ] 数据安全路径有测试（保存 / 外部变更协调 / 编码，见 §4.4）
  - [ ] 更新了 `CHANGELOG.md` 的 `Unreleased` 段
  - [ ] 未触碰 TextKit 1 API（无 `.layoutManager` 访问，[`../../docs/09`](../../docs/09-tech-stack.md)）
  - [ ] 未引入 GPL/停更依赖（见 §2.4）
  - [ ] 未开启「智能引号/破折号」等会破坏 `.md` 字节的替换

**评审规则**：

- 至少 1 位维护者 approve（单人期由作者自审 + CI 兜底，第二维护者到位后强制 1 approve）。
- 引入 `CODEOWNERS` 把不同模块的评审分派给对应维护者（**目录树定案后再落地**），分散评审负载、避免单点。
- 评审关注点固定四条：**数据安全、TextKit 2 防坑、依赖许可、范围克制**（别让 PR 把编辑器悄悄变成 IDE/PKM）。

### 2.4 依赖与许可纪律　【现在就定】

- **新依赖必须在 PR 描述里声明 license**，且与 Apache-2.0 兼容。
- **`STTextView` 已改 GPLv3 + 商业双授权**：若我们以 Apache-2.0 发布，**不得整体引入**其代码，只可研读源码作为 TextKit 2 避坑百科（[`../../docs/09`](../../docs/09-tech-stack.md)）。
- **不引入停更库**：`Down` / `Ink` / `SwiftDown` 均已停更/归档（[`../../docs/09`](../../docs/09-tech-stack.md)）。
- **`swift-markdown-engine` 若采用（M2）：fork 并锁版本**，具备接管能力——它 pre-1.0、单团队主导，是「依赖先于产品死掉」的风险点（[`../../docs/13` §7.3](../../docs/13-product-opportunities.md)）。

---

## 3. 版本与变更

### 3.1 SemVer　【现在就定】

采用 [SemVer]：`MAJOR.MINOR.PATCH`。

- MVP 首个 public release 打 **`0.y.z`**（未到 1.0，管理用户对稳定性的预期，避免 Haroopad 那种「永远 0.x 让人不敢托付」与「跳票承诺」两个极端——少承诺、快兑现，[`../../docs/13` §7.4](../../docs/13-product-opportunities.md)）。1.0 = 编辑器一件事做到能日用且数据安全路径全绿。
- Git tag 用 `vX.Y.Z`（触发 release 流水线，见 §5.3）。

### 3.2 CHANGELOG：Keep a Changelog 六分类 + Unreleased　【现在就定】

`CHANGELOG.md` 遵循 **Keep a Changelog**（事实标准，[`../../docs/17` §五](../../docs/17-human-agent-workflows.md)）：

- 版本**倒序**排列；日期用 **ISO 8601**（`2026-07-21`）；配合 SemVer。
- 每个版本按**六分类**分组：**Added / Changed / Deprecated / Removed / Fixed / Security**。
- 维护一个 **`Unreleased`** 段作为「下个版本的管道预览」——**每个 PR 顺手更新它**（PR checklist 已列）。
- 措辞用祈使现在时（`Add…` / `Fix…`），与 Conventional Commits 天然对齐。
- **人审定稿**：可用 Conventional Commits 经 `git-cliff`/`conventional-changelog` 起草，但发布前人工校对——「commit 是结构化输入、changelog 是给人读的输出」（[`../../docs/17`](../../docs/17-human-agent-workflows.md)）。自动化工具选型见文末（依赖 commit 历史积累后再定）。

> **dogfood 提示**：`CHANGELOG.md`（Keep a Changelog 六分类 + Unreleased）本身也是我们 V1 要提供的模板之一（[`../../docs/17` §对启示](../../docs/17-human-agent-workflows.md)）——我们自己先按它写，就是第一个用户。

---

## 4. 测试策略

> 总原则：**测试金字塔重心压在解析/文档模型/文件层的单元测试**（快、稳、覆盖核心）；渲染做快照测试；关键路径做少量 UI 测试；**数据安全路径必须有测试，且是 release 门禁**。

### 4.1 主干：单元测试（解析 / 文档模型 / 文件层）　【现在就定】

- **解析**：`swift-markdown` 解析正确性、GFM 全家桶（表格/任务列表/删除线/脚注）、`SourceRange` 精确性；「AST/SourceRange 文档操作 API」（路线 B 架构缝）的每个操作都要有单测——它未来要被 Skills/MCP 复用，**边界不能靠手测**。
- **文档模型**：source ↔ AST ↔ 渲染态的映射、光标/选区映射。
- **文件层**：打开、保存、编码探测、文库（文件夹）枚举。
- **测试框架**：优先 **Swift Testing**（macOS 15 + Xcode 26 SDK 已具备），新代码用它；与 XCTest 的取舍在 M1 写第一批测试时定稿。

### 4.2 渲染快照测试　【方向现在定，工具 M1 后定】

- 对 `WKWebView` 预览/导出的**生成物做快照**（优先快照「生成的 HTML 字符串」，稳定、可 diff；必要时补图像快照）。
- 快照库倾向 [swift-snapshot-testing]（MIT，pointfree），最终选型在 M1 预览管线（WKWebView 子系统）落地后定。
- 目的：预览排版是竞品重灾区（Zed 预览被吐槽标题层级不可见，[`../../docs/07`](../../docs/07-ide-terminal.md)）——快照能挡住「改 A 坏 B」的排版回归。

### 4.3 关键路径 UI 测试　【现在就定（清单），量 M1 控制】

XCUITest 只覆盖**关键路径**，保持少而稳（UI 测试慢且脆）：

- 打开一个文件夹当文库 → 编辑 → 保存。
- `⌘\` 一键分屏预览、双向滚动同步基本可用。
- omnibar 搜索/新建、命令面板（`⇧⌘P`）能打开。

### 4.4 数据安全路径：必须有测试（release 门禁）　【现在就定 —— 硬要求】

这是本项目测试策略里**不可协商**的一节——**保存与外部变更协调是路线 B 的信任地基，缺测试直接卡发布**。以下每条都要有自动化测试：

- **byte-exact 保存往返**：打开 → 不编辑 → 保存，**字节完全一致**；确认「智能引号/破折号替换」全程关闭（否则破坏 frontmatter 与代码围栏，PRD §5.1、[`../../docs/19`](../../docs/19-route-b-blueprint.md)）。
- **非 UTF-8 处理**：**报错而非静默损坏**。
- **frontmatter / 代码围栏保真**：`.mdc` 的 YAML frontmatter、` ``` ` fence 内容原样保留。
- **外部变更协调（FSEvents）**：缓冲区无脏改动时**静默刷新**；有未保存冲突时给 **Reload / Ignore / Compare** 三选项；刷新后**保留光标与滚动位置**（对标 VS Code，避开 Obsidian「切走再切回才看到外部改动」的坑，[`../../docs/17` §对启示](../../docs/17-human-agent-workflows.md)）。
- **自动保存 + 文件系统版本历史**：写入不丢数据、可回滚。
- **Agent 文件 golden fixtures**：把真实的 `CLAUDE.md` / `AGENTS.md` / `*.mdc` / `SKILL.md` / `llms.txt` 样本存进测试夹具，跑 byte-exact + 解析双重校验。

> 这些路径的**具体实现**（FSEvents 封装、冲突 UI）留到 M1；但**测试意图现在就写死进规范**，实现时补齐用例。

### 4.5 TextKit 2 防坑（测试 + 评审双保险）　【现在就定】

来自 [`../../docs/09`](../../docs/09-tech-stack.md) 的实战坑，进测试/评审清单：

- **严禁访问 `.layoutManager`**：会静默降级回 TextKit 1（macOS 26 仍有此坑）。加静态检查/评审卡点。
- 视口高度靠估算导致的**滚动跳动**要有对策与回归验证。
- **打印/PDF 走 `WKWebView`/PDFKit，绝不走 TextKit、绝不引入无头 Chrome**（PRD §7）。

---

## 5. CI / CD（GitHub Actions，macOS runner）

### 5.1 每个 PR：build + test + lint　【现在就定】

- runner 用 **macOS runner**（`macos-15` / 待 macOS 26 runner 可用后跟进，见文末），Xcode 选 macOS 26 SDK。
- 三道关：**`xcodebuild build`** + **`xcodebuild test`（含数据安全用例）** + **`swift-format lint --strict`**（有 diff 即失败）。
- 缓存 SPM 依赖；`concurrency` 取消同分支旧跑；**这三项设为 `main` 的 required status checks**（与 §2.1 分支保护联动）。
- **CI 必须在 M0 建仓时就搭好**——CuteMarkEd 正是被「跨平台打包负担 + CI 没早建」压垮的（[`../../docs/03`](../../docs/03-windows-legacy.md)）；早搭是几分钟，晚搭是噩梦。

### 5.2 签名 + 公证：放 release 流水线，M0 空壳时跑通　【现在就定】

- 独立的 release workflow，**tag `v*` 触发**：从加密 secrets 导入 Developer ID 证书 → `codesign` → **`notarytool` 提交 + `stapler` 装订** → 产出 `.dmg`/`.zip` → 附到 GitHub Release → 更新自建 Homebrew tap 的 cask。
- **趁 M0 app 还是空壳时就把这条流水线跑通**（ROADMAP M0 明确要求）：**没签名公证的 Mac app 对普通用户等于打不开**——MarkFlowy 的 `xattr` 放行、NoteGen 未签名首启告警都是活体反面教材（[`../../docs/02`](../../docs/02-cross-platform.md)、[`../../docs/18`](../../docs/18-agent-editor-competitors.md)）。
- **基础设施设自动续费**：Developer ID 证书、域名——Mark Text 官网域名忘续费直接丢失（[`../../docs/03`](../../docs/03-windows-legacy.md)）。公证所需的 App Store Connect API key、证书 p12 都放仓库加密 secrets，权限最小化。

### 5.3 版本发布节奏　【现在就定】

- **季度小发版**，向社区传递「项目活着」的信号（[`../../docs/03`](../../docs/03-windows-legacy.md)、[`../../docs/13` §7](../../docs/13-product-opportunities.md)）。
- 发版即：打 tag → CI 出签名公证包 → 更新 `CHANGELOG.md`（`Unreleased` 转成版本号）→ 更新 Homebrew cask。

---

## 6. 社区文件

> 全部放 `.github/` 与仓库根，**M0 建仓时就位**（治理承诺一旦公开不可回撤——Notable 开源转闭源两头落空，[`../../docs/13` §7.2](../../docs/13-product-opportunities.md)）。

### 6.1 Issue / PR 模板　【现在就定】

- `.github/ISSUE_TEMPLATE/bug_report.yml`（用 **issue forms**，强制填 **macOS 版本 / Colophon 版本 / 复现步骤 / 触发问题的 `.md` 样本**）与 `feature_request.yml`。
- `config.yml`：关闭空白 issue，引导到 Discussions。
- `PULL_REQUEST_TEMPLATE.md`：即 §2.3 的模板。

### 6.2 CODE_OF_CONDUCT.md　【现在就定】

- 采用 **Contributor Covenant 2.1**，联系方式填维护者邮箱。多维护者治理下，行为准则的 enforcement 也不应绑在单人身上。

### 6.3 SECURITY.md（漏洞上报流程）　【现在就定】

- **私密上报**：走 **GitHub Private Security Advisories**，**不要在公开 issue 报漏洞**；给出响应时限目标（如 72h 内首次回应）。
- **Supported Versions** 表：说明哪些版本收安全修复。
- **明确安全边界**（第一天写对，安全债会压垮项目——Abricotine 因渲染进程开 `nodeIntegration` 产生不可修复漏洞而死，[`../../docs/03`](../../docs/03-windows-legacy.md)）：
  - **`WKWebView` 预览必须严格内容隔离 + 沙箱**，不给预览层任何执行本地代码的能力。
  - 未来的 **Skills / MCP / 脚本系统（V1/V2）设计时就要有权限边界**，不是以后再补。

### 6.4 CONTRIBUTING.md 与治理声明　【现在就定（本文引用，正文归治理规范）】

- `CONTRIBUTING.md`（构建、跑测试、代码风格、提交规范的入口）+ 多维护者治理/BDFL 声明 + `FUNDING.yml`（GitHub Sponsors）——**第一天建立多维护者可能性**是 governance 硬约定（[`../../docs/13` §7.1](../../docs/13-product-opportunities.md)）。字段级内容归《开源治理规范》，本文只要求其在 M0 就位并与本文的 Git/评审规则一致。

---

## 7. 留到实现时再定（M1 spike 后 / 依赖未决决策）

以下项**依赖尚未拍板的决策或尚不存在的代码**，现在只给方向、不硬写死，进 M1 后随决策落地：

1. **`.swift-format` 精确数值与可选规则集**：`lineLength` 终值、启用哪些 optional rules——M0 建仓、对全量代码跑一遍后定稿。
2. **测试框架主选**：Swift Testing vs XCTest 的最终边界——M1 写第一批测试时定；数据安全用例先行。
3. **渲染快照工具与形态**：`swift-snapshot-testing` 是否采用、快照 HTML 字符串还是图像——依赖 M1 的 `WKWebView` 预览管线成型。
4. **目录树 / 模块边界 / `CODEOWNERS` 布局**：全部依赖 **M1 编辑内核起点 spike**（fork `swift-markdown-engine` vs 从零 `NSTextView` vs `CodeEditTextView`，PRD §12.4）——定案后固化进 `planning/M1/decisions.md`。
5. **CHANGELOG 自动化选型**：`git-cliff` vs `conventional-changelog` vs 纯手写——待 commit 历史积累、发版节奏跑顺后定。
6. **CI runner 镜像与 Xcode 版本钉定**：**macOS 26 runner 何时在 GitHub Actions 可用**是外部变量；且 **macOS 无模拟器、Liquid Glass 需 macOS 26 真机环境测试**（PRD §7）——涉及玻璃效果与 macOS 26 专属外观的 UI 测试可能一段时间内跑不进 CI，需要人工在 macOS 26 环境验证，验证清单 M1 补。
7. **分支保护的 required approvals 数、合并策略细节**：随维护者数量演进（单人 0 → 第二维护者到位即 1）；squash 之外是否允许 rebase merge 视团队规模再定。
8. **Bundle ID / 签名 identity / App 图标等发布身份**：M0 内定（PRD §12.8），本文的 release 流水线届时填入具体值。

---

<!-- 引用锚点 -->
[Swift API Design Guidelines]: https://www.swift.org/documentation/api-design-guidelines/
[Conventional Commits]: https://www.conventionalcommits.org/
[SemVer]: https://semver.org/
[swift-snapshot-testing]: https://github.com/pointfreeco/swift-snapshot-testing
