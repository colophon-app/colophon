# 跨平台桌面 Markdown 编辑器（活跃维护中）

> 类别总体观察：本类别是 Markdown 编辑器竞争最激烈的赛道，Typora 以"逐段实时渲染"交互确立了体验标杆，之后几乎所有新产品（Mark Text、MarkFlowy、Znote 等）都在模仿或改良这一交互。技术栈高度两极分化：追求界面精致的产品几乎全部使用 Electron（Typora、Mark Text、Zettlr、Inkdrop、Joplin、Notable、Znote），追求轻量的则用 Qt/C++（VNote、QOwnNotes、ghostwriter）或新兴的 Tauri/Rust（MarkFlowy），但 Qt 系产品普遍在视觉精致度上明显落后。商业模式上，小额买断制（Typora $14.99、Znote 29.90€）被社区广泛接受，订阅制（Inkdrop）则持续遭受抱怨。AI 能力在 2024-2026 年快速渗透：新产品（MarkFlowy、Znote）把 AI 作为核心卖点，老牌开源项目（QOwnNotes、Joplin）通过脚本/插件 + 本地模型（Ollama）跟进，而标杆 Typora 至今没有官方 AI，全靠社区插件——这是明显的市场空档。注：Obsidian 属知识库类，详见 05 号文档；已停更的 Abricotine、Haroopad 等归 03 号文档；Apple 原生系（iA Writer、MarkEdit 等）归 01 号文档。

### Typora（本类别标杆，重点分析）

- **基本信息**：开发者 Abner Lee（个人开发者）｜平台 macOS / Windows / Linux｜价格：$14.99 一次性买断（不含税），1 个用户最多激活 3 台设备，15 天免费试用，30 天退款保证；无订阅、无捆绑；闭源商业软件｜官网 https://typora.io｜无公开源码仓库（闭源）｜维护状态：非常活跃——1.14（2026-07-19）、1.13（2026-04-03）、1.12（2025-09-19）、1.11（2025-08-16）、1.10（2025-02-15），保持每年 3-4 个大版本
- **收费模式转变（重点）**：2015 年以 free beta 形式发布，免费公测长达 6 年积累了庞大用户群；2021 年 11 月发布 1.0 正式版并转为 $14.99 买断制。这一"长免费期养成习惯 → 小额买断收割"的路径被证明非常成功：社区虽有"$15 对基础功能偏贵"的抱怨，但 HN 上 2026 年仍有大量用户称其为"最好的 Markdown 写作体验，甚至超过 Obsidian"，并点赞其一次性付费模式。买断制没有阻碍持续更新（1.0 之后已迭代到 1.14）
- **编辑模式（重点）**：真正的"实时渲染所见即所得"开创者——没有分屏预览，光标所在的块（段落/公式/表格/代码块）自动展开为 Markdown 源码，光标离开即渲染为最终排版，"所见即所得"和"纯文本可控"合二为一；另提供整篇源码模式（Cmd+/ 一键切换）作为逃生舱。表格是图形化编辑（拖拽调整行列、对齐按钮），公式块和 Mermaid 块是"输入源码 + 下方实时预览"的浮层交互。这套分块渲染交互是十年来被模仿最多、仍未被完全超越的设计
- **核心功能**：GFM 全家桶（表格、任务列表、删除线）、脚注、内联/块级 LaTeX 数学（1.13 起升级 MathJax v4）、Mermaid（v11.12）、代码高亮（CodeMirror 语法着色）、TOC、YAML front matter、上下标/高亮等扩展语法开关；导出 PDF / HTML / DOCX / ODT / LaTeX / EPUB / 图片等（部分依赖捆绑的 Pandoc 集成）；侧栏文件树 + 文库模式、跨文件全文搜索；图片粘贴自动复制到相对目录，可配置 PicGo/自定义命令上传图床（对中文用户生态友好）；无官方插件系统（社区有注入式的 typora-plugin、typora-copilot 项目）；大纲面板、打字机模式、专注模式、自动配对、智能标点。1.13 起官方发布了 VS Code / Cursor 的 "Open in Typora" 扩展，主动融入开发者工作流
- **UI 设计（重点）**：单栏极简布局（可开合侧栏），界面元素极少，全部注意力留给正文；主题系统 = 纯 CSS 文件——一个主题就是一个 .css（加可选资源文件夹），官方维护 theme.typora.io 主题画廊，社区贡献了上百款主题（GitHub 风、Newsprint 报纸风、学术风等），三平台共用同一套渲染引擎和主题，效果完全一致。这套"主题即 CSS"的设计把定制门槛降到了前端开发者人手可为的程度，是其社区生态的核心引擎；专注模式（淡化非当前段落）+ 打字机模式（当前行垂直居中）齐备。设计风格关键词：极简、留白、排版即界面
- **技术栈**：Electron（但普遍被评价"比大多数 Electron 应用轻快"），自研 Markdown 解析与分块渲染引擎（闭源，细节未公开）
- **AI 能力**：官方无任何内置 AI（截至 1.14）。社区插件 typora-copilot（开源，Snowflyt 开发）提供 GitHub Copilot 补全 + Copilot Chat 面板，支持三平台，但需要 Copilot 订阅、需 Node.js ≥ 20，且尚不支持 Ollama 本地模型（相关 issue 悬置中）。"标杆产品 + 无官方 AI"是本类别最大的空档
- **可借鉴点**：1）分块实时渲染交互是我们产品的必修课——尤其是"光标进入即展开源码、离开即渲染"的粒度控制，以及表格/公式/图表的浮层编辑；2）"主题即 CSS 文件 + 官方主题画廊"的低门槛主题生态，原生 macOS 应用可以用类似思路（CSS/JSON 主题描述 + 在线画廊）复制；3）定价心理学：长期免费积累口碑后小额买断，社区接受度极高——我们做开源免费 + 可选付费增值时可参考其口碑路径
- **不足**：闭源且开发者背景低调，部分用户有信任顾虑；无移动端、无同步，纯桌面单机；3 台设备限制；无官方插件/扩展 API，社区插件靠 hack 注入、随版本升级易失效；对超大文档（数万行）偶有性能抱怨；无版本历史

### Mark Text

- **基本信息**：开发者 Jocs（罗冉）及社区｜平台 Linux / macOS / Windows｜免费，MIT 协议开源｜官网 https://www.marktext.cc（新版迁移 Next.js）｜GitHub https://github.com/marktext/marktext，约 58.9k star（本类别开源项目最高）｜维护状态：经历长期停滞后复活——2022-03 的 v0.17.1 之后停更约 3 年，曾被广泛认为弃坑（衍生出 jacobwhall fork（已归档）、Tkaixiang 的 electron-vite 重构 fork 等），2025 年原仓库恢复维护：v0.19.0（2025-05-28）、v0.19.1（2025-06-06）、v0.20.0-rc（2025-07），进行了 pnpm monorepo 重构并修复嵌套列表、CJK 强调语法等兼容问题
- **编辑模式**：Typora 式逐段实时渲染 WYSIWYG（是最忠实的开源复刻），另有整篇源码模式；支持打字机模式、专注模式
- **核心功能**：CommonMark + GFM（表格、任务列表）、KaTeX 数学、Mermaid / flowchart / sequence / vega-lite 图表、emoji 补全、front matter；导出 HTML / PDF（无 DOCX，是长期短板）；侧栏文件树（文件夹即文库）；图片粘贴支持本地相对路径或 PicGo/SM.MS 上传；段落快捷菜单和 @ 快速插入菜单（斜杠命令的前身式交互）；无插件系统
- **UI 设计**：单栏极简，6 款官方主题（Cadmium Light、Material Dark、Graphite 等），Tkaixiang fork 内置 33 款主题（Dracula、Nord、Catppuccin、Tokyo Night 等）；界面风格干净、接近 Typora；源代码模式、打字机模式、专注模式齐备
- **技术栈**：Electron + Vue，自研编辑器内核 muya（把 Markdown 解析与实时渲染抽象成独立库，本意是供其他项目复用）
- **AI 能力**：无
- **可借鉴点**：1）muya 的思路——把"实时渲染内核"与应用壳分离，值得我们在架构上参考（内核可测试、可复用）；2）它证明了"开源版 Typora"存在巨大需求（59k star），但也证明了纯用爱发电难以为继——我们需要可持续的维护策略；3）@ 快速插入菜单是低成本高感知的编辑辅助
- **不足**：论坛/Reddit 常见抱怨集中在历史 bug（表格和列表编辑易错乱、曾有数据丢失报告）、无 DOCX 导出、停更三年伤了社区信任（大量用户已迁往 Typora/Obsidian）；恢复维护后能否重建信任待观察

### Zettlr

- **基本信息**：开发者 Hendrik Erz（学术背景，瑞典林雪平大学）｜平台 Windows / macOS / Linux｜免费，GPL-3.0 开源，靠捐赠支持｜官网 https://www.zettlr.com｜GitHub https://github.com/Zettlr/Zettlr，约 13.3k star｜维护状态：非常活跃——4.0（2025-12，全新表格编辑器、内置 PDF/图片查看器）、最新 v4.6.0（2026-06-14），保持月度节奏
- **编辑模式**：单窗格"半实时渲染"（CodeMirror 6 装饰式渲染：链接、图片、标题、强调等原位美化显示，光标靠近时显示源码），可切换纯源码；无传统分屏预览；另有阅读性（Readability）模式按句子复杂度着色
- **核心功能**：定位"出版工作台"，学术功能是护城河——Pandoc Markdown 方言、引用文献（Zotero/JabRef/Mendeley，经 CSL JSON / BibTeX，输入 @ 即可引用）、Zettelkasten 双链 [[wiki 链接]] + 标签 + 反向链接 + 图谱视图、脚注、LaTeX 数学、Mermaid、代码高亮；经 Pandoc 导出 40+ 格式（PDF/DOCX/ODT/LaTeX/HTML/reveal.js 幻灯片等），支持项目级导出与期刊模板；跨文件全文搜索；LanguageTool 语法/风格检查内置；多光标、Vim/Emacs 键位、代码片段（snippets）、番茄钟、字数目标与项目总字数统计
- **UI 设计**：三栏布局（工作区文件树 / 文件列表 / 编辑器）+ 可开合侧栏（引用、目录、相关文件）；多主题 + 暗色模式；专注模式与打字机滚动；设计风格偏"学术工具"，比 Typora 重但比 IDE 轻；状态栏（字数/字符数、可读性开关）是 3.x 的亮点细节
- **技术栈**：Electron + TypeScript + Vue，编辑器内核 CodeMirror 6，导出依赖捆绑的 Pandoc
- **AI 能力**：无内置 AI（开发者对 AI 持审慎态度，社区讨论中未列入路线图）
- **可借鉴点**：1）CodeMirror 6 装饰式"半 WYSIWYG"是实时渲染的另一种实现路径，工程量小于 Typora 式分块渲染，值得评估；2）"编辑器 + Pandoc"的导出架构：不自己造导出轮子；3）状态栏的可读性模式、项目字数目标等"写作者关怀"细节
- **不足**：性能是头号抱怨——官方论坛 2026-03 有"最近版本几乎不可用"的帖子，GitHub issue #5019 描述千余条笔记时 macOS 上新建/粘贴卡顿近一分钟；学术功能带来配置复杂度（Pandoc、CSL、模板），非学术用户觉得重；Electron 内存占用偏高

### Inkdrop

- **基本信息**：开发者 Takuya Matsuyama（日本个人开发者，@craftzdog）｜平台 macOS / Windows / Linux + iOS / Android｜价格：纯订阅制，$4.99/月（年付）或 $5.99/月（月付），14 天试用，无免费版；闭源｜官网 https://www.inkdrop.app｜非开源（插件生态开源）｜维护状态：活跃，开发者以 "dev as a vlogger" 方式持续公开开发过程
- **编辑模式**：双栏分屏（左源码右预览），可切换仅编辑/仅预览；非 WYSIWYG
- **核心功能**：GFM + 可扩展渲染（KaTeX 数学、Mermaid、TOC、embed 等由插件提供）；100+ 官方/社区插件（JavaScript 编写，插件系统仿 Atom）；笔记本 + 标签 + 状态（Active/On Hold/Completed）管理，适合开发者任务流；端到端加密同步（自研基于 CouchDB，可自托管自己的 CouchDB 服务器）；全文搜索；Vim / Emacs / Sublime 键位，多段快捷键绑定；导出 HTML/PDF/Markdown
- **UI 设计**：三栏布局（笔记本树 / 笔记列表 / 编辑+预览）；界面精致克制，暗色主题出色，被视为"开发者审美"的代表；主题可通过插件安装（CSS 基础）
- **技术栈**：Electron + React，编辑器内核 CodeMirror；移动端 React Native
- **AI 能力**：官方无内置 AI
- **可借鉴点**：1）个人开发者靠"公开开发过程 + 明确细分人群（开发者笔记）+ 订阅"活了近十年，其博文《Why Inkdrop is a Subscription App》对定价策略的思考值得一读；2）插件 API 设计（仿 Atom 的 JS 插件 + keymap/theme 分层）是小团队做扩展生态的成熟样板
- **不足**：订阅制 + 无免费层是最大抱怨（开发者公开回应"嫌贵的用户我会忽略"，立场强硬）；闭源；单人开发的可持续性风险；界面对非开发者不友好

### Caret

- **基本信息**：开发者 Emanuil Rusev（parsedown 作者）与 Antonio Stoilkov｜平台 macOS / Windows / Linux｜价格 $29 一次性买断（早期 $15）；闭源｜官网 https://caret.io（仍可下载购买）｜GitHub 仅有 issue/发布仓（careteditor），无源码｜维护状态：实质停更——发布仓最后更新 2018-06，beta 仓最后更新 2019-02，官方 X 账号沉寂多年；有用户报告 Windows 11 上仍能运行、Debian 上已无法运行。严格说已不满足"活跃维护"，因在种子清单中故收录并标注
- **编辑模式**：混合模式——保留 Markdown 源码字符，但对语法做内联渲染增强（加粗即时变粗、链接高亮等），介于纯源码与 Typora 式 WYSIWYG 之间；这种"语法不隐藏的所见即所得"当年独树一帜
- **核心功能**：CommonMark + GFM；自动补全（链接、emoji、文件路径）、多光标、智能列表续排；导出 HTML/PDF；简单文件浏览侧栏；无插件系统、无同步
- **UI 设计**：曾被誉为"最讲究细节的 Markdown 编辑器"——金色光标、精确的行高与排版节奏、克制的配色；单栏布局；打字机滚动、专注模式。产品页口号"obsessive attention to detail"名副其实
- **技术栈**：Electron；解析器源自作者自己的 parsedown（PHP 时代成名作）思路
- **AI 能力**：无
- **可借鉴点**：1）"不隐藏语法的内联渲染"是 WYSIWYG 与源码党之间的妥协方案，对程序员用户很有吸引力，可作为我们的可选编辑模式；2）它证明界面细节（光标、动效、行距）本身就能成为付费卖点
- **不足**：付费软件多年停更是社区最大怨点（论坛有"付了钱然后作者消失"的抱怨）；Linux 新发行版已跑不动；无源码无从自救

### ghostwriter

- **基本信息**：开发者 Megan Conkle，2022 年起并入 KDE 社区｜平台 Windows / Linux 官方支持（macOS 无官方构建，可自行编译）｜免费，GPL-3.0｜官网 https://ghostwriter.kde.org｜GitHub https://github.com/KDE/ghostwriter，约 4.9k star｜维护状态：活跃，随 KDE Gear 月度发版（25.04.x → 25.12.x，2025 全年 7+ 次发布，25.12.x 持续到 2026）
- **编辑模式**：单栏源码编辑 + 可开合的实时 HTML 预览分屏；预览针对大文档做了防卡顿优化；非 WYSIWYG
- **核心功能**：内置 cmark-gfm 处理器（GFM 表格、任务列表），安装 Pandoc / MultiMarkdown / Discount 后可切换处理器并解锁更多导出（HTML/Word/ODT/PDF）与 MathJax 数学（仅 Pandoc 路径）；大纲侧栏（Ctrl+J 快速跳转）、文档统计 + 会话统计（实时字数、可读性指标）、速查表（F1）；拖拽图片自动生成链接；自动保存与文件备份；无文库管理（面向单文件写作）、无插件系统
- **UI 设计**：极简"无干扰写作"取向；焦点模式可配置高亮当前行/句子/段落/三行；Hemingway 模式（禁用退格与删除键，强迫向前写）是招牌功能；全屏模式、打字机滚动；自带主题编辑器，可自定义背景图与配色并分享主题；风格关键词：禅意、克制
- **技术栈**：C++ / Qt 6 / KDE Frameworks 6（原生 Qt，非 Electron），预览用 Qt WebEngine；Windows 上有 Qt6 OpenGL 全屏菜单 bug，需 --disable-gpu 规避
- **AI 能力**：无
- **可借鉴点**：1）焦点模式的粒度设计（行/句/段可选）与 Hemingway 模式，是差异化的"写作心流"功能，原生实现成本低；2）"内置轻量解析器 + 可外接 Pandoc"的分层导出策略；3）会话统计（本次写了多少字、码字速度）对写作者的激励设计
- **不足**：无官方 macOS 版是硬伤（对我们反而是机会）；无文件库/多文档管理，定位偏单文档写作；Qt 界面在 Windows 上观感一般；预览主题化能力弱

### Apostrophe

- **基本信息**：开发者 Manuel Genovés（GNOME World 项目，前身是 Wolf Vollprecht 的 UberWriter）｜平台：实际仅 Linux（Flathub 分发；GTK 技术上可移植但无官方 mac/Win 构建）｜免费，GPL-3.0｜主页 https://apps.gnome.org/Apostrophe｜源码 https://gitlab.gnome.org/World/apostrophe（GNOME GitLab，非 GitHub）｜维护状态：活跃——v3.0（2024-05-01，GTK4 大版本重写）、v3.2/3.3 后最新 v3.4（2025-09-30）
- **编辑模式**：单栏"轻实时渲染"：源码内联美化（标题变大、粗体变粗，语法符号保留但淡化），另有全文预览切换；灵感明显来自 iA Writer
- **核心功能**：Pandoc 作为解析与导出后端——导出 ODF / PDF / EPUB / RTF / HTML / LaTeX / MediaWiki；数学公式（经 Pandoc）；Markdown 语法工具条（3.0 新增）、列表自动缩进与括号补全；无文库管理、无 wiki 链接、无插件系统；拼写检查
- **UI 设计**：本类别"极简美学"天花板之一——GTK4 + libadwaita 设计语言，界面元素几乎为零，只有一个悬浮工具条；亮 / 暗 / 羊皮纸（sepia）三主题；专注模式 + Hemingway 模式 + 全屏；排版用心（合适的行宽、衬线正文可选）。风格关键词：iA Writer 式禅意、系统原生一致性
- **技术栈**：Python + GTK4 / libadwaita（原生 GTK），Pandoc 后端
- **AI 能力**：无
- **可借鉴点**：1）它是"如何用系统原生设计语言做出漂亮 Markdown 编辑器"的最佳参照——我们做 SwiftUI/AppKit 版可对标其克制程度（零面板、悬浮工具条、三色主题）；2）"语法符号保留但视觉弱化"的渲染策略实现简单、体验好；3）羊皮纸主题这类低成本情绪化设计很讨喜
- **不足**：实际上仅 Linux 可用；功能极少（无文库、无链接系统、无图表），重度用户留不住；强依赖 Pandoc（未装则导出不可用）

### Notable

- **基本信息**：开发者 Fabio Spampinato｜平台 macOS / Windows / Linux｜免费下载；自 v1.6 起闭源（仓库仅保留旧版源码），此前 MIT｜官网 https://notable.app｜GitHub https://github.com/notable/notable，约 23.5k star（存量热度）｜维护状态：基本停更——最后稳定版 v1.8.4（2020-01-21），notable-insiders 实验仓的通用构建（Electron 11→16 时代）也已陈旧；官网多年宣称移动端/网页端"开发中"未兑现；issue 区仍有用户提问但无官方发布。严格说已不满足"活跃维护"，因在种子清单中故收录并标注
- **编辑模式**：双栏分屏（源码 + 预览）或单栏切换；非 WYSIWYG
- **核心功能**：GFM + KaTeX + Mermaid；纯 .md 文件存储（带 YAML front matter 元数据），无数据库、无锁定——"你的数据就是文件夹里的 Markdown 文件"是核心卖点；多级标签系统（面包屑式）、笔记本、置顶、收藏；附件管理；全文搜索；暗色主题、Zen 模式；无同步（靠用户自配 iCloud/Dropbox 文件夹）；无插件系统
- **UI 设计**：三栏（标签树 / 笔记列表 / 编辑器），界面干净现代，标签侧栏的层级组织当年颇受好评
- **技术栈**：Electron / TypeScript（第三方目录称其编辑器组件源自 VS Code 系）
- **AI 能力**：无
- **可借鉴点**：1）"纯 Markdown 文件 + front matter 元数据、绝不锁定数据"的本地优先姿态为它赢得 23k star，这正是我们开源产品应有的立场；2）反面教材：开源项目中途闭源引发的社区反噬（HN/Reddit 大量批评），以及"承诺功能长期跳票"对口碑的伤害——开源承诺要慎重且坚持
- **不足**：六年无正式更新；闭源转向被社区视为背叛；无同步、无移动端；Electron 旧版本存在安全隐患

### VNote

- **基本信息**：开发者 tamlok（Le Tan，vnotex 组织）｜平台 Linux / Windows / macOS｜免费，LGPL-3.0 开源｜主页 https://vnotex.github.io/vnote｜GitHub https://github.com/vnotex/vnote，约 12.9k star｜维护状态：活跃——VNote 4 大版本重写后，最新 v4.2.0（2026-07-16）
- **编辑模式**：源码高亮编辑与渲染阅读双模式切换（编辑态对图片/公式等做原位预览增强），非 Typora 式逐段 WYSIWYG；面向"了解 Markdown 的程序员"设计
- **核心功能**：完整笔记本管理（notebook / 文件夹 / 标签），VNote 4 的旗舰功能是基于 Git 的笔记本同步——任意 Git 远端（GitHub/GitLab/自托管）经 HTTPS 或本地仓库同步，PAT 凭证存系统钥匙串，支持后台自动同步与内置冲突解决；全新原生内核 vxcore 承载笔记本管理/搜索/配置/同步（MVC + 依赖注入重构）；GFM + MathJax 数学 + Mermaid / PlantUML / Graphviz / WaveDrom 图表；全文搜索；通用入口（Universal Entry，类命令面板的快速跳转）；大纲面板；Vim 模式；快照/备份；导出 HTML / PDF / Markdown；主题系统（可自定义）；macOS DMG 已签名
- **UI 设计**：三栏工具型布局（笔记本树 / 笔记列表 / 多标签页编辑器），带工具栏与多面板，风格接近 IDE；有暗色主题；整体观感偏"程序员工具"，密度高但不够精致
- **技术栈**：C++ / Qt（原生），渲染用 Qt WebEngine（vditor/自研前端渲染层）
- **AI 能力**：无
- **可借鉴点**：1）"Git 远端即同步后端"的设计非常聪明——零服务器成本、开发者天然信任，配合钥匙串存凭证与自动冲突解决，值得我们直接借鉴为开源产品的同步方案；2）Universal Entry 命令面板式导航；3）反面参照：Qt/工具型 UI 的密度感正是我们"简洁好看"要避开的
- **不足**：社区（尤其英文社区）反馈 UI 老气、交互繁杂；Qt WebEngine 使体积和内存不"原生"；文档与社区以中文为主，国际影响力有限；无插件系统

### QOwnNotes

- **基本信息**：开发者 Patrizio Bekerle（奥地利）｜平台 Linux / macOS / Windows｜免费，GPL-2.0 开源｜官网 https://www.qownnotes.org｜GitHub https://github.com/pbek/QOwnNotes，约 5.8k star｜维护状态：极度活跃——版本号按年编号，最新 v26.7.8（2026-07-18），几乎每周发版，十年不辍
- **编辑模式**：源码编辑 + 分屏预览（可仅预览）；编辑区支持 Markdown 高亮、语法符号可选隐藏、标题折叠、行内图片预览；提供 Minimal / Full / Preview Only / Vertical / Single Column 等布局预设
- **核心功能**：纯文本 .md 文件存储；与 Nextcloud/ownCloud 深度集成（文件同步 + 服务端版本历史与回收站恢复 + Nextcloud Tasks/CalDAV 任务同步），也可用 Syncthing/Dropbox；[[wiki 链接]] + 自动补全 + 反链 + 重构改名；无限标签层级 + 多级子文件夹 + 多笔记文件夹（多项目隔离）；AES-256 笔记加密；便携模式；拼写检查 + LanguageTool + Harper + Markdown LSP（Marksman 补全/诊断、rumdl lint）——在编辑器里接 LSP 是罕见亮点；招牌是 QML/JavaScript 脚本引擎：应用内脚本市场（社区仓库 qownnotes/scripts），可自定义模板、界面、导出流程、外部服务集成；60+ 语言本地化
- **UI 设计**：可自由拆装的多面板工具型布局（首次启动即让用户选布局），暗色模式实时切换；观感朴素务实，非设计驱动；官方定位"低资源占用，不是吃 CPU 内存的 Electron 应用"
- **技术栈**：C++ / Qt（原生），预览用 Qt 文本渲染/WebEngine，脚本引擎为 QML/JS
- **AI 能力**：有——内置 AI 支持（可接 OpenAI、Groq 等，脚本可扩展任意兼容后端），并内置 MCP server 让外部 AI Agent 安全地搜索与读取笔记；这是传统开源笔记应用中最早拥抱 MCP 的案例之一
- **可借鉴点**：1）内置 MCP server 的思路对我们"接入 AI"极具参考价值——让编辑器成为 AI Agent 的数据源而非只做对话框；2）脚本引擎 + 应用内脚本市场是 C++/原生应用做扩展生态的可行样板（对应我们可用 JavaScriptCore/Swift 插件）；3）LSP 接入（Marksman）证明 Markdown 编辑也能吃编程工具链红利
- **不足**：UI 是最大槽点——面板繁多、视觉过时、上手曲线陡（开发者自己也承认它"为自己的工作流而造"）；设置项浩繁；预览排版一般

### Znote

- **基本信息**：开发者 Anthony Lagrede（法国，个人开发者）｜平台 macOS / Windows / Linux（Homebrew 可装）｜价格：免费下载使用（含免费 AI 请求额度），Pro 许可 29.90€ 一次性买断（含 VAT，覆盖所有个人设备，永久更新，解锁自带 AI Key）；GitHub 公开仓库 https://github.com/alagrede/znote-app 约 240 star（主要承载发布与反馈，非典型社区开源项目）｜官网 https://znote.io｜维护状态：活跃——v4.2.4（2026-07-18）
- **编辑模式**：实时渲染 WYSIWYG 风格编辑 + 可执行代码块——Markdown 笔记里的 JavaScript 代码块可以直接"按播放键"运行，结果内联展示，定位"Jupyter for JS developers"
- **核心功能**：本地 .md 纯文件存储（自选文件夹）、无账户、默认无遥测；GFM + 代码高亮；代码块可运行 JS（fetch API、查库、调 npm 包），主打取代 Postman/自动化脚本；@ 引用文件夹/笔记/代码块作为 AI 上下文；会议录音转写并在笔记内生成摘要；导出/发布；全文搜索
- **UI 设计**：现代双栏（文件列表 + 编辑区），界面干净，偏开发者审美；暗色主题
- **技术栈**：Electron + React
- **AI 能力**：本类别 AI 集成最深的产品之一——免费层内置 AI 请求；Pro 后 BYOK（OpenAI、OpenRouter 数百模型、Ollama 本地模型），官方口号"Unlimited AI at provider cost — no subscription, no margin"（按供应商成本用 AI，不抽成不订阅）；AI 可读取 @ 引用的文件上下文、可调用你的 JS 函数发 HTTP 请求/查数据库（工具调用范式）
- **可借鉴点**：1）"29.90€ 买断解锁 BYOK、AI 用量零抽成"是目前最被开发者社区认可的 AI 变现姿势，直接可抄；2）@ 引用笔记/文件作为 AI 上下文的交互，成本低、感知强；3）"AI + 可执行代码块"展示了 Markdown 编辑器向 agent 工作台演化的方向
- **不足**：知名度与社区都很小；Electron 底子，编辑器本身（排版、渲染精细度）平平；面向开发者，写作者场景弱；单人项目可持续性风险

### Joplin（补充收录：搜索"Typora alternatives / markdown editor linux"高频出现）

- **基本信息**：开发者 Laurent Cozic + 大型社区｜平台 Windows / macOS / Linux / iOS / Android / 终端｜应用免费开源（AGPL-3.0）；官方同步服务 Joplin Cloud 订阅：Basic 2.99€/月、Pro 4.79€/月、Teams 6.69€/月（也可完全免费走 Nextcloud/Dropbox/OneDrive/WebDAV/自托管 Joplin Server 同步）｜官网 https://joplinapp.org｜GitHub https://github.com/laurent22/joplin，约 55.7k star｜维护状态：非常活跃——v3.6.15（2026-06-20），十年持续高频迭代
- **编辑模式**：双栏分屏（CodeMirror 6 源码 + 预览）或所见即所得富文本模式（TinyMCE）二选一切换；富文本模式与 Markdown 存在转换损耗（官方也承认）
- **核心功能**：笔记本层级 + 标签 + 待办；端到端加密同步（多后端）；网页剪藏（浏览器扩展）；插件生态成熟（反链、知识图谱、表格工具、日历、备份等数百款，Extension API + 主题）；OCR、语音识别内置；全文搜索；历史版本（笔记修订历史）；导出 JEX / MD / PDF / HTML；数学（KaTeX）、Mermaid
- **UI 设计**：三栏经典布局；功能优先、观感中庸，常被评"实用但不精致"；主题可换、支持自定义 CSS
- **技术栈**：Electron + TypeScript + React；移动端 React Native；编辑内核 CodeMirror 6 / TinyMCE
- **AI 能力**：官方内置 OCR/语音识别等 AI 基础能力，Joplin Cloud 推出 Cloud AI（beta）随 Basic 起的套餐提供；插件生态是主力——Jarvis（GPT/Claude/Gemini/Ollama/HF，本地离线语义搜索 + 与笔记对话 + 自动标签）、NoteLLM（开源、支持 MCP、可接 ollama 本地模型）、AI Note Assistant 等
- **可借鉴点**：1）"应用免费开源 + 官方托管同步订阅"是开源编辑器最被验证的商业闭环（我们若做同步可参考）；2）插件 AI（尤其 Jarvis 的本地语义搜索）展示了社区补齐 AI 的速度——开放好用的插件 API 比自己抢做 AI 功能更重要；3）笔记修订历史是用户信任的重要来源
- **不足**：笔记存 SQLite 数据库而非纯 .md 文件（文件名为 ID），"数据不透明"是 Reddit 上对它最持久的批评；UI 精致度长期被 Obsidian/Notion 比下去；富文本模式与 Markdown 互转丢格式

### MarkFlowy（补充收录：新一代 Tauri + AI 产品）

- **基本信息**：开发者 drl990114（个人，中国）｜平台 Linux / macOS / Windows｜免费，AGPL-3.0 开源｜官网 https://markflowy.vercel.app｜GitHub https://github.com/drl990114/MarkFlowy，约 2.3k star｜维护状态：活跃——v0.84.0（2026-07-19），迭代频繁但仍处 0.x
- **编辑模式**：WYSIWYG 实时渲染 + 源码双模式切换（ProseMirror 系）
- **核心功能**：内置 AI 助手（见下）；文件树 + 全局搜索的轻量文库；GFM；除 Markdown 外还能编辑 JSON/TXT；智能图片处理（相对路径管理或 Base64 转换）；自定义主题（可导出分享）+ 自定义快捷键；多语言
- **UI 设计**：现代扁平、干净的双栏布局，暗色主题成熟；体积 <20MB、启动快是核心体验卖点
- **技术栈**：Tauri（Rust 壳）+ TypeScript，编辑内核基于 remirror/ProseMirror（起点是 rino 项目）——本类别少有的非 Electron 新架构
- **AI 能力**：作为一级功能内置——接 ChatGPT / DeepSeek / Ollama（本地），支持文章翻译、摘要、对话与对话一键导出
- **可借鉴点**：1）它就是"我们想做的产品"的 Tauri 版对照组：开源 + 好看 + 内置多供应商 AI（含本地 Ollama），功能取舍值得逐项研究；2）Tauri 证明 20MB 级安装包对用户的感知价值（我们用原生 Swift 可做得更小更快）；3）AI 供应商抽象层（OpenAI 协议兼容 + Ollama）的设计
- **不足**：0.x 成熟度，功能与稳定性尚浅；macOS 构建未签名（需 `xattr -cr` 手动放行，对普通用户是硬门槛——反衬签名公证的重要性）；社区小、文档少；无导出 PDF/DOCX 等重型功能

### ReText（补充收录：Linux 榜单常客）

- **基本信息**：开发者 Dmitry Shachnev｜平台 Linux 为主（Python/Qt 理论跨平台，可 pip 安装于 mac/Win，但无官方原生包）｜免费，GPL-2.0+｜GitHub https://github.com/retext-project/retext，约 2.1k star｜维护状态：慢速但存活——8.1.0（2025-01-09），前一版 8.0.2（2024-03），约年更节奏
- **编辑模式**：经典双栏分屏（源码 + 同步滚动预览），也可仅编辑/仅预览；无 WYSIWYG
- **核心功能**：基于 pymarkups 支持 Markdown / reStructuredText / Textile / AsciiDoc（8.1 新增初步支持）多标记语言——这是它的差异点；MathJax；表格编辑模式；导出 PDF / ODT / HTML；标签页多文档；可用 Python 模块扩展自定义标记
- **UI 设计**：朴素的 Qt 工具窗口，无设计野心；有语法高亮与暗色支持
- **技术栈**：Python + PyQt6（Qt6 / WebEngine 预览）
- **AI 能力**：无
- **可借鉴点**：1）"一个编辑器、多种标记语言"的抽象（markups 库）——若我们未来想兼容 reST/AsciiDoc 可参考其分层；2）反面参照：纯功能型 UI 的天花板
- **不足**：界面过时、更新缓慢；无 mac/Win 官方分发；功能停留在"够用"层面，榜单里常被列为"轻量备选"而非主力推荐

## 本类别小结

**共性与趋势**

- **交互收敛于"实时渲染"**：Typora 式逐段 WYSIWYG（Mark Text、MarkFlowy、Znote）与 CodeMirror 装饰式半渲染（Zettlr、Apostrophe）两条路线已基本淘汰纯分屏预览；仍坚持分屏的（QOwnNotes、ghostwriter、ReText、Inkdrop、Joplin）全部是工具型/老牌产品。
- **技术栈决定颜值上限与体积下限**：好看的一侧几乎全是 Electron（Typora/Mark Text/Inkdrop/Znote），轻快的一侧是 Qt/GTK 但普遍不好看（VNote/QOwnNotes/ReText，Apostrophe 是唯一"原生且美"的例外）；Tauri（MarkFlowy）是 2024 后的新平衡点。"原生 + 好看"在跨平台阵营里近乎无人做到——这正是原生 macOS 单平台产品的机会。
- **商业模式已被验证的三种**：小额买断（Typora $14.99、Znote 29.90€、Caret $29）口碑最好；开源应用 + 官方云同步订阅（Joplin）可持续；纯订阅无免费层（Inkdrop $4.99/月）能活但骂声不断。
- **AI 从卖点变标配，姿势分三档**：内置多供应商 + 本地 Ollama（MarkFlowy、Znote）；插件/脚本接入（Typora 的 copilot 插件、Joplin 的 Jarvis）；面向 Agent 的基础设施（QOwnNotes 内置 MCP server）。共同底线是 BYOK + 本地模型选项 + 不抽成，社区对"AI 订阅抽成"抵触强烈。
- **维护风险是本类别的常态**：种子 11 款中 Caret、Notable 已实质停更，Mark Text 停摆三年才复活——个人项目的可持续性是用户选型时的真实焦虑，也是"活跃维护"本身能成为卖点的原因。

**对我们产品的启示**

- **交互对标 Typora，一步到位做逐段实时渲染**：这是本类别用户的体验锚点，分屏预览起步等于落后十年；同时保留整篇源码模式和"语法符号淡化不隐藏"（Caret/Apostrophe 路线）作为可选模式，兼顾程序员用户。
- **用"原生 + 简洁"打跨平台产品打不了的仗**：对标 Apostrophe 的克制（零面板、悬浮工具条、三主题）+ Typora 的排版质感，把启动速度、内存占用、系统级细节（签名公证、钥匙串、快速预览）做成显性卖点——MarkFlowy 未签名导致 `xattr` 手动放行的教训要引以为戒。
- **主题系统抄 Typora："主题即一个样式文件" + 官方主题画廊**，把定制门槛降到前端开发者人手可为，这是冷启动社区生态最便宜的引擎。
- **AI 采用"Znote 模式 + QOwnNotes 前瞻"**：免费内置少量额度降低体验门槛，BYOK（OpenAI 协议兼容 + Ollama 本地）零抽成赢口碑；同时内置 MCP server，让编辑器成为用户 AI Agent 生态的一等公民——目前尚无一款"好看的"编辑器做到这点。
- **数据立场必须是"纯 .md 文件 + 永不锁定"**（Notable 的正面遗产、Joplin 数据库存储的反面教训），配合 VNote 4 的"任意 Git 远端即同步"方案，可以零服务器成本解决同步。
- **开源承诺要一次想清楚**：Notable 中途闭源的社区反噬和 Mark Text 停更三年的信任损耗说明——开源协议、治理方式与可持续资金来源（捐赠/买断增值/云服务）应在发布前定好并公开。
