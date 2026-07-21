# planning/standards/ —— Colophon 开发规范索引

> **这是什么**：Colophon「开工前」沉淀的一组开发规范。每一份都只定「现在就能定的原则与硬约束」，凡依赖未跑的 spike / 未拍板的决策的实现细节，都收进各文档末尾的「留到实现时再定」，不过早锁死。
>
> **这些规范同时是 AI 编码助手的规则来源（dogfood 路线 B）**：它们用祈使句、可核对的形式写成，就是为了能直接喂给 Claude Code / Cursor 等 Agent 当规则文件——「用规范文件驱动 Agent、再让 Agent 照着改代码」本身就是本产品要支持的「人 ↔ Agent 的 Markdown 循环」。**未来搬进真实仓库时，把它们译成英文，落为仓库根的 `AGENTS.md` 与 `.claude/rules/*.md`**（社区文件如 CODE_OF_CONDUCT / SECURITY 本就该是英文）。文中所有代码、API、术语、文件名、快捷键一律保持英文。
>
> **上位文档**：[../PRD.md](../PRD.md)、[../ROADMAP.md](../ROADMAP.md)。凡规范与它们冲突，以 PRD / ROADMAP 为准。

---

## 六份规范（各一句话）

| 规范 | 管什么（一句话） |
|---|---|
| **[ui-and-design.md](ui-and-design.md)** | 界面与设计规则：技术栈边界（SwiftUI 壳 / `NSTextView` 编辑区 / `WKWebView` 预览）、HIG 与系统原生、Liquid Glass 门控、极简克制的设计语言、主题 token 化、无障碍底线、布局与快捷键。 |
| **[architecture.md](architecture.md)** | 核心内核/后端层的「宪法」：六层分层与单向依赖、「文件夹即文库」模型、byte-exact + 原子写 + 外部变更协调的数据安全线、双轨解析、undo 归属、TextKit 2 防坑红线、「AI = 语法树上的操作」的接口缝。 |
| **[dependencies-and-licenses.md](dependencies-and-licenses.md)** | 依赖与许可规则：Apache-2.0 出站兼容、批准/慎用/禁用清单、SPM 版本固定与供应链安全、vendored JS 管理、`NOTICE` 传递义务、采用 `swift-markdown-engine` 的 fork+锁版本条款。 |
| **[engineering-process.md](engineering-process.md)** | 工程流程 single source of truth：swift-format 代码风格、Git 分支/Conventional Commits/PR、SemVer/CHANGELOG、测试策略（数据安全路径为 release 门禁）、CI/CD 与签名公证、社区文件。 |
| **[security-and-privacy.md](security-and-privacy.md)** | 安全与隐私红线：`WKWebView` 不可信内容隔离（CSP/净化/最小权限）、App Sandbox 与 entitlements、隐私默认（零遥测/opt-in）、未来 AI/MCP 安全原则、「数据安全即隐私」。 |
| **[agent-skills.md](agent-skills.md)** | 开发本 app 时用的 Agent Skills / Claude Code 插件推荐清单：安全三铁律、内置能力优先、建议装（Swift/SwiftUI/安全）、可选观察、明确不装。 |

---

## 配套：开工前主清单

- **[../preflight-checklist.md](../preflight-checklist.md)** —— 把「完备性批判」找出的缺口、各规范里「留到实现时再定」的项、PRD §12 未决项去重后，按「建仓库即需 / M0 内做 / 需先决策 / 早期 spike / 持续贯穿」五组归拢，作为进入 M0 前的总核对表。**先看它，再回到具体规范查细节。**
