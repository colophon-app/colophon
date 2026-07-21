# M1.0 spike fixtures

Test corpus for the M1.0 kernel spike (see [`../../planning/M1/plan.md`](../../planning/M1/plan.md) M1.0 Day 0). Each file maps to a DoD risk:

| File | Exercises |
|---|---|
| `agent-file.mdc` | byte-exact fidelity: YAML frontmatter, code fences, and straight-quote / ASCII-dash / triple-dot traps that must NOT be "smartened" on save |
| `gfm-kitchen-sink.md` | GFM tables · task lists · strikethrough · footnotes, plus LaTeX / Mermaid / fenced code for the preview slice |
| `cjk-emoji.md` | SourceRange(UTF-8) ↔ NSRange(UTF-16) offset correctness under CJK, emoji, and ZWJ sequences |
| `crlf-bom-no-trailing.md` | the byte-exact torture case: UTF-8 BOM + CRLF line endings + no trailing newline (open → save must be byte-identical) |
| `large-synthetic.md` | ~1.1 MB perf fixture — typing latency (~60fps) and large-document scroll stability. **Git-ignored (regenerable)** — recreate with the generator in `planning/M1/plan.md` M1.0 Day 0 |

**Not shipped in the app** — these live outside the Xcode target; they are for manual eyeballing (open the folder in Colophon) and future automated byte-exact regression tests.
