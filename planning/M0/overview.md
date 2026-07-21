# M0 · 立项骨架 —— Overview

> 依据 [PRD §8](../PRD.md)、[ROADMAP §2](../ROADMAP.md)、[preflight A/B/D 组](../preflight-checklist.md) 与 [standards/](../standards/) 提炼。
> 本文固化 M0 的目标 / 范围 / 完成定义；调研见同目录 `research.md`，可照做步骤见 `plan.md`，过程决策记入 `decisions.md`。

## 目标

工程地基就位，**不追求任何功能好用**，只追求三件事：**地基正确 + 不可回撤的承诺就位 + 最烦的工程流水线趁空壳跑通**。

## 范围（做）

**仓库与治理**
- GitHub org `colophon-app` + repo `colophon`（public），**第一个 commit 就带 Apache-2.0 `LICENSE`**。
- README（产品宣言 + 两条不可回撤承诺：永久开源、本地 `.md` 唯一真相源永不引入私有格式）、`.gitignore`(Xcode/Swift)、CONTRIBUTING、多维护者治理声明、CODE_OF_CONDUCT、SECURITY.md、issue/PR 模板、FUNDING。
- 仓库自己的 `AGENTS.md` / `CLAUDE.md`（第一天 dogfood 路线 B）；把 `docs/` + `planning/` 归位进仓库。

**Xcode 工程骨架**
- SwiftUI App 生命周期，最低部署目标 **macOS 15**，用最新 Xcode（macOS 26 SDK）编译；定 Bundle ID。
- `NavigationSplitView` 三栏骨架 + `NSViewRepresentable` 桥接的**空 `NSTextView`(TextKit 2)** + 打开/编辑/保存单个 `.md`（**原子写 + byte-exact，关智能标点**）+ 深浅色跟随系统。
- 文档模型：**文件夹即文库**（security-scoped bookmark），**不用 `NSDocument`/`DocumentGroup`**。
- **App Sandbox + Hardened Runtime 自 M0 起开**。

**工程流水线（趁空壳跑通）**
- i18n 通道：`Localizable.xcstrings`（String Catalog）+「所有用户可见字符串走 `String(localized:)`」约定 + CI 检测硬编码字符串。
- CI（GitHub Actions macOS runner）：build + test + swift-format lint。
- 签名公证：tag 触发 `codesign → notarytool → stapler → dmg/zip → GitHub Release`。
- **Sparkle 2** 接进空壳（EdDSA appcast，托管 GitHub Releases）。
- `PrivacyInfo.xcprivacy` + Required-Reason API 审计；崩溃上报立场（默认零遥测）。
- 依赖/许可：源文件 SPDX 头 + CI 许可扫描（挡 GPL/AGPL）。

## 范围（不做 —— M0 明确排除）

- 任何编辑器功能：语法样式化、预览、GFM、数学、混合渲染、rubric 红批、主题（除系统深浅色）。
- 任何 AI / 路线 B 功能。
- **编辑内核选型 spike（D1）属 M1**——M0 只用普通 `NSTextView` 做源码文本，不碰混合渲染内核选型。

## 完成定义（DoD）

1. 能可靠打开、编辑、保存一个 `.md`（原子写、byte-exact、智能标点已关）。
2. build 出的 app **已签名公证**，在别人机器上双击能打开。
3. CI 在 PR 上绿（build + test + lint）。
4. i18n 通道就位（String Catalog + 约定 + lint）。
5. Sparkle 自更新通道接通（能检查到 appcast）。

## 关键已定决策（进 M0 即生效）

Apache-2.0 · 最低 macOS 15 · 文件夹即文库 · swift-format · Sandbox + Hardened Runtime 自 M0 · Sparkle 2 · 版本历史存 app 容器 · 英文优先 + i18n 预留。

## 依赖与外部前提（Evan 需准备）

- **Apple Developer Program 账号**（约 $99/年）——签名公证需要 Developer ID 证书 + 用于 notarytool 的 App Store Connect API key。**这是 M0 完成 DoD#2 的硬前提，最好现在就开始注册**（审核可能要几天）。
- GitHub org 创建权限。
- 签名公证是 M0 最坑的一段（preflight §B8/§D）——`research.md` 重点覆盖。
