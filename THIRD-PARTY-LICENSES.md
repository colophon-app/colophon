# Third-Party Licenses

Colophon bundles or links the third-party open-source software listed below.
Each entry records the component, version, SPDX license, upstream source, and —
for **vendored static assets** (files copied into this repo rather than pulled
via SwiftPM) — the SHA-256 of the exact file we ship, so the artifact is
reproducible and re-verifiable on every version bump (per
`planning/standards/dependencies-and-licenses.md` §4 and decision D-M1-11:
"看 LICENSE 文件、别信摘要").

SwiftPM dependencies (swift-markdown, swift-cmark, …) are pinned in
`Package.resolved`; their licenses are tracked there and in the dependencies
standard, and are not duplicated here.

---

## highlight.js

- **Use:** preview-only syntax highlighting for fenced code blocks. Run **server-side**
  inside an in-process JavaScriptCore context (decision **D-M1-14**); highlight.js
  never executes in the WKWebView, and Colophon makes zero outbound requests to fetch it.
- **Version:** 11.11.1
- **SPDX:** `BSD-3-Clause`
- **Source:** https://github.com/highlightjs/highlight.js
- **Vendored file:** `Colophon/Colophon/Preview/Resources/highlight.min.js`
- **SHA-256:** `c4a399dd6f488bc97a3546e3476747b3e714c99c57b9473154c6fb8d259b9381`
- **Build / language set:** "common" prebuilt bundle, downloaded from cdnjs
  (`https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js`);
  the common set includes every language Colophon highlights (swift, javascript,
  typescript, python, bash, json, xml, css, markdown, c, cpp, rust, go, yaml).
  Download date: 2026-07-22.

```
BSD 3-Clause License

Copyright (c) 2006, Ivan Sagalaev.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its contributors
  may be used to endorse or promote products derived from this software without
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
