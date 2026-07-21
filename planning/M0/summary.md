# M0 收官总结（Milestone M0 · 立项骨架）

> 日期：2026-07-21 ｜ 状态：**4/5 DoD 达成,主体完成**。#5(Sparkle 自更新)按计划**延后**到下一小节、与发布自动化一起做(见 [sparkle-setup.md](./sparkle-setup.md)、[decisions.md](./decisions.md) D-M0-5)。

## 一句话
从零搭起 Colophon 的工程地基:一个**原生、沙箱化、已公证、CI 守着、多语言就绪、隐私合规**的 macOS Markdown 编辑器,加一个**公开、脚手架完整**的开源仓库——用一天。

## DoD 核对
| # | 目标 | 状态 | 证据 |
|---|---|---|---|
| 1 | 可靠开/编/存一个 `.md` | ✅ | 手测通过 + `MarkdownFileIOTests`(byte-exact 往返 + 非法 UTF-8 拒绝)绿 |
| 2 | 签名公证、任何 Mac 能开 | ✅ | `spctl` = **Notarized Developer ID**;`stapler validate` 通过;Intel+Apple Silicon 通用二进制 |
| 3 | CI 构建+测试+lint | ✅ | GitHub Actions 绿(`macos-26`,`xcodebuild test` + `swift-format lint --strict`) |
| 4 | i18n 通道 | ✅ | `Localizable.xcstrings` 抽取 11 条(含 `%1$@` 位置占位符) |
| 5 | Sparkle 自更新 | ⬜ **延后** | 计划已就绪 [sparkle-setup.md](./sparkle-setup.md) |

## 交付物
- **公开仓库** `github.com/colophon-app/colophon`(Apache-2.0):
  - `docs/`(20 份市场调研)+ `planning/`(PRD / ROADMAP / 6 份 standards / design-direction / preflight / M0 全套)
  - 治理全套:LICENSE / README(含两条不可回撤承诺)/ CoC / SECURITY / CONTRIBUTING / issue·PR 模板 / `AGENTS.md` / `CLAUDE.md` / `.claude/rules`
  - **Xcode 工程**:SwiftUI 壳 + AppKit `NSTextView`(TextKit 2)编辑区;文件夹即库(security-scoped);byte-exact 保存;`Localizable.xcstrings`;`PrivacyInfo.xcprivacy`;`MarkdownFileIOTests`
  - CI(`ci.yml`)
- **已公证的 `Colophon.app`**(Developer ID,Team 7V6USF6B96,通用二进制)——可直接分发,任何 Mac 双击即开。

## M0 关键决策(详见 [decisions.md](./decisions.md))
Sparkle 方案 A(app 不授网)· 单 `.xcodeproj` · Bundle ID `io.github.colophon-app.Colophon` · 保存 `.atomic`(终态留 M1)· 最低 macOS 15 · Apache-2.0 · 英文优先+i18n · 文件夹即库(不用 NSDocument)。

## 有意延后(排期,非烂尾)
- **#5 Sparkle 自更新 + 发布自动化(`release.yml`)** —— 天生一对(后者产出前者要吃的 appcast),下一小节一起做。计划:[sparkle-setup.md](./sparkle-setup.md)。
- **分支保护(main ruleset)** —— `build-and-lint` 已在 main 注册,可随时配 required checks。
- **「记住上次文件夹」(`bookmarks.app-scope`)** —— 需 Xcode 26 自定义 entitlements(与 Sparkle 同一套机制,一起做更省事)。
- **CI 跑 UI 测试 / 硬编码字符串 lint** —— 目前只跑单元测试,可后补。

## 工程记忆(下次少踩坑)
- Xcode 26 用「能力即构建设置」模型,**不再生成 `.entitlements` 文件**(App Sandbox = `ENABLE_APP_SANDBOX` 构建设置);要加自定义 entitlement 得新建文件并设 `CODE_SIGN_ENTITLEMENTS`,与构建设置**合并**(用 `codesign -d` 验)。
- **TextKit 2**:碰 `.layoutManager`(哪怕只读)即静默降级 TextKit 1 —— 手搭 `NSTextLayoutManager`/`NSTextContentStorage`/`NSTextContainer` 三件套。
- SourceKit 编辑器红波浪多为**跨文件索引滞后**,一次构建即清;真错以构建/CI 为准。
- `@Published`/`ObservableObject` 需 `import Combine`。
- 本地 Xcode **Distribute → Direct Distribution** 是最省事的签名+公证路径(无需 API key/secrets)。

## 下一小节入口
**发布自动化 + Sparkle**:配 GitHub secrets(Developer ID `.p12` + App Store Connect API key)→ 写 `release.yml`(tag → 签名 → 公证 → 生成 appcast → 发 Release)→ 按 [sparkle-setup.md](./sparkle-setup.md) 接 Sparkle → 本地验一次。做完 = **一条 `git tag` 发版、用户自动更新**的闭环,M0 满勾 5/5。
