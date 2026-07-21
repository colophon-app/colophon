# Markdown 编辑器技术栈与内核选型（重点：Swift / macOS 原生）

> 类别总体观察：Markdown 编辑器的技术选型本质上是「三层解耦」——文本编辑引擎（负责输入、光标、布局）、Markdown 解析器（负责语法树）、渲染层（负责预览/导出），三层各自都有成熟组件，但把三者拼成 Typora 式「行内混合渲染」的胶水代码才是真正的工作量所在。Web 阵营（CodeMirror 6 / ProseMirror 系）方案最成熟、先例最多，但要付出 Electron/WebView 的「原生感」代价；原生 Swift 阵营解析器已经不缺（Apple 官方 swift-markdown 质量很高），缺的是「带语法隐藏的混合渲染文本视图」，TextKit 2 四年后仍有大量实现层的坑，Bear 等头部产品干脆自研内核。2026 年的两个新变量值得注意：一是 macOS 26 的 SwiftUI TextEditor 终于支持 AttributedString 富文本编辑，二是 2026 年 4 月出现的开源项目 nodes-app/swift-markdown-engine 首次把「AppKit + TextKit 2 + 混合实时渲染」以 Apache-2.0 开源，几乎就是为我们这类产品准备的起点。另一个行业动向：CodeMirror / ProseMirror 作者 Marijn Haverbeke 已于 2026 年 4 月将两个项目迁出 GitHub 至自建 forge（code.haverbeke.berlin），GitHub 仓库归档为只读镜像，开发与 npm 发布仍活跃。

---

## 一、Web 编辑器内核（若走 WebView 路线的候选）

### CodeMirror 6
- **定位与能力**：Marijn Haverbeke 开发的代码编辑器内核（TypeScript，MIT），完全模块化：EditorState/EditorView 分离、事务式状态更新、Decoration（mark/widget/replace）机制、Lezer 增量解析器。@codemirror/lang-markdown 提供官方 Markdown 支持（基于 lezer-markdown，可扩展 GFM 语法节点）。虚拟滚动使其对超长文档表现极佳。
- **成熟度**：dev 仓库约 7.8k star（旧版 codemirror5 另有约 2.6 万）；2026-04-15 起 GitHub 仓库归档、迁至 code.haverbeke.berlin 自建托管，开发仍活跃（迁移后 issue 照常处理），npm 发布不受影响。6.0 稳定版发布于 2022 年。
- **与 Markdown 编辑器的适配度**：极高——这是 Obsidian Live Preview 的基础。以「纯 Markdown 源码为唯一数据源 + 装饰器按光标位置显示/隐藏语法标记」的模式实现混合渲染，保存/复制与源文件字节一致。开源复刻已有 atomic-editor（Obsidian 式行内预览，2026 年在 HN 发布）和 codemirror-live-markdown（含中文架构设计文档，KaTeX/表格/代码块插件化）。
- **对原生 macOS Swift 开发的适用性**：只能经 WKWebView 内嵌，需自建 JS↔Swift 桥（文件读写、菜单命令、查找、拼写检查）；IME/触控板惯性滚动在 WKWebView 中表现尚可但非完全原生。
- **代表使用者**：Obsidian、Chrome DevTools、Replit、Sourcegraph、GitHub 部分编辑场景。

### ProseMirror
- **定位与能力**：同为 Marijn 作品的「所见即所得」富文本内核（MIT），核心是带 Schema 约束的树状文档模型 + 可协作的 OT 式事务系统。prosemirror-markdown 模块负责 Markdown ↔ 文档树双向转换。
- **成熟度**：主仓库约 8.7k star；2026 年 4 月与 CodeMirror 一同迁至 code.haverbeke.berlin，GitHub 归档为镜像，维护活跃（2015 年至今持续开发）。
- **与 Markdown 编辑器的适配度**：中等偏高，但与 CM6 是两种哲学：PM 存储的是语义化富文本树、Markdown 只是序列化格式，往返转换会丢失源码细节（空行、标记风格、非标准语法）；适合「用户不关心源码」的 Notion 式产品，不适合「源文件即真相」的 Markdown 工具。
- **对原生 macOS Swift 开发的适用性**：同样只能走 WKWebView；桥接复杂度高于 CM6（文档模型在 JS 侧）。
- **代表使用者**：Tiptap/Milkdown 的底座、New York Times 编辑系统、Atlassian 编辑器、Asana。

### Tiptap
- **定位与能力**：ProseMirror 之上的「无头」富文本框架（TypeScript），把 PM 的陡峭 API 封装成扩展（Extension）体系，官方提供 StarterKit、表格、任务列表、协作、斜杠命令等上百个扩展；Markdown 支持经社区/官方扩展实现（输入规则 + 序列化）。
- **成熟度**：约 3.77 万 star，MIT 核心免费；商业模式为 Pro 扩展 + 协作云（订阅制，含免费档与数十至数百美元/月的团队档）。维护非常活跃（2026-07 仍高频提交）。
- **与 Markdown 编辑器的适配度**：适合「富文本为主、Markdown 为输入输出格式」的产品；继承 PM 的源码保真问题。斜杠命令、气泡菜单等交互组件可直接借鉴其交互设计。
- **对原生 macOS Swift 开发的适用性**：仅 WKWebView 路线；若做 AI 写作类产品其 AI 扩展（Content AI，付费）有现成交互范式可参考。
- **代表使用者**：GitLab 的富文本编辑器、Substack？（未知）、大量 Notion 类创业产品。

### Milkdown
- **定位与能力**：插件驱动的 WYSIWYG Markdown 编辑器框架（TypeScript，MIT）：ProseMirror 做编辑 + remark/unified 做解析，天生以 Markdown 为一等公民（这点与 Tiptap 不同）；官方插件覆盖 GFM、数学（KaTeX）、图表（Mermaid）、斜杠命令、协作。
- **成熟度**：约 1.17 万 star，维护活跃（2026-07 仍在提交）。
- **与 Markdown 编辑器的适配度**：高——它就是「开箱即用的 Typora 式网页编辑器」；主题系统完善。但仍是 PM 底座，源码往返保真度弱于 CM6 方案。
- **对原生 macOS Swift 开发的适用性**：WKWebView 内嵌可行，是「原生壳 + Web 编辑器」路线里集成成本最低的选择之一（功能全家桶已拼好）。
- **代表使用者**：多个开源笔记/博客项目（具体头部产品未知）。

### Lexical
- **定位与能力**：Meta 开源的可扩展文本编辑器框架（MIT），强调可靠性、无障碍与性能；@lexical/markdown 提供快捷输入变换与 Markdown 导入导出。核心框架无关，React 绑定最成熟。
- **成熟度**：约 2.37 万 star，Meta 团队持续维护（2026-07 活跃）。
- **与 Markdown 编辑器的适配度**：中等——Markdown 是「支持的格式」而非核心模型，混合渲染需自行实现；协作、评论等场景强。
- **对原生 macOS Swift 开发的适用性**：有一个独特资产：Meta 另开源了 lexical-ios（Swift + TextKit 实现的同构编辑器核心），证明「JS 编辑器语义 + 原生 TextKit 渲染」路线可行，但 lexical-ios 面向 iOS/UIKit 且更新缓慢，直接复用价值有限、参考价值高。
- **代表使用者**：Facebook/Instagram 的发帖编辑器、WordPress？（未知）、众多 React 应用。

### Slate
- **定位与能力**：完全可定制的富文本编辑框架（React，MIT），提供文档模型与操作原语，几乎不带默认功能——一切自己搭。
- **成熟度**：约 3.17 万 star，但常年标注 beta、API 有破坏性变更史；2026 年仍有提交但节奏放缓。社区实际多经 Plate（udecode/plate）这类上层套件使用。
- **与 Markdown 编辑器的适配度**：低——Markdown 序列化、语法高亮全需自建；论坛常见抱怨是中文/日文 IME 组合输入 bug 多。
- **对原生 macOS Swift 开发的适用性**：不推荐；相对 CM6/PM 无优势。
- **代表使用者**：Sanity Portable Text 编辑器等（多为深度定制团队）。

### Monaco Editor
- **定位与能力**：VS Code 的编辑器内核抽取版（微软，MIT），面向代码：智能提示、多光标、diff 视图、minimap。Markdown 场景下只是「带高亮的源码编辑器」，无行内渲染能力。
- **成熟度**：约 4.64 万 star，微软持续维护。
- **与 Markdown 编辑器的适配度**：低——体积大（数 MB 起）、按代码编辑设计（等宽字体、行号范式）、不支持软换行下的排版美感需求，官方不支持移动端；写作类产品几乎无人选它。
- **对原生 macOS Swift 开发的适用性**：仅 WKWebView，且是三者（CM6/PM/Monaco）中最重的；不建议。
- **代表使用者**：VS Code 本体、Azure Portal、TypeScript Playground。

---

## 二、成品编辑器的实现思路解剖

### Typora 的实现思路
- **定位与能力**：闭源商业产品（Abner Lee 开发，$14.99 买断/3 台设备/15 天试用，当前 1.13.x，2026 年仍活跃更新），是「行内混合渲染」交互范式的开创者：输入即渲染，光标进入某元素时展开该元素的 Markdown 源码。
- **实现要点（据公开资料与逆向项目）**：Electron 壳 + 基于 AST 的自研「Hybrid View」实时渲染引擎，编辑区本质是 HTML（contenteditable 系），代码块内嵌 CodeMirror；主题即 CSS 文件。其方言是 GFM 超集但不完全遵守 CommonMark（强调解析、连续空段落等有差异），社区有 typora-parser 项目专门复刻其输出。1.13 版起数学渲染升级到 MathJax v4。
- **与 Markdown 编辑器的适配度**：它就是标杆本身；其「span 级即时渲染 + 光标处回退源码」的粒度定义被 Obsidian/Bear 沿用。
- **对原生 macOS Swift 开发的适用性**：思路可搬到 TextKit 2（swift-markdown-engine 正是原生复刻）；直接复用不可能（闭源）。
- **代表使用者**：本身即终端产品；常见抱怨：Electron 内存占用、无移动端、闭源后社区无法修 bug、大文档（数万行）卡顿。

### Mark Text 的 Muya 内核
- **定位与能力**：Mark Text 是开源 Typora 复刻（Electron，MIT，约 5.89 万 star——本类别 star 最高的完整编辑器）；其编辑内核 Muya 为自研：以 Markdown 源码为数据源、contenteditable + snabbdom 虚拟 DOM 做实时渲染，支持 GFM、KaTeX 数学、Mermaid 等图表。
- **成熟度**：警示案例——主程序最后一个正式版本 v0.17.1 停在 2022 年 3 月，长期无实质开发；独立拆分的 muya 仓库（716 star）已于 2026 年 5 月正式归档。
- **与 Markdown 编辑器的适配度**：源码可读，是研究「如何用 web 技术自研混合渲染内核」的最完整公开教材；但也证明了自研 web 内核的维护成本足以拖垮社区项目。
- **对原生 macOS Swift 开发的适用性**：仅作架构参考（AST 设计、光标-语法映射逻辑）；用户论坛常见抱怨：丢数据 bug、表格编辑不稳、停更。
- **代表使用者**：Mark Text 本体。

### Obsidian 的编辑器（基于 CM6）
- **定位与能力**：Obsidian（Electron，闭源，个人免费、2025 年 2 月起商用亦免费；Sync 约 $4/月起、Publish $8/月起附加服务）的 Live Preview 编辑器构建在 CodeMirror 6 上：以 CM6 Decoration 机制按光标/选区位置隐藏或还原语法标记，源码模式与实时模式共用同一状态；wiki 链接、嵌入、callout 等为自定义语法树扩展。
- **成熟度**：产品持续高频更新；编辑器 API 向插件开放 CM6 扩展点，插件生态超 2000 个。
- **与 Markdown 编辑器的适配度**：是「CM6 = Markdown 混合编辑最佳 web 底座」的最强证明；官方开发者称 CM6「上手陡峭但极端可扩展」。
- **对原生 macOS Swift 开发的适用性**：若选「原生壳 + WKWebView 内嵌 CM6」路线，Obsidian 的实现粒度（行级揭示 + 元素级 widget）就是规格书；开源参考见 atomic-editor / codemirror-live-markdown。
- **代表使用者**：本身即终端产品；常见抱怨：Electron 手感与内存、启动速度、原生 macOS 集成弱（无系统服务/Handoff 等）。

### Bear 的自研方案（Panda 编辑器）
- **定位与能力**：Shiny Frog 为 Bear 2（2023 年 7 月发布，订阅 $2.99/月或 $29.99/年）自研的编辑器，开发期代号 Panda 并曾发布免费独立测试版。据开发者在 Reddit「Bear 2 under the hood」（2023-11）的说明：内核为 C++ 实现的 AST 引擎，其上以 Objective-C/Swift 封装原生视图层，核心代码跨 Mac/iPad/iPhone 复用。官方数据：打开 9.4 万词的《白鲸记》仅 55ms，比 Bear 1 快 5 倍以上。支持表格、脚注、YAML 等扩展，语法标记在光标离开时隐藏、选中时显现，支持折叠。
- **成熟度**：闭源；持续迭代（2026 年 4 月 Bear 2.8 加入 BearCLI、Claude Connector 与 MCP server——头部原生笔记应用已在接 AI 协议）。衍生新品 Lettera 同样构建在 Panda 上，做成「打开任意 .md 文件」的 CommonMark 独立编辑器。
- **与 Markdown 编辑器的适配度**：证明了原生混合渲染可以做到 web 方案达不到的性能与手感；也说明头部团队认为 TextKit 默认能力不够、值得自研 C++ 内核。
- **对原生 macOS Swift 开发的适用性**：架构范本（解析内核与平台视图分离、增量重排版）；不开源，只能借鉴交互与指标。
- **代表使用者**：Bear 2、Lettera。

---

## 三、Markdown 解析器（JS / C / Rust）

### markdown-it
- **定位与能力**：JS 生态最流行的 CommonMark 解析器（MIT，约 2.17 万 star）：100% CommonMark 合规、可选 GFM 表格/删除线、庞大的 markdown-it-* 插件生态（脚注、任务列表、数学、锚点等）、高性能、输出 HTML 为主（token 流可拦截）。
- **成熟度**：2026-07 仍有维护提交，但功能已冻结多年（稳定期项目）。
- **与 Markdown 编辑器的适配度**：适合「源码编辑 + HTML 预览」的分屏架构（VS Code 内置预览即此方案）；token 流不带完整源位置树，做行内混合渲染不如 Lezer/AST 型方案。
- **对原生 macOS Swift 开发的适用性**：只适合放进 WKWebView 预览端（随 JS bundle 分发）；Swift 侧无法直接调用。
- **代表使用者**：VS Code Markdown 预览、Eleventy、无数 JS 项目。

### remark / unified
- **定位与能力**：unified 生态的 Markdown 处理器（MIT，remark 约 9.0k star）：micromark（CommonMark 合规）解析为 mdast 语法树，插件在 AST 层变换（remark-gfm、remark-math、remark-frontmatter…），可经 rehype 转 HTML，是「Markdown 编译器基础设施」而非编辑器组件；MDX 构建其上。
- **成熟度**：2026-07 活跃维护，生态庞大（数百插件）。
- **与 Markdown 编辑器的适配度**：AST 带精确源位置，适合做 lint、格式化、导出流水线；Milkdown 用它做解析层。性能低于 markdown-it/cmark。
- **对原生 macOS Swift 开发的适用性**：同样仅限 WebView/Node 侧；若做「导出到多格式」的 JS 工具链（如打包一个导出 pipeline）值得用。
- **代表使用者**：MDX、Astro/Gatsby/Docusaurus 内容管线、Milkdown。

### cmark-gfm
- **定位与能力**：GitHub 维护的 cmark（CommonMark C 参考实现）分叉，加入 GFM 扩展：表格、删除线、自动链接、tagfilter、任务列表（脚注为上游 cmark 能力，需启用）。C 语言、极快（比 Markdown.pl 快数千倍级）、经大量模糊测试，AST 可编程操作后再渲染 HTML/其他格式。
- **成熟度**：约 1.1k star；维护以安全修复为主（2023 年集中修复多起多项式复杂度 DoS CVE），最新版本 0.29.0.gfm.13，仓库 2026-07 仍有提交但发版节奏慢。BSD 系许可。
- **与 Markdown 编辑器的适配度**：事实上的 GFM 参考实现，方言兼容性最有保障；AST 直接操作「并不轻松」（Loopwerk 评测语），一般经上层封装使用。
- **对原生 macOS Swift 开发的适用性**：极佳——C 库可直接进 SPM；Apple 的 swift-cmark 就是它的分叉，等于官方替你维护了 Swift 集成。
- **代表使用者**：GitHub 渲染管线（历史）、Apple swift-markdown、Bear 之外几乎所有原生 Markdown 应用的底层直系或旁系。

### pulldown-cmark
- **定位与能力**：Rust 的 CommonMark 拉式（pull）解析器（MIT，约 2.65k star）：事件流 API、零拷贝、内存占用低；扩展含表格、脚注、删除线、任务列表，近年版本加入数学扩展。
- **成熟度**：活跃（2026-07 有提交），已迁移到独立组织维护。
- **与 Markdown 编辑器的适配度**：事件流适合流式渲染与超大文档，是 Rust 工具链（含 Tauri 应用）的默认选择。
- **对原生 macOS Swift 开发的适用性**：需经 C FFI 桥接 Rust，收益不明显——同能力的 cmark-gfm 集成成本低得多；除非整体走 Tauri/Rust 路线。
- **代表使用者**：mdBook、rustdoc。

### comrak
- **定位与能力**：cmark-gfm 的 Rust 移植（BSD 系，约 1.65k star），扩展比 cmark-gfm 更多：脚注、wiki 链接、描述列表、front matter、header ID、数学、快捷表情等，且保证 GFM 输出兼容。
- **成熟度**：单人主导但非常活跃（2026-07 仍在提交）。
- **与 Markdown 编辑器的适配度**：扩展覆盖面是三个系统级解析器里最全的（尤其 wiki 链接原生支持）。
- **对原生 macOS Swift 开发的适用性**：同 pulldown-cmark，需 Rust FFI；仅在 Tauri/Rust 架构下才是首选。
- **代表使用者**：Rust 生态多个论坛/文档工具（具体头部未知）。

---

## 四、Swift 解析器

### swift-markdown (Apple 官方)
- **定位与能力**：Apple/swiftlang 官方 Markdown 解析构建库（Apache-2.0，约 3.4k star）：基于 swift-cmark（cmark-gfm 分叉）解析，暴露为不可变、线程安全、写时复制的 Swift 值类型语法树；提供 Visitor/Rewriter 遍历改写、精确 SourceRange（做编辑器高亮的关键）、块指令（Block Directive）扩展；支持 GFM 表格/删除线/任务列表与 Aside 等。
- **成熟度**：swiftlang 组织持续维护（2026-07 活跃），随 Swift 工具链演进；是 DocC 的解析底座。
- **与 Markdown 编辑器的适配度**：高——SourceRange + 值类型 AST 正是「解析驱动的属性字符串高亮」所需；短板是自带 HTML 输出能力有限，导出 HTML 通常自写 visitor 或直接用底层 cmark 的 HTML 渲染。
- **对原生 macOS Swift 开发的适用性**：本类别最佳解析选择：官方维护、SPM 一行引入、许可宽松、与 cmark-gfm 方言对齐。
- **代表使用者**：Apple DocC、Xcode 文档管线、swift-markdown-ui（经其解析）。

### swift-cmark
- **定位与能力**：swiftlang 维护的 cmark 分叉（约 324 star），在 gfm 分支上跟进 cmark-gfm 扩展，并打包成可被 SwiftPM 直接消费的 C target；一般不直接用，而是作为 swift-markdown 的依赖。
- **成熟度**：随 swift-markdown 一起活跃维护（2026-07 有提交）；BSD 系许可。
- **与 Markdown 编辑器的适配度**：需要极致解析性能或直接要 HTML 输出时可绕过 swift-markdown 直接调它。
- **对原生 macOS Swift 开发的适用性**：作为依赖自动获得；单独使用 API 是 C 风格，体验一般。
- **代表使用者**：swift-markdown、DocC。

### Down
- **定位与能力**：老牌 Swift cmark 封装（MIT，约 2.5k star）：一行把 Markdown 转 HTML/NSAttributedString/XML，附带 DownView（WKWebView 预览组件）。基于 CommonMark 0.29、无 GFM 扩展。
- **成熟度**：实质停更——最后提交 2023-07，README 长期挂「寻找维护者」；不建议新项目引入。
- **与 Markdown 编辑器的适配度**：历史上是 iOS/macOS 应用做「Markdown→富文本显示」的默认答案，现已被 swift-markdown + 自定义渲染或 swift-markdown-ui 取代。
- **对原生 macOS Swift 开发的适用性**：仅作 legacy 参考（其 AttributedString 渲染器代码可借鉴）。
- **代表使用者**：早年大量 iOS 笔记/聊天应用。

### Ink (John Sundell)
- **定位与能力**：纯 Swift 手写 Markdown 解析器（MIT，约 2.5k star），API 优雅、支持自定义修改器（modifier），为静态博客引擎 Publish 而生；明确不追求完整 CommonMark 合规。
- **成熟度**：休眠——最后提交 2024-03，多个修 bug 的 PR 长期无人合并；Loopwerk 评测结论：「API 最理想，但部分文件渲染就是不对，属于 dealbreaker」。
- **与 Markdown 编辑器的适配度**：低——编辑器对方言正确性要求高，合规性缺口不可接受。
- **对原生 macOS Swift 开发的适用性**：不建议用于编辑器；其模块化规则架构可作纯 Swift 解析器设计参考。
- **代表使用者**：Publish 静态站点生成器。

---

## 五、原生文本引擎与编辑器组件

### TextKit 2 / NSTextView
- **定位与能力**：Apple 新一代文本引擎（macOS 12 引入，Ventura 起系统文本控件默认启用）：NSTextLayoutManager / NSTextContentStorage / NSTextLayoutFragment 的视口化布局架构，理论上支持自定义布局片段（做行内 widget、隐藏语法标记的正路），Writing Tools 的改写动画也要求 TextKit 2。
- **成熟度**：架构好评、实现差评。Marcin Krzyżanowski 2025 年 8 月《TextKit 2 – the promised land》总结四年实战：滚动不稳定、文档总高度靠估算导致跳动、访问 `.layoutManager` 会静默降级回 TextKit 1（macOS 26 仍有此坑）、NSTextList 自 macOS 14 起损坏、打印支持 macOS 15 才有、大量 Feedback 无回应；CotEditor 至今坚守 TextKit 1。社区名言：「TextKit 1 是着火的房子，TextKit 2 是岩浆池」。
- **与 Markdown 编辑器的适配度**：仍是原生混合渲染唯一的官方地基——语法隐藏（自定义 NSTextContentStorage 属性变换）、行内图片/表格（自定义 layout fragment）都能做，但每一步都要绕坑。
- **对原生 macOS Swift 开发的适用性**：必修课。务实策略：NSTextView(TextKit 2) 起步 + 严禁触碰 TextKit 1 API 防降级 + 参考 STTextView/swift-markdown-engine 的已趟坑实现。
- **代表使用者**：系统 TextEdit/备忘录、swift-markdown-engine、STTextView。

### STTextView
- **定位与能力**：Krzyżanowski 开发的 TextKit 2 文本视图组件（约 1.57k star）：NSTextView/UITextView 替代品，自带行号、标尺、插件体系（可接 Neon 高亮），修复/绕过了一长串上游 TextKit 2 bug（README 维护着 FB 编号清单）。
- **成熟度**：活跃（2026-07 提交）；注意许可已改为 GPLv3 + 商业双授权——对我们「开源免费」的产品，若整体用 GPL 兼容协议（如 GPLv3）可免费使用，若想用 MIT/Apache 发布则需绕开或购买商业授权。
- **与 Markdown 编辑器的适配度**：作为「源码模式」编辑视图几乎开箱即用；混合渲染仍需自己在其上做属性/片段定制。
- **对原生 macOS Swift 开发的适用性**：高（许可是唯一考量点）；即使不用，其源码是 TextKit 2 避坑百科。
- **代表使用者**：作者的商业与开源工具、多个 macOS 开发者工具。

### Runestone
- **定位与能力**：Simon B. Støvring 的 iOS 代码编辑组件（MIT，约 3.2k star）：绕开系统文本视图的自绘布局（实现 UITextInput），tree-sitter 增量解析做高亮，行号、不可见字符、超大文件性能好。
- **成熟度**：维护放缓（最后提交 2026-03）；同名 App 是其展示品。
- **与 Markdown 编辑器的适配度**：定位是「代码编辑」，做 Markdown 源码模式可用（有 tree-sitter-markdown 文法），无混合渲染。
- **对原生 macOS Swift 开发的适用性**：低——UIKit 专用，macOS 需 Catalyst，与我们 AppKit/SwiftUI 原生方向不符；其「自绘布局绕开 TextKit」的架构决策是重要参考数据点（又一个团队放弃系统文本栈）。
- **代表使用者**：Runestone app、多个 iOS 代码/笔记应用。

### Highlightr
- **定位与能力**：通过 JavaScriptCore 运行 highlight.js 并输出 NSAttributedString 的 Swift 高亮库（MIT，约 1.87k star）：约 185 种语言、89 套主题即取即用。
- **成熟度**：低频维护（2026-02 有提交），能用但架构老（整段重高亮、非增量，JSCore 往返有开销）。
- **与 Markdown 编辑器的适配度**：适合给编辑器内代码块做高亮（Markdown 正文高亮应由解析器驱动，不该用它）；大文档多代码块时需做节流/缓存。
- **对原生 macOS Swift 开发的适用性**：快速出效果的务实选择；对性能敏感可换 tree-sitter（Neon）或 HighlighterSwift（同类封装，swift-markdown-engine 所用）。
- **代表使用者**：大量 iOS/macOS 笔记与开发工具类 App。

### swift-markdown-ui
- **定位与能力**：Guille Gonzalez 的 SwiftUI Markdown 渲染库（MIT，约 3.9k star）：GFM（表格、任务列表、删除线）只读渲染，主题化 API 精致，是 SwiftUI 里显示 Markdown 的事实标准。
- **成熟度**：已进入维护模式（README 明示），作者 2025 年 12 月开启继任项目 Textual；最后实质更新 2025-12。
- **与 Markdown 编辑器的适配度**：只管「显示」不管「编辑」——适合做预览面板、AI 回复渲染；长文档性能与文本选择能力有限（SwiftUI 布局所限）。
- **对原生 macOS Swift 开发的适用性**：分屏预览的原生候选（相对 WKWebView 的优点：无进程开销、主题与系统观感一致；缺点：无 Mermaid/KaTeX 等 JS 生态）。
- **代表使用者**：大量 SwiftUI 应用（尤其 AI 聊天类）的消息渲染。

### Textual (gonzalezreal)【新发现】
- **定位与能力**：swift-markdown-ui 作者的继任库（MIT，约 800 star，2025-12 创建）：面向 SwiftUI 的富属性文本渲染与定制，吸收前作经验重新设计。
- **成熟度**：早期但活跃（2026-06 有提交）；API 未稳定。
- **与 Markdown 编辑器的适配度**：同前作，渲染侧组件；值得跟踪其对选择、长文性能的改进。
- **对原生 macOS Swift 开发的适用性**：预览面板候选之一，暂不建议押注（太新）。
- **代表使用者**：暂无头部案例。

### SwiftUI TextEditor 的局限（与 macOS 26 后的变化）
- **定位与能力**：SwiftUI 官方多行文本输入组件。macOS 26 / iOS 26（WWDC25 session 280）前只支持纯 String——无属性样式、无行内渲染、定制点极少、大文本性能差，做 Markdown 编辑器基本不可用；macOS 26 起支持绑定 AttributedString + AttributedTextSelection，内建加粗/斜体/字号/颜色/段落样式与格式快捷键，可用 transformAttributes(in:) 做自定义格式控件。
- **成熟度**：新 API 刚落地一年内。已知限制：AttributedString 任何修改都使全部索引失效（增量高亮成本高）、无自定义行内附件/布局（图片、表格、语法隐藏仍做不到）、持久化需自行编解码、仅 macOS 26+ 可用（放弃老系统用户）。RichTextKit 作者已表态其库将因此淡出。
- **与 Markdown 编辑器的适配度**：2026 年起可以做「带实时样式的轻量 Markdown 编辑」（标题变大、加粗变粗），但 Typora 级语法隐藏与行内 widget 仍超出其能力。
- **对原生 macOS Swift 开发的适用性**：适合 MVP 或「简洁至上」的产品定位；深度编辑体验仍需 NSTextView/TextKit 2。
- **代表使用者**：Apple 官方示例、新一代 SwiftUI 笔记类小应用。

### WKWebView 预览方案
- **定位与能力**：系统 WebKit 视图做 HTML 预览/导出的通用方案：loadFileURL/自定义 URLScheme 加载本地图片，WKScriptMessageHandler 双向桥接，JS 侧跑 markdown-it/KaTeX/Mermaid/highlight.js，滚动同步靠行号锚点映射，PDF 导出用 createPDF/printOperation。
- **成熟度**：极成熟的模式；先例充分：MacDown（hoedown + WebView 分屏，GPL 开源）、Marked 2、VS Code 预览（markdown-it + webview）。
- **与 Markdown 编辑器的适配度**：分屏预览与导出（HTML/PDF/打印）的最省力路径，且是 Mermaid/KaTeX 在原生应用中唯一现实的运行环境。
- **对原生 macOS Swift 开发的适用性**：强烈建议采用但限定用途：预览/导出/图表渲染，编辑区保持原生；代价是每个 WebView 进程约数十 MB 内存与首次加载延迟，沙盒下本地资源访问需正确配 entitlement。
- **代表使用者**：MacDown、Marked 2、iA Writer（预览）、几乎所有原生分屏类 Markdown 应用。

---

## 六、渲染增强组件

### KaTeX vs MathJax
- **定位与能力**：两大 LaTeX 数学 web 渲染引擎。KaTeX（MIT，约 2.02 万 star）：同步渲染、速度快、包小，覆盖常用 LaTeX 子集；MathJax（Apache-2.0，约 1.09 万 star）：覆盖面最全（TeX/MathML/AsciiMath 输入，SVG/CHTML 输出）、无障碍最佳，v4.0（2025-08）带来换行支持、11 套新字体、语音生成移入 worker，v4.1（2025-12）继续跟进，性能差距已明显缩小。
- **成熟度**：双方 2026 年均活跃维护。
- **与 Markdown 编辑器的适配度**：行业分布：Mark Text 用 KaTeX；Typora（1.13 起 v4）与 Obsidian 用 MathJax。编辑场景重打字反馈，KaTeX 的同步快渲染更合适；导出/学术场景 MathJax 更稳。
- **对原生 macOS Swift 开发的适用性**：两者都需 JS 环境→放 WKWebView 预览端；若想在原生编辑区行内渲染公式，可用 SwiftMath（iosMath 血统的原生 CoreText 排版库，swift-markdown-engine 所用），覆盖常用子集。
- **代表使用者**：KaTeX：Khan Academy、Mark Text；MathJax：arXiv 生态、Typora、Obsidian。

### Mermaid
- **定位与能力**：文本转图表 JS 库（MIT，约 8.93 万 star）：流程图、时序图、甘特图、类图、思维导图等 20+ 图型，已成 Markdown 图表事实标准（GitHub/GitLab 原生支持代码块渲染）。
- **成熟度**：极活跃（2026-07 提交），v11 系列。
- **与 Markdown 编辑器的适配度**：用户强需求项；只能在浏览器环境运行。
- **对原生 macOS Swift 开发的适用性**：经 WKWebView 渲染（可离屏渲染成 SVG/PNG 回填原生视图，或直接在预览 WebView 中渲染）；无原生替代品，安排离线打包（约数 MB bundle）。
- **代表使用者**：GitHub、GitLab、Obsidian、Typora、Notion。

### highlight.js vs Shiki
- **定位与能力**：代码高亮双雄。highlight.js（BSD-3，约 2.5 万 star）：正则启发式、约 190+ 语言、CSS 主题、轻快，精度一般；Shiki（MIT，约 1.36 万 star）：用 VS Code 的 TextMate 文法 + Oniguruma（WASM）做词法分析，精度与 VS Code 一致、可直接用 VS Code 主题，代价是体积与初始化开销（v3 提供纯 JS 正则引擎选项减负）。
- **成熟度**：双方 2026 年均活跃。
- **与 Markdown 编辑器的适配度**：预览端静态高亮 Shiki 观感明显更好（现代文档工具已集体迁移）；编辑区实时高亮要求增量、低延迟，两者都不理想。
- **对原生 macOS Swift 开发的适用性**：预览 WebView 用 Shiki（美观）；原生编辑区代码块用 Highlightr（hljs 封装）起步、tree-sitter/Neon 进阶；Shiki 无原生封装（WASM 依赖）。
- **代表使用者**：hljs：无数网站与 Highlightr；Shiki：VitePress、Astro、Nuxt Content。

### tree-sitter / SwiftTreeSitter【新发现】
- **定位与能力**：增量解析框架（MIT，约 2.63 万 star）：错误容忍、编辑后毫秒级重解析，配 tree-sitter-markdown 文法（块/行内双文法）可做编辑器级 Markdown 语法树；SwiftTreeSitter（ChimeHQ）提供 Swift 绑定与高亮查询支持。
- **成熟度**：tree-sitter 核心极活跃；markdown 文法维护尚可但以「怪癖多」著称（Markdown 天生难以形式化）。
- **与 Markdown 编辑器的适配度**：编辑区实时高亮的性能正解（增量、局部重解析），与 swift-markdown（批处理式全量解析）互补：前者管高亮、后者管语义/导出是常见组合。
- **对原生 macOS Swift 开发的适用性**：好——C 库 + 官方 Swift 绑定；集成成本主要在文法编译与查询编写。
- **代表使用者**：Neovim、Zed、GitHub 代码导航、Runestone、CodeEdit。

### Neon (ChimeHQ)【新发现】
- **定位与能力**：Swift 语法高亮胶水库（BSD-3，390 star）：把 tree-sitter（经 SwiftTreeSitter）解析结果映射为文本属性，提供 TextViewHighlighter 直接对接 NSTextView/UITextView/STTextView，处理增量失效与异步高亮。
- **成熟度**：小而专，维护中（2026-04 提交）；ChimeHQ 出品（Chime 编辑器团队，TextKit 生态最重要的第三方之一）。
- **与 Markdown 编辑器的适配度**：解决「解析结果→TextKit 属性」这段最脏的管线，正是自研原生编辑器缺的中间件。
- **对原生 macOS Swift 开发的适用性**：高；即使不直接依赖，其失效区间计算逻辑值得抄作业。
- **代表使用者**：Chime、若干 STTextView 用户。

### CodeEditSourceEditor / CodeEditTextView【新发现】
- **定位与能力**：CodeEdit 项目（「Mac 原生开源 IDE」，主 App 仓库约 2 万+ star）拆出的编辑器组件（MIT，CodeEditSourceEditor 约 706 star）：tree-sitter 高亮 + 自研 CodeEditTextView 文本布局（因 TextKit 2 不可控而部分自绘），AppKit、macOS 专用。
- **成熟度**：活跃（2026-04 提交），API 演进中，随 CodeEdit 主项目节奏波动。
- **与 Markdown 编辑器的适配度**：面向代码编辑；做 Markdown 源码模式可行，混合渲染需大改。
- **对原生 macOS Swift 开发的适用性**：中——MIT、纯 AppKit、macOS-first 是加分项；「社区自研文本布局绕 TextKit 2」再添一例，其取舍记录值得研读。
- **代表使用者**：CodeEdit。

### SwiftDown【新发现】
- **定位与能力**：SwiftUI Markdown 编辑器组件（MIT，571 star）：主题化源码编辑 + 高亮，底层包 NSTextView/UITextView 与 cmark 系解析。
- **成熟度**：已归档（最后提交 2024-02）——SwiftUI 包装第三方编辑组件的又一个弃坑案例。
- **与 Markdown 编辑器的适配度**：仅够轻量场景；无混合渲染。
- **对原生 macOS Swift 开发的适用性**：不建议依赖；其「SwiftUI 壳 + AppKit 文本视图」桥接代码可参考。
- **代表使用者**：若干独立 App 的早期版本。

### swift-markdown-engine (nodes-app)【新发现，重点】
- **定位与能力**：2026 年 4 月出现的原生 AppKit Markdown 编辑引擎（Apache-2.0，创建三个月即约 830 star）：TextKit 2 布局 + 增量解析 + Typora/Bear 式行内混合渲染（标记隐藏、光标处还原），支持 CommonMark + 表格 + 任务列表 + `==高亮==`/删除线 + Obsidian 式 wiki 链接 + LaTeX（SwiftMath 原生渲染）+ 行内图片；代码块高亮经 HighlighterSwift；提供 NativeTextViewWrapper 桥接 SwiftUI；扩展走 MarkdownExtension 协议（解析器统一管几何、标记隐藏与重排版）；模块拆分为核心/代码块/LaTeX 三个产品以控制依赖。要求 macOS 14+（Writing Tools 集成需 15.1+）。
- **成熟度**：pre-1.0（官方建议锁版本），单一主导团队，但增长与活跃度（2026-07 持续提交）都是本类别原生方案中最好的。
- **与 Markdown 编辑器的适配度**：这就是我们要做的东西的引擎层开源实现——目前生态里唯一开源的「原生 TextKit 2 混合渲染 Markdown 引擎」。
- **对原生 macOS Swift 开发的适用性**：极高：Apache-2.0 允许我们直接以其为基础或深度借鉴；风险是项目年轻、API 不稳、单点维护。
- **代表使用者**：nodes 团队自家 App；社区采用刚起步。

---

## 七、架构层取舍

### 原生 vs Electron vs Tauri 取舍
- **定位与能力**：三条壳路线。Electron：捆绑 Chromium+Node，渲染一致、生态最大；Tauri：Rust 核 + 系统 WebView（macOS 上即 WKWebView）；原生 Swift：AppKit/SwiftUI 全栈。
- **关键数据（2025-26 公开基准）**：安装包——Electron 普遍 80–150MB vs Tauri <10MB（实测案例 Authme：85MB vs 2.5MB）vs 原生通常 10–30MB；空闲内存——Electron 常见 200–300MB vs Tauri 30–40MB（但有基准质疑：WebKit 某些负载下反而比 Chromium 多用 90MB+，Windows 上 WebView2 与 Electron 无异）；启动——Electron 1–2s vs Tauri <0.5s vs 原生近即时。Tauri 在 macOS 随系统获得 Safari 安全更新，但也继承 WebKit 特性滞后。
- **与 Markdown 编辑器的适配度**：现存头部 Markdown 编辑器几乎全是 Electron（Typora/Obsidian/Mark Text/Zettlr），这正是「原生、轻、好看」定位的市场空档；用户论坛对 Electron 手感/内存的抱怨常年存在。
- **对原生 macOS Swift 开发的适用性**：结论明确——编辑器主体走原生（差异化核心），WKWebView 仅作预览/导出/图表子系统；不建议 Tauri（编辑体验仍是 web 的，却失去 Electron 的生态一致性）。
- **代表使用者**：Electron：VS Code/Obsidian/Typora；Tauri：较新工具类应用；原生：Bear、iA Writer、Ulysses、CotEditor。

---

## 八、面向原生 macOS 的完整技术方案组合（决策核心）

### 方案 A：全原生混合渲染（TextKit 2 自绘 + swift-markdown 解析 + WKWebView 导出预览）
- **组成**：AppKit NSTextView(TextKit 2) 编辑区（SwiftUI 壳经 NSViewRepresentable 桥接）＋ swift-markdown / swift-cmark(gfm) 做语法树与语义层 ＋ tree-sitter/Neon 或解析驱动的属性映射做实时高亮与标记隐藏 ＋ 代码块 Highlightr/HighlighterSwift ＋ 数学 SwiftMath（行内）＋ WKWebView 子系统负责 HTML/PDF 导出、Mermaid、KaTeX/MathJax 复杂公式。
- **先例**：Bear/Panda（自研 C++ AST + 原生视图，55ms 打开《白鲸记》证明性能上限）、swift-markdown-engine（同架构的开源实现，可直接作为起点或上游）、soffes/MarkdownKit（早年 TextKit+CommonMark 的雏形）。
- **利**：手感、性能、体积、能耗全面最优；与系统深度集成（Writing Tools、拼写、听写、系统服务、无障碍）；这是与 Electron 竞品拉开差距的唯一路线，也最契合「简洁好看 + 原生」的定位；AI 侧可无缝接 Apple 的 Foundation Models/Writing Tools 与本地 MLX 模型。
- **弊/工作量**：最大。TextKit 2 的坑（滚动估算、降级陷阱、行内附件）需专人趟；语法隐藏 + 光标还原的状态机是核心难点；行内表格/图片渲染工作量大。从零做编辑器核心估计 6–12 人月；基于 swift-markdown-engine（Apache-2.0）起步可砍掉一半以上，但要接受 pre-1.0 API 波动，建议 fork 锁版本并向上游回馈。
- **判断**：目标产品的正解，风险集中在编辑器核心一个点上。

### 方案 B：原生壳 + WKWebView 内嵌 CodeMirror 6（Obsidian 式 Live Preview）
- **组成**：SwiftUI/AppKit 负责窗口、三栏布局、文件树、设置、快捷键；编辑区一个 WKWebView 运行 CM6 + lezer-markdown + Obsidian 式 live-preview 扩展（可基于 atomic-editor / codemirror-live-markdown 二次开发）＋ KaTeX + Mermaid + Shiki 全在 JS 侧；Swift↔JS 经 WKScriptMessageHandler 传输文档与命令。
- **先例**：Obsidian 证明了 CM6 Live Preview 的体验上限（但它连壳都是 Electron）；「原生壳 + Web 编辑内核」在商业产品中有 Craft（自研 web 内核）等混合先例；开源界此组合先例不多。
- **利**：混合渲染这一最难问题直接用成熟方案，2–4 人月可出高完成度 MVP；数学/图表/高亮生态零成本；未来跨平台（iOS/Windows）留有余地；编辑器行为可与 Obsidian 插件生态对齐。
- **弊/工作量**：「原生感」打折扣：字体渲染、惯性滚动、IME 细节、右键菜单与系统服务都要桥接或妥协；每文档一个 WebView 的内存开销（数十 MB 起）；双语言栈长期维护成本；Writing Tools/系统拼写无法直接作用于 web 编辑区——与我们的差异化卖点相冲突。
- **判断**：作为 Plan B 或快速验证市场的一代目架构合理；若最终目标是「原生手感」，此路线迟早要重写编辑区。

### 方案 C：SwiftUI 快速路线（TextEditor/STTextView 源码编辑 + 原生分屏预览）
- **组成**：SwiftUI NavigationSplitView 三栏 ＋ 编辑区二选一：macOS 26 的 AttributedString TextEditor（轻样式实时反馈）或 STTextView/CodeEditSourceEditor（源码模式 + 行号）＋ 预览区 swift-markdown-ui/Textual（纯原生）或 WKWebView（要 Mermaid/KaTeX 时）＋ swift-markdown 解析。
- **先例**：SwiftDown 及大量独立开发者 MVP；MacDown（源码 + WebView 分屏的经典形态，只是它用 AppKit+hoedown）。
- **利**：工作量最小（1–3 人月可上架），代码量少、纯 Swift 单栈，界面天然现代；对「简洁好看」的最小可爱产品足够。
- **弊/工作量**：天花板明确：做不到 Typora 式行内混合渲染（当前用户对 Markdown 编辑器的主流期待）；TextEditor 新 API 仅 macOS 26+ 且索引失效机制让增量高亮低效；分屏模式在竞品中已属「上一代交互」；后期升级混合渲染等于重做编辑区。
- **判断**：适合当作方案 A 的第一里程碑（先发布分屏版收集用户，同期开发混合渲染内核），不适合作为终态架构。

**推荐**：以方案 A 为终态目标、方案 C 为首发形态的渐进路线：M1 用 STTextView（或自建薄封装 NSTextView）+ swift-markdown + WKWebView 分屏出 MVP；M2 引入/借鉴 swift-markdown-engine 落地行内混合渲染；全程 WKWebView 只做预览导出与 Mermaid/公式，AI 层（对话、改写、续写）独立于编辑内核、通过语法树 API 操作文档，确保未来可替换模型（云端 API 与本地 MLX 并行）。

---

## 本类别小结

**共性与趋势**
- 混合渲染（Typora 式行内所见即所得）已成为 Markdown 编辑器的体验基准线，纯分屏被视为上一代交互；实现它的两条正路是 CM6 Decoration（web）与 TextKit 2 自定义布局（原生），后者 2026 年才随 swift-markdown-engine 出现开源先例。
- 解析层高度收敛于 cmark-gfm 血统（GitHub、Apple、comrak 皆是），方言兼容有事实标准可依；「编辑高亮用增量解析（tree-sitter/Lezer）、语义与导出用全量 AST（swift-markdown/remark）」的双解析器架构是普遍做法。
- 原生文本栈的现实：TextKit 2 架构对、实现坑多，Bear、Runestone、CodeEdit 三个团队各自给出了「自研内核/自绘布局」的回答；但 2024–2026 的工具链（STTextView、Neon、swift-markdown-engine）已把原生路线的门槛降到独立团队可及。
- Web 侧巨头组件（CM6/ProseMirror）健康但托管去中心化（迁离 GitHub）；渲染增强件（Mermaid/KaTeX/Shiki）全部依赖 JS 环境，任何原生方案都绕不开一个 WKWebView 子系统。
- 头部产品已开始接 AI 协议化（Bear 2.8 的 MCP server 与 Claude Connector），编辑器与 AI 的接口正在从「内嵌聊天框」走向「标准协议 + 语法树级操作」。

**对我们产品的启示**
- 差异化空间真实存在：头部 Markdown 编辑器几乎全是 Electron，「原生 + 轻 + 好看 + 开源」四项同时满足的产品目前是空白。
- 技术组合直接可抄的最短路径：NSTextView(TextKit 2) + swift-markdown(swift-cmark) + Neon/tree-sitter 高亮 + WKWebView 预览导出（内置 KaTeX/Mermaid/Shiki）+ SwiftMath 行内公式；起点认真评估 fork swift-markdown-engine（Apache-2.0，架构与我们目标完全一致）。
- 许可雷区提前排：STTextView 已改 GPLv3/商业双授权，若我们选 MIT/Apache 发布需注意；Down/Ink/SwiftDown 均已停更，不要引入。
- TextKit 2 防坑清单要进工程规范：禁触 .layoutManager 防降级、视口高度估算引起的滚动跳动要有对策、打印/PDF 走 WKWebView 而非 TextKit。
- AI 能力设计为「语法树上的操作」而非「文本替换」：解析层选 swift-markdown 的一个隐藏红利是 SourceRange 精确、AST 可编程改写，天然适合让 AI 做结构化编辑（改写某节、生成表格、插入 frontmatter），并可对齐 MCP 暴露文档操作接口。
