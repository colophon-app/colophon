# Contributing to Colophon

Thanks for your interest. Colophon is early (milestone M0 — scaffolding), so the most useful contributions right now are discussion, issues, and small focused PRs.

## Governance

Colophon is maintained by a small team and intends to stay that way. To avoid the single-maintainer failure that kills most open-source editors, merge rights and review responsibility are shared as the project grows, and `CODEOWNERS` is kept current. Decisions and their rationale are recorded under `planning/`.

## Ground rules

- Be kind. By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
- Read [`AGENTS.md`](AGENTS.md) — its **red lines** are non-negotiable (byte-exact saves, TextKit 2 only, local `.md` as source of truth, Apache-2.0-compatible deps, content layer never glass).
- Big changes: open an issue or discussion first so we agree on direction before you build.

## Development

- Requirements: latest Xcode (macOS 26 SDK). Deployment target is macOS 15.
- Build & test: `xcodebuild test -scheme Colophon -destination 'platform=macOS'`
- Format & lint: `xcrun swift-format format -i` / `xcrun swift-format lint --strict --recursive .` (ships with the toolchain; config in `.swift-format`; it must only ever touch `.swift`).

## Pull requests

- Branch off `main`; one focused change per PR. We use squash merge + linear history.
- Titles follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`).
- Update `CHANGELOG.md` (Unreleased) in the same PR.
- CI (build + test + `swift-format` lint + localization + license check) must be green.
- Add tests for anything touching file I/O, saving, or external-change handling — data safety is a hard requirement.

## Reporting bugs / security

- Bugs: use the issue templates.
- Security vulnerabilities: **do not** open a public issue — see [SECURITY.md](SECURITY.md).
