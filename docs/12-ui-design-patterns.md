# UI 设计模式总结

> 综合 01–09 号分类调研文档，对全部被调研产品的界面设计做横向拆解。总体判断：Markdown 编辑器的「好看」不是主题数量的比拼，而是由布局减法、排版打磨、克制的主题系统与专注体验四层叠加出来的；做得最好的产品（iA Writer、Typora、Bear、Craft、Paper、Apostrophe）无一例外把「界面隐身、正文即界面」当作第一原则。同时各类别反复出现同一个反例模式：功能强但界面密（QOwnNotes、VNote、Amplenote、Editor.md），口碑天花板直接被压住——印证「简洁好看」本身就是获客武器（Moeditor、Caret、Springseed 均以颜值出圈）。写作时间：2026-07-21。仅依据 01–09 号调研文档归纳。

---

## 一、布局模式盘点

### 1. 极简单栏（编辑区即全部界面）

- **代表产品**：iA Writer、Byword、Paper、Typora、Mark Text、Caret、Apostrophe、Highland 2、WriteMonkey、Moeditor、Lex、MarkEdit（文档式，无文库）、Drafts（单栏 + 抽屉列表）、Reflect、Bangle.io（无工具栏、命令面板驱动）
- **适用场景**：沉浸写作、单文档场景、以「排版即界面」为卖点的产品。是「简洁好看」阵营的绝对主流形态。
- **值得注意的细节**：
  - 单栏成立的前提是编辑模式的进化：Typora 的逐段实时渲染消灭了预览栏，才让「一个栏就是全部」成为可能；仍坚持纯源码的单栏产品（iA Writer、Byword、MarkEdit）靠语法着色/淡化维持可读性。
  - 侧栏「可收起」而非「不存在」：iA Writer 的文库侧栏、Typora 的文件树侧栏都默认隐藏或可一键收起，保证首屏是纸面。
  - Apostrophe 是「零面板」的极限样本：界面元素几乎为零，只有一个悬浮工具条，亮/暗/羊皮纸三主题，被 02 号文档称为跨平台阵营唯一「原生且美」的例外。
  - WriteMonkey 更激进：全屏禅模式是默认形态（Esc 才退回窗口），底部信息条（字数/进度/时间）可自定义，在极简与信息量之间取平衡。
  - Lex 的「纸面」思路：单栏居中、大留白、几乎无 chrome，AI 反馈以侧边批注而非弹窗呈现，不打断纸面。

### 2. 双栏分屏（源码 + 预览）

- **代表产品**：MacDown、Mou、MarkdownPad、iWriter Pro、ghostwriter、StackEdit、Dillinger、HackMD、HedgeDoc、ReText、Inkdrop、Joplin、mdnice、doocs/md、Md2All；MiaoYan（⌘\ 一键切换分屏）
- **适用场景**：程序员工具型产品、协作平台、目标平台排版工具（左写右看「发出去的样子」）。03 号文档梳理的交互演化脉络明确：双栏分屏是第一代（MarkdownPad 时代）形态，「正在过时」，新品以分屏起步「等于落后十年」（02 号小结）。
- **值得注意的细节**：
  - 同步滚动是分屏模式的体验底线：MarkdownPad 的 LivePreview 同步滚动是当年招牌；StackEdit 的精确 Scroll Sync（双栏滚动条严格绑定）被评为业界口碑最好之一；Remarkable 同步滚动坏了多年未修成为口碑黑洞（反例）。
  - MiaoYan 给出分屏的现代姿势：默认纯净单栏源码，⌘\ 一键切入 60fps 双向滚动同步的分屏——分屏是「按需模式」而不是常驻布局。
  - 目标平台排版工具把预览具象化：mdnice/doocs/md 的右栏直接模拟「手机里公众号文章的样子」，预览 = 最终发布效果的心智模型。
  - HedgeDoc 的昼夜分治：编辑侧默认暗色、预览侧亮色，可分别切换。

### 3. 三栏文件树 / 文库型

- **代表产品**：Ulysses（组/清单/编辑器）、Bear（标签/列表/编辑器）、MiaoYan（文件夹/列表/编辑器）、MWeb、Obsidian、Zettlr、NotePlan（三栏 + 右侧日历时间轴）、Joplin、Inkdrop、Notable、Boostnote、VNote、SiYuan（类 IDE 三栏 + 多页签）；变体：FSNotes / nvUltra 的「单窗三段」（搜索框/列表/编辑器）
- **适用场景**：笔记库 / 多文档管理 / 知识库场景，是「文库型编辑器」的标准答案。
- **值得注意的细节**：
  - 逐级折叠是三栏的正确打开方式：Ulysses 三栏可逐级收起到纯编辑单栏，Bear / Obsidian / MiaoYan 均可折叠——三栏是「管理态」，单栏是「写作态」，两态一键切换。
  - omnibar 是三栏的最高效入口：nvUltra / FSNotes 继承 Notational Velocity 的「一个输入框同时完成搜索/新建（搜不到即回车新建）」，01 号文档称其为笔记型编辑器最高效的入口设计；iA Writer 8 则把文档大纲合并进搜索框。
  - 非侵入式功能挂载：Ulysses 把字数目标/统计/关键词放在「附件栏」，挂在纸面之外不干扰正文。
  - 反例同样清晰：VNote、QOwnNotes 的多面板工具型三栏「密度高但不够精致」，是「简洁好看」要刻意避开的 IDE 化方向；QOwnNotes 首次启动让用户选布局预设（Minimal / Full / Preview Only / Vertical / Single Column），说明工具型产品自己也意识到布局负担。

### 4. 块编辑器 / 大纲流

- **代表产品**：块式——Notion、Craft、AppFlowy、AFFiNE、Anytype、Notesnook、Outline、语雀、wolai、飞书文档、FlowUs；大纲式——Logseq、Roam Research、RemNote、Tana
- **适用场景**：笔记/文档一体化产品、协作平台。在这一类里 Markdown 退化为输入语法糖（`#` + 空格出标题、`/` 唤起斜杠菜单），数据存私有块模型（05 号文档）。
- **值得注意的细节**：
  - Notion 是「安静界面」的教科书：块 hover 才出现拖拽手柄（⠿）和 `+` 按钮——能力藏在悬停里，界面保持灰白极简。
  - Craft 证明块编辑器也能有「文档感」：卡片化页面、细腻微动效、出版级默认排版，公认「最漂亮的笔记应用」之一（Mac App Store 2021 年度应用）。
  - Roam 的右侧堆叠 sidebar（边读边写的「双开」体验）至今仍是被广泛模仿的最佳实践。
  - Logseq 的「无边距大纲流」是大纲派的标志性视觉。
  - 对纯 Markdown 编辑器的启示主要在输入层：斜杠命令 + Markdown 快捷输入已成用户肌肉记忆，值得吸收；块模型本身与「本地 .md 文件为真相源」冲突，不宜照搬。

### 5. 特殊形态（补充盘点）

- **白板 + 卡片**：Heptabase（无限白板 + 卡片深度编辑双层结构，卡片可全屏进入专注写作）、AFFiNE（Page/Edgeless 双形态一键切换，文档与画布同一份数据）。
- **卡片时间线流**：Memos（单栏时间线 + 左侧窄导航，把「快速捕捉」摩擦降到最低）、Blinko（卡片流 + 柔和圆角）。
- **独立预览器**：Marked 2（编辑与预览解耦，监视文件实时刷新，「写作者的第二屏」）、inlyne（GPU 加速的轻量预览窗 + live reload，「markdown 界的 Preview.app」）、Glow / Frogmouth（终端阅读器，Frogmouth 有浏览器式前进/后退/书签）。
- **结构化组装**：readme.so（左侧可拖拽 section 列表 + 中间编辑 + 右侧预览，「选积木 → 填空 → 排序」消解白纸恐惧）。

---

## 二、排版与字体

### 字体选择

- **iA Writer（天花板样本）**：自研 Mono / Duo / Quattro 三款专用字体（等宽/双宽体系，字体本身已开源），配标志性蓝色光标；行距字号经过精密调校且几乎不可自定义——01 号文档的结论是「用字体与排版而非皮肤建立辨识度」，排版即品牌。
- **精选默认字体派**：MiaoYan 默认精选中文友好字体、间距为中文阅读专门调校；Moeditor 用 Raleway 字体 + 大留白单栏，当年被称为最好看的开源 Markdown 编辑器之一；Craft 的默认排版（字距/行高/标题层级）全部调过，「用户不排版也好看」。
- **有限选项派**：Notion 只给 Default / Serif / Mono 三档全局切换——选择极少但每档都成立，降低决策负担。
- **自定义放开派**：Paper 行宽/行距/字距/主题全可调（Pro）；UpNote「设置里给足排版自定义但默认值已经很好」；Moeditor 可自定义字体/行高/字号。共同点：自定义是进阶选项，默认值必须开箱即美。
- **写作专用视觉**：Sublime Text 的 MarkdownEditing 插件为写作单独设计配色方案（弱化 UI、强化正文层级），提出「同一编辑器，代码模式与写作模式视觉不同」的理念——07 号文档建议原生应用把它做得更极致（切换字体、行距、版心宽度）。

### 行宽（版心）与行高

- 行宽限制是「纸面感」的关键：Apostrophe 被点名「排版用心（合适的行宽、衬线正文可选）」；Glow 在终端里也用 `-w` 控制行宽；07 号文档把「版心、行距、中西文混排」列为开发者工具阵营的稀缺品。
- 行高被反复当作精致度的度量：iA Writer 行距精密调校不可改；Caret 以「精确的行高与排版节奏」被誉为最讲究细节的编辑器之一（金色光标同为其标志）；语雀的行高与标点处理被评为中文排版最佳梯队；Craft 行高属于「出版级默认排版」的一部分。
- 中文混排是国产产品的独立赛道：MiaoYan 自动排版格式化（中英文混排自动加空格）；Vditor 的 Lute 引擎在解析层做中西文间自动空格与中文标点优化；SiYuan 对中西文混排间距做了大量细节优化（编辑体验被少数派评为「远超 Typora」）；语雀行高、标点、中西文混排为全类别最佳梯队。

### 标题层级的视觉化手法

- **字号分级**：Typora / Apostrophe 式源码内联美化——标题变大、粗体变粗、语法符号保留但淡化；Emacs markdown-mode 的标题分级字号是同思路鼻祖（markup hiding 已有 20 年生命力）。
- **色块 / 色阶**：render-markdown.nvim 给六级标题做色块（配代码块背景 + 语言图标、表格对齐线、callout 彩色框），被公认「默认配置即好看」，其标题色阶方案被 07 号文档点名可直接参考。
- **反面教材**：Zed 的预览被用户吐槽 h1/h2/h3 字号几乎一样、层级不可见且不支持自定义预览主题——07 号文档由此得出结论：开发者编辑器普遍不重视排版美学，这正是「简洁好看」定位的空档。
- **辅助性排版着色**：iA Writer 的语法高亮按词性给名词/动词/形容词着色（独家）；Zettlr 的 Readability 模式按句子复杂度着色——排版着色不只服务层级，也可服务写作质量。

---

## 三、主题系统

### 三种主题机制

1. **主题即 CSS 文件（Web 渲染系）**
   - Typora 是范式定义者：一个主题就是一个 .css（加可选资源文件夹），官方维护 theme.typora.io 主题画廊，社区贡献上百款（GitHub 风、Newsprint 报纸风、学术风），三平台渲染完全一致。02 号文档评价：这套设计把定制门槛降到前端开发者人手可为，是其社区生态的核心引擎。
   - 同路者：Obsidian（主题即 CSS，数百款，Minimal、AnuPpuccin 等知名主题）、Marked 2（自定义 CSS 且实时热载，可当排版调试器用）、MacDown / Remarkable / StackEdit（自定义 CSS）、mdnice / doocs/md（主题渲染为内联样式，粘贴到公众号不丢样式）。
   - mdnice 更进一步把「主题做成商品」：社区投稿制主题市场、免费与付费主题并存、风格化命名（极客黑、橙心、山吹）降低选择成本。

2. **主题数据化（JSON / 变量描述，原生渲染系）**
   - NotePlan：主题完全自定义，用 JSON 定义字体/颜色/正则匹配样式——可给任意语法元素定样式，是原生应用主题机制里开放度最高的样本。
   - Glow：终端渲染样式 = 一份可分发的主题 JSON（各元素颜色/边距/前缀全部数据化），内置 dark/light/Tokyo Night 等主题，且自动检测终端背景色选暗/亮样式——「主题数据化 + 自动适配」两个思路都值得原生应用照搬。
   - ghostwriter：自带主题编辑器，可自定义背景图与配色并分享主题；MarkFlowy 支持自定义主题导出分享。

3. **内置多套精品（不开放或弱开放）**
   - Apostrophe：亮 / 暗 / 羊皮纸（sepia）三主题——极简产品的标准配置，羊皮纸这类低成本情绪化设计很讨喜。
   - Mark Text：6 款官方主题（Cadmium Light、Material Dark、Graphite 等），社区 fork 扩到 33 款（Dracula、Nord、Catppuccin、Tokyo Night）；MWeb：11 浅色 + 21 深色；iA Writer：仅浅/深两主题，几乎零自定义（被抱怨但也构成品牌）。
   - Bear：大量精致主题 + 可换图标，主题是 Pro 订阅的付费点与社区传播点；Drafts 同样主题与图标可换（Pro）。

### 深色模式处理

- **跟随系统自动切换**：MarkEdit 完全贴合 macOS 规范（原生 NSToolbar、自动深浅色、系统控件），被 01 号文档总结为「克制、系统感、零学习成本」；Glow 自动检测背景色是终端侧的同款思路。
- **独立双态设计**：几乎所有产品都提供深浅两套（Typora / Obsidian / Zettlr / Joplin 等）；Inkdrop 的暗色主题被视为「开发者审美」代表；Springseed 2.0 的深色侧栏 + 大字号 + 扁平设计在 2014 年的 Linux 桌面上出圈。
- **分区处理**：HedgeDoc 编辑侧暗、预览侧亮，可分别设置——写作与阅读的照度需求不同，这一细节少有人做。
- **系统材质联动**：Typedown 用 WinUI 3 云母/亚克力材质做出「最像 Windows 亲儿子」的观感（Windows 侧证据）；macOS 侧 iA Writer 8 与 MiaoYan 已适配 macOS 26 的 Liquid Glass 玻璃质感——深色模式不只是换色板，还要与系统材质一起适配。

---

## 四、专注体验：专注模式 / 打字机模式 / 禅模式对比

### 专注（焦点）模式——「淡化正文其余部分」

| 产品 | 聚焦粒度 | 实现细节 |
|---|---|---|
| iA Writer | 句子 / 段落 | 焦点模式与打字机滚动配合，是该交互的品牌化者 |
| ghostwriter | 当前行 / 句子 / 段落 / 三行（可配置） | 粒度最细的开源实现，07/02 号文档均点名其粒度设计 |
| iWriter Pro | 句 / 行 / 段 | 打字机模式与聚焦合并为一组设置 |
| Typora | 段落 | 专注模式 = 淡化非当前段落 |
| Caret | 段落 | Focus 模式的段落淡出被列为值得学习的细节 |
| Byword | 段落 / 行 | 与「最流畅打字手感」并列的核心卖点 |
| Zettlr / Mark Text / Apostrophe / Obsidian | 段落级 | 标配化；Obsidian 靠社区插件补打字机滚动 |

### 打字机模式——「当前行垂直居中/固定」

- 定义最清晰的是 Typora：当前行垂直居中。iA Writer、Byword、ghostwriter、WriteMonkey、Zettlr、Mark Text、Caret（Typewriter 模式）均提供打字机滚动。
- 01 号文档特别指出 Byword 的价值：光标移动与滚动动画的手感打磨本身就是核心卖点——打字机模式的品质差异在动画曲线而不在功能有无。

### 禅模式 / 全屏无干扰

- WriteMonkey：全屏禅模式是**默认形态**（Esc 退回窗口），「zenware」概念鼻祖之一；界面只剩文字和光标，可自定义的底部信息条负责最低限度的信息量。
- Dillinger：Zen 模式的克制实现——一个按钮去除全部干扰，不搞复杂设置。
- ghostwriter / Apostrophe：全屏 + 专注 + Hemingway 三件套；Notable 有 zen 模式；Laverna 有 distraction free 模式。

### 专注体验的延伸设计（差异化机会）

- **Hemingway 模式**（ghostwriter 招牌、Apostrophe 跟进）：禁用退格与删除键，强迫向前写——实现成本低、辨识度高。
- **write-only 模式**（Paper）：只能写不能删改，对抗自我审查；配合打字音效、触控板捏合调字号，把「打字的物理愉悦感」做成护城河。
- **写作冲刺 / 目标 / 统计**：Highland 的 Sprints 冲刺计时；Ulysses / WriteMonkey / Zettlr 的字数目标；ghostwriter 的会话统计（本次写了多少字、码字速度）是对写作者的激励设计。
- **暂存交互**：Highland 的 The Shelf——把「暂时不要但舍不得删」的文字拖到侧栏暂存，解决写作者真实痛点，与专注模式互补。
- **反面手感证据**：markview.nvim 的 hybrid 模式「光标一动渲染就消失」被社区公认打断心流；render-markdown.nvim 的 anti-conceal（只还原光标所在行、其余保持渲染态）被验证为手感最佳——专注体验的本质是「视觉状态变化最小化」。

---

## 五、「简洁好看」到底来自哪些具体手法（归纳清单）

**A. 减法类（界面隐身）**

1. 排版即界面：界面元素极少，全部注意力留给正文（Typora「极简、留白、排版即界面」；iA Writer「工具隐身」；Byword「无 chrome」）。
2. 侧栏/面板默认收起，管理态与写作态一键切换（Ulysses 三栏逐级折叠、iA Writer 文库侧栏、MiaoYan 三栏可收起）。
3. 无工具栏，用命令面板 + 斜杠命令替代（Bangle.io、SilverBullet、Tana Cmd+K；iA Writer 8 的 ⇧⌘P 命令面板；Obsidian Cmd+P；VNote Universal Entry；Simplenote Cmd+K）——06 号文档的原话：「宁可无工具栏 + 命令面板/斜杠命令，也不要 Editor.md 式图标堆砌」。
4. 能力藏在悬停里：Notion 块 hover 才出现拖拽手柄与 `+`；MarkPad 浮动语法工具栏只在选中文本时出现（「简洁但可发现」）；Apostrophe 仅一个悬浮工具条。
5. 复杂能力收纳进侧栏/弹层不打扰主界面（doocs/md 把图床、AI、多平台发布全部收进不打扰主界面的侧边栏）。
6. 搜索与导航合一：omnibar 搜索即新建（nvUltra/FSNotes）、搜索框合并文档大纲（iA Writer 8）、search-first 首页（Flatnotes）。

**B. 排版类（正文的质感）**

7. 自研或精选默认字体，行距字号精密调校（iA Writer 三字体、MiaoYan 中文字体、Moeditor Raleway、Craft 出版级默认值）。
8. 行宽（版心）限制与留白（Apostrophe 合适行宽、Lex/Moeditor/Outline 大留白、Typora 留白）。
9. 标题层级必须视觉可辨：字号分级或色阶（render-markdown.nvim 六级色块；Zed 层级不可见是反例）。
10. 语法标记淡化/隐藏而非删除：着色淡化（iA Writer、Byword）、选中显形离开即藏（Bear 的颗粒度）、光标行还原其余渲染（Obsidian Live Preview、render-markdown.nvim anti-conceal）。
11. 中文排版细节：中西文混排自动空格、标点与行高调校（MiaoYan、Vditor/Lute、SiYuan、语雀）——中文产品的天然差异化。
12. 默认值即成品：用户不调任何设置也好看（Craft、UpNote、render-markdown.nvim、Glow 零配置默认值）。

**C. 细节质感类（第二层体验）**

13. 克制的品牌色锚点：iA Writer 蓝色光标、Caret 金色光标、Bear 红色主题色、Reflect 紫色渐变——一个颜色即品牌，而非满界面配色。
14. 动效与手感：Paper 的丝滑打字动画/手势/打字音效、Byword 的光标与滚动动画、Craft 的物理感微动效——01 号文档称其为「简洁好看之上的第二层体验差异化」。
15. 空态页与新手引导的打磨（Anytype 被点名「值得逐屏学习其空态页与新手引导」）。
16. 情绪化低成本设计：羊皮纸主题（Apostrophe）、可换应用图标（Bear、Drafts）。
17. 性能当美学：启动即写（Simplenote「零摩擦、即开即写」、Drafts「打开 0 秒进入输入状态」）、把「快」品牌化（Reflect）、55ms 打开《白鲸记》（Bear）、零延迟手感（Zed）——慢是最大的丑。

**D. 系统一致性类**

18. 贴合系统设计语言本身就是差异化卖点：MarkEdit 的原生 NSToolbar + 自动深浅色 + 系统控件（「零学习成本」）；Typedown 的 WinUI 3 + Fluent + 云母/亚克力（Windows 侧证据）；Apostrophe 的 GTK4/libadwaita（Linux 侧证据）——03 号文档结论：「深度贴合系统设计语言（对我们即 macOS HIG、毛玻璃、原生字体渲染）本身就是差异化卖点」。
19. 与系统材质/新版本视觉同步演进（iA Writer 8 与 MiaoYan 适配 macOS 26 Liquid Glass）。

**E. 反面清单（被验证会拉低观感的做法）**

20. 图标工具栏堆砌（Editor.md 的 jQuery 时代密集工具栏，06 号文档明言「已被时代淘汰」）。
21. 多面板高密度 IDE 化（QOwnNotes「面板繁多、视觉过时」、VNote「密度高但不够精致」、Joplin「实用但不精致」）。
22. 功能强但不好看，口碑天花板被压住（Amplenote「视觉上不讨喜」是其主要减分项）。
23. 预览排版无人打磨（VS Code 默认预览简陋、Zed 预览层级不可见）。

---

## 六、对我们产品的 UI 建议

（定位：原生 macOS、简洁好看、开源免费、可接入 AI）

### 1. 默认布局

- **首屏 = 单栏纸面**：默认打开即极简单栏编辑区，对标 iA Writer 的克制与 Typora 的留白；文件树/文库侧栏默认可收起，学 Ulysses/MiaoYan 的「三栏可逐级折叠到单栏」——管理态与写作态一键互换，两个人群（单文档党 / 文库党）一套布局。
- **入口双件套**：omnibar「搜索即新建」（FSNotes/nvUltra 已验证的最高效入口）+ 命令面板 ⇧⌘P（iA Writer 8 范式），大纲不做常驻面板、合入搜索框。
- **分屏预览做成「按需模式」**：⌘\ 一键切换 + 双向滚动同步（MiaoYan 60fps 基准、StackEdit 精确绑定基准），而非常驻双栏——编辑区主形态应是混合实时渲染（光标处还原源码、其余渲染，Obsidian Live Preview / anti-conceal 路线，07 号文档验证的最优手感），分屏只服务对照场景与导出预览。
- **不做的**：常驻多面板、常驻图标工具栏、IDE 式多页签起步；格式操作交给悬停浮层（选中才出现，学 MarkPad/Notion）与快捷键。

### 2. 字体方向

- **默认值一步到位**：学 Craft/UpNote——默认字体、行高、版心宽度出厂即成品；提供 Notion 式极少档位（正文 / 衬线 / 等宽三档）而非字体列表，进阶排版参数（行宽/行距/字距）放进设置深处（Paper 模式：可调但不显眼）。
- **正文与界面分治**：界面层完全用系统字体与系统控件（SF Pro 体系，MarkEdit 路线）；正文层做写作专属排版（Sublime MarkdownEditing 的「写作换一套视觉」理念）：限制版心行宽、调校行高、标题用字号分级 + 可选色阶（render-markdown.nvim 方案）呈现层级。
- **中文混排是必修课**：默认中文友好字重与行高、中西文混排间距/自动空格（MiaoYan、Vditor/Lute、SiYuan、语雀四个样本一致指向这里），这是国产开源项目的天然差异化。
- **字体可评估但不押注**：iA Writer 的 Mono/Duo/Quattro 已开源，可评估作为等宽/写作字体选项；但 01 号文档的真正结论是「用字体与留白建立品牌」比堆选项重要——先把默认排版参数打磨到 iA 级，再谈自研字体。
- **一个品牌色锚点**：学 iA 蓝光标 / Caret 金光标 / Bear 红——用光标色或强调色做唯一品牌记忆点，界面其余保持系统中性色。

### 3. 主题策略

- **内置少而精**：浅色 / 深色 / 纸感（sepia）三套起步（Apostrophe 配置），默认跟随系统外观自动切换（MarkEdit 基准），深浅两态都必须是一等公民。
- **主题数据化、单文件、可分享**：原生编辑区主题用 JSON 变量描述（NotePlan 的「JSON 定义字体/颜色/样式」+ Glow 的「主题 = 可分发 JSON」两个先例），预览/导出主题用 CSS（Typora 范式，兼容其社区审美与迁移习惯）——两层主题共享同一套设计令牌，保证编辑与预览观感一致。
- **官方主题画廊做社区冷启动**：Typora 的 theme.typora.io 与 mdnice 的投稿制主题市场证明，「主题即一个文件 + 在线画廊」是开源产品最便宜的生态引擎；我们开源免费，主题不设付费墙（Bear 把主题当 Pro 付费点是商业产品做法，与我们定位不符）。
- **反例守则**：主题系统不追数量（MWeb 32 款主题并未换来精致口碑），先保证 3 套默认主题在深浅两态下都经得起逐像素检查。

### 4. 专注体验配置

- 专注模式做可配置粒度（行/句/段，ghostwriter 基准），打字机模式当前行垂直居中（Typora 定义），全屏禅模式一键进入（Dillinger 的克制：一个按钮，不堆设置）。
- 滚动与光标动画的手感按 Byword/Paper 标准打磨——打字机模式的差距在动画曲线。
- 差异化候选（低成本高辨识度）：Hemingway 模式（禁退格）、会话统计（ghostwriter）、The Shelf 式侧栏暂存（Highland）。
- 混合渲染的状态切换遵循 anti-conceal 原则：只还原光标行，避免 markview.nvim 式「光标一动渲染就消失」的心流打断。

### 5. 贴合 macOS 设计规范的落地建议

- **HIG 全项对齐（MarkEdit 是现成标尺）**：原生 NSToolbar、标准设置窗口、完整菜单栏与快捷键、系统右键菜单、系统拼写检查、自动深浅色——目标是「零学习成本、系统感」；03 号文档明确：把 macOS 原生质感（字体渲染、毛玻璃、动效、HIG）做满即是差异化。
- **系统材质**：侧栏与浮层使用系统毛玻璃材质，跟进 macOS 26 Liquid Glass（iA Writer 8、MiaoYan 均已适配，说明这是 2026 年原生精品的及格线）；材质随深浅色自动过渡。
- **SF Symbols**：工具栏、命令面板、状态栏图标统一采用 SF Symbols，随系统字重与深浅色自适应——避免自绘图标造成的「非原生感」，这正是 Electron 竞品（Obsidian 被抱怨「原生 macOS 集成弱」）做不到的细节。
- **系统能力集成清单**（各产品验证过的高感知低成本项）：
  - Writing Tools / Apple Intelligence 选中文本入口（Ulysses/Bear 路线，零成本 AI 兜底，且支持整体关闭）；
  - QuickLook 插件让 Finder 直接预览 .md（iWriter Pro）；
  - 签名与公证必须做（MarkFlowy 未签名需 `xattr` 手动放行是硬教训）；
  - 打印/PDF 导出走系统 WebKit/PDFKit（07 号文档：MPE 依赖无头 Chrome 导出脆弱缓慢的反面教训）。
- **AI 界面遵循同一套减法**：AI 以可收起的侧栏对话 + 选中浮层出现（doocs/md 侧栏范式 + Notion 选中浮层），输出先预览/diff 再应用，不在主界面常驻任何 AI 按钮——保持「核心极简 + AI 可开关」（01 号文档结论），并可实现 iA Writer 的 Authorship 式 AI 文本标注作为视觉差异化。
- **性能即观感指标**：启动近即时、打字零延迟、大文件流畅滚动（Bear 55ms 打开《白鲸记》、MarkEdit 百万行流畅、Zed 手感标准），把这些做成可宣传的显性卖点——原生路线相对 Electron 竞品的「好看」，一半来自排版，一半来自快。

### 6. 一句话定位

用 iA Writer 的排版克制 + Typora 的实时渲染留白 + Bear 的语法隐藏颗粒度 + Paper 的动效手感 + MarkEdit 的系统感，组合成「打开即纸面、管理可展开、主题少而精、AI 藏而不扰」的原生 macOS 界面——这五个对标对象分别是各自维度的公认天花板，而同时占齐五个维度的产品目前不存在。
