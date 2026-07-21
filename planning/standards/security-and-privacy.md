# 安全与隐私规范

> **用途**：本文是 Colophon 的《安全与隐私规范》，作为「开工准备阶段」的团队约定与 **AI 编码助手的规则文件**（dogfood 路线 B）。凡涉及内容隔离、沙箱、隐私默认、数据安全的实现，都必须遵守本文的红线；与本文冲突的代码/依赖不得合入。
>
> 版本 v0.1 · 2026-07-21 · 依据 [`../PRD.md`](../PRD.md)、[`../ROADMAP.md`](../ROADMAP.md) 与 [`../../docs/`](../../docs/) 调研（尤其 03 Abricotine、08 隐私、09 技术栈、15 MCP 安全、18 CVE 教训、19 §6 安全模型）撰写。
>
> **语言约定**：本文当前用中文，便于团队理解；未来搬进真实仓库作为 `AGENTS.md` / `.claude/rules/*.md` 时译为英文（代码/API/术语/文件名保持英文）。
>
> **「现在就定」vs「留到实现时再定」**：本文正文里以红线（必须/禁止）形式给出的是**现在就定的原则**——它们不依赖任何未决的实现选型，越早锁死成本越低（Abricotine 的教训就是安全债不能拖，docs/03）。凡依赖 M1 spike 结论或后置里程碑（V1/V2 的 AI/MCP）的**实现细节**，一律进文末「留到实现时再定」一节，现在不硬写死。

---

## 0. 威胁模型与总原则（先立场，后细则）

Colophon 是**本地优先、无账号、无服务器、不生成内容**的原生 macOS 编辑器（PRD §3、§5.4）。这决定了我们的攻击面比云端 AI 工具小得多，但有三处必须第一天做对：

1. **预览层（WKWebView）渲染的是不可信内容。** 用户打开的 `.md` 可能来自网络剪藏、也可能是外部 Agent 产出（路线 B 的常态），其正文可含恶意 HTML / 脚本 / prompt injection。**预览必须当「渲染不可信文档」来设计**——这正是 Abricotine 栽掉的地方（docs/03）。
2. **沙箱与发行渠道的能力边界要早定。** MAS 强制 App Sandbox；官网直装也应沙箱 + 硬化运行时（公证前提）。哪些能力越不过沙箱、双渠道是否有功能差异，必须在设计期决策，不能到 V2 才发现撞墙（Elephas 教训，docs/08）。
3. **AI/MCP 是未来的最大隐私责任面，原则现在立、实现留到后面。** MVP 不做任何具体 AI（PRD §5.1、ROADMAP §3.4），但「把本地文库暴露给 Agent」是真实攻击面（Obsidian Local REST API 路径穿越 CVE，docs/18）。我们现在只锁**默认 opt-in、可整体关闭、发送前可视化、最小权限 + 逐操作确认 + 审计**这套原则（docs/19 §6），具体接口留到 V1/V2。

一条贯穿全文的准则：**安全架构是第一天的设计，不是以后再补的功能**（Abricotine 因「渲染进程开 nodeIntegration，且永不会修」而被作者亲手放弃，docs/03）。

---

## 1. WKWebView 预览的内容隔离

> 背景：编辑区是原生 `NSTextView`(TextKit 2)，**WKWebView 仅用于预览 / 导出 / 图表渲染**（Mermaid、KaTeX、Shiki），这既是 PRD §7 的架构红线，也是安全边界——编辑不经 Web，Web 不碰编辑。以下规则把 Abricotine 的 nodeIntegration 类漏洞（docs/03，issue #254：预览不可信文档时任意 JS 可访问本地文件与系统 API）挡在门外。

### 1.1 红线（现在就定）

- **R1.1 预览资源一律本地、可信、离线。** KaTeX / Mermaid / Shiki 等 JS/CSS bundle **必须**随 app 打包、离线加载，**禁止**从网络拉取任何脚本/样式/字体（对标 MacMD「bundled 引擎离线渲染」，docs/18）。加载用 `loadFileURL(_:allowingReadAccessTo:)`，且 `allowingReadAccessTo` **必须**限定到「打包的预览资源目录」这一个最小目录，**禁止**授予文库目录、用户主目录或 `/`。
- **R1.2 预览内容视为不可信，默认净化原始 HTML。** Markdown 里的 raw HTML **必须**在注入前净化：剥离 `<script>`、内联事件处理器（`onclick` 等）、`javascript:` URL、`<iframe>`/`<object>`/`<embed>`。是否保留「安全子集的 raw HTML」及其白名单，属实现细节（见文末）。
- **R1.3 强制 Content-Security-Policy。** 预览页**必须**带严格 CSP：`default-src 'none'`；`connect-src 'none'`（预览层禁止任何出网）；`object-src 'none'`；`frame-src 'none'`；`base-uri 'none'`；`script-src` / `style-src` / `img-src` / `font-src` 仅放行打包资源与必要的本地来源。精确策略串留到 M1 spike（取决于 KaTeX/Mermaid 是否需要 `'unsafe-inline'`，见文末）。
- **R1.4 禁止预览层出网与自由导航。** WKWebView **必须**设 `navigationDelegate`，除首次本地加载外**取消一切导航**；文档内的外部链接**必须**交由系统默认浏览器打开（`NSWorkspace.open`），不得让 WebView 自身跳转。默认**不加载远程图片/资源**（远程图片等同追踪像素，泄露阅读行为与 IP）；是否提供「允许远程图片」的显式 opt-in 属实现细节。
- **R1.5 JS↔Swift 消息桥最小化 + 输入校验。** 
  - **禁止**暴露任何通用的「读文件 / 写文件 / 执行命令 / eval」桥接方法。
  - 消息处理器（`WKScriptMessageHandler`）数量**必须**压到最少，方向尽量单向：Swift→JS 推送「渲染后的 HTML + 滚动同步指令」，JS→Swift 仅回传「滚动位置、链接点击」等无副作用信号。
  - 每个从 JS 收到的 payload **必须**在 Swift 侧做 schema 校验（类型、取值范围、路径是否在允许集内）后才使用；**禁止**用 JS 传来的字符串拼接文件路径或 shell 命令。
  - **禁止**把用户/Agent 内容作为代码 `evaluateJavaScript` 执行；内容一律作为数据传入（`postMessage`/DOM 文本节点），不进代码路径。
- **R1.6 与导出/打印一致。** HTML/PDF 导出走同一套「本地可信资源 + 净化内容 + 严格 CSP」的 WebView 管线；PDF 走 WebKit/PDFKit（PRD §7），**禁止**引入无头 Chrome。

### 1.2 为什么是这些（可执行的理由）

Abricotine 是 Electron + nodeIntegration，我们是 WKWebView——技术栈不同，但**等价的自毁枪口**是：给预览层开任意 JS、给它宽泛的本地文件访问、用宽松的桥把不可信内容接进来（docs/03 小结第 4 条：「渲染与安全架构第一天做对，严格内容隔离沙箱」）。R1.1–R1.5 就是逐条堵死这些枪口。sandbox 下 WebView 访问本地资源需正确配 entitlement（docs/09），这与「最小 read-access 目录」要一起设计（见 §2）。

---

## 2. App Sandbox 与 entitlements

> 背景：PRD §11 已定最低 macOS 15、用 macOS 26 SDK 编译；M0 完成定义即「签名 + 公证」。公证要求硬化运行时；MAS 要求 App Sandbox。docs/08（Elephas）的硬教训：**「App Store 沙盒版无法提供全局写作功能，完整版需官网直装」——发行渠道要早做决策。**

### 2.1 红线（现在就定）

- **R2.1 M0 起即开启 App Sandbox + Hardened Runtime。** 趁 app 还是空壳、成本最低时把沙箱与公证跑通（呼应 ROADMAP §2「最烦的工程流水线在成本最低时锁死」）。**禁止**先裸奔开发、以后再补沙箱——沙箱会改变文件访问模型，晚补等于返工。
- **R2.2 文件夹访问用 security-scoped bookmarks。** 文库是「用户自选文件夹」（PRD §5.1）。沙箱下持久访问**必须**用 security-scoped bookmark 持久化，运行时 `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` 成对使用；**禁止**存裸路径字符串再直接读写（沙箱下无效）。FSEvents 文件监听（「无『已在磁盘更改』弹窗」，PRD §5.1）在持有该 scope 期间对该文件夹生效。
- **R2.3 entitlements 最小化。** 只申请当前功能真正需要的能力：
  - 文库读写：`com.apple.security.files.user-selected.read-write` + bookmarks。
  - **禁止**申请 `com.apple.security.files.all` 或任何「全盘访问」类能力。
  - **网络出站（`com.apple.security.network.client`）在 MVP 不申请**——MVP 无任何联网需求（无遥测、无账号、无 AI，分发走 Homebrew/GitHub 而非应用内下载）。等 AI/MCP 落地（V1/V2）再按需最小追加，并同步更新本规范。
- **R2.4 沙箱能力边界写进设计假设。** 任何「作用于其它 app 的系统级能力」（如 Elephas 式全局改写）在 MAS 沙箱下不可行——我们**不做**这类功能（PRD 范围克制）。系统 AI 能力经 Writing Tools 在**本 app 内**经 TextKit 2 使用，沙箱内合规（docs/08 iA/Ulysses 路线）。
- **R2.5 双渠道功能差异必须显式决策，不得撞见。** 官网直装（GitHub Releases + Homebrew）与未来 MAS 版**默认保持功能对等**：两者都沙箱化、都不依赖任何越沙箱能力，从而一套代码/一套构建服务双渠道。**一旦**出现某功能越不过 MAS 沙箱（当前已知的最可能点：V2 的 **MCP stdio launcher helper 二进制**——需随 app 分发并被 Agent 以子进程 stdio 启动，docs/15、docs/19 §四；沙箱化 MAS app 能否分发/拉起该 helper 存疑），**必须**在做该功能之前把「MAS 是否收录 / 双渠道是否分叉」当作一次正式决策记录进 `decisions.md`，而不是事后发现（Elephas 教训，docs/08）。

### 2.2 现在就定 vs 留到实现时

- **现在就定**：开沙箱 + 硬化运行时的时机（M0）、bookmarks 方案、「双渠道对等 + 分叉需显式决策」的原则、绝不申请全盘访问。
- **留到实现时**：entitlements plist 的精确清单（随功能演进逐版本敲定）、是否在 launch 时就存在 MAS 渠道、MCP helper 与 MAS 沙箱的兼容结论（见文末）。

---

## 3. 隐私默认

> 背景：docs/08 小结「隐私要工程化而非口号化：默认本地、发送前可视化将上传的内容、可整体关闭 AI」；docs/18「不默认开启、静默上传的 AI」；MacMD 以 **Zero telemetry** 立信。PRD §3 信念 5「AI 解耦、可选、可关」。以下把这些原则落成红线。

### 3.1 遥测与崩溃上报（现在就定）

- **R3.1 默认无遥测。** MVP **禁止**任何分析/埋点/心跳/静默更新检查（MacMD「无任何网络连接/更新检查/分析」是我们的标杆，docs/18）。若未来确要做产品分析，**必须**是显式 opt-in、匿名、默认关闭、在隐私说明里逐项列出，且**永不**包含文档内容。
- **R3.2 崩溃上报若做，必须 opt-in + 匿名 + 去内容。** 默认关闭；开启后**必须**在上报前剥离文档正文、文件路径、文库名、用户可识别信息；**禁止**把任何 `.md` 内容或路径写进崩溃包。
- **R3.3 绝不上传用户内容。** 这是首屏承诺（docs/08）。在没有 AI 的 MVP，这等于**根本不联网**（见 R2.3）。任何未来联网路径都要能追溯到一次显式用户同意。
- **R3.4 应用内自动更新的联网要透明且分渠道。** 官网直装若采用 Sparkle 类自动更新（联网），**必须**在隐私说明里写明并可关闭；MAS 版走 App Store 更新、不含 Sparkle——这是一处已知的合理双渠道差异（须按 R2.5 记录）。是否用 Sparkle 属实现细节（见文末）。

### 3.2 未来 AI / MCP 层的隐私原则（原则现在立，实现留到 V1/V2）

> MVP 只留「架构缝」不做 AI（PRD §5.1）。但以下原则**现在就写死**，供 AI 层落地时对齐；实现接口见 docs/19 §6、docs/15，届时细化。

- **R3.5 默认 opt-in、可整体关闭。** AI/MCP 能力默认**关闭**（MarkMorph 姿态，docs/18），并提供一个「AI 只读 / 全局关闭」总闸（PRD §3 信念 5、docs/19 §6.2）。
- **R3.6 发送前可视化。** 任何内容离开设备前，**必须**先向用户展示「将要上传的确切内容」（docs/08、docs/18、docs/19 §6.3）。
- **R3.7 最小权限 + 逐操作确认 + 审计（人在环路是硬要求）。** 
  - 作用域最小化：MCP server 只在用户**显式选定的 vault 文件夹**内工作，尊重 client 的 **Roots**；默认排除 `.git`、`.env`、密钥类文件与加密/受保护笔记（docs/15、docs/19 §6.3）。
  - 读写分级：读类在作用域内可默许，**写/移动/删一律强制确认**（不是 SHOULD 而是 MUST，docs/19 §6.2）；确认展示「哪个操作、影响哪篇、diff 摘要」。
  - 全量审计日志：记录每一次工具调用（谁、何时、改哪篇、diff 摘要，docs/15、docs/19 §6.4）。
- **R3.8 BYOK 密钥进 Keychain。** 若走 BYOK（PRD/调研倾向，docs/08 SoloMD 用 OS keychain），API key **必须**存 Keychain，**禁止**明文落 plist/UserDefaults/日志/崩溃包。
- **R3.9 本地文库经 HTTP 暴露，第一天做对（CVE 教训）。** 传输**默认走 stdio**（无端口、无鉴权面，docs/15）。**若**开 localhost HTTP：
  - **必须**鉴权（本地 bearer token）；
  - **必须**做路径校验——规范化路径后确认落在 vault root 内、拒绝 `../` 穿越（直接对应 Obsidian Local REST API 的已认证路径穿越 CVE **GHSA-62gx-5q78-wrvx**，v4.1.3 于 2026-06 修复，docs/18）；
  - **必须**最小权限、默认仅 localhost、可关闭；
  - **禁止** token passthrough（把 client token 原样转发上游，是 confused deputy 温床，docs/15）；localhost token 短时有效。
- **R3.10 把文库内容当不可信输入。** vault 里的 Markdown（尤其网络剪藏、Agent 产出）可能含 prompt injection（docs/19 §6.1 lethal trifecta：我们的 server 提供「访问私有数据」这一环）。设计 AI 层时**必须**把爆炸半径压到最小——最小权限 + 逐操作确认 + 审计是唯一防 confused deputy 的手段。

---

## 4. 数据安全即隐私

> 背景：PRD §3 信念 2「file over app」、§9 不可回撤承诺「本地 `.md` 唯一真相源、永不引入私有格式、数据可随时导出」；docs/03 小结「数据自由是底线，凡专有格式都成口碑污点（Boostnote CSON）、Laverna 死于自建同步」；docs/19 §6.5「删除默认进废纸篓不硬删」。

- **R4.1 本地优先、纯 `.md` 唯一真相源。** 文档就是磁盘上的纯 `.md`（+ 可选 YAML frontmatter），**禁止**引入任何私有/二进制存储格式（Boostnote CSON 之鉴，docs/03）。同步交给 iCloud Drive / 网盘 / Git，**禁止**自建同步服务器（Laverna 死于同步，docs/03）。
- **R4.2 随时可导出、零门槛、永不付费墙。** 导出能力（Markdown / HTML / PDF，后续 Pandoc）**禁止**设为付费功能（PRD §5.4）。
- **R4.3 删除进废纸篓，不硬删。** 删除文件**必须**走 `FileManager.trashItem` / 系统废纸篓，**禁止**直接 `removeItem` 硬删用户文档（docs/19 §6.5；也符合本项目对「永久删除数据」的安全底线）。未来 MCP `delete_note` 默认 `toTrash=true`（docs/19 §四）。
- **R4.4 保存字节保真，不静默损坏。** 保存**必须** byte-exact：关闭智能引号/破折号/自动更正（否则破坏 frontmatter 与代码 fence）；遇非 UTF-8 **报错而非静默损坏**（MacMD 教训，PRD §5.1、docs/18）。数据完整性即数据安全——这条同时归《编辑与正确性规范》，此处从「不损坏用户数据」角度重申。
- **R4.5 版本历史优先本地、可回滚。** 基于文件系统的版本历史 / 快照（PRD §5.1）；未来「Agent 每次写入前打 checkpoint、可回滚」（docs/19 §6.5）作为 AI 编辑安全网。具体机制（快照 vs 内置 Git）留到实现时。
- **R4.6 笔记加密（V2）留到实现时。** PRD §5.3 的「笔记加密」若做，倾向「以可移植 md fence 存加密块」（HelixNotes `helix-secret` 范式，docs/18），即加密而不破坏纯文本可移植性；具体方案后置。

---

## 5. 留到实现时再定（M1 spike 后 / V1-V2 落地时细化）

以下项**依赖未定的实现选型或后置里程碑**，现在不硬写死，避免过早锁死：

1. **预览层精确 CSP 串**：`script-src`/`style-src` 是否被迫放行 `'unsafe-inline'`（取决于 KaTeX/Mermaid/Shiki 打包后对内联脚本/样式的要求）——M1 预览 spike 时定，并尽量隔离到最小范围。
2. **raw HTML 处理策略**：默认净化已定（R1.2）；「是否保留安全子集 raw HTML + 具体标签/属性白名单 + 用哪个净化库」M1 定。
3. **WKWebView 精确配置与桥 schema**：`WKWebViewConfiguration` 各开关、`WKContentWorld` 隔离、消息处理器的最终名单与每条消息的校验 schema——随预览实现敲定（原则见 R1.5）。
4. **远程图片/资源**：默认不加载已定（R1.4）；「是否提供 opt-in 允许远程图片、其 UX 与风险提示」留到实现时。
5. **entitlements plist 精确清单**：随功能演进逐版本确定（原则见 R2.3：最小化、禁全盘）。
6. **发行渠道分叉**：launch 时是否已有 MAS 渠道；**MCP stdio launcher helper 与 MAS 沙箱的兼容结论**（V2 前必须决策，见 R2.5）；官网直装是否用 Sparkle 自动更新（联网，见 R3.4）。
7. **崩溃上报**：到底做不做；若做，选型与「opt-in + 匿名 + 去内容」的具体实现（原则见 R3.2）。
8. **AI/MCP 完整安全模型**：token 生命周期、Roots 处理、文件夹/标签级 allowlist/denylist 的 UX、审计日志格式、Elicitation 确认 UI、MCP Apps 沙箱 diff 卡片——V2 按 docs/15、docs/19 §6 细化（原则见 R3.5–R3.10）。
9. **发送前可视化与 BYOK 存储的具体 UX**：AI 落地（post-MVP）时定（原则见 R3.6、R3.8）。
10. **笔记加密方案**（R4.6）与 **AI 文本标注（Authorship）落盘方式**（docs/19 §6/§三 V2-8）：V2 决定。
11. **版本历史机制**：文件系统快照 vs 内置 Git vs checkpoint 的具体实现（原则见 R4.5）。

> 每落地一项，把结论回填进对应里程碑的 `decisions.md`，并同步更新本规范对应红线（把「留到实现时」上移为「已定」）。
