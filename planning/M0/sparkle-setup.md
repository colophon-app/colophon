# M0.5 · Sparkle 2 自更新 —— 已验证的接入步骤

> 由一轮联网核实(2026-07,一手来源见文末)得出,针对本项目设置:Xcode 26「能力即构建设置」模型(无 .entitlements 文件)、App Sandbox、Developer ID 公证、**Option A**(app 主体不授网、走 Sparkle 的 Downloader XPC)。
> 决策依据见 [decisions.md](./decisions.md) D-M0-1。temporary-exception 例外对 **Developer ID 分发 OK**,只是不能上 Mac App Store(我们不受影响)。

## 1. entitlements(最关键,唯一需 codesign 亲自验的一步)

新建 `Colophon/Colophon.entitlements`(**用文本/plist 编辑器建,别用 Signing & Capabilities 的 "+"** —— Xcode 26 那个按钮会打乱布局),**只放 mach-lookup 例外**:

```xml
<key>com.apple.security.temporary-exception.mach-lookup.global-name</key>
<array>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)-spks</string>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)-spki</string>
</array>
```

- 两条缺一即"authorization error";这是 mach 服务名(status/installer),不是 XPC 的 bundle id。
- **不写** app-sandbox / user-selected —— 那两个由现有构建设置合成;**不加** `network.client`(守 Option A 零出站)。
- 设 `CODE_SIGN_ENTITLEMENTS = Colophon/Colophon.entitlements`;保持 `ENABLE_APP_SANDBOX=YES` / `ENABLE_USER_SELECTED_FILES=readwrite` / `ENABLE_HARDENED_RUNTIME=YES` 不变(它们与文件在打包阶段**合并**)。
- **必须验证**:`codesign -d --entitlements :- <Colophon.app>` 要同时看到 `app-sandbox`、`files.user-selected.read-write`、两条 `-spks`/`-spki`,且**无** `network.client`。
- **后备(若合并没生效)**:关掉 `ENABLE_APP_SANDBOX`/`ENABLE_USER_SELECTED_FILES`,把 app-sandbox + user-selected read-write + 两条例外**全写进这一个文件**(hardened runtime 仍用构建设置开)。

## 2. Info.plist 键
`SUFeedURL`(appcast 地址)、`SUPublicEDKey`(步骤 3 公钥)、`SUEnableInstallerLauncherService=YES`、`SUEnableDownloaderService=YES`、`CFBundleVersion`(**递增的构建号** —— Sparkle 比对的是它,不是 ShortVersionString)。

## 3. SPM + generate_keys
- Add Package Dependencies:`https://github.com/sparkle-project/Sparkle`,规则 **Up to Next Major 2.0.0**,加到 app target。
- 跑一次 `.../artifacts/sparkle/Sparkle/bin/generate_keys` → 私钥进登录 Keychain(**异地备份,丢了就再也签不出更新**),公钥打印出来填进 `SUPublicEDKey`。

## 4. SwiftUI 接线
`SPUStandardUpdaterController(startingUpdater: true, ...)` + `.commands { CommandGroup(after: .appInfo) { CheckForUpdatesView(updater:) } }` + 一个订阅 `updater.publisher(for: \.canCheckForUpdates)` 的 ViewModel。(完整代码见 Sparkle 官方 programmatic-setup)

## 5. 本地验证(不发真版本)
`generate_appcast` 生成签名 appcast → 把 appcast 里的构建号设得**高于**本地 → 目标目录 `python3 -m http.server` → `SUFeedURL` 指本地 → **跑导出的独立 app(不要从 Xcode Run)** → "Check for Updates…" 应报"有更新";Console 无 `mach-lookup ... deny` = 例外配对成功、且零出站仍能检查。

## 坑
- 别用 Signing & Capabilities 的 "+" 改 entitlements;直接编辑 plist。
- 必用 `codesign -d` 验最终合并(源文件只是输入)。
- `CFBundleVersion` 必须递增;签名不用 `--deep`。

## 一手来源
- Sparkle 沙箱/键/服务:https://sparkle-project.org/documentation/sandboxing/
- Sparkle 主页 / SwiftUI 接线 / 发布:https://sparkle-project.org/documentation/ · /programmatic-setup/ · /publishing/
- Xcode 26 能力即构建设置:https://developer.apple.com/documentation/xcode-release-notes/xcode-26-release-notes
- Apple 临时例外须手写:https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/AppSandboxTemporaryExceptionEntitlements.html
- 实战 Sparkle+签名+公证:https://steipete.me/posts/2025/code-signing-and-notarization-sparkle-and-tears
- mach-lookup deny 症状:https://github.com/sparkle-project/Sparkle/discussions/2290
