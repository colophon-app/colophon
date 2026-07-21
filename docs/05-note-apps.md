# 闭源 / 商业笔记与文档应用中的 Markdown

> 类别总体观察：这一类产品的共同范式是「块编辑器 + Markdown 快捷输入」——Markdown 在这里不是存储格式，而是一套输入语法糖（`#` + 空格出标题、`**` 出粗体、`/` 唤起斜杠菜单）和一种导出/迁移格式；数据真正存放在私有块模型（Notion blocks、语雀 Lake、Anytype Any-Block 等）里，因此「导出保真度」几乎是全类别的通病：数据库变 CSV、多列布局丢失、块引用断链。Obsidian 是本类别中的异类与最大赢家：应用本体闭源，但以「本地 .md 文件 + 开放插件 API + 免费核心」换来了数据主权口碑与近 5000+ 插件的生态。2025–2026 年两大趋势明显：一是 AI 全面入场（Notion Agents、Tana 会议 agent、Craft 端侧模型），且 Markdown 被官方（如飞书）明确定位为「交给 AI 处理的格式」；二是对云端闭环的反弹——Reflect 推出开源本地 Markdown 版 Reflect Open、Anytype 以本地优先 + 源码开放立足，说明「本地 md + 可接 AI」正是当下的风口位置。调研截至 2026-07-21。

---

### Notion

- **基本信息**：Notion Labs Inc.（旧金山）｜macOS / Windows / iOS / Android / Web｜免费版 + Plus $10/人/月（年付，月付 $12）+ Business $20/人/月（年付，月付 $24）+ Enterprise 定制；2025-05 取消 $8/月 AI 附加包、AI 并入 Business 档；2026-05 起 Custom Agents 另按 $10/1000 credits 计量｜官网 notion.com｜闭源，无 GitHub 仓库｜维护活跃（2025-08 v2.53 上线离线模式；2026-02 上线 Markdown Content API）
- **编辑模式**：块编辑器所见即所得，无源码/分屏模式；Markdown 作为输入语法糖存在（`#`、`**`、`` ``` `` 等即时转换），`/` 斜杠命令插入全部块类型；粘贴 Markdown 文本可自动解析为块
- **核心功能**：数据库（表格/看板/日历/时间线/画廊，含公式、关联、汇总）、代码块、KaTeX 公式、任务列表、同步块、模板；导出 Markdown & CSV / HTML / PDF（整站 PDF 仅 Business+）；导入 md/CSV/Evernote 等；离线模式（2025-08，基于 CRDT 合并，需逐页逐设备手动标记，免费版数据库限 50 行）；版本历史免费版 7 天 / Plus 30 天；全文搜索 + Enterprise Search；无插件系统但有公开 API / Webhooks；2026-02 的 Markdown Content API 允许直接用「Enhanced Markdown」读写页面，被视为对 AI/Agent 场景的让步
- **UI 设计**：三栏（可折叠侧边栏 + 正文 + 评论/属性面板）；灰白极简、大量留白、emoji + 封面图的页面头部；块 hover 才出现拖拽手柄（⠿）和 `+` 按钮，是「界面安静、能力藏在悬停里」的教科书案例；字体仅提供 Default/Serif/Mono 三档全局切换；无打字机模式
- **技术栈**：Web（React）+ 桌面 Electron 壳；自研 contenteditable 块编辑器与私有块数据模型
- **AI 能力**：深度绑定：AI 写作/改写/翻译、Ask Notion 问答、Research Mode、AI Meeting Notes、Notion Agents（可选 GPT-5、Claude Opus 4.1、o3 等多模型）；仅 Business/Enterprise 可用
- **可借鉴点**：1) 斜杠命令 + Markdown 快捷输入的混合输入范式已成用户肌肉记忆，值得原生实现；2) 块 hover 交互与「安静界面」的克制设计；3) AI 与文档上下文（而非泛聊天）结合的产品思路
- **不足**：论坛常见抱怨：性能慢、页面加载卡顿（Electron + 云端架构）；Markdown 导出保真度差（数据库导成 CSV、公式/关联/多列丢失，整站导出可能耗时数天甚至失败）；离线模式限制多且来得太晚；AI 锁进 Business 档被视为变相涨价；重度依赖网络与私有格式的锁定感

### Obsidian

- **基本信息**：Dynalist Inc.（Obsidian 团队，创始人 Shida Li、Erica Xu，现 CEO Steph Ango）｜macOS / Windows / Linux / iOS / Android｜核心应用完全免费（2025-02-20 起商用许可改为可选的 $50/人/年支持性质付费）；Sync $4/月（年付，月付 $5）；Publish $8/月/站点（年付）；Catalyst $25 一次性打赏档｜官网 obsidian.md｜应用本体闭源，GitHub 仅开放插件登记仓库（obsidianmd/obsidian-releases）与 API 类型定义；社区插件绝大多数开源｜维护非常活跃（2025 年移动端启动降至 0.5s 内、核心插件 Bases 上线；2026 年新社区插件目录 + 插件自动安全扫描/安全记分卡）
- **编辑模式**：三态：源码模式 / Live Preview（实时渲染、光标处显示语法）/ 阅读视图，Cmd+E 一键切换——是「源码派」与「所见即所得派」之间最被认可的折中方案
- **核心功能**：CommonMark + GFM（表格、任务列表）、`[[wiki 链接]]`、脚注、LaTeX（MathJax）、Mermaid、callout、块引用嵌入；笔记即本地 .md 文件（vault = 普通文件夹）；反向链接、局部/全局关系图谱；Canvas 白板（开放 JSON Canvas 格式）；Bases 数据库视图（2025，用 YAML 定义、基于笔记属性）；社区插件约 4000–5800 个（Dataview 下载 390 万+、Excalidraw 500 万+）、主题数百；全文搜索快；Sync 端到端加密、含版本历史；本地 File Recovery 快照
- **UI 设计**：三栏可折叠 + 工作区多标签/分屏；命令面板（Cmd+P）；主题即 CSS，深度可定制（Minimal、AnuPpuccin 等知名主题）；有专注模式与社区打字机滚动插件；设计关键词：工具感、可塑性；最值得学习的细节：Live Preview 的光标邻近语法展开
- **技术栈**：Electron（刻意不用重前端框架，性能口碑好于一般 Electron 应用），编辑内核 CodeMirror 6；移动端 Capacitor
- **AI 能力**：官方无内置 AI；生态补位：Copilot、Smart Connections、Text Generator 等插件支持 OpenAI/Anthropic/本地 Ollama；因数据是本地纯文本，Claude Desktop、MCP、脚本等外部 AI 可直接读写 vault——「file over app」天然 AI-friendly
- **可借鉴点**：1) 成功公式 = 本地 md 数据主权 + 免费核心 + 付费增值服务（Sync/Publish）+ 开放插件 API，闭源应用也能赢得开源社区式忠诚；2) Live Preview 编辑模式设计；3) 把「格式开放」（.md、JSON Canvas）当作产品承诺来营销
- **不足**：Reddit/HN 常见抱怨：Electron 非原生观感与内存占用（HN 长期争论点）；上手曲线陡、「配置文化」劝退普通用户（社区标准建议是「先裸用两周」）；移动端体验弱于桌面（图片处理是头号槽点）；无原生协作；Sync 单独收费让新手困惑

### Craft

- **基本信息**：Craft Docs Limited（布达佩斯，创始人 Balint Orosz）｜macOS / iOS / iPadOS / visionOS / Windows / Android（2025-11）/ Web｜Starter 免费（约 1500 块、1GB、限 10 文档级轻量使用）；Plus $8/月（年付约 $4.8/月）；Family $15/月（年付 $9）；Team $50/月｜官网 craft.do｜闭源｜维护活跃（Craft 3 世代，2026 持续更新；2021 年 Mac App Store 年度应用）
- **编辑模式**：块式所见即所得，支持 Markdown 快捷输入但完全隐藏语法；无源码视图；块可折叠成页面/卡片
- **核心功能**：md / TextBundle / PDF / Word / HTML / 图片导出（导出质量在块编辑器阵营里相对较好，但复杂块仍有损）；每日笔记、双向链接、Collections 轻量数据库（表格/看板/画廊视图）、任务、模板；「分享为网页」一键生成排版精美的 craft.do 链接；全文搜索；空间同步；无插件系统（有 eXtensions API 的有限尝试）
- **UI 设计**：公认「最漂亮的笔记应用」之一：卡片化页面、细腻微动效、出版级默认排版（字距/行高/标题层级都调过）、深浅色主题与页面样式（字体/主色）逐文档可调；单文档聚焦式布局；最值得学习的细节：默认样式即成品——用户不排版也好看
- **技术栈**：Apple 平台原生 Swift，Mac 端为 Mac Catalyst（Apple WWDC22 官方标杆案例，性能远好于 Electron 竞品）；Windows/Android/Web 为另一套代码（框架未公开）
- **AI 能力**：Craft Assistant：端侧 Apple Foundation Models（免费、离线、不耗积分）+ 可选本地 Llama 3.2 + 云端 Core/Fast/Max 档（按套餐配额）；支持自带 OpenAI / Anthropic API Key 绕过配额；Execute（直接改文档）/ Explore（先提案后应用）两种 agent 模式
- **可借鉴点**：1) 「原生性能 + 设计打磨」本身就是差异化卖点，与我们定位完全同路；2) 端侧模型免费 + 云端配额 + 自带 Key 的三层 AI 策略非常值得抄；3) Markdown 快捷输入但不暴露语法的低门槛处理
- **不足**：评测常见抱怨：Collections 数据库远弱于 Notion（公式/关联缺失）；导出复杂块有损；Craft 2→3 换代与订阅调整引发老用户（含旧买断用户）不满；免费版块数限制；非 Apple 平台体验明显掉档

### UpNote

- **基本信息**：UpNote Co., Ltd（越南河内，2 人团队，2017 年上线）｜macOS / Windows / Linux / iOS / Android｜免费版限 50 条笔记（无附件/表格）；Premium $1.99/月 或 终身买断 $39.99（官方承诺买断权益永久有效）｜官网 getupnote.com｜闭源｜维护活跃、更新频繁
- **编辑模式**：富文本所见即所得 + Markdown 快捷输入（输入语法即转换并隐藏符号）；无源码模式，非纯 md 应用
- **核心功能**：嵌套笔记本 + 标签、双向链接、模板、代码块、表格（付费）、高亮/多字体；导出 Markdown / PDF / HTML / Text；自动备份、版本历史、笔记密码锁、窗口置顶；Firebase 云同步（速度口碑好）；无插件系统、无 API
- **UI 设计**：双栏/三栏（笔记本列表 + 笔记列表 + 编辑器）；干净轻盈、排版舒适，多主题、自定义字体与行宽；有专注模式；设计关键词：clean、无广告干扰；值得学习：设置里给足排版自定义但默认值已经很好
- **技术栈**：桌面为 Electron；后端 Google Firebase（HTTPS 传输 + 静态加密，非 E2EE）；移动端技术未知
- **AI 能力**：无内置 AI（截至 2026-07）
- **可借鉴点**：1) $39.99 终身买断证明「一次付费」在独立笔记应用市场依然能打（对我们的免费开源策略是背书：低价/免费是独立开发者的护城河）；2) 2 人小团队维护 5 平台的克制功能范围
- **不足**：评测抱怨：数据在 Firebase 云端、无本地文件与 E2EE；Markdown 支持不完整（无公式/图表）；无 API/插件扩展；免费版 50 条限制体验不到全貌

### Simplenote

- **基本信息**：Automattic（WordPress 母公司）｜macOS / Windows / Linux / iOS / Android / Web｜完全免费｜官网 simplenote.com｜客户端开源 GPLv2：simplenote-electron 约 5.3k star（最新 v2.27.1，2026-07-01）、simplenote-macos / -ios / -android 均开源，但同步后端闭源｜维护状态：**2026-03-02 官宣停止积极开发**，仅保留基础维护（macOS 原生客户端最后版本停在 2024-09 的 2.21，仅 Electron/Web 端还在修 bug）
- **编辑模式**：纯文本 Markdown 源码编辑 + 手动切换预览（需对单条笔记勾选 Markdown）；Electron 端近年加入了源码内轻量装饰渲染（标题/粗斜体着色）与 Cmd+K 命令面板
- **核心功能**：基础 Markdown（无表格/公式/图表，不支持图片附件）；标签、置顶、全文搜索；免费全平台同步；拖动滑块式版本历史回溯；发布为公开网页；协作（共享标签）；导出 txt/zip；无插件
- **UI 设计**：双栏（列表 + 编辑器）极简到近乎禁欲；无格式工具栏；设计关键词：零摩擦、即开即写
- **技术栈**：桌面 Electron + React；macOS / iOS 客户端为原生（Swift/ObjC，开源可读，对我们是免费的 AppKit 参考代码）；后端 Simperium 同步服务
- **AI 能力**：无
- **可借鉴点**：1) 「打开即写」的启动速度与零摩擦体验是极简笔记的灵魂；2) 开源的原生 macOS 客户端源码可直接研读；3) 教训：免费无商业模式 → 母公司弃养，长期承诺需要收入支撑
- **不足**：已停止积极开发，新用户采用有风险；功能过少（无图片、表格、扩展语法）；笔记存服务器而非本地文件、非端到端加密

### RemNote

- **基本信息**：RemNote Inc.（源于 MIT 的学习科学团队）｜Web / macOS / Windows / Linux / iOS / Android｜免费版 + Pro 订阅（约 $6–8/月，各来源口径不一）+ Life-Long Learning 一次性买断档；AI 附加包 $10/月（2 万 credits）；教育折扣 25% + 按地区自动降价｜官网 remnote.com｜闭源｜维护活跃
- **编辑模式**：大纲（outliner）块编辑器、实时渲染；支持 Markdown 快捷输入与 md 导入导出（Obsidian/Workflowy/Dynalist 迁移）
- **核心功能**：招牌是「笔记内联闪卡语法」：`>>` 基本卡、`::` 双向概念卡、`;;` 描述卡、`{{}}` 填空卡，笔记即卡片、卡片进间隔重复（SRS）队列；PDF 导入标注（免费试用 3 份）、图像遮挡、LaTeX、表格、每日文档、双链与门户（portal）；考试排程器；导出 Markdown/PDF；有插件系统（社区插件市场）
- **UI 设计**：三栏（侧栏 + 大纲正文 + 学习队列/PDF 面板）；面向学习场景的队列界面；设计中规中矩、信息密度高
- **技术栈**：Web 技术栈，桌面为 Electron 壳；移动端技术未知
- **AI 能力**：AI 生成闪卡（三档深度）、AI Tutor 对话、AI 测验与解释、闪卡洞察；按 credits 计费（多数功能约 2 credits/次）
- **可借鉴点**：1) 「输入语法 → 结构化对象」的语法糖设计（`::` 即生卡）展示了 Markdown 类快捷输入的更高阶玩法；2) 深耕单一人群（学生/备考）而非泛笔记的定位策略
- **不足**：评测抱怨：移动端卡顿是头号槽点；概念多、对新手过于复杂；同步偶发问题；G2 好评集中在闪卡而非编辑器本身

### Heptabase

- **基本信息**：Heptabase Inc.（创始人詹雨安 Alan Chan，YC S21，种子轮 $1.7M，团队分布台北/伦敦）｜macOS / Windows / Linux / iOS / Android / Web｜无免费版，7 天试用；月付 $11.99/月，年付合 $8.99/月（$107.88/年）；Premium 档 $17.99/月（年付）解锁无限 PDF + 完整 AI；终身版 $659（约等于 6 年年费）｜官网 heptabase.com｜闭源｜维护活跃（2024 发布 1.0，获 Product Hunt 2023 年度 Golden Kitty）
- **编辑模式**：卡片内实时渲染 Markdown（WYSIWYG，支持 md 快捷输入），卡片再摆上无限白板；「白板空间布局 + 卡片深度编辑」双层结构
- **核心功能**：无限白板（分区、箭头、心智图、卡片堆叠）、卡片库（同一卡片可出现在多个白板、处处同步）、双链、标签 + 表格视图、PDF 标注（高亮自动成卡）、journal、任务；离线可用、跨端同步；**全库一键导出 Markdown**（官方明确以此缓解闭源锁定焦虑）；无插件系统
- **UI 设计**：无限画布 + 卡片的现代设计，深浅色主题；卡片可全屏进入专注写作；设计关键词：空间思维、视觉化；值得学习：把「知识结构」变成可直接拖拽的空间对象
- **技术栈**：Electron + React + TypeScript，编辑器基于 ProseMirror（公司招聘页证实）；移动端 React Native；后端 AWS + MySQL/SQLite
- **AI 能力**：有（较竞品晚）：AI 集成按档位给 credits，Premium 档完整解锁；细节功能演进快，评测普遍认为 AI 不是其核心卖点
- **可借鉴点**：1) 「闭源但承诺全量 md 导出」的信任策略；2) ProseMirror 之上做实时渲染 md 的工程路线可参考；3) 单一愿景（视觉化学习复杂主题）驱动的产品叙事
- **不足**：评测抱怨：数百卡片的大白板有性能问题；涨价史与无免费版拉高门槛；移动端仍是二等公民；线性笔记用户会觉得过度设计

### Tana

- **基本信息**：Tana Inc.（奥斯陆，创始人 Tarjei Vassbotn 为前 Google 产品人）｜Web / macOS / Windows 桌面端 + iOS / Android（捕捉为主）｜免费版（500 AI credits/月、5 个自定义 supertag、2 工作区）；Plus 约 $8–10/月；Pro 约 $14–18/月（各来源口径不一，重会议用户需 Pro）；学生/NGO 五折｜官网 tana.inc｜闭源｜维护活跃（AI 方向投入激进）
- **编辑模式**：大纲块编辑器、实时渲染；支持部分 Markdown 快捷输入；非 md 存储
- **核心功能**：招牌 supertag——给任意节点打 `#会议`/`#人` 等标签即附加字段 schema，可查询、过滤、以数据库视图展示（「标签即数据库」）；Search Node 实时查询、Command Node 自动化、日历集成、语音捕捉（Tana Capture）；AI 会议 agent 加入 Google Meet/Zoom/Teams，60 语言转录并在会后约 7 分钟产出结构化纪要；导出 JSON/Markdown——但评测一致认为导出偏「技术性数据倾倒」，supertag 结构、查询、关联全部丢失，迁移成本高
- **UI 设计**：单栏大纲 + 侧面板、命令面板驱动（Cmd+K）；设计关键词：键盘流、结构化；值得学习：把 schema 定义做成「打个标签」这么轻
- **技术栈**：Web（React）为主，桌面为封装壳（官方未详述）；数据云端
- **AI 能力**：全类别里最激进之一：多模型可选（GPT-5 / Claude / Gemini 按任务切换）、会议纪要 agent、跨节点 AI 综合、AI 字段填充；免费档也送少量 credits
- **可借鉴点**：1) 「AI-native 工作流」（会议→自动结构化）代表 AI 笔记的方向感；2) supertag 的轻量 schema 思路；3) 教训：导出锁定是口碑负资产——我们做本地 md 恰是其反面
- **不足**：评测抱怨：上手要 5–10 小时才「开窍」；订阅贵且 AI 用量焦虑；无真正离线；Markdown 导出近乎摆设

### Roam Research

- **基本信息**：Roam Research Inc.（创始人 Conor White-Sullivan）｜Web 为主 + Electron 桌面壳，移动端仅 PWA｜Pro $15/月 或 $165/年；Believer $500/5 年；31 天试用、无免费版｜官网 roamresearch.com｜闭源｜维护状态：更新缓慢，被多方评为「2023 年后无重大更新」，月活约百万量级但远低于 2020–21 巅峰，用户大量流向 Obsidian / Logseq / Tana
- **编辑模式**：大纲块编辑器；块聚焦时显示类 Markdown 源语法（但方言私有：`((块引用))`、`[[页面]]`、`{{组件}}`、`^^高亮^^`），失焦即渲染——「块级源码/渲染切换」交互的鼻祖之一
- **核心功能**：双向链接与块引用/块嵌入的开创者；每日笔记、图谱、query 查询、看板/表格组件、白板（diagram）；导出 Markdown / JSON / EDN（md 导出中块引用变成裸 UID，保真度差）；Roam Depot 插件市场（社区扩展仍活跃，如 LiveAI）；API 开放较晚
- **UI 设计**：双栏（主栏 + 右侧可堆叠 sidebar，边读边写的「双开」体验被广泛模仿）；界面简陋实用主义，几乎无视觉打磨
- **技术栈**：ClojureScript + DataScript（浏览器内 Datalog 图数据库）；桌面为 Electron 壳
- **AI 能力**：无原生 AI（2026 年仍如此），靠社区扩展接第三方模型
- **可借鉴点**：1) 右侧堆叠 sidebar 的「引用着写」交互至今仍是最佳实践之一；2) 块级「聚焦显源码、失焦即渲染」是轻量版实时渲染方案；3) 教训：概念开创者若停止迭代 + 定价高冷，会被免费开放的追随者（Obsidian/Logseq）吃掉
- **不足**：论坛抱怨：$15/月对比免费竞品毫无性价比；开发停滞、无原生移动端；大图谱性能差；创始人言行与公司文化争议损耗品牌

### Capacities

- **基本信息**：Capacities GmbH（德国，两位创始人，100% 自有资金无外部投资）｜macOS / Windows / Linux / iOS / Android / Web｜免费版 + Pro $9.99/月（年付，月付约 $12）+ Believer $12.49/月｜官网 capacities.io｜闭源｜维护活跃（发布节奏快、社区反馈响应好）
- **编辑模式**：块编辑器实时渲染 + Markdown 快捷输入；以「对象」而非文件组织
- **核心功能**：对象类型系统（人、书、会议、项目…各带属性/模板），同一数据多视图（表格/画廊/墙/列表）；每日笔记、双链、标签；**导出是全类别标杆**：属性转 YAML front matter、集合转 CSV、链接转相对本地链接、文件名人类可读——官方明说「可直接用于 markdown 目录型应用（如 Obsidian）」；支持自动定时导出备份；全员可批量导入 md/CSV/ZIP；纯云存储、部分离线；无插件系统
- **UI 设计**：三栏、精致现代、动效克制；设计关键词：studio for your mind；值得学习：对象页顶部属性区与正文的融合排版
- **技术栈**：前端 Vue 3 + TypeScript + TailwindCSS + Vite（官方确认）；桌面壳框架未官方披露
- **AI 能力**：Pro 档：AI 助手可读用户笔记上下文问答、联网搜索、图像分析（OCR/取色/分类）、属性自动填充；每日 AI 预算制，超额可**自带 API Key** 继续使用
- **可借鉴点**：1) md 导出设计（front matter + 本地相对链接）是「块模型 → Markdown 保真」的最佳参考实现；2) 「AI 预算 + 自带 Key」机制平衡成本与开放性；3) 独立自筹资金 + 快速迭代的社区运营
- **不足**：评测抱怨：移动端 bug 多（文字消失、编辑失败）；仅云存储、无本地文件选项，敏感数据用户却步；对象模型学习曲线；无插件生态

### 语雀

- **基本信息**：蚂蚁集团（阿里系，起源于 2016 年蚂蚁金融云内部工具）｜Web + 桌面客户端（macOS/Windows，Electron）+ iOS/Android｜免费版 + 个人专业会员 ¥99/年；团队/空间版另计；对教育、公益组织认证后免费；2022 年调价风波（100 篇文档限制、¥999 至尊会员均在舆论压力下回调/取消）｜官网 yuque.com｜闭源；2022 年官宣编辑器「将开源」至今未落地，仅开放编译产物（editor.yuque.com）与官方 VSCode 插件 lake-editor｜维护活跃（但 2023-10-23 曾发生约 7–8 小时 P0 级宕机）
- **编辑模式**：富文本所见即所得 + Markdown 快捷输入（历史上从 CodeMirror 纯 md 编辑器起家，2017 年转向 fork Slate 的自研富文本路线）；另有专门的 Markdown 语法速查与兼容层
- **核心功能**：「知识库（book）+ 目录树」的结构化文集组织是招牌；代码块支持近百种语言、可命名/换主题/折叠；LaTeX 公式、PlantUML/文本绘图、画板（思维导图/流程图）、数据表/工作表；导入 Markdown；导出 md/PDF/Word（部分格式与批量导出需会员）；私有 Lake 格式（.lake/.lakebook，社区有转 md 工具，官方 API 不允许修改 Lake 文档）；全文搜索、版本历史、分享/数字花园、开放 API（可同步博客到 GitHub）
- **UI 设计**：知识库列表 + 目录树 + 正文的两/三栏；中文排版全类别最佳梯队（行高、标点、中西文混排）；书卷气、克制；值得学习：目录树驱动的「写书感」信息架构
- **技术栈**：前端 React、桌面 Electron、后端 Node.js（Egg.js）；编辑器为 fork Slate 深度自研 + 私有 Lake 存储格式
- **AI 能力**：已上线 AI 帮写/总结类助手（依托阿里系模型），非产品核心卖点，公开细节有限
- **可借鉴点**：1) 面向技术写作者的代码块/公式/绘图能力标准；2) 「知识库/目录树」组织对长文档集的价值；3) 教训：私有格式 + 导出设限 + 宕机事故的组合，直接把用户推向「本地 Markdown」阵营——我们的反面教材与机会
- **不足**：社区抱怨：2022 定价策略伤害免费用户信任；2023 宕机引发「云笔记可靠性」大讨论；导出受限、Lake 格式锁定；高级 Markdown 语法支持不全；移动端体验平平

### wolai (我来)

- **基本信息**：上海我云网络科技出品，2023-03 被钉钉（阿里）收购，团队并入钉钉负责智能化协作文档与钉钉个人版，创始人马锐拉留任产品一号位｜Web / 桌面（macOS/Windows）/ iOS/Android｜按工作空间收费：个人免费版（历史上有 1000 块 / 200MB 存储等限制）；个人专业版历史价 ¥98–158/年（多次调整，现价以官网为准）｜官网 wolai.com｜闭源｜维护状态：仍在运营，但被收购后独立产品迭代明显放缓，社区普遍担忧其边缘化
- **编辑模式**：Notion 式块编辑器所见即所得 + Markdown 快捷输入；支持 md 导入导出
- **核心功能**：块引用、双向链接、简单表格与多维表、模板中心、导出 Markdown/PDF/HTML（批量导出等需付费）；中文特色功能（丰富的块颜色/彩色文字、中文排版细节）；全文搜索（付费档）；无插件系统
- **UI 设计**：类 Notion 三栏；本地化视觉细节（强调色、卡片装饰）比 Notion 更「热闹」；值得学习：针对中文用户的色彩与装饰偏好调研
- **技术栈**：Web 自研块编辑器 + Electron 桌面壳
- **AI 能力**：被收购后 AI 投入主要落在钉钉侧（钉钉 AI 文档）；wolai 本体 AI 能力有限/未知
- **可借鉴点**：1) 教训：纯粹跟随 Notion 的功能军备竞赛难以独立存活；2) 免费版限制过紧（1000 块）会在获客期就劝退用户；3) 中文块编辑器的本地化细节仍可参考
- **不足**：知乎/V2EX 常见抱怨：免费版几乎不可用、测试期涨价风波、收购后更新停滞担忧、数据导出格式受限

### 飞书文档

- **基本信息**：字节跳动（飞书 / 国际版 Lark）｜Web / 桌面（macOS/Windows）/ iOS/Android，文档是飞书套件一部分｜个人与小团队免费（标准版）；商业版按飞书套件席位订阅（具体价格以官网为准）｜官网 feishu.cn｜闭源｜维护活跃（大厂投入，文档/多维表格是主推方向）
- **编辑模式**：块编辑器所见即所得 + Markdown 快捷输入（`#` 空格、三反引号出代码块、`/` 斜杠菜单插入块）；移动端支持输入 md 语法但不支持查看语法源码；可混用工具栏与 md 语法
- **核心功能**：**2025 年官方上线「下载为 Markdown」**——此前仅支持 Word/PDF，社区长期靠 feishu2md（Go，寻找维护者中）、Cloud Document Converter 等第三方工具导出；官方公告明确把 md 定位为「适合继续编辑、迁移、版本管理和交给 AI 处理」的格式（Word/PDF 用于交付）；多人实时协同、评论/批注、同步块、知识库（Wiki）、多维表格（Base）、思维笔记、画板、投票等超文本组件；全文搜索、版本历史；开放平台 API
- **UI 设计**：三栏 + 协作者头像与评论侧栏；中文排版与块交互细节打磨好；设计关键词：协同、企业感；值得学习：块级评论与划词评论的融合交互
- **技术栈**：文档为 Web 自研块编辑器；桌面套件客户端为 Electron 系（含自研优化，官方未完整披露）
- **AI 能力**：内置飞书 AI（依托字节豆包等模型）：文档写作/润色/总结、问答、会议纪要（妙记）等，深度嵌入套件
- **可借鉴点**：1) 官方把「导出 Markdown」明说成 **AI/Agent 时代的数据接口**——为我们「md 原生 + AI」的立项逻辑提供了大厂背书；2) 块编辑器 + md 快捷输入的中文最佳实践之一；3) 教训：导出能力缺位多年催生一整个第三方工具生态，说明用户对 md 出口的刚需
- **不足**：抱怨集中在：md 导出姗姗来迟且多列布局等复杂块仍会丢失；企业套件太重、个人用户定位模糊；文档深度依赖飞书账号体系与云端

### Anytype

- **基本信息**：Any Association / Anytype（柏林）｜macOS / Windows / Linux / iOS / Android｜本地优先 + E2EE：免费档含 1GB 网络同步、共享空间限 3 人；付费档各来源报价不一（$4–$19/月或 Builder $99/年），且可完全自托管绕开付费｜官网 anytype.io｜源码开放但非 OSI 开源：Any Source Available License 1.0（限非商业使用或指定网络内商用）；GitHub anyproto/anytype-ts 约 8.5k star，最新 v0.55.26-beta（2026-07-18），非常活跃；核心库 anytype-heart（Go）、iOS（Swift）、Android（Kotlin）同许可开放｜维护活跃
- **编辑模式**：块编辑器所见即所得 + Markdown 快捷输入；对象/类型/关系（Objects/Types/Relations）数据模型
- **核心功能**：本地存储 + P2P/自托管同步 + 端到端加密；类型化对象与关系、集合与多视图、图谱、模板；导入 md/Notion；导出 Markdown（2025-07 起属性与类型一并导出，社区另有 Anyblock Exporter、Jimmy 等转换工具）；API 与 MCP 方向的开发者门户
- **UI 设计**：三栏、现代深色调、可定制侧栏；设计关键词：privacy、local-first
- **技术栈**：桌面 Electron + TypeScript，核心逻辑为 Go 共享库（anytype-heart），移动端原生（Swift/Kotlin）——「原生壳 + 跨端核心库」架构
- **AI 能力**：暂无官方内置 AI（截至 2026 年中），社区经 API/本地方案探索
- **可借鉴点**：1) 「本地优先 + 加密 + 源码开放」的信任叙事与我们高度同频；2) Go 核心库 + 各端原生客户端的架构值得评估；3) 把导出保真（属性随 md 走）当版本亮点来发布
- **不足**：评测抱怨：同步概念复杂、速度不稳；历史上 JSON 导出难用（近年才改进）；对象模型学习曲线；付费档定价信息混乱

### Reflect

- **基本信息**：Reflect App, LLC（Alex MacCaw 等）｜macOS / iOS / Web｜单一订阅 $10/月或 $120/年（一说年付 $100），14 天试用、无免费版、无 Android；另有新产品 **Reflect Open**：MIT 协议开源、本地 Markdown 文件、macOS 版免费（GitHub team-reflect/reflect-open 约 1.3k star，v0.6.0 发布于 2026-07-14，活跃）｜官网 reflect.app｜主产品闭源｜维护活跃
- **编辑模式**：实时渲染的极简笔记流（每日笔记 + 反链），无源码模式；Reflect Open 则直接围绕「一个 md 文件夹」构建
- **核心功能**：每日笔记、双向链接、AI 建议关联（写作时自动提示旧笔记链接）、Whisper 语音转录、Readwise/Kindle 同步、快速捕捉；端到端加密（XChaCha20-Poly1305 客户端加密，经 Doyensec 独立审计；忘密码即失数据）；无文件夹体系；导出 md（反链等元数据有损）
- **UI 设计**：单栏极简、以「快」为设计核心（自称最快笔记应用）、紫色渐变品牌感强；值得学习：把性能当作核心卖点来讲
- **技术栈**：Web 技术栈（桌面壳）；Reflect Open 为本地 md 优先的新代码库，README 自述「local-first、AI-agent-friendly、可自带 API Key」
- **AI 能力**：GPT-4 写作助手、语音转文字、chat with notes、AI 反链建议；Reflect Open 支持自带 Key 的可选 AI
- **可借鉴点**：1) **Reflect Open 的战略转向（闭源云订阅 → 开源本地 Markdown + 自带 Key AI）与我们的产品定义几乎一模一样，是最直接的可对标项目**；2) E2EE 作为付费理由；3) 「快」的品牌化
- **不足**：Reddit 抱怨：$10/月偏贵、无免费版、无 Android；格式能力弱（无高亮/颜色/复杂块）；无文件夹让部分用户不适
 
### Amplenote

- **基本信息**：Alloy.dev（西雅图，创始人 Bill Harding）｜Web / macOS / Windows / Linux / iOS / Android｜免费 Personal 档 + Pro 约 $5.84–7/月 + Unlimited 约 $10–12/月 + Founder 约 $20–25/月（年付/月付口径差异）｜官网 amplenote.com｜闭源｜维护活跃
- **编辑模式**：富文本编辑器 + Markdown 输入；导出为标准 md
- **核心功能**：「Jots（速记）→ Notes → Tasks → Calendar」四模式流水线；任务系统是招牌：任意清单项可带截止/重复/优先级/时长，Task Score 算法按紧急度、优先级、年龄自动排序「现在该做什么」；日历与 Google/Outlook/iCloud 双向同步、任务拖拽上日历；双链、Vault 加密笔记、有插件系统；导出 Markdown：标签/日期转 YAML front matter、富脚注转 md 脚注（但链接是 Amplenote 绝对 URL 而非 wiki 链接）
- **UI 设计**：功能主义、加载快，但被评「视觉上不讨喜」——设计语言是其主要减分项
- **技术栈**：Web 技术栈（桌面客户端框架未公开）
- **AI 能力**：Ample Agent（AI 助手/agent，Founder 档含 Pro 版本）
- **可借鉴点**：1) Task Score 的「算法替用户做优先级」思路；2) md 导出走 YAML front matter 的规范做法；3) 教训：功能强但不好看，口碑天花板就被压住——印证「简洁好看」的价值
- **不足**：评测抱怨：界面老气；Jots/Notes/Tasks 概念多、上手慢；任务必须依附笔记存在；免费版限 5MB 上传且无日历同步

### FlowUs (息流)

- **基本信息**：国内团队开发的类 Notion 产品（与 wolai 同赛道）｜Web / 桌面 / iOS/Android｜个人免费版较宽松；个人专业版年费制（历史评测约百元级/年，现价以官网为准）；**5 人以下小组版免费**（对标 Notion 团队版收费点）；有教育优惠｜官网 flowus.cn｜闭源｜维护状态：仍在运营迭代（2026 年具体节奏未知）
- **编辑模式**：块编辑器所见即所得 + Markdown 快捷输入；支持 md 导入导出
- **核心功能**：文档 + 多维表（Notion 的 7 种视图已全部对齐）+ 「文件夹页面」网盘能力（整夹上传、Office 文件在线预览，免跳转）；模板中心；与 Figma、Airtable、ProcessOn、Canva 等第三方嵌入联动；原生移动端「打开即写」口碑好
- **UI 设计**：类 Notion 三栏，中文界面与交互本地化；设计关键词：本地化、性价比
- **技术栈**：Web 自研块编辑器 + 桌面壳（框架未知）
- **AI 能力**：AI 功能曾长期公测、全面开放节奏未知
- **可借鉴点**：1) 「免费策略打在对手收费点上」（小组免费）的差异化定价；2) 文档 + 网盘融合满足中文用户「附件重度」习惯
- **不足**：评测抱怨：细节完成度距 Notion 有差距；AI 迟迟未全量；功能多导致上手成本；同类国产工具（语雀/wolai/FlowUs）互相竞争下的长期存续疑虑

---

## 本类别小结

**共性与趋势**

- 「块编辑器 + Markdown 快捷输入 + 斜杠命令」已是行业标配输入范式：Markdown 在闭源笔记应用里普遍退化为输入语法糖与导出格式，真实存储是私有块模型（Notion blocks、Lake、Any-Block、supertag 图）。
- 导出保真度是全类别的阿喀琉斯之踵：数据库/属性/块引用/多列布局在转 md 时大量丢失（Notion、Tana、Roam 尤甚）；做得最好的是 Capacities（YAML front matter + 本地相对链接 + CSV）与 Heptabase（全库一键 md），它们把「可导出」当卖点营销。
- Obsidian 模式（闭源应用 + 本地 md 文件 + 免费核心 + 开放插件 API + 付费 Sync/Publish）被验证为最能积累长期信任与生态的路线；Roam（高价 + 停滞）与语雀（私有格式 + 宕机 + 调价）是其反面教材。
- 2025–2026 的行业共识正在把 Markdown 重新推上 C 位：飞书官方把导出 md 定位为「交给 AI 处理」的格式，Notion 上线 Markdown Content API，Reflect 干脆推出开源本地 md 的 Reflect Open——「Markdown 是 AI 时代的数据接口」已成明牌。
- AI 形态分层明显：绑定订阅高档位（Notion Business）、credits 计量（RemNote/Tana/Craft）、端侧模型免费（Craft + Apple Foundation Models）、自带 API Key（Craft/Capacities/Reflect Open）；无 AI 的产品（Roam/Simplenote/UpNote）普遍被视为掉队信号。
- 原生与否直接影响口碑：Craft（Swift/Catalyst）靠「快 + 好看」拿下 Mac 年度应用；Electron 阵营（Obsidian/Notion/Heptabase）中只有刻意做性能优化的 Obsidian 免于「臃肿」骂名。

**对我们产品的启示**

- 数据格式即信任：坚持「本地 .md 文件 + 无私有格式」，把 Obsidian 的 file-over-app 叙事 + 我们的完全开源做成双重信任优势；导出/导入保真度按 Capacities 标准对齐（front matter、相对链接、图片本地化）。
- 输入范式取两家之长：源码/实时渲染可切换（Obsidian Live Preview 是标杆），同时提供斜杠命令与 Markdown 快捷输入，降低从 Notion/飞书迁移用户的学习成本。
- 原生 macOS 是真实差异点：Craft 证明「原生性能 + 出版级默认排版」本身就能赢；Simplenote 开源的 macOS 原生客户端可作为 AppKit/Swift 参考代码。
- AI 策略照抄 Craft/Reflect Open 的三层结构：端侧/本地模型（免费、隐私）+ 自带 API Key（开放）+ 可选官方云服务（未来商业化余地）；本地 md 让外部 AI 工具（CLI agent、MCP）零成本接入，是相对云端块模型产品的结构性优势。
- 商业模式参考 Obsidian：核心免费开源，收入押在同步/发布等服务上；避免 Roam 式高价订阅与语雀式「拿基础功能收费」的信任透支。
- 避坑清单：不做私有存储格式；不把导出设为付费墙；免费版不设 wolai 式窒息限制；移动端可以晚做但桌面体验必须一步到位（本类别几乎所有产品的差评都集中在「第二平台」）。
