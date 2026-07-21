# IDE / 终端 / 插件生态中的 Markdown 工作流

> 类别总体观察：开发者并不缺「Markdown 编辑器」——他们在 IDE 和终端里就把 Markdown 写了，这个类别展示的是"作为基础设施的 Markdown"：编辑器内核提供语法高亮与预览，扩展补齐快捷键/导出/图表，LSP（Marksman）提供跳转与补全，格式化器（Prettier/mdformat）进 CI，Pandoc 负责格式出口。近两年的两大趋势值得注意：一是「行内渲染」取代「分屏预览」成为新宠（render-markdown.nvim、markview.nvim、JetBrains 的 focus 模式），证明程序员也想要"接近所见即所得但不失控于源码"的体验；二是 AI 全面下沉为编辑器基础能力（Copilot、Zed Agent/Zeta、JetBrains AI Assistant），Markdown 写作是其最自然的落地场景之一。VS Code 事实上定义了开发者 Markdown 编辑的功能基线（粘贴 URL 成链接、拖拽/粘贴图片自动落盘、链接校验、重命名同步改链接），任何面向开发者的新编辑器都会被拿来与这条基线比较。终端侧（Glow/mdcat/Frogmouth）则提醒我们：只读的「阅读体验」本身就是一个被低估的场景。

### VS Code（内置 Markdown 支持）

- **基本信息**：Microsoft｜macOS / Windows / Linux｜免费（官方二进制免费闭源，源码 Code - OSS 为 MIT 协议）｜官网 code.visualstudio.com｜github.com/microsoft/vscode（star 约 16-17 万）｜维护状态：每月一个大版本，非常活跃
- **编辑模式**：纯源码 + 分屏预览（`Cmd+K V` 侧边预览、`Shift+Cmd+V` 切换预览），双向同步滚动并在预览中标示编辑器当前行；无所见即所得
- **核心功能**（这是开发者 Markdown 编辑的"功能基线"，值得逐条对标）：
  - CommonMark 为基础，预览内置 Mermaid 渲染与 KaTeX 数学公式（2024 年后陆续内置）
  - **粘贴 URL 自动成链接**：选中文字后粘贴 URL 直接变成 `[文字](url)`（`markdown.editor.pasteUrlAsFormattedLink`）
  - **拖拽 / 粘贴图片自动处理**：从 Explorer/Finder 拖入文件自动插入相对链接；粘贴剪贴板图片自动保存到 `markdown.copyFiles.destination` 指定目录并插入引用
  - **链接智能化**：输入 `](` 或 `[[` 时自动补全工作区文件路径和标题锚点；`markdown.validate.enabled` 开启后校验死链、失效锚点并给出诊断；**文件移动/重命名自动更新所有引用链接**；F2 重命名标题会同步更新全部引用；Find All References 可查某文件/标题被谁引用
  - 大纲视图（Outline）、`Shift+Cmd+O` 文内标题跳转、`Cmd+T` 全工作区标题搜索、Smart Select 按块级结构扩展选区
  - 导出：无内置导出（依赖扩展）；插件系统即 VS Code 扩展市场，Markdown 相关扩展数千个
- **UI 设计**：经典三栏 IDE 布局（文件树 + 编辑器 + 可选预览）；预览样式偏 GitHub 风；主题系统全局共享；无专注/打字机模式。值得学习的细节：预览与编辑器滚动联动时的"当前行指示条"
- **技术栈**：Electron；编辑器内核 Monaco；Markdown 解析 markdown-it
- **AI 能力**：GitHub Copilot 深度集成（2024 年 12 月起有免费档：每月约 2000 次补全 + 50 次对话），在 Markdown 中可续写文本、Chat 可改写/总结/生成文档，Copilot LLM API 还开放给扩展调用
- **可借鉴点**：
  1. **把"链接与图片"做成零摩擦**：粘贴 URL 成链接、粘贴/拖拽图片自动落盘并插入相对路径，这套交互是开发者最高频的痛点解法，原生 macOS 应用完全可以做得更顺（NSPasteboard + 拖拽 API）
  2. **把工作区当"知识库"对待**：链接校验、重命名自动改引用、跨文件标题搜索，这是"编辑器"与"文件夹里的一堆 .md"之间的关键差距
  3. 大纲、Smart Select 等结构化编辑能力全部基于语法树，值得用同样思路（swift-markdown/tree-sitter）实现
- **不足**：论坛常见抱怨：Electron 内存占用高、启动慢，"用 IDE 写作太重"；预览与编辑分屏割裂，写作沉浸感差；默认预览样式简陋；导出必须装扩展

### Markdown All in One（VS Code 扩展）

- **基本信息**：Yu Zhang（个人开源）｜VS Code 扩展｜免费，MIT｜github.com/yzhang-gh/vscode-markdown（star 约 3.3k，市场下载量约 1400 万）｜最新版 v3.6.3（2025-03-09），此后无新版本，更新节奏明显放缓但仍在处理 issue
- **编辑模式**：增强源码编辑（配合 VS Code 内置预览）
- **核心功能**：
  - **写作快捷键**：`Cmd+B` 加粗、`Cmd+I` 斜体、`Alt+S` 删除线、`Alt+C` 勾选任务项、`Ctrl+Shift+]/[` 升降标题级别——把"IDE 快捷键肌肉记忆"映射到 Markdown 语义
  - **列表智能续行**：回车自动接续列表项、Tab/Backspace 调整缩进层级、自动修复有序列表编号
  - TOC 目录生成与保存时自动更新（兼容 GitHub/GitLab slug 规则）、章节自动编号
  - GFM 表格格式化、数学公式（KaTeX）、文件/图片路径补全、导出 HTML
- **UI 设计**：无独立 UI，纯编辑行为增强
- **技术栈**：TypeScript（VS Code 扩展 API）
- **AI 能力**：无
- **可借鉴点**：
  1. **快捷键语义化清单可以直接抄**：`Cmd+B`/`Cmd+I`/升降标题/勾选任务，是开发者对 Markdown 编辑器的隐性预期
  2. **列表续行与编号自动修复**是最能体现"编辑器懂 Markdown"的微交互，成本低、感知强
  3. "保存时自动更新 TOC"这种把维护性工作自动化的思路
- **不足**：更新停滞一年以上引发维护性担忧；大文档下部分功能（如自动补全、TOC 更新）曾有性能问题（历史 issue #360 等）；功能与 VS Code 内置能力日益重叠

### Markdown Preview Enhanced（VS Code / Atom 扩展）

- **基本信息**：shd101wyy（Yiyi Wang，个人开源）｜VS Code 扩展｜免费，NCSA 协议｜github.com/shd101wyy/vscode-markdown-preview-enhanced（star 约 2k，主库 markdown-preview-enhanced 另有约 4k+）｜最新版 v0.8.30（2026-06-08），维护中但开放 issue 约 1.4k 个
- **编辑模式**：源码 + 增强分屏预览（自动同步滚动）
- **核心功能**（本类别导出/图表能力天花板）：
  - 图表：**Mermaid、PlantUML、WebSequenceDiagrams、Vega/Vega-Lite、WaveDrom** 等多种图表语法直接渲染
  - 数学：KaTeX / MathJax 双引擎
  - **导出**：PDF（经 Chrome/Puppeteer 或 Prince）、HTML、PNG/JPEG，且可调用 **Pandoc** 导出更多格式；支持 front-matter 配置导出参数
  - **Code Chunk**：在 Markdown 里执行代码块并嵌入运行结果（类文学编程/Notebook）
  - Presentation 模式：用 Reveal.js 把 Markdown 写成幻灯片
  - 文件引入（`@import` 拼接子文档）、TOC、脚注、图片上传集成；强调所有内容本地处理、不上传数据
- **UI 设计**：预览主题可切换（含 GitHub 风格等多套 CSS），支持自定义 CSS
- **技术栈**：TypeScript；解析基于 markdown-it 系（crossnote 内核）；PDF 导出依赖 Puppeteer 驱动无头 Chrome
- **AI 能力**：无
- **可借鉴点**：
  1. **"一站式图表渲染"是开发者刚需**：Mermaid + PlantUML + 数学公式一次配齐，这是我们接入 WKWebView/JavaScriptCore 渲染管线时的功能清单
  2. Code Chunk（可执行代码块）是差异化方向，与 AI 结合想象空间大
  3. 反面教材同样有价值：**导出链路依赖无头 Chrome 导致脆弱又缓慢**——原生应用用系统 WebKit/PDFKit 做导出是明确的体验优势点
- **不足**：Puppeteer/Chromium 检测失败导致 PDF 导出报错是最高频抱怨（跨 Windows/Linux 大量 issue）；长文档 + 大量 KaTeX/图表时导出可慢至数分钟；PDF 缺书签/目录（outline）；issue 积压严重、单人维护

### Front Matter CMS（VS Code 扩展）

- **基本信息**：Elio Struyf（个人开源 + 赞助模式：GitHub Sponsors / Open Collective）｜VS Code 扩展｜免费，MIT｜官网 frontmatter.codes｜github.com/estruyf/vscode-front-matter（star 约 2.5k）｜最新版 v10.11.0（2026-07-02），活跃，但作者明言大功能开发依赖赞助
- **编辑模式**：源码编辑 + **仪表盘式 CMS 面板**（webview），不是传统预览
- **核心功能**：
  - 把 VS Code 变成静态站点（Hugo / Jekyll / Hexo / Next.js / Gatsby / Astro 等）的 **Headless CMS**：内容列表的搜索/筛选/排序、按模板新建文章
  - **Front matter 元数据表单化编辑**：日期、标签、分类、草稿状态用 UI 控件而非手写 YAML
  - SEO 检查（标题/描述/关键词长度与密度）、媒体仪表盘（图片元数据管理）、分类法（taxonomy）管理、i18n 多语言内容、站点内预览、数据文件与 snippet 面板
- **UI 设计**：在 IDE 内嵌完整 Web 仪表盘（卡片式内容列表 + 右侧元数据面板），是"编辑器长出 CMS"的代表作
- **技术栈**：TypeScript + React（webview）
- **AI 能力**：有。曾推出赞助者专属 "Front Matter AI"（后移除），现改为调用 **VS Code 的 GitHub Copilot LLM API**（默认 gpt-4o-mini）生成标题建议、描述建议、标签/分类建议，并开放 @frontmatter/extensibility 接自有 AI API
- **可借鉴点**：
  1. **Front matter 表单化**：博客作者是 Markdown 编辑器的重要人群，把 YAML front matter 渲染成原生表单（日期选择器、标签输入框）是低成本高感知的功能
  2. AI 用在"元数据生成"（标题/摘要/标签）比通用聊天更具体、更好落地
  3. 复用宿主的 AI 额度（Copilot API）而非自建 API-key 门槛，这个思路对应到 macOS 就是接 Apple Intelligence / 本地模型
- **不足**：配置复杂（frontmatter.json 学习成本）、与特定 SSG 目录结构耦合；单人维护、大功能推进慢；webview 面板与 VS Code 原生 UI 风格割裂

### markdownlint（VS Code 扩展 + CLI）【补充发现】

- **基本信息**：David Anson（个人开源）｜VS Code 扩展 / Node CLI（markdownlint-cli2）｜免费，MIT｜github.com/DavidAnson/vscode-markdownlint（star 约 1.3k；核心库 markdownlint 另有约 5k+）｜持续维护（99 个 tag，2026 年仍有发布）
- **核心功能**：约 60 条 lint 规则（MD001-MD060：标题层级、列表缩进、空行、行长、裸链接等），输入时实时画波浪线；其中约 30 条可自动修复，`Format Document` / `fixAll` 一键修完；CLI 版进 CI/pre-commit；支持自定义规则与 `.markdownlint.json` 配置
- **技术栈**：JavaScript
- **AI 能力**：无
- **可借鉴点**：
  1. **"Markdown 也需要 linter"是开发者独有的心智**：新编辑器可内置轻量 lint（如标题跳级、裸 URL 提醒）+ 一键修复，替代装插件
  2. 规则全部可配置/可关闭的分级设计，避免"编辑器管太宽"的反感
- **不足**：默认规则偏严格，新手常被大量警告淹没（Reddit 常见吐槽"第一件事是关掉一半规则"）；规则与 Prettier 格式化偶有冲突

### Foam（VS Code 扩展）【补充发现】

- **基本信息**：Foam 社区（130+ 贡献者）｜VS Code 扩展｜免费，MIT｜foambubble.github.io/foam｜github.com/foambubble/foam（star 约 17.3k）｜最新版 vscode@0.40.4（2026-05-14），活跃
- **编辑模式**：源码编辑 + 知识图谱/面板增强（配合 VS Code 内置预览）
- **核心功能**：`[[wikilink]]` 双向链接 + 自动补全、**交互式知识图谱可视化**、反向链接面板（带上下文预览）、Daily Notes、模板、标签浏览、孤儿/占位笔记检测、笔记嵌入（transclusion）、重命名时自动同步链接、生成 GitHub 兼容的 markdown 引用以保证仓库里可读
- **技术栈**：TypeScript
- **AI 能力**：无官方 AI（可与 Copilot 共存）
- **可借鉴点**：
  1. 证明了"**Obsidian 式双链笔记**可以纯以开放 .md 文件 + Git 工作流实现"，这正是开发者用户想要的：无私有库格式、可进版本控制
  2. 反向链接面板 + 图谱是笔记场景的期望配置；wiki 链接落盘时转标准 markdown 链接的兼容策略值得抄
- **不足**：依赖 VS Code 生态，体验碎片化（图谱、预览、编辑分属不同面板）；性能在大库下一般；相较 Obsidian 功能仍显简陋

### JetBrains 系列（IntelliJ IDEA / WebStorm / PyCharm 等内置 Markdown 插件）

- **基本信息**：JetBrains｜macOS / Windows / Linux｜Markdown 插件免费捆绑于所有 IDE（源码属 intellij-community，Apache-2.0）；IDE 本身：Community 版免费，Ultimate 个人订阅约 US$169/首年（逐年递减；WebStorm/Rider 2024 起非商业使用免费）｜plugins.jetbrains.com/plugin/7793-markdown｜随 IDE 版本节奏持续更新（每年 3 个大版本）
- **编辑模式**：源码 + 分屏实时预览（左右或上下分割，可只看编辑器或只看预览），近年新增编辑器内局部渲染改进
- **核心功能**：
  - CommonMark 基础；表格编辑有**行列标记控件**（选择/移动/插入/删除/对齐行列）
  - **代码块语言注入**：在 markdown 代码块内获得该语言完整的高亮、补全、检查；README 中的 shell 命令块有 gutter 运行按钮可直接执行
  - Mermaid / PlantUML 渲染（需一键安装扩展插件，编辑器会在图表块旁给安装提示）；TeX/LaTeX 数学支持
  - **导出**：HTML、PDF 开箱即用；配置 Pandoc 后可导出/导入 **DOCX**（Word 双向转换）
  - 链接补全、重构联动（文件重命名更新链接）
- **UI 设计**：IDE 三栏布局；预览默认样式与 IDE 主题一致，可自定义 CSS（如仿 GitHub）；新版提供 Compose 渲染引擎选项（实验性，替代 Chromium）
- **技术栈**：JVM（Kotlin/Java + Swing/Compose）；预览默认经 **JCEF（内嵌 Chromium）** 渲染，正在试验 Compose 原生渲染
- **AI 能力**：AI Assistant（订阅制，2025.1 起提供免费层）：文档续写/改写/总结、commit message 生成；Junie 编码 agent。均可在 Markdown 文件中使用
- **可借鉴点**：
  1. **代码块语言注入**是"面向开发者的 Markdown 编辑器"最有说服力的功能：块内高亮+补全+可运行，原生应用可用 tree-sitter 注入实现
  2. 表格的行列操作控件：在纯文本表格上叠加结构化操作 UI
  3. Pandoc 集成方式值得抄：自动探测可执行文件、把 DOCX 导入/导出做成菜单项，而不是让用户记命令行
- **不足**：**JCEF 预览性能是重灾区**：YouTrack 上大量"预览滚动约 20fps、卡顿闪烁"投诉，2025.1 改为进程外渲染后又出现预览损坏、IDE 无法启动等回归；IDE 太重，没人为了写 Markdown 单开 IDEA；Mermaid 需另装插件

### Zed

- **基本信息**：Zed Industries（Atom / tree-sitter 原班人马创业公司）｜macOS / Linux / Windows｜编辑器免费开源（GPL-3.0 为主 + 部分 Apache-2.0）；AI 用量走订阅（免费档每月 2000 次 Zeta 预测，Pro 解除限制）｜zed.dev｜github.com/zed-industries/zed（star 约 87k）｜2026-04-29 发布 1.0，当前 v1.11.x，极活跃
- **编辑模式**：源码 + 预览面板（`cmd-k v`）；无所见即所得
- **核心功能**：
  - Markdown 语法高亮基于 **tree-sitter**，代码块内按语言二次高亮
  - 预览近期补齐：**Mermaid 渲染**、预览字号独立缩放、从预览复制富文本时自动转回良构 Markdown
  - 列表续行/退出（空列表项回车自动清除标记）；格式化直接内置 **Prettier**（`cmd-shift-i` 或保存时格式化）
  - 第三方扩展 zed-gfm-preview 调用 GitHub API 渲染正宗 GFM
- **UI 设计**：极简、快、无 chrome 的现代编辑器美学；但 Markdown 预览排版被用户吐槽 h1/h2/h3 字号几乎一样、层级不可见，且暂不支持自定义预览主题（Discussion #43384）
- **技术栈**：**Rust + 自研 GPUI 框架（GPU 加速 UI）**，全原生渲染，无 Electron；这是"高性能原生编辑器"的当代标杆
- **AI 能力**：本类别最激进——Agent Panel 原生 AI 代理（多线程并行、逐 hunk 接受/拒绝、检查点回滚）；**Zeta/Zeta2 开源 edit-prediction 模型**（基于 Qwen2.5-Coder 微调，权重与数据集公开），Tab 连续应用预测；ACP 协议接入外部 agent（Claude Code、Gemini CLI 等）；Subtle Mode 按住 alt-tab 才显示预测、松手即散
- **可借鉴点**：
  1. **性能即产品**：Rust/GPU 渲染带来的"零延迟手感"是开发者选择 Zed 的第一理由，我们做原生 Swift 应用应把打字延迟、大文件滚动当成硬指标
  2. AI 交互范式可整体参考：开源预测模型 + 逐块 diff 审阅 + 检查点回滚 + Subtle Mode（不打扰优先），与"开源免费 + 接入 AI"的定位完全同构
  3. 预览排版被骂恰说明：**开发者编辑器普遍不重视排版美学，这正是我们"简洁好看"定位的空档**
- **不足**：Markdown 预览功能薄弱（无自定义主题、标题层级视觉不清、缺内部锚点跳转/折叠标题，Discussion #23951/#30275 长期开放）；AI 深度绑定订阅引部分用户反感；写作场景功能（导出、图片粘贴管理）几乎空白

### Sublime Text（MarkdownEditing 插件）

- **基本信息**：Sublime HQ（编辑器，US$99 买断含 3 年更新，可无限试用）；MarkdownEditing 为社区插件（现由 deathaxe 主导）｜macOS / Windows / Linux｜插件免费，MIT｜github.com/SublimeText-Markdown/MarkdownEditing（star 约 3.3k）｜最新版 3.6.3（2026-06-30），活跃
- **编辑模式**：纯源码编辑（无内置预览；预览需另装 MarkdownPreview 等插件）
- **核心功能**：标准 Markdown / GFM / MultiMarkdown 三方言语法定义与**写作优化配色方案**；快捷键调整标题级别、`Alt+X` 勾选任务；列表回车续行、Tab 缩进换符号；标题折叠与导航；引用段自动扩展、链接引用管理（自动把内联链接转引用式并归集到文末）、Setext 标题转换、脚注命令、Critic Markup 审阅标记
- **UI 设计**：延续 Sublime 极简美学；亮点是**为写作单独设计的配色方案**（弱化 UI、强化正文层级），早年几乎定义了"程序员 Markdown 写作"的视觉
- **技术栈**：Sublime 为 C++/Python 原生（自绘 UI，GPU 加速），插件为 Python
- **AI 能力**：无官方；社区有 LSP-copilot 等第三方方案
- **可借鉴点**：
  1. "**写 Markdown 时换一套专用配色/排版**"的理念：同一编辑器，代码模式与写作模式视觉不同——原生应用可做得更极致（切换字体、行距、版心宽度）
  2. 引用式链接自动管理（正文干净、链接归集文末）是资深写作者喜欢的小众刚需
- **不足**：无预览需拼插件、体验碎片；Sublime 本体闭源且生态活力下降（Reddit 常见"都 2025 了还有人买 Sublime 吗"论调）；插件历史上曾因过度绑定快捷键、覆盖配色引发争议（v3 已收敛）

### markdown-preview.nvim（Neovim）

- **基本信息**：iamcco（个人开源）｜Neovim/Vim 插件｜免费，MIT｜github.com/iamcco/markdown-preview.nvim（star 约 7.9k）｜**最后一次 release v0.0.10 为 2022-05，基本停止维护**（仍是装机量最大的方案之一）
- **编辑模式**：源码在 Neovim，预览在**外部浏览器**实时同步
- **核心功能**：保存/输入即刷新、**同步滚动**；KaTeX 数学、Mermaid/PlantUML/流程图/时序图、Chart.js 图表、TOC、emoji、任务列表、本地图片；暗/亮主题切换；可自定义预览端口与浏览器
- **技术栈**：Vim 插件 + **本地 Node.js 服务**推送到浏览器渲染
- **AI 能力**：无
- **可借鉴点**：
  1. "编辑归编辑、渲染归浏览器"的解耦架构简单可靠，同步滚动协议（按行号映射）可参考
  2. 它的停更与替代品崛起说明：**用户已不满足于"另开一个窗口预览"**，行内渲染是方向
- **不足**：依赖 Node/yarn 构建常装挂（大量 issue）；停更多年、bug 不修；浏览器窗口与终端来回切换割裂

### peek.nvim（Neovim）【补充发现，简要】

- **基本信息**：toppair（个人开源）｜Neovim 插件｜免费，MIT｜github.com/toppair/peek.nvim（star 约 1k+）｜维护低频
- **核心功能**：markdown-preview.nvim 的现代替代：基于 **Deno** 运行时（默认沙箱、无文件/网络权限），webview 窗口实时预览、同步滚动、TeX 数学、Mermaid、GitHub 风格样式
- **可借鉴点**：用 Deno 沙箱解决"预览服务权限过大"的安全顾虑，说明开发者在意渲染管线的权限边界
- **不足**：需装 Deno，门槛劝退部分用户；功能少于 markdown-preview.nvim

### render-markdown.nvim（Neovim）

- **基本信息**：MeanderingProgrammer（个人开源）｜Neovim ≥0.9 插件｜免费，MIT｜github.com/MeanderingProgrammer/render-markdown.nvim（star 约 4.8k）｜700+ commits，2026 年仍高频更新，活跃
- **编辑模式**：**行内渲染（编辑器内直接美化，无分屏）**——本类别最值得研究的交互创新
- **核心功能**：
  - 用 **tree-sitter 解析 + Neovim extmark/虚拟文本**把源码"就地"替换为渲染效果：六级标题色块、代码块背景+语言图标、表格对齐线、检查框、Obsidian/GitHub 风格 callout 彩色框、行内/块级 LaTeX、wiki 链接、YAML front matter、隐藏 HTML 注释
  - **anti-conceal 机制**：只在光标所在行还原源码，其余行保持渲染态——"编辑哪行哪行变源码"
  - 按窗口可视范围渲染（大文件不卡）；按 Vim 模式切换渲染策略；高度可定制（颜色/图标/边框/内边距），支持自定义 handler 扩展
- **UI 设计**：纯字符界面做出准所见即所得效果；默认配置即好看，被公认"开箱即用的美化"
- **技术栈**：Lua + tree-sitter（markdown、markdown_inline、html、latex、yaml 五个 grammar）
- **AI 能力**：无（但它是各类 Neovim AI 聊天插件渲染回复的事实标准依赖）
- **可借鉴点**：
  1. **anti-conceal 是"混合编辑模式"的最优交互原型**：全文渲染态 + 光标行源码态，比 Typora 式整块还原更稳定、比分屏更沉浸——强烈建议作为我们编辑器的核心交互
  2. "只渲染可视区域"的性能策略
  3. callout、任务列表、标题色阶的默认视觉方案可直接参考
- **不足**：表格/长行在开启软换行时渲染易错位；与 conceal、其他插件的 extmark 偶有冲突；毕竟是"伪渲染"，图片显示依赖终端图形协议、能力有限

### markview.nvim（Neovim）【补充发现】

- **基本信息**：OXY2DEV（个人开源）｜Neovim ≥0.10.3 插件｜免费，Apache-2.0｜github.com/OXY2DEV/markview.nvim（star 约 3.6k）｜最新版 v28.3.0（2026-05-16），活跃
- **编辑模式**：行内渲染 + **hybrid mode**（编辑时局部还原）+ splitview 分屏，多模式可切
- **核心功能**：与 render-markdown.nvim 同类但野心更大：除 Markdown 外还渲染 **LaTeX（2056 个数学符号）、Typst、内联 HTML、AsciiDoc**；支持软换行下渲染；动态高亮组随配色方案自动适配；自带 708 种文件类型图标
- **技术栈**：Lua + tree-sitter
- **AI 能力**：无
- **可借鉴点**：
  1. 多标记语言统一渲染管线的架构思路（一套渲染器多方言）
  2. 社区对比结论有价值：其 hybrid 模式"光标一动渲染就消失"被普遍认为**打断写作心流**，反证 render-markdown 的 anti-conceal（只还原光标行）才是正确手感
- **不足**：配置面大、版本号激进变动（v28+）常有破坏性更新；hybrid 模式体验争议

### obsidian.nvim（Neovim）

- **基本信息**：原作者 epwalsh 停止维护后由社区接管（obsidian-nvim 组织）｜Neovim ≥0.10 插件｜免费，Apache-2.0｜github.com/obsidian-nvim/obsidian.nvim（社区 fork star 约 2k，原仓库 star 更多但已停更）｜最新版 v3.16.5（2026-06-25），活跃
- **编辑模式**：源码编辑增强（常与 render-markdown.nvim 搭配获得渲染效果）
- **核心功能**：在 Neovim 里复刻 Obsidian 工作流且**兼容 Obsidian 库**：`[[` wiki 链接 + 异步自动补全、反向链接、标签导航、Daily Notes（支持日期偏移解析）、模板、**剪贴板粘贴图片落盘**、ripgrep 全库搜索、LSP 式 code action（重命名笔记并同步引用、勾选框切换）、脚注管理；可与 Obsidian Sync 并存
- **技术栈**：99% Lua
- **AI 能力**：无（生态内另有 avante.nvim / codecompanion.nvim 等通用 AI 插件配合）
- **可借鉴点**：
  1. **"兼容 Obsidian 库格式"本身就是获客策略**：开发者已有大量 Obsidian 笔记库，新编辑器若能直接打开 Obsidian vault（wiki 链接、daily notes 目录约定），迁移成本归零
  2. 把笔记操作建模为 LSP 动作（重命名=refactor、链接=goto definition）的思路与 Marksman 呼应
  3. 原作者停更、社区 fork 接管的案例提醒：单人维护的开源项目需要早建社区治理
- **不足**：配置项繁多、上手陡；与各补全引擎（nvim-cmp/blink.cmp）适配问题常见；fork 过渡期文档混乱

### Emacs markdown-mode（与 Org-mode 对比）

- **基本信息**：Jason Blevins 创建，现社区维护｜Emacs major mode，全平台｜免费，GPL-3.0｜jblevins.org/projects/markdown-mode｜github.com/jrblevin/markdown-mode（star 约 1k）｜最新版 v2.8（2026-03-08），近 2000 commits，长期稳定维护（2007 年至今近 20 年）
- **编辑模式**：源码 + **markup hiding**（隐藏标记符号的"半渲染"显示）+ 可调外部预览
- **核心功能**：完整语法高亮与样式化显示（标题分级字号、行内代码变色）；`C-c C-s` 前缀成体系的样式快捷键；**大纲折叠与导航完全对齐 Org-mode 习惯**（TAB 循环可见性）；表格编辑（行列操作，源自 org-table）；GFM 模式、任务列表、脚注/引用管理、wiki 链接；代码块可在 indirect buffer 中用该语言的 major mode 编辑；编译/预览命令可插拔（Markdown.pl/MultiMarkdown/Pandoc/CommonMark 任选）
- **与 Org-mode 对比**（社区共识）：技术上 Org 全面占优——Babel 可执行代码块与文学编程、agenda 任务日程、导出后端丰富、结构化编辑更强；Markdown 的胜点只在**生态通用性**（GitHub/静态站点/协作者不用 Emacs）。结论：Emacs 用户对内用 Org、对外产出 Markdown。Org 的启示在于"文档=笔记+任务+代码执行"的一体化想象力
- **技术栈**：Emacs Lisp
- **AI 能力**：无内置；Emacs 生态经 gptel、copilot.el 等接入
- **可借鉴点**：
  1. **markup hiding 是行内渲染的鼻祖思路**（显示美化但源文件不变），印证该交互 20 年生命力
  2. 大纲折叠/结构导航按住键盘不放的操作流，适合做成我们编辑器的"键盘优先"模式
  3. Org-mode 的启发：任务列表若能与提醒/日程轻集成，会超越"纯文本编辑"价值
- **不足**：预览需外部处理器、开箱体验原始；Emacs 门槛本身；与 Org 相比功能永远"差一截"的定位尴尬

### Glow

- **基本信息**：Charm（Bubble Tea/Lip Gloss 同门）｜终端 CLI/TUI，macOS / Linux / Windows｜免费，MIT｜github.com/charmbracelet/glow（star 约 26k）｜最新版 v2.1.2（2026-04），活跃
- **编辑模式**：**只读渲染**（阅读器，非编辑器）
- **核心功能**：`glow README.md` 即在终端渲染出带色彩、间距、语法高亮代码块的排版；TUI 模式自动发现目录/Git 仓库内所有 markdown 并可浏览，快捷键仿 less，`e` 键调 $EDITOR 编辑；可读取 GitHub/GitLab/HTTP 远端文件；`-p` 走系统分页器、`-w` 控制行宽；**自动检测终端背景色选暗/亮样式**，内置 dark/light/Tokyo Night 等主题且支持 JSON 自定义样式表；v2 已彻底移除 Charm Cloud "stash" 云存储功能，回归纯本地工具
- **UI 设计**：终端排版美学标杆——纯字符环境靠留白、缩进、色彩层级做出"好看"，Charm 全家桶的设计语言高度统一
- **技术栈**：Go（渲染库 Glamour + TUI 框架 Bubble Tea）
- **AI 能力**：无
- **可借鉴点**：
  1. **"渲染样式 = 一份可分发的主题 JSON"**：把排版参数（各元素颜色/边距/前缀）全部数据化，用户可分享主题——原生应用同理可做主题市场
  2. 零配置默认值 + 自动适配明暗背景的开箱体验
  3. 砍掉云功能回归本地的决策广受好评：**本地优先是开发者工具的信任底线**
- **不足**：不渲染 HTML 标签（重 HTML 的 README 显示残缺）；不支持数学公式、脚注等 Pandoc 扩展；图片只显示 alt 文本；宽表格在窄终端换行错乱、无横向滚动

### mdcat

- **基本信息**：swsnr（个人开源）｜终端 CLI，macOS / Linux / Windows｜免费，MPL-2.0｜github.com/swsnr/mdcat（star 约 2.4k）｜最后版本 2.7.1（2024-12），**原仓库已归档停更**，存在社区 fork（BIRSAx2/mdcat）
- **编辑模式**：只读渲染（`cat` 的 markdown 版，直接输出不进 TUI）
- **核心功能**：区别于 Glow 的核心卖点是**保真度**：在 iTerm2 / WezTerm / kitty 中**行内显示真实图片**（终端图形协议）、OSC 8 可点击超链接、iTerm2 标题跳转标记、syntect 语法高亮；`-p` 可选分页。弱点：不渲染表格
- **技术栈**：Rust
- **AI 能力**：无
- **可借鉴点**：
  1. 对终端图形协议（iTerm2/kitty/Sixel）与 OSC 8 链接的运用展示了"在宿主能力范围内做最大保真"的工程态度
  2. 单一职责（只做渲染、组合 Unix 管道）与 Glow 的 TUI 路线形成互补，说明同一场景可分"管道工具"与"沉浸应用"两层
- **不足**：已停止维护；不支持表格渲染是硬伤；效果依赖特定终端，兼容性说明成本高

### Frogmouth

- **基本信息**：Textualize（Rich/Textual 作者 Will McGugan 的公司）｜终端 TUI，macOS / Linux / Windows（Python 3.8+）｜免费，MIT｜github.com/Textualize/frogmouth（star 约 3.2k）｜最后版本 v0.9.1（2023-11），**事实停更**
- **编辑模式**：只读浏览（定位是终端里的 Markdown"浏览器"而非查看器）
- **核心功能**：浏览器式**导航栈（前进/后退）、历史记录、书签**、自动目录侧栏；本地文件与 URL 均可打开；`frogmouth gh textualize/textual` 一条命令直接浏览任意 GitHub 仓库的 README；跨会话状态保持
- **UI 设计**：基于 Textual 框架，在终端里做出了侧栏 + 内容区 + 弹窗的完整"应用级"布局，鼠标可点
- **技术栈**：Python + Textual（Rich 渲染）
- **AI 能力**：无
- **可借鉴点**：
  1. "**把文档阅读当浏览行为设计**"：历史、书签、站内导航——我们的编辑器若有阅读模式，链接跳转的前进/后退栈是值得抄的心智模型
  2. `gh 用户/仓库` 直达 README 的"零克隆阅读"入口设计
- **不足**：停更两年+；启动即打开上次文档且无法关闭历史功能（用户抱怨）；Python 启动速度与分发不如 Go/Rust 单文件

### inlyne【补充发现】

- **基本信息**：Inlyne Project（社区开源）｜独立 GUI 查看器（非终端渲染但属开发者管道工具），macOS / Linux / Windows｜免费，MIT｜github.com/Inlyne-Project/inlyne（star 约 1.3k）｜最新版 v0.5.2（2026-05-19），维护中
- **编辑模式**：只读渲染 + **live reload**（监听文件保存自动刷新，配合任意编辑器当"外置预览窗"）
- **核心功能**：`inlyne README.md` 秒开一个 **GPU 加速**的渲染窗口；表格、语法高亮代码块、图片、任务列表、引用块；定位是"markdown 界的 macOS 预览（Preview.app）"——比开浏览器/VS Code 轻一个数量级
- **技术栈**：Rust；comrak 解析 markdown→HTML，自研渲染（wgpu GPU 渲染 + Lyon 矢量 + Winit 窗口），完全无浏览器内核
- **AI 能力**：无
- **可借鉴点**：
  1. 验证了**不用 WebView 也能渲染 markdown**的技术路线（解析→自绘），对我们评估 SwiftUI/TextKit 2 自绘渲染 vs WKWebView 有直接参考价值
  2. "秒开、只读、live reload"的轻量预览窗形态，可作为我们应用的伴生功能（如菜单栏快速预览）
- **不足**：排版细节粗糙（自绘渲染的代价）；无导出；HTML 支持子集有限

### Marksman（Markdown LSP）

- **基本信息**：Artem Pyanykh（个人开源）｜LSP 服务器，macOS / Linux / Windows 自包含二进制（Homebrew/Snap 可装）｜免费，MIT｜github.com/artempyanykh/marksman（star 约 3.3k）｜最新 release 2026-02，维护中
- **编辑模式**：不是编辑器，是**把 Markdown 当编程语言对待的语言服务器**，编辑体验由宿主提供
- **核心功能**（LSP 化思路全景）：
  - **补全**：输入 `[[` 或 `](` 时补全工作区内文档名与标题锚点（支持 wiki 链接与标准链接双语法，面向 Zettelkasten 场景）
  - **跳转/引用**：goto definition 跳到被链接文档/标题；find references 列出所有反向链接
  - **重构**：rename 重命名文档或标题，自动更新全库引用
  - **诊断**：死链、悬空 wiki 链接实时报错
  - 一套服务器通吃十余编辑器：VS Code、Neovim（nvim-lspconfig/mason）、Helix（内置默认启用）、Emacs、Sublime、Zed、BBEdit、Kakoune 等
- **技术栈**：F#（.NET，自包含编译）
- **AI 能力**：无
- **可借鉴点**：
  1. **"Markdown 知识库 = 代码库"的抽象**：链接是符号引用、重命名是重构、死链是编译错误——我们编辑器的库管理功能应直接按这套语义设计（甚至可以内嵌或复用 Marksman）
  2. 证明跨文档智能（反向链接/重命名同步）可以与 UI 解耦为独立引擎，架构上值得借鉴：核心引擎独立于界面层
  3. Helix 默认内置它，说明 LSP 化让"任何编辑器秒变笔记应用"——反过来，我们的原生编辑器若支持 LSP 客户端协议，就能白嫖整个生态
- **不足**：无实时渲染类功能（纯语言智能）；对超大知识库索引性能一般；配置文档较薄，wiki 链接与 Obsidian 语法细节（别名、嵌入）兼容不完整

### Prettier（Markdown 格式化）

- **基本信息**：OpenJS 基金会旗下社区项目｜Node CLI / 编辑器集成，全平台｜免费，MIT｜prettier.io｜github.com/prettier/prettier（star 约 52k）｜最新版 3.9.5（2026-07-09），非常活跃
- **核心功能**：作为"武断的格式化器"覆盖 Markdown：统一标题/列表/强调符号风格、表格对齐、代码块围栏；关键选项 `proseWrap`（`preserve` 默认不动换行 / `always` 硬换行到 printWidth / `never` 段落合一行）；被 VS Code、Zed 等直接内置为默认 Markdown 格式化器，保存即格式化
- **技术栈**：JavaScript；Markdown 解析用 remark-parse
- **AI 能力**：无
- **可借鉴点**：
  1. **"保存即格式化"应成为我们编辑器的内置选项**（表格自动对齐尤其讨喜），开发者已被 Prettier 驯化出此预期
  2. `proseWrap` 三态设计直接照抄：中文场景尤其需要 `preserve`/`never`（硬换行会在渲染时产生多余空格）
- **不足**：`always` 模式会破坏引用式链接（issue #9232）、对换行敏感的渲染器（BitBucket/GitHub 评论）不安全；三个选项命名语义模糊、文档不清是多年吐槽点；默认不换行让期待"格式化=换行"的用户困惑（issue #5123）

### mdformat（Markdown 格式化）

- **基本信息**：Taneli Hukkinen（个人开源，tomli 作者）｜Python CLI / 库，全平台｜免费，MIT｜github.com/hukkin/mdformat（star 约 800）｜v1.0.0（2025-10-16）里程碑版，活跃
- **核心功能**：**严格 CommonMark 合规**的格式化器；与 Prettier 的差异化：纯 Python 零 Node 依赖（Python 工具链项目 CI 更友好）、解析器（markdown-it-py）比 Prettier 的 remark-parse v8 更合规、**格式化前后做 AST 等价性安全检查**（保证不改变文档语义）；插件体系支持 GFM（mdformat-gfm）、front matter、TOC 自动生成、代码块内嵌代码格式化；pre-commit 官方钩子
- **技术栈**：Python（markdown-it-py）
- **AI 能力**：无
- **可借鉴点**：
  1. **"格式化后 AST 必须等价"的安全检查**是工程亮点：我们做任何自动改写（格式化、AI 改写）都应有这层"语义不变"校验
  2. 插件式方言扩展（核心只管 CommonMark，GFM/front matter 都是插件）是干净的架构分层
- **不足**：star 少、知名度低于 Prettier；默认输出风格（如 `#` 转 setext 等细节）与主流习惯偶有出入需插件调整；生态小

### Pandoc（格式转换枢纽，简要）

- **基本信息**：John MacFarlane（伯克利哲学教授，CommonMark 规范作者之一）｜CLI，全平台｜免费，GPL-2.0+｜pandoc.org｜github.com/jgm/pandoc（star 约 45.5k）｜最新版 3.10（2026-06），20 年持续维护
- **核心功能**：**约 40+ 输入格式 × 60+ 输出格式**的文档转换瑞士军刀：Markdown ↔ DOCX / LaTeX / PDF / EPUB / HTML / reST / MediaWiki…；自家 Pandoc Markdown 方言是扩展最全的方言（脚注、引用文献 citeproc、定义列表、表格多形态、数学）；Lua 脚本自定义 reader/writer/filter；模板系统控制输出样式
- **技术栈**：Haskell
- **AI 能力**：无
- **可借鉴点**：
  1. **不要自研导出**：JetBrains、MPE、Obsidian 插件全都把 DOCX/复杂导出外包给 Pandoc——我们应内置"检测/引导安装 Pandoc + 图形化封装参数"，导出矩阵瞬间拉满
  2. Pandoc Markdown 的扩展清单是"方言支持优先级"的权威参考
- **不足**：CLI 参数极复杂，普通用户必须靠 GUI 封装；PDF 输出依赖 LaTeX 发行版（体积大、安装劝退）；默认模板视觉平庸

## 本类别小结

**共性与趋势**

1. **行内渲染取代分屏预览成为主流方向**：render-markdown.nvim / markview.nvim / Emacs markup-hiding / JetBrains 的探索殊途同归——开发者想要"看起来是渲染的、点进去是源码的"混合态；而"光标行还原源码、其余保持渲染"（anti-conceal）被社区验证为手感最佳的方案。
2. **Markdown 正在被"语言工具链化"**：LSP（Marksman）、Linter（markdownlint）、Formatter（Prettier/mdformat）、编译器（Pandoc）、tree-sitter 语法树——开发者用对待代码的整套基建对待 Markdown，链接=符号、死链=报错、重命名=重构。
3. **图片/链接的零摩擦处理成为基线**：VS Code 定义的"粘贴 URL 成链接、粘贴图片自动落盘、重命名同步改引用"已是隐性标配，任何新编辑器缺这些会被立刻感知。
4. **AI 已下沉为编辑器基础设施**：Copilot（VS Code）、AI Assistant（JetBrains）、Agent Panel + 开源 Zeta 模型（Zed）；而纯 Markdown 工具（终端阅读器、格式化器、LSP）尚无 AI 集成——空白即机会。
5. **本地优先是开发者的信任底线**：Glow 砍掉云 stash 广受好评、MPE 强调数据不出本地、peek.nvim 用 Deno 沙箱——隐私与离线能力是这个人群的硬性偏好。
6. **单人维护项目普遍脆弱**：Markdown All in One 停滞、markdown-preview.nvim/mdcat/Frogmouth 停更、obsidian.nvim 靠社区 fork 续命——活跃维护本身就是竞争力。

**对我们产品的启示**

- **核心交互押注 anti-conceal 式混合编辑**：全文渲染态 + 光标行/选区还原源码，配合 `Cmd+/` 类快捷键在纯源码、混合、纯阅读三态间切换；这是 Neovim 生态用两年时间替我们验证过的最优解。
- **把 VS Code 基线功能做满做顺**：粘贴 URL 成链接、粘贴/拖拽图片自动落盘（目录规则可配）、`[[`/`](` 路径与锚点补全、死链诊断、文件重命名同步改链接、`Cmd+B/I` 快捷键、列表续行与编号自修复、保存即格式化（表格对齐）。这份清单就是开发者用户的验收标准。
- **知识库语义学 Marksman，架构上引擎与 UI 分离**：反向链接、跨文件重命名、全库标题搜索做成独立核心层；可评估直接内嵌 Marksman 或兼容 LSP 以低成本获得生态。
- **渲染管线学 MPE 的功能面 + 原生实现避其坑**：Mermaid/PlantUML/KaTeX 一次配齐，但导出走系统 WebKit/PDFKit 而非无头 Chrome；DOCX 等复杂格式外包给 Pandoc 并做图形化封装（学 JetBrains 的自动探测 + 菜单化）。
- **代码块是面向开发者的胜负手**：块内按语言高亮（tree-sitter 注入）、一键复制、可选运行（学 JetBrains gutter 运行与 MPE code chunk），这是通用写作类编辑器不会做深的差异化。
- **AI 策略学 Zed**：本地/开源模型优先 + 逐块 diff 审阅 + 检查点回滚 + Subtle Mode 式不打扰交互；写作场景优先做具体小事（标题/摘要/标签生成，学 Front Matter）而非泛聊天框。
- **用"美"打开发者工具的空档**：Zed 预览排版被骂、终端工具先天受限、VS Code 预览简陋——"原生 macOS + 认真做排版字体（版心、行距、中西文混排）+ 主题数据化可分享（学 Glow）"在这个人群里是稀缺品。
- **兼容存量生态降低迁移成本**：可直接打开 Obsidian vault（wiki 链接、daily notes 约定，学 obsidian.nvim/Foam）、front matter 表单化（学 Front Matter CMS）、`.markdownlint` / `.prettierrc` 配置文件识别。
