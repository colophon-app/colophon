# Web 在线 Markdown 编辑器

> 类别总体观察：Web 端 Markdown 编辑器可分为四个亚类——通用在线编辑（StackEdit、Dillinger）、实时协作平台（HackMD、HedgeDoc）、目标平台排版工具（mdnice、doocs/md、Md2All 等微信公众号排版，属中文市场特有物种）、可嵌入编辑器组件（Editor.md、Vditor、TOAST UI、Milkdown、EasyMDE）。一个明显的分化是：没有清晰变现或场景定位的通用工具普遍陷入停滞（StackEdit 2019 年后无大版本、Editor.md 停留在 2015、TOAST UI 2022 年后冻结），而有明确场景（公众号排版的 doocs/md）或商业模式（HackMD SaaS）的产品仍在高速迭代。编辑交互上，行业从「双栏分屏」向「即时渲染/所见即所得」演进，技术底座高度集中于 ProseMirror（Milkdown、TOAST UI v3、Bangle.io）与 CodeMirror，中文社区则贡献了独有的 Lute 引擎（Vditor）。AI 方面整体渗透率不高：doocs/md 是唯一深度内置 AI 侧边栏的开源产品，HackMD 则选择「API + MCP，做人与 AI Agent 的共享上下文层」这一差异化路线。

### StackEdit
- **基本信息**：开发者 Benoit Schweblin（benweet，个人开发者）｜平台：浏览器（PWA，可离线）｜价格与授权：免费，开源 Apache-2.0；应用内另有约 $5/年 的赞助计划用于解锁服务器端 PDF/Pandoc 导出｜官网 https://stackedit.io ｜GitHub：github.com/benweet/stackedit，约 23,000 star｜维护状态：最近一次代码推送为 2023-07，最后大版本 v5.14.0 发布于 2019-07，属半停更状态（站点仍可用）
- **编辑模式**：双栏分屏预览 + 精确 Scroll Sync（双栏滚动条严格绑定）；编辑区本身用 contenteditable 做了「样式化语法高亮」——加粗、标题在源码区就有格式感，介于纯源码与 WYSIWYG 之间；预览栏可一键收起变单栏
- **核心功能**：Markdown Extra / GFM / CommonMark 三种方言且每个语法特性可单独开关；KaTeX 数学公式、mermaid 流程图/时序图、ABC 记谱法（五线谱）、emoji；文件同步 Google Drive / Dropbox / GitHub / CouchDB，可发布到 Blogger、WordPress、Zendesk、GitHub Pages；导出 Markdown / HTML / 经 Handlebars 模板自定义格式；内置工作区文件树、离线写作；「协作」通过同步 + DiffMatchPatch 合并实现（非实时协同）
- **UI 设计**：三栏结构（可折叠文件树 + 编辑 + 预览），顶部极简、多数功能藏在右侧抽屉；2017 年 Material 风格，如今显得过时；最值得学习的细节是编辑区内的样式化语法渲染与精确 Scroll Sync
- **技术栈**：Vue.js SPA；自研 cledit 编辑内核（contenteditable + MutationObserver + Google DiffMatchPatch）；渲染用 markdown-it + 大量插件（footnote、deflist、abbr 等）；PWA 离线
- **AI 能力**：无
- **可借鉴点**：1) 编辑区「源码但有格式感」的样式化高亮，是纯源码与 WYSIWYG 之间的优雅折中；2) 按语法特性逐项开关的方言配置面板；3) Scroll Sync 的精确绑定算法（业界口碑最好之一）
- **不足**：2019 年后基本停更，730+ open issue 无人处理；云同步依赖 Google/GitHub 登录，本地优先用户不满；官方文档匮乏，功能靠自己摸索；界面陈旧（HN/Reddit 常见评价：「好用但看起来像被遗弃了」）

### Dillinger
- **基本信息**：开发者 Joe McCann（Node.js 社区知名开发者）｜平台：浏览器｜价格与授权：完全免费无付费层，开源 MIT｜官网 https://dillinger.io ｜GitHub：github.com/joemccann/dillinger，约 8,300 star｜维护状态：最近推送 2026-06，仍在维护（但功能多年无大变化）
- **编辑模式**：双栏分屏实时预览 + scroll sync，无 WYSIWYG；支持 Zen（禅）专注模式一键去除干扰
- **核心功能**：GFM + 内嵌 HTML；一键导出 Markdown / 带样式 HTML / PDF；OAuth 云存储矩阵：GitHub、Dropbox、Google Drive、OneDrive、Bitbucket 均可导入并存回；拖拽导入 md/html/图片文件（图片需连接 Dropbox）；文档自动保存到浏览器 localStorage，首次加载后可离线用；Vim / Emacs 键位
- **UI 设计**：经典双栏 + 顶部菜单（导出藏在 Utilities 菜单里），带夜间模式；风格是「工具型极简」，打开即写零门槛；最值得学习的是无需注册即可完成写作—导出的完整闭环
- **技术栈**：Node.js 后端 + 浏览器前端；早期为 AngularJS + Ace 编辑器，官网现称基于 Monaco（VS Code 同款编辑内核）
- **AI 能力**：无
- **可借鉴点**：1) 「打开即写、无账号」的零摩擦启动；2) 五大云盘 OAuth 集成做文件的导入/写回；3) Zen 模式的克制实现（一个按钮，不搞复杂设置）
- **不足**：无协作、无版本历史；评测称其「简单够用但缺进阶功能」；文件管理完全依赖第三方云盘，本身无文库概念

### HackMD
- **基本信息**：开发者 HackMD 团队（台湾公司，前身即 CodiMD 的商业母体）｜平台：浏览器 SaaS + REST API + MCP Server｜价格与授权：闭源；Free $0（笔记不限量、单笔记最多 3 名协作者、版本历史仅保留最近 10 个、3 个自定义模板、1MB 图片上传、API 400 次/月、GitHub push 20 次/月）；Prime $5/席/月（年付，官方称省 37.5%，即月付约 $8/席/月）解锁全文搜索、20MB 图片、PDF 导出、无限版本/模板/GitHub push、API 2 万次/月、GitLab 集成；Enterprise 定制价（RBAC、SAML/LDAP SSO、自定义域名、可私有部署）｜官网 https://hackmd.io ｜开源版见 HedgeDoc 条目｜维护状态：活跃运营中
- **编辑模式**：双栏分屏，支持「仅编辑 / 双栏 / 仅预览」三视图切换；移动端自动切单栏
- **核心功能**：实时多人协同（多光标）、行内评论、suggest edit（建议编辑，类似 Google Docs 建议模式）、版本时间线（命名版本、对比 diff、回滚、下载）、GitHub App 双向同步（笔记内直接 pull/push 到仓库）、Book 模式（多篇笔记组织成书）、Slide 模式（reveal.js，YAML slideOptions 配置主题/转场，S 键进入演讲者视图含计时器）、团队工作区、模板；数学公式、mermaid 等图表；笔记权限用一个下拉框设定（谁可读/谁可写：owner / signed-in / guest 组合）
- **UI 设计**：双栏 + 顶部工具栏，功能密度较高、偏工程师审美；暗色主题；最值得学习的是「一个下拉框解决分享权限」和版本时间线的可滚动叙事感
- **技术栈**：Web SaaS（同源的 CodiMD 为 Node.js + CodeMirror 5，协同基于 OT）；提供 REST API 与官方 MCP Server
- **AI 能力**：编辑器内无续写/改写按钮；战略上把自己定位为「团队与 AI Agent 的共享上下文层」——通过 API + MCP 让 Claude Code、Cursor、GitHub Actions 等读写笔记，宣称 API 月调用量超 100 万次
- **可借鉴点**：1) 权限模型的交互极简化（一个控件、几个明确档位）；2) 版本历史做成「可命名、可对比、可回滚」的时间线；3) 通过 MCP 把文档暴露给 AI Agent——这与我们「接入 AI 的原生编辑器」高度相关，可让文档成为 agent 可读写的上下文
- **不足**：Capterra 评论称「对比其他知识管理工具，价格贵而功能少」；G2 评论称移动端不友好（Android 键盘弹出问题，官方承认原生移动端遥遥无期）；GitHub issue 反馈长文档（约 400 行 + 20 图）出现打字卡顿；免费版单笔记 3 协作者、10 个版本的限制常被吐槽；hackmd.io 公开笔记被 SEO 垃圾内容滥用影响观感

### HedgeDoc (CodiMD)
- **基本信息**：开发者 HedgeDoc 开源社区（2015 年始于 HackMD 开源版，2018 分叉为 CodiMD，2020 改名 HedgeDoc）｜平台：浏览器 + 自托管服务端（Docker/Node.js），无官方云服务｜价格与授权：免费，AGPL-3.0｜官网 https://hedgedoc.org ｜GitHub：github.com/hedgedoc/hedgedoc 约 7,300 star（最近推送 2026-07）；另有 HackMD 官方维护的姊妹项目 github.com/hackmdio/codimd 约 10,100 star（AGPL-3.0，最近推送 2025-10）｜维护状态：1.x 仅维护不加新功能；2.0 完全重写进行中，已至 Alpha 3，GitHub 里程碑完成约 88%，尚无稳定版发布日期
- **编辑模式**：双栏分屏，视图三档 View / Both / Edit；编辑器为 CodeMirror，右下角可切 Sublime / Emacs / Vim 键位
- **核心功能**：实时多人协同；GFM + 数学公式、mermaid、graphviz、abc 记谱、csv 表格等多种图表嵌入；`:` 触发 emoji 补全、`[]`/`{}`/`!` 触发引用与图片提示；Slide 模式（reveal.js，文档类型设为 slide 即可演示）；Revision 版本记录与回滚；图片上传（本地 / S3 / Azure / imgur 等后端）；导出 Markdown / HTML / PDF；权限系统 6 档：freely（任何人可编辑）/ editable（登录者可编辑，游客只读）/ limited / locked（仅所有者可编辑）/ protected / private，由所有者通过右上角小按钮切换；登录支持 LDAP、SAML、OAuth2、GitHub 等十余种
- **UI 设计**：双栏 + 顶栏，编辑侧默认暗色、预览侧亮色（可分别切换昼/夜）；ToC 按钮悬浮于预览区右下角并高亮当前章节；设计务实、无明显美学野心；最值得学习的是 6 档权限模型与「文档类型 = slide/book」的模式化思路
- **技术栈**：Node.js 服务端；1.x 前端 CodeMirror 5 + markdown-it；2.0 重写拆分为独立前后端（React + NestJS）；资源占用低，官方称树莓派可流畅运行
- **AI 能力**：无
- **可借鉴点**：1) 六档笔记权限的命名与粒度设计（匿名协作到完全私有的完整光谱）；2) 「一份 Markdown，多种呈现」（文档/幻灯片切换）；3) 开源协作编辑器自托管生态的运营方式（社区、demo 实例）
- **不足**：2.0 重写历时 5 年以上仍在 alpha，1.x 期间新功能冻结，社区多次追问时间表；无评论/建议编辑系统（对比 HackMD）；发布页面缺乏排版美感、无模板与自定义样式；自托管需自己维护服务器、数据库与备份

### Editor.md
- **基本信息**：开发者 pandao（中国个人开发者）｜平台：浏览器（可嵌入的开源组件）｜价格与授权：免费，MIT｜官网 https://pandao.github.io/editor.md/ ｜GitHub：github.com/pandao/editor.md，约 14,300 star｜维护状态：最后正式版本 v1.5.0 发布于 2015-06-09，事实停更逾十年（仓库偶有提交至 2024-04，580+ open issue 基本无人处理）
- **编辑模式**：双栏分屏实时预览（可关闭预览 watch/unwatch）、全屏模式、只读模式；顶部大工具栏驱动
- **核心功能**：CommonMark + GFM，ToC、emoji、任务列表、@链接 等扩展；KaTeX 数学公式、flowchart 流程图、sequence 时序图；代码折叠、搜索替换、多语言语法高亮、跨域图片上传、识别与过滤 HTML 标签；AMD/CMD 模块化加载（Require.js/Sea.js），支持自定义插件与主题
- **UI 设计**：典型「jQuery 时代」双栏 + 密集图标工具栏；主题可自定义但整体审美停留在 2015；对我们价值主要是反面教材——工具栏堆砌的界面已被时代淘汰
- **技术栈**：CodeMirror + jQuery + marked.js
- **AI 能力**：无
- **可借鉴点**：1) 作为组件被国内大量博客/CMS/论坛嵌入，验证了「编辑器组件化生态」的传播力；2) 功能逐项开关的嵌入配置思路
- **不足**：停更十年、依赖 jQuery 技术栈过时；早期 issue 即反馈录入延迟明显（#45）；新项目已普遍改用 Vditor / TOAST UI 等替代

### Vditor
- **基本信息**：开发者 Vanessa219（严丽）与 88250，隶属 B3log 开源社区（思源笔记同团队）｜平台：浏览器组件（原生 JS / Vue / React / Angular / Svelte 均可用）｜价格与授权：免费，MIT｜官网 https://b3log.org/vditor ｜GitHub：github.com/Vanessa219/vditor，约 11,200 star｜维护状态：最近推送 2026-07，持续活跃
- **编辑模式**：一个内核三种模式——WYSIWYG 所见即所得（富文本式）、IR 即时渲染（类 Typora：光标所在处显示源码、离开即渲染）、SV 传统分屏预览；模式可在初始化与运行时切换
- **核心功能**：全部 CommonMark + 全部 GFM（表格、任务列表、删除线、自动链接、XSS 过滤）+ 脚注、ToC、自定义标题 ID，大部分特性可开关；数学公式、脑图、图表、流程图、甘特图、时序图、五线谱、Graphviz、PlantUML；大纲面板、语音阅读、标题锚点、代码高亮与一键复制、导出、图片懒加载、任务列表、多平台预览、「复制到微信公众号/知乎」适配；工具栏 36+ 项且每项的快捷键、图标、提示、子菜单均可自定义
- **UI 设计**：默认双栏或单栏（取决于模式），内置亮/暗主题与内容主题切换；作为组件不强加布局；最值得学习的是 IR 模式的光标交互细节（国产实现里最接近 Typora 的）
- **技术栈**：TypeScript；渲染引擎为 Lute——Go 编写、编译到 JS 的结构化 Markdown 引擎，完整实现最新 CommonMark/GFM 规范，基于 AST 操作，支持源码映射（IR 模式的基础），并针对中文语境优化（如中西文间自动空格、术语修正）
- **AI 能力**：无内置
- **可借鉴点**：1) 「一个引擎、三种编辑模式」的架构——我们的原生 app 若想同时提供源码与即时渲染，可参考其 AST + 源码映射方案；2) Lute 引擎对中文排版的专门优化（自动空格、中文标点处理），这是面向中文用户的关键差异点；3) 复制到公众号/知乎的目标平台适配开关
- **不足**：文档与社区以中文为主，国际化存在门槛；是组件而非成品应用，开箱体验依赖集成方；所见即所得/即时渲染模式在复杂嵌套语法下的光标与解析边缘情况是 issue 区的主要反馈类型（此类模式的共性难题）

### markdown-nice (mdnice)
- **基本信息**：开发者：墨滴团队（国内小型创业团队）｜平台：Web（editor.mdnice.com）+ Chrome 插件 + PC 客户端｜价格与授权：编辑器基础功能免费，有会员体系（具体定价未公开检索到，写作「未知」）；主题市场采用社区投稿制，分免费与付费主题，付费后获永久使用许可；免费图床单图限约 4MB；开源版协议 GPL-3.0｜官网 https://mdnice.com ｜GitHub：github.com/mdnice/markdown-nice，约 4,700 star｜维护状态：开源仓库最近推送 2023-10，开源版基本停更；商业产品（在线版/客户端）仍在运营
- **编辑模式**：双栏——左侧 Markdown 源码，右侧实时预览「发到公众号后的效果」；本质是分屏预览 + 目标平台样式仿真
- **核心功能**：一键复制带内联样式的富文本到微信公众号、知乎、稀土掘金等平台；20+ 官方主题（极客黑、橙心、山吹等风格化命名）+ 自定义主题 CSS；数学公式、代码高亮；内置免费图床；主题收藏后自动应用
- **UI 设计**：双栏 + 顶部工具栏 + 右侧主题选择列表；预览区即「手机里文章的样子」，把抽象的排版结果具象化；最值得学习的是「主题即商品」的市场化设计与预览即目标平台效果
- **技术栈**：React + Ant Design（开源仓库可见）；编辑内核与解析器未详（未知）
- **AI 能力**：官方社区介绍产品含 AI 助手辅助写作（形式与细节未知）
- **可借鉴点**：1) 主题市场 + 社区投稿分成的内容生态（对开源产品可转化为主题插件社区）；2) 「预览 = 最终发布效果」的心智模型；3) 风格化主题命名降低选择成本
- **不足**：知乎用户反馈 Mac 客户端与 Chrome 插件存在登录问题，认为小团队精力有限、体验欠佳；开源版停更近三年；免费图床有体积与外链限制（简书等平台无法直接使用）

### doocs/md
- **基本信息**：开发者：Doocs 开源社区｜平台：Web（md.doocs.org）+ 浏览器扩展（Chrome/Edge/Firefox）+ CLI（`npm i -g @doocs/md-cli`，默认端口 8800）+ Docker（arm64/amd64）+ 可部署 Cloudflare Workers｜价格与授权：完全免费，WTFPL 协议｜GitHub：github.com/doocs/md，约 13,100 star｜维护状态：最近推送 2026-07-20，极其活跃（open issue 仅 13 个）
- **编辑模式**：双栏——左 Markdown、右微信图文实时预览；分屏预览型
- **核心功能**：全部基础 Markdown + 数学公式 + Mermaid + 代码高亮，渲染为带内联样式的 HTML（粘到公众号后台不丢样式）；自定义主题与 CSS；本地内容管理与草稿自动保存；多图床：GitHub、阿里 OSS、腾讯 COS、七牛、MinIO、公众号图床、Telegram、Cloudinary、Cloudflare R2 及自定义上传接口，上传自动压缩并显示进度；文章同步助手一键发布到公众号、知乎、微博、B 站、豆瓣、百家号、简书、头条号、CSDN、掘金等平台；字数统计与阅读时长；导入导出 md / html / png
- **UI 设计**：高度简洁的双栏 + 顶部精简工具栏，主题切换即时生效；预览区模拟手机宽度；设计关键词「克制、即用即走」；最值得学习的是把复杂能力（图床、AI、多平台发布）全部收纳进不打扰主界面的侧边栏/弹层
- **技术栈**：Vue 3 + Vite；编辑内核 CodeMirror；纯前端可静态部署
- **AI 能力**：本类别中最完整——集成 DeepSeek、OpenAI、通义千问、腾讯混元、火山方舟等主流模型；内置默认免费 AI 服务（无需自配 API key 即可用）；独立 AI 侧边栏支持智能对话、文本生成、AI 图像生成；AI 可直接引用整篇文档作为上下文；支持自定义快捷指令
- **可借鉴点**：1) AI 侧边栏形态：对话 + 引用全文 + 用户自定义快捷指令，且提供默认免费通道降低门槛——与我们「接入 AI」的目标几乎是现成参考答案；2) 多图床抽象层（统一上传接口 + 可插拔后端）；3) 主题 → 内联样式的渲染管线（导出到任何富文本环境都不丢样式）
- **不足**：定位单一（公众号/中文平台排版），非通用写作工具；导出格式有限（无 PDF/Word/EPUB）；无云同步与协作，内容仅存本地浏览器

### readme.so
- **基本信息**：开发者 Katherine Peterson（现名 Katherine Oelsner，GitHub octokatherine，后入职 GitHub）｜平台：浏览器｜价格与授权：免费，开源 MIT｜官网 https://readme.so ｜GitHub：github.com/octokatherine/readme.so，约 4,600 star｜维护状态：最近推送 2026-03，低频维护
- **编辑模式**：结构化「分节组装」：左侧为可拖拽排序的 section 列表，中间编辑当前 section 的 Markdown，右侧实时渲染预览——三栏混合模式，2021-04 于 Product Hunt 首发走红
- **核心功能**：数十个 README 常用分节模板（安装、用法、API 文档、徽章、FAQ、License、致谢等），点选加入、拖拽排序、逐节编辑；实时预览（GitHub 样式）；下载 README.md 或复制原文；暗色模式；多语言界面；无账号体系，内容存于浏览器本地
- **UI 设计**：三栏布局、Tailwind 简洁风；把「写 README」拆解为「选积木 → 填空 → 排序」；最值得学习的是用结构化模板消解白纸恐惧的产品思路
- **技术栈**：Next.js + TailwindCSS + dnd-kit（拖拽）+ react-markdown（渲染）
- **AI 能力**：无（后来的竞品多以 AI 生成 README 为卖点）
- **可借鉴点**：1) 「分节模板 + 拖拽组装」可迁移为我们产品的文档模板/骨架功能；2) 单一场景做到极致的传播效应（首发即爆款）；3) 每个 section 自带示例文案，即改即用
- **不足**：场景极窄，写完即离开；无云存储，换设备内容不带走；预览仅 GitHub 一种样式；维护频率低、社区 PR 响应慢

### Markdown Live Preview
- **基本信息**：开发者 tanabe（日本个人开发者）｜平台：浏览器单页工具｜价格与授权：免费，开源 MIT｜官网 https://markdownlivepreview.com ｜GitHub：github.com/tanabe/markdown-live-preview，约 900 star｜维护状态：始于 2011 年，最近推送 2026-06，仍在维护
- **编辑模式**：纯双栏分屏：左侧代码编辑器、右侧 GitHub 风格渲染，无其他模式
- **核心功能**：即时渲染、Mermaid 图表、HTML 输出经 DOMPurify 消毒（防 XSS）、内容自动保存到 localStorage、一键复制/清空；无文件管理、无导出、无同步——功能被有意压缩到最小
- **UI 设计**:单页双栏、零装饰、零注册、零弹窗；「打开 3 秒内开始预览」是全部体验；最值得学习的是对「单一用途工具页」的克制
- **技术栈**：Monaco Editor（VS Code 内核）+ marked 解析 + mermaid + github-markdown-css，Vite 构建，纯静态无后端
- **AI 能力**：无
- **可借鉴点**：1) 极简单用途工具也有长青生命力（2011 年至今），可作为我们产品「快速预览」子场景的标杆；2) 默认 GitHub 样式渲染符合开发者心智；3) DOMPurify 消毒等安全细节
- **不足**：单文档、无导出/文件管理，稍复杂需求即需换工具；界面无主题与排版选项

### Bangle.io
- **基本信息**：开发者 Kushan Joshi（kepta，个人开发者）｜平台：仅 Web 的本地优先笔记应用（PWA 可安装，离线可用）｜价格与授权：免费，开源 AGPL-3.0｜官网 https://bangle.io （v2 位于 app.bangle.io）｜GitHub：github.com/bangle-io/bangle-io，约 1,200 star｜维护状态：最近推送 2026-07，活跃（v2 重构进行中）
- **编辑模式**：所见即所得实时渲染（Notion 式富文本体验），底层始终以标准 Markdown 文件存储；支持分屏与多标签
- **核心功能**：直接打开本地文件夹作为工作区（File System Access API），笔记即磁盘上的 .md 文件、无锁定；workspace 多工作区、标签、反向链接（backlinks）、可折叠标题、日期解析、emoji、todo 列表、Markdown 快捷输入；GitHub 仓库同步；完全离线、无跟踪无遥测；作者称万级笔记量依然流畅
- **UI 设计**：Notion 式极简：无工具栏、命令面板驱动、多标签 + 分屏；关键词「本地优先、安静、快」；最值得学习的是「富文本体验 + 纯文本存储」的心智统一
- **技术栈**：非 Electron 的纯 Web 应用；编辑器基于 ProseMirror（自研 bangle.dev / banger-editor 高阶组件库）+ React；File System Access API 直写本地文件、IndexedDB 存元数据；PNPM monorepo + 自研依赖注入的服务化架构
- **AI 能力**：无
- **可借鉴点**：1) 与我们理念最接近的 Web 对应物——「本地文件夹 + 标准 Markdown + WYSIWYG」正是原生 macOS 编辑器的正确姿势；2) ProseMirror 做 Markdown WYSIWYG 的工程实践（banger-editor 可直接研究）；3) 无工具栏、命令面板驱动的界面减法
- **不足**：File System Access API 导致仅 Chrome/Edge 等 Chromium 系浏览器可用（HN 用户实测反馈）；无协作；个人项目、bus factor 风险；star 数与知名度有限

### Milkdown
- **基本信息**：开发者 Mirone（Saul-Mirone）及社区｜平台：浏览器编辑器框架/组件｜价格与授权：免费，开源 MIT｜官网 https://milkdown.dev ｜GitHub：github.com/Milkdown/milkdown，约 11,700 star｜维护状态：最近推送 2026-07，活跃
- **编辑模式**：所见即所得（受 Typora 启发的即时渲染）；作为框架不限定布局
- **核心功能**：「一切皆插件」——语法、主题、UI 均为插件；commonmark/GFM preset、数学公式、表格、斜杠命令、tooltip、图片上传；基于 Y.js 的实时协同编辑支持；headless 无预置样式、完全可定制；官方提供 @milkdown/crepe 开箱即用发行版（内置主题与常用插件）；React / Vue / SolidJS 官方适配，社区有 Angular 适配
- **UI 设计**：框架本身无 UI 立场，crepe 版风格现代简洁（浮动工具条、斜杠菜单）；最值得学习的是插件化架构让主题/交互彻底解耦
- **技术栈**：ProseMirror（文档模型与编辑行为）+ remark/unified（Markdown 解析与序列化）双层架构；60+ 包的 pnpm monorepo，@milkdown/prose 统一 re-export 13 个 ProseMirror 模块保证版本一致
- **AI 能力**：框架本身无（可通过插件接入）
- **可借鉴点**：1) 「微内核（解析/序列化/插件加载器）+ 插件」的架构对我们设计可扩展系统极具参考价值；2) ProseMirror 管富文本、remark 管 Markdown 语义的双层分工，是 WYSIWYG-Markdown 的教科书方案；3) 默认发行版（crepe）+ headless 双形态兼顾易用与可定制
- **不足**：是框架不是成品，集成与配置门槛高（对比类评测普遍提及需要自行搭建大量 UI）；插件 API 学习曲线陡；文档对高级用法覆盖不足

### TOAST UI Editor
- **基本信息**：开发者 NHN Cloud（韩国）｜平台：浏览器组件｜价格与授权：免费，开源 MIT｜官网 https://ui.toast.com/tui-editor ｜GitHub：github.com/nhn/tui.editor，约 18,000 star｜维护状态：npm 最新版 3.2.2 发布于约 2022 年，仓库最后推送 2024-08，643 open issue，事实停更（无官方弃坑声明）
- **编辑模式**：双模式切换：Markdown 模式（分屏 + 语法高亮 + scroll sync）与 WYSIWYG 模式，同一文档两种视图随时互切
- **核心功能**：CommonMark + GFM；官方插件：chart 图表、UML、代码语法高亮、颜色语法、表格合并单元格；独立 Viewer 组件（只读渲染更轻量）；国际化多语言；可关闭的 Google Analytics 使用统计（默认开启）
- **UI 设计**：组件默认样式规整、企业风；模式切换按钮位于编辑器右下角；最值得学习的是双模式切换时内容不丢失的一致性处理
- **技术栈**：v3 起用 ProseMirror 同时驱动 Markdown 与 WYSIWYG 两模式（弃用 CodeMirror 与 squire）；自研 ToastMark 解析器，为实时预览设计、支持增量解析与精确源位置映射
- **AI 能力**：无
- **可借鉴点**：1) ToastMark「为编辑器而生的解析器」思路——增量解析 + 源位置映射，正是双向同步的关键技术；2) ProseMirror 统一双模式数据模型，避免两套内核间转换失真
- **不足**：三年以上无版本更新、依赖升级与 bug 无人处理，社区评估为「未维护」；WYSIWYG 模式表达力仍受 Markdown 语法上限约束；默认开启使用数据统计引发隐私顾虑
- 附注：GitLab 曾在其 Web IDE 的所见即所得方案讨论中评估过 TOAST UI，可见其在组件市场的历史地位

### EasyMDE (SimpleMDE 社区分支)
- **基本信息**：开发者 Ionaru（Jeroen Akkerman），前身 SimpleMDE（Sparksuite，2016 年后停更）｜平台：浏览器组件（textarea 直接替换）｜价格与授权：免费，开源 MIT｜GitHub：github.com/Ionaru/easy-markdown-editor，约 3,000 star｜维护状态：最近推送 2026-05，活跃维护中
- **编辑模式**：单栏源码 + 顶部工具栏为主，可切换并排分屏预览与全屏模式；编辑区内做轻量样式化（加粗直接显示为粗体）
- **核心功能**：工具栏（可自定义按钮）、自动保存、拼写检查、快捷键、状态栏（字数/行数）、图片上传扩展；渲染基于 marked 支持 GFM 基础语法
- **UI 设计**：极简「表单增强」审美，专为嵌入评论框/后台表单设计；最值得学习的是对初学者的低压交互（图标即语法教学）
- **技术栈**：CodeMirror 5 + marked
- **AI 能力**：无
- **可借鉴点**：1) 「接管一个 textarea 即完成集成」的极低门槛 API 设计；2) 社区接盘停更项目并长期维护的治理范本
- **不足**：内核仍是 CodeMirror 5（老一代）；无真正 WYSIWYG；生态里 SimpleMDE 原包仍被误用（原项目 2016 年停更）

### wechat-format
- **基本信息**：开发者 lyricat（Lyric，现 Quaily 创始人）｜平台：浏览器｜价格与授权：免费，开源（仓库未标明协议）｜GitHub：github.com/lyricat/wechat-format，约 4,500 star｜维护状态：已停止维护（最近推送 2025-09 为收尾性质），作者建议迁移到其新产品 Quaily Markdown Tools（quaily.com/tools/markdown-to-wx）
- **编辑模式**：双栏：左 Markdown、右微信特制 HTML 预览
- **核心功能**：Markdown 转微信公众号兼容 HTML、代码高亮、简洁主题样式、一键复制到公众号后台
- **UI 设计**：单页双栏、无账号、开箱即用；风格干净克制
- **技术栈**：纯前端 Web 应用（Vue，解析细节未知）
- **AI 能力**：无（其继任者 Quaily 是 AI 辅助的写作/Newsletter 平台）
- **可借鉴点**：1) 个人开发者的单一用途工具也能拿下 4.5k star，佐证公众号排版是真实长尾刚需；2) 「停更时给出明确迁移出口」的负责任做法
- **不足**：已停更；功能远少于 doocs/md（无图床、无主题市场、无多平台）

### Md2All
- **基本信息**：开发者：个人（具体身份未知）｜平台：浏览器（md.aclickall.com）｜价格与授权：全部功能免费；是否开源未知｜官网 http://md.aclickall.com ｜GitHub：未知｜维护状态：未知（知乎/博客园教程多为 2018-2022 年）
- **编辑模式**：双栏：左侧粘贴/编辑 Markdown，右侧实时预览排版效果
- **核心功能**：一键排版复制到微信公众号、博客园、掘金、知乎、CSDN、WordPress、Hexo 等；自定义 CSS；80+ 种代码高亮主题；LaTeX 数学公式在公众号完美显示；图片自动上传云图床；生成带样式的 HTML 文件；支持表格、任务列表、KaTeX、脚注等扩展，甚至可直接用原生 html/css 排版
- **UI 设计**：功能优先的双栏工具页，视觉朴素
- **技术栈**：纯 Web 工具，细节未知
- **AI 能力**：无
- **可借鉴点**：1) 「一键复制到 N 个平台」的多目标适配是中文写作者的高频刚需；2) 公众号不支持 LaTeX，其公式转换方案（转图片/内联样式）值得研究
- **不足**：未开源、维护状态不明；界面陈旧；无内容管理与同步

## 本类别小结

**共性与趋势**
- 亚类分化明确：通用在线编辑（StackEdit/Dillinger/Markdown Live Preview）、实时协作（HackMD/HedgeDoc）、目标平台排版（mdnice/doocs/md/wechat-format/Md2All）、嵌入式组件（Editor.md/Vditor/TOAST UI/Milkdown/EasyMDE）、结构化生成（readme.so）。GitHub（github.dev / web 编辑器）与 GitLab Web IDE 也内置了够用的 Markdown 编辑与预览，进一步压缩了「通用在线编辑」的生存空间——这或许是 StackEdit、Editor.md、TOAST UI 相继停滞的结构性原因。
- 存活者要么有商业模式（HackMD 按席位订阅 $5-8/席/月），要么有清晰场景与活跃社区（doocs/md 周更级迭代），纯情怀通用工具几乎全部进入维护模式。
- 编辑交互从「双栏分屏」向「即时渲染/WYSIWYG」演进；技术上 ProseMirror 成为 WYSIWYG-Markdown 事实标准（Milkdown、TOAST UI v3、Bangle.io），解析层普遍走 markdown-it / marked / remark，中文社区另有支持源码映射与中文优化的 Lute 引擎（Vditor）。
- 中文公众号排版工具是本类别最独特的需求信号：主题模板市场、带内联样式的一键复制、内置图床、多平台一键分发、公众号不支持 LaTeX 的公式转换——反映中文用户「写作之后还要发布、发布必须好看」的完整链路诉求。
- AI 渗透率整体偏低：doocs/md 是唯一把 AI 侧边栏（对话 + 引用全文 + 快捷指令 + 默认免费模型）做成熟的开源产品；HackMD 则绕开编辑器内 AI，转做「API + MCP 的人机共享上下文层」。两条路线都成立且不互斥。

**对我们产品（原生 macOS、简洁好看、开源免费、接入 AI）的启示**
- 编辑内核：参考 Vditor/Lute 与 TOAST UI/ToastMark 的经验——要做即时渲染或双模式切换，必须有支持「增量解析 + 源码位置映射」的解析层；macOS 原生可用 swift-markdown/cmark-gfm 自建 AST 映射，模式切换时内容零失真是硬指标。
- 本地优先：Bangle.io 证明「富文本体验 + 磁盘上就是标准 .md 文件」的心智最受开发者认可，这在原生 app 上实现成本更低（无浏览器沙箱限制），应作为核心卖点。
- AI 形态：直接借鉴 doocs/md 的侧边栏范式（对话、引用整篇文档、自定义快捷指令、多模型可配 + 低门槛默认通道），同时学 HackMD 提供 MCP/URL scheme 让外部 Agent 读写文档，一进一出两个方向都覆盖。
- 中文市场切入点：内置「复制为公众号/知乎格式」（内联样式导出）与图床上传，是 doocs/md 万星验证过的刚需，也是海外原生编辑器（Typora 之外）普遍缺失的差异化功能。
- 界面减法：Markdown Live Preview 与 Bangle.io 的启示是宁可无工具栏 + 命令面板/斜杠命令，也不要 Editor.md 式图标堆砌；StackEdit 的样式化源码高亮与精确 Scroll Sync 是分屏模式下最值得复刻的两个细节。
- 分享与协作预留：即使首版不做协作，HedgeDoc 六档权限模型与 HackMD「一个下拉框定权限 + 可命名版本时间线」是未来做分享功能时的现成设计语言。
- 社区生态：mdnice 的主题市场与 Milkdown 的插件架构提示：开源产品把「主题/插件」做成社区可投稿的扩展点，是低成本获得生态与传播的路径。
