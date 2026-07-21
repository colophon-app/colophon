# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Native macOS editor skeleton: folder-as-library (security-scoped, no proprietary format), a TextKit 2 source editor bridged from AppKit, and byte-exact open/edit/save (strict UTF-8, smart substitutions off).
- App Sandbox + Hardened Runtime; Developer ID signing and notarization.
- Continuous integration (GitHub Actions): build, unit tests, and `swift-format` lint on every push and pull request.
- Byte-exact round-trip unit tests for file I/O.
- Internationalization: a String Catalog with all user-facing strings extracted (English).
- Privacy manifest (`PrivacyInfo.xcprivacy`): no tracking, no data collection.
- Project scaffolding: Apache-2.0 license, product manifesto, governance files, `AGENTS.md` / `CLAUDE.md`, and the `docs/` (market research) and `planning/` (PRD, roadmap, standards, M0 plan) trees.
