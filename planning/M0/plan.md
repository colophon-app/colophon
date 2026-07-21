# M0 · 执行计划（plan）

> **怎么用**：这是 M0 的照做清单，逐条勾 `- [ ]`。具体命令/配置/坑的详解在 [`research.md`](./research.md)（引其小节号），决策在 [`decisions.md`](./decisions.md)，范围/DoD 在 [`overview.md`](./overview.md)。
> **顺序**：M0.0 立刻启动（审核慢）并与 M0.1–M0.3 并行；M0.4 需 M0.0 证书 + M0.5 的 Sparkle 决策已定。
> **已定决策（[decisions.md](./decisions.md)）**：Sparkle 方案 A（app 不授网）· 单 `.xcodeproj` · Bundle ID `io.github.colophon-app.Colophon` · 保存用 `.atomic`。

---

## M0.0 · 外部前提启动（第 0 天 · Evan · 与后续并行）

> 目标：把审核慢的东西先启动。前置：无。**不启动就卡死 M0.4。**

- [ ] 注册 **Apple Developer Program**（约 $99/年）
- [ ] 证书到手后：创建 **Developer ID Application** 证书，导出 `.p12`（含私钥）
- [ ] App Store Connect 生成 **Team API Key（角色 Developer）**，下载 `AuthKey_*.p8`（只能下一次），记 Key ID + Issuer ID —— **不要用 Individual/Personal key**
- [ ] 建 GitHub org `colophon-app`（含未来 `colophon-app/homebrew-tap`）
- [ ] （可选）决定是否注册域名（影响 Bundle ID，见 D-M0-3）
- [ ] 给证书有效期 / 域名 / API key 设日历提醒或自动续费（Mark Text 域名忘续费教训）
- [ ] Sparkle EdDSA 私钥生成后异地离线备份（见 M0.5）

## M0.1 · 仓库与不可回撤承诺（research §1 · 可由 Claude 代写文件内容）

> 目标：仓库+承诺+治理就位。前置：org 已建。

- [ ] `gh repo create colophon-app/colophon --public`
- [ ] 第一个 commit：`LICENSE`(Apache-2.0 官方全文，别手改) + `NOTICE` + `README.md`（产品宣言 + 两条不可回撤承诺：永久开源、本地 `.md` 唯一真相源永不引入私有格式）
- [ ] `.gitignore`(Swift 模板 + 追加 `.DS_Store`/签名产物/Sparkle `.pem`)——**绝不 ignore `Package.resolved`**
- [ ] 目录树：`Colophon/`(App/Editor/Document/FileSystem/) · `ColophonTests/` · `.github/` · `docs/` · `planning/` · `LICENSES/`
- [ ] 社区文件：`CODE_OF_CONDUCT.md`(Contributor Covenant 2.1) · `SECURITY.md`(Private Advisories + 安全边界) · `CONTRIBUTING.md`(含多维护者治理声明)
- [ ] `.github/`：`ISSUE_TEMPLATE/`(bug/feature forms + config) · `PULL_REQUEST_TEMPLATE.md`(含 red-line checklist) · `FUNDING.yml` · `CODEOWNERS`
- [ ] `.swift-format`(`xcrun swift-format dump-configuration` 起草，按 engineering §1.2 改)
- [ ] `AGENTS.md`(英文精炼，人手写不灌水) + `CLAUDE.md`(薄指针) + `.claude/rules/*.md`(swift-format 只碰 .swift / TextKit 2 禁 .layoutManager / byte-exact / GPL·停更依赖闸)
- [ ] `CHANGELOG.md`(Keep a Changelog + Unreleased)
- [ ] 把 `docs/` + `planning/` 归位进仓库
- [ ] **分支保护暂不锁死**——等 M0.3 的 CI job 注册后再回来配 required checks

**坑**：LICENSE 用官方全文（否则 licensee 认不出、无徽章）；承诺公开即不可回撤（想清楚再写）；AGENTS.md 别 `/init` 完就不管。

## M0.2 · Xcode 空壳能开/编/存（research §2 · 本阶段最技术密集）

> 目标：能可靠开/编/存一个 `.md`。前置：M0.1（代码有地方放）。

- [ ] Xcode 26 新建 App：SwiftUI / Swift / **Storage=None**（不带出 DocumentGroup）
- [ ] 部署目标 **macOS 15.0**；Bundle ID `io.github.colophon-app.Colophon`；单 target + 单 scheme
- [ ] 手动建 `Colophon.entitlements`（不勾 target membership，Build Settings 填路径）
- [ ] 开 App Sandbox + Hardened Runtime，写全四把钥匙：`app-sandbox` · `files.user-selected.read-write` · `files.bookmarks.app-scope`（+ M0.5 的 Sparkle mach-lookup 例外）；Release 绝不含 `get-task-allow`
- [ ] 文件夹即文库：`NSOpenPanel`(选目录) → security-scoped `bookmarkData` 持久化 → 重启 `resolvingBookmarkData` + 判 `stale` 重存 + 用**解析返回的 url** `startAccessing`/`stopAccessing` 配平
- [ ] 列目录：`FileManager.enumerator` 过滤 `.md`(懒加载、跳隐藏)
- [ ] **TextKit 2 桥接**（`MarkdownTextView: NSViewRepresentable`）：手搭 `NSTextLayoutManager`+`NSTextContentStorage`+`NSTextContainer` 三件套 + `NSTextView(frame:textContainer:)`——**绝不用 `scrollableTextView()`、绝不碰 `.layoutManager`**
- [ ] Coordinator **只存 `Binding<String>`**（非 parent）；`textDidChange` 回写；`updateNSView` 先 `if tv.string != text` 比较防死循环
- [ ] 关全部智能标点（5 个 `isAutomatic*` = false）+ **App 早期 `UserDefaults.register`** 对应 `NSAutomatic*SubstitutionEnabled=false`（系统偏好会覆盖 view 级）
- [ ] 严格 UTF-8：解码失败**报错让用户选编码**，绝不 lossy；记录 BOM/行尾/末尾换行原样回写
- [ ] 保存：`data.write(to:options:.atomic)`（在 library scope 内）
- [ ] `NavigationSplitView` 三栏 + 深浅色跟随系统（不写死 `.preferredColorScheme`，chrome 用语义色）；编辑区不套玻璃，任何 `glassEffect` 走 `if #available(macOS 26, *)`
- [ ] 提交 `.xcodeproj` + `Package.resolved`
- [ ] 冒烟：`codesign -d --entitlements -` 看四把钥匙 + `grep runtime` 看 hardened

**坑**：TextKit 1 静默降级（Code review 必查）；Coordinator 存 parent 失效；bookmark 五种失败；智能标点被系统偏好覆盖；别被 DocumentGroup 带偏。

## M0.3 · CI 绿（research §1.8/§3.D/§4 i18n lint）

> 目标：PR 上 build/test/lint 绿。前置：M0.2（有能编译的空壳）。**不需要证书**（用 `CODE_SIGNING_ALLOWED=NO`）。

- [ ] `.github/workflows/ci.yml`：`runs-on: macos-26` + `push:{branches:[main]}`(注册 job) + 显式 `sudo xcode-select -s /Applications/Xcode_26.x.app`(以当时 runner readme 的可选列表为准)
- [ ] job：`xcodebuild test ... CODE_SIGNING_ALLOWED=NO`(含数据安全用例) · `xcrun swift-format lint --strict --recursive` · `scripts/check-localization.sh`(硬编码字符串) · `actions/dependency-review-action@v4`(allow-list: MIT/BSD/ISC/Apache-2.0)
- [ ] job 名全局唯一
- [ ] Conventional Commits / PR 标题校验 Action
- [ ] 回 M0.1 配 **main ruleset**：Require PR + Require status checks(build/test/lint) + Block force push + Linear history；只留 Squash merge

**坑**：required check 不出现在列表（job 未在 main 跑过/重名 → 先合一次注册）；runner/Xcode 版本漂移（显式钉版本）。

## M0.4 · 签名公证跑通（research §3 · 最坑 · DoD#2）

> 目标：app 签名公证、别人机器双击能开。前置：**M0.0 证书到手** + M0.2 + M0.3。

- [ ] 配 GitHub secrets：`DEVELOPER_ID_APP_P12_BASE64`/`_PASSWORD` · `KEYCHAIN_PASSWORD` · `ASC_API_KEY_ID`/`_ISSUER_ID`/`_P8_BASE64` · `SPARKLE_ED_PRIVATE_KEY` · `HOMEBREW_TAP_TOKEN`(PAT: public_repo+workflow)
- [ ] `ExportOptions.plist`(method=developer-id, teamID, signingStyle=automatic)
- [ ] `.github/workflows/release.yml`(`on: push: tags: ['v*']`)：临时 keychain 导证书 + **`security set-key-partition-list`**(消 CI 弹窗) → `xcodebuild archive` + `-exportArchive`(inside-out 签名，**不用 `--deep`**) → `ditto -c -k --keepParent` 打 zip → `notarytool submit --wait` → `stapler staple` 装 `.app` → `create-dmg` 两步公证 → `gh-release` + `homebrew-bump-cask`
- [ ] 打测试 tag 跑通空壳包
- [ ] 另一台 Mac 验收：`spctl -a -t exec -vv`(须 Notarized) + `stapler validate` + 双击能开 → **DoD#2 达成**

**坑**：altool 已死（只用 notarytool）；errSecInternalComponent（必跑 set-key-partition-list）；`--deep` 毁签名；zip 用 ditto+keepParent、staple 装 `.app` 不是 zip；get-task-allow 别进 Release；Homebrew 用 PAT。

## M0.5 · Sparkle / i18n / 隐私（research §4 · DoD#4/#5）

> 目标：自更新接通 + i18n 通道就位 + 隐私清单就位。前置：M0.2(entitlements) + M0.4(release 流水线)。

- [ ] **【已定 D-M0-1】** Sparkle 方案 A：`SUEnableDownloaderService=YES`，app 不加 `network.client`
- [ ] Sparkle：SPM 集成(锁 2.x) + `generate_keys` + 私钥进 secret 并**异地备份** + Info.plist(`SUFeedURL`/`SUPublicEDKey`/`SUEnableInstallerLauncherService`/`SUEnableDownloaderService`/`CFBundleVersion` 递增) + entitlements 加 `-spks`/`-spki` mach-lookup 例外 + SwiftUI 菜单接线
- [ ] appcast 生成(`generate_appcast`)接进 M0.4 的 release.yml
- [ ] 验证能检查到更新（DoD#5）
- [ ] String Catalog：`Localizable.xcstrings` + `SWIFT_EMIT_LOC_STRINGS=YES` + 代码约定(`String(localized:)` / 正文文件名用 `Text(verbatim:)`) + 复数/RTL 预留
- [ ] i18n 硬编码 lint 并入 M0.3 CI
- [ ] `PrivacyInfo.xcprivacy`：零遥测 + `UserDefaults`(CA92.1) + `FileTimestamp`(理由码按用途选) + **不重复声明 Sparkle 自带条目**
- [ ] 崩溃上报：MVP 不接（若接必须 opt-in + MetricKit 本地 + 去内容）

**坑**：Sparkle 沙箱静默失败（launcher service + 两个 mach-lookup 例外都要）；私钥丢失=再也签不出更新；别改 Sparkle XPC bundle id；String Catalog 不 Build 就不抽；误本地化正文/文件名；漏声明 FileTimestamp。

---

## 阶段依赖

```
M0.0（外部证书，慢，立即启动，Evan）──────────────────────┐
M0.1（仓库承诺）→ M0.2（Xcode 空壳能开编存）→ M0.3（CI 绿）→ M0.4（签名公证）→ M0.5（Sparkle/i18n/隐私）
```

## M0 完成定义（DoD 总核对）

- [ ] #1 能可靠开/编/存一个 `.md`（原子写、byte-exact、智能标点已关）
- [ ] #2 app 已签名公证，别人机器双击能开（`spctl` 显示 Notarized）
- [ ] #3 CI 在 PR 上绿（build + test + lint）
- [ ] #4 i18n 通道就位（String Catalog + 约定 + lint）
- [ ] #5 Sparkle 自更新通道接通（能检查到 appcast）

## 分工

- **Evan**：M0.0（账号/证书/org）· 建 repo · Xcode GUI 操作（新建工程、加 capability、加 package）· 跑 build/在真机验收 · 配 GitHub secrets。
- **Claude 可代写文件内容**：LICENSE/NOTICE/README/.gitignore/.swift-format/社区文件/issue·PR 模板/AGENTS.md·CLAUDE.md·.claude/rules/CHANGELOG（M0.1）；`ci.yml`/`release.yml`/`ExportOptions.plist`/`check-localization.sh`（M0.3/M0.4）；`.entitlements`/`PrivacyInfo.xcprivacy` 内容；Swift 骨架源码（`MarkdownTextView.swift`/`BookmarkStore.swift`/`ContentView.swift` 等，M0.2/M0.5）。
