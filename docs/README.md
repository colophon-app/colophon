# Markdown 编辑器全市场调研文档 · 总索引

> 调研日期：2026-07-21 ｜ **第一阶段（01–13）** 全市场普查：01–10 分类调研 + 11–13 综合分析。**第二阶段（14–19）** 路线 B 专题：Markdown × AI Agent 深度调研（编辑器作为「人 ↔ AI Agent 的 Markdown 界面」）。

## 调研背景与目标

本套文档是对 Markdown 编辑器全市场的系统性调研，目标是为「用 Xcode 开发一款原生 macOS、简洁好看、开源免费、可接入 AI 的 Markdown 编辑器」提供决策依据。调研覆盖 Apple 原生、跨平台桌面、Windows 与停更遗产、开源知识库、商业笔记应用、Web 在线、IDE/终端插件、AI 写作八大产品类别及技术栈选型，逐款记录基本信息、编辑模式、核心功能、UI 设计、技术栈、AI 能力、可借鉴点与不足，并在综合文档中提炼出功能矩阵、UI 设计模式与产品机会。

## 文档目录 · 第一阶段：全市场普查（01–13）

| 文档 | 一句话说明 | 收录条目 |
|---|---|---|
| [01-apple-native.md](./01-apple-native.md) | Apple 平台原生编辑器（macOS/iOS），与目标产品形态最接近的直接竞品：iA Writer、Ulysses、Bear、NotePlan、MarkEdit、妙言等 | 20 款产品 |
| [02-cross-platform.md](./02-cross-platform.md) | 活跃维护中的跨平台桌面编辑器，重点解剖标杆 Typora 的实时渲染交互与买断定价，兼及 Mark Text、Zettlr、MarkFlowy 等 | 14 款产品 |
| [03-windows-legacy.md](./03-windows-legacy.md) | Windows 专属与已停更/衰落产品的历史与死亡教训（单人枯竭、组件技术债、转型翻车），对「可持续维护」最有参考价值 | 20 款产品 |
| [04-open-source-knowledge-bases.md](./04-open-source-knowledge-bases.md) | 开源笔记/知识库应用（本地优先、双链、可自托管）：Joplin、Logseq、思源、Trilium、AppFlowy、Anytype 等，含协议与商业化观察 | 19 款产品 |
| [05-note-apps.md](./05-note-apps.md) | 闭源/商业笔记与文档应用中的 Markdown（块编辑器 + Markdown 语法糖范式）：Notion、Obsidian、Craft、语雀、飞书等 | 17 款产品 |
| [06-web-editors.md](./06-web-editors.md) | Web 在线编辑器四亚类：通用在线、协作平台（HackMD）、公众号排版工具（doocs/md 等中文特有物种）、可嵌入组件（Vditor、Milkdown 等） | 16 款产品/组件 |
| [07-ide-terminal.md](./07-ide-terminal.md) | IDE/终端/插件生态中的 Markdown 工作流：VS Code 功能基线、JetBrains/Zed、Neovim 行内渲染系、终端阅读器、LSP、格式化器与 Pandoc | 23 个条目 |
| [08-ai-writing.md](./08-ai-writing.md) | AI 写作工具与编辑器 AI 集成现状（Notion AI、Lex、Type、Reor、Obsidian 插件生态、MCP 路线等），附 AI×Markdown 交互形式穷举清单 | 16 个条目 + 28 种交互形式 |
| [09-tech-stack.md](./09-tech-stack.md) | 技术栈与内核选型（重点 Swift/macOS 原生）：Web 编辑器内核、成品实现解剖、各语言解析器、原生文本引擎、渲染增强组件，收束为 A/B/C 三套完整方案 | 40 个条目（含 3 套方案） |
| [10-gap-supplement.md](./10-gap-supplement.md) | 查漏补缺：比对 awesome-markdown-editors / AlternativeTo / 少数派等榜单后补收的遗漏项，含 2025–2026「原生 macOS + 开源 + AI Agent 协作」新生代（OpenMark、Clearly、SideMark、NoteGen、Yank Note、Markor 等），与本项目定位高度重合 | 22 款产品 |
| [11-feature-matrix.md](./11-feature-matrix.md) | 功能对比矩阵与功能全集：9 张分类对比大表（去重后约 130 款产品 + 09 号技术组件速览）、8 大类 240+ 条功能全集清单、3 组焦点对比（编辑模式流派/原生 vs Electron/免费与付费差距） | 9 张矩阵表 + 240+ 条功能点 |
| [12-ui-design-patterns.md](./12-ui-design-patterns.md) | UI 设计模式总结：5 大布局模式、排版与字体、3 种主题机制、专注体验对比、23 条「简洁好看」具体手法归纳（含反面清单）、6 条对我们产品的 UI 建议 | 37 条归纳条目 |
| [13-product-opportunities.md](./13-product-opportunities.md) | 产品机会与功能规划建议：市场格局（八大阵营/商业模式/三大趋势）、8 大市场空白、定位与打法、MVP→V1→V2 功能分层与「不做清单」、AI 集成构思、技术选型倾向、风险清单，附核心结论一页纸 | 8 大机会 + 全套规划 |

## 文档目录 · 第二阶段：Markdown × AI Agent 深度调研（路线 B）

> 背景：产品定位已收紧为「面向**写大量 Markdown 的开发者**」；AI 策略确定走「**路线 B**」——编辑器自己不生成内容（那是 AI Agent 的活），而是成为「人 ↔ AI Agent 的 Markdown 界面」。本阶段专门调研「如何用 Markdown 增强 AI Agent 体验，编辑器该为此做什么」。

| 文档 | 一句话说明 | 收录条目 |
|---|---|---|
| [14-agent-md-formats.md](./14-agent-md-formats.md) | 写给 AI Agent 的 Markdown 文件格式与规范：CLAUDE.md（层级/@import）、AGENTS.md（24+ 工具的跨工具标准）、Cursor `.mdc`、Copilot instructions、Windsurf/Cline/Aider/Gemini 规则、llms.txt、frontmatter 约定与「好指令文件」最佳实践 | 20+ 格式/规范 |
| [15-mcp-for-editor.md](./15-mcp-for-editor.md) | MCP 深度解剖：三原语（Tools/Resources/Prompts）、传输与授权、现有笔记类 MCP server 全扫描（Obsidian/Bear/Basic Memory/Logseq/Apple Notes/Joplin/VMark 等），反推我们编辑器该暴露的接口草案（含独占的 AST 结构化编辑 `apply_edit`） | 接口草案 + 全行业扫描 |
| [16-agent-skills.md](./16-agent-skills.md) | Agent Skills 与 Markdown（技能即 Markdown）：SKILL.md 结构与 frontmatter、渐进式披露、Skills vs MCP vs 规则文件三门分工、生态与最佳实践，及把编辑器做成「skill 作者工作台」 | Skills 机制 + 结合点 |
| [17-human-agent-workflows.md](./17-human-agent-workflows.md) | 人机协作工作流：规格驱动开发（spec-kit/Kiro/EARS）、计划与任务文件（plan.md/tasks.md 复选框）、Agent 产出报告的 diff 审阅与 checkpoint 回滚、ADR/MADR/CHANGELOG 等 Markdown 协作产物 | 工作流全景 |
| [18-agent-editor-competitors.md](./18-agent-editor-competitors.md) | 竞品拆解：SideMark（三方合并）、Ritemark、VMark、Nimbalyst（内联 diff）、MacMD、OpenMark、Clearly、SoloMD 等「编辑器×Agent」新物种，及 Cursor/Zed/Kiro/Claude Code，收束为「可借鉴 vs 该避免」清单 | 20+ 产品 |
| [19-route-b-blueprint.md](./19-route-b-blueprint.md) | **路线 B 综合蓝图**：人机 Markdown 循环全景、MVP/V1/V2 功能分层、MCP 接口草案、要采纳的标准（AGENTS.md/MCP/Skills/llms.txt/JSON Canvas）、安全与权限模型、「不做」清单、8 个待 dogfooding 验证的开放问题，附核心结论一页纸 | 全套路线 B 规划 |

## 总体统计

- **产品/工具条目**：01–08 号分类文档收录 **145 个产品/工具条目**，10 号查漏补缺再补 **22 款**（合 167 项）；跨类别去重后约 **150 款产品**。
- **技术条目**：09 号文档收录 **40 个条目**，涵盖 Web 编辑器内核、成品实现解剖、JS/C/Rust/Swift 解析器、原生文本引擎与组件、渲染增强组件、架构取舍与 3 套完整方案组合。
- **综合归纳**：11–13 号文档产出 9 张对比矩阵、240+ 条功能全集、28 种 AI 交互形式、37 条 UI 设计归纳与 8 大市场机会。
- **类别覆盖**（9 大类）：① Apple 原生 ② 跨平台桌面 ③ Windows 专属/停更遗产 ④ 开源知识库 ⑤ 闭源商业笔记应用 ⑥ Web 在线与嵌入组件 ⑦ IDE/终端/插件生态 ⑧ AI 写作与 AI 集成 ⑨ 技术栈与内核。
- **全部文档主条目合计：261 个**（产品/工具 145 + 查漏补缺 22 + 技术 40 + 综合归纳 54）。
- **第二阶段（路线 B 专题，14–19 号 6 份）**：覆盖 20+ 种 Agent 相关文件格式（14）、全行业笔记类 MCP server 扫描 + 我们的接口草案（15）、Agent Skills 机制与结合点（16）、人机协作工作流全景（17）、20+ 款「编辑器 × Agent」竞品拆解（18），收束为一份可直接指导开发的路线 B 产品设计蓝图（19）。

## 建议阅读顺序

1. **先看结论**：[13-product-opportunities.md](./13-product-opportunities.md) —— 市场空白、定位、功能分层与风险，文末附「核心结论一页纸」，10 分钟建立全局判断。
2. **再看全景**：[11-feature-matrix.md](./11-feature-matrix.md) —— 用 9 张矩阵表横向定位任何一款产品，功能全集清单可直接当产品需求池用。
3. **然后看设计**：[12-ui-design-patterns.md](./12-ui-design-patterns.md) —— 「简洁好看」的具体手法与反面清单，直接指导 UI 决策。
4. **动手前看技术**：[09-tech-stack.md](./09-tech-stack.md) —— Swift/macOS 原生路线的组件选型与 A/B/C 方案取舍，开工前必读。
5. **按需回查分类文档**（01–10）：研究直接竞品看 01、02；吸取停更教训看 03；对比开源社区运营看 04；理解块编辑器与商业笔记范式看 05；找 Web 组件与中文场景看 06；对齐开发者功能基线看 07；设计 AI 功能看 08（28 种交互形式清单是 AI 功能设计的起点）；**10 号查漏补缺尤其要读**——它收录的 2025–2026「原生 macOS + 开源 + AI Agent 协作」新生代与本项目定位高度重合，既是灵感也是竞争预警。

6. **深入 AI × Agent（第二阶段·路线 B，当前推进方向）**：[19-route-b-blueprint.md](./19-route-b-blueprint.md) 是这一阶段的总纲，先读它——人机 Markdown 循环全景、MVP/V1/V2 功能分层、MCP 接口草案、安全模型、「不做」清单、8 个待 dogfooding 验证的开放问题都在里面；想深挖某一面再看 [15](./15-mcp-for-editor.md)（MCP 接口该暴露什么）、[14](./14-agent-md-formats.md)（Agent 文件格式）、[16](./16-agent-skills.md)（Skills）、[17](./17-human-agent-workflows.md)（协作工作流）、[18](./18-agent-editor-competitors.md)（竞品该抄什么/避什么）。

各分类文档（01–10、14–18）开头均有「总体观察」段落，结尾均有「小结」或「对我们编辑器的启示」，时间紧张时可只读这两部分。
