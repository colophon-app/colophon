<!-- Title must follow Conventional Commits, e.g. "feat(editor): reveal source on cursor line" -->

## What & why

<!-- What does this change and why? Link any related issue. -->

## Test plan

<!-- How did you verify this? -->

## Checklist

- [ ] `CHANGELOG.md` (Unreleased) updated
- [ ] Tests added/updated for file I/O, saving, or external-change handling (if touched)
- [ ] `swift-format lint --strict` passes; formatting touched only `.swift`
- [ ] No TextKit 1 access (`.layoutManager` / `scrollableTextView()`)
- [ ] Smart punctuation stays disabled; saves remain byte-exact
- [ ] No GPL/AGPL or abandoned dependencies added; `Package.resolved` committed
- [ ] User-facing strings use `String(localized:)`; content/paths use `verbatim`
