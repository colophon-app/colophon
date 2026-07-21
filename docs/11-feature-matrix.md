# 功能对比矩阵与功能全集

> 汇总口径：本文档完全基于 docs/01–09 号分类调研文档整理（目录中无 10 号文档），不引入文档之外的信息。收录产品约 130 款，去重原则：同一产品在多份文档出现时（如 Joplin、QOwnNotes、Caret、Mark Text、Notable、ReText、Foam、Anytype、Craft、Notion、Obsidian、iA Writer、Ulysses、Bear），只在其主类别表格中列一行，AI 等信息合并各文档描述。09 号文档的技术内核/组件另列简表。整理日期：2026-07-21。

---

## 一、总览大表

### 表 1：Apple 平台原生编辑器（01 号文档）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| iA Writer | Apple 原生 | macOS/iOS/iPadOS（另有 Win/Android） | 买断：Mac $49.99 等，各平台单独购买，无订阅 | 闭源（三款字体开源） | 纯源码+语法样式化，独立预览面板 | 原生 AppKit/UIKit，自研文本引擎 | 反向切入：Authorship 标注 AI 文本，7.3 起集成 Apple Intelligence 校对；刻意不做生成 | 极简写作的天花板，"工具隐身、排版即品牌" |
| Ulysses | Apple 原生 | macOS/iOS/iPadOS | 订阅 $5.99/月或 $39.99/年 | 闭源 | 源码样式化实时渲染（气泡内联） | 原生 AppKit/UIKit 自研引擎 | 无生成式 AI；LanguageTool 系校对；借力 Apple Writing Tools | 作家的 IDE：三栏文库+目标统计+一键发布 |
| Bear | Apple 原生 | macOS/iOS/iPadOS/watchOS | 免费+Pro $2.99/月或 $29.99/年 | 闭源 | 隐藏标记式实时渲染（光标进入显形） | 原生 UI+自研跨平台内核 Panda（C++ AST），9.4 万词 55ms 打开 | 无内置生成；2.8 起有 BearCLI、MCP server 与 Claude Connector；借力 Writing Tools | "最漂亮的笔记 app"，标签即组织 |
| Byword | Apple 原生 | macOS/iOS | 买断 Mac $10.99、iOS $5.99 | 闭源 | 单栏源码+语法淡化，⌥⌘P 切换预览 | 原生 AppKit/UIKit | 无 | 以打字手感著称的极简编辑器（事实停更） |
| MWeb Pro | Apple 原生 | macOS/iOS/iPadOS | 买断 $34.99 终身 | 闭源 | 源码+分屏实时预览，编辑区内联图片/公式 | 原生（非 Electron），预览 WebView | 未知 | 文库+外部文件夹+发布+静态博客的中文全能工具 |
| Marked 2 | Apple 原生 | macOS | 买断 $13.99 | 闭源 | 纯预览器（无编辑功能），监视文件实时刷新 | 原生 AppKit+WebKit | 无 | 写作者的"第二屏"：预览/校对/导出解耦 |
| Highland 2 / Pro | Apple 原生 | macOS（Pro 扩至 iPad/iPhone） | H2 停售；Highland Pro 订阅 $4.99/月起 | 闭源 | 纯文本语法样式化实时渲染（Fountain 为主+Markdown） | 100% 原生 | 无（/Lookup 为词典查询） | 编剧写作流程工具（Scratchpad、The Shelf、Sprints） |
| Taio | Apple 原生 | iOS/iPadOS/macOS | 免费+Pro 内购（订阅或买断 $29.99+） | 闭源 | 源码高亮+预览切换，多标签 | 原生 UIKit，Mac 为 Catalyst | 无内置（JS 动作理论可接 API） | 编辑器+积木式 JS 自动化的文本处理中枢（近停更） |
| Drafts | Apple 原生 | iOS/iPadOS/macOS/watchOS/visionOS | 免费+Pro 约 $19.99/年 | 闭源 | 纯源码+可切语法定义，HTML 预览窗 | 原生（非 Electron） | 无内置功能；提供 OpenAI() 与 SystemLanguageModel（Apple 端上模型）脚本对象+社区 AI 动作 | "文字的起点"：捕捉优先+动作系统枢纽 |
| 1Writer | Apple 原生 | iOS/iPadOS | 买断 $4.99+小费 | 闭源 | 单栏源码+行内轻量预览 | 原生 UIKit | 无 | 买断制老派实用派，JS 动作扩展 |
| iWriter Pro | Apple 原生 | macOS/iOS | 买断约 $9.99–11.99 | 闭源 | 源码高亮+分屏预览（滚动同步） | 原生 AppKit/UIKit | 无 | "iA Writer 式体验 + 1/5 价格 + 无订阅" |
| NotePlan | Apple 原生 | macOS/iOS/iPadOS+Web beta | 订阅约 $100/年 | 主程序闭源（插件生态开源） | 实时渲染混合（标记淡化，任务/日期交互化） | 原生 Swift | 内置：⌘O 上下文 AI（选笔记/文件夹为上下文）、生成/改写/总结、语音转写 | 任务+笔记+日历三合一生产力仪表盘 |
| nvUltra | Apple 原生 | macOS | 未发布（七年私测） | 闭源 | 源码+预览，omnibar 搜索即新建 | 原生 AppKit | 无 | Notational Velocity 精神续作（vaporware） |
| FSNotes | Apple 原生 | macOS/iOS | 开源免费 MIT（MAS 付费支持版） | 开源（约 7.4k star） | 源码高亮为主+预览切换 | Swift 5 原生（AppKit/UIKit+TextKit） | 无 | nvALT 续作：纯文件+Git 版本控制+闪电搜索 |
| MiaoYan（妙言） | Apple 原生 | macOS | 开源免费 MIT（MAS 付费支持版） | 开源（约 8.4k star） | 纯源码高亮+⌘\ 一键分屏（60fps 双向同步），明确不做 WYSIWYG | Swift 6 AppKit，仅 23MB | 无 | 中文高颜值极简编辑器，附妙言 PPT |
| Paper | Apple 原生 | macOS（仅 Apple Silicon）/iOS | 免费+Pro（订阅或隐藏买断） | 闭源 | 单栏源码淡化渲染，文件式无文库 | 原生自研渲染 | 无 | 把打字动效与手感做成护城河 |
| MarkEdit | Apple 原生 | macOS | 完全免费 MIT | 开源（约 5.2k star） | 纯源码（文档式），预览由官方扩展提供 | Swift/AppKit 壳+CodeMirror 6 内核，约 4MB | 官方扩展 MarkEdit-ai-writer 接 Apple Intelligence 端上模型 | "Markdown 界的 TextEdit"，与我们定位重合度最高 |
| MacDown | Apple 原生 | macOS | 免费开源 MIT | 开源（约 9.8k star） | 经典双栏分屏（左源码右 WebView 预览） | Objective-C+AppKit+Hoedown(C)+WebView | 无 | 2014–2019 年 Mac 开源默认之选（已停更） |
| Notenik | Apple 原生 | macOS | 完全免费 MIT | 开源 | 编辑/显示双 Tab 切换 | Swift+AppKit | 无 | 笔记+可自定义元数据字段的"个人 CMS" |
| Mou | Apple 原生 | macOS | 免费/捐赠 | 闭源 | 双栏分屏实时预览 | 原生 AppKit+WebView | 无 | 2012–2015 中文圈最流行（已死，教训条目） |

### 表 2：跨平台桌面编辑器（02 号文档）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| Typora | 跨平台 | macOS/Windows/Linux | 买断 $14.99（3 台设备，15 天试用） | 闭源 | 逐段实时渲染 WYSIWYG 开创者+整篇源码模式 | Electron+自研分块渲染引擎 | 官方无任何 AI；社区插件 typora-copilot（需 Copilot 订阅） | 实时渲染交互的体验标杆 |
| Mark Text | 跨平台 | Linux/macOS/Windows | 免费 MIT | 开源（约 58.9k star，本类最高） | Typora 式逐段实时渲染+源码模式 | Electron+Vue+自研 Muya 内核 | 无 | "开源版 Typora"（停更三年后 2026 复活） |
| Zettlr | 跨平台 | Win/macOS/Linux | 免费 GPL-3.0（捐赠） | 开源（约 13.3k star） | CodeMirror 6 装饰式半实时渲染+源码切换 | Electron+TS+Vue+CM6+Pandoc | 无内置 | 学术出版工作台（引用文献、Zettelkasten、40+ 格式导出） |
| Inkdrop | 跨平台 | 三平台+iOS/Android | 纯订阅 $4.99/月起，无免费版 | 闭源（插件生态开源） | 双栏分屏（源码+预览） | Electron+React+CodeMirror；移动端 RN | 官方无内置 | 开发者笔记，"公开开发过程+订阅"活了近十年 |
| Caret | 跨平台 | 三平台 | 买断 $29 | 闭源 | 语法字符保留的内联渲染（源码与 WYSIWYG 之间） | Electron+parsedown 系自研解析 | 无 | "最讲究细节的 Markdown 编辑器"（已停更） |
| ghostwriter | 跨平台 | Windows/Linux（macOS 需自编译） | 免费 GPL-3.0 | 开源（约 4.9k star，KDE） | 单栏源码+可开合实时预览分屏 | C++/Qt6/KDE（原生 Qt） | 无 | 禅意无干扰写作（Hemingway 模式、焦点粒度可选） |
| Apostrophe | 跨平台 | 实际仅 Linux | 免费 GPL-3.0 | 开源（GNOME） | 单栏轻实时渲染（语法保留但淡化）+全文预览 | Python+GTK4/libadwaita+Pandoc | 无 | "原生且美"的 GNOME 极简天花板 |
| Notable | 跨平台 | 三平台 | 免费；v1.6 起闭源 | 闭源（旧版 MIT，约 23.5k star） | 双栏分屏或单栏切换 | Electron+TS+Monaco | 无 | "纯 .md 文件+front matter 永不锁定"（基本停更，闭源反噬教训） |
| VNote | 跨平台 | 三平台 | 免费 LGPL-3.0 | 开源（约 12.9k star） | 源码高亮编辑/渲染阅读双模式 | C++/Qt 原生+Qt WebEngine，vxcore 内核 | 无 | 程序员笔记本，旗舰功能是任意 Git 远端同步 |
| QOwnNotes | 跨平台 | 三平台 | 免费 GPL-2.0 | 开源（约 5.8k star） | 源码编辑+分屏预览，多布局预设 | C++/Qt 原生，QML/JS 脚本引擎 | 内置 AI（OpenAI/Groq 等可接）+内置 MCP server 供外部 Agent 读笔记 | 十年周更的极客工具箱（Nextcloud 集成、脚本市场、LSP） |
| Znote | 跨平台 | 三平台 | 免费（含 AI 额度）+Pro 29.90€ 买断 | 仓库公开（约 240 star，非典型开源） | 实时渲染 WYSIWYG+可执行 JS 代码块 | Electron+React | 深度：免费额度+BYOK（OpenAI/OpenRouter/Ollama）零抽成，@ 引用笔记为上下文，会议转写 | "Jupyter for JS developers"+AI 变现姿势标杆 |
| MarkFlowy | 跨平台 | 三平台 | 免费 AGPL-3.0 | 开源（约 2.3k star） | WYSIWYG 实时渲染+源码双模式 | Tauri（Rust 壳）+TS+remirror/ProseMirror，<20MB | 一级功能内置：ChatGPT/DeepSeek/Ollama，翻译/摘要/对话 | 新一代 Tauri+AI 开源编辑器（我们的 Tauri 对照组） |
| ReText | 跨平台 | Linux 为主 | 免费 GPL-2.0+ | 开源（约 2.1k star） | 经典双栏分屏+同步滚动 | Python+PyQt6 | 无 | 15 年长寿的多标记语言（md/reST/Textile/AsciiDoc）工具 |

### 表 3：Windows 专属与已停更产品（03 号文档，去除与表 2 重复者）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| MarkdownPad | Windows/停更 | Windows | 免费+Pro $14.95 买断 | 闭源 | 双栏分屏 LivePreview+同步滚动 | .NET/WPF+Awesomium 内嵌浏览器 | 无 | Win7 时代标杆；死于渲染内核依赖（2014 停更） |
| Markdown Monster | Windows/存活 | Windows | 买断 $99 起（多档），永久许可 | 源码可申请（非 FOSS） | 源码+同步 HTML 预览分屏 | WPF(.NET)+WebView2 | 完整 BYOK：OpenAI/Azure/OpenRouter/Grok/Gemini/Ollama 任意兼容端点，生图嵌入、补全、AI 摘要 | 一人公司"明码收费+博客营销"活得最久的样本 |
| Typedown | Windows/停更 | Win10/11 | 免费 MIT | 开源（约 1k star） | 类 Typora 实时渲染（Web 内核嵌 WebView2） | C#+WinUI 3 壳+JS/TS 编辑内核 | 无 | "最像 Windows 亲儿子"的编辑器（2023 停更） |
| WriteMonkey | Windows/半休眠 | WM2 仅 Win；WM3 跨平台 | 免费+捐赠解锁插件 | 闭源 | 纯源码单栏+语法高亮，全屏禅模式默认 | WM2 .NET；WM3 NW.js | 有：AI Helper 插件接 GPT-3/4（自备 key） | 全屏 zenware 鼻祖（注释段落、写作目标） |
| Texts | 停更 | Windows/macOS | 买断约 $19–30（已死） | 闭源 | 纯 WYSIWYG（不露源码，底层存 Markdown） | 原生+Pandoc 导出管线 | 无 | "Markdown 界的 Word"（2018 停更，安静死亡） |
| CuteMarkEd | 停更 | Windows/Linux | 免费 GPL | 开源（约 1.5k star） | 双栏分屏+同步滚动 | C++/Qt+Discount(C)+Qt WebKit | 无 | 2015 年就带 Mermaid/数学的先驱（死于 Qt WebKit 废弃） |
| MdCharm | 停更 | Windows/Linux | 免费 BSD-3 | 开源 | 双栏分屏，多标签 | C++/Qt | 无 | Markdown Extra/MultiMarkdown 双引擎可切（被遗忘） |
| Haroopad | 停更 | 三平台 | 免费 GPL-3.0 | 开源（约 1.7k star） | 双栏分屏+同步滚动，多布局 | node-webkit+CodeMirror+marked | 无 | "编辑器即发布工具"：约 100 种服务嵌入语法+一键发布（2015 停更） |
| Abricotine | 停更 | 三平台 | 免费 GPL-3.0 | 开源（约 2.6k star，已归档） | 行内就地渲染（inline preview 折中路线） | Electron+CodeMirror | 无 | 分屏与 WYSIWYG 之外的第三条路（死于 nodeIntegration 安全债） |
| Moeditor | 停更 | 三平台 | 免费 GPL-3.0 | 开源（约 4.1k star，已归档） | 读/写/预览三模式切换 | Electron+自研 moemark | 无 | 以"素雅颜值"出圈的学生团队项目 |
| Remarkable | 半死亡 | Linux | 免费 MIT | 开源（约 2k star） | 双栏分屏实时预览 | Python+GTK+WebKitGTK | 无 | GNOME 生态双栏老将（同步滚动坏了多年未修） |
| Springseed | 停更 | Linux | 免费 MIT | 开源 | 笔记列表+编辑/预览切换 | CoffeeScript+Atom Shell | 无 | 17 岁开发者的高颜值 Linux 笔记（2014 后停更） |
| Laverna | 停更 | Web+Electron 桌面 | 免费 MPL-2.0 | 开源（约 9.2k star） | 分屏/预览/无干扰三模式 | JS(Backbone)+Pagedown+SJCL 加密 | 无 | "开源版 Evernote"（官方自认死亡，死于同步） |
| Boostnote | 停更 | 三平台 | Legacy 免费开源；后转 SaaS | 开源 GPL-3.0（约 17k star，已归档） | 源码编辑+预览，另有代码片段笔记 | Electron+React+CodeMirror | 无 | 程序员笔记（死于 CSON 专有格式+强行 SaaS 化，服务 2025 关停） |
| MarkPad | 停更 | Windows | 免费 MS-PL | 开源（约 1.4k star） | 双栏分屏+多标签 | .NET/WPF+内嵌浏览器 | 无 | Metro 风+博客/Jekyll 发布（社区周项目无长期 owner） |
| Yu Writer | 停更 | Windows/macOS | 免费+Pro 约 ¥100/设备 | 闭源 | 源码+预览，多标签，Read Mode | 未知跨平台框架 | 无 | 永远停在 Beta 的 Typora 挑战者 |

### 表 4：开源笔记 / 知识库（04 号文档）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| Joplin | 开源知识库 | Win/macOS/Linux/iOS/Android/终端 | 应用免费 AGPL-3.0；Joplin Cloud 2.99€/月起 | 开源（约 55.7k star） | 源码+分屏预览（CM6）/富文本（TinyMCE）双编辑器 | Electron+React；移动 RN；CM6+TinyMCE | 官方无内置（Cloud AI beta）；插件 Jarvis（GPT/Claude/Gemini/Ollama，语义检索+对话）、NoteLLM 等 | 开源笔记的同步方案最全者（多后端+E2EE） |
| Logseq | 开源知识库 | 全平台+Web | 免费 AGPL-3.0；Sync 长期 Beta（捐赠者） | 开源（约 44k star） | 大纲块编辑，块级"点击进源码、失焦渲染" | ClojureScript+Electron/Capacitor，自研块编辑器 | 官方无内置；社区插件（gpt3-openai、ollama-logseq 等） | 大纲双链笔记；"文件转数据库"大重写的信任危机样本 |
| SiYuan（思源笔记） | 开源知识库 | 全平台+Docker | 本体免费 AGPL-3.0；订阅 148 元/年；功能买断 64 元 | 开源（约 45.3k star） | 块级实时渲染所见即所得（.sy 私有存储，md 为导入导出） | Go 内核+TS 前端（Electron 壳），自研 Lute 引擎+Protyle 编辑器 | 内置：OpenAI 兼容 API（可自定 Base URL），续写/总结/翻译/润色 | 中文块编辑器手感天花板，两人团队养活项目 |
| Trilium / TriliumNext | 开源知识库 | 三平台+服务器版 | 完全免费 AGPL-3.0 | 开源（约 36.9k star） | CKEditor 5 富文本 WYSIWYG（非 md 原生），代码笔记 CodeMirror | Electron+Node（TS 化重构中） | 曾内置完整 LLM（OpenAI/Anthropic/Ollama+向量检索），v0.102.0 起因维护成本移除，转 MCP/插件 | 无限层级笔记树+属性+脚本的个人信息平台 |
| AppFlowy | 开源知识库 | 全平台 | 免费 AGPL-3.0；Cloud Pro $12.5/人/月；AI 附加包 | 开源（约 74.1k star） | Notion 式块编辑 WYSIWYG+斜杠命令 | Flutter（全端 UI）+Rust 核心，非 Electron | 深度内置且是付费点：云端前沿模型附加包+完全离线本地 AI（Vault） | 开源 Notion 替代，"本地 AI 作为付费功能"的定价创新 |
| Anytype | 开源知识库 | 全平台 | 免费+会员制（Plus/Pro/Ultra） | 源码开放（Any Source Available License，非 OSI） | 块编辑 WYSIWYG，对象/类型/关系模型 | Electron+TS 前端+Go 中间件（anytype-heart）+自研 CRDT any-sync；移动端原生 Swift/Kotlin | 无深度内置生成；走 MCP Server+本地 API 基础设施路线 | 本地优先+E2EE 的对象化笔记，开源阵营颜值标杆 |
| Notesnook | 开源知识库 | 全平台+Web | 免费+Essential $1.67/月起 | 全栈 GPL-3.0（含服务器，约 14.3k star） | 富文本块式 WYSIWYG（加密数据库存储） | React+Electron+RN，编辑器 TipTap(ProseMirror) | 无官方内置 | "连服务器都开源"的消费级 E2EE 笔记 |
| Standard Notes | 开源知识库 | 全平台 | 免费档+Productivity $90/年起 | 开源 AGPL-3.0（约 6.6k star） | 纯文本/md 源码+预览/Super 块编辑器三体系 | Electron+React；Super 基于 Meta Lexical | 无内置（隐私定位） | 加密至上的长期主义笔记（被 Proton 收购的善终样本） |
| Outline | 开源知识库 | Web SaaS+Docker 自托管 | BSL 1.1（非 OSI）；云版约 $10/月起 | 源码可得（约 39.8k star） | ProseMirror 富文本 WYSIWYG+全量 md 快捷输入+斜杠命令 | Node+React+TS+MobX | AI Answers：基于工作区文档的语义检索问答（云版/授权版） | "漂亮的团队 wiki"，md 快捷输入手感标杆 |
| Memos | 开源知识库 | 自托管 Web（Docker） | 完全免费 MIT，无付费服务 | 开源（约 61.7k star） | 纯 Markdown 源码输入+卡片流渲染（时间线优先） | Go 后端+React/TS 前端 | 无内置；社区经 API 自建 | 微博式闪念捕捉做到极致（60k+ star） |
| SilverBullet | 开源知识库 | 自托管 Web/PWA | 完全免费 MIT | 开源（约 5.7k star） | CodeMirror 6 实时渲染混合模式（类 Live Preview） | TS+CM6+Preact；v2 服务器 Rust；Space Lua 脚本 | 社区插件 silverbullet-ai（OpenAI/Gemini/Ollama 等，AI 面板+语义搜索） | "页面即程序"的极客个人空间（md 文件+内存索引） |
| Dendron | 开源知识库 | VS Code 扩展 | 免费 Apache-2.0 | 开源（约 7.5k star） | VS Code 源码编辑+分屏预览 | TypeScript（VS Code API） | 无 | 层级命名法 PKM；VC+开源笔记失败样本（仅维护模式） |
| Foam | 开源知识库 | VS Code 扩展 | 免费 MIT | 开源（约 17.3k star） | VS Code 源码编辑+预览 | TypeScript（VS Code API） | 无（可与 Copilot 共存） | wiki 链接+反链+图谱的最小 PKM 闭环 |
| Athens Research | 开源知识库 | 桌面（Electron）+Web Demo | 免费 EPL-1.0 | 开源（约 6.3k star，已停维护） | Roam 式大纲块编辑+双链+斜杠命令 | ClojureScript+Electron+Datascript 图数据库 | 无 | VC 融资开源 Roam 替代的完整反面样本 |
| AFFiNE | 开源知识库 | 全平台+Docker | 核心 MIT；Cloud Pro $6.75/月；AI 附加 $8.9/月；终身 $499.99 | 开源（约 70.6k star） | Page 块编辑+Edgeless 无边界白板双形态一键切换 | TS+自研 BlockSuite（Yjs CRDT）+Electron | 内置付费：续写/改写/总结、文档生成思维导图与幻灯片、白板 AI 绘图 | "一份数据、文档与白板双视图"的形态创新 |
| Docmost | 开源知识库 | 自托管 Web+云版 | 核心 AGPL-3.0，企业功能商业授权 | 开源（约 21.1k star） | TipTap 富文本 WYSIWYG+md 快捷输入 | TS（NestJS+React），协作 Yjs | 未知（未见内置生成） | 开源 Confluence/Notion 替代（空间+权限+协作） |
| Blinko | 开源知识库 | 自托管 Web+Tauri 客户端 | 免费 GPL-3.0 | 开源（约 10.8k star） | Memos 式卡片流+md 源码输入 | TS+Tauri（Rust） | 内置且是卖点：AI RAG 检索问答、AI 标签，模型自配（含 Ollama） | "轻笔记+自带 RAG"对 Memos 模式的 AI 升级 |
| Flatnotes | 开源知识库 | 自托管 Web（Docker） | 完全免费 MIT | 开源（约 3.2k star） | 原始 md 源码/所见即所得双模切换 | Python(FastAPI)+Vue | 无 | "无数据库——就是一个平面 md 文件夹" |

### 表 5：闭源 / 商业笔记与文档应用（05 号文档，AI 信息并入 08 号文档描述）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| Notion | 商业笔记 | 全平台+Web | 免费+Plus $10/人/月；AI 并入 Business $20；Agents 按积分计费 | 闭源 | 块编辑器 WYSIWYG，md 仅为输入语法糖+导出格式 | Electron 壳+React，自研 contenteditable 块模型 | 最全形态：改写/续写/问答/Research Mode/Meeting Notes/多模型 Agents（GPT-5、Claude Opus 等），仅 Business+ | 块编辑器范式定义者；导出保真差是原罪 |
| Obsidian | 商业笔记 | 全平台 | 核心免费（商用 $50/年可选）；Sync $4/月起；Publish $8/月 | 本体闭源（插件生态开源，约 4000–5800 个插件） | 源码/Live Preview/阅读三态一键切换 | Electron+CodeMirror 6；移动 Capacitor | 官方零内置；插件 Copilot/Smart Connections/Text Generator（OpenAI/Anthropic/Ollama）；官方发 obsidian-skills 教外部 Agent 读开放格式 | "file over app"：本地 md+插件生态之王 |
| Craft | 商业笔记 | Apple 全家+Win/Android/Web | Starter 免费+Plus $8/月（年付约 $4.8） | 闭源 | 块式 WYSIWYG，md 快捷输入但完全隐藏语法 | Apple 端原生 Swift/Mac Catalyst（WWDC 标杆案例）；自研同步 | Craft Assistant：端侧 Apple Foundation Models 免费+本地 Llama+云端三档配额+BYOK；Execute/Explore 双权限模式；支持 MCP | 原生性能+设计打磨的"最漂亮文档应用" |
| UpNote | 商业笔记 | 全平台 | $1.99/月或终身买断 $39.99 | 闭源 | 富文本 WYSIWYG+md 快捷输入（隐藏符号） | Electron+Firebase 云 | 无内置 | 2 人团队的平价终身买断笔记 |
| Simplenote | 商业笔记 | 全平台 | 完全免费 | 客户端开源 GPLv2（同步后端闭源） | 纯文本 md 源码+手动切换预览 | Electron+React；macOS/iOS 原生客户端开源可读 | 无 | 零摩擦极简同步笔记（2026-03 官宣停止积极开发） |
| RemNote | 商业笔记 | 全平台+Web | 免费+Pro 约 $6–8/月+AI 附加 $10/月 | 闭源 | 大纲块编辑器实时渲染+md 快捷输入 | Web 栈+Electron 壳 | AI 生成闪卡、AI Tutor、测验解释（credits 计费） | "笔记即闪卡"的学习科学工具 |
| Heptabase | 商业笔记 | 全平台+Web | $11.99/月（年付 $8.99），无免费版；终身 $659 | 闭源 | 卡片内实时渲染 md WYSIWYG+无限白板双层 | Electron+React+ProseMirror；移动 RN | 有（按档位 credits），非核心卖点 | 白板卡片式视觉思考；"闭源但全库一键导出 md"信任策略 |
| Tana | 商业笔记 | Web+桌面+移动捕捉 | 免费档+Plus/Pro（约 $8–18/月） | 闭源 | 大纲块编辑+supertag（标签即数据库） | Web(React)+桌面壳，数据云端 | 最激进之一：会议纪要 agent（60 语言）、多模型切换、AI 字段填充 | AI-native 结构化笔记；md 导出近乎摆设的反面教材 |
| Roam Research | 商业笔记 | Web+Electron 壳 | $15/月或 $165/年，无免费版 | 闭源 | 大纲块编辑，块聚焦显源码（私有方言） | ClojureScript+DataScript 图数据库 | 无原生 AI（靠社区扩展） | 双链/块引用开创者；高价+停滞被免费追随者吃掉 |
| Capacities | 商业笔记 | 全平台+Web | 免费+Pro $9.99/月 | 闭源 | 块编辑实时渲染+md 快捷输入，对象组织 | Vue 3+TS+Tailwind+桌面壳 | Pro：读笔记上下文问答、联网搜索、图像分析、属性填充；AI 预算+自带 Key | 对象化笔记；md 导出保真（front matter+相对链接）全类标杆 |
| 语雀 | 商业笔记 | Web+桌面+移动 | 免费+个人会员 ¥99/年 | 闭源（编辑器"将开源"未兑现） | 富文本 WYSIWYG+md 快捷输入（私有 Lake 格式） | React+Electron+Node(Egg.js)，fork Slate 自研 | 已上线 AI 帮写/总结（阿里系模型），非核心卖点 | 中文"知识库+目录树"写书感；私有格式+宕机的反面教材 |
| wolai（我来） | 商业笔记 | Web+桌面+移动 | 免费+专业版（历史 ¥98–158/年） | 闭源 | Notion 式块编辑 WYSIWYG+md 快捷输入 | Web 自研块编辑器+Electron | 被钉钉收购后 AI 投入在钉钉侧 | 中文 Notion 追随者；免费版限制过紧+被收购边缘化 |
| 飞书文档 | 商业笔记 | 全平台 | 个人/小团队免费；商业版按席位 | 闭源 | 块编辑 WYSIWYG+md 快捷输入（`/` 斜杠菜单） | Web 自研块编辑器+Electron 系客户端 | 内置飞书 AI（豆包系）：写作/润色/总结/问答/妙记 | 企业协同文档；官方把"导出 md"定位为交给 AI 的格式 |
| Reflect / Reflect Open | 商业笔记 | macOS/iOS/Web | 主产品 $10/月无免费版；Reflect Open 免费 MIT | 主产品闭源；Reflect Open 开源（约 1.3k star） | 实时渲染极简笔记流（每日笔记+反链）；Open 版围绕本地 md 文件夹 | Web 栈壳；Open 为本地优先新代码库 | GPT-4 写作助手、语音转录、chat with notes、AI 反链建议；Open 版可自带 Key | E2EE+快；Open 版战略转向与我们定位几乎一致 |
| Amplenote | 商业笔记 | 全平台+Web | 免费+Pro 约 $5.84/月起 | 闭源 | 富文本+md 输入 | Web 技术栈 | Ample Agent（AI 助手） | Jots→Notes→Tasks→Calendar 流水线+Task Score 算法排序 |
| FlowUs（息流） | 商业笔记 | Web+桌面+移动 | 个人免费+专业版年费；小组版（5 人内）免费 | 闭源 | 块编辑 WYSIWYG+md 快捷输入 | Web 自研块编辑器+桌面壳 | AI 曾长期公测，全量节奏未知 | 文档+多维表+网盘的国产性价比 Notion |

### 表 6：Web 在线编辑器与嵌入组件（06 号文档）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| StackEdit | Web 通用 | 浏览器（PWA 可离线） | 免费 Apache-2.0（赞助约 $5/年解锁服务端导出） | 开源（约 23k star） | 双栏分屏+精确 Scroll Sync，编辑区样式化语法高亮 | Vue+自研 cledit 内核+markdown-it | 无 | 老牌全能在线编辑器（2019 后半停更） |
| Dillinger | Web 通用 | 浏览器 | 完全免费 MIT | 开源（约 8.3k star） | 双栏分屏+scroll sync+Zen 模式 | Node+Monaco | 无 | "打开即写、无账号"+五大云盘 OAuth 导入写回 |
| HackMD | Web 协作 | 浏览器 SaaS+API+MCP | 免费+Prime $5/席/月（年付）+企业版 | 闭源（开源版为 HedgeDoc/CodiMD） | 双栏分屏，仅编辑/双栏/仅预览三视图 | Web SaaS（CodiMD 系 Node+CodeMirror 5+OT） | 编辑器内无 AI；战略定位"人与 AI Agent 的共享上下文层"（REST API+官方 MCP Server） | 实时协作 md 平台（多光标、建议编辑、版本时间线） |
| HedgeDoc (CodiMD) | Web 协作 | 自托管（Docker/Node） | 免费 AGPL-3.0 | 开源（约 7.3k star） | 双栏分屏，View/Both/Edit 三档 | Node+CodeMirror 5；2.0 重写为 React+NestJS | 无 | 自托管协作笔记（6 档权限模型、Slide 模式） |
| Editor.md | 嵌入组件 | 浏览器组件 | 免费 MIT | 开源（约 14.3k star） | 双栏分屏+密集工具栏 | CodeMirror+jQuery+marked | 无 | jQuery 时代国民组件（停更逾十年，反面教材） |
| Vditor | 嵌入组件 | 浏览器组件（各框架可用） | 免费 MIT | 开源（约 11.2k star） | 一个内核三模式：WYSIWYG/IR 即时渲染/SV 分屏 | TS+Lute 引擎（Go 编译到 JS，AST+源码映射） | 无内置 | 国产实现里最接近 Typora 的组件，中文排版优化 |
| markdown-nice (mdnice) | 公众号排版 | Web+Chrome 插件+客户端 | 基础免费+会员+主题市场 | 开源版 GPL-3.0（已停更；商业产品在运营） | 双栏：源码+公众号效果仿真预览 | React+Ant Design | 有 AI 助手辅助写作（细节未知） | 公众号排版+"主题即商品"市场化设计 |
| doocs/md | 公众号排版 | Web+浏览器扩展+CLI+Docker | 完全免费 WTFPL | 开源（约 13.1k star） | 双栏：左 md 右微信图文实时预览 | Vue 3+Vite+CodeMirror，纯前端可静态部署 | 本类最完整：DeepSeek/OpenAI/通义/混元/火山方舟+默认免费通道，AI 侧边栏对话+引用全文+自定义快捷指令+生图 | 公众号排版开源标杆（多图床+多平台一键发布） |
| readme.so | 结构化生成 | 浏览器 | 免费 MIT | 开源（约 4.6k star） | 分节模板拖拽组装+实时预览三栏 | Next.js+Tailwind+react-markdown | 无 | 用积木消解 README 白纸恐惧 |
| Markdown Live Preview | Web 通用 | 浏览器单页 | 免费 MIT | 开源（约 900 star） | 纯双栏分屏 | Monaco+marked+DOMPurify | 无 | 2011 年至今的单一用途预览页 |
| Bangle.io | Web 本地优先 | 仅 Web（PWA，Chromium 系） | 免费 AGPL-3.0 | 开源（约 1.2k star） | Notion 式 WYSIWYG，底层始终是本地 .md 文件 | ProseMirror（自研 banger-editor）+React+File System Access API | 无 | "富文本体验+纯文本存储"的 Web 对应物 |
| Milkdown | 嵌入框架 | 浏览器框架 | 免费 MIT | 开源（约 11.7k star） | Typora 式即时渲染 WYSIWYG（插件化） | ProseMirror+remark/unified 双层架构 | 框架无内置（可插件接入） | "一切皆插件"的 WYSIWYG-Markdown 教科书方案 |
| TOAST UI Editor | 嵌入组件 | 浏览器组件 | 免费 MIT | 开源（约 18k star） | md 分屏/WYSIWYG 双模式互切 | ProseMirror 双模式+自研 ToastMark 增量解析器 | 无 | 企业级双模式组件（2022 后事实停更） |
| EasyMDE | 嵌入组件 | 浏览器组件 | 免费 MIT | 开源（约 3k star） | 单栏源码+工具栏，可分屏/全屏 | CodeMirror 5+marked | 无 | "接管一个 textarea 即完成集成"（SimpleMDE 社区续命分支） |
| wechat-format | 公众号排版 | 浏览器 | 免费 | 开源 | 双栏微信预览 | Vue 纯前端 | 无 | 公众号排版先驱（已停更并指引迁移到 Quaily） |
| Md2All | 公众号排版 | 浏览器 | 全部免费 | 未知 | 双栏实时预览 | 未知 | 无 | 一键排版复制到公众号/知乎/CSDN 等 N 平台 |

### 表 7：IDE / 终端 / 插件生态（07 号文档）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| VS Code | IDE | 三平台 | 免费（二进制闭源，源码 Code-OSS MIT） | 源码开源 | 源码+分屏预览（同步滚动+当前行指示） | Electron+Monaco+markdown-it | GitHub Copilot 深度集成（有免费档），Copilot LLM API 开放给扩展 | 开发者 Markdown 编辑的"功能基线"（粘贴链接/图片落盘/重命名改引用） |
| Markdown All in One | VS Code 扩展 | VS Code | 免费 MIT | 开源（约 3.3k star，下载约 1400 万） | 源码编辑增强 | TypeScript | 无 | 快捷键/列表续行/TOC 的标配全家桶 |
| Markdown Preview Enhanced | VS Code 扩展 | VS Code | 免费 NCSA | 开源（约 2k+4k star） | 源码+增强分屏预览 | TS+markdown-it 系+Puppeteer 导出 | 无 | 图表（Mermaid/PlantUML/Vega）与导出能力天花板，含可执行 Code Chunk |
| Front Matter CMS | VS Code 扩展 | VS Code | 免费 MIT（赞助驱动） | 开源（约 2.5k star） | 源码+仪表盘式 CMS 面板 | TS+React（webview） | 调用 Copilot LLM API 生成标题/描述/标签，开放接自有 API | 把 VS Code 变成静态站点 Headless CMS（front matter 表单化） |
| markdownlint | 扩展+CLI | VS Code/CI | 免费 MIT | 开源（约 1.3k+5k star） | lint 诊断（约 60 条规则，30 条可自动修复） | JavaScript | 无 | "Markdown 也需要 linter" |
| JetBrains Markdown 插件 | IDE | JetBrains 全家 | 插件免费捆绑（IDE 另计） | 插件 Apache-2.0 | 源码+分屏实时预览 | JVM(Kotlin/Java)+JCEF 预览 | AI Assistant（2025.1 起有免费层）+Junie agent | IDE 内 md 基建：代码块语言注入+表格行列控件+Pandoc DOCX |
| Zed | 编辑器 | macOS/Linux/Windows | 编辑器免费开源（AI 用量订阅） | 开源 GPL-3.0 为主（约 87k star） | 源码+预览面板 | Rust+自研 GPUI（GPU 加速，无 Electron） | 最激进：Agent Panel、开源 Zeta 边推预测模型、ACP 接外部 agent、Subtle Mode | 高性能原生编辑器标杆；预览排版弱反衬"美"是空档 |
| Sublime Text + MarkdownEditing | 编辑器+插件 | 三平台 | ST $99 买断；插件免费 MIT | ST 闭源/插件开源（约 3.3k star） | 纯源码+写作专用配色方案 | C++/Python 原生自绘 | 无官方（社区 LSP-copilot） | 早年定义"程序员 Markdown 写作"视觉的老将 |
| markdown-preview.nvim | Neovim 插件 | Neovim | 免费 MIT | 开源（约 7.9k star） | 源码在 Neovim，浏览器实时同步预览 | Vim 插件+本地 Node 服务 | 无 | 装机量最大的 nvim 预览方案（2022 后停更） |
| peek.nvim | Neovim 插件 | Neovim | 免费 MIT | 开源（约 1k star） | webview 窗口预览+同步滚动 | Deno（默认沙箱） | 无 | 用 Deno 沙箱解决预览权限顾虑的现代替代 |
| render-markdown.nvim | Neovim 插件 | Neovim | 免费 MIT | 开源（约 4.8k star） | 行内渲染（anti-conceal：仅光标行还原源码） | Lua+tree-sitter+extmark 虚拟文本 | 无（是 nvim AI 插件渲染回复的事实标准） | 混合编辑模式的最优交互原型 |
| markview.nvim | Neovim 插件 | Neovim | 免费 Apache-2.0 | 开源（约 3.6k star） | 行内渲染+hybrid+splitview 多模式 | Lua+tree-sitter | 无 | 多标记语言（md/LaTeX/Typst/AsciiDoc）统一渲染 |
| obsidian.nvim | Neovim 插件 | Neovim | 免费 Apache-2.0 | 开源（社区 fork 约 2k star） | 源码编辑增强（兼容 Obsidian 库） | 99% Lua | 无（配 avante.nvim 等通用 AI 插件） | 在 Neovim 里复刻 Obsidian 工作流 |
| Emacs markdown-mode | Emacs | 全平台 | 免费 GPL-3.0 | 开源（约 1k star，近 20 年维护） | 源码+markup hiding 半渲染+外部预览 | Emacs Lisp | 无内置（生态 gptel/copilot.el） | 行内渲染鼻祖；"对内 Org、对外 Markdown" |
| Glow | 终端 | 三平台 CLI/TUI | 免费 MIT | 开源（约 26k star） | 只读渲染（TUI 浏览+分页） | Go（Glamour+Bubble Tea） | 无 | 终端排版美学标杆；样式=可分发的主题 JSON |
| mdcat | 终端 | 三平台 CLI | 免费 MPL-2.0 | 开源（约 2.4k star，已归档） | 只读渲染（cat 式输出） | Rust | 无 | 终端保真渲染（行内真图片、OSC 8 链接） |
| Frogmouth | 终端 TUI | 三平台 | 免费 MIT | 开源（约 3.2k star，停更） | 只读浏览（导航栈/历史/书签） | Python+Textual | 无 | 终端里的 Markdown"浏览器" |
| inlyne | GUI 查看器 | 三平台 | 免费 MIT | 开源（约 1.3k star） | 只读渲染+live reload | Rust+comrak+wgpu 自绘（无浏览器内核） | 无 | "markdown 界的 Preview.app"轻量预览窗 |
| Marksman | LSP | 三平台二进制 | 免费 MIT | 开源（约 3.3k star） | 语言服务器（补全/跳转/反链/重命名/死链诊断） | F#(.NET) | 无 | 把 Markdown 知识库当代码库对待的 LSP |
| Prettier | 格式化 CLI | 全平台 | 免费 MIT | 开源（约 52k star） | 武断格式化器（proseWrap 三态） | JS+remark-parse | 无 | "保存即格式化"的事实标准 |
| mdformat | 格式化 CLI | 全平台 | 免费 MIT | 开源（约 800 star） | CommonMark 合规格式化+AST 等价性安全检查 | Python+markdown-it-py | 无 | 格式化前后语义不变的工程标杆 |
| Pandoc | 转换 CLI | 全平台 | 免费 GPL-2.0+ | 开源（约 45.5k star） | 文档转换器（约 40+ 输入 × 60+ 输出） | Haskell | 无 | 全行业导出外包对象，"不要自研导出" |

### 表 8：AI 写作工具与 AI 集成（08 号文档；Notion/Craft/Obsidian/iA Writer/Ulysses/Bear 的 AI 已并入前表）

| 名称 | 类别 | 平台 | 价格/授权 | 是否开源 | 编辑模式 | 技术栈 | AI | 一句话定位 |
|---|---|---|---|---|---|---|---|---|
| Lex | AI 写作 | Web+iOS | 免费约 30 次检查/月+Pro $18/月（年付约 $12/月） | 闭源 | 极简富文本（类 Google Docs），支持 md 语法输入 | Web 应用 | `+++` 续写、批改式 Checks（可自定义检查项）、Ask Lex 全文对话、多模型切换 | "AI 编辑而非 AI 代笔"的严肃写作工具 |
| Type | AI 写作 | Web+桌面（可离线） | 免费限量+Premium $29/月（同类最贵） | 闭源 | WYSIWYG 文档编辑+md 快捷键 | Web 技术 | 一键成稿、Type Chat、Inline Commands、Document Review 整篇统改、每文档挂 5 个知识源 | 形态最完整的 AI 原生文档编辑器 |
| Mem | AI 写作 | macOS/Win/iOS/Web | 免费 25 条/月+Pro $12/月 | 闭源 | 轻量富文本+md 输入 | Web+桌面壳 | 全库 RAG 对话、Smart Write、Voice Mode、自动标签/关联（反组织理念） | "AI Thought Partner"自组织笔记 |
| Reor | AI 写作 | 三平台 | 完全免费 AGPL-3.0 | 开源（约 8.6k star，2026-03 归档） | 类 Obsidian 实时渲染 md 编辑 | Electron+React+Ollama+Transformers.js+LanceDB | 全本地：本地 LLM+本地 embedding+RAG 问答+自动关联，离线可用 | "AI 思考工具应默认本地跑模型"的实验（停更警示） |
| NotebookLM | AI 研究 | Web/iOS/Android | 免费+Google AI 订阅捆绑 | 闭源 | 非编辑器：来源接地研究工具 | Google 内部栈 | source-grounded RAG+带引用回答+Audio Overview 播客/导图/闪卡 | "回答必须带出处"的范式代表 |
| Cursor | AI IDE | 三平台 | Hobby 免费+Pro 约 $20/月 | 闭源（VS Code fork） | 纯源码+预览分栏 | Electron | Tab 幽灵补全、Cmd+K 选中改写（diff 预览）、Agent 批量读写本地 .md、.cursor/rules 规则文件 | "Agent 直接读写本地纯文本"被验证的最强范式 |
| Sudowrite | AI 小说 | Web | $10–44/月（积分制可滚存） | 闭源 | 富文本章节编辑器（非 md） | Web | 小说全流程：续写/Rewrite/Describe/Brainstorm+Story Bible 结构化记忆+自研 Muse 模型+多候选卡片 | 小说向 AI 工具箱 |
| Novelcrafter | AI 小说 | Web（离线 PWA） | 软件订阅 $4–20/月，AI 一律 BYOK | 闭源 | 章节/场景富文本+md 语法输入 | Web | BYOK 任意模型（含本地）、Codex 世界观词条自动注入上下文 | "软件钱和模型钱分开"的 BYOK 模式代表 |
| Elephas | AI 助手 | macOS/iOS 原生 | $9.99/月起（三档） | 闭源 | 非编辑器：系统级 AI（任意 App 选中处理）+Super Brain 知识库 | 原生 Apple 应用 | 全局改写/续写/总结、20+ 格式本地知识库问答带引用、可全离线本地模型、上传前脱敏 28 类实体 | Mac 原生系统级 AI 的独立开发样本 |
| Ritemark | AI 编辑器 | macOS/Windows | 完全免费 MIT | 开源（小型新项目） | WYSIWYG 可视化 md+内置 AI 终端 | 桌面壳+Web 编辑器（推测 Electron/Tauri 类） | 内置终端直接跑 Claude Code/Codex/OpenCode CLI Agent（统一审批策略）+定时 Agent 任务 | "开源+本地 md+外部 Agent"的直接原型 |
| VMark | AI 编辑器 | 桌面（macOS 等） | 免费 ISC 开源 | 开源（约 417 star） | WYSIWYG/Source Peek/源码三模式 | Tauri v2+React+Tiptap(ProseMirror)+CodeMirror 6 双内核 | 原生内置 MCP server：Claude Desktop/Claude Code/Codex/Gemini CLI 直连读写文档 | "AI 集成方式是协议而非聊天框" |

> 注：08 号文档还提及同细分的 Markra（开源 WYSIWYG+AI diff 预览）与 mdedit.ai（离线优先技术文档向），以及 Obsidian AI 三大插件（Copilot 约 7.4k star、Smart Connections 约 5.3k star、Text Generator 约 2k star），说明"开源 + 本地 Markdown + AI"细分正被快速填补。

### 表 9：技术内核与组件速览（09 号文档，列结构从简：名称｜类型｜许可｜对我们的适配结论）

| 名称 | 类型 | 许可 | 适配结论（一句话） |
|---|---|---|---|
| CodeMirror 6 | Web 源码编辑内核 | MIT | Obsidian Live Preview 底座；混合渲染最成熟 Web 方案，原生只能经 WKWebView |
| ProseMirror | Web 富文本内核 | MIT | 语义树模型，md 仅是序列化格式，源码保真弱；适合 Notion 式产品 |
| Tiptap | ProseMirror 封装框架 | MIT 核心+Pro 付费 | 富文本为主的产品首选封装；斜杠命令/气泡菜单交互可借鉴 |
| Milkdown | WYSIWYG-md 框架 | MIT | PM+remark 双层，md 一等公民；WKWebView 集成成本最低的全家桶 |
| Lexical / lexical-ios | Meta 编辑器框架 | MIT | md 非核心模型；lexical-ios 证明"JS 语义+原生 TextKit 渲染"可行（参考价值大于复用价值） |
| Slate | 富文本框架 | MIT | 常年 beta、IME bug 多，不推荐 |
| Monaco | VS Code 内核抽取 | MIT | 面向代码、体积大，写作类产品几乎无人选 |
| markdown-it | JS 解析器 | MIT | 分屏预览端标配（VS Code 同款）；无完整源位置树，不适合混合渲染 |
| remark / unified | JS AST 处理器 | MIT | 带精确源位置，适合 lint/格式化/导出流水线 |
| cmark-gfm | C 参考实现（GitHub 维护） | BSD 系 | GFM 事实标准；可直接进 SPM，Apple swift-cmark 即其分叉 |
| pulldown-cmark / comrak | Rust 解析器 | MIT/BSD 系 | Tauri/Rust 路线首选；Swift 路线下无必要（FFI 成本） |
| swift-markdown + swift-cmark | Apple 官方 Swift 解析 | Apache-2.0 | 原生路线最佳解析选择：SourceRange 精确、值类型 AST、官方维护 |
| Down / Ink / SwiftDown | 老一代 Swift 组件 | MIT | 均已停更/归档，不要引入新项目 |
| TextKit 2 / NSTextView | 原生文本引擎 | 系统 | 原生混合渲染唯一官方地基；架构好评实现坑多（降级陷阱、滚动估算） |
| STTextView | TextKit 2 文本视图 | GPLv3+商业双授权 | 源码模式几乎开箱即用；许可是唯一考量点，也是 TextKit 2 避坑百科 |
| Runestone | iOS 自绘编辑组件 | MIT | UIKit 专用；"自绘布局绕开 TextKit"的重要参考数据点 |
| Highlightr / HighlighterSwift | 代码高亮（hljs 封装） | MIT | 编辑区代码块高亮的务实起步选择 |
| swift-markdown-ui / Textual | SwiftUI 只读渲染 | MIT | 预览面板/AI 回复渲染候选；前者已维护模式、后者太新 |
| SwiftUI TextEditor（macOS 26） | 官方 SwiftUI 输入组件 | 系统 | 2026 起可做轻样式 md 编辑；语法隐藏与行内 widget 仍做不到 |
| WKWebView 预览方案 | 系统 WebKit | 系统 | 预览/导出/Mermaid/KaTeX 的唯一现实运行环境；限定用途强烈建议采用 |
| KaTeX / MathJax | 数学渲染 | MIT/Apache-2.0 | 编辑场景 KaTeX 快、导出学术 MathJax 全；均需 JS 环境；原生行内可用 SwiftMath |
| Mermaid | 文本图表 | MIT | 事实标准、强需求；只能浏览器环境跑，离线打包约数 MB |
| highlight.js / Shiki | 代码高亮 | BSD-3/MIT | 预览端 Shiki 观感好；编辑区实时高亮两者都不理想 |
| tree-sitter / SwiftTreeSitter | 增量解析框架 | MIT | 编辑区实时高亮的性能正解；与 swift-markdown 全量 AST 互补 |
| Neon (ChimeHQ) | 解析→TextKit 属性胶水 | BSD-3 | 解决"解析结果到文本属性"最脏管线的中间件 |
| CodeEditSourceEditor | AppKit 编辑组件 | MIT | macOS-first；又一个"自研布局绕 TextKit 2"案例 |
| Muya (Mark Text) | Web 混合渲染内核 | MIT（2026-05 归档） | 研究"自研混合渲染"的最完整公开教材；也证明自研 Web 内核拖垮社区项目 |
| swift-markdown-engine (nodes-app) | 原生 TextKit 2 混合渲染引擎 | Apache-2.0 | 生态里唯一开源的"原生 Typora/Bear 式行内混合渲染"；建议 fork 锁版本作为起点 |

---

## 二、功能全集清单

> 使用说明：以下功能点从 01–09 号文档中穷举而来，是功能规划的核心素材。每条标注 1–3 个代表产品（取文档中该功能的最佳/最典型实现者）。带 ★ 的条目在各文档小结中被点名为"基线预期"或"必修课"。

### 2.1 编辑体验

- ★ 逐段/块级实时渲染（光标进入展开源码、离开即渲染）——Typora（开创者）、Mark Text、SiYuan Protyle
- ★ 语法标记淡化/隐藏式混合渲染（Live Preview / anti-conceal）——Obsidian、Bear、render-markdown.nvim（仅光标行还原源码，被验证为手感最优）
- 语法字符保留的内联样式化渲染（不隐藏标记）——Caret、Apostrophe、StackEdit
- 纯源码编辑+语法高亮/淡化着色——iA Writer、MarkEdit、Sublime MarkdownEditing
- 双栏分屏预览+同步滚动——MWeb、MacDown、StackEdit（Scroll Sync 精确绑定口碑最佳）
- 预览自动滚动到当前编辑位置——MarkdownPad、Marked 2（自动滚到最近编辑处）
- 编辑/预览/阅读多态一键切换——Obsidian（Cmd+E 三态）、Vditor（WYSIWYG/IR/SV）、VMark（WYSIWYG/Source Peek/源码）
- 块编辑器+斜杠命令——Notion、Craft、AppFlowy
- 大纲（outliner）块编辑——Logseq、Roam Research、Tana
- 打字机滚动（当前行垂直居中）——iA Writer、Byword、Typora
- 焦点/专注模式（行/句/段粒度聚焦）——iA Writer、ghostwriter（行/句/段/三行可配）、Typora
- 全屏禅模式/无干扰模式——WriteMonkey（默认形态）、Dillinger（Zen）、Abricotine
- Hemingway 模式（禁用退格强迫向前写）——ghostwriter、Apostrophe
- 多光标编辑——MarkEdit、Zettlr、Notable（Monaco）
- 标题/列表/代码折叠——Bear、MarkEdit、Emacs markdown-mode（TAB 循环可见性）
- Vim / Emacs / Sublime 键位——Zettlr、Inkdrop、HedgeDoc
- ★ 命令面板——iA Writer 8（⇧⌘P）、Obsidian（Cmd+P）、VNote（Universal Entry）
- @ / 斜杠快速插入菜单——Mark Text、Notion、Outline（斜杠菜单标杆）
- 浮动选区工具栏（选中才出现）——MarkPad、Milkdown crepe、Apostrophe（悬浮工具条）
- 表格图形化编辑（拖拽行列/对齐按钮）——Typora、JetBrains（行列标记控件）、Zettlr 4（全新表格编辑器）
- ★ 列表智能续行/编号自动修复——Markdown All in One、Caret、Zed
- ★ 语义化快捷键（Cmd+B/I、升降标题、勾选任务）——Markdown All in One、Sublime MarkdownEditing、Bear
- ★ 粘贴 URL 自动成链接——VS Code（`pasteUrlAsFormattedLink`）
- ★ 图片粘贴/拖拽自动落盘并插入相对路径——VS Code、Typora、obsidian.nvim
- ★ 链接/文件路径/标题锚点自动补全（`[[` 与 `](` 触发）——VS Code、Marksman、Foam
- ★ 死链/失效锚点诊断——VS Code（markdown.validate）、Marksman
- ★ 文件/标题重命名自动更新全库引用——VS Code、Marksman、Dendron（批量重构）
- Find All References / 反向链接查询——VS Code、Marksman、Foam（反链面板带上下文预览）
- 自动配对/智能标点——Typora
- 打字手感/动效打磨（滚动动画、金色光标、捏合调字号）——Paper、Byword、Caret
- 打字音效——Paper
- 打开即写零摩擦捕捉（0 秒进入输入态）——Drafts、Simplenote、Memos
- omnibar 搜索即新建（搜不到即回车创建）——nvUltra、FSNotes、Flatnotes（search-first 入口）
- 文本暂存架（拖放暂存"舍不得删"的文字）——Highland（The Shelf、Scratchpad）
- write-only 模式（只能写不能删改）——Paper
- 段落注释语法（`//` 草稿注释）——WriteMonkey
- 段落上下移动——Texts
- 自动保存与文件备份——ghostwriter、EasyMDE、MarkdownPad
- 多标签页/多窗口/分屏编辑——Taio、VNote、Bangle.io
- 编辑器内可执行代码块（运行结果内联）——Znote（JS 代码块）、Markdown Preview Enhanced（Code Chunk）、JetBrains（gutter 运行按钮）
- 中英文混排自动加空格/中文排版调校——MiaoYan、Vditor（Lute 引擎）、SiYuan
- 大文档/大库性能——Bear（9.4 万词 55ms）、MarkEdit（百万行流畅、10MB 秒开）、FSNotes（10k+ 文件流畅）
- 拼写检查/语法风格检查——Zettlr（LanguageTool 内置）、Ulysses（20+ 语言校对）、QOwnNotes（LanguageTool+Harper+LSP）
- Markdown Lint（实时波浪线+一键修复）——markdownlint、QOwnNotes（rumdl）
- ★ 保存即格式化（表格对齐、风格统一）——Prettier（VS Code/Zed 内置）、mdformat（AST 等价性校验）
- 结构化选区扩展（Smart Select）——VS Code
- 移动端扩展键盘行——1Writer、Taio
- 引用式链接自动管理（链接归集文末）——Sublime MarkdownEditing
- 语音听写/录音入笔记——NotePlan（录音转写）、Mem（Voice Mode）
- 阅读性着色（按句子复杂度）——Zettlr（Readability 模式）
- 词性语法高亮（名/动/形着色）——iA Writer（独家）

### 2.2 语法与渲染

- ★ CommonMark + GFM 全家（表格、任务列表、删除线、自动链接）——Typora、MarkEdit（严格 GFM 零私有语法）、cmark-gfm（事实标准）
- 脚注——iA Writer（MultiMarkdown）、Zettlr、Ulysses
- ★ LaTeX 数学公式（行内/块级）——Typora（MathJax v4）、Mark Text（KaTeX）、iWriter Pro
- ★ Mermaid 图表——Typora、Marked 2、CuteMarkEd（2015 年即支持的先驱）
- PlantUML / Graphviz / WaveDrom / flowchart 等多图表——VNote、Markdown Preview Enhanced、SiYuan（含甘特图/五线谱）
- ECharts / Chart.js / Vega-Lite 图表——MWeb、markdown-preview.nvim、Mark Text（vega-lite）
- ABC 记谱/五线谱——StackEdit、Vditor、HedgeDoc
- 代码块语法高亮——Bear（150+ 语言）、Haroopad（71 种）、Highlightr（185 种语言 89 主题）
- ★ 代码块语言注入（块内补全/高亮/可运行）——JetBrains（完整语言支持）、Zed（tree-sitter 二次高亮）
- ★ [[wiki 链接]] 双向链接+反向链接——Obsidian、Logseq、Foam
- 块引用/块嵌入（transclusion）——Roam（开创者）、Logseq、SiYuan
- 文件嵌入/子文档拼接——iA Writer（Content Blocks）、Markdown Preview Enhanced（@import）、Foam（笔记嵌入）
- ★ YAML front matter——Notable（元数据架构）、Typora、Front Matter CMS（表单化编辑）
- TOC 自动生成与保存时更新——Marked 2、Markdown All in One、Editor.md
- callout / admonition 彩色框——Obsidian、render-markdown.nvim
- CriticMarkup 审阅标记——Marked 2、Sublime MarkdownEditing
- Fountain 剧本语法——Highland、Marked 2
- 多方言支持/解析引擎可切换——MarkdownPad（4 种引擎）、ReText（markups 抽象层）、Drafts（MultiMarkdown 6 与 cmark-gfm 双解析器可选）
- 自有方言扩展——Ulysses（Markdown XL 28 标记）、Bear（Polar Bear）、Roam（私有块语法）
- 高亮 `==`、上下标等扩展语法开关——Typora、swift-markdown-engine
- emoji 补全（`:` 触发）——Mark Text、HedgeDoc、Caret
- 约 100 种互联网服务嵌入语法（YouTube/SoundCloud 等）——Haroopad
- 内嵌 HTML 渲染+XSS 过滤/消毒——Dillinger、Vditor（XSS 过滤）、Markdown Live Preview（DOMPurify）
- 多标记语言渲染（reST/AsciiDoc/Textile/Typst/Org）——ReText、markview.nvim、Emacs（Org-mode 对照）
- ★ 增量解析+源码位置映射（混合渲染的技术前提）——Lute（Vditor/SiYuan）、ToastMark（TOAST UI）、tree-sitter/Lezer
- 语法特性逐项开关——StackEdit（方言配置面板）、Typora、Vditor
- Jekyll/front matter 渲染兼容——MacDown、MarkPad（Jekyll 站点支持）
- 公式在公众号的兼容转换——Md2All、doocs/md
- 图片懒加载/行内图片渲染——Vditor、FSNotes、Abricotine

### 2.3 文件与组织

- ★ 本地 .md 文件夹为唯一真相源（file over app、永不锁定）——Obsidian、MiaoYan、Notable/Flatnotes（"文件夹即数据"）
- 任意文件夹皆可为库/多库并开——nvUltra、FSNotes、MWeb（外部文件夹模式）
- 文库/笔记本层级管理——Ulysses（Sheet/Group）、Joplin、MWeb（分类树+一文多分类）
- 标签系统（含嵌套标签）——Bear（#嵌套标签#）、Notable（面包屑多级）、QOwnNotes（无限层级）
- 智能文件夹/筛选器——Yu Writer、Ulysses（关键词/筛选器）
- front matter 元数据/结构化字段——Notenik（每集合自定义字段模板）、Capacities（属性系统）、Amplenote（标签/日期转 YAML）
- ★ 全文搜索（跨文件）——FSNotes（闪电搜索）、Obsidian、VS Code（Cmd+T 全工作区标题搜索）
- OCR 搜索（图片与 PDF 内文字）——Bear Pro、Joplin
- 知识图谱可视化（全局/局部）——Obsidian、Foam、Zettlr
- 每日笔记/日记流——NotePlan（自动生成日/周/月/年笔记）、Logseq、Craft
- 任务管理/待办（勾选、状态、优先级）——NotePlan、Amplenote（Task Score 算法排序）、Inkdrop（任务状态流）
- 日历集成/时间块——NotePlan（Apple/Google 日历+拖拽时间块）、Amplenote（双向同步）、Tana
- 闪卡/间隔重复（SRS）——RemNote（`::` 语法即卡片）、Logseq、SiYuan
- PDF 导入与标注——Logseq、RemNote（图像遮挡）、Heptabase（高亮自动成卡）
- 白板/无限画布——Obsidian Canvas（开放 JSON Canvas 格式）、AFFiNE（Edgeless）、Heptabase
- 数据库/多维表视图——Notion（表格/看板/日历/时间线）、AppFlowy、Obsidian Bases / SiYuan 属性视图
- 笔记加密/私密 Vault——FSNotes（AES-256）、Bear、Notesnook（应用锁 Vault）
- ★ 版本历史/快照/文件恢复——Joplin（笔记修订历史）、SiYuan（数据快照回滚）、Obsidian（File Recovery）
- Git 版本控制/Git 集成——FSNotes（内置 Git）、VNote 4（任意 Git 远端）、Markdown Monster
- 网页剪藏（浏览器扩展）——Joplin、Bear、Notesnook
- 附件管理——Notable、Joplin、Notesnook
- 模板系统/模板中心——Notion、NotePlan（模板引擎）、readme.so（分节模板组装）
- 层级命名法组织（`a.b.c` 点分隔）——Dendron
- 对象类型系统（类型+关系+多视图）——Anytype、Capacities、Tana（supertag 标签即数据库）
- 笔记克隆/一文多处——Trilium（笔记克隆）、Heptabase（卡片多白板同步）、MWeb（一文多分类）
- 导入迁移（Evernote/Notion/Obsidian 等）——Joplin（ENEX）、Notesnook（导入器矩阵）、RemNote
- ★ 兼容 Obsidian vault 存量生态——obsidian.nvim、Reor（与 vault 并行使用）、Foam
- 剪贴板管理器——Taio（iCloud 同步+小组件）
- 收藏/置顶/旗标——Notable、Simplenote、Yu Writer
- 多工作区隔离——Bangle.io、Drafts（Workspaces）、QOwnNotes（多笔记文件夹）
- 孤立笔记/占位链接检测——Foam
- 文档统计（字/词/句/段、码字速度、可读性）——ghostwriter（会话统计）、Marked 2（可读性指数）、iWriter Pro
- 写作目标（字数/截止日）——Ulysses、Zettlr（项目字数目标）、WriteMonkey
- 番茄钟/写作冲刺——Zettlr、Highland（Sprints）

### 2.4 导出与发布

- HTML 导出（含带内联样式富文本）——MacDown、Marked 2（可内嵌资源单文件）、doocs/md（内联样式不丢格式）
- ★ PDF 导出——Typora、Marked 2、Markdown Preview Enhanced（反面教训：依赖无头 Chrome 脆弱缓慢，原生应走系统 WebKit/PDFKit）
- DOCX / Word 双向——Ulysses、iA Writer（双向导入导出）、JetBrains（Pandoc 菜单化封装）
- ePub——Ulysses、MWeb（整分类导出）、iWriter Pro
- LaTeX / XeLaTeX——iWriter Pro、Zettlr、Texts
- ODT / RTF——ReText、MdCharm、Byword
- 图片导出（长图/PNG/JPG）——MWeb、MiaoYan、Bear
- ★ Pandoc 集成（40+ 输入 × 60+ 输出）——Zettlr（捆绑）、Texts、Marked 2（自定义处理器外接）
- 导出模板/样式定制——iA Writer（模板系统）、StackEdit（Handlebars）、Glow（样式 JSON）
- 一键发布博客（WordPress/Ghost/Medium/Micro.blog）——Ulysses、MWeb、Markdown Monster（MetaWeblog 管理）
- 静态博客/静态网站生成——MWeb Pro（独有卖点）、Notenik、Dendron（Next.js 发布）
- 发布为公开网页/数字花园——Obsidian Publish、Craft（分享为网页）、Standard Notes（Listed 匿名博客）
- ★ 公众号/知乎等中文平台排版复制——doocs/md、mdnice、Vditor（"复制到公众号/知乎"适配）
- 多平台文章一键分发（公众号/知乎/掘金/CSDN 等）——doocs/md（文章同步助手）、Md2All、Haroopad（WordPress/Evernote/Tumblr）
- 幻灯片/演示模式——HackMD/HedgeDoc（reveal.js Slide 模式）、MiaoYan（妙言 PPT）、Markdown Preview Enhanced
- Book 模式（多篇组织成书）——HackMD、语雀（知识库目录树）
- 导出时剥离元数据——iA Writer（Authorship 块导出自动剥离）
- 全库一键导出/自动定时导出——Heptabase（全库 md）、Capacities（定时导出备份，front matter+相对链接保真标杆）
- AI 朗读音频导出——Type
- 以邮件发送文档——Haroopad
- 剪贴板富文本互转（复制为富文本/粘贴转 md）——Paper、Zed（预览复制自动转回 md）、MarkPad（贴图转 md）
- 打印支持——Highland Pro（订阅过期仍可打印导出）
- 命令行导出工具——MacDown（`macdown` CLI）、doocs/md（md-cli）、Bear（BearCLI）

### 2.5 同步与协作

- ★ iCloud Drive 文件夹同步（零自建成本）——iA Writer、1Writer、MiaoYan（靠 iCloud/坚果云/Dropbox 客户端）
- Dropbox / WebDAV / OneDrive / 网盘目录同步——1Writer（多后端）、StackEdit（Google Drive/Dropbox/GitHub/CouchDB）、WriteMonkey
- 专有云同步（CloudKit/Firebase/自研）——Bear（CloudKit）、NotePlan（纯文本+CloudKit）、UpNote（Firebase）
- ★ 端到端加密同步——Joplin（多后端可选 E2EE）、Notesnook（XChaCha20-Poly1305）、Standard Notes / Inkdrop（自研 CouchDB 系）
- 自托管同步服务器——Joplin Server、Notesnook（服务器开源）、Inkdrop（自托管 CouchDB）
- ★ Git 远端即同步后端（零服务器成本）——VNote 4（HTTPS+钥匙串+自动冲突解决）、Foam（Git 工作流）、StackEdit（GitHub 同步）
- 官方云同步订阅（开源应用的商业闭环）——Obsidian Sync（E2EE+版本历史）、Joplin Cloud、SiYuan（148 元/年含 8GB）
- P2P / CRDT 本地优先同步——Anytype（any-sync+备份节点）、AFFiNE（Yjs CRDT）、Notion（离线模式 CRDT 合并）
- 实时多人协同编辑（多光标）——HackMD、HedgeDoc、Outline
- 评论/批注/建议编辑——HackMD（行内评论+suggest edit）、飞书文档（块级评论+划词评论）、Outline
- ★ 权限模型——HedgeDoc（freely→private 六档）、HackMD（一个下拉框定权限）、Docmost（空间+群组权限）
- 版本时间线（命名版本/对比 diff/回滚）——HackMD、Joplin、SiYuan
- 团队空间/共享工作区——Notion、Anytype（共享空间+聊天）、HackMD
- 离线优先/完全离线可用——Obsidian、Bangle.io、Anytype
- 同步冲突解决——VNote（内置冲突解决）、StackEdit（DiffMatchPatch 合并）
- GitHub App 双向同步（笔记内 pull/push）——HackMD、MarkPad（直接打开/保存到 GitHub）
- 协作反面教训（自建同步翻车）——Laverna（死于同步）、Joplin（大库冲突丢笔记抱怨）、Logseq Sync（常年 Beta）

### 2.6 个性化

- ★ 主题即 CSS 文件+官方主题画廊——Typora（theme.typora.io，上百款社区主题）、Marked 2（自定义 CSS 热载）、Obsidian（主题即 CSS，数百主题）
- 数据化主题（JSON 定义样式）——NotePlan（JSON+正则匹配任意语法元素）、Glow（渲染样式=可分发 JSON）
- 主题/插件市场（社区投稿生态）——SiYuan（集市）、mdnice（主题市场分免费/付费）、Obsidian
- 深浅色/跟随系统/多主题——MWeb（11 浅+21 深）、Apostrophe（亮/暗/羊皮纸三主题）、Mark Text（Tkaixiang fork 内置 33 款）
- 自定义字体/行距/字距/版心宽度——Paper（排版个性化极深）、UpNote、Moeditor
- 自研品牌字体——iA Writer（Mono/Duo/Quattro，开源）
- 界面布局预设/可拆装面板——QOwnNotes（首启即选布局+工作区保存）、VNote、Joplin
- 自定义快捷键——MarkFlowy、CuteMarkEd、MdCharm
- ★ 插件系统（JS/API）——Obsidian（约 4000–5800 个插件）、Joplin（数百款）、Inkdrop（100+，仿 Atom）
- 脚本引擎/自动化动作——Drafts（JS 动作+社区目录）、QOwnNotes（QML/JS+脚本市场）、Trilium（前后端脚本+REST API）
- 嵌入式脚本语言统一扩展面——SilverBullet（Space Lua 统一脚本/模板/查询/Widget）
- CSS/JS 注入自定义——MarkEdit（CSS/JS/CodeMirror 扩展）、Obsidian（CSS snippets）、Editor.md（插件+主题自定义）
- 工具栏逐项自定义——Vditor（36+ 项均可配快捷键/图标/子菜单）、EasyMDE
- 多语言界面 i18n——QOwnNotes（60+ 语言）、Haroopad（14 种）、MarkFlowy
- 可换 App 图标——Bear、Drafts
- 写作专用配色方案（区别于代码模式）——Sublime MarkdownEditing、iA Writer（词性着色）
- 背景图/情绪化主题——ghostwriter（自定义背景图+主题编辑器）、Apostrophe（羊皮纸）
- 语法元素显示粒度可调（隐藏/显示标记）——QOwnNotes（语法符号可选隐藏）、Emacs markdown-mode（markup hiding 开关）
- 自定义语法定义——Drafts（Pro 自定义语法）、ReText（Python 模块扩展标记）、Marked 2（自定义处理器）

### 2.7 AI（依据 08 号文档 28 种交互形式清单扩展，含各文档补充）

**生成与改写类**
- ★ 选中改写浮层菜单（预览后替换/插入/丢弃）——Notion AI、Apple Writing Tools（Ulysses/Bear 借力）、Elephas
- 续写/幽灵文本补全（Tab 接受；散文场景需可关/延迟）——Cursor Tab、Sudowrite Write、Lex（`+++` 触发）
- 空行/斜杠命令唤起生成——Notion（空行+space）、Craft、Type（inline commands）
- 一键成稿/草稿生成——Type（Generate Draft）
- 整文档级 AI 编辑（全篇统一口径修改）——Type（Document Reviews）
- ★ diff 预览后应用（逐块接受/拒绝+检查点回滚）——Cursor（Cmd+K）、Zed（逐 hunk+回滚）、Obsidian Smart Composer / Markra
- 多候选卡片输出（逐张采纳）——Sudowrite
- AI 翻译/摘要/润色——MarkFlowy、SiYuan、Notion
- AI 生图并嵌入文档——Markdown Monster（DALL-E-3/gpt-image-1）、doocs/md
- AI 元数据生成（标题/摘要/标签建议）——Front Matter CMS、Jarvin（Joplin Jarvis 自动标签）、Notion

**对话与检索类**
- ★ 文档感知对话侧栏（自动携带当前文档上下文）——Type Chat、Obsidian Copilot、doocs/md（引用全文+自定义快捷指令）
- @ 引用笔记/文件夹/网页作为上下文——Znote、Cursor、NotePlan（选笔记为上下文）
- ★ 全库 RAG 问答（向量检索）——Mem Chat、Obsidian Copilot（Vault QA）、Reor / Blinko
- 来源接地问答+引用跳转原文——NotebookLM、Elephas（Super Brain）
- AI 语义搜索——Notion（Ask Notion 跨外部源）、Outline（AI Answers）、Joplin Jarvis
- 相关笔记被动推荐（本地 embedding、零提示词）——Smart Connections（本地 bge-micro-v2 零配置）、Mem、Reflect（AI 反链建议）

**检查与标注类**
- 批改式检查 Checks（清单式呈现、可自定义检查项）——Lex Checks、Ulysses 内置校对
- 本地非 LLM 风格检查（冗词/套话划除）——iA Writer（Style Check、词性 Syntax Highlight）
- ★ AI 文本标注/作者身份追踪（开放规范）——iA Writer Authorship（Markdown Annotations 规范已开源，尚无第二家开源编辑器实现）

**Agent 与协议类**
- Agent 模式（多步执行/直接读写本地文件）——Notion Agent（最长 20 分钟任务）、Cursor Agent、Zed Agent Panel
- Execute/Explore 双权限模式（直接执行 vs 提案确认）——Craft Assistant
- 编辑器内嵌 CLI Agent 终端——Ritemark（Claude Code/Codex/OpenCode 统一审批）
- ★ 编辑器自带 MCP server（外部 AI 客户端连入读写）——VMark、QOwnNotes、Bear 2.8 / Craft / Anytype / HackMD
- Agent Skills / 开放格式文档（教外部 Agent 用自家格式）——obsidian-skills（MIT）、Cursor `.cursor/rules`
- 定时/后台 Agent 任务（日报/周报）——Ritemark、Notion Custom Agents
- 项目级规则文件（写作规范约束 AI）——Cursor（.mdc 规则）、obsidian-skills

**模型与商业类**
- ★ 系统级 AI 借力（Apple Intelligence Writing Tools，零成本端侧）——Ulysses/Bear、MarkEdit（ai-writer 扩展）、Craft（端侧模型免费）
- ★ 本地模型运行（Ollama/LM Studio/内置下载，完全离线）——Reor（Ollama+LanceDB 全本地）、MarkFlowy、Craft（本地 Llama）
- ★ BYOK 自带 API Key/任意 OpenAI 兼容端点——Novelcrafter（AI 一律 BYOK）、Markdown Monster、Znote（"按供应商成本用 AI，零抽成"）
- 多模型切换/Auto 自动路由——Notion（GPT-5/Claude/o3+Auto）、Tana（按任务切换）、doocs/md（多家国产模型+默认免费通道）
- 免费额度+付费解锁 BYOK——Znote（29.90€ 买断解锁）、doocs/md（默认免费 AI 服务）
- AI credits 计量制——RemNote（$10/月 2 万 credits）、Sudowrite（积分滚存）、Craft（按档配额）
- AI 锁进高价档的反面教材——Notion（AI 并入 $20 Business 档引发抱怨）
- 开源补全模型——Zed（Zeta/Zeta2，权重与数据集公开）
- 垂直场景自训模型——Sudowrite（Muse 小说模型）

**记忆与多模态类**
- 结构化长期记忆（人物/世界观/设定库自动注入）——Sudowrite（Story Bible）、Novelcrafter（Codex 词条）、Type（Notes/知识源）
- 语音转结构化笔记（要点/待办提取）——Mem（Voice Mode）、Notion（AI Meeting Notes）、NotePlan（录音转写）
- 会议纪要 agent（入会转录+结构化输出）——Tana（60 语言、会后约 7 分钟出纪要）、Znote（会议录音摘要）
- 多模态产出（播客/思维导图/闪卡/幻灯片）——NotebookLM（Audio Overview）、AFFiNE（文档生成导图/PPT）、RemNote（AI 闪卡）
- 自动组织（自动打标签/自动关联）——Mem、Joplin Jarvis、Blinko

**隐私工程类**
- ★ 隐私工程（上传前脱敏/最小上传/不训练承诺/可整体关闭）——Elephas（28 类实体本地脱敏）、Craft（最小数据+不训练）、Ulysses（可整体禁用 AI）
- 全程本地检测不上传——iA Writer（Authorship 本地识别）、Smart Connections（本地 embedding 无需 API key）

### 2.8 其他（系统集成 / 工程 / 运营）

- QuickLook 插件（Finder 直接预览 md）——iWriter Pro
- 命令行工具/CLI 伴生——Bear（BearCLI）、MacDown、doocs/md（md-cli）
- URL scheme / x-callback 自动化——Drafts、1Writer、Paper（Callback URL）
- REST / gRPC API——Memos（API 优先带来第三方客户端生态）、HackMD（月调用超 100 万次）、Outline
- LSP 支持（编辑器接语言服务器）——QOwnNotes（Marksman 补全/诊断）、Marksman 本身（十余编辑器通吃）、Helix（默认内置 Marksman）
- ★ 图床上传抽象层（多后端可插拔）——doocs/md（GitHub/OSS/COS/七牛/R2 等+自动压缩）、Typora（PicGo/自定义命令）、Taio（内置图床）
- 智能图片处理（相对路径管理/Base64 转换）——MarkFlowy、VS Code（copyFiles.destination 目录规则）
- 网页多格式粘贴（paste-as）——Texts、MarkPad（剪贴板贴图转 md）
- 演讲者视图+计时器——HackMD（S 键）
- 无障碍——MathJax（无障碍最佳）、Lexical（强调可靠性与无障碍）
- ★ 渲染安全沙箱/内容隔离——peek.nvim（Deno 沙箱）、SilverBullet（Web Worker 沙箱插件）、Abricotine（反面教材：nodeIntegration 漏洞致死）
- 便携模式（U 盘即走）——QOwnNotes、WriteMonkey
- 无遥测/无数据收集——MiaoYan、Znote（默认无遥测）、Bangle.io
- 应用签名与公证——VNote（DMG 已签名）、MarkFlowy（反面教材：未签名需 xattr 放行）
- 双因素认证——Standard Notes
- RSS 输出——Memos
- 微信收集箱——SiYuan（订阅附带）
- Readwise / Kindle 集成——Reflect
- 第三方客户端生态——Memos（MoeMemos 等）
- 只读阅读器形态（编辑与阅读解耦）——Glow、inlyne（live reload 外置预览窗）、Frogmouth（浏览器式导航栈/书签）
- `gh 用户/仓库` 零克隆读 README——Frogmouth
- 嵌入组件形态（textarea 替换/框架集成）——EasyMDE、Vditor、Milkdown（headless+crepe 双形态）
- SEO 检查/媒体仪表盘（博客场景）——Front Matter CMS
- 开源治理与可持续（多维护者/发版节奏/停更迁移出口）——ReText（极小维护面 15 年）、Mark Text（单点维护 burnout 反面）、wechat-format（停更时给出迁移出口的负责任做法）
- 商业模式配套（GitHub 免费+MAS 付费支持版）——FSNotes、MiaoYan
- 教育/公益优惠——SiYuan（教育 6.4 折）、语雀（教育公益免费）、HackMD（Prime 教育相关折扣见官网）

---

## 三、焦点对比

### 3.1 编辑模式三大流派

**流派一：源码 + 分屏预览（第一代，正在过时但仍有生态位）**

- 代表产品：MacDown、MWeb、iWriter Pro、Inkdrop、Joplin、ghostwriter、ReText、QOwnNotes、HackMD/HedgeDoc、VS Code/JetBrains（IDE 阵营整体）、MarkdownPad（历史标杆）。
- 体验特征：左源码右预览（或预览窗独立），"写"与"看"割裂，靠同步滚动（StackEdit 的精确 Scroll Sync、MarkdownPad 的 LivePreview 定位是体验底线）缝合；实现成本最低（解析器+WebView 即可），方言兼容与导出保真最好控制，程序员接受度高。
- 现状判断（02/03/06 号文档共识）：分屏在活跃产品中只剩工具型/老牌产品坚持；02 号文档明言"分屏预览起步等于落后十年"。但它有两个仍然成立的变体：一是 Marked 2 / inlyne 的"编辑与预览彻底解耦"（预览是独立能力）；二是 MiaoYan 的"纯净源码 + ⌘\ 一键 60fps 分屏"——以原生实现成本换可靠性的务实折中。
- 中间态补充：在纯源码与实时渲染之间存在一条被反复验证的过渡带——"语法样式化/淡化但不隐藏"（iA Writer、Caret、Apostrophe、StackEdit 编辑区），以及 Neovim 生态两年验证出的 anti-conceal 行内渲染（render-markdown.nvim：全文渲染态、仅光标行还原源码），07 号文档认为后者是"混合编辑模式的最优交互原型"。

**流派二：Typora 式实时渲染（当前用户预期的基准线）**

- 代表产品：Typora（开创者）、Mark Text（最忠实开源复刻）、Obsidian Live Preview（CM6 装饰式实现，源码/实时/阅读三态）、Bear（隐藏标记式）、SiYuan Protyle（中文手感天花板）、Ulysses/NotePlan（标记淡化混合）、Zettlr/SilverBullet（CM6 半渲染）、MarkFlowy/Znote/Typedown/Vditor IR（追随者）。
- 体验特征："所见即所得"与"纯文本可控"合二为一：光标所在块展开源码、离开即渲染；表格/公式/图表用浮层或图形化编辑；通常保留整篇源码模式作为逃生舱（Typora Cmd+/、Obsidian Cmd+E）。底层仍是 Markdown 文件，导出零转换损耗——这是它与块编辑器的本质区别。
- 工程代价（01/09 号文档共识）：这是三条路里胶水代码最重的。Web 侧有 CM6 Decoration（Obsidian 路线）与 contenteditable 自研（Typora/Muya）两条成熟路径；原生侧公认极难——Bear 为此自研 C++ 内核 Panda，MiaoYan 明确放弃，MarkEdit 干脆改用 CodeMirror，直到 2026-04 swift-markdown-engine（Apache-2.0）才出现首个开源的原生 TextKit 2 混合渲染实现。
- 结论：01–03、07、09 号文档一致把该模式列为新编辑器的"必修课"与用户预期锚点。

**流派三：Notion 式块编辑（笔记/协作应用的主流，但 Markdown 只是语法糖）**

- 代表产品：Notion（范式定义者）、Craft、AppFlowy、AFFiNE、Anytype、Capacities、语雀、wolai、飞书文档、FlowUs、UpNote、Notesnook、Outline/Docmost（ProseMirror/TipTap 系）；大纲变体：Roam、Logseq、Tana、RemNote、Athens。
- 体验特征：一切皆块，`/` 斜杠命令插入块类型，Markdown 退化为输入快捷方式（`#`+空格出标题）与导出格式；块可拖拽、可挂属性、可变数据库视图；上手门槛最低、协作与结构化能力最强。
- 系统性代价（05 号文档核心结论）：数据存私有块模型（Notion blocks、Lake、Any-Block、supertag 图），"导出保真度是全类别的阿喀琉斯之踵"——数据库变 CSV、多列丢失、块引用断链（Notion/Tana/Roam 尤甚）；做得最好的 Capacities（front matter+相对链接）与 Heptabase（全库一键 md）反而把"可导出"当卖点营销。
- 与前两派的关系：飞书官方把"导出 Markdown"定位为交给 AI 的格式、Notion 上线 Markdown Content API、Reflect 推出开源本地 md 的 Reflect Open——块编辑阵营正在向 Markdown 回流，反向印证"本地 md + 实时渲染"路线的长期正确性。

**三派对我们的取舍（各文档小结综合）**：交互对标流派二（逐段实时渲染为主态），保留流派一的整篇源码模式与"语法淡化不隐藏"可选态（照顾程序员），吸收流派三的斜杠命令与 Markdown 快捷输入（降低 Notion/飞书迁移成本），但数据层坚决不做块模型——本地 .md 文件为唯一真相源。

### 3.2 原生 vs Electron：分布与口碑差异

**阵营分布（按主类别统计文档收录产品）**

- 原生阵营（AppKit/UIKit/Swift/Catalyst）：几乎全部集中在 01 号 Apple 文档——iA Writer、Ulysses、Bear、Byword、MWeb、Marked 2、Highland、Taio、Drafts、1Writer、iWriter Pro、NotePlan、nvUltra、FSNotes、MiaoYan、Paper、MarkEdit（壳原生芯 CodeMirror）、MacDown、Notenik、Mou；商业笔记阵营仅 Craft（Catalyst，WWDC 标杆案例）与 Simplenote 的 mac 客户端；AI 阵营仅 Elephas；另有 Rust 自研 GPUI 的 Zed 与 C++/Python 自绘的 Sublime Text。
- 原生 Qt/GTK（跨平台"类原生"）：ghostwriter、Apostrophe、VNote、QOwnNotes、ReText、CuteMarkEd、MdCharm、Remarkable——04 号文档统计其收录的 19 个开源知识库中"仅 QOwnNotes 一个原生独苗"。
- Electron 阵营（数量绝对优势）：Typora、Mark Text、Zettlr、Inkdrop、Caret、Notable、Znote、Joplin、Obsidian、Notion、Logseq、SiYuan（壳）、Trilium、Anytype、Notesnook、Standard Notes、AFFiNE、Heptabase、Roam（壳）、UpNote、语雀、wolai、飞书（系）、VS Code、Cursor、Reor、Abricotine、Moeditor、Boostnote、Laverna 等。
- 新折中层：Tauri（MarkFlowy、Blinko、VMark，<20MB）、Flutter+Rust（AppFlowy）、NW.js/node-webkit（WriteMonkey WM3、Haroopad——已被时代淘汰的先例）。

**关键量化对比（09 号文档 2025–26 公开基准）**：安装包 Electron 普遍 80–150MB vs Tauri <10MB vs 原生通常 10–30MB（MarkEdit 约 4MB、MiaoYan 23MB）；空闲内存 Electron 常见 200–300MB vs Tauri 30–40MB；启动 Electron 1–2s vs 原生近即时；性能上限的原生实证是 Bear（9.4 万词《白鲸记》55ms 打开）。

**口碑差异（各文档论坛/社区反馈汇总）**

- Electron 的骂点高度一致：内存占用、启动速度、非原生观感与手感（HN 对 Obsidian 的长期争论、"用 IDE 写作太重"、Joplin/VS Code 的臃肿抱怨）；例外是刻意做性能优化者（Typora"比大多数 Electron 应用轻快"、Obsidian 刻意不用重前端框架）才免于"臃肿"骂名。
- 原生的口碑红利真实存在：Craft 靠"快 + 好看"拿下 Mac 年度应用；Bear/iA Writer 的手感是品类口碑基石；Zed 靠 Rust/GPU"零延迟手感"成为开发者第一理由。
- 但"原生 ≠ 好看"：Qt/GTK 阵营普遍"轻快但不好看"（VNote/QOwnNotes/ReText 的 UI 是最大槽点），Apostrophe 是唯一"原生且美"的例外；AppFlowy 的 Flutter 则"缺原生质感"。
- 结构性结论（02/04/09 号文档一致）："好看的一侧几乎全是 Electron，轻快的一侧普遍不好看"；跨平台阵营里"原生 + 好看"近乎无人做到，开源知识库领域"原生 macOS + 好看"几乎无人占位——这正是原生 macOS 单平台产品最大的市场空档。技术依赖上还有一条铁律（03 号文档）：依赖 Awesomium/Qt WebKit/node-webkit/旧 Electron 的产品全部被依赖的死亡拖垮，渲染内核必须选系统长期支持方案（WKWebView/TextKit）。

### 3.3 免费开源与付费产品的功能差距在哪

**付费产品领先的方面（差距集中区）**

1. 编辑手感与视觉打磨：实时渲染的细腻度（Typora 分块渲染、Bear 隐藏标记颗粒度、SiYuan 中文手感）、动效（Paper、Craft）、默认排版（iA Writer 字体体系、Craft"不排版也好看"）——开源阵营中只有 MiaoYan/Mark Text/Apostrophe 少数以颜值立身，Qt 系开源普遍"功能强但丑"（QOwnNotes、VNote），07 号文档指出连 Zed 的预览排版都被骂"标题层级不可见"。
2. 同步与多端：付费产品自带成熟同步（Bear CloudKit、Ulysses iCloud、UpNote Firebase、Obsidian Sync E2EE）与移动端；开源产品靠网盘/Git/自托管拼装（FSNotes iCloud 文件夹、VNote Git、Joplin 多后端），体验碎、冲突处理弱（Joplin 大库丢笔记、Logseq Sync 常年 Beta、Laverna 直接死于同步）；移动端更是开源重灾区（MiaoYan/MarkEdit/QOwnNotes/Trilium 无移动端，FSNotes iOS 明显弱于 Mac）。
3. 协作能力：实时协同、评论、建议编辑、权限体系几乎全在商业产品（Notion、飞书、HackMD、Outline 云版）；开源侧仅自托管的 HedgeDoc/Docmost/AFFiNE 可比，个人开源编辑器基本为零。
4. AI 的"开箱即用"深度：商业产品有托管推理与配额（Notion 多模型 Agents、Craft 三层模型、Tana 会议 agent）；开源产品普遍不自建云 AI（成本与维护黑洞，Trilium 内置后又移除即是教训），而以 BYOK/本地 Ollama/插件/MCP 提供——门槛更高但零抽成、更隐私。
5. 打磨与支持的持续性：付费收入换来持续迭代（Typora 买断后仍年更 3–4 版、Markdown Monster 十年）；免费开源的停更率触目惊心（03 号文档：star 数与存活无关，58k star 的 Mark Text 也停摆三年；8.6k star 的 Reor 两年归档）。

**开源免费阵营领先或反超的方面**

1. 数据自由与信任：纯 .md 文件、零锁定是开源阵营的立身之本（Notable/Flatnotes/SilverBullet/MiaoYan），付费阵营反而普遍私有格式锁定（Ulysses .ulyz、Bear SQLite、Notion 块模型、语雀 Lake、思源 .sy 亦被诟病）；05 号文档确认"导出保真度是商业块编辑器全类别的阿喀琉斯之踵"。
2. 扩展性与生态：脚本/插件/主题的开放程度开源占优（QOwnNotes 脚本市场、SilverBullet Space Lua、Joplin 数百插件），闭源产品中只有 Obsidian 以"闭源本体 + 开放插件 API"取得两全。
3. 知识库/双链领域整体反超：Logseq、SiYuan、Joplin、Foam、Trilium 等开源产品的功能面（双链、块引用、图谱、闪卡、SQL 查询）不输甚至超过商业对手，Roam（$15/月）正是被免费开放的追随者吃掉的。
4. 隐私与本地优先：无遥测、本地模型、E2EE 自托管（Notesnook 连服务器都开源、Anytype 本地加密）是开源可信度优势，也是 AI 时代的新护城河。
5. 价格本身：Typora $14.99 一次性买断已被视为口碑定价，订阅制（Ulysses/Inkdrop/NotePlan 约 $40–100/年）是全品类差评核心来源——免费开源天然站在用户情绪的正确一侧。

**结论（对我们的功能规划）**：免费开源与付费产品的差距不在功能清单的长度，而集中在四件"要花钱养人"的事上——手感打磨、同步、移动端、持续维护。我们的策略应是：用原生 macOS 把"手感与颜值"这一最大差距在开源阵营内补齐（这是差异化核心）；同步走 iCloud 文件夹 + Git 远端的零服务器方案回避开源同步陷阱；AI 走"Apple 端上模型免费兜底 + BYOK/Ollama + MCP 协议"的零成本三层架构；并用"MIT/宽松协议 + GitHub 免费 + MAS 付费支持版 + 多维护者治理"解决可持续性——这四条分别有 Craft/Bear、VNote/FSNotes、Craft/Znote/VMark、FSNotes/MiaoYan 的被验证先例。

---

## 附：本文档的三点使用提示

1. 表 1–8 合计收录约 120 款产品/工具，表 9 收录约 30 项技术内核与组件；查某一竞品的完整细节请回到对应编号的原始文档。
2. 第二部分功能全集共 8 组、约 220 个功能点，其中带 ★ 的约 30 项是各文档小结公认的"基线预期"，可直接作为 MVP 验收清单的候选池。
3. 第三部分三组对比的结论互相咬合：编辑模式选流派二（实时渲染）、技术栈选原生（补开源阵营最大短板）、功能差距用"原生手感 + 数据自由 + 协议化 AI"来打——这是九份文档指向的同一个定位空档：「原生 macOS + 简洁好看 + 开源免费 + 本地 Markdown + 协议化 AI」目前无人同时占据。
