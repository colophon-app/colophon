# Agent Skills 与 Markdown：技能即 Markdown

> 总体观察：Agent Skills 是 Anthropic 于 2025-10 推出、并在 2025-12-18 开源为跨厂商开放标准（agentskills.io）的一种「能力封装格式」，而它的物理载体恰恰就是 **Markdown**——一个带 YAML frontmatter 的 `SKILL.md`，外加若干可选的附带文件（脚本、参考文档、模板）。对一款原生 Markdown 编辑器而言，这是整份调研里「最顺手」的一块：skill 不是我们要新支持的文件类型，它**就是 Markdown 本身**。
>
> 在「路线 B」的三种「AI 的门」里，skill 填的是「按需加载的操作手册／程序化技能」这一格，与 MCP（连接工具，doc 15）、CLAUDE.md/AGENTS.md（常驻指令，doc 14）分工明确、互补而非竞争。更关键的是：在 Claude Code 里一个 skill 只是 `.claude/skills/` 下的一个文件夹，**不需要我们跑任何 server**——这使 skill 成为路线 B 里最轻的落地方式。
>
> 本文的主张就是「技能即 Markdown」：编辑器既应当是**写 skill 最舒服的地方**（frontmatter + 渐进披露结构 + 附带文件，全是我们的主场），也应当**为自家格式与工作流附带官方 skills**，让用户已经在跑的 Agent（Claude Code、Codex、Cursor 等）无需我们提供后端，就能安全、正确地操作整个 Markdown 文库（呼应 doc 13 的 V2 建议）。

---

## 一、Skills 是什么：一个 `SKILL.md` 就是一项技能

### 1.1 定义与最小结构

Anthropic 官方定义：Agent Skills 是「organized folders of instructions, scripts, and resources that agents can discover and load dynamically to perform better at specific tasks」——**可被 Agent 动态发现并按需加载的、装着指令/脚本/资源的有组织文件夹**。官方文档进一步把它类比成「给新同事写的 onboarding 指南」：把某个领域的工作流、上下文、最佳实践打包，让通用 Agent 变成专才。

一个 skill 的最小形态就是**一个目录 + 一个 `SKILL.md`**。`SKILL.md` 只有两部分：

1. **YAML frontmatter**（`---` 包裹）——技能的「身份证」，告诉 Agent 这项技能是什么、何时该用；
2. **Markdown 正文**——技能的「操作手册」，告诉 Agent 一旦决定用了要具体怎么做。

官方最小模板（来自 anthropics/skills 的 `template`）：

```markdown
---
name: my-skill-name
description: A clear description of what this skill does and when to use it
---

# My Skill Name

[Instructions that Claude will follow when this skill is active]

## Examples
- Example usage 1
- Example usage 2

## Guidelines
- Guideline 1
```

一句话：**skill = 一段带 frontmatter 的 Markdown + 可选的附带文件**。这正是我们的编辑器每天在处理的东西。

### 1.2 frontmatter 字段与硬性约束（来自 platform.claude.com 官方文档）

官方**只强制两个字段**：`name` 与 `description`。二者的校验规则相当具体，是我们做「frontmatter 校验」功能可以直接落地的清单：

| 字段 | 是否必填 | 硬性约束（官方） |
|---|---|---|
| `name` | 必填 | 最长 **64 字符**；只能用**小写字母、数字、连字符**；不能含 XML 标签；不能包含保留词 **`anthropic`、`claude`** |
| `description` | 必填 | **非空**；最长 **1024 字符**；不能含 XML 标签；**必须同时写清「做什么」和「何时用」** |

- `description` 是**整个机制里最重要的一句话**：Agent 在启动时把所有已安装 skill 的 `name` + `description` 预载入 system prompt，之后**拿用户请求去和 `description` 做匹配**来决定要不要触发这项 skill。官方给的范例（pdf skill）：
  `description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`
  ——注意它「做什么（前半句）+ 何时用（Use when…）」的固定句式。
- **额外/实验性字段**：官方 overview 只保证 `name`/`description` 两个必填字段；Claude Code 场景里另见一个**实验性**的 `allowed-tools`，用来声明这项 skill 只需要哪些工具（如 `Bash(git:*) Bash(jq:*) Read`），触发时 Agent 只获得所列工具的访问权。社区代码里还能看到未被官方文档收录的字段（如 `when_to_use`），**不应依赖**。我们的校验器应以 `name`/`description` 为准，其余字段作可选提示。

### 1.3 渐进式披露（progressive disclosure）：三级按需加载

这是 skill 机制的**核心设计原则**，也是「为什么 skill 要拆成 frontmatter + 正文 + 附带文件」的原因。官方类比：像一本组织良好的手册——先是**目录**，再是**具体章节**，最后是**详细附录**——Agent 只在需要时逐级加载。官方给出的三级与其 token 成本（这张表值得逐格记住）：

| 层级 | 何时加载 | token 成本 | 内容 |
|---|---|---|---|
| **Level 1 · Metadata** | 启动时**始终**加载 | **每个 skill 约 100 tokens** | frontmatter 的 `name` + `description` |
| **Level 2 · Instructions** | skill **被触发时** | **建议 < 5k tokens** | `SKILL.md` 正文（工作流、最佳实践、指引） |
| **Level 3+ · Resources** | **按需**（被引用到才读） | **未访问前为 0** | 附带文件：参考文档被读入才进上下文；脚本经 bash 运行、**只有输出进上下文，代码本身永不进上下文** |

由此得出两条对我们极重要的性质：

- **装很多 skill 不花上下文**：触发前每个 skill 只占约 100 tokens 的 metadata，所以「装一大批 skill」几乎无成本。
- **附带内容近乎无上限**：文件不被访问就不耗上下文，因此一个 skill 可以捆绑「完整的 API 文档、大数据集、大量示例」而无惩罚——官方原话是「no practical limit on bundled content」。
- 脚本比「让模型现场生成等价代码」更**可靠且省 token**：跑 `validate_form.py` 时，只有 `Validation passed` 之类输出进上下文。

### 1.4 打包脚本与资源：推荐目录结构

当 `SKILL.md` 变臃肿或某些内容只在特定场景相关时，就把它们拆成附带文件、在正文里用文件名引用。官方推荐的标准三目录：

```text
my-skill/
├── SKILL.md      # 核心指令（Level 1 frontmatter + Level 2 正文）
├── scripts/      # 可执行 Python/Bash 脚本——经 bash 运行，只回传输出
├── references/   # 供查阅的文档——被读取时才进上下文
└── assets/       # 模板、二进制文件等资源
```

官方 pdf skill 的真实形态则是把拆分文件放在同级：`SKILL.md` 引用 `FORMS.md`（表单填写指南）、`REFERENCE.md`（详细 API），并配 `scripts/fill_form.py`——「把表单填写移到 `forms.md`，让 skill 核心保持精简，相信 Claude 只在真要填表时才去读 `forms.md`」。三种内容各有所长：**instructions 管灵活指引、code 管可靠确定、resources 管事实查阅**。

### 1.5 如何被加载与触发：四个「表面」（surface）各有差异

skill「write once」，但**在哪儿用、怎么装**四个表面各不相同（官方明确「custom Skills 不跨表面同步」，得分别上传）：

- **Claude Code**：**纯文件系统**，无需上传。放进 `~/.claude/skills/`（个人）或项目内 `.claude/skills/`（项目级），Agent 自动发现并使用。预置的四个文档 skill（pptx/xlsx/docx/pdf）**在 Claude Code 里不可用**，但开源的 `claude-api` skill 随 Claude Code 捆绑。可经 Claude Code **Plugins** 分享。→ **这是对我们最重要的表面：写个文件夹就完事。**
- **claude.ai**：把 skill 打成 **zip 从 Settings → Features 上传**；需 Pro/Max/Team/Enterprise 且开启 code execution；**每个用户各自上传**，不共享、无管理员集中管理。预置文档 skill 在「创建文档」时自动生效。
- **Claude API / Developer Platform**：需搭配 **code execution tool**（skill 就跑在它的 container 里），在 `container` 参数里指定 `skill_id`，加 beta header **`skills-2025-10-02`**（用 Files API 传文件再加 `files-api-2025-04-14`）。预置 id 为 `pptx`/`xlsx`/`docx`/`pdf`；自定义 skill 经 **`/v1/skills` 端点**上传、**工作区级共享**。API 沙箱**无网络、不能运行时装包**。
- **Claude Agent SDK**：官方列为受支持表面之一（「supported today across Claude.ai, Claude Code, the Claude Agent SDK, and the Claude Developer Platform」）。
- 另外 **Claude Platform on AWS** 与 **Microsoft Foundry**（需 Hosted-on-Anthropic 部署）也支持，行为与 API 一致。

**触发逻辑统一**：启动预载 `name`+`description` → 用户请求与 `description` 匹配 → Agent 用 bash `cat SKILL.md` 读入正文 → 正文若引用其它文件再逐个 bash 读 → 脚本经 bash 执行只取输出。**全程模型自主，无需用户手动挂载**——这也是为什么 `description` 写得好不好几乎决定 skill 的成败。

---

## 二、Skills vs MCP vs 规则文件：三种「AI 的门」的分工

这是我们设计「AI 的门」时最需要讲清的一张分工图（MCP 细节归 doc 15，CLAUDE.md/AGENTS.md 细节归 doc 14，此处只划边界）：

| 维度 | **Agent Skills** | **MCP** | **CLAUDE.md / AGENTS.md / rules** |
|---|---|---|---|
| 本质 | 以 Markdown 承载的**程序化技能/操作手册** | **工具与数据的连接协议** | **常驻指令/项目规则** |
| 回答的问题 | 「**怎么做**这件事」（the playbook） | 「让 Agent **能访问**某样东西」（the tools） | 「**始终**要遵守的约定」 |
| 加载时机 | **按需**（description 匹配才触发；渐进披露） | 工具常驻可调用 | **每次会话常驻** |
| 上下文成本 | 触发前仅约 100 tokens/个 | 工具 schema 常驻占用 | 常驻占用 |
| 载体 | `SKILL.md`（Markdown + frontmatter + 附件） | server 进程 + 协议 | Markdown 文本 |

官方与社区共识的**决策口诀**：

- 「**每次会话都要生效的规则**」→ 写进 **CLAUDE.md/AGENTS.md**（doc 14）。
- 「**只在某类任务时才需要的工作流/操作手册**」→ 写成一个 **skill**。
- 「让 Agent **连到外部工具/API/数据库**，或读写你的文库」→ 用 **MCP**（doc 15）。
- 三者**互补组合**：一句被官方与社区反复引用的话——*MCP gives your agent access to tools and data; Skills teach your agent what to do with those tools and data.*（MCP 给「访问权」，skill 给「怎么用」；skill 是 MCP 的**说明书**。）

对我们的直接含义：**同一个「安全操作文库」的能力，最好由 MCP + skill 合起来交付**——MCP 暴露「读写某节/插入表格/生成 front matter」等工具，skill 教 Agent「何时、以何顺序、注意哪些坑」来用这些工具。而在不方便跑 MCP 的场景，**单靠 skill（纯文件）也能把文库约定教给 Agent**（见第六节 (c)）。

---

## 三、Skills 生态：官方示例、开放标准、社区

### 3.1 官方 anthropics/skills 仓库

Anthropic 在 `github.com/anthropics/skills` 维护规范 + 示例 skills，是学习「好的 `SKILL.md` 长什么样」的第一站。仓库结构为 `skills/`（示例）+ `spec/`（规范）+ `template/`（模板）。**多数 skill 为 Apache-2.0 开源**，四个文档 skill（pptx/xlsx/docx/pdf）为 **source-available（可见源码但非 OSI 开源）**，作为生产参考实现。目前的示例 skill 目录名（对我们有直接借鉴意义的已标注）：

`algorithmic-art`、`brand-guidelines`（← 品牌/风格，类比我们的主题）、`canvas-design`、`claude-api`、`doc-coauthoring`（← **文档协同创作，与我们产品高度相关**）、`docx`、`frontend-design`、`internal-comms`、`mcp-builder`（← 帮 Agent 生成 MCP server）、`pdf`、`pptx`、`skill-creator`（← **官方的「造 skill 的 skill」**）、`slack-gif-creator`、`theme-factory`（← **主题工厂，直接对应我们的主题系统**）、`web-artifacts-builder`、`webapp-testing`、`xlsx`。

其中 **`skill-creator`** 是 Anthropic 在 Claude Code 里提供的「用来造 skill 的 skill」，会引导你搭好 frontmatter 与结构——是我们做「新建 skill 向导」的现成参考。

### 3.2 开放标准 agentskills.io 与 Agentic AI Foundation

- **2025-12-18，Anthropic 把 Agent Skills 开源为跨厂商标准**，规范发布在 **agentskills.io**，规范与校验工具在 `github.com/agentskills/agentskills`。核心承诺是 **write once, run anywhere**：一个符合规范的 skill 可跨 Claude Code、OpenAI Codex、GitHub Copilot、Cursor、Gemini CLI 等任意兼容 Agent 运行（工具差异可能需小改）。
- **采纳极快**：发布 48 小时内微软经 Copilot 接入 VS Code、OpenAI 接入 ChatGPT 与 Codex；到 2026-03 已有 **30+ 工具**读同一份 `SKILL.md`。（Simon Willison 曾在 2025-12 记录：ChatGPT 的 code interpreter 环境里早有 `/home/oai/skills` 目录、内置 PDF/文档/表格 skill，与该格式结构一致。）
- **治理中立**：标准由 **Agentic AI Foundation**（Linux Foundation 旗下、2025-12 成立，创始项目由 Anthropic、OpenAI、Block 贡献）托管，不绑定单一厂商。
- 官方还同步发布了**企业级 skill 管理层**与一批**合作伙伴 skill**（Atlassian、Canva、Cloudflare、Figma、Notion、Ramp、Stripe、Zapier）。

**对我们的战略含义**：我们为自家格式写的 skill **不是只服务 Claude 一家**——它是一份可跨 30+ Agent 复用的开放格式资产，写一次，Cursor/Codex/Copilot 用户都受益。这大幅提高了「为自家格式写 skill」的投入产出比。

### 3.3 Claude Code 的 plugins 与 skills 的关系

社区共识的心智模型：**skills/subagents/MCP 是能力，plugins 是打包与分发，commands 只是「手动调用的 skill」，marketplace 让 plugin 可被发现**。

- **plugin 不增加新能力**，只是把 skill、subagent、hook、MCP server 配置、slash command、LSP 定义**打包成一个带版本、可安装、可更新的单元**（类比一个 npm 包）。若你的东西只是一个 skill、不需要版本/清单/命名空间，直接以**独立 skill** 发布即可。
- **marketplace 就是一个 git 仓库注册表**：`/plugin marketplace add <owner/repo>` 订阅，`/plugin install <plugin>@<marketplace>` 安装，缓存到 `~/.claude/plugins/cache/` 跨项目可用。Anthropic 运营 `claude-plugins-official`（默认自带）与 `claude-community`（审核后收录）两个公共目录；团队常自建私有 marketplace。
- **commands 已并入 skills**（「commands are simply skills you invoke by hand」）——这意味着我们若做「斜杠命令/快捷指令」，底层就是 skill，无需另造一套。

**对我们的含义**：把我们自家 skills 作为**一个 plugin 发布到 marketplace**（像 kepano 那样），是近乎零成本的分发/获客渠道；用户一条 `/plugin marketplace add <我们>` 就装上全部「教 Agent 操作本编辑器文库」的 skill。

### 3.4 社区生态：合集、市场与框架（截至 2026 快速膨胀）

- **awesome 合集（GitHub，复制文件夹即用）**：`ComposioHQ/awesome-claude-skills`、`VoltAgent/awesome-agent-skills`（按可运行的 Agent 打标签、跨 CLI 覆盖强）、`addyosmani/agent-skills`（生产级精选）、`vercel-labs/agent-skills`（Vercel 官方合集）。
- **marketplace/registry**：`Skills.sh`（Vercel 背书，2026-01，npm 式包管理，`npx skills add`，跨 Claude Code/Codex/Cursor 一条命令装）、`SkillsMP`、`LobeHub`、`ClaudeSkills.info`、`Agentskill.club`、`Agensi`（含付费 skill，对每次提交跑 8 点安全扫描、创作者 80/20 分成）、`Smithery`（skill 与 MCP server 合一注册表）。
- **框架**：`superpowers`（Jesse Vincent）——把 skill 组织成一套开发方法论（先头脑风暴再动手、TDD、系统化调试、写计划并执行、适时请人复核）。
- **警示（对「skill 画廊」功能是硬约束）**：这些市场**大多无策展、无安全审查**，而 skill/plugin **会在你机器上跑代码**——官方与社区一致强调「装前审阅」。

### 3.5 obsidian-skills 深读：给「格式」写 skill 的范本（我们要照抄的模式）

`kepano/obsidian-skills`（作者 **Steph Ango，即 Obsidian CEO**）是与我们定位最贴近的先例：**为一个编辑器的开放格式写官方 skill，让任意 Agent 学会操作它的文库**。它教 Agent 使用 Obsidian CLI 与开放格式（Markdown、Bases、JSON Canvas），**遵循 Agent Skills 规范，因此 Claude Code、Codex、OpenCode 都能用**。安装方式覆盖 `/plugin marketplace add kepano/obsidian-skills`、`npx skills add …`、以及手动放进 vault 根的 `.claude/` 文件夹。（该仓库很受欢迎，各聚合站 star 口径不一，以官方仓库为准。）

其中的 `obsidian-markdown` skill 是「教格式」的教科书级样板，值得逐点拆解：

- **frontmatter**（注意 description 的「做什么 + 何时用」句式）：
  ```yaml
  name: obsidian-markdown
  description: Create and edit Obsidian Flavored Markdown with wikilinks, embeds,
    callouts, properties, and other Obsidian-specific syntax. Use when working with
    .md files in Obsidian, or when the user mentions wikilinks, callouts, frontmatter,
    tags, embeds, or Obsidian notes.
  ```
- **正文**：一个「创建笔记的 6 步工作流」+ 各类语法分节（wikilink/block id、embed、callout、properties、tags、comments、highlight、math/Mermaid、footnotes），并给一个**综合示例**。
- **渐进披露**：把大块参考拆进 `PROPERTIES.md`、`EMBEDS.md`、`CALLOUTS.md`，正文按需引用。
- **关键设计取舍**：这个 skill **只讲 Obsidian 特有的扩展**，标准 Markdown（标题/粗体/列表/表格）**当作已知不再赘述**——这正是「focus on what the model doesn't already know」最佳实践的体现，也是我们写自家 skill 的第一原则。

---

## 四、写好一个 skill 的最佳实践（引 Anthropic 官方「Skill authoring best practices」）

官方把「造 skill」类比成「给新同事写 onboarding」，给出九条可直接落进我们「作者工作台」校验规则的实践：

1. **把上下文窗口当公共资源**：触发前只有 metadata 预载，但 `SKILL.md` 一旦被读入，每个 token 都在和对话历史抢占用——**正文要精简**（官方 Level 2 目标 **< 5k tokens**；社区经验法则 **≤ 500 行**、SKILL.md **< 5000 词**）。
2. **写可被发现的 name 与 description**：`name` 建议用**动名词（gerund，verb+-ing）**，如 `processing-pdfs`；`description` 是**决定能否触发的最重要元素**，必须同时含「做什么 + 触发情境」。官方 skill-creator 建议 description 稍微**「pushy」一点**，因为模型有**低触发（under-trigger）倾向**；「缺触发条件」是 skill 该触发却没触发的**头号原因**。
3. **用渐进披露组织规模**：`SKILL.md` 臃肿就拆分、只引用文件名；互斥/罕见路径分开放以省 token；引用**只保持一层深**，长参考文件加**目录（TOC）**。
4. **讲「为什么」，别只下命令**：满篇大写 `ALWAYS/NEVER/MUST` 给的是无上下文的死规则，模型会「守字面、丢边界」；官方 skill-creator 把 **all-caps 的 MUST/ALWAYS/NEVER 明确标为 yellow flag**。更好的是「先给规则、再讲原因」，让模型能推广到没写到的情形（真正脆弱的步骤才用裸命令）。
5. **让「自由度」匹配任务脆弱度**：开放式任务给**高自由度的文字指引**；脆弱任务给**低自由度的精确脚本**。模板同理分两档——机器要解析的输出用「严格模板」，人读的文档用「灵活模板」，**默认优先灵活**。
6. **聚焦模型不会的东西**：别浪费 token 教模型本就擅长的（如常规写代码）；**最有价值的往往是 `Gotchas`（常见坑）一节**，且应基于 Claude 用这个 skill 时真实犯的错、随时间更新。
7. **代码既是工具也是文档**：脚本可执行、也可当参考；要**讲清 Claude 该「跑」还是「读」**。注意环境约束（API 无网络、不能运行时装包），依赖包要在 `SKILL.md` 里列明并确认可用。
8. **由评估驱动、迭代开发**：**先找差距**（在代表性任务上跑 Agent、看它哪里卡）再写指令；「盯住一个难任务反复迭代到成功，再把成功做法抽成 skill」是最实用的一招；进阶可用「**Claude A 改 skill / Claude B 测**」双实例回路。
9. **跨模型、跨表面测试**：对 Opus 够用的，对 Haiku 可能要更详细；官方推荐三档测试——claude.ai 手测（快）、Claude Code 脚本测（可重复）、Skills API 程序化测（成体系）。

---

## 五、安全模型：skill 会在你机器上跑代码

官方反复强调：**只用可信来源的 skill**（自己写的、或来自 Anthropic）。因为 skill 通过「指令 + 代码」赋予 Agent 新能力，**恶意 skill 能指使 Agent 以偏离其声明用途的方式调用工具或执行代码**，导致数据外泄、越权访问等。要点：

- **逐文件审阅**：`SKILL.md`、脚本、图片、资源都要看，警惕「与声明用途不符」的网络调用/文件访问。
- **外部来源尤其危险**：会从外部 URL 拉数据的 skill 风险最高（拉回的内容可能夹带恶意指令）；即便可信 skill 也可能因其外部依赖变化而被污染。
- **当作「安装软件」对待**——尤其在接触敏感数据/关键系统时。
- 注意 **Skills 不在 ZDR（zero data retention）覆盖范围**内，其定义与执行数据按标准留存策略处理。

**对我们「skill 画廊/安装」功能的硬约束**：安装前必须展示**源码审阅视图**与「此 skill 会运行代码」的明确提示，绝不静默安装。

---

## 六、与编辑器的三种结合点

### (a) 编辑器 = 写/管理 skills 的最佳场所

skill 的物理形态——**Markdown + YAML frontmatter + 附带 Markdown/脚本/资源**——恰好是我们编辑器的原生主场。今天开发者写 skill 的痛点全落在我们能解决的地方：手写 frontmatter 容易违反 `name`/`description` 约束、渐进披露的多文件结构在纯文本编辑器里「看不见」、拆分与引用完整性无人校验、打包到不同表面（zip / `.claude/skills/` / `/v1/skills`）要手工搬运。把这些做成一个**「Skill Author's Workbench（skill 作者工作台）」**，就是把「技能即 Markdown」落成产品力（具体功能见文末启示）。

### (b) 为自家格式/工作流附带官方 skills，让外部 Agent 懂我们的文库

照抄 `obsidian-skills` 的模式：**我们发布一组官方 skill，教任意兼容 Agent 正确操作本编辑器的文库**——文件夹约定、front matter schema、wiki 链接规则、附件落盘规则、主题文件格式、发布管线等。因为 skill 是**开放标准**，这一份资产同时服务 Claude Code、Codex、Cursor、Copilot 等 30+ Agent。这正是 doc 13 V2 建议「内置 MCP server + 为自家格式撰写 Agent Skills」里的 skill 半边，且比 MCP 半边更轻、可先行。

### (c) skills 作为「不跑 server 也能实现路线 B」的轻量方案

这是本文最具战略价值的一点。在 **Claude Code 表面，skill 就是 `.claude/skills/` 下一个文件夹**——**无需上传、无需 API、无需我们跑任何后端**。于是：

> 编辑器把上述官方 skills 写进用户 vault 的 `.claude/skills/`（项目级）或 `~/.claude/skills/`（全局），用户**已经在跑的 Claude Code 立刻就「懂」我们的文库**——全程零 server、零 API、零推理成本、零隐私责任。

这使 skill 成为**路线 B 的最低成本落地**：MVP/V1 阶段先靠「写 skill 文件」实现「让外部 Agent 安全读写我的 Markdown 文库」，把更重的**内置 MCP server 放到 V2** 作为增强（提供确定性的语法树级工具）。二者不是二选一：**skill 教「怎么做」，MCP 给「工具」**，最终形态是二者合璧，但 skill 让我们能**先交付、且不背任何后端负担**。

---

## 对我们编辑器的启示

### A. 把编辑器做成「Skill Author's Workbench」——具体功能清单

1. **SKILL.md 模板/脚手架（New Skill 向导）**：一键生成合规 frontmatter + 标准 body（`# 标题` / `## Instructions` / `## Examples` / `## Guidelines`）+ `scripts/` `references/` `assets/` 目录骨架；直接采用 anthropics/skills 的 `template` 与官方句式。可内置若干「起手式」（教格式 / 封装工作流 / 包脚本三类）。
2. **frontmatter 实时校验（我们最容易做出差异的功能）**：按官方规则校 `name`（≤64、仅小写字母/数字/连字符、禁保留词 `anthropic`/`claude`、建议 gerund 命名）与 `description`（非空、≤1024、**必检「做什么 + 何时用」是否齐全**、缺触发词时提示补齐、「pushy 度不足」提醒）。这是我们「front matter 表单化编辑」（doc 13 V2）在 skill 场景的自然延伸。
3. **渐进披露结构可视化**：把 `SKILL.md` + 被引用文件 + `scripts/` 画成一棵树，**标注每一级的加载时机与 token 预算**（Level 1 ~100、Level 2 目标 <5k）；`SKILL.md` 超 ~5k tokens/~500 行时**预警并建议拆分**到 `references/`。让「渐进披露」这个抽象机制**在编辑器里看得见**——这是纯文本编辑器给不了的。
4. **description / 正文 linter（触发力与风格）**：检测 `description` 是否含触发情境；标红正文里的 all-caps `ALWAYS/NEVER/MUST`（官方 yellow flag）并建议改写为「规则 + 原因」；提示补 `Gotchas` 段；对「机器解析输出 vs 人读文档」建议严格/灵活模板。
5. **引用完整性检查**：`SKILL.md` 里 `[FORMS.md](FORMS.md)` 之类链接指向的文件是否存在、引用是否**只一层深**、长参考文件是否有 TOC——复用我们知识库的「死链诊断」能力。
6. **多目标打包/导出（一键切换四个表面）**：导出 claude.ai 用的 **zip**；写入 **`~/.claude/skills/` 或项目 `.claude/skills/`**；生成 **plugin manifest** 以便 `/plugin marketplace add` 发布；（可选）经 `/v1/skills` 上传到 API 工作区。搬运细节全部自动化。
7. **测试/预览回路**：提供「**以 Agent 视角预览**」——先只显示这个 skill 会被看到的 `name`+`description`（模拟 Level 1），再展开正文；一键 `npx skills add` 或在（可选的）内置终端里跑 Claude Code 实测；内建 skill-creator 式「Claude A 改 / Claude B 测」迭代提示。
8. **Skill 画廊/市场（安装前必审）**：浏览、安装、更新社区 skills（anthropics/skills、kepano/obsidian-skills、awesome 合集、Skills.sh），可从画廊 **fork 一个 skill 到本地编辑**；同时托管**我们自家 skills 的官方画廊**。**安装前强制展示源码审阅视图 + 「此 skill 会运行代码」安全提示**（第五节的硬约束）。
9. **与 Authorship 联动（可选）**：我们计划做的 Markdown Annotations（doc 13 V1）可自然延伸到 skill——由 skill/Agent 生成的段落可标注来源，延续「透明 AI」品牌立场。

### B. 我们该为自家格式/工作流写哪些官方 skills

1. **`<editor>-markdown` / `<editor>-library`（最核心）**：教 Agent 我们文库的约定——文件夹布局、front matter schema、wiki 链接与锚点规则、daily notes 目录约定、图片/附件落盘规则。**直接照抄 `obsidian-markdown` 的写法：只讲我们特有的扩展，标准 Markdown 当已知。**
2. **`<editor>-themes`**：教 Agent 读写我们的主题文件（CSS/JSON 主题），让「让 AI 帮我做/改一个主题」成为可能；对标官方 `theme-factory` / `brand-guidelines`，也直接服务 doc 13 的「主题画廊」生态。
3. **`<editor>-publishing`**：教 Agent 走我们的发布管线——复制为公众号/知乎格式、图床上传、静态博客生成（doc 13 V1/V2 功能），把「写完还要发」的长尾刚需交给 Agent 自动化。
4. **`authoring-agent-context`（路线 B 的用户场景本身）**：一个帮用户写「给 Agent 看的 Markdown」的 skill——CLAUDE.md、AGENTS.md、spec、任务清单、项目记忆。格式细节归 doc 14，但**「怎么写好这些文件」封装成 skill** 正是我们的活，也是路线 B 最高频的场景。
5. **配合内置 MCP server 的「说明书」skill（V2，与 doc 15 分工）**：当我们上线 MCP server（暴露「改写某节 / 插入表格 / 生成 front matter」等语法树级工具）时，配一个 skill 教 Agent **何时、以何顺序、注意哪些坑**来用这些工具——skill 是 MCP 的操作手册，二者合璧才安全好用。

### C. 三条落地判断

- **顺序**：skill 是路线 B 里**最轻、可最先做**的一环——先写好第 B 组的 `-markdown`/`-library` skill 并作为 plugin 发布，即可让用户已在跑的 Claude Code 正确操作我们的文库，**MVP/V1 就能兑现路线 B，MCP server 留到 V2**。
- **杠杆**：因为 skill 是**开放标准（agentskills.io）**，我们写的每个 skill 同时服务 30+ Agent、并可经 marketplace 近零成本分发——投入产出比远高于绑定单一厂商的集成。
- **护城河**：市面上的 skill 工具多是命令行/网页；把 skill 的 frontmatter 校验、渐进披露可视化、多表面打包做进一个**原生、好看的 Markdown 编辑器**，是「技能即 Markdown」这一命题最自然、也目前无人认真占据的落点。

---

### 参考来源（官方一手为主）

- Anthropic 工程博客：*Equipping agents for the real world with Agent Skills* — anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- Claude 平台文档：*Agent Skills*（overview）— platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- Claude 平台文档：*Skill authoring best practices* — platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- 官方 skill 仓库 — github.com/anthropics/skills（含 `template`、`skill-creator`、`theme-factory`、`doc-coauthoring` 等）
- 开放标准 — agentskills.io ；规范/校验工具 github.com/agentskills/agentskills ；治理 Agentic AI Foundation（Linux Foundation）
- 社区范本 — github.com/kepano/obsidian-skills（Obsidian CEO Steph Ango；`obsidian-markdown` skill）
- Claude Code 文档 — code.claude.com/docs/en/skills 、plugins-reference
- 生态合集/市场 — Skills.sh（`npx skills add`）、ComposioHQ/awesome-claude-skills、VoltAgent/awesome-agent-skills、addyosmani/agent-skills、obra/superpowers
