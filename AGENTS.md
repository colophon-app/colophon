# AGENTS.md

Shared instructions for AI coding agents (Claude Code, Codex, Cursor, …) working in this repo. `CLAUDE.md` points here. Keep this file short and high-signal — do not restate what the code or docs already say.

## What this is

Colophon: a native macOS Markdown editor for developers. Swift, SwiftUI shell + AppKit `NSTextView` (TextKit 2) editor core + swift-markdown parsing + `WKWebView` preview. Min deployment target macOS 15; built with the latest Xcode (macOS 26 SDK). Apache-2.0.

The plan lives in [`planning/`](planning/): read `planning/PRD.md` (what/why), `planning/ROADMAP.md` (phases), `planning/standards/` (how), `planning/preflight-checklist.md`, and the current milestone folder `planning/M0/`. The market research is in [`docs/`](docs/).

## Build / test / format

- Build & test: `xcodebuild test -scheme Colophon -destination 'platform=macOS'`.
- Format & lint: `xcrun swift-format` (ships with the toolchain — do not add it as a package dependency). Config in `.swift-format`.
- CI runs build + test + `swift-format lint --strict` + a localization check on every PR.

## Red lines (non-negotiable — a PR that violates these will be rejected)

1. **Byte-exact saves.** Never turn on smart quotes / dashes / substitutions. Round-trip must be byte-identical (or fail loudly). Preserve BOM, line endings, trailing newline. Strict UTF-8 — never lossy-decode.
2. **TextKit 2 only.** Never touch `NSTextView.layoutManager` (even a read silently downgrades to TextKit 1) and never use `scrollableTextView()`. Build the `NSTextLayoutManager` / `NSTextContentStorage` / `NSTextContainer` stack by hand.
3. **`swift-format` touches only `.swift`.** Never reformat user Markdown or any file under `docs/`, `planning/`, or a user's library.
4. **Local `.md` is the source of truth.** No proprietary storage format, ever. No lock-in.
5. **Dependencies:** SPM only, licenses must be Apache-2.0-compatible (MIT/BSD/ISC/Apache). No GPL/AGPL. No abandoned libs (Down/Ink/SwiftDown). Commit `Package.resolved`. STTextView is GPLv3 — do not vendor it.
6. **Content layer is never glass.** Liquid Glass is chrome-only; gate any `glassEffect` behind `if #available(macOS 26, *)`.

## Conventions

- Conventional Commits (`feat/fix/docs/refactor/perf/test/build/ci/chore`). Branch off `main`, open a PR (squash merge, linear history).
- Update `CHANGELOG.md` (Unreleased) in the same PR.
- User-facing strings go through `String(localized:)`; filenames / `.md` content / paths use `Text(verbatim:)` or plain `String`.
- Detailed per-rule notes live in `.claude/rules/`.
