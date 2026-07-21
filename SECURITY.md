# Security Policy

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Report privately via [GitHub Private Security Advisories](https://github.com/colophon-app/colophon/security/advisories/new) (Security → Report a vulnerability). If that is unavailable, email evanyifanyang2026@gmail.com.

Please include a description, reproduction steps, affected version(s), and impact. We aim to acknowledge within 72 hours and will keep you informed as we work on a fix. Please give us a reasonable chance to release a fix before public disclosure.

## Supported versions

Colophon is pre-1.0. Until 1.0, only the latest released version receives security fixes.

| Version | Supported |
|---|---|
| latest release | ✅ |
| older | ❌ |

## Security boundaries

Colophon is a local, offline-first editor. Its security model:

- **The `WKWebView` preview is strictly isolated**: content is sanitized, a strict CSP is applied, only local trusted resources load, remote resources (including remote images by default) are blocked, and no remote code is ever fetched or executed. The JS↔Swift message bridge is minimal and validates all input.
- **App Sandbox + Hardened Runtime** are enabled; file access is limited to user-selected folders via security-scoped bookmarks.
- **No telemetry by default**; user content is never uploaded.
- **Future AI / MCP features** will be opt-in, off by default, scope-minimized, and gated by explicit per-operation confirmation with an audit trail.
