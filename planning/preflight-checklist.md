# Colophon · 开工前主清单（Preflight Checklist）

> **用途**：进入 M0（建仓库 + 骨架）之前的总核对表。它把三处来源去重后归拢到一张表：
> ① 一份「完备性批判」找出的缺口清单；② [六份开发规范](standards/README.md)各自「留到实现时再定」的项；③ [PRD §12](PRD.md) 未决清单。
>
> **怎么用**：先读顶部小结（我们想清楚了什么 / 还需要你拍板什么），再按 A→E 逐组核对。每项一句话 + 指向对应规范或文档。**A（建仓库即需）与 B（M0 内做）是执行项**，进 M0 直接开工；**C（需先决策）是等 Evan 拍板的**；**D（早期 spike）是最该先做原型的技术未知数**；**E（持续贯穿）是每个里程碑 DoD 都要走查的**。
>
> 版本 v0.1 · 2026-07-21 · 依据 [PRD.md](PRD.md)、[ROADMAP.md](ROADMAP.md) 与 [standards/](standards/)。

---

## 小结：想清楚了什么 / 还需你拍板什么

### ✅ 我们已经想清楚了什么（六份规范已把原则层锁死）

- **产品与范围**：名称 Colophon、Apache-2.0、最低 macOS 15、英文优先、范围克制（不做终端/RAG/PKM/白板/同步/私有格式）——PRD §11 已锁。
- **架构骨干**：六层分层与单向依赖、**「文件夹即文库」而非 `NSDocument`**（[architecture §2.1](standards/architecture.md) 已决）、双轨解析、undo 入口在模型层、「AI = 语法树操作」的接口缝**已有一页 Swift 草案**（[architecture §7.2](standards/architecture.md)）。
- **数据安全线**：原子写 + byte-exact + 严格 UTF-8 + `NSFileCoordinator`/FSEvents 外部协调 + 回环抑制，**已写进** [architecture §3](standards/architecture.md)（缺口清单里「未写进工程规范」的顾虑已消解，剩验证）。
- **安全与隐私**：`WKWebView` 不可信内容隔离（CSP/净化/禁出网/最小 read-access）、App Sandbox + Hardened Runtime 自 M0 起开、security-scoped bookmarks、零遥测、崩溃上报 opt-in+去内容——[security 全文](standards/security-and-privacy.md)。
- **工程流程**：swift-format（已选定，不用 SwiftLint）、main 保护+短命分支+Conventional Commits、SemVer+Keep a Changelog、**测试金字塔与数据安全路径 release 门禁已定**、CI+签名公证流水线、社区文件全套已列——[engineering 全文](standards/engineering-process.md)。
- **依赖许可**：出站兼容规则 + 批准/慎用/禁用清单 + 版本固定 + `NOTICE` 义务 + `swift-markdown-engine` 采用条款——[dependencies 全文](standards/dependencies-and-licenses.md)。
- **设计与无障碍**：极简克制的设计语言、系统原生优先、Liquid Glass 门控、无障碍基线（含 Reduce Transparency/Motion）——[ui-and-design 全文](standards/ui-and-design.md)。

### 🟡 还需要你（Evan）拍板什么（详见 C 组，共 6 项）

1. **编辑内核起点**：fork `swift-markdown-engine` /（b）从零 TextKit 2 /（c）`CodeEditTextView`——依 D 组 spike 结果拍板。
2. **版本历史/checkpoint 存哪**：app 容器（`~/Library/Application Support/Colophon/`）vs 用户文件夹内隐藏目录——**关系到会不会污染用户的 git 仓库**。
3. **直分发的自动更新**：是否用 Sparkle 2（EdDSA appcast）+ 未来 MAS 走系统更新的三渠道模型。
4. **沙箱 / MAS 双渠道**：确认「首发即沙箱、MAS 作为显式架构目标（双渠道功能对等）」。
5. **UI mockup 定调**：出 1–2 张关键界面 mockup——它一并解锁「默认字体方向 / 排版数值 / 品牌强调色」三项子决策。
6. **MVP 编辑模式 staged**：确认 M1 只做「源码样式化 + 分屏」、M2 才上行内混合渲染。

> 另外 **7 个技术未知数需先做 spike 原型**（D 组），其中「编辑内核对比」spike 直接为决策 1 供数据。

---

## A. 建仓库即需（第一个 commit 前后就位，成本最低、承诺不可回撤）

| # | 项 | 一句话 | 依据/落点 |
|---|---|---|---|
| A1 | **i18n 通道第一天打通** | 建仓即加 `Localizable.xcstrings`（String Catalog），工程规范写死「所有面向用户字符串走 `String(localized:)`」，CI 加「检测硬编码 UI 字符串」lint；首发只出英文但通道打通、预留 RTL/复数。 | 缺口#10（新增，需补进 [engineering](standards/engineering-process.md)）；PRD §11「i18n 预留」 |
| A2 | **依赖/许可持续机制** | `NOTICE` + `THIRD-PARTY-LICENSES` 生成流程、SPM 许可扫描进 CI（禁 GPL/AGPL、白名单 MIT/Apache/BSD）、每次加依赖过四道闸、源文件加 SPDX 头。 | [dependencies §2.6/§1.2/§3](standards/dependencies-and-licenses.md)（原则已定，自动化 M0 落地）；缺口#13 |
| A3 | **社区健康文件全套** | `.github/`：CODE_OF_CONDUCT（Contributor Covenant 2.1）、SECURITY.md（GitHub Private Advisory + 支持版本 + 响应 SLA）、bug/feature issue forms、PR 模板、FUNDING.yml。 | [engineering §6](standards/engineering-process.md)（已完整规定，A 组只是执行）；缺口#14 |
| A4 | **工程一致性配置 + 红线编码成 lint** | 仓库根放 `.swift-format` + pre-commit/CI（`lint --strict`）；写自定义 lint 规则拦截 `.layoutManager`（TextKit 1 降级）与 GPL 依赖 import，把「文档提醒」升级成机器可执行卡点。 | [engineering §1/§4.5](standards/engineering-process.md)（swift-format 已选定；自定义 lint 规则待建）；缺口#22 |
| A5 | **不可回撤承诺 + dogfood 文件就位** | 第一个 commit 带 Apache-2.0 `LICENSE`；README 写产品宣言 + 两条不可回撤承诺（永久开源、本地 `.md` 唯一真相源永不引入私有格式）；仓库自己的 `AGENTS.md`/`CLAUDE.md` 当天建（dogfood 路线 B）。 | [ROADMAP §2](ROADMAP.md)；PRD §9 |

---

## B. M0 内做（骨架阶段完成，多数原则已定、此处是「产出物」）

| # | 项 | 一句话 | 依据/落点 |
|---|---|---|---|
| B1 | **byte-exact 保真契约成一页** | 把散在规范里的编码/行尾（LF/CRLF）/BOM/尾换行/混合行尾/非 UTF-8 策略汇成一页显式「保真契约」，作为 round-trip 测试的规格。 | [architecture §3.2](standards/architecture.md) 已分散覆盖，需汇总成文；缺口#16 |
| B2 | **测试三层 + round-trip 语料建起来** | ①byte-exact round-trip 语料（各种 frontmatter/围栏/CRLF/BOM/尾换行/非 UTF-8 → parse→serialize 逐字节相等或明确报错）②AST 操作单测 ③预览快照测试；round-trip 设为 CI 门槛。 | [engineering §4](standards/engineering-process.md)（策略已定，需建语料/fixtures）；缺口#17 |
| B3 | **错误处理哲学成文** | 定统一原则并给统一 error 呈现组件：数据完整性错误**绝不静默**（宁可挡住保存并显式提示）、可恢复错误就地非模态提示（呼应无弹窗）、所有错误可诊断（结构化日志）。写进工程规范。 | 缺口#18（新增，规范暂缺，需补进 [engineering](standards/engineering-process.md)/[architecture](standards/architecture.md)） |
| B4 | **崩溃上报立场 + Privacy Manifest** | 在 README 写死立场（默认零遥测、永不上传文档内容、崩溃上报 opt-in 优先 MetricKit 本地）；M0 加 `PrivacyInfo.xcprivacy` 并审计 Required-Reason API（文件时间戳/UserDefaults 等）。**含「崩溃上报到底做不做」的决定。** | [security §3.1](standards/security-and-privacy.md)（立场已定；privacy manifest + Required-Reason 审计为新增）；缺口#12 |
| B5 | **应用图标 + 最小品牌资产集** | 出一版可用图标（macOS 26 分层图标规范，Icon Composer 产 `.icon` + 各尺寸）、强调色、README 头图；确立 wordmark + 配色/字体令牌，与编辑器主题 token 统一。 | 缺口#20（新增）；PRD §12.8；[ui-and-design §5](standards/ui-and-design.md) token 化 |
| B6 | **AI 门 Swift 接口草案定稿** | 把 `DocumentReader`/`DocumentEditor`/`ActiveEditorState`/`StructuralEdit` 一页草案对齐 MCP 接口，确保 M1 写编辑核心时所有编辑（含 ⌘B/升降标题）都过这一层。 | [architecture §7.2](standards/architecture.md) **已有草案**，M0/M1 精化签名；缺口#21、PRD §12.9 |
| B7 | **发布身份与工程骨架** | Bundle ID、目录结构/target 划分（按层强制依赖）、CI 选型（GitHub Actions）、Xcode 工程（SwiftUI 生命周期 + 三栏壳 + 空 `NSTextView` 桥接 + 开/编/存 `.md` + 深浅色）。 | PRD §12.8；[engineering §1.3](standards/engineering-process.md)（目录树定案依 M1 spike，先给方向） |
| B8 | **签名公证流水线 + 沙箱趁空壳跑通** | tag 触发的 release workflow（codesign→notarytool→stapler→dmg/zip→GitHub Release→更新 Homebrew cask）；App Sandbox + Hardened Runtime 自 M0 开启；基础设施设自动续费。 | [engineering §5.2](standards/engineering-process.md)、[security §2](standards/security-and-privacy.md)、[ROADMAP §2](ROADMAP.md)（核心 M0 项，已充分规范） |

---

## C. 需先决策（等 Evan 拍板 —— 共 6 项）

> **状态（2026-07-21 已拍板）**：**C2**（版本历史/checkpoint 存 app 容器，不污染用户 git）、**C3**（直分发采用 Sparkle 2）、**C4**（首发即 App Sandbox + Hardened Runtime，MAS 为显式目标、双渠道功能对等）、**C6**（MVP 走 staged：M1 源码+分屏，M2 混合渲染）**均已确认**。**C1**（编辑内核起点）待 **D1 spike** 数据后定。**C5**（UI mockup）进行中。

| # | 决策 | 选项 / 建议 | 为什么现在定 | 依据 |
|---|---|---|---|---|
| C1 | **编辑内核起点** | （a）fork `swift-markdown-engine` /（b）从零 `NSTextView`+TextKit 2 /（c）`CodeEditTextView` —— **依 D1 spike 对比后拍板**（建议对比 a 与 c）。 | 决定混合渲染到达速度与依赖风险；不先定会把文本操作与 AST 操作耦合死。 | PRD §12.4；[architecture §8](standards/architecture.md)、[dependencies §6](standards/dependencies-and-licenses.md) |
| C2 | **版本历史/checkpoint 存哪** | 建议存 app 容器（`~/Library/Application Support/Colophon/`）+ security-scoped bookmark + 内容指纹映射回用户文件；**绝不默认往用户文件夹写隐藏目录**（如要则 opt-in 且 .gitignore 友好）。 | 目标文库几乎必然本身是 git 仓库，写快照进文件夹会污染 git、触发无谓 diff——「file over app」与「app 要存状态」的真实张力。 | 缺口#4；[architecture §3.5](standards/architecture.md)、[security R4.5](standards/security-and-privacy.md)（实现方向留白，需拍板存储位置） |
| C3 | **直分发的自动更新机制** | 建议三渠道模型：直分发用 **Sparkle 2**（EdDSA appcast，托管 GitHub Releases）+ Homebrew cask + 未来 MAS 走系统更新；M0 就把 Sparkle 接进空壳。 | 直分发无自更新 = 普通用户永远停在旧版，季度发版的「项目活着」信号传不到已安装用户。 | 缺口#11；[security R3.4](standards/security-and-privacy.md)（Sparkle 属实现细节，需决定采用与否） |
| C4 | **沙箱 / MAS 双渠道定位** | 确认「首发即 App Sandbox + Hardened Runtime、MAS 作为显式架构目标、双渠道功能对等」；把 MAS 约束转成显式清单（文件夹一律 bookmark、禁绝对路径假设、避免任意子进程）。 | 沙箱直接约束文件监听/MCP helper/localhost/JSCore/WKWebView；若 M0 不按沙箱兼容写文件层，后期加沙箱等于重写。 | 缺口#1；[security §2](standards/security-and-privacy.md)（沙箱原则已定 R2.1–R2.5，需 Evan 确认 MAS 为显式目标） |
| C5 | **UI mockup 定调** | 进 M1 UI 前出 1–2 张关键界面 mockup（单栏纸面态、三栏管理态、分屏预览、命令面板、frontmatter 表单态），定死字体/版心行宽/标题层级/品牌色锚点/玻璃用量。**一并解锁**：默认字体方向（等宽/衬线/sans）、精确排版数值、品牌强调色具体色值。 | 审美与克制是核心护城河却无视觉锚点；直接写 SwiftUI 易长成「默认样式 app」，返工成本高。 | 缺口#19；PRD §12.7；[ui-and-design §4/§9](standards/ui-and-design.md)（三项子决策明确「留到 mockup 后定」） |
| C6 | **MVP 编辑模式 staged** | 建议 staged：M1 先「源码样式化 + 分屏预览」，M2 才上行内混合渲染（避免一上来啃最难的坑）。 | 一次性梭哈混合渲染 = 「推倒重写」死亡螺旋高发；先发货再增强。 | PRD §12.5；[ROADMAP §1/§3](ROADMAP.md) |

> **说明**：C1 的拍板依赖 D1 的 spike 数据——先做原型、再做决定。C2/C3/C4 是纯策略决策，可先拍；C5 依赖出 mockup。

---

## D. 早期 spike 验证（最该先做原型的技术未知数 —— 共 7 项）

> ROADMAP 只点名 TextKit 2 要早 spike，但同等致命的未知数不止这一个。**每个 spike time-boxed，出「行/不行 + 坑 + 决策」记入对应里程碑的 `decisions.md`**。这是缺口#6 要的那张「集中的风险 spike 清单」。

| # | Spike | 验什么 | 依据 |
|---|---|---|---|
| D1 | **编辑内核对比 + TextKit 2 混合渲染核心坑** | 对比（a）fork engine /（c）CodeEditTextView（也评估 b 从零）；验语法隐藏 + 光标处还原源码 + **accessibility tree 不断裂**（VoiceOver 能读正文）+ 长文档滚动高度稳定（不跳）。直接为 **C1** 供数据。 | [architecture §6.2/§8](standards/architecture.md)、[ROADMAP §6](ROADMAP.md)；缺口#6、#8 |
| D2 | **byte-exact round-trip** | 各种 frontmatter / 代码围栏 / CRLF / BOM / 尾换行 / 非 UTF-8 → parse→serialize **逐字节相等或明确报错**；确认智能标点全程关闭。 | [architecture §3.2](standards/architecture.md)、[engineering §4.4](standards/engineering-process.md)；缺口#5、#16、#17 |
| D3 | **FSEvents 无弹窗刷新 + 回环抑制** | 外部（Agent）改盘上文件即时刷新、无「已在磁盘更改」弹窗；能区分「自己写的」和「外部写的」，避免自触发刷新循环。 | [architecture §3.3](standards/architecture.md)；缺口#5、#6 |
| D4 | **WKWebView 60fps 双向滚动同步** | ⌘\ 分屏预览编辑↔预览双向滚动同步稳定 60fps（同步坏了是口碑黑洞）。 | [ui-and-design §1.4/§7.6](standards/ui-and-design.md)；缺口#6 |
| D5 | **原子写 + NSFileCoordinator + 网盘并发** | write-to-temp + 原子 rename（或 `replaceItem` 保 inode/权限/xattr）、经 `NSFileCoordinator`；**模拟 iCloud/网盘延迟与并发写、冲突副本**，验不丢字节、不写坏文件。 | [architecture §3.1/§3.4](standards/architecture.md)；缺口#5 |
| D6 | **MCP stdio helper × App Sandbox 可行性（前瞻）** | 沙箱化的 MAS app 能否分发并以子进程 stdio 拉起 MCP helper、拿到活动编辑器状态。**做该功能前必须有结论**，避免 V2 撞墙。 | [security R2.5](standards/security-and-privacy.md)、[architecture §7](standards/architecture.md)；缺口#1、#6 |
| D7 | **不可信 md 安全** | 打开恶意大表格/深嵌套 md **不卡死**（解析设大小/嵌套深度/超时上限，防 swift-cmark 血统的多项式复杂度 DoS）+ 预览 **不泄露远程资源**（默认不加载远程图片，CSP `connect-src 'none'`）。 | [security §1](standards/security-and-privacy.md)、[dependencies §3.4](standards/dependencies-and-licenses.md)；缺口#7 |

---

## E. 持续贯穿（每个里程碑 DoD 都要走查）

| # | 项 | 一句话 | 依据 |
|---|---|---|---|
| E1 | **无障碍基线** | 全键盘可达、VoiceOver 能朗读编辑区与预览、支持 app 自有正文字号设置、遵守系统对比度（WCAG AA）、RTL/双向文本可用；每里程碑 DoD 走查（含混合渲染 spike 里验 a11y tree 不断裂）。 | [ui-and-design §6/§8](standards/ui-and-design.md)；缺口#8 |
| E2 | **Reduce Transparency / Reduce Motion / Increase Contrast** | 用系统语义材质（不硬编码模糊值），监听三项无障碍开关；玻璃层在降低透明度时回退到不透明可读态、动效在 Reduce Motion 下降级；纳入逐里程碑走查清单。 | [ui-and-design §3.4/§6](standards/ui-and-design.md)；缺口#15 |
| E3 | **性能基准 harness** | 早建轻量 harness：定预算（冷启动、稳态内存、打字延迟 p95、《白鲸记》/万行滚动帧率），用 XCTest metrics/os_signpost + 标准化大文档语料；关键指标进 CI 做回归门槛；同机对比 Typora/Obsidian 出可复现对比表。 | 缺口#9（新增，规范暂缺）；PRD §10 成功标准 |
| E4 | **依赖许可持续扫描** | 每次加/升依赖过四道闸、CI 白名单挡 GPL/AGPL、`Package.resolved` 进 review、跟 `swift-markdown`/`swift-cmark` 安全更新（cmark-gfm 有多起 DoS CVE）。 | [dependencies §1.2/§3](standards/dependencies-and-licenses.md)（建仓库设 A2，此处是长期执行面）；缺口#13 |
| E5 | **玻璃效果 macOS 26 真机验证** | Liquid Glass 观感与回退行为在 macOS 26 真机验证（macOS 无模拟器）；同时在 macOS 15 验回退经典外观、无半截玻璃。涉及玻璃的 UI 测试短期内可能跑不进 CI，需人工走查。 | [ui-and-design §3.3](standards/ui-and-design.md)、[engineering §7](standards/engineering-process.md) |
| E6 | **dogfooding + 季度小发版** | 自己用 Colophon 写本项目所有 `.md`；每次「要是编辑器能帮我做这个就好了」= 一条真实需求；季度小发版传「项目活着」信号。 | [ROADMAP §6](ROADMAP.md)；PRD §8 |

---

> **流程衔接**：A/B 项进 M0 直接开工；进入 M0/M1 时按 [planning/README.md](README.md) 流程，把本清单相关项固化进 `Mx/plan.md` 的任务清单与 `Mx/decisions.md`。C 组每拍一项、D 组每跑一个 spike，都把结论回填 `decisions.md`，并把对应规范里的「留到实现时再定」上移为「已定」。
