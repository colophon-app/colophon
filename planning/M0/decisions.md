# M0 · 决策记录（decisions, ADR-lite）

> 本文记录 M0 阶段做出的决定及理由（随做随记）。这四条是 `research.md` §5 逼出的「跨阶段决策项」，按「研究→决定，不甩回问 Evan」的原则先拍定；标「可复核/可逆」的欢迎 Evan 事后推翻。

## D-M0-1 · Sparkle 自更新的联网方式 = 方案 A（Downloader XPC，app 层不授网）

- **背景**：security §R2.3 红线「MVP 不申请 `com.apple.security.network.client`」，但 Sparkle 自更新要下载（research §4.2）。
- **决定**：采用**方案 A**——`SUEnableDownloaderService=YES`，下载留在 Sparkle 自带的 Downloader XPC 内，**app 主体不加 `network.client`**。
- **理由**：守住 R2.3 红线（app 主体零出站是我们「本地优先/隐私」叙事的硬承诺）；代价（发行说明回落旧 WebView 行为）可接受。
- **注意**：Sparkle 2.6+ 起 Downloader XPC 默认不再沙箱化，**每次升级 Sparkle 必重读官方 sandboxing 指南复核**。此决策影响 M0.2 的 entitlements 与 M0.4 的签名。
- **状态**：已定（可复核）。若方案 A 落地受阻，退方案 B（全 app 加 `network.client`）须回本文写明理由。

## D-M0-2 · 工程形态 = 单个 `Colophon.xcodeproj`（M0 不引 XcodeGen/Tuist）

- **决定**：M0 直接提交单 target 的 `Colophon.xcodeproj`，依赖走 Xcode 的 SPM，`Package.resolved` 提交。
- **理由**：SPM 不能构建 macOS `.app`；XcodeGen/Tuist 是又一层会腐烂的构建依赖，违背「极小维护面」。留到 M1 模块化再评估。
- **状态**：已定（M1 可重评）。

## D-M0-3 · Bundle ID = `io.github.colophon-app.Colophon`

- **决定**：暂用 `io.github.colophon-app.Colophon`（对齐 GitHub org）。
- **理由**：尚未注册自有域名；此 ID 合法、稳定、可改。若将来注册了 `colophon.app` 等域名，可切 `app.colophon.Colophon`（改 Bundle ID 有迁移成本，越早定越好，故先锚定 io.github 形态）。
- **状态**：已定（注册域名后可复核）。

## D-M0-4 · 保存写入 API = `Data.write(to:options:.atomic)`（M0）

- **决定**：M0 保存用 `.atomic`（写临时文件→rename）满足原子语义。
- **理由**：足够满足 M0 的 byte-exact + 不写坏文件；`.atomic` 换 inode/可能丢 xattr、`replaceItemAt` 在 iCloud 下偶发 NSCocoaError 513——元数据保留 vs NSFileCoordinator 协调的**最终选型留到 M1**（architecture §3.1）。
- **状态**：已定（M1 D5 spike 后定终态）。

## D-M0-5 · Sparkle 自更新 + 发布自动化，延后到下一小节一起做（2026-07-21）

- **决定**：M0.5 的 Sparkle 自更新（DoD#5）不在本次做，与「发布自动化（`release.yml`）」合并为下一个专注小节。M0 以 **4/5 DoD** 落在一个干净里程碑；自更新计划已就绪（[sparkle-setup.md](./sparkle-setup.md)）。
- **理由**：① Sparkle 消费的 appcast 由发布流程产出，二者是一个功能的两半，一起做才是完整闭环、避免重复连线；② Sparkle 是全程最琐碎、唯一碰签名的一块（entitlements 合并细节需 `codesign` 亲验），更适合清醒专注时段做；③ DoD#1–4 已达成，在高点落袋。
- **状态**：已定（可复核）。入口见 [sparkle-setup.md](./sparkle-setup.md)。
