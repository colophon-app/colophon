# AI 写作工具与编辑器的 AI 集成

> 类别总体观察：这个类别在 2024–2026 年发生了明显分化。一端是「AI 原生」写作工具(Lex、Type、Mem、Sudowrite),把 AI 做成产品的核心卖点,普遍采用 Web 技术 + 订阅制($12–29/月),形态从「选中改写」演进到「文档感知对话」再到「多步 Agent」;另一端是传统精品编辑器(iA Writer、Ulysses、Bear、Obsidian),它们几乎一致地**拒绝内置云端 AI**,转而依托 Apple Intelligence 系统能力、插件生态或 MCP/Agent Skills 等开放接口,把选择权交给用户。中间地带出现了一批开源实验(Reor、Ritemark、VMark、Markra),验证「本地模型 + 纯 Markdown 文件 + 外部 CLI Agent」的路线——其中 Reor 已停更,说明纯开源 AI 笔记应用的可持续性存疑。隐私(内容是否离开设备、是否用于训练)已成为该品类最主要的争论点和差异化维度;iA Writer 的 Authorship「标注 AI 文本」则代表了一种独特的反向立场,且已开源为 Markdown Annotations 规范。

### Notion AI
- **基本信息**:Notion Labs｜macOS / Windows / iOS / Android / Web｜基础版免费;Plus $10/人/月(年付);**AI 完整能力仅含在 Business $20/人/月及以上**——原 $10/月的 AI 附加包已于 2025 年 5 月对新用户下架;2026 年 5 月起 Custom Agents 按积分计费($10/1000 积分,月度不滚存)｜闭源｜notion.com｜维护状态:高频更新(2025-09 推出 AI Agents,2026-01 v3.2 移动端对齐,2026-02 v3.3 Custom Agents)
- **编辑模式**:块编辑器(block-based)实时渲染所见即所得,支持 Markdown 快捷输入,但底层非 Markdown 文件
- **核心功能**:数据库/表格、模板、多人协作、Web Clipper、导出 Markdown/PDF/HTML;版本历史按档位 7/30/90 天;全文搜索 + AI 语义搜索(Ask Notion 可跨 Google Drive、Slack 等外部源)
- **UI 设计**:双栏(侧边栏 + 正文),块 hover 出现拖拽手柄;主题仅明/暗;设计关键词:极简、灰白、块操作;值得学习:空行输入 space 唤起 AI、选中文字浮层 AI 菜单的低打扰交互
- **技术栈**:Electron(桌面端),Web 技术栈
- **AI 能力**:形态最全:选中改写/翻译/总结、空行续写、Q&A 语义搜索、AI Meeting Notes、数据库列自动填充、Notion Agent(可自主执行最长 20 分钟的多步任务)、Custom Agents;2026-01 起可选 GPT-5.2 / Claude Opus 4.5 / Gemini 3 或 Auto 自动路由
- **可借鉴点**:1) 「空行 + space」「选中 + 浮层」两个唤起点覆盖了 90% 写作场景,交互成本极低;2) AI 输出先以预览态呈现,用户选择替换/插入/丢弃,不直接污染原文;3) 多模型可切换 + Auto 路由的设计
- **不足**:AI 被锁进 $20 的 Business 档引发大量 Reddit 抱怨(「被迫为不需要的 AI 付费」);非本地文件、离线弱;r/notion 上有账号被封导致数据无法取回的争议案例;重度用户抱怨大文档性能

### Craft (AI Assistant)
- **基本信息**:Luki Labs(匈牙利)｜macOS / iOS / iPadOS / Windows / Web｜免费版 1GB 存储;Plus $8/月(年付,月付 $10);Family $15/月;Team $50/月;每档含 AI 用量配额,另有按周期续期的积分包;**本地模型永久免费且不占配额**｜闭源｜craft.do｜2021 年 Mac App of the Year;维护活跃(Assistant、Tasks 等持续迭代)
- **编辑模式**:块式所见即所得(类 Notion 但更「文档感」),支持 Markdown 快捷输入与导出
- **核心功能**:文档/子页面(卡片)结构、双链、任务系统(Inbox/日期/提醒)、每日笔记;导出 Markdown/PDF/Word/图片;自研实时同步协议;版本历史 7–180 天按档位;支持 MCP 与开放 API
- **UI 设计**:双栏,大量微动效与卡片化视觉,公认「Apple 平台最漂亮的文档应用」之一;多彩主题与文档封面;设计关键词:精致、圆角卡片、物理感动效;值得学习:块选中后的操作浮层、页面转卡片的层级可视化
- **技术栈**:原生——Mac Catalyst(官方访谈确认,团队对 UI/UX 层做了重度定制以避免「拉伸 iOS 应用」感),自研同步引擎;Xcode 开发
- **AI 能力**:Craft Assistant 对话式助手:云端 Core/Fast/Max 三档模型 + 免费本地模型;Execute 模式可直接增删改内容、调整样式、建子页,Explore 模式先提案待确认;聊天会话跨设备同步;官方承诺不用用户内容训练模型、只发送单次请求所需最小数据;可通过 MCP/API 用自己的 ChatGPT/Claude 订阅,不重复付费
- **可借鉴点**:1) Execute/Explore 双模式(直接执行 vs 提案确认)是 Agent 写作的优秀权限设计;2) 「本地模型免费、云模型计量」的商业模型;3) Catalyst/原生也能做出顶级视觉品质,证明原生路线的上限
- **不足**:论坛常见抱怨:Markdown 导出保真度一般(块结构丢失)、订阅价值感随涨价下降、功能越加越多偏离「简洁文档」初心、Windows/Web 端体验落后 Apple 端

### Lex (lex.page)
- **基本信息**:Lex(创始人 Nathan Baschez,前 Substack/Every)｜Web(+iOS App,Pro 附带)｜免费版约 30 次 AI 检查/月(GPT-3.5、Mistral、Llama 3 等基础模型);Pro $18/月或 $145/年(约 $12/月,不同评测另有 $17/月、$150/年的说法,来源不一);30 天不满意退款｜闭源｜lex.page｜维护活跃(持续接入 GPT-4o/4.1、Claude 4 Opus/Sonnet 等新模型)
- **编辑模式**:极简富文本编辑器(类 Google Docs 单页文档),支持 Markdown 语法输入;非本地文件
- **核心功能**:实时协作(光标级,但无评论线程/建议模式)、文档历史、提示词库、context tags(为文档挂常驻背景知识);无模板库、无 SEO 工具——刻意不做营销内容功能
- **UI 设计**:单栏居中、大留白、几乎无 chrome 的「纸面」;设计关键词:安静、编辑部气质;值得学习:AI 反馈以「编辑批注」而非「弹窗打断」的方式呈现在侧边
- **技术栈**:Web 应用;编辑器内核未知
- **AI 能力**:定位「AI 编辑而非 AI 代笔」:1) 输入 `+++` 触发续写;2) Checks——一键运行语法、简洁度、陈词滥调、可读性等检查,也可自定义检查项,结果以批改清单呈现(区别于 Grammarly 的实时下划线);3) Ask Lex 带全文上下文的对话;4) 多模型切换。有评测称其简洁度检查比人工自查多找出 23% 冗词
- **可借鉴点**:1) 「批改式 Checks」是比实时纠错更尊重心流的语法检查形态,且支持用户自定义检查项;2) `+++` 这种纯文本触发符与 Markdown 编辑器气质天然契合;3) 「帮你写得更好而不是替你写」的定位赢得了严肃写作者口碑
- **不足**:仅 Web/iOS、无 macOS 原生与本地文件;免费额度小;协作功能简陋(无评论);定价信息在各来源间混乱

### Type (type.ai)
- **基本信息**:Type.ai(2023 年创立,YC W23,创始人 Stew Fortier + CTO Stefan Li,种子轮 $2.8M,自称 15 万写作者,估算年营收约 $200 万)｜Web + 桌面端(支持离线)｜免费版限量;Premium $29/月或 $276/年(约 $23/月)——同类独立编辑器中最贵｜闭源｜type.ai｜维护活跃(2025–2026 转向长篇创作/小说定位)
- **编辑模式**:所见即所得文档编辑器,支持 Markdown 快捷键;单文档最长约 15 万词
- **核心功能**:导入 Word/PDF;导出 Word/PDF/AI 朗读音频;25 个内置模板;每文档可挂 5 个知识源(DOCX/PDF/图片文字/URL/自定义文本);Notes 功能记忆人物/世界观设定并注入后续生成;离线优先,本地保存 + 云同步;版本回顾
- **UI 设计**:单栏文档 + 右侧 AI 面板;干净、商务;值得学习:AI 命令(inline command)与文档评审(Document Review)在同一编辑器内闭环,不用切换工具
- **技术栈**:Web 技术;编辑器内核未知
- **AI 能力**:形态最完整的「AI 原生文档编辑器」之一:Generate Draft 一键成稿、Type Chat 常驻对话、Inline AI Commands、AI Rewrites、Document Reviews(对整篇文档跨段落统一修改)、Content Ideas;可选 Anthropic/OpenAI/Google 高级模型;承诺不用用户数据训练
- **可借鉴点**:1) Document Review——「整文档级」AI 编辑是选中改写之外的重要形态;2) Notes/知识源 = 给 AI 挂持久上下文,长文写作刚需;3) 「写作如雕塑」——AI 出粗坯、人来精修的产品叙事
- **不足**:$29/月被普遍认为过贵;上下文限于当前文档而非项目多文件;长文中 AI 用词重复;生态小、集成少

### Mem
- **基本信息**:Mem Labs(2019 年创立,融资 $28.6M,a16z + OpenAI Startup Fund)｜macOS / Windows / iOS / Web(**无 Android 原生应用**)｜Mem 2.0 定价(2025-10-01 起):免费版每月仅 25 条新笔记 + 25 条对话;Pro $12/月(年付约 $144/年)｜闭源｜mem.ai｜维护中(2.0 重写后每周更新)
- **编辑模式**:轻量富文本笔记编辑器,支持 Markdown 输入;无本地 Markdown 文件
- **核心功能**:无文件夹/无目录的「反组织」理念——AI 自动打标签、自动关联相关笔记;自然语言语义搜索;模板;Chrome 剪藏、邮件转笔记;会议录音转录摘要;离线编辑 + 同步
- **UI 设计**:单栏流式笔记 + 侧栏;设计关键词:轻、快、无结构;值得学习:「相关笔记」侧栏的被动推荐(写作时自动浮现旧笔记)
- **技术栈**:Web 技术 + 桌面壳(官方称 2.0 为「native experience」,未确认框架,疑似 Electron 类方案)
- **AI 能力**:定位「AI Thought Partner」:Mem Chat 对全部笔记做 RAG 问答与综合;Smart Write 引用自己笔记辅助起草;Voice Mode 语音转结构化笔记(自动提取要点/待办);自动标签与关联
- **可借鉴点**:1) 「与自己的全部笔记对话」是 RAG 在个人写作场景最被验证的形态;2) 被动式相关笔记推荐不打断写作;3) 反面教训:纯靠 AI 组织、放弃用户手动结构,留存存疑
- **不足**:评测与 Reddit 常见抱怨:bug 多、客服「几乎不存在」、免费版 2.0 后大幅缩水、离线能力弱、无 Android;Notion AI 等挤压下差异化变窄

### Reor
- **基本信息**:开源项目(reorproject)｜macOS / Windows / Linux｜完全免费,AGPL-3.0(早期 GPL-3.0)｜reorproject.org｜github.com/reorproject/reor 约 8.6k star、530 fork｜**已停更:最后版本 v0.2.32(2025-04-05),仓库 2026-03-07 归档为只读**
- **编辑模式**:类 Obsidian 的 Markdown 实时渲染编辑器
- **核心功能**:指向本地一个目录的纯 Markdown 文件(可直接用 Obsidian vault 并行使用);每篇笔记自动分块嵌入内置向量库;向量相似度自动关联相关笔记;语义搜索;AI 闪卡生成;frontmatter 解析不完善
- **UI 设计**:三栏(文件树 + 编辑器 + 相关笔记/聊天侧栏),暗色为主;设计朴素,工程感强
- **技术栈**:Electron + React + Vite,主题用 Tamagui;本地 AI 基于 Ollama + Transformers.js + LanceDB
- **AI 能力**:立项假设即「AI 思考工具应默认本地运行模型」:本地 LLM(经 Ollama 下载管理)+ 本地 embedding;RAG 问答、语义搜索、自动关联全部离线可用;也可接 OpenAI 兼容 API
- **可借鉴点**:1) 「本地目录 + 本地向量库 + 本地模型」的完整隐私架构可直接参考(LanceDB 嵌入式向量库很适合桌面应用);2) 「与 Obsidian vault 共存」的兼容策略降低迁移成本;3) 反面教训:无商业模式的开源 AI 笔记应用两年即停更,社区规模(8.6k star)不等于可持续
- **不足**:HN/Reddit 反馈:编辑器粗糙、本地小模型问答质量有限、性能一般;最终停止维护

### Obsidian AI 插件生态(Copilot / Text Generator / Smart Connections 等)
- **基本信息**:Obsidian 本体(Dynalist Inc.,个人使用免费,商用 license $50/人/年,Sync 另付费)官方**不内置任何 AI**;AI 能力全部来自社区插件。三大头部插件:
  - **Copilot for Obsidian**(logancyang):约 7.4k star,AGPL-3.0,v3.3.3(2026-05-21);免费版 BYOK,Copilot Plus $14.99/月
  - **Smart Connections**(brianpetro):约 5.3k star,「Smart Plugins License」(源码可见但限制竞争性再分发,已非 OSI 开源),v4.5.3(2026-06-04);免费 + 付费高级档
  - **Text Generator**(nhaouari):约 2k star,MIT,v0.8.7(2026-04-27),累计 207 个 release,维护活跃
  - 其他:Smart Composer(Cursor 式选中改写 + 一键 apply)、Local GPT(纯本地)、Khoj(可自托管)
- **编辑模式**:Obsidian 本体为源码模式 + Live Preview 实时渲染 + 阅读模式三态切换
- **核心功能**:Copilot 集对话、Vault QA(全库 RAG)、内联生成于一体,支持 OpenAI/Anthropic/Google/OpenRouter/本地模型,Plus 档加 Agent 模式、图像理解、PDF/网页总结;Smart Connections 默认用本地 bge-micro-v2 模型做 embedding,零配置无需 API key,写作时侧栏被动浮现相关笔记;Text Generator 走模板路线——带变量的提示词模板 + 社区模板市场,frontmatter 配置
- **UI 设计**:插件均遵循 Obsidian 侧栏/命令面板范式;值得学习:AI 作为右侧栏与命令面板的「可选层」,完全不侵入编辑器主体
- **技术栈**:Obsidian 为 Electron + CodeMirror 6;插件为 TypeScript
- **AI 能力**:社区共识用法是组合安装:Copilot 管对话/问答、Smart Connections 管被动联想、Text Generator 管模板化生成;本地模型支持(Ollama/LM Studio,约 20 分钟配好后完全离线零 API 成本)被多篇对比文章列为选型第一维度。官方立场:CEO Steph Ango(kepano)2026 年初发布 MIT 协议的 **obsidian-skills**(Markdown/Bases/JSON Canvas/CLI 等 Agent Skills),思路是「不往产品里塞 AI 按钮,而是把开放格式教给外部 Agent」,与其 files-over-apps 哲学一致
- **可借鉴点**:1) 「本体零 AI + 插件/开放格式接入」是隐私敏感用户最认可的架构,与我们开源定位高度契合;2) Smart Connections 的「本地 embedding、零配置、无 API key」是被动 AI 的标杆;3) obsidian-skills 提示了一条新路:为自家格式写 Agent Skills/MCC 文档,让 Claude Code 等外部 Agent 成为「免费的 AI 功能」
- **不足**:插件质量参差、配置门槛高(Reddit 常见「装了三个 AI 插件互相冲突」);Smart Connections 改协议引发社区不满;插件供应链安全风险(社区插件可静默读全库)

### iA Writer(反向立场:标注 AI 而非内置 AI)
- **基本信息**:iA(Information Architects,瑞士/日本)｜macOS / iOS / iPadOS / Windows / Android｜一次性买断:Mac $49.99、iPhone/iPad $49.99、Windows $29.99(微软商店;官网直购另有 $39.99 说法),跨平台需分别购买;7 天试用;无订阅｜闭源(但 Markdown Annotations 规范开源在 GitHub)｜ia.net/writer｜维护活跃(iA Writer 7 起持续更新 Authorship)
- **编辑模式**:纯源码 Markdown + 语法高亮弱渲染(标记淡化),独立预览窗/分栏;无所见即所得
- **核心功能**:GFM、脚注、任务列表、MathJax、内容块(嵌入文件);导出 Markdown/HTML/PDF/Word,模板系统;基于文件夹的本地文件库 + iCloud 同步;Focus/打字机模式、Syntax Highlight(词性着色)、Style Check(全程本地运行的风格检查,划掉冗词套话)
- **UI 设计**:单栏极简天花板:自研 iA Quattro/Mono/Duo 字体、无工具栏、蓝色光标标志性;设计关键词:克制、印刷品质;值得学习:用字体与排版而非 UI 元素建立品牌识别
- **技术栈**:原生(macOS 为 AppKit + 自研文本引擎)
- **AI 能力**:**刻意不内置生成式 AI**。核心是 Authorship:1) 粘贴文本可标记作者(人/ChatGPT/Claude 等),AI 文本最初以灰色淡显,近期改为「彩虹渐变」高亮(理由:灰色太安静,不足以提醒你独立思考);2) 自动识别从 ChatGPT/LM Studio 复制的对话并主动提议标注;3) 「Paste Edits From」自动 diff 选中文本与粘贴文本,把改动归属给指定作者;4) 作者信息作为文件末尾独立块存储(Markdown Annotations 开放规范),导出时自动剥离;5) 全程本地检测,不上传文本。官方主张:「用 AI 挑毛病,而不是替你写」
- **可借鉴点**:1) Authorship/Markdown Annotations 是现成的开放规范,我们可以第一个在开源编辑器中实现它,直接差异化;2) 「AI 文本可视化」满足教育、出版等对 AI 披露有硬需求的场景;3) Style Check 证明「本地、非 LLM 的写作辅助」也有价值
- **不足**:社区抱怨:各平台分开买断且 iOS 从 $20 涨到 $50;功能保守(无双链/插件);Authorship 依赖手动/粘贴识别,无法检测「假装手打」的 AI 文本

### Ulysses / Bear(Apple Intelligence 路线)
- **基本信息**:Ulysses(德国 Ulysses GmbH)｜macOS / iOS / iPadOS｜订阅约 $5.99/月或 $39.99/年,闭源,维护活跃。Bear(意大利 Shiny Frog)｜macOS / iOS｜免费 + Pro 订阅 $2.99/月或 $29.99/年,闭源,维护活跃
- **编辑模式**:两者均为「Markdown 语法 + 实时样式渲染」的混合单栏编辑器(标记保留但样式化)
- **核心功能**:Ulysses:文库(Sheets/组)、目标字数、发布到 WordPress/Ghost/Medium、导出 PDF/Word/ePub/HTML、内置 20+ 语言语法风格校对(基于 LanguageTool 技术,本地+云);Bear:标签系统、双链、加密笔记、导出 Markdown/PDF/HTML,CoreData 库 + iCloud 同步
- **UI 设计**:均为三栏(库/列表/编辑器)可收纳为单栏;Ulysses 偏专业写作工房,Bear 以红爪主题色与优雅排版著称;值得学习:Bear 的主题系统与标签图标,Ulysses 的发布管线
- **技术栈**:均为原生 AppKit/UIKit(Bear 2 自研编辑器内核 Panda)
- **AI 能力**:两者均**不自建云端 AI**,策略一致:接入系统级 Apple Intelligence Writing Tools(macOS 15.1+/iOS 18.1+ 的校对、改写、总结;15.2 起可经 ChatGPT Compose 生成)——选中文本右键唤起,处理尽量在设备端,可在设置中整体禁用;Ulysses 强调文本「除非显式发送,否则不离开设备、绝不用于训练」。Bear 团队公开表示不愿为追热点把笔记送第三方服务器,社区中不少用户希望它学习 iA Writer 的立场;深度需求由社区 MCP server(如 ulysses-mcp,开源、非官方)满足
- **可借鉴点**:1) 「系统 Writing Tools 免费兜底 + 明确隐私承诺」是原生 Mac 应用零成本获得 AI 能力的最短路径,我们可直接采用;2) 「可整体关闭 AI」应作为设置项标配;3) 社区用 MCP 补深度 AI 的模式说明:开放接口比内置功能更被高级用户欢迎
- **不足**:Writing Tools 能力浅(无对话/无长文续写)、依赖 OS 版本;Ulysses 订阅制长期被 Reddit 诟病;Bear 功能迭代慢、无 Windows/Android

### NotebookLM(简要)
- **基本信息**:Google｜Web / iOS / Android｜免费版:100 个笔记本、每本 50 个来源、每日 50 次对话、每日 3 个 Audio Overview;付费绑定 Google AI 订阅:Plus $7.99/月、Pro $19.99/月、Ultra $99.99 或 $200/月(2026-05 拆分);不单独售卖｜闭源｜notebooklm.google
- **编辑/核心/UI**:非 Markdown 编辑器——「来源接地」研究工具:上传文档/网页/视频(单来源上限 50 万词或 200MB),所有回答仅基于来源并带引用;可生成播客式 Audio Overview(50+ 语言)、视频概览、思维导图、闪卡、报告;全档位共享 1M token 上下文;2026-06 起底层为 Gemini 3.5 并加入 agentic 来源发现
- **技术栈**:Web(Google 内部栈)
- **AI 能力**:范式代表:**source-grounded RAG + 带引用回答 + 多模态产出**,幻觉控制靠「只答来源内的内容」
- **可借鉴点**:1) 「回答必须带出处、点击跳回原文」的引用交互值得任何文库问答功能借鉴;2) 把用户文档变成播客/导图的「输出多模态」思路
- **不足**:不能编辑写作、锁死 Google 生态、来源需手动上传;免费额度按 24 小时滚动重置被用户抱怨反直觉

### Cursor 等 AI IDE 中写 Markdown(简要)
- **基本信息**:Anysphere｜macOS / Windows / Linux｜Hobby 免费(约 50 次/月高级请求),Pro 约 $20/月｜闭源(VS Code fork)｜cursor.com｜高频更新
- **编辑模式**:纯源码(VS Code Markdown 编辑 + 预览分栏)
- **核心功能/AI 能力**:写 Markdown 的独特体验:1) Tab 幽灵文本补全在散文中同样生效(不少写作者反映干扰,常为 .md 关闭补全或把触发延迟调到 200–300ms);2) Cmd+K 选中改写,diff 预览后应用;3) Chat/Agent 用 `@` 引用多文件、网页、PDF 作上下文,可直接批量读写本地 .md 文件;4) `.cursor/rules` 目录放 .mdc 规则文件定义写作规范;5) Notepads 常驻提示词。有非程序员用户把它当「第二大脑」:纯 Markdown 目录 + 语义搜索找回旧笔记
- **UI/技术栈**:Electron(VS Code),对写作者视觉噪音大
- **可借鉴点**:1) 「Agent 直接读写本地纯文本文件」被验证为最强大的 AI 写作范式,而 Markdown 编辑器是比 IDE 更适合承载它的壳;2) 规则文件(项目级写作规范)与 @ 引用多文件上下文;3) 反面:补全时机不当会毁掉写作心流——散文场景应默认关闭或弱化幽灵文本
- **不足**:面向代码的 UI/信息密度对写作者不友好;无排版/导出;订阅计费复杂多变

### Sudowrite(补充:小说向 AI 原生工具)
- **基本信息**:Sudowrite(美国)｜Web｜订阅含 AI 用量(积分制,未用积分可滚存 12 个月):Hobby $10/月(年付,22.5 万积分)、Professional $22/月(100 万积分)、Max $44/月(200 万积分)｜闭源｜sudowrite.com｜维护活跃(2025-06 发布自研小说模型 Muse 1.5,盲测对比 Claude 3.7 Sonnet 以 2:1 被偏好)
- **编辑模式**:富文本章节编辑器(非 Markdown)
- **核心/AI 能力**:小说全流程工具箱:Write(续写)、Rewrite、Describe(五感描写)、Brainstorm;**Story Bible**——人物/情节/世界观结构化档案自动注入生成上下文,保证长篇一致性;多模型(GPT/Claude/自研 Muse)
- **UI 设计**:三栏(章节树 + 正文 + AI 卡片流);AI 结果以卡片多候选呈现,可逐张采纳
- **技术栈**:Web
- **可借鉴点**:1) 多候选卡片式 AI 输出(而非单一结果覆盖)把选择权具象化;2) Story Bible = 「结构化长期记忆」的成熟实现;3) 垂直场景自训模型的差异化打法
- **不足**:积分制成本不透明、界面学习曲线;非虚构写作不适用;Reddit 上对 AI 写小说的伦理争议集中于此类产品

### Novelcrafter(补充:BYOK 模式代表)
- **基本信息**:Novelcrafter(独立团队)｜Web(支持离线 PWA)｜软件订阅 $4 / $8 / $14 / $20 每月四档(年付减两个月),**AI 一律 BYOK**(自带 OpenAI/Anthropic/OpenRouter key 或本地模型,AI 费用另计,Reddit 实测 $0.35–$70+/月不等);21 天免费试用｜闭源｜novelcrafter.com｜维护活跃
- **编辑模式**:章节/场景富文本编辑器,支持 Markdown 语法输入
- **核心/AI 能力**:**Codex** 世界观数据库(人物/地点/阵营/魔法体系词条,AI 生成时自动携带相关词条 + 前文场景);Story Board/Grid/Matrix/Outline 多视图规划;对话式写作与场景改写;任意模型可换,本地模型免费
- **UI 设计**:双栏 + 可弹出 Codex 面板;工具感强
- **技术栈**:Web
- **可借鉴点**:1) BYOK(自带 key)+ 低价软件订阅,是开源编辑器最自然的 AI 商业中立方案——我们几乎必然采用;2) Codex 词条在编辑器内 hover 即卡片预览的交互;3) 「软件钱和模型钱分开」的透明定价获得社区好感
- **不足**:双重账单心智负担、配置门槛高(「Sudowrite 有学习曲线,Novelcrafter 是配置负担 + 学习曲线」);Web-only

### Elephas(补充:macOS 原生系统级 AI)
- **基本信息**:Elephas(独立开发)｜macOS 13+ / iOS / iPadOS(原生应用,非 Web 壳)｜Standard $9.99/月($99/年)、Pro $14.99/月(3 设备)、Pro+ $18.99/月(5 设备、不限量),年付约 8 折;7 天 Pro 试用;曾有买断 LTD｜闭源｜elephas.app
- **编辑模式**:非编辑器——系统级 AI 助手(任意 App 内选中文本处理)+ Super Brain 知识库
- **核心/AI 能力**:Super Command 全局快捷键在任何应用中改写/续写/总结;**Super Brain**:导入 PDF/Word/Apple Notes/Notion/Obsidian/Markdown/网页/YouTube 字幕等 20+ 格式建本地知识库,问答带原文引用;可完全离线跑本地模型;可选 OpenAI/Claude/Gemini/Groq;发送前自动脱敏 28 类实体(姓名/邮箱/SSN 等);注意:App Store 沙盒版无法提供全局写作功能,完整版需官网直装
- **UI 设计**:菜单栏应用 + 浮窗;标准 Mac 控件
- **技术栈**:原生 Apple 平台应用(官方强调非 Web 包装)
- **可借鉴点**:1) 「发送云端前本地脱敏」是我们能抄的隐私工程亮点;2) 原生 Mac + 本地模型 + 多 Provider 切换已被独立开发者跑通;3) 警示:App Store 沙盒会限制系统级 AI 能力,发行渠道要早做决策
- **不足**:非写作环境(无文档管理/排版);评测称 UI 略工具化、token 配额档位复杂

### Ritemark(补充:开源 Markdown + CLI Agent)
- **基本信息**:独立开发者 jarmo-productory｜macOS / Windows｜完全免费,MIT 开源｜ritemark.app｜github.com/jarmo-productory/ritemark-public(star 数未知,小型新项目)｜维护活跃(v1.8.0,2026 年,持续发版)
- **编辑模式**:所见即所得可视化 Markdown 编辑 + 内置 AI 终端
- **核心/AI 能力**:本地优先——指向本地项目文件夹,纯 .md 文件、无云、无账号;**内置终端直接运行 Claude Code / Codex / OpenCode 三种 CLI Agent**,统一在一套审批策略后面:Agent 读写、新建文件,可视化编辑器即时反映;支持 `/diagram` 嵌入离线 draw.io 图;v1.8 加入定时 Agent 任务(每日简报/周报)
- **UI 设计**:编辑器 + AI 侧栏/终端双栏
- **技术栈**:未知(桌面壳 + Web 编辑器,推测 Electron/Tauri 类)
- **可借鉴点**:1) 这几乎是我们产品定位的直接原型:「开源 + 本地 Markdown + 外部 Agent 而非自建 AI」——差异点在于我们可以用原生 Swift 做出远好于它的 UI;2) 「一套审批策略管住多个 Agent 运行时」的安全设计;3) 定时 Agent 任务是差异化功能灵感
- **不足**:知名度低、无 iOS/同步;UI 打磨一般;类似定位的还有 Markra(开源 WYSIWYG + AI diff 预览)与 mdedit.ai(离线优先技术文档向),说明该细分已开始拥挤

### VMark(补充:Tauri + MCP 的 AI-friendly 编辑器)
- **基本信息**:李笑来(xiaolai)个人项目｜macOS 等桌面平台｜免费,ISC 协议开源｜github.com/xiaolai/vmark 约 417 star｜维护活跃(v0.9.5,2026-07-19);特点:「vibe-coded」(AI 在人类监督下写成),只收 Issue 不收 PR
- **编辑模式**:三模式:WYSIWYG / Source Peek(源码浮窗) / Source Mode,可切换
- **核心/AI 能力**:定位「人与 AI 共同读写同一批纯文本」的工作区;**原生内置 MCP server**,Claude Desktop、Claude Code、Codex CLI、Gemini CLI 可直接连进来读写当前文档——AI 集成方式是协议而非聊天框
- **UI 设计**:简洁双栏;Tailwind 风格
- **技术栈**:**Tauri v2**(非 Electron)+ React 19 + TypeScript;编辑器内核 Tiptap/ProseMirror(WYSIWYG)+ CodeMirror 6(源码)——这套「双内核」组合是当前开源界最主流的 Markdown 编辑器方案
- **可借鉴点**:1) 「编辑器自带 MCP server」是把 AI 交互外包给用户已付费的 Claude/ChatGPT 客户端的最轻实现,零 AI 成本、零隐私责任;2) Tiptap/ProseMirror + CodeMirror 6 双内核的模式切换架构可直接参考(即便我们用原生,概念可移植);3) 证明了一人 + AI 编程可以快速做出这类产品——竞争窗口不会太久
- **不足**:star 少、生态早期;Tauri 文本编辑性能与输入法处理仍是社区常提的坑;非原生 UI

## AI × Markdown 编辑器可能的交互形式(穷举清单)

| # | 交互形式 | 说明 | 代表产品 |
|---|---------|------|---------|
| 1 | 选中改写(浮层菜单) | 选中文本弹出改写/翻译/总结菜单,结果预览后替换 | Notion AI、Type、Apple Writing Tools(Ulysses/Bear)、Elephas |
| 2 | 续写/幽灵文本补全 | 光标处灰字续写,Tab 接受;散文场景需可关闭/延迟 | Cursor Tab、Sudowrite Write、Lex `+++` |
| 3 | 空行/斜杠命令唤起生成 | 空行按 space 或 `/ai` 触发生成 | Notion(space)、Craft、Type inline commands |
| 4 | 文档感知对话侧栏 | 常驻 Chat,自动携带当前文档上下文 | Type Chat、Obsidian Copilot、Craft Assistant、Cursor Chat |
| 5 | 全文库 RAG 问答 | 对整个笔记库/文件夹做向量检索 + 问答 | Mem Chat、Copilot Vault QA、Reor、Elephas Super Brain |
| 6 | 来源接地问答 + 引用跳转 | 回答仅基于指定来源并带可点击出处 | NotebookLM、Elephas(引用原文) |
| 7 | 批改式检查(Checks) | 一键运行语法/简洁度/陈词滥调等检查,清单式呈现,支持自定义检查项 | Lex Checks、Ulysses 内置校对 |
| 8 | 本地非 LLM 风格检查 | 设备端规则/词性分析,划掉冗词套话 | iA Writer Style Check、Syntax Highlight |
| 9 | AI 文本标注/作者身份追踪 | 标记哪些字来自 AI(灰显/彩虹),diff 归属,开放规范存储 | iA Writer Authorship(Markdown Annotations) |
| 10 | 相关笔记被动推荐 | 本地 embedding,写作时侧栏自动浮现相关旧笔记,零提示词 | Smart Connections、Mem、Reor |
| 11 | 模板化生成 | 带变量的提示词模板 + 社区模板市场 | Obsidian Text Generator、Type 模板、Sudowrite 工具卡 |
| 12 | 整文档级 AI 编辑 | 对全篇做统一口径修改/审校,而非逐段 | Type Document Reviews |
| 13 | diff 预览后应用(apply) | AI 改动先以 diff 呈现,逐块接受/拒绝 | Cursor Cmd+K、Smart Composer、Markra |
| 14 | Agent 模式(多步执行/直接读写文件) | AI 自主完成跨文件多步任务 | Notion Agent、Cursor Agent、Ritemark、Craft Execute 模式 |
| 15 | 编辑器内嵌 CLI Agent 终端 | 直接在编辑器里跑 Claude Code/Codex 等 | Ritemark |
| 16 | 编辑器自带 MCP server(协议接入) | 外部 AI 客户端连入读写文档,编辑器不自建 AI | VMark、Craft(MCP)、社区 ulysses-mcp、obsidian-skills |
| 17 | 系统级 AI 借力 | 接入 Apple Intelligence Writing Tools,零成本、设备端优先 | Ulysses、Bear |
| 18 | 本地模型运行 | Ollama/LM Studio/内置下载,完全离线 | Reor、Craft 本地模型、Elephas、Local GPT、Smart Connections(本地 embedding) |
| 19 | 多模型切换/BYOK/自动路由 | 用户选模型或自带 API key,软件与模型费用分离 | Notion(Auto)、Lex、Novelcrafter(BYOK)、Copilot |
| 20 | 结构化长期记忆(世界观/设定库) | 人物/设定词条自动注入生成上下文 | Sudowrite Story Bible、Novelcrafter Codex、Type Notes、Lex context tags |
| 21 | 项目级规则文件(写作规范) | 仓库内纯文本规则约束 AI 文风与格式 | Cursor `.cursor/rules`、obsidian-skills |
| 22 | 语音转结构化笔记 | 录音/口述自动转要点、待办 | Mem Voice Mode、Notion AI Meeting Notes |
| 23 | 多模态产出(播客/导图/闪卡) | 把文档反向生成音频、思维导图、闪卡 | NotebookLM、Reor(闪卡) |
| 24 | 自动组织(标签/关联/整理) | AI 自动打标签、建立笔记关联 | Mem、Reor |
| 25 | 定时/后台 Agent 任务 | 按计划运行 AI 任务(日报/摘要) | Ritemark、Notion Custom Agents |
| 26 | 隐私工程(脱敏/最小上传/不训练承诺) | 发送前本地脱敏、只传所需片段、显式承诺不训练 | Elephas(28 类实体脱敏)、Craft、Ulysses |
| 27 | Execute/Explore 双权限模式 | AI 直接执行 vs 仅提案待确认,用户可选 | Craft Assistant |
| 28 | 多候选卡片输出 | 一次生成多个候选,逐张采纳 | Sudowrite |

## 本类别小结

**共性与趋势**
- AI 交互重心正从「选中改写/续写」(2023 形态)转向「文档感知对话」→「全库 RAG」→「多步 Agent 直接读写文件」(2025–2026 形态);Notion、Craft、Cursor 三家都在 2025–2026 年上线了 Agent。
- 隐私成为第一分歧线:AI 原生工具靠「不训练承诺 + 最小上传」自证;精品原生应用(iA/Ulysses/Bear)干脆不自建云 AI;开源阵营用本地模型(Ollama/LanceDB/Transformers.js)彻底解题。本地 embedding 做「相关笔记推荐」已被 Smart Connections 验证为零成本、零隐私风险的最佳被动 AI。
- 商业模式三分:含 AI 用量的高价订阅($12–29/月,Notion 甚至把 AI 锁到 $20 档)、BYOK + 低价软件费(Novelcrafter、Obsidian 插件)、买断 + 系统 AI 免费兜底(iA、Ulysses/Bear 路线)。社区口碑明显偏向后两者。
- 「编辑器不内置 AI,而是通过开放协议(MCP/Agent Skills)让外部 Agent 进来」是 2026 年最新趋势(obsidian-skills、VMark、Craft MCP),对开源产品尤其友好:零 AI 成本、零隐私责任、复用用户已有的 Claude/ChatGPT 订阅。
- 纯开源 AI 笔记应用可持续性存疑:Reor 8.6k star 仍在两年内归档停更;而 Ritemark/VMark/Markra 等新项目扎堆出现,说明「开源 + 本地 Markdown + AI」的窗口正被快速填补。

**对我们产品的启示**
- 分层 AI 架构:第 0 层接 Apple Intelligence Writing Tools(免费、设备端、一行代码级成本);第 1 层 BYOK 多 Provider(OpenAI/Anthropic/本地 Ollama);第 2 层暴露 MCP server + 为自家格式写 Agent Skills,让 Claude Code 等成为「免费高级 AI 功能」。自己不承担推理成本,与开源免费定位自洽。
- 交互上优先做四件事:选中浮层改写(带 diff 预览 + 接受/拒绝)、文档感知对话侧栏、Lex 式批改 Checks、本地 embedding 相关笔记推荐;散文场景默认关闭幽灵文本补全(Cursor 的教训)。
- 把 iA Writer 的 Markdown Annotations(Authorship)作为差异化亮点实现——它是开放规范,目前没有第二家开源编辑器支持,「能标注 AI 写了哪些字的开源编辑器」是清晰的传播点。
- 隐私要工程化而非口号化:默认本地、发送前可视化「将要上传的内容」、可整体关闭 AI(Ulysses 做法)、承诺不训练写进首屏。
- 原生路线有先例背书:Craft(Catalyst)证明原生能做出品类最佳视觉,Elephas 证明独立开发者能跑通「原生 + 本地模型 + 多 Provider」;而竞品(Ritemark/VMark)均为 Web/Tauri 壳,原生 AppKit/SwiftUI 的手感与性能就是我们的护城河。
