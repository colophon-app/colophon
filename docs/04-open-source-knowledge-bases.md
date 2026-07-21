# 开源笔记 / 知识库应用（以 Markdown 为基础）

> 调研日期：2026-07-21。本类别覆盖「开源（或源码可得）的笔记 / 知识库型应用」：本地优先、双链 / 块引用、可自托管是共同关键词。总体观察：(1) 协议选择高度分化——面向个人的本地应用普遍选 AGPL-3.0（Joplin、Logseq、SiYuan、Trilium、AppFlowy）以防云厂商白嫖，社区工具选 MIT（Memos、SilverBullet、Foam、AFFiNE 核心），商业公司则用 BSL（Outline）或自造的 source-available 协议（Anytype）；(2) 商业化几乎只有一条被验证的路——「应用免费开源 + 官方云同步 / 协作订阅」，客单价集中在每月 2~10 美元 / 欧元；(3) 技术栈上 Electron + Web 编辑器（CodeMirror / ProseMirror 系）仍是绝对主流，原生只有 QOwnNotes（Qt）一个独苗，Flutter+Rust（AppFlowy）与 Tauri（Blinko）是新变量；(4) AI 集成呈三种姿态：深度内置并作为付费点（AppFlowy、AFFiNE、SiYuan）、交给社区插件（Joplin、Logseq、SilverBullet）、以及做过又撤掉（Trilium，因维护负担在 v0.102.0 移除核心 AI）；(5) 反面教材同样丰富——Athens、Dendron 证明 VC + 开源 PKM 的商业模式极难成立，Logseq 证明「停摆式大重写」会烧掉社区信任。

### Joplin
- **基本信息**：Laurent Cossé 创立，法国公司 Joplin 运营 Joplin Cloud，社区共建｜Windows / macOS / Linux / iOS / Android / 终端 CLI + Web Clipper｜应用完全免费；协议 AGPL-3.0（2022 年由 MIT 切换）；Joplin Cloud 订阅：Basic 2.99 欧/月（年付折合约 2.39 欧/月，1~2GB）、Pro 5.99 欧/月（10GB）、Teams 7.99 欧/用户/月，均有 14 天试用，学生教师 5 折｜官网 joplinapp.org｜github.com/laurent22/joplin，约 55.7k star｜维护活跃：v3.6.15（2026-06-20）
- **编辑模式**：双编辑器切换——Markdown 源码 + 分屏预览（CodeMirror 6），或富文本所见即所得（TinyMCE）；一键切换，两种模式长期并存
- **核心功能**：GFM（表格、任务列表）、KaTeX 数学公式、Mermaid、多媒体附件；同步后端抽象层支持 Nextcloud / Dropbox / OneDrive / WebDAV / S3 / 自托管 Joplin Server / Joplin Cloud，全部可选端到端加密；全文搜索；笔记历史版本；数百个插件 + 主题；Evernote ENEX 导入；导出 MD / HTML / PDF / JEX 归档
- **UI 设计**：经典三栏（笔记本树 / 笔记列表 / 编辑器）；观感偏「工具软件」，主题可换但默认样式常被嫌过时；无打字机模式（靠插件）；值得学习的细节：Web Clipper 与桌面端的无缝衔接
- **技术栈**：Electron + React（桌面），React Native（移动）；编辑器 CodeMirror 6 + TinyMCE
- **AI 能力**：官方无内置；社区插件 Jarvis 很成熟（支持 GPT / Claude / Gemini / Ollama / Hugging Face，笔记语义检索、以笔记为上下文对话、自动打标签 / 摘要，2026-07 仍在更新且支持移动端）
- **可借鉴点**：1) 同步后端抽象 + E2EE 的架构设计，让「开源应用 + 官方云」商业模式成立且不绑架用户；2) 以 Discourse 论坛 + Google Summer of Code 长期运营社区；3) Jarvis 证明「AI 交给插件、内核保持中立」也能满足用户
- **不足**：UI / 编辑器观感被长期抱怨（论坛名帖：「viewer 很美但 editor 很丑」）；大库（约 600+ 笔记）同步易冲突甚至丢笔记；移动端输入延迟、拼写检查缺失、同步慢是 App Store 差评重灾区

### Logseq
- **基本信息**：Logseq 团队（Tienson Qin 创立），有风投与 OpenCollective 捐赠支持｜Windows / macOS / Linux / iOS / Android / Web（app.logseq.com）｜应用免费；AGPL-3.0；Logseq Sync 长期 Beta、面向 5~15 美元/月的 OpenCollective 捐赠者，第三方追踪显示未来 Sync 定价约 5 美元/月（年付 4.17），Logseq Pro（RTC 协作）未公布定价｜官网 logseq.com｜github.com/logseq/logseq，约 44k star｜维护活跃但处在剧烈转型期：2.0.1 Beta（DB 版，2026-07-13）
- **编辑模式**：大纲（outliner）块编辑；块级「点击进源码、失焦即渲染」的混合实时渲染
- **核心功能**：双向链接、块引用、Org-mode 与 Markdown 双方言、日记流、PDF 标注、闪卡（间隔重复）、白板、Datalog / 简单查询、插件 API + 主题市场；v1 以纯 MD 文件为存储，2.0（DB 版）改为 SQLite 数据库 + RTC 实时协作 + 新移动端（iOS Alpha）；导出 MD / OPML / EDN / PNG
- **UI 设计**：左侧边栏 + 主区 + 可开右侧边栏；图谱视图；社区主题极丰富；无边距的大纲流设计是标志
- **技术栈**：ClojureScript（Electron 桌面 / Capacitor 移动）；自研块编辑器（每块一个 textarea 的方案）
- **AI 能力**：官方无内置；靠社区插件（gpt3-openai、ollama-logseq、copilot 类）
- **可借鉴点**：1) 块级大纲 + 双链的交互范式；2) 反面教训：「文件优先」转向「数据库优先」的三年大重写导致 HN / 论坛出现「bait and switch」指责与用户流失——承诺过的数据格式不要动摇；3) 路线图与社区沟通频率直接影响开源项目存亡感知（"Is Logseq dead?" 成为论坛热帖）
- **不足**：大图谱性能差（约 2000 页级别打开要数分钟、折叠块卡 10 秒+）；Sync 常年 Beta；DB 版放弃纯 Markdown 文件引发信任危机；开发停滞感与沟通不足是最大抱怨

### SiYuan (思源笔记)
- **基本信息**：云南链滴科技（B3log 开源社区，88250 与 Vanessa 两人核心团队）｜Windows / macOS / Linux / iOS / Android / HarmonyOS / Docker 自托管｜本体免费且允许商用；AGPL-3.0；年付订阅 148 元/年（原价 192，含官方同步 8GB、图床、微信收集箱），「功能特性」买断 64 元（解锁 S3 / WebDAV 第三方同步），续订终身锁定首次订阅价，教育 6.4 折｜官网 b3log.org/siyuan｜github.com/siyuan-note/siyuan，约 45.3k star｜维护极活跃：v3.7.2（2026-07-14）
- **编辑模式**：块级实时渲染所见即所得（类 Typora 即时渲染），可查看块的 Markdown 源码；内容以自有 .sy（JSON）格式存储，Markdown 为导入导出格式
- **核心功能**：块引用 / 双向链接、数据库（属性视图）、KaTeX、Mermaid / PlantUML / 甘特图 / 五线谱、闪卡间隔重复、SQL 查询、模板、插件 + 挂件 + 主题集市、端到端加密同步（官方云或 S3 / WebDAV）、数据快照与版本回滚、全文搜索、导出 MD / PDF / HTML / Word 并适配知乎 / 公众号发布
- **UI 设计**：类 IDE 的三栏 + 多页签 + 可停靠面板；对中文排版有大量细节优化（中西文混排间距等，编辑体验被少数派评为「远超 Typora」）；主题市场繁荣
- **技术栈**：内核为 Go 单二进制（本地 HTTP 服务）+ TypeScript 前端（Electron 壳）；自研 Markdown 引擎 Lute（Go）与所见即所得编辑器 Protyle
- **AI 能力**：内置，设置 OpenAI 兼容 API（可填自定义 Base URL 接本地 / 第三方模型）后提供续写、总结、翻译、润色等 AI 写作命令与问答
- **可借鉴点**：1) Protyle 的中文即时渲染编辑手感是同类天花板，值得逐细节对照；2) 「免费本体 + 同步订阅 + 小额功能买断」三层商业化，两人团队即可养活项目；3) 内核（Go 服务）与界面分离，天然获得 Docker / 移动 / 桌面全端复用
- **不足**：.sy 专有格式带来迁移顾虑（社区最常见吐槽）；大文档多图场景卡顿；同步收费与「开源但功能特性付费」引发争议；概念多、要写 SQL，对非技术用户门槛高；早期 UI/UX 曾长期被喷

### Trilium Notes / TriliumNext
- **基本信息**：原作者 zadam 个人项目，2024 年交由社区，TriliumNext 组织接棒维护（现回归 Trilium Notes 名称）｜Windows / macOS / Linux 桌面 + 服务器版（Docker，自带 Web UI），无官方移动 App｜完全免费；AGPL-3.0｜官网 / 文档 triliumnotes.org｜github.com/TriliumNext/Trilium，约 36.9k star｜维护活跃：v0.104.0（2026-07-18）
- **编辑模式**：非 Markdown 原生——CKEditor 5 富文本所见即所得（支持 Markdown 风格自动格式化输入），代码笔记用 CodeMirror；Markdown 仅作导入导出
- **核心功能**：无限层级笔记树 + 「笔记克隆」（一条笔记挂多处）；属性系统（标签 / 关系）支撑查询与自动化；前后端 JavaScript 脚本化 + REST API；自托管同步服务器；按笔记粒度加密；版本历史；关系图 / 思维导图 / 地理地图；网页分享发布；全文搜索
- **UI 设计**：左树 + 多标签编辑区的类 IDE 布局；主题可换但整体观感被评「过时、密集」；值得学习：属性面板与树操作的键盘效率
- **技术栈**：Electron + Node.js（TypeScript 化重构中）；CKEditor 5 + CodeMirror
- **AI 能力**：曾内置完整 LLM 集成（OpenAI / Anthropic / Ollama + 向量嵌入语义检索 + Agent 工具），因「长期维护不可持续」自 v0.102.0 起从核心移除，转向 MCP / 第三方插件（如 trilium-chat）
- **可借鉴点**：1) 属性 + 脚本让笔记应用变成「个人信息平台」的思路；2) 原作者退出后社区分叉续命的治理样本；3) 直接教训：内置多供应商 AI 的维护成本可能压垮小团队——用 MCP / 插件边界隔离 AI 更可持续
- **不足**：UI 老旧、无官方移动端（网页版触屏体验一般）、数据存 SQLite 内 HTML 而非 MD 文件、概念多上手复杂、Electron 资源占用

### AppFlowy
- **基本信息**：AppFlowy Inc.｜macOS / Windows / Linux / iOS / Android，云或自托管｜应用免费开源；AGPL-3.0；AppFlowy Cloud：Free（2 成员 / 5GB / 每月 10 次 AI 响应）、Pro 12.5 美元/成员/月（年付 120 美元/年，成员数叠乘）、AI MAX 附加包 8 美元/用户/月（GPT-5 / Claude / Gemini 前沿模型）、本地 AI「Vault Workspace」6 美元/用户/月（年付）；自托管免费｜官网 appflowy.com｜github.com/AppFlowy-IO/AppFlowy，约 74.1k star｜维护活跃：v0.12.5（2026-06-23）
- **编辑模式**：Notion 式块编辑所见即所得；Markdown 快捷输入 + 斜杠命令 + @ / [[ 引用；MD 导入导出
- **核心功能**：文档 + 数据库（网格 / 看板 / 日历视图）、模板库、多工作区、离线本地优先、AppFlowy Cloud（Rust）自托管、实时协作、AI 聊天与写作；导出 MD / HTML / PDF（部分）
- **UI 设计**：Notion 式左侧空间树 + 页面画布；移动端为独立优化的 Flutter UI；暗色主题；设计语言干净但细节完成度弱于 Notion
- **技术栈**：Flutter（全端 UI）+ Rust（核心与协作引擎），非 Electron
- **AI 能力**：深度内置且是主要付费点——AI 对话 / 写作 / 图像，支持云端前沿模型（付费附加包）与完全离线的本地模型（Ollama 路线的 Vault 方案，主打「AI 不出本机」）
- **可借鉴点**：1) 「本地 AI 作为付费功能」是对隐私用户群非常聪明的定价创新；2) Rust + Flutter 证明非 Electron 路线可行，但也暴露非原生观感问题；3) AGPL + 云订阅 + 按工作区计费的分层结构
- **不足**：功能广而不深、「rough around the edges / 不完整」是评论区高频词；移动端 bug 较多；相比 Notion 块类型仍少；Flutter 在桌面缺原生质感

### Anytype
- **基本信息**：Any Association（瑞士非营利实体，前 Anytype 团队）｜macOS / Windows / Linux / iOS / Android｜应用免费；协议为自订的 Any Source Available License 1.0（非 OSI 开源）；会员制：曾公示免费档 1GB 网络空间 / 3 个共享空间，2026 年第三方核实的新结构为 Plus 4 美元/月、Pro 8 美元/月、Ultra 16 美元/月（年付 8 折，具体以 anytype.io/pricing 为准）；学生与贡献者 5 折；30 天退款｜官网 anytype.io｜桌面端 github.com/anyproto/anytype-ts 约 8.5k star（核心在 anytype-heart 仓库）｜维护活跃：v0.55.26-beta（2026-07-18）
- **编辑模式**：块编辑所见即所得，一切内容是「对象 + 关系」；Markdown 可导入导出，但导出会丢失属性 / 关系 / 文字颜色（完整导出只能用自有 Any-Block JSON）
- **核心功能**：对象类型系统与自定义关系、集合（Set）查询视图、图谱、模板、白板、端到端加密（本地生成 12 词恢复短语）、P2P + 备份节点同步、多人共享空间与聊天、本地 API / MCP Server
- **UI 设计**：开源阵营公认颜值最高之一——克制的留白、精致的图标与动效、柔和配色；三栏可收纳；值得逐屏学习其空态页与新手引导
- **技术栈**：Electron + TypeScript 前端，Go 中间件（anytype-heart），自研 CRDT 同步协议 any-sync
- **AI 能力**：走「基础设施」路线：MCP Server + 公开 API 让本地 Claude / OpenAI 客户端读写笔记，官方原型「本地 Agent」（自带 API key 即起）；2026-02 官方博客明确「无 AI / 本地 AI / 云 AI 由用户自选」，暂无深度内置生成功能
- **可借鉴点**：1) 界面设计与品牌质感是本类别标杆；2) 「MCP 优先、把笔记变成 AI 记忆体」的集成思路与我们的 AI 规划高度相关；3) 反面：自造 source-available 协议带来长期的「假开源」舆论成本
- **不足**：非 OSI 开源被反复批评；MD 导出有损造成软锁定担忧；自托管困难（每次更新需自行编译）；Electron；学习曲线陡（对象 / 关系概念多）

### Notesnook
- **基本信息**：Streetwriters（巴基斯坦团队）｜Web / Windows / macOS / Linux / iOS / Android + Web Clipper｜免费档 + 订阅（2025 年底改版）：Essential 1.67 美元/月、Pro 5.83 美元/月（每月 10GB 附件流量、单文件 1GB）、Believer 7.5 美元/月（均为年付折算），Pro 年付有区域定价，学生优惠；全栈 GPL-3.0（含同步服务器，可自托管）｜官网 notesnook.com｜github.com/streetwriters/notesnook，约 14.3k star｜维护活跃：v3.4.4（2026-07-13）
- **编辑模式**：富文本块式所见即所得（支持 Markdown 快捷输入）；数据存加密数据库而非 MD 文件；导出 MD / PDF / HTML
- **核心功能**：端到端加密（XChaCha20-Poly1305 + Argon2）、笔记本 / 嵌套标签 / 颜色、提醒、私密 Vault（应用锁）、Monograph 公开分享页、附件管理、会话历史、自托管同步服务器、导入器覆盖 Evernote / Obsidian 等
- **UI 设计**：三栏，现代、圆润、移动端体验较好；专注模式；暗色主题；值得学习：加密产品也能做得不极客、面向普通消费者
- **技术栈**：React + Electron（桌面）、React Native（移动）；编辑器基于 TipTap（ProseMirror）
- **AI 能力**：无官方内置 AI（截至 2026-07 未见）
- **可借鉴点**：1) 「连服务器都开源」的全栈开源作为信任卖点；2) 定价改版时用博客长文解释成本结构（无限存储不可持续）——透明沟通降低涨价反弹；3) TipTap 技术选型参考
- **不足**：Apple 平台同步不稳（App Store 评论多次抱怨付费仍无法同步）；有用户报告附件下载失败疑似丢数据；把应用锁改为订阅功能引发「贪婪」批评；免费档 50MB/月附件太紧；无实时协作

### Standard Notes
- **基本信息**：Standard Notes（Mo Bitar 创立），2024-04 被 Proton AG 全资收购，保持独立品牌｜Web / Windows / macOS / Linux / iOS / Android，可自托管｜免费档（纯文本 + 基础 Markdown、3 天历史、不限设备）；Productivity 90 美元/年；Professional 120 美元/年（100GB 加密存储）；学生 7 折；AGPL-3.0｜官网 standardnotes.com｜github.com/standardnotes/app，约 6.6k star｜维护放缓：桌面 3.201.21（2026-03-06），并入 Proton 后节奏明显变慢
- **编辑模式**：多编辑器体系：纯文本；Markdown 源码 + 预览；新一代「Super」编辑器（块式富文本，Markdown 快捷输入与双向转换）
- **核心功能**：端到端加密同步、嵌套文件夹与标签（付费）、无限版本历史（付费）、每日加密备份、Listed 匿名博客发布、文件存储（付费）、自托管服务器、双因素认证
- **UI 设计**：极简双 / 三栏；刻意朴素、无干扰；主题属付费功能；专注模式
- **技术栈**：Electron + React；Super 编辑器基于 Meta 的 Lexical 框架
- **AI 能力**：无内置 AI（隐私定位使然）
- **可借鉴点**：1) 「长期主义 + 安全审计报告」的品牌构建（多次第三方审计公开）；2) 被 Proton 收购是开源笔记公司少有的善终样本，可研究其协议（AGPL）如何保住社区信任；3) Lexical 作为编辑器选型的参考案例
- **不足**：免费档只有纯文本被广泛抱怨「差距过大」；订阅偏贵（90 美元/年）；无双链 / 图谱等 PKM 能力；Super 编辑器长期修 bug；收购后发展前景存疑

### Outline
- **基本信息**：General Outline, Inc.（Tom Moor 等）｜Web SaaS（getoutline.com）+ Docker 自托管，无官方原生桌面 / 移动端｜协议 BSL 1.1（非 OSI 开源，自托管个人 / 团队使用免费，商业增强需授权）；云版 30 天试用后按团队人数分层计费，第三方核实入门约 10 美元/月（小团队），200 人以上联系销售，非营利 / 教育 7 折｜官网 getoutline.com｜github.com/outline/outline，约 39.8k star｜维护活跃：v1.9.1（2026-07-13）
- **编辑模式**：富文本所见即所得（ProseMirror），全量 Markdown 快捷输入、粘贴 MD 自动转换、斜杠命令；导出保持 Markdown 兼容
- **核心功能**：集合 / 嵌套文档结构、实时多人协作与评论、版本历史、40+ 集成（Slack 深度集成）、API 完善、公开分享与站点发布、多语言、全文搜索
- **UI 设计**：公认「漂亮的团队 wiki」——大字号标题、克制的留白、优秀的快捷键体系、暗色模式；值得逐项学习其斜杠菜单与粘贴智能转换
- **技术栈**：Node.js + React + TypeScript + MobX；编辑器基于 ProseMirror（由其开源的 rich-markdown-editor 演化而来）
- **AI 能力**：「AI Answers」——基于工作区文档的语义检索问答，出现在搜索顶部与 Slack 中；仅云版 / 授权版可用，自托管需配 OPENAI_API_KEY + pgvector；承诺数据不用于训练
- **可借鉴点**：1) 「Markdown 快捷输入 + 斜杠命令」的编辑手感是同类标杆，直接对标学习；2) AI Answers 是「检索问答先于生成写作」的稳妥 AI 切入点；3) BSL 的取舍：保护了商业化但持续被质疑「不算开源」
- **不足**：BSL 引发开源社区不满；定位团队协作、单人使用过重；自托管依赖 Postgres / Redis / S3 配置繁琐；离线能力弱、无本地文件存储

### Memos
- **基本信息**：usememos 开源社区（创始人 Steven）｜自托管 Web（Docker 单容器，SQLite / MySQL / PostgreSQL），无官方桌面 / 移动端（社区有 MoeMemos 等第三方 App）｜完全免费，无任何付费服务；MIT｜官网 usememos.com｜github.com/usememos/memos，约 61.7k star｜维护活跃：v0.29.1（2026-06-05）
- **编辑模式**：纯 Markdown 源码输入框，发布后渲染为卡片；「时间线优先」的微博式流，无所见即所得
- **核心功能**：GFM 子集（任务列表、代码块、#标签）、图片 / 文件附件、笔记间引用、公开 / 私有可见性、RSS、REST + gRPC API、Web Clipper、全文搜索；无端到端加密、无版本历史、无插件系统
- **UI 设计**：单栏时间线 + 左侧窄导航，极简；移动浏览器体验好；值得学习：把「快速捕捉」这一个动作的摩擦降到最低
- **技术栈**：Go 后端 + React / TypeScript 前端
- **AI 能力**：无内置；社区经 API 外接 AI 机器人 / RAG 属自行搭建
- **可借鉴点**：1) 单一场景（闪念捕捉）做到极致也能拿下 60k+ star，「小而清晰」的产品定义力；2) MIT + 零商业化的纯社区模式对我们「开源免费」定位是一种参照；3) API 优先带来繁荣的第三方客户端生态
- **不足**：版本间破坏性变更频繁（如 v0.26.0 认证 / 数据库大改，升级须备份）；功能刻意精简（无层级、无 E2EE）不适合做主力知识库；无官方移动端

### SilverBullet
- **基本信息**：Zef Hemel 个人发起 + 社区｜自托管 Web / PWA（Docker / 单二进制），数据即本地 Markdown 文件夹；桌面移动均通过浏览器 / PWA 安装｜完全免费；MIT｜官网 silverbullet.md｜github.com/silverbulletmd/silverbullet，约 5.7k star｜维护活跃：v2 于 2025-08 发布，2.9.0（2026-06-11）
- **编辑模式**：CodeMirror 6 实时渲染混合模式（光标所在处显源码、其余渲染，类 Obsidian Live Preview）
- **核心功能**：wiki 链接、frontmatter、对象索引与集成查询、模板、命令面板、Plugs 插件（沙箱 Web Worker）、「Space Lua」（Lua 5.4 方言）统一脚本 / 模板 / 查询 / 自定义 Widget、离线优先 PWA、多设备经服务器同步
- **UI 设计**：单栏编辑器 + 命令面板的极简界面，几乎无 chrome；值得学习：把「页面即程序」做成一致的心智模型
- **技术栈**：客户端 TypeScript + CodeMirror 6 + Preact；v2 服务器用 Rust 重写（v1 为 Deno）；渲染、索引、Lua 全在客户端跑
- **AI 能力**：社区插件 silverbullet-ai（justyns 维护）：OpenAI / Gemini / Ollama / Mistral / OpenRouter 等，右侧 AI 聊天面板、以笔记为上下文、向量嵌入语义搜索、prompt 模板；仍标注早期阶段
- **可借鉴点**：1) 「Markdown 文件为唯一事实源 + 内存索引层」的架构，兼得纯文件与数据库查询；2) 用一门嵌入式语言（Lua）统一扩展面，比插件 API 更彻底；3) LWN / HN 报道显示极客定位也能形成高粘性小社区
- **不足**：门槛高（需自托管、写 Lua）；v1→v2 迁移有破坏性（移除 online mode 与旧查询语法）；无原生客户端；受众小众

### Dendron
- **基本信息**：Dendron Inc.（Kevin Lin），VC 资助｜VS Code 扩展（跨平台）｜免费；Apache-2.0｜官网 dendron.so｜github.com/dendronhq/dendron，约 7.5k star｜维护状态：README 明示「仅维护模式，活跃开发已停止」（2023 年起）
- **编辑模式**：VS Code Markdown 源码编辑 + 预览面板（分屏）
- **核心功能**：层级命名法（`project.tasks.2024` 式点分隔）+ Lookup 快速检索创建、Schema 模板校验、反向链接、图谱、批量重构（改名自动更新链接）、多 Vault、Next.js 静态发布；号称支撑 1 万+ 笔记
- **UI 设计**：完全继承 VS Code；无自有设计体系
- **技术栈**：TypeScript / VS Code 扩展 API
- **AI 能力**：无
- **可借鉴点**：1) 「层级 + Schema」对抗大库混乱的信息架构思路；2) 反面教训：面向开发者的笔记工具付费转化极难，公司化运营两年即停摆——对我们的开源定位是商业化警钟
- **不足**：停止开发；绑定 VS Code、非开发者无法使用；概念与配置繁重

### Foam
- **基本信息**：社区项目（Jani Eväkallio 发起）｜VS Code 扩展｜免费；MIT｜官网 foambubble.github.io/foam｜github.com/foambubble/foam，约 17.3k star｜维护中但节奏平缓：vscode 0.40.4（2026-05-14）
- **编辑模式**：VS Code 源码编辑 + Markdown 预览
- **核心功能**：`[[wikilink]]` 与自动补全、反链面板、知识图谱可视化、日记与模板、笔记嵌入、孤立笔记 / 占位符检测、标签浏览器；配合 Git / GitHub Pages 存储与发布
- **UI 设计**：依附 VS Code；图谱视图是少数自有 UI
- **技术栈**：TypeScript / VS Code 扩展 API
- **AI 能力**：无（可间接借用 VS Code 内 Copilot 等）
- **可借鉴点**：1) 「寄生在成熟编辑器上」实现最小可行 PKM，验证了 wiki 链接 + 反链 + 图谱是该品类的最小功能闭环；2) 零商业化的社区自治可持续样本（与 Dendron 对照）
- **不足**：绑定 VS Code；功能天花板低、迭代慢；移动端无解

### Athens Research
- **基本信息**：Athens Research（Jeff Tang），曾获风投的开源 Roam 替代品｜桌面（Electron）+ Web Demo｜免费；代码 EPL-1.0 + 创意内容 CC BY-SA 3.0｜github.com/athensresearch/athens，约 6.3k star｜已停止维护：README 明示「no longer maintained」，最后版本 v2.0.0（2022-08）
- **编辑模式**：Roam 式大纲块编辑、双链、斜杠命令；数据存图数据库（非 MD 文件），可导出 Markdown
- **核心功能**：块引用 / 双链 / 日记 / 图谱，后期转型团队协作知识图谱（RTC）
- **UI 设计**：Roam 式极简大纲；当年以社区共建设计著称
- **技术栈**：ClojureScript + Electron + Datascript 图数据库
- **AI 能力**：无
- **可借鉴点**：1) 最完整的反面样本：VC 融资 + 开源 PKM + 转型协作仍失败，说明该品类难以支撑风投回报模型，「小成本 + 社区」路线更现实；2) 其「build in public」的社区动员（公开路线图、贡献者课程）早期非常成功，运营手法可借鉴
- **不足**：项目已死；在世时即有性能与稳定性抱怨；图数据库存储依赖导出工具迁移

### AFFiNE
- **基本信息**：toeverything（AFFiNE 团队）｜macOS / Windows / Linux / iOS / Android / Web + Docker 自托管｜核心 MIT（企业版另有授权）；AFFiNE Cloud：Free（10GB / 3 成员 / 7 天历史）、Pro 6.75 美元/月（年付，100GB）、AI 附加 8.9 美元/月（年付）、自托管 Team 10 美元/座/月（10 座起）、Believer 终身买断 499.99 美元（1TB）｜官网 affine.pro｜github.com/toeverything/AFFiNE，约 70.6k star｜维护极活跃：v0.27.2（2026-07-20）
- **编辑模式**：双形态一键切换：Page 模式（块编辑所见即所得，Markdown 快捷输入）与 Edgeless 无边界白板模式（文档与画布同一份数据）；导出 MD / HTML / PDF / PNG
- **核心功能**：文档 + 白板 + 数据库表格、双链、模板、实时协作、本地优先（CRDT）、AI 生成演示文稿 / 思维导图 / 写作、自托管
- **UI 设计**：现代、动效丰富、接近 Notion + Miro 融合体；设计感强但密度高；值得学习其文档/白板切换的过渡设计
- **技术栈**：TypeScript；自研开源编辑器框架 BlockSuite（基于 Yjs CRDT）；桌面 Electron（含少量 Rust / Swift / Kotlin 原生模块）
- **AI 能力**：内置 AFFiNE AI（付费附加）：续写 / 改写 / 总结、由文档生成思维导图与幻灯片、白板内 AI 绘图
- **可借鉴点**：1) BlockSuite 是可直接研究（MIT）的块编辑器 + CRDT 实现；2) 「一份数据、文档与白板双视图」的形态创新；3) MIT 宽松协议 + 云增值 + 终身买断组合定价
- **不足**：功能铺得广、稳定性与细节打磨常被抱怨（bug 多、性能一般）；本地版与云版功能差异引发困惑；产品心智介于笔记与白板之间不够聚焦

### Docmost
- **基本信息**：Docmost 团队（开源 Confluence / Notion 替代）｜自托管 Web（Docker）+ 云版｜核心 AGPL-3.0，企业功能走商业授权（open-core）；自托管社区版免费，云版 / 企业版定价见官网（具体数字未知）｜官网 docmost.com｜github.com/docmost/docmost，约 21.1k star｜维护活跃：v0.95.0（2026-07-03）
- **编辑模式**：富文本所见即所得（TipTap / ProseMirror 系），Markdown 快捷输入；MD 导入导出
- **核心功能**：空间（Spaces）+ 权限 + 群组、实时协作与评论、页面历史、全文搜索、附件、Mermaid / Draw.io / Excalidraw 图表嵌入、多语言
- **UI 设计**：干净的 Notion 风双栏；功能面克制
- **技术栈**：TypeScript（NestJS + React），协作基于 Yjs
- **AI 能力**：未知（官方博客谈论 AI wiki 话题，未见内置生成功能）
- **可借鉴点**：1) AGPL 社区版 + 企业授权的 open-core 边界划分清晰（SSO 等企业能力收费）；2) 两年内从零到 20k+ star，验证「Confluence 平替」叙事的拉新效率
- **不足**：年轻项目功能缺口多（导出、集成较少）；主打团队场景、个人使用偏重；无桌面 / 移动客户端

### Blinko
- **基本信息**：blinko-space 社区｜自托管 Web + Tauri 客户端（macOS / Windows / Linux / Android）｜免费；GPL-3.0（awesome-selfhosted 收录时标注 AGPL-3.0，以仓库现行 GPL-3.0 为准）｜github.com/blinko-space/blinko，约 10.8k star｜维护活跃：1.8.8（2026-06-20）
- **编辑模式**：Memos 式卡片流 + Markdown 源码输入
- **核心功能**：闪念卡片笔记、完整 Markdown、标签、附件、AI RAG 语义检索（接 OpenAI / Ollama 等自选模型）、每日回顾、自托管数据自主
- **UI 设计**：卡片流 + 柔和圆角，比 Memos 更「消费级」的观感
- **技术栈**：TypeScript 为主，客户端用 Tauri（Rust）打包
- **AI 能力**：内置且是卖点：AI RAG 检索问答、AI 标签 / 归档辅助，模型可自配（含本地 Ollama）
- **可借鉴点**：1) 「轻笔记 + 自带 RAG」是 AI 时代对 Memos 模式的直接升级，验证了本地知识库问答的需求；2) Tauri 客户端的轻量化路线
- **不足**：项目年轻、稳定性与文档一般；依赖自托管；深度知识管理能力有限

### QOwnNotes
- **基本信息**：Patrizio Bekerle（个人开发者）｜Windows / macOS / Linux（唯一 Qt 原生桌面派）｜完全免费；GPL-2.0｜官网 qownnotes.org｜github.com/pbek/QOwnNotes，约 5.8k star｜维护极活跃：滚动发布，v26.7.8（2026-07-18）
- **编辑模式**：Markdown 源码编辑（编辑器内高亮渲染）+ 可选预览面板
- **核心功能**：平面 MD 文件夹存储、Nextcloud / ownCloud 笔记同步与版本恢复、wiki 链接与反链、AES-256 笔记加密、拼写 / 语法检查、脚本引擎（QML/JS）+ 在线脚本市场、任务（CalDAV）集成、全文搜索
- **UI 设计**：可自由停靠的多面板工具型 UI，信息密度高、观感老派；面板布局可存为工作区
- **技术栈**：C++ / Qt（Qt 5.5+ / Qt 6）原生，非 Electron——本类别唯一原生应用
- **AI 能力**：内置 AI 支持（可接 OpenAI、Groq 等接口进行文本生成辅助）
- **可借鉴点**：1) 原生框架的性能与内存优势实证（秒开、低占用），对我们做原生 macOS 是直接参照；2) 单人开发者 + 快速小步发布维持十年活力；3) 脚本市场以极低成本实现可扩展性
- **不足**：UI 审美与易用性常被诟病「工程师风」；macOS 端非一等公民（Qt 观感与系统不融合）；无官方移动端

### Flatnotes
- **基本信息**：Dullage（个人开发者）｜自托管 Web（Docker）｜完全免费；MIT｜github.com/dullage/flatnotes，约 3.2k star｜维护平缓：v5.5.4（2025-10-20）
- **编辑模式**：原始 Markdown 源码模式与所见即所得模式双模切换
- **核心功能**：「无数据库——就是一个平面 Markdown 文件夹」；高级搜索（含通配符）、#标签、`[[wikilink]]`、REST API、多种认证方式（含无认证 / TOTP）；无同步（数据在服务器文件系统）、无版本历史、无插件
- **UI 设计**：单栏极简、响应式移动布局；首页即搜索框的「search-first」设计有辨识度
- **技术栈**：Python（FastAPI）后端 + Vue 前端
- **AI 能力**：无
- **可借鉴点**：1) 「一个 md 文件夹就是全部数据」的极端透明存储承诺，换来的信任感值得我们在文案与架构上效仿；2) search-first 的入口设计
- **不足**：单用户为主、功能极少；无客户端、依赖自托管；更新缓慢

## 本类别小结

**共性与趋势**
- **协议即战略**：做官方云服务的项目几乎清一色 AGPL-3.0（Joplin、Logseq、SiYuan、Trilium、AppFlowy、Docmost），用传染性阻止第三方托管抢生意；纯社区工具选 MIT（Memos、SilverBullet、Foam、Flatnotes、AFFiNE 核心）换取传播最大化；想两头占的走 BSL（Outline）或自造协议（Anytype），但都持续付出「不算真开源」的舆论成本。
- **商业化只有一条被验证的路**：应用免费开源 + 官方同步 / 协作订阅（Joplin Cloud 2.99 欧/月起、SiYuan 148 元/年、Notesnook 1.67 美元/月起、AFFiNE 6.75 美元/月），辅以小额买断（SiYuan 64 元特性、AFFiNE 499 美元终身）；纯靠 VC 的 Athens、Dendron 均已死亡，证明该品类撑不起风投模型，「低成本小团队 + 订阅」才是可持续解。
- **存储格式是信任生命线**：放弃纯 Markdown 文件的项目全部付出了代价——Logseq 转数据库被骂「bait and switch」、SiYuan 的 .sy、Anytype 的有损导出、Trilium 的 SQLite 都在社区被反复声讨；而 SilverBullet / Flatnotes / QOwnNotes 的「文件夹即数据」是口碑最稳的承诺。
- **编辑器内核集中在三家**：CodeMirror 6（源码 / 混合渲染：Joplin、SilverBullet）、ProseMirror 系（所见即所得：Outline、Notesnook、Docmost 的 TipTap）、以及少数自研（SiYuan 的 Protyle、AFFiNE 的 BlockSuite）；原生渲染方案在本类别是空白。
- **AI 姿态分层**：内置并收费（AppFlowy、AFFiNE、SiYuan）、检索问答先行（Outline AI Answers、Blinko RAG）、交给插件生态（Joplin Jarvis、silverbullet-ai、Logseq 插件）、明确当基础设施做 MCP / API（Anytype）、以及做了又撤（Trilium）——「本地模型 / 自带 key」是隐私用户群的共同底线。
- **Electron 统治、原生缺位**：19 个项目中仅 QOwnNotes 为原生（Qt），AppFlowy（Flutter+Rust）、Blinko（Tauri）为折中；「原生 macOS + 好看」在开源知识库领域几乎无人占位。

**对我们产品的启示**
- **定位空档明确**：「原生 macOS（AppKit/SwiftUI）+ 简洁好看 + 纯 Markdown 文件 + 开源」的组合在本类别是空白——最接近的 QOwnNotes 输在审美，颜值最高的 Anytype / AFFiNE 输在 Electron 与格式锁定；这正是我们的差异化位置。
- **协议建议**：若计划未来做官方同步 / AI 云服务，学 Joplin / SiYuan 用 AGPL-3.0 起步最稳（保留商业护城河且社区接受度高）；若纯客户端不做云，MIT/Apache 更利传播。避免 BSL 与自造协议的舆论税。
- **存储承诺写进宣言**：第一天就承诺「本地 Markdown 文件夹为唯一事实源、永不引入私有格式」，并像 SilverBullet 一样用内存索引层补数据库能力——这是从 Logseq / Anytype 流失用户的最强接收器。
- **AI 集成路线**：学 Anytype 与 Trilium 的正反两面——不要在核心内置多供应商 AI（维护黑洞），而是「OpenAI 兼容接口 + 自带 key + 本地 Ollama + MCP 暴露笔记库」的薄层设计；第一个 AI 功能优先做「基于笔记库的检索问答」（Outline AI Answers 模式）而非炫技生成。
- **编辑手感对标对象**：源码 / 混合模式对标 SilverBullet（CodeMirror 6 实时渲染），中文即时渲染细节对标 SiYuan Protyle，快捷输入 / 斜杠命令对标 Outline；三者拆解后取交集即是「简洁好看」的工程定义。
- **社区运营参照**：Joplin 的 Discourse 论坛 + GSoC、SiYuan 的集市生态、Athens 早期的 build-in-public 都值得抄作业；同时守住 Memos / Logseq 的教训——升级不搞破坏性变更、路线图沟通高频透明。
