# 产品机会与功能规划建议

> 撰写说明：本文完全依据 docs/ 目录下 01–09 号分类调研文档（调研截至 2026-07-21）归纳撰写，不引入文档之外的信息。撰写时 10 号分类文档与 11、12 号综合文档尚未生成/不可读，按任务约定跳过。文中括号内的（01）（02）等编号指向对应调研文档，便于回溯核对。
>
> 我们的产品目标：用 Xcode 开发的原生 macOS Markdown 编辑器，简洁好看、开源免费、可接入 AI。

---

## 一、市场格局总结

### 1.1 八大阵营

| 阵营 | 代表产品 | 特征与现状 |
|---|---|---|
| Apple 原生商业精品（01） | iA Writer、Ulysses、Bear、Craft、NotePlan、Drafts、Paper、Highland Pro | 设计水准最高的一档，全部收费且多数走向订阅或高价买断；AI 整体保守（NotePlan 内置、iA Writer 反向做 AI 标注、其余基本空白）；腰部独立应用大面积停更（Byword、Taio、Mou，nvUltra 七年私测未发布） |
| Apple 原生开源（01） | FSNotes（约 7.4k star）、MiaoYan（约 8.4k）、MarkEdit（约 5.2k）、Notenik；已停更：MacDown（约 9.8k）、Mou | 2025–2026 年该子阵营反而最活跃，是与我们定位重合度最高的一群；但各有明显短板：MarkEdit 刻意极简（无内置预览、无文库）、MiaoYan 无 AI 无移动端、FSNotes 稳定性与 UI 设计感被诟病、Notenik 不好看 |
| 跨平台 Electron（02、05） | Typora（标杆，$14.99 买断、闭源）、Mark Text（开源复刻，约 58.9k star）、Obsidian、Zettlr、Joplin、Inkdrop、Notion、Heptabase | 竞争最激烈的赛道；Typora 的「逐段实时渲染」是十年来的体验锚点；好看的产品几乎全是 Electron，社区对其内存与手感的抱怨常年存在 |
| 跨平台非 Electron（02、04、07） | Qt 系（VNote、QOwnNotes、ghostwriter）、Tauri/Rust 系（MarkFlowy、Blinko、VMark）、Flutter+Rust（AppFlowy）、Rust 自研 GPU 渲染（Zed） | 轻快但普遍不好看（Apostrophe 是 Linux 上唯一「原生且美」的例外）；Tauri 是 2024 年后的新平衡点；Zed 证明「性能即产品」，但其 Markdown 预览排版被用户吐槽 |
| 开源知识库 / 自托管（04） | Logseq、SiYuan、Trilium、AFFiNE、Anytype、Notesnook、Standard Notes、Outline、Memos、SilverBullet | 本地优先、双链、可自托管是关键词；19 个项目中仅 QOwnNotes 一个 Qt 原生；协议即战略（做云服务的清一色 AGPL） |
| 闭源商业笔记 / 文档（05） | Notion、Craft、语雀、飞书文档、Roam、Tana、Capacities、Reflect、UpNote | 共同范式是「块编辑器 + Markdown 快捷输入」，Markdown 退化为输入语法糖与导出格式；导出保真度是全类别通病；Obsidian 以「本地 .md + 免费核心 + 插件生态」成为异类赢家 |
| Web 编辑器与组件（06） | HackMD/HedgeDoc、StackEdit、Dillinger、doocs/md、mdnice；组件：CodeMirror 6、ProseMirror、Vditor、Milkdown、TOAST UI | 无清晰场景或变现的通用工具普遍停滞；中文公众号排版是独特刚需；doocs/md 是唯一把 AI 侧栏做成熟的开源 Web 产品 |
| IDE / 终端 / 工具链（07） | VS Code（功能基线）、JetBrains、Zed、Neovim（render-markdown.nvim 等）、Marksman（LSP）、Prettier/mdformat、Pandoc、Glow | 开发者用对待代码的整套基建对待 Markdown；「行内渲染」正在取代「分屏预览」；AI 已下沉为编辑器基础能力 |

另有一个跨阵营的新物种值得单列（08）：「开源 + 本地 Markdown + AI」实验型编辑器——Reor（8.6k star，已于 2026-03 归档停更）、Ritemark（内置 CLI Agent 终端）、VMark（Tauri + 原生 MCP server）、Markra 等，说明这一细分已开始被快速填补。

### 1.2 商业模式分布

| 模式 | 代表与价位 | 社区口碑 |
|---|---|---|
| 小额买断 | Typora $14.99、Znote 29.90€、UpNote $39.99 终身、Caret $29（已停更） | 接受度最高；Typora「长免费期养口碑 → 小额买断」被验证非常成功（02） |
| 高价买断 | iA Writer $49.99（各平台单独购买）、MWeb $34.99、Markdown Monster $99 | 可行但被涨价差评困扰；Markdown Monster 靠「明码标价 + 内容营销」一人公司活了近十年（03） |
| 订阅制 | Ulysses $39.99/年、Bear Pro $29.99/年、NotePlan 约 $100/年、Inkdrop $4.99/月、Roam $15/月、Heptabase $8.99/月起 | 头部产品的主流选择，但「从买断转订阅」长期被社区反复扣分（01、05） |
| 开源应用 + 官方云订阅 | Joplin Cloud 2.99€/月起、SiYuan 148 元/年、Notesnook、AFFiNE；同构的闭源版是 Obsidian（核心免费 + Sync $4/月） | 开源阵营唯一被反复验证的商业闭环（04）；纯 VC 路线（Athens、Dendron）全部死亡 |
| 开源 + 支持版/捐赠 | FSNotes、MiaoYan（GitHub 免费 + App Store 付费支持版）、Zettlr（捐赠）、1Writer（买断 + 小费罐） | 独立开源项目被验证的温和回血路径（01） |
| 纯免费无收入 | MarkEdit、Memos、SilverBullet；反面：Mou（众筹失败即停更）、Simplenote（母公司弃养停止积极开发） | 传播最快，但无收入模型的项目生命周期通常等于作者热情周期（03、05） |
| AI 变现 | 绑订阅档位（Notion AI 锁进 Business $20/人/月）、credits 计量（RemNote $10/月、Tana、Sudowrite）、AI 附加包（AFFiNE 8.9 美元/月、AppFlowy AI MAX 8 美元/月）、BYOK + 低价软件费（Novelcrafter、Znote「按供应商成本用 AI，不抽成」）、本地模型免费（Craft） | 社区口碑明显偏向 BYOK/本地模型/不抽成一侧（02、08） |

### 1.3 三条行业级趋势

1. **交互收敛于「实时渲染」**：Typora 式逐段渲染与 CodeMirror 装饰式半渲染两条路线已基本淘汰纯双栏分屏（02）；Neovim 生态进一步验证了 anti-conceal（全文渲染态、仅光标行还原源码）是手感最佳的混合态（07）。
2. **Markdown 被确立为 AI 时代的数据接口**：飞书官方把「下载为 Markdown」明确定位为「交给 AI 处理」的格式，Notion 上线 Markdown Content API，Reflect 干脆推出开源本地 Markdown 的 Reflect Open（05）；Bear 2.8 内置 MCP server 与 Claude Connector（09）——「本地 md + 可接 AI」正处在风口位置。
3. **AI 集成从「内嵌聊天框」走向「协议化」**：MCP server / Agent Skills（VMark、QOwnNotes、Bear、HackMD、obsidian-skills）让外部 Agent 直接读写文档，编辑器零 AI 成本、零隐私责任（08、09）。

---

## 二、市场空白与机会（逐条核对文档事实）

**机会 1：标杆 Typora 存在三重结构性缺口。**
经核对（02）：Typora $14.99 买断、闭源、无公开源码仓库；截至 1.14 官方无任何内置 AI，社区插件 typora-copilot 需 Copilot 订阅、靠 hack 注入且不支持 Ollama；无官方插件系统、无移动端、无同步、无版本历史。它定义了体验标杆，却把「开源、AI、扩展性」三个位置全部留空。

**机会 2：「开源版 Typora」的信任真空至今没有被填上。**
Mark Text 以约 58.9k star 证明了这一需求的体量，但 2022-03 之后停摆约三年、大量用户流失，2025–2026 年虽恢复维护，信任仍待重建（02、03）；MacDown（约 9.8k star）最后推送停在 2023-07，Mou 早已死亡，其真空位曾先后由 MacDown 与 Typora 填补（01）——现在这个生态位再次空出。

**机会 3：「原生 macOS + 开源 + 好看 + AI」四要素叠加目前无人占据。**
这是 01 号文档的原文结论：MacDown 停更、Mou 已死、MarkEdit 刻意极简无预览、MiaoYan 无 AI 无移动端。04 号文档同样指出开源知识库领域「原生 macOS + 好看」几乎无人占位（颜值最高的 Anytype/AFFiNE 输在 Electron 与格式锁定，唯一原生的 QOwnNotes 输在审美）；09 号文档从技术侧再次确认：现存头部 Markdown 编辑器几乎全是 Electron，「原生、轻、好看、开源」四项同时满足是空白。

**机会 4：AI 能力大多绑定订阅或 credits，隐私顾虑成为第一分歧线。**
经核对：Notion AI 完整能力仅含在 Business $20/人/月 及以上（05、08）；RemNote AI 附加包 $10/月、AFFiNE AI 附加 8.9 美元/月、AppFlowy AI MAX 8 美元/月、Tana/Sudowrite 走 credits、JetBrains AI Assistant 与 Zed AI 走订阅（04、07、08）。与此同时，08 号文档明确：隐私（内容是否离开设备、是否用于训练）已成该品类最主要的争论点；02 号文档总结社区共同底线是「BYOK + 本地模型选项 + 不抽成」，对「AI 订阅抽成」抵触强烈。已被验证的正面样本（Znote 买断解锁 BYOK 零抽成、Craft 本地模型免费、Novelcrafter BYOK + 低价软件费）都不在「原生 + 开源 + 精品设计」阵营里——01 号文档的判断是：**尚无一款「简洁原生编辑器 + 一流 AI 体验」的产品**。

**机会 5：精品原生阵营集体拒绝内置云 AI，恰好留出差异化空间。**
iA Writer 刻意不做生成式 AI（反向做 Authorship 标注）、Ulysses/Bear 只接系统级 Apple Intelligence Writing Tools、Obsidian 官方零 AI 靠插件（08）。这既说明该人群对隐私和心流的在意（我们必须尊重），也说明「把 AI 做得体面」在原生精品里还没有正面样本——NotePlan 是唯一深度内置者，但它是约 $100/年 的订阅产品（01）。

**机会 6：中文市场存在两个被万星项目验证过的专属刚需。**
其一，中文排版细节（自动加空格、中西文混排、中文字体调校）是 MiaoYan、Vditor/Lute、SiYuan 的共同差异化武器（01、04、06）；其二，公众号/知乎排版与多平台分发是 doocs/md（约 13.1k star、极活跃）、mdnice 验证过的真实长尾刚需，而海外原生编辑器普遍缺失（06）。

**机会 7：开发者工具的「美学空档」。**
Zed 预览排版被用户吐槽标题层级不可见、VS Code 预览简陋、终端工具先天受限（07）——「原生 macOS + 认真做排版字体 + 主题数据化可分享」在开发者人群里是稀缺品。同时 VS Code 定义的功能基线（粘贴 URL 成链接、粘贴图片自动落盘、链接校验与重命名同步）给了我们一份明确的验收清单。

**机会 8（伴随警示）：窗口期真实存在但不会太久。**
2026-04 出现的 swift-markdown-engine 首次把「AppKit + TextKit 2 + 混合实时渲染」以 Apache-2.0 开源，大幅降低了原生路线门槛（09）；VMark 证明「一人 + AI 编程」可以快速做出此类产品，Ritemark/Markra 等同类定位项目正在扎堆出现（08）。这个细分正在被快速填补，应尽快占位。

---

## 三、定位建议与差异化打法

### 3.1 一句话定位

**「Typora 级的编辑体验 + iA Writer 级的排版审美 + Obsidian 级的数据主权 + Znote 级的 AI 姿势，做成一个开源免费的原生 macOS 应用。」**

四个支柱，每一个都有调研依据：

1. **原生**：AppKit/SwiftUI 全原生编辑区，把启动速度、内存占用、打字延迟、系统集成（Writing Tools、拼写、QuickLook、快捷指令）做成显性卖点——这是 Electron 阵营结构性做不到的（02、09）；Craft 证明原生路线能拿 Mac 年度应用级的口碑（05）。
2. **简洁好看**：单栏排版对标 iA Writer，克制程度对标 Apostrophe（零面板、悬浮工具条），动效手感对标 Paper，「用字体与留白建立品牌」而非堆功能（01、02）。颜值本身就是获客武器——Moeditor、Caret、Springseed 都靠颜值出圈（03）。
3. **开源免费 + 数据主权**：MIT/Apache 开源；本地 .md 文件夹为唯一真相源、永不引入私有格式、导出零门槛——这是从 Logseq/语雀/Boostnote 流失用户的最强接收器（03、04、05）。
4. **AI 可选且体面**：分层接入（系统级免费 → BYOK 零抽成 → MCP 协议化），默认本地优先、可整体关闭、生成可标注（Authorship）——组合了 08 号文档里社区口碑最好的全部姿势，且目前没有任何一个产品把它们组合在一起。

### 3.2 对标与打法矩阵

| 对手 | 它的强项 | 我们的打点 |
|---|---|---|
| Typora | 逐段实时渲染标杆、$14.99 口碑、主题生态 | 开源免费、原生性能与系统集成、官方 AI 与扩展体系、版本历史（它没有） |
| MarkEdit | 同为原生开源、系统感极佳、GFM 严格 | 它刻意不做预览/文库/开箱 AI；我们提供「开箱即完整」的写作体验，吸引非极客用户 |
| MiaoYan | 原生开源高颜值、中文排版、8k+ star 验证需求 | 补上它明确没有的 AI、更完整的编辑交互（混合渲染）；沿用其中文排版优势 |
| Obsidian | 生态之王、Live Preview、本地 md | 不做全功能 PKM，做「轻、快、美」的编辑器；原生手感与零配置开箱；可直接打开 Obsidian vault 降低迁移成本（07、08） |
| Bear / iA Writer / Ulysses | 设计天花板、成熟商业产品 | 免费开源 + 纯文件无私有库（Bear/Ulysses 的库格式长期被扣分）+ 官方 AI 分层（它们保守留白） |
| MarkFlowy / VMark / Ritemark | 同为「开源 + AI」新物种、迭代快 | 它们是 Electron/Tauri/Web 壳；原生 AppKit 的手感、性能与系统集成是我们的护城河（08、09） |

### 3.3 获客与社区路径（全部来自被验证的先例）

- **命名生态位**：直接抢占「MacDown/Mark Text 之后的 Mac 开源 Markdown 编辑器默认选择」这一自然流量位（01、02）。
- **主题即一个样式文件 + 官方主题画廊**：Typora 用纯 CSS 主题把定制门槛降到前端开发者人手可为，是冷启动社区生态最便宜的引擎（02）；Glow 的「主题即可分发的 JSON」同理（07）。
- **中文市场组合拳**：中文排版细节 + 复制为公众号/知乎格式（doocs/md 万星验证的刚需），作为国产项目的天然差异化（01、06）。
- **发布姿势**：GitHub Releases + Homebrew 免费、Mac App Store 付费支持版回血（FSNotes/MiaoYan 双渠道模式）；首发即完成签名公证（MarkFlowy 未签名需 `xattr` 放行是反面教材）（01、02）。
- **叙事**：把「file over app + 完全开源」做成双重信任优势对外讲（05）；隐私承诺（默认本地、不训练、可关闭 AI）写进首屏（08）。

---

## 四、功能分层建议

### 4.0 分层原则

- **范围克制**：先把编辑器一件事做到 1.0（Haroopad 同时铺三条产品线而死，03）；移动端、协作、云服务全部后置（05 号文档显示几乎所有产品的差评都集中在「第二平台」）。
- **路线**：采用 09 号文档的渐进建议——MVP 用可控成本的形态先发布收集用户，V1 落地行内混合渲染这一「当代体验基准线」；避免 nvUltra 式完美主义拖延（01）。
- 每条功能均注明理由与参考产品，全部选自调研到的功能全集。

### 4.1 MVP：立住「原生、简洁、好看、可靠」

| # | 功能 | 理由与说明 | 参考产品 |
|---|---|---|---|
| 1 | 源码编辑 + 语法样式化/标记淡化（标题变大、粗体变粗，标记符保留但视觉弱化） | 01 号建议的起步形态：体验好、原生实现成本可控，回避完整 WYSIWYG 的工程深坑（MiaoYan 明确放弃、Bear 为此自研 C++ 内核）；「语法可见的就地渲染」对程序员用户本身就有吸引力 | iA Writer、Apostrophe、Caret、Bear |
| 2 | ⌘\ 一键分屏实时预览，60fps 双向滚动同步 | 分屏作为 MVP 过渡与「逃生舱」；滚动同步是分屏体验底线（MarkdownPad 当年的招牌、StackEdit 的口碑细节） | MiaoYan、MacDown、StackEdit |
| 3 | GFM 全家桶（表格、任务列表、删除线、脚注）+ LaTeX 数学 + Mermaid + 代码块高亮 | 「技术写作全家桶」2015 年 CuteMarkEd 就已配齐，是标配预期，首发就该带上；解析对齐 cmark-gfm 事实标准 | Typora、MWeb、Zettlr、CuteMarkEd |
| 4 | 本地 .md 文件夹即文库（用户自选文件夹，无账号无私有格式），iCloud Drive/网盘天然同步 | 数据主权是口碑生命线（Notable 的正面遗产、Boostnote CSON 与 Joplin 数据库的反面教训）；不自造同步（Laverna 死于同步） | MiaoYan、MarkEdit、Notable、Obsidian |
| 5 | omnibar：搜索与新建合一 + 全文搜索 | 笔记型编辑器最高效的入口设计，被 FSNotes/MiaoYan 继承验证 | nvUltra、FSNotes |
| 6 | 命令面板（⇧⌘P） | 低 UI 成本的功能聚合入口，維持界面极简 | iA Writer 8、Obsidian、VNote Universal Entry |
| 7 | 图片粘贴/拖拽自动落盘（目录规则可配）+ 选中文字粘贴 URL 自动成链接 | VS Code 定义的开发者基线功能，缺失会被立刻感知；原生 NSPasteboard 可做得更顺 | VS Code、MWeb、Typora |
| 8 | Markdown 语义快捷键（⌘B/⌘I/升降标题/勾选任务）+ 列表续行与编号自动修复 | 「编辑器懂 Markdown」的微交互，成本低感知强，是开发者隐性预期 | Markdown All in One、Sublime MarkdownEditing |
| 9 | 导出 HTML / PDF（走系统 WebKit/PDFKit） | 基础出口；MPE 依赖无头 Chrome 导出脆弱缓慢是反面教材，原生管线是体验优势点 | Marked 2、Markdown Preview Enhanced（反面） |
| 10 | 专注模式（行/句/段粒度可选）+ 打字机滚动 | 写作心流功能，原生实现成本低、差异化感知强 | ghostwriter、iA Writer、Byword |
| 11 | 深浅色主题各一套精调 + 完全贴合 macOS 规范（原生工具栏、系统控件、自动深浅色） | 「系统感」本身是差异化（Typedown 靠贴合 Fluent 出圈的 macOS 对应物）；先做两套精品胜过堆主题 | MarkEdit、Apostrophe、Typedown |
| 12 | 接入 Apple Intelligence Writing Tools（选中文本校对/改写/总结，设备端优先，可整体关闭） | 08 号文档的「第 0 层 AI」：一行代码级成本、免费、离线，原生应用独享的捷径 | Ulysses、Bear、Drafts、MarkEdit |
| 13 | 版本保护底线：自动保存 + 基于文件系统的版本历史 | 数据安全是信任来源（Joplin 的笔记历史、Obsidian File Recovery 被视为信任功能） | iA Writer、FSNotes |
| 14 | 工程底线：签名公证、Homebrew + GitHub Releases 分发、崩溃即修的小步发版 | MarkFlowy 未签名劝退普通用户；季度小发版是「项目活着」的信号（03） | MarkEdit、FSNotes |

### 4.2 V1：立住差异化（混合渲染 + AI + 主题生态）

| # | 功能 | 理由与说明 | 参考产品 |
|---|---|---|---|
| 1 | 行内混合渲染（anti-conceal：全文渲染态，仅光标行/选区还原源码），与源码模式、阅读模式三态一键切换 | 当代体验基准线（02）；anti-conceal 被 Neovim 生态验证为手感最优、比 Typora 式整块还原更稳定（07）；原生实现可基于/借鉴 swift-markdown-engine（09） | Typora、Obsidian Live Preview、render-markdown.nvim、swift-markdown-engine |
| 2 | AI 分层接入 + 核心交互四件套（详见第五章） | 选中改写浮层（diff 预览）、对话侧栏、@ 引用上下文、本地模型；BYOK 零抽成 | Znote、doocs/md、Craft、Cursor |
| 3 | AI 文本标注（实现 iA Writer 开源的 Markdown Annotations/Authorship 规范） | 现成开放规范、目前没有第二家开源编辑器支持——「能标出 AI 写了哪些字的开源编辑器」是清晰传播点，且与我们的生成功能构成「生成 + 溯源」闭环 | iA Writer Authorship |
| 4 | 主题系统：「主题即一个样式文件」+ 官方主题画廊 + 社区投稿 | Typora 社区生态的核心引擎，冷启动最便宜的传播杠杆；NotePlan 的 JSON 主题证明原生应用同样可行 | Typora、NotePlan、Glow |
| 5 | 中文排版细节：中西文混排自动空格、标点与字距调校、中文友好默认字体 | 国产项目天然差异化，MiaoYan 以此收获大量 Typora 迁移用户；Lute 引擎证明可做成解析层能力 | MiaoYan、Vditor/Lute、SiYuan |
| 6 | `[[wiki 链接]]` + 路径/标题锚点补全 + 反向链接面板 | 双链是笔记场景最小闭环（Foam 验证）；纯 .md 文件实现、落盘可转标准链接保证仓库可读 | Bear、FSNotes、Foam、Marksman |
| 7 | 知识库语义：死链诊断、文件/标题重命名自动更新全库引用、跨文件标题搜索 | 「把文件夹当知识库对待」是编辑器与「一堆 .md」的关键差距；语义学 Marksman（链接=符号、死链=报错、重命名=重构） | VS Code、Marksman |
| 8 | Pandoc 集成：自动探测、图形化封装，解锁 DOCX/EPUB/LaTeX 等导出矩阵 | 「不要自研导出」是 07 号文档的明确结论；学 JetBrains 的自动探测 + 菜单化 | JetBrains、Zettlr、Texts |
| 9 | 表格图形化辅助（行列增删/对齐控件）+ 保存即格式化（表格自动对齐；proseWrap 默认 preserve 以适配中文） | 表格是纯文本编辑最痛处；Prettier 已驯化出「保存即格式化」预期；任何自动改写都做 AST 等价校验（mdformat 的安全思路） | Typora、JetBrains、Prettier、mdformat |
| 10 | Git 版本历史（可选内置） | 开源编辑器做版本历史的优雅方案，零服务器成本；进一步可评估 VNote 4 的「任意 Git 远端即同步」 | FSNotes、VNote 4 |
| 11 | 复制为公众号/知乎格式（内联样式富文本）+ 可配置图床上传 | 中文写作者「写完还要发布、发布必须好看」的完整链路刚需，doocs/md 万星验证；海外原生编辑器普遍缺失 | doocs/md、mdnice、Vditor、MWeb/PicGo 生态 |
| 12 | QuickLook 预览插件、Finder/系统服务集成 | 低成本高感知的系统集成，强化「原生」卖点 | iWriter Pro |
| 13 | 写作者关怀件：字数/阅读时长统计、会话统计、写作目标；The Shelf 式暂存架（可选） | 低成本差异化；The Shelf 解决「舍不得删又暂时不要」的真实痛点 | Ulysses、ghostwriter、Highland 2 |

### 4.3 V2：生态与纵深

| # | 功能 | 理由与说明 | 参考产品 |
|---|---|---|---|
| 1 | 内置 MCP server + 为自家格式撰写 Agent Skills | AI 协议化趋势的一等公民入场券：让用户已付费的 Claude/ChatGPT/CLI Agent 直接读写文库，零推理成本、零隐私责任；目前尚无一款「好看的」编辑器做到 | VMark、QOwnNotes、Bear 2.8、HackMD、obsidian-skills |
| 2 | 本地 embedding「相关笔记被动推荐」+ 全库检索问答（回答带引用、点击跳回原文） | 被动 AI 的标杆形态（零配置、无 API key）；「检索问答先于炫技生成」是 04 号文档的明确建议；本地向量库可用 LanceDB 一类嵌入式方案 | Smart Connections、Outline AI Answers、NotebookLM、Reor、Elephas |
| 3 | JavaScriptCore 脚本/插件系统 + 应用内脚本市场 | 「开放好用的插件 API 比自己抢做功能更重要」（Joplin 的教训）；脚本市场是原生应用做扩展生态的可行样板；AI 动作天然是一类脚本 | Drafts、Taio、QOwnNotes、Joplin |
| 4 | 发布管线：WordPress/Ghost/Medium/Micro.blog 一键发布，静态博客生成（可选） | 「编辑器即发布工具」是留存利器；博客人群与 Markdown 高度重叠 | Ulysses、MWeb、Byword Premium、Markdown Monster |
| 5 | 演示模式（Markdown 一键变幻灯片） | 轻量惊喜功能，妙言 PPT 与 HackMD Slide 模式双重验证；「一份 Markdown 多种呈现」 | MiaoYan（妙言 PPT）、HackMD/HedgeDoc、MPE（reveal.js） |
| 6 | 兼容 Obsidian vault（wiki 链接、daily notes 目录约定）与 front matter 表单化编辑 | 「兼容存量生态」让迁移成本归零（07 的明确建议）；front matter 表单化服务博客人群 | obsidian.nvim、Foam、Reor、Front Matter CMS |
| 7 | 笔记加密（按文件夹/文件 AES） | 隐私叙事的加分项，开源阵营成熟先例 | FSNotes、QOwnNotes |
| 8 | iOS 伴侣版评估（先做只读/快速捕捉） | 移动端是几乎所有竞品的差评重灾区（05），必须在桌面体验彻底站稳后再投入；Bear 为跨端自研内核的成本是前车之鉴 | Bear、1Writer |
| 9 | 分享/协作预留（不做实时协同，先做「导出分享页」与权限模型设计） | HackMD「一个下拉框定权限」与 HedgeDoc 六档权限是未来的现成设计语言；实时协同成本极高，远期再议 | HackMD、HedgeDoc |

### 4.4 明确不做清单（同样重要）

- **不做私有存储格式、不把导出设为付费墙**（Boostnote/语雀/Tana 的反面教训，03、05）。
- **不自建同步服务器**：同步交给 iCloud Drive/网盘/Git（Laverna 死于同步，03）。
- **不做块编辑器/数据库/白板**：那是 Notion/AFFiNE 的战场，功能广而不深是它们的通病（04、05）；我们守住「编辑器」的定义力（Memos 单一场景 60k+ star 的启示）。
- **不做全家桶式 AI 军备竞赛**：Trilium 内置多供应商 AI 后因维护不可持续而移除，是直接警告（04）。
- **首版不做实时协同、不做 Windows/Linux**：范围克制（03）。

---

## 五、AI 集成构思

### 5.1 总体架构：三层递进，自己不承担推理成本（08 号文档的分层建议）

- **第 0 层 · 系统级（免费兜底）**：Apple Intelligence Writing Tools（校对/改写/总结，设备端优先）+ Apple Foundation Models 端上模型。参考 Ulysses/Bear/Craft/Drafts/MarkEdit 的既有路线，原生应用独享、几乎零成本。
- **第 1 层 · BYOK 多供应商（核心层）**：任意 OpenAI 兼容端点 + Anthropic + 本地 Ollama，自带 Key、用量零抽成。参考 Znote（「按供应商成本用 AI，不订阅不抽成」）、Markdown Monster、Novelcrafter——这是社区口碑最好的姿势。
- **第 2 层 · 协议层（生态层）**：内置 MCP server + 官方 Agent Skills 文档，让 Claude Code 等外部 Agent 成为「免费的高级 AI 功能」。参考 VMark、Bear 2.8、QOwnNotes、HackMD、obsidian-skills。
- （远期可选第 3 层：官方低门槛默认通道，参考 doocs/md 的默认免费 AI 服务——但有真实成本，须与商业化一并考虑，MVP/V1 不做。）

### 5.2 具体交互形式清单

| # | 交互形式 | 借鉴自 | 我们如何做出差异 |
|---|---|---|---|
| 1 | 选中改写浮层（改写/翻译/总结/自定义指令），结果以 diff 预览，逐块接受/拒绝后应用 | Notion AI 浮层、Apple Writing Tools、Cursor Cmd+K、Smart Composer、Zed 逐 hunk 审阅 | 原生浮层贴合系统观感；改写落在语法树上而非纯文本替换（swift-markdown 的 SourceRange/AST 改写），保证不破坏 Markdown 结构；每次 AI 改动可自动写入 Authorship 标注 |
| 2 | 续写 / 幽灵文本补全 | Cursor Tab、Lex 的 `+++` 触发符、Sudowrite Write | 吸取 Cursor 教训：散文场景**默认关闭**；提供 Zed 式 Subtle Mode（按键才显示）与 `+++` 纯文本触发符——后者与 Markdown 气质天然契合 |
| 3 | 文档感知对话侧栏 + `@` 引用文件/文件夹作为上下文 + 自定义快捷指令 | doocs/md AI 侧栏（对话+引用全文+快捷指令）、Obsidian Copilot、Craft Assistant、Znote/Cursor 的 @ 引用、Type Chat | 侧栏完全可隐藏、不侵入编辑主体（Obsidian 插件范式）；上传内容可视化（发送前展示将要上传的片段，学 Elephas 的隐私工程思路）；对话可一键导出为 Markdown |
| 4 | 本地模型运行 | Reor（Ollama + 本地向量库全离线）、Craft（本地模型免费不占配额）、MarkFlowy/Znote（Ollama 选项）、Smart Connections（本地 embedding） | 「本地优先」做成默认叙事而非高级选项；结合 Apple 端上模型（第 0 层）实现「不插网线也有完整 AI」；本地 embedding 驱动的被动推荐零 API 成本 |
| 5 | AI 文本标注 / 作者身份追踪 | iA Writer Authorship（Markdown Annotations 开放规范：AI 文本灰显/高亮、粘贴自动识别、diff 归属、导出自动剥离） | 做该开放规范的**第一个开源实现**；且与我们的生成功能闭环——凡经本产品 AI 生成/改写的文字自动标注，透明 AI 成为品牌立场 |
| 6 | 批改式检查（Checks）+ 本地风格检查 | Lex Checks（一键运行语法/简洁度/陈词滥调检查，清单式呈现，支持自定义检查项）、iA Writer Style Check（本地非 LLM）、Ulysses 校对 | 「批改清单」而非实时下划线，尊重心流；本地规则检查免费打底，LLM 检查走 BYOK；检查项本身是可分享的纯文本配置 |
| 7 | 整文档级 AI 编辑 + 权限双模式 | Type Document Reviews（全篇统一口径修改）、Craft Execute/Explore（直接执行 vs 提案确认） | 整文档修改一律走「提案 + diff + 检查点回滚」（Zed 检查点思路），不给 AI 静默改文的权限 |
| 8 | 模板化生成 / 项目级规则文件 | Obsidian Text Generator（提示词模板 + 社区市场）、Cursor `.cursor/rules`、obsidian-skills | 指令与规则就是文库里的 .md 文件（写作规范、文风约束随项目走），可版本控制、可社区分享——与「一切皆本地纯文本」自洽 |
| 9 | 全库 RAG 问答（带引用跳转）与相关笔记被动推荐 | Outline AI Answers（检索问答先行）、NotebookLM（回答必须带出处、点击跳回原文）、Mem Chat、Copilot Vault QA、Smart Connections | V2 落地；嵌入式本地向量库（Reor 用 LanceDB 的先例）；引用跳转做成一等交互；推荐是被动侧栏、零打扰 |
| 10 | MCP server / 外部 Agent 接入 | VMark（编辑器自带 MCP server）、Ritemark（内嵌 CLI Agent 终端 + 统一审批策略）、Bear 2.8、obsidian-skills | 我们不内嵌终端（保持简洁），走「MCP + Agent Skills」纯协议路线；文档操作以语法树 API 暴露（改写某节、插入表格、生成 front matter），比裸文本读写更安全精确 |
| 11 | 语音/多模态、定时 Agent 任务、自动组织 | Mem Voice Mode、NotebookLM 多模态产出、Ritemark 定时任务、Mem 自动标签 | 全部列为远期观察项，不进 V1/V2 承诺——防止 AI 功能面失控（Trilium 教训） |

### 5.3 隐私工程与红线（做成产品承诺）

来自 08 号文档的共识清单：默认本地、最小上传、发送前可视化将上传内容、显式「不训练」承诺写进首屏、AI 可在设置中整体关闭（Ulysses 做法）、软件钱与模型钱分开算（Novelcrafter 的透明定价获得社区好感）。此外注意发行渠道：App Store 沙盒会限制部分系统级能力（Elephas 的警示），官网直装 + MAS 双渠道需早做决策。

---

## 六、技术选型倾向（基于 09 号技术栈文档）

### 6.1 总路线：方案 A 为终态、方案 C 为首发的渐进路线（09 号文档的推荐原文）

- **M1（对应 MVP）**：NSTextView（TextKit 2，必要时薄封装）+ swift-markdown 解析 + WKWebView 分屏预览/导出，SwiftUI 壳经 NSViewRepresentable 桥接；快速出货、收集用户。
- **M2（对应 V1）**：落地行内混合渲染——认真评估以 Apache-2.0 的 swift-markdown-engine 为起点或上游（fork 锁版本并向上游回馈），它是目前生态里唯一开源的「原生 TextKit 2 混合渲染 Markdown 引擎」，与我们目标架构完全一致；Bear/Panda（55ms 打开 9.4 万词《白鲸记》）证明了原生混合渲染的性能上限。

### 6.2 组件清单

| 层 | 选型 | 理由 |
|---|---|---|
| 编辑区 | AppKit NSTextView + TextKit 2 | 原生混合渲染唯一的官方地基；Writing Tools 也要求 TextKit 2 |
| 解析（语义/导出） | swift-markdown + swift-cmark（gfm） | Apple 官方维护、SPM 一行引入、SourceRange 精确、与 cmark-gfm 方言对齐——本类别最佳选择 |
| 解析（实时高亮） | tree-sitter + SwiftTreeSitter + Neon | 「增量解析管高亮、全量 AST 管语义」的双解析器架构是行业普遍做法；Neon 解决「解析结果→TextKit 属性」最脏的管线 |
| 代码块高亮 | Highlightr/HighlighterSwift 起步，tree-sitter 进阶 | 快速出效果的务实选择（swift-markdown-engine 同款路径） |
| 行内数学 | SwiftMath（原生 CoreText 排版） | 编辑区行内公式的原生方案，覆盖常用子集 |
| 预览/导出/图表 | WKWebView 子系统（markdown-it 或直出 HTML + KaTeX/MathJax、Mermaid、Shiki） | Mermaid/KaTeX 只能跑在 JS 环境；限定用途「预览、导出、图表」，编辑区保持原生；PDF 走 createPDF/printOperation，绝不引入无头 Chrome |
| 复杂格式导出 | 外接 Pandoc（自动探测 + 图形化封装） | 行业共识「不要自研导出」；DOCX/EPUB/LaTeX 一次接入全部解锁 |
| SwiftUI TextEditor（macOS 26 新 API） | 不作为主编辑区 | 只支持轻样式、做不到语法隐藏与行内 widget，且仅 macOS 26+；可作实验性轻量场景 |

### 6.3 明确不选与许可雷区

- **不选 Electron**：它是我们差异化的对立面（现存头部几乎全是 Electron，抱怨常年存在）；**不建议 Tauri**：编辑体验仍是 Web 的，却失去 Electron 的生态一致性——两头不占（09）。
- **许可雷区**：STTextView 已改 GPLv3 + 商业双授权——若我们以 MIT/Apache 发布需绕开或购买授权（可只研读其源码作为 TextKit 2 避坑百科）；Down、Ink、SwiftDown 均已停更/归档，不要引入。
- **TextKit 2 防坑清单进工程规范**：严禁触碰 `.layoutManager` 防止静默降级回 TextKit 1；视口高度估算导致的滚动跳动要有对策；打印/PDF 走 WKWebView 而非 TextKit；参考 STTextView/swift-markdown-engine 的已趟坑实现。
- **AI 层架构原则**：AI 能力设计为「语法树上的操作」而非文本替换（swift-markdown 的 SourceRange + Visitor/Rewriter 是隐藏红利），独立于编辑内核、云端 API 与本地模型可并行替换；同一套语法树 API 未来对齐 MCP 暴露。
- **开源协议建议（结合 04 号文档）**：纯客户端阶段用 MIT 或 Apache-2.0 最利传播，且与 swift-markdown-engine（Apache-2.0）、swift-markdown（Apache-2.0）兼容；若未来上线官方同步/AI 云服务，届时再评估 AGPL 边界（Joplin/SiYuan 路径）。避免 BSL 与自造协议的长期舆论税（Outline/Anytype 的教训）。

---

## 七、风险与注意事项

### 7.1 可持续性是第一功能（停更项目的集中教训，03 号文档为主）

1. **star 数与存活无关**：Mark Text 约 58k star、Laverna 9.2k、Moeditor 4.1k、Reor 8.6k 全都停摆过；反而是维护面极小的 ReText 靠一人业余时间活了 15 年。结论：**刻意控制功能表面积**，把范围收小到长期养得起。
2. **单点维护者是最大单点故障**：Mark Text（作者全职工作后无人有合并权限）、Moeditor（学生毕业）、Springseed（少年开发者离场）、obsidian.nvim（原作者停更靠社区 fork 续命）。对策：第一天建立多维护者治理——合并权限下放、CONTRIBUTING、明确的终身维护者/BDFL，并保持哪怕每季度一次的小发版节奏向社区传递「活着」的信号。
3. **免费无收入模式的生命周期 = 作者热情周期**：Mou 众筹失败即停更、Simplenote 被母公司弃养、Reor 两年归档。对策：发布前就公开可持续机制（GitHub Sponsors/捐赠 + App Store 付费支持版起步，未来保留同步/云服务选项），并像 Markdown Monster 那样持续内容营销维持关注度。
4. **VC 模式在本品类不成立**：Athens、Dendron 融资后仍死亡（04）；「低成本小团队 + 社区」才是现实解，不要按风投叙事规划产品。

### 7.2 治理与承诺红线

5. **开源承诺不可回撤**：Notable 开源转闭源导致社区反噬、贡献归零、商业化也没做成，两头落空；协议、治理方式与资金来源应在发布前定好并公开（02、03）。
6. **数据格式承诺不可动摇**：Logseq「文件优先」转「数据库优先」被骂 bait-and-switch 并引发用户流失（04）。我们的「本地 .md 文件夹为唯一真相源、永不引入私有格式」要写进宣言，且永不违背。
7. **不搞破坏性变更、路线图高频透明沟通**：Memos 版本间破坏性变更、Logseq 沟通不足让「项目死了吗」成为论坛热帖（04）；HedgeDoc 2.0 重写五年仍 alpha 期间新功能冻结的代价同样在列。

### 7.3 技术与安全风险

8. **推倒重写是独立项目头号杀手**：WriteMonkey WM2→WM3 重写耗尽精力、Caret 4.0 死在 RC 阶段、HedgeDoc 2.0 五年未稳定（03、06）。对策：渐进式架构（MVP→混合渲染是「增强」不是「重写」），核心难点（TextKit 2 混合渲染）尽早原型验证。
9. **渲染/依赖内核必须选官方长期支持组件**：Awesomium 拖死 MarkdownPad、Qt WebKit 拖死 CuteMarkEd、NW.js 拖死 Haroopad（03）。我们用系统 WKWebView + Apple 官方 swift-markdown，正是为了规避这类「依赖先于产品死掉」的技术债；同时注意 swift-markdown-engine 目前 pre-1.0、单一团队主导，需 fork 锁版本、具备接管能力。
10. **安全架构第一天做对**：Abricotine 因渲染进程开启 nodeIntegration 产生无法修复的安全漏洞，最终成为压垮项目的稻草（03）。WKWebView 预览必须严格内容隔离与沙箱，插件/脚本系统（V2）设计时就要有权限边界（peek.nvim 用 Deno 沙箱的思路、Obsidian 插件供应链风险的教训）。
11. **AI 是潜在的维护黑洞**：Trilium 内置多供应商 AI 后因「长期维护不可持续」整体移除（04）。对策即第五章的分层架构——薄封装 BYOK + 协议化（MCP），不在核心内置重型 AI 管线。

### 7.4 竞争与节奏

12. **窗口期紧迫**：swift-markdown-engine 把原生混合渲染门槛打下来了，VMark/Ritemark/Markra 正在扎堆填补「开源 + 本地 md + AI」空位（08、09）。既不能 nvUltra 式七年磨一剑（01），也不能 Yu Writer 式仓促挑战在位者——它的教训是：没有结构性差异（开源、原生、AI），「比 Typora 快一点」不构成活下去的理由（03）。我们的结构性差异必须在 V1 完整立起来。
13. **避免长期 Beta 与跳票**：Haroopad 版本号永远 0.x 让用户不敢托付、Notable 承诺功能常年「Future」伤害口碑（02、03）。少承诺、快兑现，路线图只写有把握的。

### 7.5 落地细节清单（全部来自真实翻车案例）

- 域名、证书设自动续费（Mark Text 官网域名忘续费丢失，03）。
- CI/CD 与打包自动化在项目早期建好（CuteMarkEd 被跨平台打包负担压垮，03）。
- 首发即签名公证（MarkFlowy 的 `xattr` 手动放行是普通用户硬门槛，02）。
- App Store 沙盒对系统级能力的限制要提前验证，官网直装与 MAS 的功能差异要想清楚（Elephas，08）。
- 停更/转向时给用户明确迁移出口是负责任开源项目的底线（wechat-format 的正面示范，06）——愿景是不用走到那一步，但这条应写进项目治理文档。

---

## 附：核心结论一页纸

1. **定位成立**：「原生 macOS + 开源免费 + 简洁好看 + AI 分层」四要素叠加经 01/02/04/09 四份文档交叉验证为市场空白；Typora（闭源收费无 AI）、Mark Text（停摆失信）、MacDown/Mou（死亡）、MarkEdit/MiaoYan（各缺一角）共同让出了这个位置。
2. **体验路线**：MVP 以「源码样式化 + 分屏预览」快速占位，V1 以 anti-conceal 行内混合渲染 + AI 四件套 + 主题画廊立住差异化，V2 以 MCP/RAG/插件/发布管线建生态。
3. **技术路线**：AppKit/TextKit 2 全原生编辑区 + swift-markdown 双解析器架构 + WKWebView 仅作预览导出；评估 fork swift-markdown-engine；不用 Electron/Tauri。
4. **AI 路线**：系统级免费兜底 → BYOK 零抽成 → MCP 协议化；默认本地、可整体关闭、生成必可标注（Authorship 首个开源实现）；自己不承担推理成本。
5. **生存路线**：MIT/Apache 开源 + GitHub 免费 + MAS 支持版；多维护者治理 + 季度发版；数据格式与开源承诺永不回撤；范围克制，先把编辑器一件事做到 1.0。
