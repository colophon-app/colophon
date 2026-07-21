# Apple 平台原生 Markdown 编辑器（macOS / iOS）

> 类别总体观察：这是与我们目标产品形态最接近的一类，也是竞争最拥挤、分化最明显的一类。头部商业产品（iA Writer、Ulysses、Bear、NotePlan）全部活跃且几乎全部走向订阅或高价买断，设计水准极高；腰部独立应用则大面积停更（Byword、Taio、MacDown、Mou，nvUltra 七年私测未发布），说明"简洁 Markdown 编辑器"作为付费独立生意已很难维持。开源原生阵营（FSNotes、MiaoYan、MarkEdit、Notenik）反而在 2025–2026 年最活跃，其中 MarkEdit 与 MiaoYan 与我们的定位（原生、简洁、开源免费）几乎完全重合。AI 集成整体保守：只有 NotePlan 做了内置 AI，iA Writer 反向做"AI 文本标注"（Authorship），Drafts 与 MarkEdit 走"脚本/扩展 + Apple Intelligence 端上模型"路线——原生 Markdown 编辑器的 AI 位置目前基本是空白，这是我们最大的机会窗口。调研时间：2026-07-21。

---

### iA Writer

- **基本信息**：开发者 iA Inc.（Information Architects，苏黎世/东京）｜macOS / iOS / iPadOS（另有 Windows、Android 版）｜买断制：Mac $49.99、iPhone & iPad 单独买断（v7 起涨至约 $49.99，近期 App Store 亦见 $39.99 标价）、Windows $29.99，7 天免费试用，无订阅｜官网 ia.net/writer｜闭源（但其三款定制字体 iA Writer Mono/Duo/Quattro 开源）｜维护活跃：2026-06 发布 iA Writer 8（适配 macOS 26 Tahoe 的 Liquid Glass 界面、命令面板、搜索式大纲导航）；曾获 Red Dot Best of the Best 2025、iF 设计金奖 2026、Apple Design Award 2025 入围
- **编辑模式**：纯源码 + 语法样式化（标记符号保留但着色/淡化），刻意**不做** WYSIWYG（官方认为实时渲染分散注意力）；预览为独立面板/窗口，可滑动切换
- **核心功能**：Markdown + 部分 MultiMarkdown 扩展（表格、脚注、任务列表、Content Blocks 文件嵌入语法）；焦点模式（句子/段落聚焦）、语法高亮（按词性给名词/动词/形容词着色，独家）、Style Check（冗词/填充词检查）、Hashtag 组织、文库（iCloud/Dropbox/Google Drive/本地文件夹）、全文搜索、版本历史（基于文件系统）、导出 PDF/Word/HTML、MS Word 双向导入导出、模板系统；iA Writer 8 新增命令面板（⇧⌘P，聚合格式化/导出/Authorship 操作）与合并进搜索框的文档大纲跳转
- **UI 设计**：极简单栏 + 可收起文库侧栏；标志性蓝色光标与自研等宽/双宽字体（Mono/Duo/Quattro），行距字号经过精密调校且几乎不可自定义；浅/深两主题；打字机滚动 + 焦点模式；设计关键词：克制、"工具隐身"、排版即品牌。最值得学习的细节：用字体与排版而非皮肤建立辨识度；搜索框与大纲/导航合一
- **技术栈**：原生（macOS AppKit、iOS UIKit，多年迭代的自研文本引擎）；非 Electron
- **AI 能力**：反向切入——Authorship 功能追踪并以颜色/灰度标记"哪些字是 AI 写的"（粘贴自 ChatGPT/Claude/Gemini 的文本自动标注，7.3 起集成 Apple Intelligence 校对也计入），刻意不内置生成式续写
- **可借鉴点**：1) "少即是多"的单栏排版与自研字体策略，是"简洁好看"的天花板参照；2) Authorship 的"AI 透明度"思路可与我们的 AI 功能互补（生成 + 标注）；3) 命令面板（⇧⌘P）作为低 UI 成本的功能入口
- **不足**：社区常见抱怨：几乎零自定义（字体/主题被锁死）、文库管理弱不适合长篇项目、各平台单独收费且 iOS 从 $20 涨到约 $50 引发差评、无 WYSIWYG 对新手不友好

### Ulysses

- **基本信息**：开发者 Ulysses GmbH & Co. KG（德国莱比锡）｜macOS / iOS / iPadOS｜订阅制：$5.99/月或 $39.99/年（一份订阅覆盖全平台，支持家庭共享），14 天试用，学生优惠；无买断；也包含在 Setapp 中；停止付费后进入只读模式｜官网 ulysses.app｜闭源｜维护活跃（持续大版本更新）
- **编辑模式**：源码样式化实时渲染（标记着色、图片/脚注等以"气泡"内联呈现），介于纯源码与 WYSIWYG 之间；预览仅在导出时
- **核心功能**：自有方言 Markdown XL（28 个标记定义：脚注、注释、批注、内联注记等），也可切换标准 Markdown/Minimark/Textile'd；Sheet/Group 层级文库（专有 .ulyz 格式）+ External Folders 模式直接编辑纯 .md；写作目标（字数/截止日）、写作统计、内置语法与风格检查（20+ 语言，基于 LanguageTool）、关键词/筛选器、全文搜索、iCloud 同步与版本备份；导出 md/txt/HTML/ePub/PDF/DOCX，一键发布 WordPress/Ghost/Medium/Micro.blog
- **UI 设计**：经典三栏（组/清单/编辑器），可逐级收起到纯编辑单栏；主题市场（社区主题可下载）、打字机模式、深浅色；设计关键词：优雅、"作家的 IDE"。最值得学习的细节：三栏逐级折叠的信息层次；附件栏（笔记/关键词/目标）挂在纸面之外不干扰正文
- **技术栈**：原生 AppKit / UIKit（自研文本引擎，德企老牌 Cocoa 团队）
- **AI 能力**：无内置生成式 AI（截至调研；校对为传统 NLP）
- **可借鉴点**：1) 三栏布局 + 逐级折叠是"文库型编辑器"的标准答案；2) "目标/统计/关键词放附件栏"的非侵入式功能挂载；3) 直接发布到博客平台是留存利器
- **不足**：订阅制是差评核心（从买断转订阅至今仍被反复提起）；.ulyz 专有格式锁定；仅 Apple 平台；对 Markdown 纯粹主义者来说方言偏离标准

### Bear

- **基本信息**：开发者 Shiny Frog（意大利帕尔马小团队）｜macOS / iOS / iPadOS / Apple Watch｜免费版功能完整但单机；Bear Pro $2.99/月或 $29.99/年（7 天试用）解锁 iCloud 多端同步、全部主题、OCR 搜索、更多导出｜官网 bear.app｜闭源｜维护活跃（Bear 2 于 2023-07 发布，此后持续更新）；曾获 Apple Design Award 2017、App Store 年度应用 2016
- **编辑模式**：实时渲染混合——语法标记默认隐藏（Markdown hiding），光标进入时显形，接近 WYSIWYG 但底层仍是 Markdown；无分屏预览
- **核心功能**：自有兼容方言 "Polar Bear"：GFM 表格、任务列表、脚注、代码块（150+ 语言高亮）、LaTeX 数学、[[wiki 链接]] 与反链、YAML front matter、标题/列表折叠、嵌套样式；#嵌套标签# 即打即分类（无文件夹）、TOC 面板、网页剪藏扩展、笔记加密、Sketch 手绘（iPad）；导出 PDF/HTML/DOCX/JPG/MD（部分需 Pro）；全文搜索可搜图片与 PDF 内文字（Pro）；CloudKit 同步；性能：9.4 万词的《白鲸记》55ms 打开
- **UI 设计**：三栏（标签/笔记列表/编辑器）可折叠；大量精致主题（Pro）与可换图标；排版细腻、红色主题色辨识度高；设计关键词：亲切、精致、"最漂亮的笔记 app"。最值得学习的细节：语法隐藏的实现颗粒度（选中即显、离开即藏）；标签即组织的零管理成本
- **技术栈**：原生 UI + 自研跨平台编辑器内核（即多年打磨的 "Panda" 编辑器项目，曾以独立测试版发布，后并入 Bear 2；官方称核心大部分代码跨 Mac/iPad/iPhone 共享）
- **AI 能力**：无
- **可借鉴点**：1) "隐藏标记式"实时渲染是原生 Markdown 所见即所得的最佳工程范本；2) 免费单机 + 付费同步的定价漏斗；3) 主题系统作为付费点与社区传播点
- **不足**：常见抱怨：笔记存在内部 SQLite 库而非纯文件（导出才是 md）、免费版无同步、无 Web/Windows 版、协作缺失；"为自己设备间同步付费"在 Reddit 上长期被吐槽

### Byword

- **基本信息**：开发者 Metaclassy, Lda.（葡萄牙）｜macOS / iOS｜买断：Mac $10.99、iOS $5.99（历史价格有浮动）｜官网 bywordapp.com（仍在售但无动态）｜闭源｜**事实停更**：Mac v2.9.6 自 2023-10、iOS v2.9.3 自 2020-04 未再更新，开发商无公开声明
- **编辑模式**：单栏纯源码 + 语法淡化着色，⌥⌘P 切换预览；无分屏
- **核心功能**：Markdown/MultiMarkdown（表格、脚注、交叉引用）；纯文本文件存储于 iCloud/Dropbox 任意文件夹（无锁定）；导出 HTML/PDF/RTF/DOCX；历史上以内购 Premium 提供发布到 WordPress/Medium/Blogger/Tumblr/Evernote；打字机滚动、段落/行聚焦、字数统计、全键盘操作
- **UI 设计**：极简单栏、浅/深主题、以"流畅打字手感"著称（少数派早年评为"最流畅的写作体验"）；设计关键词：安静、无 chrome。最值得学习的细节：光标移动与滚动动画的手感打磨
- **技术栈**：原生 AppKit / UIKit
- **AI 能力**：无
- **可借鉴点**：1) 打字手感（滚动、光标、动画）本身就是核心卖点；2) "纯文件 + 任意文件夹"零锁定策略赢得口碑
- **不足**：弃更是唯一但致命的问题；社区共识是"老用户可继续用，新用户别买"——也证明了简洁编辑器若无持续收入难以为继

### MWeb Pro

- **基本信息**：开发者 coderforart（中国独立开发者，2015 年发布）｜macOS / iOS / iPadOS｜MWeb Pro 官网买断 $34.99（终身、14 天试用、无订阅），App Store 另有版本｜官网 mweb.im｜闭源｜维护活跃（2025 年持续更新 4.7.x：升级 Mermaid 11.14、iCloud 同步修复工具等）
- **编辑模式**：源码 + 分屏实时预览（Editor & Preview 模式），编辑区内联显示图片与公式/图表预览
- **核心功能**：CommonMark + GFM 全家桶：表格、TOC、任务列表、脚注、数学公式、代码块、Mermaid、ECharts 图表；图片粘贴直接入库并内嵌显示（jpg/png/gif/webP/HEIC）；四模块结构：编辑器、外部文件夹模式（直接管理任意 .md 目录）、文库模式（分类树 + 标签、一文多分类）、发布模块；导出 Image/HTML/ePub/PDF/RTF/Docx，整个分类可导出 ePub/PDF；发布到 WordPress/Metaweblog API/Evernote/Blogger/Medium/Tumblr；**静态博客生成**（Pro 独有）；iCloud 同步；表格生成/格式化工具、大纲视图
- **UI 设计**：三栏文库布局；11 款浅色 + 21 款深色主题，支持自定义主题；对中文排版友好；设计关键词：功能密集、工具向。可学习细节：外部文件夹与内置文库双模式并存的架构
- **技术栈**：原生（macOS AppKit、iOS UIKit，官方明确宣传非 Electron）；预览为 WebView 渲染
- **AI 能力**：未知（未见官方 AI 功能）
- **可借鉴点**：1) "文库 + 外部文件夹"双模式同时满足笔记党和纯文件党；2) 图片粘贴自动入库的处理流程；3) 中文用户群运营（Markdown + 发布 + 静态站一条龙）
- **不足**：界面精致度不如 Ulysses/Bear（功能多但视觉平平）；英文市场知名度低；单人开发风险

### Marked 2

- **基本信息**：开发者 Brett Terpstra（美国，nvALT 作者）｜macOS 专用（预览器而非编辑器）｜买断 $13.99（Paddle 官网直售 + Mac App Store，官网有试用）｜官网 marked2app.com｜闭源｜维护活跃：2.6.45（2025-03）、2.6.46 加入 Mermaid 渲染；另有资料称 2026-05 已发布下一代 Marked 3
- **编辑模式**：无编辑功能——纯预览/校对/导出工具，监视任意编辑器保存的文件实时刷新并自动滚动到最近编辑处；可监视整个文件夹（自动显示最近修改的文档）
- **核心功能**：MultiMarkdown 6 + GFM（含换行保留、围栏代码）+ CriticMarkup + Fountain；支持自定义处理器（可接 Pandoc 等任意命令行）；自动 TOC、数学公式、Mermaid、文本折叠；导出 HTML（可内嵌资源的单文件）/PDF/DOCX 多种样式；自定义 CSS 主题并实时热载（可当网页排版调试器用）；写作统计、可读性指数、重复词/填充词校对工具；与几乎所有编辑器（含本清单多数产品）联动
- **UI 设计**：单窗口预览 + 丰富样式库；设计关键词：工具箱、写作者的"第二屏"
- **技术栈**：原生 AppKit + WebKit 渲染管线
- **AI 能力**：无
- **可借鉴点**：1) "编辑与预览解耦"的产品哲学——预览可以是独立窗口/独立能力；2) 自定义处理器（外接 Pandoc/脚本）的开放架构；3) 校对统计工具集是被低估的差异化点
- **不足**：MAS 版无试用被差评；不能读 Ulysses 专有库（需 External Folders）；新手不理解"没有编辑功能"的定位

### Highland 2（→ Highland Pro）

- **基本信息**：开发者 Quote-Unquote Apps（编剧 John August 团队）｜macOS（Highland Pro 扩展至 iPad/iPhone，各平台 100% 原生）｜Highland 2 原为 $49.99 买断（免费写作、付费去水印导出），**已停售**；2024 年起由订阅制 Highland Pro 取代：$4.99/月（年付）或 $9.99/月，30 天试用；订阅过期仍可打开/打印/导出（不锁文件）｜官网 quoteunquoteapps.com/highland-pro｜闭源｜Highland 2 停更、Highland Pro 活跃
- **编辑模式**：纯文本语法样式化实时渲染（Fountain 剧本语法为主 + 支持 Markdown 写散文/大纲），所见接近成稿
- **核心功能**:以写作流程见长：Scratchpad 草稿区、The Shelf（侧边拖放暂存架）、/Lookup 行内查询研究、Sprints 写作冲刺计时、Revision 修订模式、目标与统计、模板；导出 PDF/FDX（Final Draft）等；iCloud 同步
- **UI 设计**：单栏纸面感、极度干净；设计关键词：纸、专注、作家工具。最值得学习的细节：The Shelf——把"暂时不要但舍不得删"的文字拖到侧栏暂存，解决写作者真实痛点
- **技术栈**：原生 Mac 应用（官方强调 native，非跨平台框架）
- **AI 能力**：无（/Lookup 为词典/维基查询，非生成式）
- **可借鉴点**：1) The Shelf 式的文本暂存交互；2) "订阅过期不锁内容"的良性订阅设计；3) 斜杠命令（/Lookup）在纯文本界面中的运用
- **不足**：Markdown 只是配角（核心是 Fountain 剧本）；买断转订阅引老用户不满；Mac 之外生态弱

### Taio

- **基本信息**：开发者 颖钟 Ying Zhong（网名 cyan，JSBox 与 MarkEdit 同一作者）｜iOS / iPadOS / macOS 通用购买｜免费 + Taio Pro 内购：$1.49/月、约 $10.49–14.99/年、买断 $29.99–46.99（区域浮动）｜官网 taio.app｜闭源｜**近乎停更**：v1.68.0 最后更新 2023-09-13（开发者重心已转向 Mac 开源应用 MarkEdit 等）
- **编辑模式**：源码高亮 + 预览切换；多标签页同时编辑
- **核心功能**：100% 兼容 CommonMark 与 GFM；全文搜索、大纲视图、数学公式与图表、标签 / wiki 链接 / 反向链接、内置图床上传、焦点模式、多主题、代码语法高亮；**文本动作系统**：类快捷指令的积木式工作流 + 可用 JavaScript 写自定义动作块（JSBox 引擎，含大量 iOS API 绑定）；剪贴板管理（iCloud 同步、桌面小组件）；文件基于 Files/iCloud Drive，无私有格式
- **UI 设计**：iOS 原生规范、清爽克制；设计关键词：极客、模块化。可学习细节：编辑器 + 自动化动作的"文本处理中枢"定位
- **技术栈**：原生 UIKit，macOS 端为 Mac Catalyst
- **AI 能力**：无内置（理论上可用 JS 动作调 API）
- **可借鉴点**：1) JavaScript 动作扩展让轻量编辑器获得无限可能——与我们"接入 AI"天然契合（AI 即一类动作）；2) 通用购买 + 免费增值定价
- **不足**：两年多未更新令付费用户不安；Catalyst 的 Mac 体验不如纯 AppKit 应用；社区规模小

### Drafts

- **基本信息**：开发者 Agile Tortoise（Greg Pierce，美国）｜iOS / iPadOS / macOS / watchOS / visionOS｜免费可用核心功能；Drafts Pro 约 $19.99/年（或 $1.99–2/月），解锁动作编辑、主题、Workspaces 等；支持家庭共享｜官网 getdrafts.com｜闭源｜维护非常活跃（MacStories 2025 年度应用；Drafts 48 已适配 OS 26 与 Apple Intelligence）
- **编辑模式**：纯源码 + 可切换语法高亮定义；Mac/iPad 提供随保存刷新的 HTML 实时预览窗（内置 Basic/Foghorn/Swiss 三套模板 + 自定义模板）
- **核心功能**：定位"文字的起点"——打开即键盘就绪的收件箱；双解析器可选：MultiMarkdown 6 与 cmark-gfm（各自扩展可配置），另有 Taskpaper、自定义语法定义（Pro）；标签 + Workspaces 组织、全文搜索、iCloud 同步、版本历史；**动作系统**为灵魂：数百个社区动作（发送到邮件/日历/Obsidian/博客等）、JavaScript 脚本引擎、URL scheme 自动化
- **UI 设计**：单栏 + 抽屉式列表；主题与图标可换（Pro）；设计关键词：快、键盘优先、管道枢纽。可学习细节：打开 App 0 秒进入输入状态的"捕捉优先"体验
- **技术栈**：原生（iOS UIKit；Mac 为共享核心的原生应用，非 Electron）
- **AI 能力**：无内置功能，但官方提供 `OpenAI()` 脚本对象（可接 OpenAI/xAI/DeepSeek/Perplexity，自带 API key），Drafts 48+ 提供 `SystemLanguageModel` 脚本对象直调 Apple Intelligence 端上模型；社区已有 Ask ChatGPT、Modify Selection 等成熟动作
- **可借鉴点**：1) "脚本对象 + 社区动作目录"是编辑器接入 AI 的低维护成本模式；2) 端上模型（Apple Foundation Models)接口值得跟进；3) 免费核心 + Pro 扩展权的订阅分层
- **不足**：笔记存内部库非纯文件（导出/动作可补救）；UI 朴素、学习曲线陡；"什么都能做"导致定位模糊

### 1Writer

- **基本信息**：开发者 Ngoc Luu（独立开发者）｜iOS / iPadOS 专属（无 Mac 版）｜$4.99 买断 + 自愿小费罐，无订阅｜官网 1writerapp.com｜闭源｜维护低频但未死：最近更新 2025-09-24（v3.3.x）
- **编辑模式**：单栏源码 + 行内轻量预览（inline preview）
- **核心功能**：Markdown/纯文本编辑；iCloud Drive / Dropbox / WebDAV 多后端同步；扩展键盘行（符号/快捷操作）；**JavaScript 动作扩展**（社区共享动作）；TextExpander、x-callback-url 自动化；待办勾选、图片插入、字数统计、深色主题、全文搜索
- **UI 设计**：iOS 经典单栏极简；设计关键词：老派、实用。可学习细节：编辑键盘扩展行的按键编排
- **技术栈**：原生 UIKit
- **AI 能力**：无
- **可借鉴点**：1) 买断 + 小费的可持续独立开发模式口碑极好（"没有订阅套路"是五星评论高频词）；2) JS 动作是移动端扩展性的标配答案
- **不足**：无 Mac 版；更新节奏慢、UI 多年未翻新；WebDAV/Dropbox 偶发同步问题

### iWriter Pro

- **基本信息**：开发者 Serpensoft Group｜macOS / iOS（各自买断）｜Mac 约 $9.99–11.99 买断（不同渠道/时期），iOS 单独购买且常有半价促销；无订阅｜官网 serpensoft.com/iwriter-pro｜闭源｜维护活跃（当前版本要求 macOS 15.6+，说明近期仍在更新）
- **编辑模式**：源码高亮 + 分屏预览（滚动同步）
- **核心功能**：MultiMarkdown 6 完整支持（表格、脚注）；LaTeX 数学、Mermaid/流程图、预览内代码高亮；导出 HTML/PDF/RTF/EPUB/LaTeX/DOCX；打字机模式（句/行/段聚焦）；QuickLook 插件（Finder 直接预览 md）；iCloud 跨设备同步；大文件流畅编辑；字/词/句/段统计
- **UI 设计**：明显对标 iA Writer 的极简单栏；设计关键词：干净、廉价版 iA。App Store 均分约 4.7
- **技术栈**：原生 AppKit / UIKit
- **AI 能力**：无
- **可借鉴点**：1) 证明"iA Writer 式体验 + 1/5 价格 + 无订阅"存在真实市场（大量评论自述从 Ulysses/iA 迁来）；2) QuickLook 插件是低成本高感知的系统集成
- **不足**：评论区报过查找失效（2024-08）、iPad 启动崩溃、Dropbox 绑定失败等质量问题；被指"模仿 iA Writer"缺乏原创性

### NotePlan

- **基本信息**：开发者 NotePlan LLC（Eduard Metzger，柏林创立，2016）｜macOS / iOS / iPadOS + Web（beta）｜订阅制：约 $8.33/月（年付，约 $100/年），月付更贵；7 天试用；无免费档（到期变只读）；含在 Setapp 中｜官网 noteplan.co｜主程序闭源（插件生态开源在 GitHub）｜维护活跃
- **编辑模式**：实时渲染混合（语法样式化 + 标记淡化），任务/日期等元素交互化
- **核心功能**：任务 + 笔记 + 日历三合一（Bullet Journal 思路）：自动生成每日/每周/每月/每年笔记；Markdown 任务语法、日程时间块（任务拖到日历）、Apple/Google 日历与提醒事项集成；[[wiki 链接]] 与反链、标签、模板引擎、**JavaScript 插件系统**、主题完全自定义（JSON 定义字体/颜色/正则匹配样式）；数据为本地 Markdown 文件，CloudKit 同步、离线优先
- **UI 设计**：三栏（侧栏/列表/编辑器）+ 右侧日历时间轴；设计关键词：生产力仪表盘。可学习细节：主题用 JSON + 正则自定义任意语法元素样式的机制
- **技术栈**：原生 Swift（官方反复强调 native、非 Electron；Mac 端具体框架未公开确认）
- **AI 能力**：**内置 AI**（本类别唯一深度集成者）：⌘O 呼出带上下文的 AI 提示（可把笔记/文件夹加入上下文）、生成/改写/总结、语音录音转写入笔记
- **可借鉴点**：1) 本类别唯一的"原生 + 本地 Markdown + 内置 AI"样本，其"选笔记作为上下文再提问"的交互直接可参考；2) JSON 主题 + 插件的开放性；3) 纯文本文件 + CloudKit 的同步架构
- **不足**：约 $100/年被普遍嫌贵；Apple-only、Web 版弱；功能密集导致上手门槛高；非日历用户觉得"太重"

### nvUltra

- **基本信息**：开发者 Brett Terpstra + Fletcher Penney（MultiMarkdown 作者）｜macOS｜**未正式发布**：约 2019 年起私测至今，2026-05 仍在发 "Mark II" beta，价格与发售日未定（官网购买按钮"coming soon"）｜官网 nvultra.com｜闭源｜状态：七年私测，社区戏称 vaporware
- **编辑模式**：源码 + 预览；核心交互是 Notational Velocity 式 omnibar——一个输入框同时完成搜索/新建（搜不到即回车新建）
- **核心功能**：任意文件夹皆可为库（多库并开）、闪电全文搜索、MultiMarkdown 完整支持、标签、文件夹加密、纯文本文件零锁定、外部编辑器联动
- **UI 设计**：单窗三段（搜索框/列表/编辑器）；设计关键词：键盘流、搜索即入口
- **技术栈**：原生 AppKit
- **AI 能力**：无
- **可借鉴点**：1) omnibar"搜索与新建合一"是笔记型编辑器最高效的入口设计（FSNotes/MiaoYan 均继承）；2) 反面教训：完美主义拖延发布会耗尽社区耐心
- **不足**：不发布本身就是最大不足；等待者已大量流向 FSNotes/Obsidian

### FSNotes

- **基本信息**：开发者 Oleksandr Hlushchenko（乌克兰）｜macOS / iOS｜开源免费（MIT），GitHub glushchenko/fsnotes 约 7.4k star、约 570 fork；GitHub Releases 免费下载，App Store 付费版为"象征性价格"的支持渠道，无订阅｜官网 fsnot.es｜维护活跃：FSNotes 7 于 2026-01 发布，7.2.1 更新于 2026-06，最近推送 2026-07
- **编辑模式**：源码高亮为主 + 预览切换（WebView 渲染）；nvALT 精神续作
- **核心功能**：GFM；单窗 omnibar 搜索即新建；10k+ 文件依然流畅；代码块 30+ 语言高亮、行内图片、[[wiki 链接]]、标签、Mermaid、MathJax；AES-256 笔记加密；**Git 版本控制与备份**内置；外部编辑器修改实时热载；iCloud Drive / Dropbox 等任意文件夹同步；多库多文件夹
- **UI 设计**：单窗三段（搜索/列表/编辑），朴素工具风；深浅色；设计关键词：快、键盘流、工程师审美。可学习细节：以文件系统为唯一真相源（app 只是视图）的架构
- **技术栈**：Swift 5 原生（AppKit/UIKit + TextKit）
- **AI 能力**：无
- **可借鉴点**：1) "开源 + GitHub 免费 + App Store 付费支持"的双渠道模式可直接复用；2) Git 做版本历史是开源编辑器的优雅方案；3) 纯文件架构换来的零锁定口碑
- **不足**：HN/Reddit 常见抱怨集中在稳定性（崩溃/同步毛刺）与 UI 设计感不足；iOS 版体验明显弱于 Mac 版

### MiaoYan (妙言)

- **基本信息**：开发者 tw93（中国独立开发者）｜macOS 专属（11.5+）｜开源免费（MIT），GitHub tw93/MiaoYan 约 8.4k star、约 500 fork，最近推送 2026-07；安装：GitHub Releases / Homebrew 免费，另上架 Mac App Store（付费版，作为支持开发者渠道，同一代码库）｜官网即 GitHub 仓库｜维护活跃（已适配 macOS 26 玻璃质感）
- **编辑模式**：纯源码高亮为主，⌘\ 一键切换分屏实时预览（60fps 双向滚动同步）；官方明确不做 WYSIWYG——认为原生 Swift 实现所见即所得复杂度与可靠性代价过高，"纯净编辑 + 即时分屏"是折中
- **核心功能**：本地优先（只读写用户选定的 Markdown 文件夹，不内置账号/云；跨设备靠 iCloud Drive/坚果云/Dropbox 客户端）；LaTeX、Mermaid、[[wiki 链接]] 反链、版本历史、自动排版格式化（含中英文混排自动加空格）、**妙言 PPT**（Markdown 一键变演示文稿）、全文搜索、导出图片/PDF 等；无数据收集
- **UI 设计**：单窗三栏（文件夹/文件列表/编辑器）可收起；默认精选中文友好字体、间距为中文阅读调校；深色模式、极简"高颜值"是核心卖点（大量用户自称从 Typora 迁来）；设计关键词：妙、美、快、简。可学习细节：中文排版细节（字体、字间距、自动空格）作为差异化
- **技术栈**：Swift 6 原生（AppKit），仅 23MB；项目初始结构参考 FSNotes（README 致谢）
- **AI 能力**：无（README 未提及任何 AI 功能）
- **可借鉴点**：1) 与我们定位最接近的中文样本——证明"原生 + 开源 + 颜值"能拿 8k+ star；2) 中文排版打磨是国产利基；3) "编辑器 + PPT 模式"式的轻量惊喜功能
- **不足**：无 iOS 版、无内置同步、无 WYSIWYG；功能面窄（V2EX 评论认为更适合程序员轻笔记而非重度写作）；单人项目节奏依赖作者精力

### Paper (papereditor.app)

- **基本信息**：开发者 Mihhail Lapushkin（爱沙尼亚独立开发者）｜macOS（14+，仅 Apple Silicon）/ iOS / iPadOS（Mac 与移动端分开购买）｜免费增值：基础功能免费，Pro Features 提供订阅（月/年）与**默认隐藏的一次性买断选项**（需在弹窗点"Show one-time purchase"），试用不限时；具体价格分区域，未知确切数字｜官网 paper.pro（原 papereditor.app）｜闭源｜维护活跃；App Store 约 4.2★
- **编辑模式**：单栏纯源码淡化渲染，无文库——直接打开/新建 .md 文件（文件式而非库式）
- **核心功能**：Markdown / 纯文本；导出 PDF/HTML/RTF/DOCX/ePub/图片/剪贴板；发布 Medium/WordPress/Ghost/Micro.blog；与 Marked 2 联动预览；iCloud 同步；特色功能：write-only 模式（只能写不能删改，对抗自我审查）、打字音效、隐藏字符显示、触控板捏合调字号、Callback URL 自动化
- **UI 设计**：本类别动效与手感的极致——丝滑打字动画、手势驱动、几乎零 chrome；排版个性化极深（行宽/行距/字距/主题全可调，Pro）；设计关键词：优雅、动效、玩具般的愉悦。最值得学习的细节：把"打字的物理愉悦感"（动画/声音/手势）做成产品护城河
- **技术栈**：原生 Mac/iOS 应用（自研渲染，细节未公开；仅支持 M 系芯片侧面说明技术较新）
- **AI 能力**：无
- **可借鉴点**：1) 打字动效与手势是"简洁好看"之上的第二层体验差异化；2) "不限时试用 + 隐藏买断"的温和商业化
- **不足**：Havn 等评测称"最喜欢却最难推荐"：无文库管理（全靠 Finder）、Pro 定价偏贵、用例太窄

### MarkEdit（补充发现）

- **基本信息**：开发者 cyanzhong（Ying Zhong，即 Taio/JSBox 作者）｜macOS 专属｜完全免费开源（MIT），GitHub MarkEdit-app/MarkEdit 约 5.2k star、约 230 fork，最近推送 2026-07-20（极活跃）；安装：GitHub Releases / `brew install --cask markedit`｜维护活跃
- **编辑模式**：纯源码编辑，定位"Markdown 界的 TextEdit"——基于文档而非文库，无内置预览（预览由官方扩展 MarkEdit-preview 提供）
- **核心功能**：严格遵循 GFM 规范、零私有语法；约 4MB 体积、百万行文件流畅、10MB 文件秒开；多光标、代码折叠、查找替换、系统拼写检查；**扩展体系**：CSS/JavaScript/CodeMirror 扩展自定义，官方扩展含 MarkEdit-preview（预览）、MarkEdit-theming（主题）、MarkEdit-ai-writer（AI）
- **UI 设计**：完全贴合 macOS 规范：原生 NSToolbar、自动深浅色、系统控件；设计关键词：克制、系统感、零学习成本
- **技术栈**：**Swift/AppKit 原生外壳 + CodeMirror 6 编辑内核**的混合架构；作者公开解释：深谙 TextKit 1/2 仍选 CodeMirror，因原生生态没有能与 CodeMirror/Monaco 竞争的编辑内核，多光标与折叠在 TextKit 上实现代价过高——对我们的内核选型是第一手参考
- **AI 能力**：官方扩展 MarkEdit-ai-writer 接入 Apple Intelligence（macOS Tahoe 端上模型）实现 AI 辅助写作
- **可借鉴点**：1) 与我们目标（原生、简洁、开源、AI）重合度最高的现存项目，是最直接的对标与差异化对象；2) "原生壳 + CodeMirror 芯"的务实内核路线及其取舍论证；3) AI 做成可选扩展而非内置，保持主程序极简
- **不足**：无预览开箱即用（要装扩展）、无文库/同步/移动端；对非技术用户功能过素

### MacDown（补充发现）

- **基本信息**：开发者 Tzu-ping Chung（uranusjr）与社区｜macOS｜免费开源（MIT）；GitHub MacDownApp/macdown 约 9.8k star、约 1.16k fork｜官网 macdown.uranusjr.com｜**事实停更**：最后推送 2023-07；2025 年后出现社区复刻"MacDown 3000"尝试延续
- **编辑模式**：经典双栏分屏——左源码右 WebView 实时预览
- **核心功能**：Hoedown C 解析器（GFM、表格、任务列表）、MathJax 数学、Prism 代码高亮、Jekyll front matter 渲染、自定义 CSS 主题、导出 HTML/PDF；命令行工具 `macdown`
- **UI 设计**：朴素双栏工具风；设计关键词：程序员的免费默认选择（2014–2019 时代）
- **技术栈**：Objective-C + AppKit + Hoedown（C）+ WebView；Mou 的开源精神续作
- **AI 能力**：无
- **可借鉴点**：1) 曾长期占据"Mac 开源 Markdown 编辑器"生态位，其停更留下的空位正是我们的机会；2) 近万 star 证明该生态位的天然流量
- **不足**：停更、界面陈旧、对 Apple Silicon/新系统适配存疑

### Notenik（补充发现）

- **基本信息**：开发者 Herb Bowie（美国，作家/退休工程师）｜macOS 专属｜完全免费开源（MIT，无内购无广告），Mac App Store 全功能免费；GitHub hbowie/Notenik-25（最新代码库，star 数较少，具体未知）｜官网 notenik.app｜维护活跃（2025 年起在新仓库持续提交，更新频率很高）
- **编辑模式**：编辑/显示双 Tab 切换（非实时渲染）；Markdown + 结构化字段
- **核心功能**：每条笔记 = 纯文本文件 + 可自定义元数据字段（每个集合可定义自己的字段模板与排序）；wiki 链接、标签、任务字段；**静态网站生成**与网页发布能力突出；模板与脚本自动化；Zettelkasten 社区口碑好
- **UI 设计**：双栏工具风，谈不上漂亮；设计关键词：数据化笔记、个人 CMS
- **技术栈**：Swift + AppKit 原生
- **AI 能力**：无
- **可借鉴点**：1) "笔记 + 结构化字段"展示了纯文本之上做元数据的可能性；2) 独立作者长期高频维护的开源可持续样本
- **不足**：UI 复杂且缺乏现代设计；学习曲线陡；知名度低

### Mou（补充·历史条目）

- **基本信息**：开发者 Chen Luo（中国独立开发者）｜macOS｜免费/捐赠（后期尝试众筹 1.0 转付费未果）｜官网已停｜闭源｜**已停更**（约 2015–2016 年后无更新），是 2012–2015 年间 Mac 中文圈最流行的 Markdown 编辑器
- **编辑模式**：双栏分屏实时预览
- **核心功能**：GFM 基础语法、自定义 CSS、导出 HTML/PDF、当年对中文支持最佳（少数派 2015 年评"对中文支持最好的 Markdown 编辑器"）
- **UI/技术栈**：原生 AppKit + WebView 预览
- **AI 能力**：无
- **可借鉴点 / 教训**：免费聚拢巨大用户群但无收入模型，众筹转型失败即停更——开源免费产品需要提前想好可持续机制（捐赠/企业赞助/App Store 支持版）
- **不足**：已死；其真空先后由 MacDown（开源复刻）与 Typora 填补

---

## 本类别小结

**共性与趋势**

- 编辑模式三分天下：纯源码派（iA Writer、MarkEdit、MiaoYan、FSNotes——理由都是"专注/可靠"）、隐藏标记实时渲染派（Bear、Ulysses、NotePlan——体验最好但工程量最大）、双栏分屏派（MWeb、MacDown、iWriter Pro——实现最容易，正在过时）。原生阵营公认：TextKit 上做完整 WYSIWYG 极难，Bear 为此自研跨平台内核，MiaoYan 明确放弃，MarkEdit 干脆用 CodeMirror。
- 商业模式分层清晰：头部转订阅（Ulysses $39.99/年、Bear $29.99/年、NotePlan 约 $100/年、Highland Pro），中坚高价买断（iA Writer $49.99、MWeb $34.99），长尾低价买断多数停更（Byword、Taio、1Writer 勉力维持）。开源产品普遍用"GitHub 免费 + App Store 付费支持版"回血（FSNotes、MiaoYan）。
- 停更率极高：种子清单 16 个里 Byword、Taio、Highland 2、Mou 已停或停售，nvUltra 七年未发布，MacDown 停更——"简洁 Markdown 编辑器"是低门槛红海，活下来靠的是明确的差异化（字体排版/任务日历/自动化/开源社区）。
- 纯文本文件、零锁定、iCloud 文件夹同步已成本类共识与口碑来源；专有库格式（Ulysses/Bear/Drafts）持续被社区扣分。
- AI 现状：NotePlan 内置（带上下文提问）、iA Writer 做 AI 标注、Drafts/MarkEdit 走脚本与 Apple Intelligence 扩展、其余全部空白——**尚无一款"简洁原生编辑器 + 一流 AI 体验"的产品**。

**对我们产品的启示**

- 生态位判断：MacDown 停更、Mou 已死、MarkEdit 刻意极简无预览、MiaoYan 无 AI 无移动端——"原生 macOS + 开源 + 好看 + AI"四要素叠加目前无人占据，定位成立。
- 内核选型是第一决策：要么学 MarkEdit（AppKit 壳 + CodeMirror 6 芯，快速获得多光标/折叠/性能，代价是非纯原生文本栈），要么学 Bear/MiaoYan（TextKit 自研，纯原生但 WYSIWYG 成本极高）。建议先做"源码样式化 + 标记淡化"（Bear 式轻渲染），回避完整 WYSIWYG。
- 必抄的交互：omnibar 搜索即新建（nvUltra/FSNotes）、命令面板 ⇧⌘P（iA Writer 8）、语法标记"选中显形"（Bear）、The Shelf 暂存（Highland）、⌘\ 一键分屏（MiaoYan）。
- 数据架构：本地 .md 文件夹为唯一真相源 + iCloud Drive 同步 + Git 版本历史（FSNotes 方案），换取零锁定口碑。
- AI 设计参考：NotePlan 的"选笔记为上下文再提问"、Drafts 的"AI 即动作/脚本"、MarkEdit 的"AI 即可选扩展"、iA Writer 的 Authorship 标注——建议组合：核心极简 + AI 作为可开关模块（支持自带 key 与 Apple 端上模型），并提供 AI 文本溯源标注。
- 商业与社区：MIT 开源 + GitHub Releases 免费 + MAS 付费支持版是被验证的可持续路径；中文排版细节（MiaoYan 的字体与自动空格）是国产项目的天然差异化。
- 设计基准：单栏排版对标 iA Writer，主题与图标体系对标 Bear，动效手感对标 Paper；"用字体与留白建立品牌"比堆主题更重要。
