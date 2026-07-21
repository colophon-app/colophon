# 依赖与许可规范

> 本规范规定 Colophon（Apache-2.0、原生 macOS、最低 macOS 15）引入、固定、审查第三方依赖的规则，以及必须守住的许可红线；目标是让「引一个依赖」这件事有据可依、可审批、可回溯，避免重蹈调研里「依赖内核先于产品死亡」的覆辙。
>
> **语言约定**：本文档当前用中文便于团队理解。**未来搬进真实仓库作为 `AGENTS.md` / `.claude/rules` 时译成英文**（代码/API/许可名/文件名保持英文）。本文写法刻意做成「可直接喂给 AI 编码助手的规则文件」——这本身就是在 dogfood 路线 B。
>
> **依据**：PRD §7（技术架构）、§9（开源运营）、§11–12（已定决策）；ROADMAP §1/§6；`docs/09-tech-stack.md`（技术栈选型与许可雷区）、`docs/03-windows-legacy.md`（依赖内核死亡教训）。凡与 `docs/` 冲突处以 PRD/本文为准。

---

## 0. 三条硬约束（一切规则的前提）

这三条来自已锁定的决策（PRD §11），**不接受依赖引入时讨价还价**：

1. **出站许可 = Apache-2.0。** 任何进入编译产物、被链接、或随 app 分发的依赖，其许可必须与「我们以 Apache-2.0 对外发布」兼容（详见 §2）。
2. **最低部署目标 = macOS 15.0。** 依赖不得要求 macOS 15 之上的最低系统版本（`macOS 26+` 专属 API 走 `if #available` 门控，不是靠依赖硬拉高部署目标）。
3. **编辑区原生、WebView 只做预览/导出/图表。** 依赖按用途分区：进「原生编辑内核」的和进「WKWebView 子系统」的，评审标准与许可处理方式不同（§2.4、§4）。**不引入 Electron / Tauri / 无头 Chrome**（PRD §7 红线）。

---

## 1. 依赖引入准则与审批流程

### 1.1 SPM 优先

- **一律用 Swift Package Manager 引入依赖**，在 Xcode 工程的 Package Dependencies 里声明；不引入 CocoaPods / Carthage。
- **C 库经 SPM 的 C target 消费**（例：`swift-cmark` 已被 `swift-markdown` 打包为可被 SwiftPM 直接消费的 C target，我们不手动 vendoring cmark）。
- **JS 侧资源（KaTeX / Mermaid / Shiki 等）不是 SPM 依赖**，按「vendored 静态资源」管理，规则见 §4。
- **外接 CLI（Pandoc 等）不是链接依赖**，按「外部进程」管理，规则见 §2.5。

### 1.2 新增依赖前必须逐条过的四道闸

任何人（含 AI 编码助手）提议新增一个 SPM 依赖，先在 PR 描述里回答这四点，缺一不可：

1. **维护活跃度**：最近一次实质提交时间？发版节奏？是单人还是有组织治理？有没有归档/「寻找维护者」/`discontinued` 信号？
   - 硬门槛：**停更 / 归档 / README 挂「looking for maintainer」的库一律不引入**（`Down`/`Ink`/`SwiftDown` 就是反例，见 §3）。
   - 单人维护但活跃的库可用，但要在 PR 里标注「单点维护风险」并说明接管/替换成本。
2. **许可兼容**：许可类型？是否落在 §2 的「批准」集合？若是 GPL/LGPL/MPL/SSPL/商用双授权，**默认拒绝**，除非用途是「仅只读源码借鉴、不链接不分发」（§2.3）。
3. **体量与表面积**：它自己又拖进来多少间接依赖？二进制体积增量？API 表面积多大（我们用到的是不是一小块）？
   - 原则（ROADMAP §6「极小维护面」、`docs/03` ReText 长寿教训）：**能用系统框架/官方库解决的，不引第三方；能只用一个模块的，不引整包。**
4. **可替代性 / 退出成本**：如果它明天死了，我们换掉它要多久？我们的代码是否被它的 API 深度绑架？
   - 深度绑架编辑内核的依赖（如 swift-markdown-engine）适用更严格的「接管能力」条款（§5）。

### 1.3 审批流程

- **M0/M1 阶段（单人 + AI 辅助）**：作者本人是 BDFL，新增依赖由作者在 PR 里过完 §1.2 四道闸即可合并；**决定与理由记进对应里程碑的 `decisions.md`（ADR-lite）**。
- **多维护者之后**：新增/升级「进编译产物」的依赖需至少一名其他维护者 review §1.2 四点；纯 dev 工具依赖（linter、脚本）可放宽。
- **升级现有依赖**：小版本升级看 changelog + CI 绿；跨大版本或换许可，按新增依赖同等对待重新过闸。
- **任何依赖变更都必须同一个 PR 里带上 `Package.resolved` 变更**（§3 供应链）。

---

## 2. 许可红线与「批准 / 慎用 / 禁用」清单

### 2.1 出站兼容规则（Apache-2.0 项目能安全吸收什么）

| 入站许可 | 结论 | 说明 |
|---|---|---|
| MIT / BSD-2 / BSD-3 / ISC / zlib | ✅ 可链接可分发 | 宽松许可，保留版权与许可声明即可 |
| Apache-2.0 | ✅ 可链接可分发 | 与本项目同许可；**注意传递 `NOTICE` 文件义务**（§2.6） |
| GPLv2 / GPLv3 | ❌ 不可链接不可分发 | 单向兼容——Apache-2.0 代码可进 GPLv3 项目，反之不行；会「传染」我们的出站许可 |
| LGPL | ⚠️ 默认避开 | 动态链接理论可行但带来额外义务，且 macOS 分发/签名场景复杂化，不值得 |
| MPL-2.0 | ⚠️ 慎用 | 文件级 copyleft，技术上兼容但给被改动文件附加义务；非必要不碰 |
| SSPL / BUSL / 商用双授权（GPL+商业） | ❌ 禁用 | 例：`STTextView`（GPLv3 + 商业双授权），见 §2.3 |

**记忆口诀**：Apache-2.0 项目安全吃 **MIT / BSD / Apache**；遇到 **GPL/LGPL/MPL/SSPL/商用双授权** 一律停下来问（默认拒）。

### 2.2 批准 / 慎用 / 禁用清单（现在就定）

> 「用途」列标注该依赖进「编辑内核（原生）」还是「WebView 子系统（JS）」。许可以调研（`docs/09`）记录为准，**实际引入前在 PR 里用 whois 式核对一次当时的 LICENSE 文件**（许可可能变，`STTextView` 就是从宽松改成 GPLv3 的活例）。

#### ✅ 批准（符合 §2.1，可直接按 §1 流程引入）

| 依赖 | 许可 | 用途 | 备注 |
|---|---|---|---|
| `swift-markdown`（Apple/swiftlang） | Apache-2.0 | 编辑内核：语义解析 / 导出 / SourceRange / AST | **首选解析层**，官方维护、SPM 一行、许可同源；路线 B 的「语法树操作 API」建在它上面 |
| `swift-cmark`（swiftlang） | BSD 系 | `swift-markdown` 的传递依赖 | 不单独声明，跟随 `swift-markdown`；**安全更新要跟**（cmark-gfm 历史有多起多项式复杂度 DoS CVE，见 §3.4） |
| `SwiftTreeSitter`（ChimeHQ）+ tree-sitter 核心 | MIT | 编辑内核：增量高亮 | 与 `swift-markdown`（全量 AST）互补的「增量解析」侧；是否引入取决于高亮方案 spike（§6） |
| `Neon`（ChimeHQ） | BSD-3 | 编辑内核：把 tree-sitter 结果映射为文本属性 | 「解析结果→TextKit 属性」的中间件；与 `SwiftTreeSitter` 配套 |
| `Highlightr` | MIT | 编辑内核：代码块高亮（起步） | JSCore 跑 highlight.js；M1 快速出效果用，注意节流/缓存 |
| `HighlighterSwift` | MIT | 编辑内核：代码块高亮（替代候选） | `swift-markdown-engine` 所用；若采用该引擎则可能随之进来（§5） |
| `SwiftMath` | MIT | 编辑内核：行内数学（原生 CoreText） | iosMath 血统；覆盖常用 LaTeX 子集；WebView 侧另有 KaTeX 兜底 |
| `KaTeX` | MIT | WebView：预览/导出数学 | vendored JS（§4）；编辑反馈优先用它（同步快渲染） |
| `Mermaid` | MIT | WebView：图表 | vendored JS（§4）；无原生替代，只能在 WebView 跑 |
| `Shiki` | MIT | WebView：预览端代码高亮 | vendored JS（§4）；观感优于 hljs；注意 WASM 体积与初始化开销 |
| `MathJax`（若选它替 KaTeX） | Apache-2.0 | WebView：导出/学术场景数学 | 覆盖面全、无障碍好；KaTeX vs MathJax 最终取舍见 §6 |
| `highlight.js`（若 Shiki 太重） | BSD-3 | WebView：预览端代码高亮（备选） | 轻快、精度一般 |

#### ⚠️ 慎用（可用但带条件，引入前必须在 `decisions.md` 记明理由与退出方案）

| 依赖 | 许可 | 用途 | 慎用理由与条件 |
|---|---|---|---|
| `swift-markdown-engine`（nodes-app） | Apache-2.0 | 编辑内核：原生混合渲染引擎（M2） | pre-1.0、单团队主导、API 不稳。**若采用，必须走 §5 的 fork+锁版本+接管能力条款**；是否采用本身留到 M1 spike 定（PRD §12.4） |
| `CodeEditTextView` / `CodeEditSourceEditor`（CodeEdit） | MIT | 编辑内核：源码模式起步（M1 spike 候选） | 许可 OK；风险在「API 随主项目波动、且它自己也在绕 TextKit 2 自绘」。作为 M1 spike 备选之一评估（PRD §12.4） |
| `swift-markdown-ui` / `Textual`（gonzalezreal） | MIT | 预览面板（原生候选） | `swift-markdown-ui` 已进维护模式、`Textual` 太新且 API 未稳；作为「WKWebView 预览」的原生替代**仅在需要时评估**，不押注（§6） |

#### ❌ 禁用（不引入到编译产物；仅可只读借鉴，见 §2.3）

| 依赖 | 原因 |
|---|---|
| `STTextView` | **GPLv3 + 商业双授权** —— 与 Apache-2.0 出站不兼容。**不链接、不分发**；其源码是 TextKit 2 避坑百科，**仅允许只读研读避坑**（§2.3） |
| `Down` | **实质停更**（最后提交约 2023-07，README 长期挂「寻找维护者」）；能力已被 `swift-markdown` + 自定义渲染取代（`docs/09`） |
| `Ink`（John Sundell） | **休眠 + 合规缺口**（最后提交约 2024-03，明确不追求完整 CommonMark 合规，评测有「部分文件渲染就是不对」的 dealbreaker）（`docs/09`） |
| `SwiftDown` | **已归档**（最后提交约 2024-02）——「SwiftUI 包装第三方编辑组件」的又一个弃坑案例（`docs/09`） |
| Electron / Tauri / 无头 Chrome（Awesomium 等嵌入式内核） | 架构红线（PRD §7）；且 `docs/03` 反复验证「小众/停维护的嵌入式渲染内核先于产品死亡」（Awesomium / Qt WebKit / NW.js 全部拖垮宿主产品） |

> **提醒**：`STTextView`、`Down`、`Ink`、`SwiftDown` 里有大量「已趟过的坑」和值得抄的架构。禁用的是**依赖它们**，不是**读它们**——只读借鉴规则见 §2.3。

### 2.3 「只读借鉴」而非「引入」的边界（针对 GPL/停更库）

对 `STTextView`（GPLv3）以及任何我们想学但不能链接的库，允许：

- **阅读源码理解 TextKit 2 的坑与解法**（例：`.layoutManager` 降级陷阱、滚动高度估算、FB bug 清单）。
- **借鉴通用思路/公开事实**（哪个系统 API 有 bug、绕过的大致方向）。

**明令禁止**：

- 复制粘贴 GPL 代码片段进我们的仓库（哪怕改写变量名）；
- 把 GPL 库的头文件/接口逐行照搬形成「换皮」实现；
- 引入 GPL 库作为链接依赖或分发它。

判断准则：**产出的是「我们自己写的、受启发的实现」，不是「对方代码的再表达」。** 有疑问时在 PR 里说明借鉴来源与自研程度。

### 2.4 编辑内核 vs WebView 子系统的许可差异

- **编辑内核依赖**（进原生二进制、静态/动态链接）：严格适用 §2.1。
- **WebView 子系统依赖**（KaTeX/Mermaid/Shiki 等 JS，作为**资源文件**打包）：同样必须许可兼容并随分发保留声明，但它们是「随 app 分发的资源」而非「链接的库」，MIT/BSD/Apache 都可安全 bundle（§4 管固定与安全，§2.6 管声明）。

### 2.5 外接 CLI（Pandoc 等）的许可处理

- **Pandoc 是 GPL**（复杂格式导出用，V2+）。**不 bundle、不静态链接**，而是**调用用户系统里自行安装的 `pandoc` 可执行文件**（独立进程），这样不构成衍生作品、不传染我们的许可。
- 规则：**凡 GPL 系工具，只允许「用户自备 + 我们 spawn 外部进程」模式，绝不随 app 分发其二进制**；若将来确需 bundle，必须先做 GPL 分发义务的法律核对（默认不做）。

### 2.6 Apache-2.0 的 `NOTICE` 传递义务（现在就定的合规动作）

- 我们发布 Apache-2.0 需维护自己的 `LICENSE` + `NOTICE`。
- **引入的 Apache-2.0 依赖（`swift-markdown`、可能的 `swift-markdown-engine`、`MathJax`）若带 `NOTICE`，其内容必须在我们分发物中保留/传递。**
- 全部第三方许可（含 MIT/BSD 的版权声明、vendored JS 的许可）汇总进一个 **`THIRD-PARTY-LICENSES` 清单**，随 release 分发；生成方式（手工维护 vs 工具生成）留到 M0 定（§6）。

---

## 3. 版本固定与供应链安全

### 3.1 版本固定（pin）策略

- **`Package.resolved` 必须提交进仓库并纳入 review**；它是我们依赖图的唯一真相源。
- SPM 版本区间规则：
  - 稳定的官方/组织库（`swift-markdown` 等）：用 `upToNextMinor`（`.upToNextMinor(from:)`），允许补丁/小版本，跨大版本人工评审。
  - **pre-1.0 / 单团队 / API 不稳的库（`swift-markdown-engine` 等）：锁到精确版本或精确 commit**（`.exact(...)` 或指向我们 fork 的固定 revision），**禁止用浮动 `branch`/`from: "0.x"`**（0.x 语义下 minor 即可含破坏性变更）。
- **不用指向上游 `branch` 的依赖**（构建不可复现）；唯一例外是指向**我们自己 fork 的、锁定 commit** 的依赖（§5）。

### 3.2 来源审查

- 优先选**可信组织**出品（`swiftlang`/Apple、ChimeHQ 等 TextKit 生态老牌方）。
- 新增依赖前**实际打开其仓库核对**：许可文件、最近提交、issue 响应、是否归档。**不凭印象**（许可会变——`STTextView` 前车之鉴）。
- 升级依赖时读 changelog / diff，不无脑跟最新。

### 3.3 不在运行时动态拉取/执行代码（安全红线）

这条直接对应 `docs/03` 里 Abricotine「渲染进程开 `nodeIntegration`、预览不可信文档即任意 JS 可访问本地文件」而死于安全债的教训：

- **WKWebView 只加载随 app 打包的本地资源**（`loadFileURL` / 自定义 URLScheme），**不从网络加载脚本/样式**；预览页设置 **CSP**，禁用远程 `script-src`。
- **不在运行时从远端下载并执行任何代码/插件**（KaTeX/Mermaid/Shiki 全部离线 bundle，不走 CDN）。
- **沙箱最小权限**：WebView 子系统按需最小 entitlement 访问本地图片资源，不给多余网络/文件权限。
- 未来 Skill 画廊（V2）「装前强制源码审阅」是这条原则的延伸（PRD §5.3），不在本文展开。

### 3.4 CVE / 安全更新

- **`swift-markdown` / `swift-cmark` 的安全更新要跟**：cmark-gfm 历史上集中修过多起多项式复杂度 DoS CVE（`docs/09`），我们的解析层是它的下游。
- vendored JS（KaTeX/Mermaid/Shiki）的安全公告也要盯，随其修复版更新 bundle。
- 具体的自动化（Dependabot / 定期审计脚本 / SRI 校验）配置留到 M0 CI 落地（§6）。

---

## 4. Vendored JS 资源（WebView 子系统）的固定与打包

- **KaTeX / Mermaid / Shiki 等 JS 及其字体资源，以固定版本 vendoring 进仓库（或作为受控构建产物），随 app bundle 离线分发**，不运行时从 CDN 拉取（§3.3）。
- 每个 vendored 资源在仓库里记录：**版本号、来源 URL、许可**（进 `THIRD-PARTY-LICENSES`）。
- 升级 vendored JS 按依赖升级同等对待（过 §1.2 闸、记 `decisions.md`）。
- **打包时对资源做完整性校验**（如构建期校验哈希 / SRI），防止被替换。
- KaTeX vs MathJax、Shiki vs highlight.js 的**最终取舍**留到 M1（§6）；本节只固定「如何管它们」，不固定「选哪个」。

---

## 5. 若采用 `swift-markdown-engine`：fork + 锁版本 + 接管能力

> **前置**：是否以 `swift-markdown-engine` 为混合渲染起点/上游，**留到 M1 spike 后定**（PRD §12.4，对比 fork 它 vs 从零 vs CodeEditTextView）。本节规定的是「**一旦决定采用，必须遵守的条款**」——现在就把条款定死，避免届时草率直连上游。

它的价值与风险（`docs/09`）：Apache-2.0、架构与我们目标完全一致、是目前**唯一开源的原生 TextKit 2 混合渲染引擎**；但 **pre-1.0、单一主导团队、API 不稳**——官方自己都建议锁版本。这正是 `docs/03` 反复上演的「**依赖内核先于产品死亡**」风险（Awesomium / Qt WebKit / NW.js 各自拖垮了宿主产品）。因此采用它必须满足**全部**下列条款：

1. **Fork 到我们自己的 org**（如 `colophon-app/swift-markdown-engine`），**SPM 依赖指向我们的 fork 并锁到精确 commit/tag**，绝不直连上游浮动分支（§3.1）。
2. **具备接管能力（不只是使用能力）**：
   - 至少一名维护者**通读其核心**（`MarkdownExtension` 协议、标记隐藏/几何/重排版的统一管理逻辑），能在上游停摆时自行修 bug、加特性。
   - 我们对它的改动尽量以**可 rebase 的补丁**形式维护，保持对上游的可追踪性。
3. **只取需要的模块**：它已拆分为核心 / 代码块 / LaTeX 三个产品——**按需引入以控制依赖表面积**（§1.2 第 3 闸），不整包吞下。
4. **回馈上游但不依赖其节奏**（Apache-2.0 善意 + 降低长期分叉成本），发布节奏、安全修复以我们 fork 为准。
5. **写明退出方案**：把「若上游死亡，我们维护 fork 的成本」记进 `decisions.md`；这与 PRD §7「风险集中在编辑器内核一个点上」的判断一致——**这是我们唯一允许深度绑架的依赖，因此对它的接管准备必须最充分**。

---

## 6. 留到实现时再定（M1 spike 后细化，现在不硬写死）

以下项**依赖尚未拍板的决策或未跑的 spike**，现在写死会变成技术债；先留边界、到点再定，并把结论记进对应里程碑的 `decisions.md`：

- **编辑内核起点最终选型**：fork `swift-markdown-engine` vs 从零 `NSTextView`+TextKit 2 vs `CodeEditTextView` —— 留到 **M1 spike**（PRD §12.4）。§5 只是「若选前者的条款」，不是「已选前者」。
- **编辑区代码块高亮方案**：`Highlightr`（起步）vs `HighlighterSwift`（若随 swift-markdown-engine 进来）vs `tree-sitter`+`Neon`（进阶）—— 取决于内核选型与性能实测（M1/M2）。
- **实时高亮是否引入 `SwiftTreeSitter`+`Neon`**：即「增量解析侧」是否需要，取决于 `swift-markdown` 全量解析在真实文档上的延迟表现（M1 实测）。
- **预览层是否用原生渲染替代/补充 WKWebView**：`swift-markdown-ui`/`Textual` vs `WKWebView` —— 涉及 Mermaid/KaTeX 只能在 WebView 跑的约束，留到有真实性能数据时定（M1/M2）。
- **数学与代码高亮的 WebView 侧最终取舍**：KaTeX vs MathJax（编辑反馈 vs 导出/学术）、Shiki vs highlight.js（观感 vs 体积）—— M1 出预览子系统时定。
- **Pandoc 集成形态**：确认为「用户自备 CLI + 外部进程」，但**接入时机（V2+）与具体调用/错误处理**留到那时（§2.5 已定许可处理原则）。
- **供应链自动化配置**：`Package.resolved` 审计、Dependabot、vendored JS 的哈希/SRI 校验、`THIRD-PARTY-LICENSES` 的生成方式（手工 vs 工具）—— 留到 **M0 CI/CD 落地**时一起定（§3.4、§2.6 已定原则）。
- **本规范译成英文并落为 `AGENTS.md` / `.claude/rules`**：建仓库、目录结构确定后进行（PRD §12.8）。
