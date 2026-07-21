# Windows 专属与已停更的 Markdown 编辑器（历史与教训）

> 类别总体观察：本类别覆盖两类产品——只做 Windows 的编辑器，以及各平台已停更/衰落的项目，合计 20 款。它们大多诞生于 2011–2017 年 Markdown 桌面编辑器的第一波黄金期，如今除 Markdown Monster、ReText 等极少数外均已死亡或休眠。死亡原因高度集中：单人维护者精力耗尽（Abricotine、Haroopad、Mark Text）、闭源+买断制收入无法养活全职团队（Caret、Texts、MarkdownPad）、依赖的渲染组件（Awesomium、Qt WebKit、NW.js）先于产品死掉造成技术债雪崩，以及向 SaaS 强行转型抛弃原有社区（Boostnote）。值得注意的反例是：维护面极小、依赖极少的工具型项目（ReText，15 年不死）和「一人公司+付费买断+持续写博客经营」的 Markdown Monster 反而活得最久。这些正反教训对我们做「开源免费、可持续维护」的 macOS 原生编辑器是最直接的参考。

---

## 一、种子清单条目

### MarkdownPad
- **基本信息**：开发者 Evan Wondrasek（美国明尼阿波利斯，个人开发者）｜Windows 专属（XP–8 时代）｜免费版 + Pro 版 $14.95 买断；闭源｜官网 markdownpad.com（仍在线）｜无 GitHub（闭源）｜**已停更**：最后版本 2.5 发布于 2014 年 12 月，作者最后一次公开动态为 2016 年 2 月，此后彻底沉寂
- **编辑模式**：经典双栏分屏（左源码/右 LivePreview），预览自动滚动到当前编辑位置（当年的招牌功能）
- **核心功能**：多 Markdown 引擎可切换——标准 Markdown、Markdown Extra（表格）、GFM（离线版，含任务列表与 emoji）、2.5 版新增 CommonMark；自定义 CSS（支持多样式表 + 内置 CSS 编辑器）；HTML 导出、PDF 导出（Pro）；快捷键与工具栏一键加格式；自动保存。无文库管理、无同步、无插件系统
- **UI 设计**：双栏单窗口，可自定义配色/字体/布局；典型 Win7 时代工具软件风格；无专注模式。值得学习的细节：LivePreview 与编辑位置的同步滚动体验
- **技术栈**：.NET 4 + WPF；预览用第三方嵌入式 Chromium「Awesomium」渲染
- **AI 能力**：无
- **可借鉴点**：1) 「免费够用 + Pro 买断解锁导出/引擎」的分层在当年跑通过；2) 预览同步滚动是分屏模式的体验底线；3) 反面教材——预览内核选型必须选有长期生命力的方案
- **不足**：Windows 8/10 上预览窗格直接崩溃，需手动安装 Awesomium 1.6.6 SDK 才能修复（论坛/AlternativeTo 大量抱怨）；停更后「谁还会买 Pro」成为 SitePoint 等评测的共同质疑
- **停更原因/教训**：单人副业项目 + 闭源，作者兴趣转移后无人能接手；依赖的 Awesomium 自身停止维护，Windows 升级即崩溃，技术债直接压垮产品。教训：闭源单人项目没有「社区续命」选项；嵌入式 WebView 依赖是长期风险点。

### Markdown Monster
- **基本信息**：开发者 Rick Strahl / West Wind Technologies（一人公司）｜Windows 专属（WPF）｜免费试用（全功能+偶尔弹提示），单用户 $99 买断、终身版 $399、升级 $49、5 用户 $399、10 用户 $749、25 用户 $1,899、站点授权 $5,999，均为永久许可｜官网 markdownmonster.west-wind.com｜GitHub：RickStrahl/MarkdownMonster——曾是「Source Open」（可看源码但非 FOSS），2021 年 5 月因大量盗用滥用被作者撤下源码，现仓库仅作 issue 跟踪与下载页，源码按申请开放私有仓库；star 数约低数千级（具体未知）｜**仍在活跃维护**（v4.x，2025 年后仍持续发版）
- **编辑模式**：源码编辑 + 同步 HTML 预览分屏（非 WYSIWYG），预览可关
- **核心功能**：GFM；博客发布是招牌——直接发布/管理 WordPress 与 MetaWeblog API 博客；截图捕捉与多种图片粘贴/嵌入方式；内联拼写检查；文本片段（Text Expansion）、C# 脚本、完整 .NET Addin 插件模型；表格编辑器；Git 集成；HTML/PDF 导出
- **UI 设计**：传统 Windows 桌面软件风格：工具栏 + 多标签 + 可折叠侧栏/预览，深浅主题；谈不上「简洁好看」，定位是生产力工具。值得学习的细节：低干扰的「gentle toolbar」理念——工具栏存在但刻意克制
- **技术栈**：WPF（.NET），编辑区嵌入 Web 编辑器、预览用 WebView2
- **AI 能力**：**有，且较完整**：BYOK（自带 API Key）接入 OpenAI / Azure / OpenRouter / Grok / Gemini / Ollama 等任何 OpenAI 兼容端点；功能包括 Dall-E-3 / gpt-image-1 图片生成并一键嵌入文档、AI 文本补全、博客发布时「AI 生成摘要」等（2023 年底起陆续加入）
- **可借鉴点**：1) BYOK + 兼容任意 OpenAI 端点（含本地 Ollama）是最省心、最不惹反感的 AI 接入方式，直接可抄；2) 一人公司靠「买断 + 大版本付费升级 + 博客内容营销」活了近十年，是独立编辑器商业上最成功的样本之一；3) .NET Addin 式插件模型让重度用户自助扩展
- **不足**：Windows-only 排除了大量开发者；UI 被认为偏老派、按钮多；「源码撤下」事件让社区观感受损（HN/Reddit 有讨论）；评估版弹窗被部分用户抱怨
- **存活之道（对照教训）**：明确收费、不假装开源（License 写得极清楚）、作者以博客持续输出维持关注度——开源项目若无收入，反而更需要设计可持续机制。

### Typedown
- **基本信息**：开发者 byxiaozhi（个人）｜Windows 10/11 专属（WinUI 3）｜免费；MIT 协议｜Microsoft Store 分发（免费下载）｜GitHub：byxiaozhi/Typedown，约 1,000 star / 85 fork，无正式 Release｜**基本停更**：代码最后实质提交 2023 年 4 月，2024 年 3 月仅改过一次 README，67 个 issue 无人处理
- **编辑模式**：类 Typora 的实时渲染所见即所得（编辑器为 Web 实现，嵌在 WebView2 中），无分屏
- **核心功能**：GFM 基本语法、数学公式、图表等（对标 Typora 的常用集）；面向技术文档/论文/博客写作；导出与文件管理功能较基础；无同步、无插件系统
- **UI 设计**：亮点所在——WinUI 3 + Fluent Design，云母/亚克力材质、原生标题栏与系统动效，被 Store 用户评价为「界面最像 Windows 亲儿子的 Markdown 编辑器」；单栏极简布局
- **技术栈**：混合架构：C#（42.8%）+ WinUI 3 外壳，编辑内核为 JS/TS Web 实现跑在 WebView2 里
- **AI 能力**：无
- **可借鉴点**：1) 「原生外壳 + Web 编辑内核」的混合架构，是拿到原生质感又复用成熟 Web 编辑器的务实路线（与我们 SwiftUI + WKWebView 的可选方案同构）；2) 深度贴合系统设计语言（对我们即 macOS HIG、毛玻璃、原生字体渲染）本身就是差异化卖点
- **不足**：issue 长期无人回应；无正式版本发布流程；Store 版与源码版更新脱节；功能广度远不及 Typora
- **停更原因/教训**：典型的个人兴趣项目，作者热情期过后无收入、无共同维护者即休眠。教训：单人开源项目要在早期就建立发版流程和第二维护者，否则 1k star 也只是「好看的墓碑」。

### WriteMonkey
- **基本信息**：开发者：斯洛文尼亚个人开发者（writemonkey.com，具体姓名未公开宣传）｜WM2 为 Windows 专属（2006 年起）；WM3 跨 Windows/macOS/Linux｜免费 + 「捐赠任意金额解锁插件」（pay-what-you-want，PayPal，WM2 捐赠 key 不能用于 WM3）；闭源｜官网 writemonkey.com｜GitHub 仅有 wm3 的 wiki/issue 仓库（无源码）｜**半休眠**：WM3 最新版 3.3.0 发布于 2023 年 1 月 22 日，此后无更新；WM2 已明确不再开发
- **编辑模式**：纯源码单栏 + Markdown 语法高亮，无预览面板；全屏「禅模式」是默认形态（Esc 退回窗口）
- **核心功能**：Markdown + 脚注、TOC、KaTeX 数学公式等非标准扩展；「//」开头段落作为注释（写作草稿场景的巧思）；repository 文件夹式文库；打字机滚动；写作目标/统计；自动保存 + Dropbox/Google Drive/OneDrive 目录同步；插件系统（捐赠者专享），其中含 **AI Helper 插件：接 GPT-3/4（自备 API key）**；便携免安装，可放 U 盘运行
- **UI 设计**：极简到只剩文字和光标，颜色/字体/版面/信息条全可自定义；「zenware」概念的鼻祖之一；专注+打字机模式是核心卖点。值得学习的细节：可自定义的底部信息条（字数/进度/时间）在极简与信息量之间的平衡
- **技术栈**：WM2 为 .NET（Windows）；WM3 为 NW.js（Chromium 系，非 Electron）
- **AI 能力**：有（插件形式）：AI Helper 插件接入 GPT-3/4，需自备 API key
- **可借鉴点**：1) 「注释段落」「写作目标」等写作者向的小功能设计；2) 全屏禅模式作为默认形态的胆量；3) 捐赠解锁插件是开源/免费软件温和变现的一种参考（但天花板很低）
- **不足**：WM3 重写后长期功能不及 WM2（论坛老用户抱怨最多的点）；闭源+慢更新让用户没有安全感；无预览对新手不友好；捐赠 key 不跨大版本引发不满
- **停更原因/教训**：跨平台大重写（WM2→WM3）耗尽精力，重写版长期追不平旧版功能，用户流失；捐赠模式收入不足以支撑全职。教训：「推倒重写」是独立项目头号杀手；如果重写，必须尽快恢复旧版核心体验。

### Texts
- **基本信息**：开发者：texts.io 团队（个人/极小团队，未公开）｜Windows + macOS｜付费买断（历史价格约 $19–30，后期免费提供；具体现价未知）；闭源｜官网 texts.io（页面仍在线但产品已死）｜无公开 GitHub｜**已停更**：AlternativeTo 记录最后版本发布于 2018 年 3 月
- **编辑模式**：纯所见即所得「Rich Editor for Plain Text」——不露出 Markdown 源码，用样式操作写作、底层存 Markdown（比 Typora 更接近 Word 的交互）
- **核心功能**：表格、图片、脚注、数学公式；导出是最大卖点——经 **Pandoc** 输出 PDF、HTML5、Word、ePub、XeLaTeX、HTML 演示文稿；「insert bibliography」参考文献插入、paste-as 多格式粘贴、段落上下移动；可发布 GitHub Pages 博客；主题与导出模板可定制。无文库、无同步、无插件
- **UI 设计**：单栏、类文字处理器的干净版面，强调排版质量；设计风格关键词：「Markdown 界的 Word」
- **技术栈**：桌面原生应用（具体框架未知），导出管线基于 Pandoc
- **AI 能力**：无
- **可借鉴点**：1) 以 Pandoc 为导出后端，一次接入换来十几种专业导出格式（macOS 上同样可行）；2) 「内容与格式分离、底层永远是纯 Markdown」的产品哲学表述值得借用；3) 学术向功能（脚注/引用/XeLaTeX）是差异化蓝海
- **不足**：知名度始终小众；闭源付费+无更新后用户迅速流失；对 Markdown 方言支持面窄（论坛反馈）
- **停更原因/教训**：小众定位 + 闭源买断制收入不足，团队无声消失，连停更公告都没有。教训：闭源产品「安静死亡」对用户伤害最大；开源至少能让数据与工具活下去。

### CuteMarkEd
- **基本信息**：开发者 Christian Loose（个人）｜Windows / Linux（Qt，理论可编译 macOS 但无官方包）｜免费；GPL 开源｜项目页 cloose.github.io/CuteMarkEd｜GitHub：cloose/CuteMarkEd，约 1.5k star / 328 fork｜**已停更**：最后版本 0.11.3 发布于 2016 年 3 月 28 日；社区续命 fork 为 Waqar144/CuteMarkEd-NG
- **编辑模式**：双栏分屏（源码 + 实时 HTML 预览），可同步滚动
- **核心功能**：数学公式、mermaid 流程图/时序图（2015 年就支持，相当早）、代码语法高亮、Markdown 语法高亮、片段（snippet）与文档词自动补全、Hunspell 拼写检查、YAML front matter 处理选项、自定义快捷键、演示模式、字数统计、HTML/PDF 导出、主题
- **UI 设计**：标准 Qt 桌面双栏布局，工具型外观；无专注模式。值得学习的细节：snippet 补全器同时补全「文档中已出现的词」——轻量但实用
- **技术栈**：C++ / Qt 5.4；Markdown 解析用 Discount（C 实现），高亮用 PEG Markdown Highlight，预览用 Qt WebKit
- **AI 能力**：无
- **可借鉴点**：1) mermaid/数学等「技术写作全家桶」早已是标配预期，我们首发就该带上；2) 原生 C++/Qt 证明了非 Electron 的实时预览完全可行、性能更好（对应我们用原生 + 高性能解析器的路线）
- **不足**：README 长期求助「需要有人帮忙打包 Linux/macOS」；下载源停留在 OpenSUSE 13.2 / Fedora 20 时代；Windows 构建后期无人维护
- **停更原因/教训**：单人维护 + 跨平台打包负担压垮热情；依赖的 Qt WebKit 被 Qt 官方废弃，迁移成本高企。教训：CI/CD 与打包自动化要在项目早期建好；渲染依赖要选官方长期支持的组件（macOS 上即 WKWebView）。

### MdCharm
- **基本信息**：开发者 zhangshine（个人，中国）｜Windows / Linux｜早期为共享软件收费、后完全开源免费；BSD-3-Clause｜GitHub：zhangshine/MdCharm，约 359 star / 98 fork｜**已停更**：实质开发止于 2013–2014 年，仓库最后 push 为 2019 年 11 月
- **编辑模式**：双栏分屏（编辑 + 预览），两侧均可单独关闭；多标签同时编辑多文件
- **核心功能**：支持 Markdown Extra 与 MultiMarkdown 两种方言、可切换解析引擎；导出 HTML / PDF / ODT；拼写检查；自定义快捷键/字体/配色/缩进；自定义文件关联；插入链接图片；搜索
- **UI 设计**：大窗口多标签的传统桌面工具布局；无主题系统亮点、无专注模式
- **技术栈**：C++ / Qt
- **AI 能力**：无
- **可借鉴点**：1) 「解析引擎可切换」满足方言洁癖用户；2) ODT 导出提醒我们办公格式互通仍有需求
- **不足**：知名度低，Softpedia 时代之后再无评测；停更后无 fork 续命，彻底被遗忘
- **停更原因/教训**：先收费后开源都没形成社区，个人项目在 Typora 等更强产品出现后被替代。教训：「开源」本身不带来社区，需要持续经营；被更好产品替代时，小项目没有护城河。

### Haroopad
- **基本信息**：开发者 Rhio Kim / Haroo Studio（韩国）｜Windows / macOS / Linux｜免费；GPL-3.0｜官网 pad.haroopress.com｜GitHub：rhiokim/haroopad，约 1.7k star / 222 fork｜**已停更**：官方最后版本 v0.13.1（2015 年 6 月），v0.13.2 仅通过 GitHub issue 评论静默发布（2016 年 3 月，修显卡兼容），此后仅 2018 年一次文档提交
- **编辑模式**：双栏分屏 + 同步滚动，多种布局视图（可隐藏任一侧）
- **核心功能**：GFM、MathJax 数学公式、flowchart/sequence 图、脚注、TOC、任务列表、71 种语言代码高亮、7 套预览主题；重量级特色：**约 100 种互联网服务的嵌入语法**（YouTube、SoundCloud、Flickr 等）、一键发布到 WordPress/Evernote/Tumblr、以邮件发送文档；演示模式；Vim/Emacs 键位；14 种界面语言；导出 HTML/PDF；命令行支持
- **UI 设计**：深色系现代感界面（2014 年标准下相当漂亮），主题/皮肤双层定制；无打字机模式。值得学习的细节：把「发布/分享」做成一等公民的思路
- **技术栈**：node-webkit（NW.js 前身）+ CodeMirror + marked + Bootstrap
- **AI 能力**：无
- **可借鉴点**：1) 「编辑器即发布工具」的定位（现代对应：一键发 GitHub Pages / 静态博客）；2) 嵌入第三方媒体的通用语法设计；3) 从韩国市场出发做全球化 i18n 的路径
- **不足**：版本号永远停在 0.x 让用户不敢托付；停更后 macOS 新系统上无法运行；同步滚动与大文档性能被抱怨
- **停更原因/教训**：单人项目野心过大（编辑器+静态站生成器 Haroopress+发布平台全都做），精力分散；node-webkit 技术栈快速老化。教训：范围克制——先把编辑器一件事做到 1.0，比同时铺三条产品线更可能存活。

### Abricotine
- **基本信息**：开发者 Thomas Brouard（brrd，法国）｜Windows 7+ / macOS / Linux｜免费；GPL-3.0｜官网 abricotine.brrd.fr｜GitHub：brrd/abricotine，约 2.6k star / 150 fork｜**已停更**：最后版本 1.1.4（2022 年 6 月 9 日）；2023 年 7 月 19 日作者在 issue #347 正式宣布停止开发与支持，2023 年 8 月 30 日仓库归档
- **编辑模式**：行内预览（inline preview）——在源码编辑器内就地渲染图片、数学、复选框、嵌入视频等，介于纯源码与 Typora 式 WYSIWYG 之间的「半实时渲染」
- **核心功能**：GFM、数学公式、表格管理、语法高亮、TOC 侧栏、拼写检查、全屏无干扰模式、自定义主题；经 Pandoc 导出；无文库/同步/插件系统
- **UI 设计**：单栏极简 + 可开关侧栏大纲；法式克制的排版审美，默认主题干净。值得学习的细节：inline preview 的折中路线——保留源码可见性的同时消灭分屏
- **技术栈**：Electron + CodeMirror（JS 77%）
- **AI 能力**：无
- **可借鉴点**：1) 「源码可见的就地渲染」是纯 WYSIWYG 与分屏之外的第三条路，值得在 macOS 原生编辑器里认真评估；2) 反面教材——Electron 安全模型欠账的后果
- **不足**：渲染性能一般；表格编辑弱；最致命的是 issue #254 披露的安全漏洞：渲染进程开启 nodeIntegration，预览不可信文档（iframe/图片）时任意 JS 可访问本地文件与系统 API，且永远不会修复
- **停更原因/教训**：作者明确表态「多年没有精力维护，且出现了危险 bug」——安全债成为压垮项目的最后一根稻草，作者甚至不建议他人 fork。教训：安全架构（沙箱、内容隔离）必须是第一天的设计，不是以后再补的功能；维护者要在 burnout 前公开求援。

### Moeditor
- **基本信息**：开发者：Moeditor 团队（中国学生开发者社区，组织名 Moeditor）｜Windows / macOS / Linux｜免费；GPL-3.0｜主页 moeditor.github.io｜GitHub：Moeditor/Moeditor，约 4.1k star / 266 fork｜**已停更**：2016 年 6 月创建，实质开发约止于 2017 年，仓库已归档（最后 push 2020 年 7 月），描述自标「(discontinued)」
- **编辑模式**：读 / 写 / 预览三模式切换（写=纯源码，预览=整页渲染），非同屏实时预览
- **核心功能**：GFM、TeX 数学、UML 图、编辑器内代码高亮、focus mode、自定义字体/行高/字号、highlight.js 主题、自动重载、多语言（中英法德西葡）；自研解析器 moemark（fork 自 marked）
- **UI 设计**：以「素雅」出圈——大留白单栏、Raleway 字体、淡色 UI，当年在中文社区被称为最好看的开源 Markdown 编辑器之一
- **技术栈**：Electron + moemark
- **AI 能力**：无
- **可借鉴点**：1) 「好看」本身可以是获客核心（4.1k star 大半来自颜值）；2) 默认排版（字体/行高/留白）打磨到位，用户开箱即得漂亮文档
- **不足**：模式切换打断心流（写作时看不到渲染效果）；大文档卡顿；停更快、issue 堆积
- **停更原因/教训**：学生团队毕业/兴趣转移，无治理结构与继任者；自研解析器加重维护负担。教训：star 数与可持续性无关；关键人依赖是最大单点故障，早立 CONTRIBUTING 与多维护者机制。

### ReText
- **基本信息**：开发者 Dmitry Shachnev（俄罗斯，2011 年至今）｜Linux 为主（Python 跨平台可运行于 Win/macOS）｜免费；GPL-2.0+｜GitHub：retext-project/retext，约 2.05k star / 207 fork；PyPI/Flathub 分发｜**仍在维护但节奏缓慢**：8.1.0 发布于 2025 年 1 月 9 日，仓库最后 push 2026 年 5 月——15 年长寿项目
- **编辑模式**：源码编辑 + 可切换的实时预览分屏，多标签
- **核心功能**：经 pymarkups 支持 Markdown、reStructuredText、Textile、AsciiDoc（8.1 起）多标记语言；数学公式；导出 HTML/PDF/ODT；自定义 CSS；可用 Python 模块扩展自定义标记；Ctrl+H 查看生成的 HTML
- **UI 设计**：朴素的 Qt 工具界面，无主题系统、无专注模式——「能用但不好看」的典型
- **技术栈**：Python + PyQt6；预览用 QTextBrowser 或 PyQt6-WebEngine
- **AI 能力**：无
- **可借鉴点**：1) 长寿秘诀=极小的维护面：依赖少、功能克制、不追热点，值得我们在架构上刻意控制表面积；2) 多标记语言抽象层（markups）的插件化设计
- **不足**：界面老旧是最常见吐槽；预览排版一般；非 Linux 平台体验差、无官方 mac 包
- **存活之道（对照教训）**：一位维护者 + 15 年小步慢跑证明：把范围收小到自己业余时间养得起，比铺大摊子更能穿越周期。

### Remarkable
- **基本信息**：开发者 Jamie McGowan（爱尔兰，个人）｜Linux 专属（.deb/AUR/Snap）｜免费；MIT（仓库 license 标注）｜官网 remarkableapp.github.io｜GitHub：jamiemcg/Remarkable，约 2.03k star / 226 fork｜**半死亡后小幅复活**：约 2017–2023 年停滞、被 AlternativeTo 标记「possibly discontinued」，2024 年发布 v1.95（适配 Ubuntu 24.04、修扩展 API），此后又归沉寂，2025 年新 issue 无人回应
- **编辑模式**：双栏分屏实时预览
- **核心功能**：GFM、表格、MathJax、代码高亮、自定义 CSS、自定义快捷键、HTML/PDF 导出、多种内置样式；无文库/同步/插件
- **UI 设计**：GTK 风格双栏，随 GNOME 主题走；无专注模式
- **技术栈**：Python + GTK + WebKitGTK，解析用 python-markdown
- **AI 能力**：无
- **可借鉴点**：1) 深度融入单一桌面生态（它之于 GNOME ≈ 我们之于 macOS）能换来发行版收录与自然流量；2) 反面提醒：同步滚动这类「体验级 bug」长期不修会成为口碑黑洞
- **不足**：同步滚动坏了多年未修（作者自己在 release note 承认）；更新间隔以年计；HiDPI/新系统适配靠社区 fork
- **停更原因/教训**：个人业余项目随作者生活阶段起伏；「复活一次再沉睡」说明没有形成维护梯队。教训：与其猛更一版，不如建立哪怕每季度一次的小发版节奏，向用户传递「活着」的信号。

### Springseed
- **基本信息**：开发者 Michael Harker（开发时年仅 17 岁）与 Jono Cooper｜Linux 专属（.deb）｜免费；MIT｜GitHub：spsdco/notes，约 551 star / 52 fork（2012 年 12 月创建，最后 push 2017 年 12 月）｜**已停更**：2.0（2014 年 6 月）后不久停止开发，官网早已下线
- **编辑模式**：笔记应用式：列表 + 编辑区，Markdown 书写、HTML 预览切换
- **核心功能**：笔记本/分类管理、Markdown 格式化、Dropbox 同步、搜索、收藏、嵌入图片
- **UI 设计**：1.x 为浅色圆润风；2.0 改为深色侧栏 + 大号字体 + 扁平方正设计，被 OMG! Ubuntu 专文称赞——在 2014 年的 Linux 桌面上非常出挑；三栏笔记布局
- **技术栈**：CoffeeScript + Spine.js + Atom Shell（Electron 前身）
- **AI 能力**：无
- **可借鉴点**：1) 「简洁好看」在设计荒漠平台（当年的 Linux）能瞬间出圈——同理，把 macOS 原生审美做足就是传播点；2) Dropbox 目录同步这类「借力网盘」是零成本同步方案
- **不足**：功能浅（无标签体系、无导出选项）；Dropbox API 变更后同步失效无人修
- **停更原因/教训**：十几岁的核心开发者升学/离场，项目无人接盘。教训：社区项目要警惕「天才少年单点」；用爱发电的生命周期通常等于作者的人生阶段。

### Laverna
- **基本信息**：开发者：Laverna 团队（开源社区项目）｜Web 应用 + Electron 桌面端（Win/macOS/Linux）｜免费；MPL-2.0｜官网 laverna.cc｜GitHub：Laverna/laverna，约 9.2k star / 799 fork｜**已停更**：官方 wiki 直接写明「LAVERNA IS A DEAD PROJECT，请转向衍生 fork（Encryptic）」，实质开发止于约 2018 年
- **编辑模式**：三种模式：normal（分屏）、preview、distraction free；编辑器基于 Pagedown
- **核心功能**：定位「开源版 Evernote」：Markdown 笔记、任务列表、标签/笔记本；**客户端 AES 加密**（SJCL）；数据存浏览器 IndexedDB/localStorage；Dropbox 与 RemoteStorage 同步；无需注册即用
- **UI 设计**：三栏笔记应用布局（笔记本/列表/编辑器），Web 风格
- **技术栈**：JavaScript（Backbone/Marionette 系）+ Pagedown + SJCL；桌面端 Electron 打包
- **AI 能力**：无
- **可借鉴点**：1) 「隐私优先 + 本地数据 + 免注册」的价值主张在今天更吃香，可作为我们的叙事之一；2) 反面教材——把同步承诺写进卖点之前，先想清楚能不能长期做好
- **不足**：HN/论坛集中抱怨 Dropbox 同步不可靠、多设备冲突丢笔记；浏览器存储让用户对数据安全没底
- **停更原因/教训**：作者亲述因「同步与多设备问题」难以解决而放弃，转投其他项目。教训：同步是笔记类产品技术含量最高、最容易翻车的部分；纯文件（.md on disk）+ 系统级同步（iCloud Drive）是更稳妥的架构。

### Boostnote
- **基本信息**：开发者 BoostIO（日本，Junyoung Choi 等，曾获风投）｜Windows / macOS / Linux｜Legacy 版免费开源，后续 Boost Note 转 SaaS 订阅（免费+付费云）｜GitHub：BoostIO/BoostNote-Legacy，约 16.9k–17.1k star / 1.5k fork；GPL-3.0｜**已停更且服务关闭**：Legacy 最终版 v0.16.1（2020 年，经 boost-releases 仓库分发），仓库 2026 年 5 月 12 日归档只读；继任 SaaS「Boost Note」已于 **2025 年 9 月 30 日正式终止服务**
- **编辑模式**：笔记应用式：源码编辑 + 预览（CodeMirror），另有「snippet note」代码片段笔记类型
- **核心功能**：面向程序员的笔记：Markdown 笔记 + 多文件代码片段笔记、标签、文件夹、本地存储、放网盘目录实现同步、LaTeX、代码高亮、快捷键；**槽点：笔记存为 .cson 专有格式**而非 .md，迁移需转换脚本
- **UI 设计**：三栏（存储/列表/编辑）深色开发者风格，类 IDE
- **技术栈**：Electron + React + CodeMirror
- **AI 能力**：无
- **可借鉴点**：1) 「为开发者而做」的清晰人群定位曾换来 17k star 的爆发式社区；2) 双重反面教材——专有存储格式 + 强行 SaaS 化
- **不足**：CSON 格式锁定被骂最多；Legacy 停更后 Dropbox 同步损坏无人修；老用户在 GitHub discussion 里追问「原来的免费版怎么了」
- **停更原因/教训**：拿了融资后从「开源本地笔记」pivot 成「团队协作文档 SaaS」，抛弃原社区；SaaS 竞争失败后 2025 年关服，两头落空。教训：开源社区是资产不是包袱，pivot 时抛弃它等于自毁根基；数据格式必须用纯 .md——用户文件的可迁移性是不可妥协的底线。

---

## 二、主动补充条目（搜索发现的同类遗漏产品）

### MarkPad
- **基本信息**：开发者 Code52（微软系社区「每周一项目」计划）｜Windows 专属（另有 Win8 Metro/Store 版）｜免费；MS-PL 开源｜GitHub：Code52/DownmarkerWPF，约 1,442 star / 453 fork｜**已停更**：实质开发止于 2013–2015 年（仓库最后 push 为 2022 年 6 月的琐碎改动），最后版本约 0.10.x
- **编辑模式**：双栏分屏实时预览 + 多标签
- **核心功能**：直接打开/保存到博客（MetaWeblog）、GitHub、Jekyll 站点支持、「Open from folder」；剪贴板贴图转 Markdown；拼写检查；浮动语法工具栏；.md/.mdown/.markdown/.mkd 关联
- **UI 设计**：WPF Metro 风格（当年微软设计语言的桌面演绎），浮动工具栏只在选中文本时出现——这个细节今天看仍不过时
- **技术栈**：.NET / WPF；预览为嵌入式浏览器组件
- **AI 能力**：无
- **可借鉴点**：1) 浮动选区工具栏（选中才出现格式按钮）是「简洁但可发现」的好范式；2) Jekyll/博客工作流集成
- **不足**：Bug 多、打磨不足；Store 版与桌面版割裂
- **停更原因/教训**：「社区周项目」模式先天没有长期 owner，热闹的贡献者来了又走。教训：开源项目需要明确的终身维护者/BDFL，众包起步的项目更要尽早确立归属。

### Caret
- **基本信息**：开发者 Emanuil Rusev（Parsedown 作者）与 Antonio Stoilkov（保加利亚）｜macOS / Windows / Linux｜$29 买断 + 免费试用；闭源（其 Markdown 算法开源为 parsedown）｜官网 caret.io（仍在线仍在卖）｜GitHub 仅 careteditor/issues 与 releases 仓库｜**已停更**：最后稳定版 3.4.6（2018 年 6 月 15 日），4.0 重写止步于 4.0.0-rc23（2019 年 2 月 22 日），此后组织内所有仓库零活动
- **编辑模式**：单栏「智能源码」混合模式——保留 Markdown 语法字符但就地渲染强调/标题层级，辅以 Dark/Focus/Typewriter 三种模式
- **核心功能**：语法辅助（表格/列表/围栏代码/链接）、文件路径与 emoji 与代码自动补全、行内 LaTeX 渲染、侧栏文件管理（过滤/预览/移动/重命名）、标签页、标题大纲、多光标、查找替换、拼写检查、导出 PDF/HTML
- **UI 设计**：公认「最好看的 Markdown 编辑器」之一：极简单栏、精致的字距与行高、克制的动效；Product Hunt 上以颜值走红。值得学习的细节：侧栏与编辑区的视觉层级处理、Focus 模式的段落淡出
- **技术栈**：Electron；解析基于 parsedown 思路的自研算法
- **AI 能力**：无
- **可借鉴点**：1) 「保留语法字符的就地渲染」精准命中程序员既要源码可控又要美观的心理，与我们目标用户高度重合；2) 打磨级别的 UI 细节（这正是 macOS 用户的口味）；3) 反面教材——买断制小团队的天花板
- **不足**：$29 闭源在免费开源竞品（Mark Text/Zettlr）夹击下失去性价比；4.0 承诺跳票成社区笑柄；停更后网站照常卖钱被 Reddit 用户批评
- **停更原因/教训**：两位作者全职投入约两年，买断收入无法覆盖持续开发，4.0 大重写在 RC 阶段资金/精力耗尽。教训：小团队慎做「攒大招式」大版本重写；靠一次性买断养全职团队在这个品类几乎不可行——开源+服务/赞助反而更持久。

### Mark Text
- **基本信息**：开发者 Jocs（罗冉，中国）｜Windows / macOS / Linux｜免费；MIT｜官网原域名已因忘续费丢失｜GitHub：marktext/marktext，约 55k–58.4k star / 4.3k fork——本品类 star 最高的项目｜**停摆后于 2026 年复活**：最后正式版 0.17.1（2022 年 3 月），2022–2025 事实弃更（2023 年起社区连发「项目死了吗」issue，2025 年 12 月社区发 PSA 宣告弃更并指向 Tkaixiang fork）；2026 年 5 月作者宣布回归维护、fork 合并回主仓库
- **编辑模式**：Typora 式实时渲染 WYSIWYG（自研 Muya 引擎），另有源码模式、打字机模式、专注模式
- **核心功能**：GFM 全家（表格/任务列表）、KaTeX 数学、mermaid/flowchart/vega 图表、front matter、emoji、图片粘贴自动处理（可接 PicGo 上传）、6 套主题、导出 HTML/PDF、多标签与侧栏文件树
- **UI 设计**：以「simple and elegant」立身：单栏大留白、精选默认字体、亮暗主题均耐看，是开源阵营里最接近 Typora 颜值的产品
- **技术栈**：Electron + 自研 Muya 编辑内核（contenteditable 方案）+ Vue；复活后的新架构由 electron-vite + Vue3 + Pinia 重建
- **AI 能力**：无
- **可借鉴点**：1) Muya 证明开源界能做出 Typora 级实时渲染，其数据模型/光标处理值得研读（MIT 可参考）；2) 「免费开源版 Typora」的定位一句话就讲清价值；3) 反面教材——58k star 也救不了单维护者 burnout
- **不足**：长期停更期间 bug 无人修（表格编辑、中文输入法问题是重灾区）；Electron 内存占用；域名丢失导致官网失联
- **停更原因/教训**：核心作者全职工作后无暇维护，社区 PR 堆积也无人有权限合并；复活契机竟是作者辞职做独立开发。教训：给核心贡献者发合并权限、建立组织化治理，别让项目健康与某一个人的人生绑定；域名/证书等基础设施要设自动续费。

### Notable
- **基本信息**：开发者 Fabio Spampinato（个人）｜Windows / macOS / Linux｜免费使用；**自 v1.9（2020 年）起闭源**，仓库只保留旧版源码（最后开源提交 v1.8.4，2020 年 1 月）｜官网 notable.app｜GitHub：notable/notable，约 23.5k star / 1.2k fork｜**事实停滞**：官网大量功能（同步、版本控制、移动端、插件）常年标注「Future」，社区普遍认为开发已停
- **编辑模式**：源码编辑 + 分屏预览（非 WYSIWYG），多笔记编辑、zen 模式
- **核心功能**：笔记=磁盘上的纯 .md 文件 + front matter 元数据（无锁定，可直接用任何编辑器/网盘/Git 管理）；GFM + KaTeX + Mermaid；标签体系、附件管理；编辑器与 VS Code 同款（Monaco）：多光标、minimap、语法高亮
- **UI 设计**：三栏（标签/列表/编辑）现代扁平风，深色主题完成度高
- **技术栈**：Electron + React + Monaco
- **AI 能力**：无
- **可借鉴点**：1) 「笔记就是磁盘上的 Markdown 文件」+ front matter 元数据的架构值得直接继承——最大化数据自由；2) 反面教材——开源转闭源的信任代价
- **不足**：HN/Reddit 对闭源决定反弹强烈（作者回应「等财务可持续再考虑重新开源」）；承诺功能多年不兑现；更新极慢
- **停更原因/教训**：以闭源换商业化，结果社区贡献归零、口碑受损、商业化也没做成，项目卡死在两头之间。教训：对我们最重要的一条——「开源免费」的承诺一旦给出就不可回撤，回撤的信誉损失大于闭源收益；财务可持续要用赞助/服务等与开源兼容的方式解决。

### Yu Writer
- **基本信息**：开发者 ivarptr（中国，个人）｜Windows / macOS（Linux 版永远「Coming soon」）｜免费版 + Pro 买断约 ¥100/设备（海外约 $7–15）；闭源｜官网 ivarptr.github.io/yu-writer.site｜GitHub 仅官网仓库（已于 2023 年 3 月 10 日归档）｜**已停更**：永远停在 Beta 0.5.3，2021 年起用户已在 AlternativeTo 抱怨无更新
- **编辑模式**：源码编辑 + 预览，多标签；另有 Read Mode、演示模式
- **核心功能**：文库（Library）/智能文件夹/旗标等内容组织；大纲；历史记录；字数统计；多格式导出；当年在 V2EX 等中文社区被称为「比 Typora 更高效」的挑战者
- **UI 设计**：现代深色 GUI、三栏文库布局；Softpedia 评价「功能与界面印象良好但 Beta 打磨不足」（手册与升级页只有中文）
- **技术栈**：未知（跨平台桌面框架，疑为自研/混合方案）
- **AI 能力**：无
- **可借鉴点**：1) 文库+智能文件夹的轻量组织模型适合「比笔记应用轻、比单文件编辑器重」的定位；2) 反面教材——长期 Beta 消耗信任
- **不足**：Beta 阶段即收费引发争议；国际化不完整；停更后购买用户无处维权
- **停更原因/教训**：个人闭源项目单挑 Typora，先发优势与口碑均不足，作者退出后一切归零。教训：挑战强势在位者（Typora）必须有结构性差异（如开源、原生、AI），「更快一点」不构成活下去的理由。

---

## 本类别小结

**共性与趋势**
- 死亡时间高度集中在 2016–2020：第一代（2011–2014 起步）几乎全军覆没；直接死因排前三的是维护者退出、渲染内核/框架技术债、商业模式断粮。
- Windows 专属产品无一例外走向停更或小众化（MarkdownPad、MarkPad、Typedown、WM2），存活者 Markdown Monster 靠的是明确收费而非平台红利；「平台专属+免费+闭源」是最危险的组合。
- 停更的开源项目普遍有三个前兆：发版停止但 issue 还开着 → 社区出现 -NG/fork → 官方 README 打上 discontinued。从停更到用户大规模流失通常不超过两年。
- star 数与存活无关：Mark Text 58k、Laverna 9.2k、Moeditor 4.1k 全都停摆过；反而是 2k star 的 ReText 靠极小维护面活了 15 年。
- 技术栈教训一致：依赖 Awesomium / Qt WebKit / node-webkit / 旧 Electron 的产品，全部被依赖的死亡拖垮；数据格式上，凡用专有格式（Boostnote 的 CSON）都成为口碑污点。
- 交互演化脉络清晰：双栏分屏（MarkdownPad 代）→ 行内预览折中（Abricotine、Caret）→ Typora 式实时渲染（Mark Text、Typedown）成为用户默认预期。

**对我们产品（原生 macOS、简洁好看、开源免费、接入 AI）的启示**
- 可持续性是第一功能：从第一天建立多维护者治理（合并权限下放、CONTRIBUTING、季度小发版节奏），不让项目与任何一个人的人生阶段绑定（Mark Text、Moeditor、Springseed 之鉴）。
- 开源承诺不可回撤：Notable 开源转闭源两头落空；变现走赞助/GitHub Sponsors/官方服务路线，与开源兼容（Markdown Monster 的「明码标价+内容营销」亦可参考其精神）。
- 数据自由是底线：笔记/文档=磁盘上的纯 .md（学 Notable 的 front matter 元数据），同步交给 iCloud Drive/网盘，自己不造同步轮子（Laverna 死于同步）。
- 渲染与安全架构第一天做对：用系统长期支持的 WKWebView 或纯原生 TextKit 渲染，严格内容隔离沙箱（Abricotine 死于 nodeIntegration 安全债）；避免一切「小众嵌入内核」。
- 编辑模式取实时渲染为主、源码模式为辅（用户预期已被 Typora/Mark Text 教育完成），可研究 MIT 协议的 Muya 内核设计；保留 Caret 式「语法字符可见的就地渲染」作为差异化选项。
- AI 接入抄 Markdown Monster 的作业：BYOK + 任意 OpenAI 兼容端点 + 本地 Ollama，功能从「选中改写/续写/生成摘要/生图嵌入」做起——这是全品类死掉的老产品都没有、而我们能建立代差的地方。
- 范围克制：先把编辑器单件事做到 1.0（Haroopad 死于同时做三条产品线）；「简洁好看」本身就是获客武器（Moeditor、Caret、Springseed 均以颜值出圈），把 macOS 原生质感（字体渲染、毛玻璃、动效、HIG）做满即是差异化。
