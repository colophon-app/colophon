# Engineering rules (enforceable)

These expand the red lines in `AGENTS.md`. Treat each as a Code-review must-check.

## TextKit 2 (headline pitfall)
- Never access `NSTextView.layoutManager` — even a read silently and permanently downgrades the view to TextKit 1 (still true on macOS 26). Never use `NSTextView.scrollableTextView()` or the no-arg initializer.
- Construct the stack manually: `NSTextLayoutManager` → `NSTextContentStorage` (`addTextLayoutManager`) → `NSTextContainer` → `NSTextView(frame:textContainer:)`.
- Any TextKit-1 access must sit only in the `else` branch of `if let tlm = tv.textLayoutManager { … } else { … }`.

## byte-exact saves
- In `makeNSView`, set all five `isAutomatic*SubstitutionEnabled`/correction flags to `false`, AND register the matching `NSAutomatic*SubstitutionEnabled = false` defaults at app launch (view-level settings are overridden by system preferences).
- Decode with strict UTF-8; on failure, surface an error and let the user pick an encoding — never lossy-decode or swallow `�`.
- Record and restore BOM, line-ending style (LF/CRLF), and trailing-newline exactly. Do not normalize whitespace.
- Save with `Data.write(to:options:.atomic)` for M0 (final I/O API deferred to M1).

## SwiftUI ↔ AppKit bridge
- `Coordinator` stores a `Binding`, never the `View` (the representable is a value type and gets recreated).
- In `updateNSView`, guard `if tv.string != text` before writing back to avoid an update loop / caret jump.

## Sandbox & files
- App Sandbox + Hardened Runtime are on from M0. Folder access uses `NSOpenPanel` + security-scoped bookmarks (resolve → handle `stale` → `startAccessingSecurityScopedResource` on the *resolved* URL → balance `stop`).
- Release builds must not contain `com.apple.security.get-task-allow`.

## Dependencies & formatting
- SPM only; Apache-2.0-compatible licenses; no GPL/AGPL; no abandoned libs. Commit `Package.resolved`. Re-check a dependency's license on every bump (licenses change).
- `swift-format` runs only on `.swift`. Never format Markdown, `docs/`, `planning/`, or user files.
