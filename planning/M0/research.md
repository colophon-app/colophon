# M0 工程地基调研（research）

> **用途**：本文是 M0（立项骨架）的工程调研汇总，是写 [`plan.md`](./plan.md)（可照做步骤清单）的直接输入。目标 = [`overview.md`](./overview.md) 的三件事：**地基正确 + 不可回撤承诺就位 + 最烦的工程流水线趁空壳跑通**；DoD = 能开/编/存一个 `.md`、app 签名公证能在别人机器双击打开、CI 绿、i18n 通道就位、Sparkle 接通。全文对齐 [`../standards/`](../standards/) 各规范（引用其小节号），凡与调研冲突以 standards 为准。
>
> **数据新鲜度提醒（务必读）**：本文覆盖的是**版本敏感**内容（Xcode 26 / macOS 26 SDK / 2026 年的 GitHub Actions runner 镜像与 Apple 工具链）。核心事实已于 **2026-07-21** 联网核实到一手来源（Apple 官方文档、GitHub runner-images 仓库、Sparkle 官方）。**但工具链每月漂移**——落地写 `plan.md`/CI 时，凡涉及「runner 默认 Xcode 版本、镜像内可选 Xcode 列表、action 主版本号、Apple 角色/证书要求」的具体值，都要以官方最新为准再核对一遍。查不到的写「未证实」，见各节标注。
>
> **外部前提（Evan 需先准备，是 DoD#2 硬前提）**：
> - **Apple Developer Program 账号**（约 $99/年）——签名公证需要 **Developer ID Application 证书** + 用于 `notarytool` 的 **App Store Connect API Key（Team Key，Developer 角色）**。**账号/证书审核可能数天，立刻开始注册**。证书未到手前，CI 的 build/test/lint 可先用 `CODE_SIGNING_ALLOWED=NO` 独立跑绿，签名公证 release 流水线待证书就位再联调。
> - **GitHub org 创建权限**（建 `colophon-app`）。
> - （可选）**域名**（如 `colophon.app`）——影响 Bundle ID 选型；无自有域名时用 `io.github.colophon-app.Colophon`。

---

## 第一节 · 仓库结构 · 治理 · 许可自动化

### 1.1 要点小结

- **工程形态**：SPM **不能**构建 macOS `.app` target，M0 必须有 `.xcodeproj`。M0 首选**直接提交单 target 的 `Colophon.xcodeproj`**（零额外构建依赖，契合「极小维护面」）；XcodeGen / Tuist 是又一层会腐烂的构建依赖，留到 M1 模块化再评估。依赖走 Xcode 的 SPM Package Dependencies，**`Package.resolved` 必须提交**。
- **不可回撤承诺**：第一个 commit 就带 **Apache-2.0 `LICENSE` 全文**（GitHub 靠 licensee 逐字匹配才出许可徽章）+ `NOTICE` + `README`（两条承诺：永久开源、本地 `.md` 唯一真相源永不引入私有格式）。
- **治理**：用 **Rulesets**（非 classic 分支保护）保护 `main` + squash + 线性历史 + required checks；Conventional Commits 用**服务端 Action** 兜底（本地 hook 可被 `--no-verify` 跳过）。
- **格式化**：`swift-format` 自 Xcode 16 起**随工具链发布**，统一 `xcrun swift-format`，别再单独引 SPM 二进制依赖（engineering-process §1.1/§1.2）。
- **许可自动化**：源文件 SPDX 头 +（可选全量）REUSE 合规；CI 用 allow-list 挡 GPL/AGPL；`THIRD-PARTY-LICENSES` 用工具从 SPM checkout 生成，并履行 Apache `NOTICE` 传递义务（dependencies-and-licenses §2.6）。
- **dogfood 路线 B**：仓库根 `AGENTS.md` 作跨工具主文件，`CLAUDE.md` 作薄指针 + `.claude/rules/*.md`；把 standards 精炼译成英文，**人手写、信号密度优先**（LLM 灌水会降成功率、涨成本）。

### 1.2 可执行步骤（命令 / 配置 / 文件名）

1. **建 org + repo**：`gh repo create colophon-app/colophon --public`。
2. **第一个 commit 三件套**：
   - `LICENSE`：用 GitHub 新建仓库的 Apache-2.0 模板，或 `gh api /licenses/apache-2.0 --jq .body > LICENSE`（保证 licensee 逐字识别 → 出许可徽章）。**不要手改正文**。
   - `NOTICE`：首行 `Colophon` + `Copyright 2026 The Colophon Authors`。
   - `README.md`：产品宣言 + 写死两条不可回撤承诺。
3. **目录树**（对齐 engineering-process §1.3 领域分组、architecture §1.3 按层）：
   - 源码 `Colophon/`：`App/ Editor/ Parsing/ Document/ FileSystem/ Preview/ AgentFiles/ DesignSystem/`（M0 只填 `App/ Editor/ Document/ FileSystem/`）。
   - `ColophonTests/`、`ColophonUITests/`（镜像源码结构）。
   - `.github/`、`docs/`、`planning/`、`LICENSES/`（REUSE 许可全文）、`Resources/`（vendored JS 留位）。
   - 仓库根：`LICENSE NOTICE README.md CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md .gitignore .swift-format REUSE.toml AGENTS.md CLAUDE.md ExportOptions.plist`。
4. **`.gitignore`**：`gh api /gitignore/templates/Swift --jq .source > .gitignore`；确认含 `DerivedData/ build/ *.xcuserstate xcuserdata/ .build/ .swiftpm/`；手动追加 `.DS_Store`、签名产物 `*.p12 *.cer *.mobileprovision`、`fastlane/` 输出、Sparkle 私钥 `*.pem`。**红线：绝不 ignore `Package.resolved`**。
5. **社区文件**（engineering-process §6，M0 建仓即就位）：
   - `CODE_OF_CONDUCT.md` = **Contributor Covenant 2.1** 逐字（2.1 仍是最新，无 3.0），enforcement 联系填维护者邮箱、**别绑单人**。
   - `SECURITY.md`：走 **GitHub Private Security Advisories**（不在公开 issue 报漏洞）+ 72h 首响 + Supported Versions 表 + 安全边界（WKWebView 严格隔离 / CSP / 无远程执行 / Skills·MCP 权限边界——security §1、§6.3）。
   - `CONTRIBUTING.md`：build/test/风格/commit 入口 + 多维护者治理声明。
6. **Issue/PR 模板**（engineering-process §6.1、§2.3）：
   - `.github/ISSUE_TEMPLATE/bug_report.yml`（issue forms，强制填 macOS 版本 / Colophon 版本 / 复现步骤 / 触发问题的 `.md` 样本）、`feature_request.yml`、`config.yml`（`blank_issues_enabled: false` + 引导 Discussions）。
   - `.github/PULL_REQUEST_TEMPLATE.md` = What/Why + Test plan + checklist（数据安全测试、CHANGELOG Unreleased、未碰 TextKit 1 `.layoutManager`、未引 GPL/停更依赖、未开智能引号）。
7. **FUNDING / CODEOWNERS**：`.github/FUNDING.yml`（`github: [colophon-maintainer]`）；`.github/CODEOWNERS` M0 单人先 `* @evan`，第二维护者到位后按模块拆。
8. **main 分支保护（用 Rulesets）**：Settings > Rules > Rulesets 建 branch ruleset 命中 `main`：Require PR、Require status checks（选 build/test/lint 三个 job）、Block force pushes、Require linear history。Settings > General **只留 Squash merge**。Required approvals 现设 0（单人），第二维护者到位即上调 1 + 开 Require review from Code Owners。可脚本化：`gh api --method POST /repos/colophon-app/colophon/rulesets`。
9. **Conventional Commits 强制**（服务端兜底）：PR 上跑 `webiny/action-conventional-commits`；因用 squash merge，PR 标题即最终 commit，再加 `amannn/action-semantic-pull-request` 校验标题。type 用 `feat/fix/docs/refactor/perf/test/build/ci/chore`，scope 对齐 engineering-process §2.2。
10. **`.swift-format` 配置**：`xcrun swift-format dump-configuration > .swift-format` 起草，按 engineering-process §1.2 改（`lineLength: 100`、`indentation: {spaces: 4}`、`tabWidth: 4`、`maximumBlankLines: 1`，规则集 `AlwaysUseLowerCamelCase`/`OrderedImports`/`UseEarlyExits` 等）。CI job：`xcrun swift-format lint --strict --recursive .`（有 diff 即失败）。本地 pre-commit 用 repo-local hook 调 `xcrun swift-format format -i`。**红线：只作用 `.swift`，绝不格式化用户 `.md`**（写进 `.claude/rules`）。
11. **SPDX 头**：每个 `.swift` 顶部 `// SPDX-License-Identifier: Apache-2.0`（可选 `// SPDX-FileCopyrightText: 2026 The Colophon Authors`）。批量：`reuse annotate --license Apache-2.0 --copyright "The Colophon Authors" Colophon/**/*.swift`。
12. **REUSE 合规（可选全量）**：不能加注释的文件（`.entitlements`/`.xcstrings`/资产/vendored JS）走仓库根 `REUSE.toml`（REUSE spec 3.3，取代旧 DEP5，二者互斥）；许可全文 `reuse download Apache-2.0` → `LICENSES/Apache-2.0.txt`；CI 加 `uses: fsfe/reuse-action@v6` 跑 `reuse lint`。**M0 轻量替代**：只保证新增 `.swift` 含 SPDX 头 + CI grep，逐步收敛到全量。
13. **CI 挡 GPL/AGPL 依赖**：PR 上 `uses: actions/dependency-review-action@v4`，配 `license-check: true` + `allow-licenses: MIT, BSD-2-Clause, BSD-3-Clause, ISC, Apache-2.0`（**用 allow-list；`deny-licenses` 已弃用**）。Swift 依赖图自 2023-06 支持 `Package.resolved`。新增依赖 PR 里人工核对当时 LICENSE（许可会变——STTextView 从宽松改 GPLv3 的前车之鉴，dependencies §2.2）。
14. **`THIRD-PARTY-LICENSES` 生成**：`license-plist --package-sources-path <DerivedData>/SourcePackages/checkouts --markdown-path THIRD-PARTY-LICENSES.md --fail-if-missing-license`（sandbox 模式无需网络）。Apache-2.0 依赖（swift-markdown 等）若带 NOTICE，内容须传递进我们的 `NOTICE`（Apache §4d，dependencies §2.6）。M0 依赖少可先手写、后接自动化。
15. **AGENTS.md / CLAUDE.md**：`AGENTS.md` 放 build/test/风格/commit/许可闸/红线的英文精炼；`CLAUDE.md` 写 `See AGENTS.md for shared rules` + Claude 专属项；细则拆进 `.claude/rules/*.md`（swift-format 只碰 `.swift`、TextKit 2 禁 `.layoutManager`、byte-exact 保存、GPL/停更依赖闸）。**人手写，别 `/init` 完就不管**。
16. **`CHANGELOG.md`**：Keep a Changelog 六分类（Added/Changed/Deprecated/Removed/Fixed/Security）+ `Unreleased` 段，日期 ISO 8601；每个 PR 顺手更新 Unreleased，发版转版本号（engineering-process §3.2）。

### 1.3 坑与对策

| 坑 | 对策 |
|---|---|
| **单点维护者 = Mark Text 死因**（作者全职后 PR 无人有权限合并） | 第一天开分支保护 + 要求 PR；尽早把 merge 权限授予第二维护者；CoC/SECURITY 联系不绑单人；required approvals 随人数 0→1 演进 |
| **CI 晚搭 = CuteMarkEd 死因** | M0 空壳时就把 build/test/lint + 签名公证全跑通——早搭几分钟，晚搭噩梦（engineering-process §5.1） |
| **LICENSE 识别失败**（改写/只放 SPDX 头，licensee 认不出） | 用官方 Apache-2.0 全文模板，别手改 body |
| **`Package.resolved` 被 ignore / 构建不可复现** | 确认已提交并 review；稳定官方库用 `.upToNextMinor`，pre-1.0/单团队库锁精确版本或 fork 固定 commit，禁浮动 branch（dependencies §3.1） |
| **required status check 不出现在 ruleset 列表** | job 未在 `main` 上真跑过、或跨 workflow 重名。CI workflow 加 `push: {branches:[main]}` 先注册一次，**job 名全局唯一**，再回 ruleset 勾选 |
| **许可扫描漏传递依赖 / `deny-licenses` 已弃用** | 扫描覆盖整棵依赖树；用 allow-list（只列 MIT/BSD/ISC/Apache-2.0）；白名单加依赖须写清法律理由 |
| **Apache NOTICE 传递义务被忽略** | 维护 `NOTICE` + `THIRD-PARTY-LICENSES` 并随 release 分发 |
| **AGENTS.md 灌水反伤**（重复仓库已有信息降成功率、涨约 23% 成本） | 人手写、只写非显然信息、定期裁剪 |
| **安全债不可修复 = Abricotine 死因** | SECURITY.md 第一天写死 WKWebView 严格隔离 + CSP 禁远程 + 只加载本地资源 + 不运行时下载执行代码；Skills/MCP 权限边界设计期就定（security §6.3、R1.x） |

### 1.4 来源

- swift-format Configuration / README / pre-commit hooks：https://github.com/swiftlang/swift-format
- GitHub Rulesets 可用规则：https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets
- required status checks 排障：https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks
- REUSE spec 3.3 / tutorial / reuse-tool：https://reuse.software/spec-3.3/ 、https://github.com/fsfe/reuse-tool
- SPDX in source：https://spdx.github.io/using/license-id-in-source/ ；Apache src-headers：https://www.apache.org/legal/src-headers.html
- dependency-review-action：https://github.com/actions/dependency-review-action ；Swift 依赖图支持：https://github.blog/changelog/2023-06-19-dependency-graph-dependabot-alerts-and-advisory-database-now-support-swift-advisories/
- LicensePlist：https://github.com/mono0926/LicensePlist ；github/gitignore Swift：https://github.com/github/gitignore/blob/main/Swift.gitignore
- Contributor Covenant 2.1：https://www.contributor-covenant.org/version/2/1/code_of_conduct/
- AGENTS.md：https://agents.md ；Conventional Commits：https://www.conventionalcommits.org/ ；Keep a Changelog：https://keepachangelog.com/

---

## 第二节 · Xcode 工程骨架 · 文件夹即库 · NSTextView(TextKit 2) 桥接

### 2.1 要点小结

- **新建工程**：现代 Xcode **不再自动生成 `.entitlements`**，App Sandbox + Hardened Runtime 必须手动建 entitlements 文件并**自 M0 起开**（security R2.1）。
- **文件夹即文库**（architecture §2.1，**不用 NSDocument/DocumentGroup**）：NSOpenPanel 选文件夹 → `bookmarkData(options:.withSecurityScope)` 持久化 → 重启用 `URL(resolvingBookmarkData:options:.withSecurityScope:...)` 解析 + 处理 `bookmarkDataIsStale` + 平衡 `start/stopAccessingSecurityScopedResource()`；需 `files.user-selected.read-write` + `files.bookmarks.app-scope` 两个 entitlement。
- **TextKit 2 桥接头号坑**：`NSTextView.scrollableTextView()` 等便捷构造会**静默降级 TextKit 1**；任何对 `.layoutManager` 的访问（即便只读）都会当场降级，macOS 26 仍有此坑（architecture §6.1）。必须手动搭 `NSTextLayoutManager` + `NSTextContentStorage` + `NSTextContainer` 三件套并用 `NSTextView(frame:textContainer:)` 注入。
- **byte-exact 保存**（architecture §3.1/§3.2、security R4.4）：关全部智能标点（且系统偏好会覆盖 view 级设置，需同时 register UserDefaults）、严格 UTF-8 解码失败即报错、记录行尾/BOM 原样回写、原子写。
- **Coordinator**：必须存 `Binding` 而非 parent（NSViewRepresentable 是值类型会被销毁）；`updateNSView` 写回前必须比较避免死循环（ui-and-design §1.2）。

### 2.2 可执行步骤（命令 / 配置 / 文件名）

1. **新建工程**：Xcode 26 新建 App，Interface=SwiftUI、Language=Swift、**Storage=None**（不勾 Core Data/CloudKit/Document App，避免带出 DocumentGroup 模板）。产品名 Colophon。
2. **部署目标**：Target > General > Minimum Deployments = **macOS 15.0**。SDK 由 Xcode 决定（macOS 26），部署目标独立设 15.0。命令行核对：`xcodebuild -showBuildSettings -target Colophon | grep -E 'MACOSX_DEPLOYMENT_TARGET|SDKROOT'` 应见 `15.0` 与 `macosx26`。
3. **Bundle ID**：有域名用 `app.colophon.Colophon`；开源无自有域名用 `io.github.colophon-app.Colophon`（对齐 org）。M0 单 app target + 单 scheme。
4. **手动建 entitlements**：File>New>File 搜 'Property List'，命名 `Colophon.entitlements`（扩展名 `.plist`→`.entitlements`），**不勾 target membership**；Build Settings 搜 'Code Signing Entitlements' 填相对路径。
5. **开 Sandbox + Hardened Runtime**：Signing & Capabilities 加 'App Sandbox' 与 'Hardened Runtime'。`Colophon.entitlements` 写全：
   ```xml
   com.apple.security.app-sandbox = true
   com.apple.security.files.user-selected.read-write = true
   com.apple.security.files.bookmarks.app-scope = true   <!-- 缺它重启后无法解析 bookmark -->
   ```
   Hardened Runtime 是 build setting（`ENABLE_HARDENED_RUNTIME=YES`）。构建后核对：`codesign -d --entitlements - --xml /path/Colophon.app`。**Release 配置绝不含 `com.apple.security.get-task-allow`**（否则公证/Gatekeeper 挑刺）。
6. **选文件夹**（`LibraryPicker.swift`）：`NSOpenPanel`，`canChooseDirectories=true`、`canChooseFiles=false`、`allowsMultipleSelection=false`、`canCreateDirectories=true`；`runModal()==.OK` 后取 `p.url`。此根文件夹 = 一个 `Library`。
7. **持久化访问权**（`BookmarkStore.swift`）：
   ```swift
   let data = try url.bookmarkData(options: .withSecurityScope,
                                   includingResourceValuesForKeys: nil, relativeTo: nil)
   // 存 UserDefaults / Application Support（M0 用 UserDefaults 可）
   // 重启解析：
   var stale = false
   let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope,
                     relativeTo: nil, bookmarkDataIsStale: &stale)
   if stale { /* 用解析出的新 url 重新 bookmarkData 覆盖旧值 */ }
   guard url.startAccessingSecurityScopedResource() else { /* 处理失败 */ }
   defer { url.stopAccessingSecurityScopedResource() }
   ```
   **关键**：用**解析返回的 url**（不是原 url）调 startAccessing；start/stop 严格配平，别在异步读文件完成前提前 stop。
8. **列目录 + 打开 `.md`**：`FileManager.default.enumerator(at: libraryURL, includingPropertiesForKeys:[.isRegularFileKey], options:[.skipsHiddenFiles])` 过滤 `.md`（懒加载，architecture §2.3 不一次性全读）。子文件继承根文件夹授权，打开单文件 `try Data(contentsOf: fileURL)` 无需每个 `.md` 单独 bookmark。
9. **TextKit 2 桥接骨架**（`MarkdownTextView.swift`，`struct MarkdownTextView: NSViewRepresentable`），`makeNSView` 手动搭栈：
   ```swift
   let lm = NSTextLayoutManager()
   let cs = NSTextContentStorage()
   cs.addTextLayoutManager(lm)
   let container = NSTextContainer(size: .zero)
   container.widthTracksTextView = true
   lm.textContainer = container
   let tv = NSTextView(frame: .zero, textContainer: container)   // 绝不用 scrollableTextView()
   // 放进 NSScrollView：sv.documentView = tv; sv.hasVerticalScroller = true
   tv.delegate = context.coordinator
   tv.allowsUndo = true; tv.isRichText = false; tv.usesFontPanel = false
   ```
10. **Coordinator + 单向状态流**：`makeCoordinator` 返回的 `Coordinator` **存 `Binding<String>` 而非 parent**；实现 `NSTextViewDelegate.textDidChange`：`binding.wrappedValue = tv.string`；`updateNSView` 写回前 `if tv.string != text { tv.string = text }`（防死循环/光标跳动，ui-and-design §1.2）。
11. **关智能标点（byte-exact 硬配置，architecture §3.2）**：`makeNSView` 里全关 `isAutomaticQuoteSubstitutionEnabled`、`isAutomaticDashSubstitutionEnabled`、`isAutomaticTextReplacementEnabled`、`isAutomaticSpellingCorrectionEnabled`、`isAutomaticPeriodSubstitutionEnabled` = false。**关键**：系统偏好会覆盖 view 级设置，故 App 启动早期同时：
    ```swift
    UserDefaults.standard.register(defaults: [
      "NSAutomaticQuoteSubstitutionEnabled": false,
      "NSAutomaticDashSubstitutionEnabled": false,
      "NSAutomaticPeriodSubstitutionEnabled": false,
      "NSAutomaticTextReplacementEnabled": false,
    ])
    ```
    拼写红波浪可留，自动纠正必关。
12. **严格 UTF-8 + 保真属性**：`guard let text = String(data: raw, encoding: .utf8) else { throw ... }`——非法 UTF-8 **报错**让用户选编码，**绝不 lossy/吞 `�`**。在 `Document` 记录：是否有 BOM（`EF BB BF` 前缀）、行尾风格（含 CRLF 就记 CRLF）、末尾是否有换行——原样回写，不规范化空白、不重排。
13. **原子写保存**：源码字符串 → `data(using: .utf8)` → 按记录的 BOM/行尾还原 → `try data.write(to: fileURL, options: [.atomic])`（写临时文件→rename）。M0 先用 `.atomic` 满足语义；`.atomic` 会换 inode、可能丢 xattr，保元数据的 `FileManager.replaceItemAt` 在 iCloud 下偶发 NSCocoaError 513——**最终 API 选型 architecture §3.1 留到 M1**。保存也在 library security scope 内。
14. **三栏 + 深浅色**（`ContentView.swift`）：`NavigationSplitView { 侧栏 } content: { 文件列表 } detail: { MarkdownTextView(text:$source) }`。深浅色**不写死** `.preferredColorScheme`——SwiftUI 默认跟随系统；chrome 用语义色（`.labelColor`/`Color.primary`/`.textBackgroundColor`），侧栏用 `.sidebar` 样式自动过渡（ui-and-design §2）。**编辑区不套玻璃**；任何 `glassEffect` 等 macOS 26+ API 必须 `if #available(macOS 26, *)` 门控 + macOS 15 回退（ui-and-design §3、architecture §6.3）。M0 空壳优先纯标准组件，不写显式玻璃。
15. **签名冒烟验证（DoD#2 前置）**：`xcodebuild -scheme Colophon -configuration Release build` → `codesign -d --entitlements - Colophon.app`（看四项 entitlement）→ `codesign -d -vvv Colophon.app 2>&1 | grep runtime`（应见 `flags=...(runtime)`）。

### 2.3 坑与对策

| 坑 | 对策 |
|---|---|
| **TextKit 1 静默降级（头号坑）**：访问 `.layoutManager`（哪怕只读）或用 `scrollableTextView()`/无参构造，view 当场换回 `NSLayoutManager`，自定义布局全失效，macOS 26 仍有 | 手动搭 TK2 三件套 + `NSTextView(frame:textContainer:)`；布局只走 `NSTextLayoutManager`/`NSTextContentStorage`/`NSTextLayoutFragment`；TK1 访问只放 `if let tlm = tv.textLayoutManager {} else {}` 的 else 分支；开发期监听 `willSwitchToNSLayoutManager` 抓越界；**Code review 必查**（architecture §6.1）。私有 default `NSTextViewAllowsDowngradeToLayoutManager=NO` 可根治但有 App Store 风险，不依赖 |
| **Coordinator 持有 parent 会失效**（值类型被销毁重建） | Coordinator 只存 `Binding<String>`（及必要闭包），不存 View |
| **updateNSView 死循环 / 光标跳到开头** | 写回前 `if tv.string != text` 比较；delegate 回调加 flag 抑制回环 |
| **智能标点被系统偏好覆盖**（只设 view 级无效） | 同时 `UserDefaults.register` 对应 `NSAutomatic*SubstitutionEnabled=false`；仍不放心用 `textView(_:shouldChangeTextInRanges:replacementStrings:)` 兜底 |
| **security-scoped bookmark 常见失败**：(1) 缺 `bookmarks.app-scope` → 重启无法解析；(2) 用原始 url 而非 resolving 返回的新 url → startAccessing 返回 false；(3) start/stop 不配平/提前 stop；(4) `stale==true` 不重存；(5) 对根授权后又 startAccessing 子文件 | 严格按「解析→判 stale 重存→对返回 url startAccessing→操作→stopAccessing」；对根 url 起 scope、子文件继承；缓存已解析 url（解析较贵） |
| **macOS 系统级 bookmark 回归 bug**（Sequoia 报 'Failed to retrieve app-scope key' NSCocoaError 256 等，是 ScopedBookmarkAgent daemon 的 OS bug） | 留一个最小复现工程（建→存→重启→解析）区分是自己代码还是 OS；遇到不盲改代码，重启 Mac/等 daemon 重启可自愈 |
| **原子写换 inode / iCloud 冲突** | M0 先用 `.atomic` 满足语义；元数据保留 vs iCloud 协调（NSFileCoordinator）最终选型 architecture §3.1 留到 M1；别用「先截断再写」 |
| **被 DocumentGroup/NSDocument 模板带偏**（一窗口一文件对抗文件夹即文库，自动保存黑盒与 byte-exact 打架） | 新建时选普通 App 模板、Storage=None，自建 Storage 层（architecture §2.1） |

### 2.4 来源

- Michael Tsai — TextKit 2: The Promised Land（macOS 26 降级坑）：https://mjtsai.com/blog/2025/08/15/textkit-2-the-promised-land/
- WWDC22 What's new in TextKit and text views（if-let textLayoutManager 分支 / willSwitchToNSLayoutManager）：https://developer.apple.com/videos/play/wwdc2022/10090/
- Apple Forums — 手动搭 TK2 into NSViewRepresentable：https://developer.apple.com/forums/thread/682459 ；textContentStorage is nil：https://developer.apple.com/forums/thread/685110
- Apple Forums — Coordinator 存 Binding：https://developer.apple.com/forums/thread/697123 ；NavigationSplitView 多次 updateNSView：https://developer.apple.com/forums/thread/749620
- startAccessingSecurityScopedResource：https://developer.apple.com/documentation/foundation/nsurl/startaccessingsecurityscopedresource()
- Apple Forums — folder security-scoped bookmark 全流程：https://developer.apple.com/forums/thread/124687 ；Sequoia bookmark bug：https://developer.apple.com/forums/thread/764435
- TrozWare — Playing in the Mac App Sandbox（2026-03，手动建 entitlements + Sandbox+Hardened Runtime）：https://troz.net/post/2026/playing_mac_sandbox/
- isAutomaticQuoteSubstitutionEnabled：https://developer.apple.com/documentation/appkit/nstextview/isautomaticquotesubstitutionenabled ；系统偏好覆盖：https://forums.developer.apple.com/thread/121828
- replaceItemAt iCloud 513：https://developer.apple.com/forums/thread/817068

---

## 第三节 · 签名公证流水线 · GitHub Actions macOS CI（最坑）

### 3.1 要点小结（含 2026-07-21 已核实的版本事实）

- **altool 已死**：自 **2023-11-01** 起 Apple 公证服务拒收 altool/Xcode 13 及更早上传。CI 只用 `xcrun notarytool`，认证用 **App Store Connect Team API Key + Developer 角色**的 `.p8`（Developer 角色足够公证，已核实）。
- **runner 与默认 Xcode 双重漂移（已核实到一手 readme）**：`macos-26` 于 **2026-02-26 GA**；当前 `macos-26-arm64` 镜像 = **macOS 26.4**，装有 **Xcode 26.0.1 / 26.1.1 / 26.2 / 26.3 / 26.4.1 / 26.5 / 26.6**，**默认 Xcode = 26.5，且 readme 注明 2026-07-21（今天）起默认切到 26.6**。`macos-latest` 自 **2026-06-15** 起滚动切到 `macos-26`。→ **runner 钉 `macos-26`、Xcode 显式 `xcode-select -s`**，别用 `macos-latest`、别靠默认。
- **签名**：临时 keychain 导入 Developer ID 证书 + `security set-key-partition-list` 消除 CI 授权弹窗；用 `xcodebuild -exportArchive`（`method=developer-id`）做 inside-out 签名，**不用 `--deep`**。
- **公证**：`ditto -c -k --keepParent` 打 zip、`notarytool submit --wait`、`stapler staple` 装订到 **`.app`（不是 zip）**。
- **关键交叉点（M0 必须显式决策）**：M0 起即开 App Sandbox + Hardened Runtime，而 Sparkle 2 沙箱自更新需额外 entitlements/XPC——**与 security R2.3「MVP 不申请网络出站」冲突**，见第四节 4.2 与「给 plan.md 的输入」M0.5。

### 3.2 可执行步骤（命令 / 配置 / 文件名）

**A. 前置·Apple 侧（一次性，可能审核数天，立刻做）**
1. developer.apple.com 创建 **Developer ID Application** 证书，导出 `.p12`（含私钥），identity 形如 `Developer ID Application: Evan Yang (TEAMID)`。
2. App Store Connect > Users and Access > Integrations/API Keys 生成 **Team Key（角色 Developer 即够公证）**，下载 `AuthKey_XXXXXXXXXX.p8`（只能下一次），记 Key ID（10 位）与 Issuer ID（UUID）。**不要用 Individual/Personal key**（仅 Xcode 26+ 可用且必须省略 issuer，否则 401）。

**B. 前置·本地生成 secrets**（base64 化后进 GitHub Settings > Secrets and variables > Actions）
```bash
base64 -i Colophon-DevID.p12 | pbcopy      # → DEVELOPER_ID_APP_P12_BASE64
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy    # → ASC_API_KEY_P8_BASE64
```
需配的 secrets：`DEVELOPER_ID_APP_P12_BASE64`、`DEVELOPER_ID_APP_P12_PASSWORD`、`KEYCHAIN_PASSWORD`（自定临时口令）、`ASC_API_KEY_ID`、`ASC_API_ISSUER_ID`、`ASC_API_KEY_P8_BASE64`、`SPARKLE_ED_PRIVATE_KEY`、`HOMEBREW_TAP_TOKEN`（PAT）。

**C. 工程文件**
- `ExportOptions.plist`（仓库根）：`method=developer-id`、`teamID=<TEAMID>`、`signingStyle=automatic`。让 `xcodebuild -exportArchive` 自动 inside-out 签名、规避 `--deep`。
- `Colophon.entitlements`：见第二节步骤 5 的三把钥匙 +（Sparkle 相关）见第四节 4.2 的决策项。

**D. `.github/workflows/ci.yml`（PR 门禁）**
```yaml
on: [pull_request]        # 另加 push:{branches:[main]} 让 required check 注册（见 1.3）
concurrency: { group: ci-${{ github.ref }}, cancel-in-progress: true }
jobs:
  build-test-lint:
    runs-on: macos-26
    steps:
      - uses: actions/checkout@v5
      - run: sudo xcode-select -s /Applications/Xcode_26.5.app   # 显式钉版本，别靠默认（默认在漂移）
      - uses: actions/cache@v4      # 缓存 DerivedData 的 SourcePackages（SPM）
      - run: xcodebuild test -scheme Colophon -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO   # 含数据安全用例
      - run: xcrun swift-format lint --strict --recursive Colophon ColophonTests    # 随工具链，无需额外装
      - run: bash scripts/check-localization.sh    # 硬编码字符串检查（见第四节）
```
> **注**：`Xcode_26.5.app` 是 2026-07-21 核实的镜像内路径；写 CI 时以当时 `macos-26-arm64-Readme.md` 的「可选 Xcode 列表 + 精确 app 文件名」为准（可选版本会随镜像滚动增删）。把 build/test/lint 三个 **job 名全局唯一**并设为 `main` 的 required checks。

**E. `.github/workflows/release.yml`（`on: push: tags: ['v*']`，`runs-on: macos-26`）**
1. **导证书进临时 keychain**（末行 `set-key-partition-list` 是消除 CI 授权弹窗的关键）：
   ```bash
   K=$RUNNER_TEMP/build.keychain
   echo "$P12_BASE64" | base64 --decode > $RUNNER_TEMP/cert.p12
   security create-keychain -p "$KEYCHAIN_PASSWORD" "$K"
   security set-keychain-settings -lut 3600 "$K"
   security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$K"
   security import $RUNNER_TEMP/cert.p12 -k "$K" -P "$P12_PASSWORD" -T /usr/bin/codesign
   security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$K"
   security list-keychains -d user -s "$K" login.keychain
   rm $RUNNER_TEMP/cert.p12
   ```
2. **归档 + 导出**：
   ```bash
   sudo xcode-select -s /Applications/Xcode_26.5.app
   xcodebuild archive -scheme Colophon -configuration Release \
     -archivePath $RUNNER_TEMP/Colophon.xcarchive -destination 'generic/platform=macOS' \
     OTHER_CODE_SIGN_FLAGS="--timestamp"
   xcodebuild -exportArchive -archivePath $RUNNER_TEMP/Colophon.xcarchive \
     -exportOptionsPlist ExportOptions.plist -exportPath $RUNNER_TEMP/export
   # 导出物已 Developer ID + hardened runtime + timestamp inside-out 签名，不加 --deep/--force
   ```
3. **公证 `.app`**：
   ```bash
   echo "$ASC_API_KEY_P8_BASE64" | base64 --decode > $RUNNER_TEMP/AuthKey.p8
   APP=$RUNNER_TEMP/export/Colophon.app
   ditto -c -k --keepParent "$APP" $RUNNER_TEMP/Colophon.zip     # 必须 ditto+keepParent，用 zip 会 signature invalid
   xcrun notarytool submit $RUNNER_TEMP/Colophon.zip --key $RUNNER_TEMP/AuthKey.p8 \
     --key-id "$ASC_API_KEY_ID" --issuer "$ASC_API_ISSUER_ID" --wait
   xcrun stapler staple "$APP"                                   # 装订到 .app，不是 zip
   # 排查：xcrun notarytool log <submission-id> --key ... --key-id ... --issuer ...
   ```
4. **打 DMG（先装订 app 再打包，DMG 再走一遍公证+装订）**：
   ```bash
   brew install create-dmg
   create-dmg --volname Colophon --app-drop-link 600 185 $RUNNER_TEMP/Colophon.dmg $RUNNER_TEMP/export/Colophon.app
   xcrun notarytool submit $RUNNER_TEMP/Colophon.dmg --key ... --wait
   xcrun stapler staple $RUNNER_TEMP/Colophon.dmg
   ```
   （若也分发 zip，须用**装订后**的 `.app` 重新 `ditto` 打一个新 zip——提交给 Apple 的那个 zip 本身没被装订。）
5. **Sparkle 签名 + appcast**（见第四节 4.2）：`bin/sign_update` 取 `edSignature`，或 `generate_appcast --ed-key-file <keyfile> <dir>` 一步生成 `appcast.xml`。
6. **发布 + Homebrew**：`softprops/action-gh-release@v2` 把 `Colophon.dmg` + `appcast.xml` 附到 Release；`macauley/action-homebrew-bump-cask@<pinned-sha>`（token 用 `HOMEBREW_TAP_TOKEN` PAT，**不能用默认 GITHUB_TOKEN**；tap 自建 `colophon-app/homebrew-tap`，cask `colophon`）。

**F. 验收（DoD#2）**：把产物拷到另一台 Mac（或 CI 内）：
```bash
spctl -a -t exec -vv Colophon.app          # 必须 source=Notarized Developer ID
xcrun stapler validate Colophon.app         # 通过
codesign --verify --deep --strict --verbose=2 Colophon.app   # 无 error
```
双击能开 = DoD#2 达成。

### 3.3 坑与对策

| 坑 | 对策 |
|---|---|
| **altool 已死**（2023-11-01 起拒收） | 只用 `xcrun notarytool`（TN3147）；Team API key + Developer 角色 `.p8` |
| **CI codesign 卡 errSecInternalComponent**（keychain 已解锁仍弹授权框） | import 后**必跑** `security set-key-partition-list -S apple-tool:,apple: -s -k <pw> <keychain>`；只 unlock、只加 `-T` 都不够 |
| **`--deep`/`--force` 坑**（掩盖 bug、公证随机失败，且毁 Sparkle XPC 签名） | 用 `xcodebuild -exportArchive`（method=developer-id）inside-out 签名，逐个嵌套 framework/dylib 先签、.app 最后签；绝不 `--deep` |
| **zip 打错 "signature invalid"** | `ditto -c -k --keepParent App App.zip`；`stapler staple` 对象是 `.app`/`.dmg` 不是提交用的 zip；分发 zip 用装订后 app 重打 |
| **沙箱 + Sparkle 冲突（M0 必须决策）** | 见第四节 4.2；把「Sparkle 联网方式」按 R2.5/R3.4 记进 `decisions.md` |
| **get-task-allow 混进 Release** | 该 entitlement 只应在 Debug；Release 确保移除 |
| **runner 与默认 Xcode 双重漂移** | 钉 `runs-on: macos-26` + 显式 `sudo xcode-select -s /Applications/Xcode_26.x.app`；`macos-15` 镜像也已装 Xcode 26.x 可作备选 |
| **Homebrew cask token 用错**（默认 GITHUB_TOKEN 无法跨仓库建 PR） | 用 PAT（`public_repo`；监听 tag 触发还需 `workflow` scope）存 `HOMEBREW_TAP_TOKEN`，tap 自建；官方 `homebrew/cask` 由 BrewTestBot 自动 bump，别对它用此 action |
| **docs/03 教训** | CI 晚建被打包压垮（CuteMarkEd）→ M0 空壳跑通两条流水线；证书/域名忘续费（Mark Text）→ 设自动续费/日历提醒，私钥进加密 secrets；首发未签名公证（MarkFlowy 让用户敲 xattr、NoteGen 告警）→ DoD#2 硬门禁 `spctl` 显示 Notarized 才算过 |

### 3.4 来源

- Apple notary update（altool 停用）：https://developer.apple.com/news/?id=y5mjxqmn ；TN3147：https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool
- notarytool 用 Team key + Developer 角色：https://developer.apple.com/forums/thread/133063 ；notarytool man：https://keith.github.io/xcode-man-pages/notarytool.1.html
- macos-26 GA：https://github.blog/changelog/2026-02-26-macos-26-is-now-generally-available-for-github-hosted-runners/
- **macos-26-arm64 镜像（macOS 26.4；Xcode 26.0.1–26.6，默认 26.5，2026-07-21 起 26.6）**：https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md
- macos-15 镜像（已装 Xcode 26.x）：https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md ；macos-latest 迁移：https://github.com/actions/runner-images/issues/14167
- import-codesign-certs：https://github.com/apple-actions/import-codesign-certs ；set-key-partition-list：https://developer.apple.com/forums/thread/666107
- ditto/staple/dmg 两步公证：https://gist.github.com/rsms/929c9c2fec231f0cf843a1a746a416f5
- 官方公证文档：https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
- action-homebrew-bump-cask：https://github.com/macauley/action-homebrew-bump-cask

---

## 第四节 · Sparkle 2 自更新 · String Catalog i18n · 隐私清单

### 4.1 要点小结

- **Sparkle 2** 走 SPM；沙箱下必须开 `SUEnableInstallerLauncherService` + `-spks`/`-spki` 两个 mach-lookup 临时例外（缺一即「能查到更新但装不上」且不报错，**已核实**）。**与 security R2.3「MVP 不申请 network.client」冲突** → 见 4.2 决策。
- **String Catalog** 从第一天用 `Localizable.xcstrings` + `SWIFT_EMIT_LOC_STRINGS=YES` 自动抽取；首发只翻英文但通道即通；CI 用 SwiftLint 自定义正则挡硬编码字符串。
- **隐私清单** `PrivacyInfo.xcprivacy`：Required-Reason 强制只作用于 App Store 上传（Developer ID 公证版不被拦），但仍应 M0 就写好（双渠道对等 + 零遥测立场诚实化）；**`FileTimestamp` 与 `UserDefaults` 是本项目必审的两类 API**。崩溃上报 MVP 默认不做（security R3.1）。

### 4.2 【M0 关键决策】Sparkle 联网 vs security R2.3（必须显式拍板并记进 decisions.md）

security **R2.3** 明确「MVP 不申请 `com.apple.security.network.client`」，但 Sparkle 自更新需下载。**二选一，必须显式决策（R2.5/R3.4 要求记录）**：

- **方案 A（推荐，最贴合 R2.3）**：`SUEnableDownloaderService=YES`——下载留在 Sparkle 自带的 Downloader XPC 内，**app 层不授网**。代价：发行说明回落到旧 WebView 行为；且 **Sparkle 2.6+ 起 Downloader XPC 默认不再被沙箱化**，升级 Sparkle 时须重读官方 sandboxing 指南确认这块行为。
- **方案 B（最省事）**：给全 app 加 `com.apple.security.network.client=true`。**直接违反 R2.3 红线**，仅在方案 A 不可行时选，且必须在 decisions.md 写清理由。

无论哪种，都要把「Sparkle 自更新需联网」按 R2.5/R3.4 记进 `planning/M0/decisions.md` 并写进隐私说明（可关闭）。MAS 版（未来）走 App Store 更新、不含 Sparkle，是已知的合理双渠道差异。

### 4.3 可执行步骤（命令 / 配置 / 文件名）

**Sparkle**
1. **集成**：Xcode > Add Package Dependencies，URL `https://github.com/sparkle-project/Sparkle`，规则 'Up to Next Major Version' 锁 2.x，链接到 app target。CLI 工具在 `~/Library/Developer/Xcode/DerivedData/<proj>/SourcePackages/artifacts/sparkle/Sparkle/bin/`。
2. **密钥**：在上面 `bin/` 跑一次 `./generate_keys`（私钥进登录 Keychain 条目 'Private key for signing Sparkle updates'，打印 base64 `SUPublicEDKey`）。CI 备份：`./generate_keys -x sparkle_private_key.pem` → 内容存 secret `SPARKLE_ED_PRIVATE_KEY` 后**立即删本地文件**，`.pem` 加进 `.gitignore`。**私钥务必异地再备份——丢了就再也签不出用户能装的更新**。
3. **Info.plist**：
   - `SUFeedURL` = `https://github.com/colophon-app/colophon/releases/latest/download/appcast.xml`
   - `SUPublicEDKey` = 上一步公钥
   - `SUEnableInstallerLauncherService = YES`（沙箱必需）
   - `SUEnableDownloaderService = YES`（方案 A）
   - `CFBundleVersion` 必须单调递增整数（Sparkle 靠它比版本）
4. **entitlements**（`Colophon.entitlements` 追加，Xcode 构建自动替换 `$(PRODUCT_BUNDLE_IDENTIFIER)`）：
   ```xml
   com.apple.security.temporary-exception.mach-lookup.global-name = [
     "$(PRODUCT_BUNDLE_IDENTIFIER)-spks",
     "$(PRODUCT_BUNDLE_IDENTIFIER)-spki"
   ]
   <!-- 方案 A：不加 network.client；方案 B：加 com.apple.security.network.client = true -->
   ```
5. **SwiftUI 接线**：App 里 `private let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)`；`.commands { CommandGroup(after: .appInfo) { CheckForUpdatesView(updater: updaterController.updater) } }`；按钮 `disabled(!vm.canCheckForUpdates)`，`vm` 订阅 `updater.publisher(for: \.canCheckForUpdates)`。
6. **验证能检查到更新（DoD#5）**：本地 `CFBundleVersion=1`，做一个含 version>1 item + edSignature 的 `appcast.xml`，临时托管（Release 草稿资产或 `python -m http.server`），点 'Check for Updates…' 应弹「有可用更新」。排障：`codesign -d --entitlements :- Colophon.app` 确认 mach-lookup + sandbox；Console.app 过滤 'Sparkle'；Xcode 无法附着 XPC 时，Scheme 关 'Debug XPC services used by app' 或脱离 Xcode 跑。
7. **appcast/CI**：`xcodebuild archive/export`（优先 archive+export，别自写引用 XPC/framework 的 codesign 脚本）→ 产物放 `updates/` → `./generate_appcast --ed-key-file <私钥文件> updates/`（生成 `appcast.xml` + `*.delta` 增量包）→ 随归档上传 Release。CI 里私钥写临时文件、用完删、绝不进仓库。

**i18n**
8. **建档**：File>New>File>String Catalog，命名 `Localizable` → `Localizable.xcstrings` 加入 app target。Project Info>Localizations development language=English、勾 'Use Base Internationalization'；首发只留 English 列，其余语言点 '+' 增列。
9. **构建设置**：Build Settings>Localization 'Use Compiler to Extract Swift Strings'（`SWIFT_EMIT_LOC_STRINGS`）=YES（Xcode 16+ 默认 YES）；**必须真正 Build 一次**编译器才把字符串抽进 `.xcstrings`。
10. **代码约定**：SwiftUI 里 `Text("Open Folder…")`（字面量自动本地化）；非 SwiftUI 处 `String(localized: "save.error", defaultValue: "Could not save", comment: "...")`；跨函数用 `LocalizedStringResource`。**绝不本地化**的（文件名、`.md` 正文、frontmatter、路径）一律 `Text(verbatim:)`/纯 `String`（呼应 byte-exact 红线）。放进 Swift Package 的字符串必须 `String(localized: key, bundle: .module)`。
11. **CI 挡硬编码**（`scripts/check-localization.sh` 或直接 SwiftLint）：`.swiftlint.yml` 加 `custom_rules` 正则（匹配 `Text("...")`、`Button("...")`、`.alert("...")` 字面量，提示改用 `String(localized:)`/`Text(verbatim:)`，severity warning）；CI `brew install swiftlint` 后 `swiftlint lint --strict --reporter github-actions-logging`（`--strict` 让 warning 也 fail）。运行期补充：Scheme>Run>App Language 选 'Double-Length / Right-to-Left Pseudolanguage'，或 `-NSShowNonLocalizedStrings YES` 抓漏。
12. **预留复数/RTL**：`.xcstrings` 里 key 右键 'Vary by Plural'（首发只填英文 one/other）；布局用 leading/trailing 而非 left/right，先用 RTL 伪语言跑一遍确认三栏 NavigationSplitView 不破版。

**隐私清单**
13. **建档**：File>New>File>App Privacy File → `PrivacyInfo.xcprivacy` 加入 app target 的 Copy Bundle Resources。零遥测立场：`NSPrivacyTracking=false`、`NSPrivacyTrackingDomains=[]`、`NSPrivacyCollectedDataTypes=[]`。
14. **Required-Reason 审计**（按实际用到的 API 声明 `NSPrivacyAccessedAPITypes`）：
    - `UserDefaults` → `NSPrivacyAccessedAPICategoryUserDefaults` 理由 **CA92.1**。
    - **文件时间戳**（`FileManager` attributes / `.contentModificationDate`，文库排序与「修改时间」显示、FSEvents 必然触发）→ `NSPrivacyAccessedAPICategoryFileTimestamp`，按用途在 C617.1/DDA9.1/3B52.1/0A2A.1 中选（对「仅本 app 内展示给用户」常用 **C617.1**，对照 Apple『Describing use of required reason API』定夺）。
    - 若显示磁盘空间 → `DiskSpace` 7D9E.1；若用系统启动时间/单调时钟 → `SystemBootTime` 35F9.1。
    - **注意 Sparkle 自带其 `PrivacyInfo.xcprivacy`**，Xcode 归档时汇总进 Privacy Report，**不要重复声明它的条目**。
15. **崩溃上报立场**：MVP 默认不做（security R3.1/R3.2）。若未来做：app 内显式 opt-in + MetricKit 本地（`MXMetricManager` 订阅 `MXDiagnosticPayload`/`MXCrashDiagnostic`），上报前剥离正文/路径/文库名、默认只落本地。**MetricKit 不受系统「Share with App Developers」开关约束**，接了就等于自己收数据，故必须自建 opt-in。

### 4.4 坑与对策

| 坑 | 对策 |
|---|---|
| **Sparkle 沙箱静默失败**（缺 mach-lookup 例外或没开 `SUEnableInstallerLauncherService` → 能查到更新但装不上，不报错） | 两者都配齐；`codesign -d --entitlements :- Colophon.app` 验证 `-spks`/`-spki` + app-sandbox 都在 |
| **network.client 与 R2.3 冲突** | 见 4.2：推荐 `SUEnableDownloaderService=YES`，按 R2.5/R3.4 记 decisions.md |
| **别手改 Sparkle XPC bundle id**（`org.sparkle-project.InstallerLauncher`/`Downloader`，Steinberger 2025 实录：改 XPC bundle id 是大错） | 优先 `xcodebuild archive + export` 让 Xcode 自动签名/嵌入，别自写 codesign 脚本 |
| **`SUPublicEDKey` 没进包**（报 'update is improperly signed' 拒装） | 构建后确认 app 内 Info.plist 含公钥且与私钥匹配；`CFBundleVersion` 单调递增 |
| **私钥丢失/泄露**（丢=再也签不出更新，泄露=任何人可推恶意更新） | `generate_keys -x` 导出后异地离线备份 + 存 CI Secret；签名机与托管分离 |
| **String Catalog 不抽字符串**（`SWIFT_EMIT_LOC_STRINGS=NO` 或没 Build；动态插值不抽） | 确认设置 YES 且每次改字符串后 Build；动态串统一 `String(localized:)` |
| **误本地化正文/文件名**（`Text("...")` 对字面量默认本地化） | 非 UI 文案一律 `Text(verbatim:)`/纯 String；Swift Package 内字符串记得 `bundle: .module` |
| **正则 lint 假阳/假阴**（多行/拼接漏，注释/日志误报） | 正则 + 运行期 `-NSShowNonLocalizedStrings YES`/伪语言双管齐下 |
| **以为 Developer ID 不用做隐私清单**（Required-Reason 强制只在 App Store 上传触发） | M0 就写好：双渠道对等（未来 MAS 需要）+ 零遥测立场落到文件；理由码按真实用途选，选错将来 MAS 提审被拒 |
| **漏声明 FileTimestamp**（文库排序/「修改时间」/FSEvents 都读时间戳） | 把 `FileTimestamp` 与 `UserDefaults` 当作本项目默认必声明的两类 |
| **MetricKit 静默采集** | MVP 干脆不接；若接必须自建 opt-in + 本地存 + 去内容 |

### 4.5 来源

- Sparkle 沙箱（`SUEnableInstallerLauncherService`/`SUEnableDownloaderService`、`-spks`/`-spki`、Downloader 与 network.client 取舍）：https://sparkle-project.org/documentation/sandboxing/
- Sparkle 集成/密钥/appcast：https://sparkle-project.org/documentation/ 、https://sparkle-project.org/documentation/customization/
- Steinberger 2025（不改 XPC bundle id、优先 archive/export）：https://steipete.me/posts/2025/code-signing-and-notarization-sparkle-and-tears
- 沙箱是否需 Downloader 服务的讨论：https://github.com/sparkle-project/Sparkle/discussions/2270
- SwiftUI 接 Sparkle：https://medium.com/@borto_ale/integrating-sparkle-updater-in-swiftui-for-macos-82ae4e0b4ac6
- WWDC25 Explore localization with Xcode：https://developer.apple.com/videos/play/wwdc2025/225/
- Required-Reason API 理由码权威表：https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api ；TN3183：https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest
- privacy manifest 结构：https://developer.apple.com/documentation/bundleresources/privacy-manifest-files ；强制自 2024-05-01（ITMS-91053）：https://developer.apple.com/news/?id=3d8a9yyh
- MetricKit MXCrashDiagnostic：https://developer.apple.com/documentation/metrickit/mxcrashdiagnostic ；不受 Share 开关约束：https://developer.apple.com/forums/thread/733806
- SwiftLint：https://github.com/realm/SwiftLint ；String Catalog 101：https://belief-driven-design.com/xcode-string-catalogs-101-672f5/

---

## 第五节 · 给 plan.md 的输入（M0 执行阶段划分建议）

> 把上面浓缩为**有序阶段**。原则：**能并行的并行、有前置依赖的串行**；每阶段给「关键坑」与「前置依赖」。总策略呼应 overview——趁空壳把最烦的流水线跑通，成本最低。**外部前提（Apple Developer 账号/证书）审核慢，M0.0 立刻启动，与 M0.1–M0.3 并行等待。**

### M0.0 · 外部前提启动（第 0 天，与后续并行）
- **做**：注册 Apple Developer Program；建 `colophon-app` org；（可选）注册域名。证书到手后创建 Developer ID Application 证书 + App Store Connect Team API Key（Developer 角色）。
- **前置**：无。**关键坑**：审核数天——**不启动就卡死 M0.4**。证书未到手不阻塞 M0.1–M0.3。

### M0.1 · 仓库与不可回撤承诺（第一节）
- **做**：建 public repo；第一个 commit 带 Apache-2.0 LICENSE 全文 + NOTICE + README（两条承诺）；`.gitignore`；社区文件（CoC 2.1 / SECURITY / CONTRIBUTING）；issue/PR 模板；FUNDING/CODEOWNERS；`.swift-format`；`AGENTS.md`/`CLAUDE.md`/`.claude/rules`；CHANGELOG；把 `docs/`+`planning/` 归位进仓库。**分支保护先不锁死**（等 M0.3 的 CI job 注册后再回来配 required checks）。
- **前置**：org 创建（M0.0）。**关键坑**：LICENSE 用官方全文（licensee 识别）；`Package.resolved` 别 ignore；承诺一旦公开不可回撤（想清楚再写）；AGENTS.md 别灌水。

### M0.2 · Xcode 空壳能开/编/存（第二节）
- **做**：新建 SwiftUI App（Storage=None）；部署目标 macOS 15；Bundle ID；手动建 `.entitlements` + 开 Sandbox + Hardened Runtime（四把钥匙）；文件夹即文库（NSOpenPanel + security-scoped bookmark + stale 处理）；TextKit 2 三件套桥接 + Coordinator 存 Binding；关智能标点 + UserDefaults register；严格 UTF-8 + 记录 BOM/行尾；原子写；NavigationSplitView 三栏 + 深浅色跟随系统。**提交 `.xcodeproj` + `Package.resolved`**。
- **前置**：M0.1 仓库就位（代码要有地方放）。**关键坑（本阶段最技术密集）**：TextKit 1 静默降级（绝不碰 `.layoutManager`）；Coordinator 别存 parent；updateNSView 死循环；bookmark 五种失败模式；智能标点被系统偏好覆盖；别被 DocumentGroup 模板带偏。

### M0.3 · CI 绿（第一节步骤 8/13/14 + 第三节 D + 第四节 i18n lint）
- **做**：写 `ci.yml`（`runs-on: macos-26` + 显式 `xcode-select` + build/test/lint + 硬编码字符串检查 + dependency-review allow-list）；job 名全局唯一；`push:{branches:[main]}` 先合一次注册 job；回 M0.1 的 ruleset 勾选 build/test/lint 为 required checks；Conventional Commits/PR 标题校验 Action。
- **前置**：M0.2（要有能编译的空壳）。证书**不需要**（用 `CODE_SIGNING_ALLOWED=NO`）。**关键坑**：required check 不出现在列表（job 未在 main 跑过/重名）；runner 与默认 Xcode 漂移（显式钉版本，写 CI 时以当时 readme 的可选 Xcode 列表为准）。

### M0.4 · 签名公证跑通（第三节 · 最坑，DoD#2）
- **做**：secrets 配置（p12/p8/keychain/API key base64）；`ExportOptions.plist`；`release.yml`（临时 keychain + `set-key-partition-list` + archive/export + notarytool + stapler + create-dmg 两步公证 + gh-release + homebrew-bump-cask）；打一个测试 tag 跑通空壳包；另一台 Mac `spctl`/`stapler validate` 验收。
- **前置**：**M0.0 证书必须到手**；M0.2（有可被签名的 app 骨架）；M0.3（CI 基础设施）。**关键坑**：altool 已死（只用 notarytool）；errSecInternalComponent（必跑 set-key-partition-list）；`--deep` 毁签名（用 export）；zip 用 ditto+keepParent、staple 装 `.app`；get-task-allow 别进 Release；Homebrew 用 PAT；**首发未签名公证=用户打不开（DoD#2 硬门禁）**。

### M0.5 · Sparkle / i18n / 隐私（第四节，DoD#4/#5）
- **做**：
  - **【先决策】4.2 的 Sparkle 联网方案 A/B**，记进 `decisions.md`（这是 M0.5 的阻塞项，且影响 M0.2 的 entitlements 与 M0.4 的签名）。
  - Sparkle 集成（SPM + generate_keys + Info.plist 键 + mach-lookup 例外 + SwiftUI 菜单）+ appcast 生成接进 M0.4 的 release.yml；验证能检查到更新。
  - String Catalog 建档 + `SWIFT_EMIT_LOC_STRINGS=YES` + 代码约定 + CI 硬编码 lint（并入 M0.3）。
  - `PrivacyInfo.xcprivacy`（零遥测 + UserDefaults CA92.1 + FileTimestamp 理由码；不重复声明 Sparkle 条目）。
- **前置**：M0.2（entitlements 文件）、M0.4（release 流水线，appcast 随 release 走）。**关键坑**：Sparkle 沙箱静默失败（配齐 launcher service + 两个 mach-lookup 例外）；私钥丢失（异地备份）；别改 Sparkle XPC bundle id；String Catalog 不 Build 就不抽；误本地化正文/文件名；漏声明 FileTimestamp；MetricKit 静默采集（MVP 不接）。

### 阶段依赖速览
```
M0.0（外部证书，慢，立即启动）───────────────┐
M0.1（仓库承诺）→ M0.2（Xcode 空壳能开编存）→ M0.3（CI 绿）→ M0.4（签名公证）→ M0.5（Sparkle/i18n/隐私）
                                              ↑                    ↑
                              (i18n lint 并入 M0.3)      (需 M0.0 证书 + M0.5 的 Sparkle 联网决策先定)
```
- **跨阶段决策项（越早定越好，进 `decisions.md`）**：① 4.2 Sparkle 联网 A/B（影响 entitlements + 签名 + 隐私说明）；② 工程形态（单 `.xcodeproj` vs XcodeGen/Tuist，M0 选前者）；③ Bundle ID（依赖是否有域名）；④ 原子写 API（M0 用 `.atomic`，最终 architecture §3.1 留 M1）。
