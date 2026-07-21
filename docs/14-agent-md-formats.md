# 写给 AI Agent 的 Markdown：文件格式与规范

> 总体观察：2025–2026 年冒出了一个全新的 Markdown 文体——**开发者用 Markdown 写「给 AI Agent 看的文件」**，而不是给人看的文档。这类文件分两大家族：一是「指令文件」（`CLAUDE.md`、`AGENTS.md`、`.cursor/rules/*.mdc`、`copilot-instructions.md`、`GEMINI.md` 等），告诉 Agent「在这个仓库里该怎么干活」；二是「知识索引」（`llms.txt` / `llms-full.txt`），告诉 Agent「这个站点/文库的资料在哪、长什么样」。整个格局同时在**收敛**（`AGENTS.md` 已成为被 24+ 工具原生读取、Linux Foundation 背书、60,000+ 仓库采用的跨工具最大公约数）又在**碎片化**（几乎每个工具仍保留自己的规则目录、frontmatter 字段名、glob 语义、字符上限与层级路径）。共同点是：它们**全都是纯 Markdown（外加可选的 YAML frontmatter）**——恰好是我们编辑器的主场。对面向「写大量 Markdown 的开发者」的产品而言，「舒服地写、并正确地组织这些文件」是一个正在成形、目前几乎没人认真服务的刚需。
>
> 说明：本文只覆盖**静态文件格式与规范本身**。MCP（内置 server／协议接入）归 15 号文档、Agent Skills 归 16 号、Agent 工作流归 17 号，本文仅在「该把什么内容从指令文件里挪出去」时顺带指向它们。所有事实均以官方规范／官方文档／官方仓库为准（调研于 2026-07-21），第三方来源的结论会标注不确定性。

---

## 一、CLAUDE.md：Claude Code 的项目记忆

Claude Code 有**两套并列的记忆系统**，每次会话开始都会加载（官方文档 `code.claude.com/docs/en/memory`）：

| | CLAUDE.md 文件 | Auto memory（自动记忆） |
|---|---|---|
| 谁写 | 你（人） | Claude 自己 |
| 内容 | 指令与规则 | 学到的模式与经验 |
| 作用域 | 项目 / 用户 / 组织 | 每个 git 仓库一份，跨 worktree 共享 |
| 加载 | 每次会话**全量**载入 | 每次会话载入 `MEMORY.md` 的前 200 行或 25KB |

关键定性：CLAUDE.md 是**上下文（context），不是强制配置（enforced configuration）**——官方明确说它「作为 system prompt 之后的一条 user message 送入，不保证严格遵守」。要硬性拦截某动作要用 `PreToolUse` hook，而非写在 CLAUDE.md 里。

### 1.1 层级机制（企业 / 用户 / 项目 / 本地）

CLAUDE.md 可存在于多个位置，按「作用域从宽到窄」的加载顺序（越靠后越接近工作目录、优先级越高）：

| 作用域 | 位置 | 用途 |
|---|---|---|
| **Managed policy（企业托管）** | macOS `/Library/Application Support/ClaudeCode/CLAUDE.md`；Linux/WSL `/etc/claude-code/CLAUDE.md`；Windows `C:\Program Files\ClaudeCode\CLAUDE.md` | 组织统一下发，个人设置无法排除；也可用 `managed-settings.json` 的 `claudeMd` 键内联 |
| **User（用户级）** | `~/.claude/CLAUDE.md` | 跨所有项目的个人偏好 |
| **Project（项目级）** | `./CLAUDE.md` 或 `./.claude/CLAUDE.md` | 随 git 共享给团队 |
| **Local（本地级）** | `./CLAUDE.local.md` | 个人的项目内偏好，需自行加进 `.gitignore`（`/init` 选 personal 会自动加） |

加载规则：从工作目录**向上遍历目录树**，每一级的 `CLAUDE.md` 和 `CLAUDE.local.md` 都被发现并**拼接**（不是互相覆盖）；内容按「从文件系统根到工作目录」排序，同级里 `CLAUDE.local.md` 排在 `CLAUDE.md` 之后。**子目录**里的 `CLAUDE.md` 不在启动时加载，而是当 Claude 读取该子目录下文件时按需载入。monorepo 里可用 `claudeMdExcludes`（glob）跳过别的团队的 CLAUDE.md。块级 HTML 注释 `<!-- ... -->` 在注入前会被**剥离**（可用来给人类维护者留言而不耗 token）。

### 1.2 `.claude/rules/`：路径作用域的模块化规则

大项目可把指令拆进 `.claude/rules/` 目录，每个 `.md` 一个主题（`testing.md`、`api-design.md`…），递归发现、可放子目录、可 symlink 共享。无 frontmatter 的规则文件与 `.claude/CLAUDE.md` 同优先级、启动即载入；带 `paths` frontmatter 的则是**路径作用域规则（path-specific rules）**，只在 Claude 读到匹配文件时才载入：

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
---
# API 开发规则
- 所有 API endpoint 必须做输入校验
```

glob 支持 `**/*.ts`、`src/**/*`、`*.md`、大括号展开 `{ts,tsx}` 等；`[` 是 bracket 表达式起始，要匹配字面量需转义 `\[`。用户级 `~/.claude/rules/` 对所有项目生效、优先级低于项目规则。

### 1.3 @import 导入、# 快捷追加、斜杠命令

- **`@path/to/import` 导入**：相对/绝对路径皆可（相对路径相对于**含 import 的文件**而非工作目录）；可递归导入，**最大深度 4 跳（four hops）**；解析时跳过代码块与行内 code span（想提到路径又不导入就用反引号包住 `` `@README` ``）；首次遇到外部 import 会弹审批对话框。这是 CLAUDE.md 兼容 AGENTS.md 的官方推荐手段（见 1.5）。注意：import 只帮助**组织**，被导入文件仍在启动时全部进上下文，**不省 token**。
- **`#` 快捷追加**：在输入行以 `#` 开头打一句话回车，Claude 就把它写进最相关的 CLAUDE.md，并让你选目的地（project / user `~/.claude/CLAUDE.md` / local）。Anthropic 团队用它随手记「项目约定、bash 命令、代码风格小坑」。注意：2025 年底社区报告过某些平台上 `#` 失效被当普通文本的 bug（issue #14868），官方建议升级到最新版，`/memory` 可作替代。
- **`/init`**：分析代码库自动生成起步 CLAUDE.md；若已存在则给改进建议而非覆盖；在已有 `AGENTS.md`、`.cursorrules`、`.devin/rules/`、`.windsurfrules` 的仓库里会读取并吸收它们。`CLAUDE_CODE_NEW_INIT=1` 开启多阶段交互式流程。
- **`/memory`**：列出并打开各作用域的 CLAUDE.md / CLAUDE.local.md / auto memory 文件，切换 auto memory 开关。**`/context`**：查当前会话实际加载了哪些文件（调试「Claude 没读到我的规则」的首选）。

### 1.4 Auto memory（自动记忆）

Claude 自己在 `~/.claude/projects/<project>/memory/` 下积累经验：入口 `MEMORY.md`（简洁索引，每次载入前 200 行 / 25KB）+ 若干主题文件（`debugging.md` 等，按需读取）。`<project>` 由 git 仓库派生，所有 worktree/子目录共享一份、机器本地、不跨机器同步。可用 `autoMemoryEnabled: false` 或 `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` 关闭。（本仓库 `~/.claude/projects/.../memory/MEMORY.md` 用的正是这套机制。）

### 1.5 与 AGENTS.md 的关系

Claude Code **只读 `CLAUDE.md`，不读 `AGENTS.md`**。官方给出的桥接办法：在 CLAUDE.md 顶部写 `@AGENTS.md` 导入，再在下面追加 Claude 专属指令；或 `ln -s AGENTS.md CLAUDE.md` 建 symlink（Windows 建 symlink 需管理员/开发者模式，故推荐用 import）。

### 1.6 最佳实践（官方明述）

- **大小**：单个 CLAUDE.md 目标 **< 200 行**；越长越耗上下文、遵守度越差（CLAUDE.md 不像 `MEMORY.md` 有硬截断，是全量载入，但短才好）。
- **结构**：用 markdown 标题和 bullet 分组；Claude 和人一样扫描结构。
- **具体**：写可验证的指令——「用 2 空格缩进」优于「格式化好代码」，「提交前跑 `npm test`」优于「测试你的改动」，「API handler 在 `src/api/handlers/`」优于「文件放整齐」。
- **一致**：两条规则冲突时 Claude 会任选其一；定期审查根/嵌套 CLAUDE.md 与 `.claude/rules/` 去掉过时或矛盾项。
- **该挪走的挪走**：多步流程 → Skill；只对局部代码生效的 → path-scoped rule；必须在固定时机执行的（每次提交前）→ hook。`/doctor`（v2.1.206+）会建议裁掉「Claude 能从代码库自行推断」的内容（目录结构、依赖列表），保留「坑、原因、与工具默认值不同的约定」。

---

## 二、AGENTS.md：正在收敛的跨工具开放标准

`AGENTS.md`（官网 `agents.md`）是这波格局里最重要的收敛力量。定位一句话：**「给 Agent 的 README」**——一个可预测的、专门放「构建/测试/风格/贡献」等上下文的地方，把会干扰人类读者的细节从 README 里分出来。

- **起源与治理**：由 OpenAI 于 2025-08 发布（脱胎于 OpenAI Codex、Amp、Jules、Cursor、Factory 的协作），2025 年底移交给 **Linux Foundation 旗下的 Agentic AI Foundation（AAIF）**托管，与 Anthropic 的 MCP、Block 的 Goose 并列。（治理归属据多方一手报道，可作可信但非本站自证。）
- **格式**：**就是标准 Markdown，无必填字段、无 YAML frontmatter、无特殊语法**。官方 FAQ 原话：随便用什么标题都行，Agent 直接解析你写的文本。常见小节：Project overview、Build/test commands、Code style、Testing instructions、Security、Commit/PR guidelines、Deployment。
- **monorepo 嵌套**：支持目录树里放多个 `AGENTS.md`，**Agent 读取离被编辑文件最近的那个（就近优先），子项目可各自定制**；用户在对话里的显式指令覆盖一切。官方举例 OpenAI 自家 Codex 仓库用了 **88 个 AGENTS.md**。
- **规模**：官网称覆盖 **60,000+ 开源项目**（GitHub `path:AGENTS.md` 搜索口径）。
- **谁支持（官网列出的 24+ 工具）**：OpenAI Codex、Jules（Google）、Factory、Aider、goose、opencode、Zed、Warp、VS Code、Devin（Cognition）、UiPath Autopilot & Coded Agents、Junie（JetBrains）、Amp（Sourcegraph）、Cursor、RooCode、Gemini CLI（Google）、Kilo Code、Phoenix、Semgrep、GitHub Copilot Coding Agent、Ona、Windsurf（Cognition）、Augment Code……
- **值得注意的两点**：**Amp 原生读 `AGENTS.md`，找不到时回退读 `CLAUDE.md`**（迁移期的实用桥）；**Claude Code 是唯一的大 holdout**（坚持 `CLAUDE.md`，靠 `@AGENTS.md` 导入或 symlink 兼容）。
- **迁移**：把老的单文件规范改名并建软链向后兼容——`mv AGENT.md AGENTS.md && ln -s AGENTS.md AGENT.md`。

一句判断：**AGENTS.md 赢在「刻意什么都不规定」**——正因为它只是纯 Markdown、没有 schema，才能被这么多工具零成本地共同读取。它是「共享的散文正文」，而各家的 rules 系统是「工具专属的结构化补充」。

---

## 三、Cursor Rules

Cursor 的项目规则放在 **`.cursor/rules/` 目录下的 `.mdc`（Markdown + frontmatter）文件**，随 git 版本化。该目录里的普通 `.md` 会被忽略（除非用 `.mdc` 扩展名，或走 `AGENTS.md` 模式）。

- **frontmatter 只有三个字段**：`description`（给 Agent 判断相关性用的说明）、`globs`（触发自动附加的文件 glob）、`alwaysApply`（布尔）。官方未记录第三个之外的字段。
- **四种规则类型**（由字段组合决定何时注入）：

| 类型 | 触发方式 | 配置 |
|---|---|---|
| Always | 每次会话都注入 | `alwaysApply: true` |
| Auto Attached（按文件） | 打开/编辑匹配 `globs` 的文件时 | 给 `globs`、`alwaysApply: false` |
| Agent Requested（智能） | Agent 依据 `description` 自行决定 | 给 `description`、`alwaysApply: false` |
| Manual | 在对话里 `@rule-name` 显式引用 | `description` 与 `globs` 都省略 |

- **Project Rules vs User Rules**：Project Rules 在 `.cursor/rules`、随仓库共享；**User Rules 是全局的、纯文本（在 Settings 里设，不是文件），只对 Agent(Chat) 生效、不作用于 Inline Edit（Cmd/Ctrl+K）**。
- **嵌套 & AGENTS.md**：支持子目录里的嵌套 `AGENTS.md`，与父级合并、越具体越优先；官方把 `AGENTS.md` 定位为 `.cursor/rules` 的**「简单替代」**——无 metadata、无复杂配置的纯 markdown，适合「不想要结构化规则开销」的场景。glob 示例：`*.ts`、`**/*.tsx`、`src/**/*.tsx`、逗号分隔 `docs/**/*.md, docs/**/*.mdx`。
- **旧版 `.cursorrules`**：项目根的单文件旧格式；当前官方文档已**不再提及**（视为 deprecated，官方引导迁移到 `.cursor/rules/`），但为向后兼容一般仍会被读取。

---

## 四、GitHub Copilot：仓库级与路径级指令

Copilot 的自定义指令有清晰的两级 + 优先级（官方文档 `docs.github.com/copilot`）：

- **仓库级**：`.github/copilot-instructions.md`（自然语言 Markdown），对该仓库的所有请求生效。
- **路径级**：`.github/instructions/` 目录（及子目录）下的 `NAME.instructions.md` 文件，**必须有 frontmatter**：
  - `applyTo`：glob，指定生效的文件/目录，例如 `applyTo: "**/*.ts,**/*.tsx"`；匹配到时，路径级指令与仓库级指令**同时**生效。
  - `excludeAgent`（可选）：阻止特定 agent 使用，取值 `code-review` 或 `cloud-agent`。
- **优先级**：**Personal（个人）> Repository（仓库）> Organization（组织）**。
- **也读跨工具文件**：Copilot 支持仓库任意位置的 `AGENTS.md`（就近优先），或仓库根的单个 `CLAUDE.md` / `GEMINI.md`。

Copilot 是「路径级 + frontmatter glob」这一模式最规范的官方样本之一，`applyTo` 与 Cursor 的 `globs`、Claude 的 `paths`、Windsurf 的 `globs` 是同一类东西的不同拼写。

---

## 五、其他工具的规则/记忆文件

### 5.1 Windsurf（现属 Cognition/Devin）

官方文档已并入 `docs.devin.ai`（Windsurf 被 Cognition 收购，与 agents.md 把 Windsurf 标注为「Cognition」一致）。

- **位置**：工作区规则 `.devin/rules/*.md`（首选）或 `.windsurf/rules/*.md`（回退）；旧单文件 `.windsurfrules`（仍读）；全局 `~/.codeium/windsurf/memories/global_rules.md`。
- **字符上限**（明确数字）：**每个工作区规则文件 12,000 字符**、**全局规则文件 6,000 字符**。
- **frontmatter 的 `trigger` 四态**：`always_on`（每条消息都进 system prompt）、`model_decision`（先只给 description，需要时载入全文）、`glob`（配 `globs`，读/改匹配文件时生效）、`manual`（不进 prompt，靠 `@rule-name` 激活）。全局规则和根 `AGENTS.md` 不用 frontmatter、恒为 always-on。
- **Auto-generated memories**：Cascade 对话中自动生成、存 `~/.codeium/windsurf/memories/`、不耗 credit；但官方建议「持久知识写进 Rules 或 AGENTS.md」以便团队共享。
- **AGENTS.md**：支持，作为「零配置的位置作用域规则」——根目录 = always-on，子目录 = glob。

### 5.2 Cline

- **位置**：工作区 `.clinerules/`（根目录）或全局目录；处理其中所有 `.md`/`.txt` 并合并；数字前缀（`01-coding.md`）仅用于排序、可选。
- **条件规则**：支持 YAML frontmatter 的 `paths`（glob），无 frontmatter 的文件恒为 always-on；建议把常开规则放无 frontmatter 文件、上下文相关的才用条件。
- **跨工具**：读全局 `~/.agents/AGENTS.md`；自动探测 `.cursorrules`、`.windsurfrules`；同项目若也用 Claude Code 则一并读 `CLAUDE.md`。工作区规则优先级高于全局。

### 5.3 Roo Code（警示：已停运）

- **重要动态**：Roo Code 于 **2026-04-21 宣布关停**（累计 300 万安装），**2026-05-15 仓库归档只读**，官方建议用户迁往 **Cline**（据多篇第三方报道，非本文一手自证）。这是「同源工具也各起炉灶」的活教材——它、Cline、Kilo Code 同一血脉却用了不同目录名。
- **格式回顾**：`.roo/rules/`（把配置收进专属 `.roo/` 文件夹，区别于 Cline 的根 dotfile），递归、按文件名字母序拼接；**mode 中心**（Code/Architect/Ask/Debug/Orchestrator 五种内置模式，`.roo/rules-{modeSlug}/` 放模式专属规则，靠 `groups` 键做**结构化的按模式权限**，比 Cline 的 glob 条件更硬）。`AGENTS.md` 默认自动加载，`roo-cline.useAgentRules: false` 可关，注入时带 `# Agent Rules Standard (AGENTS.md)` 头，2025-07 加入支持。

### 5.4 Aider

- **原生约定文件 `CONVENTIONS.md`**：默认查找该文件（可用 `--conventions-file` 改名）。加载方式：命令行 `aider --read CONVENTIONS.md`、对话内 `/read CONVENTIONS.md`（标为只读并启用 prompt caching）、或 `.aider.conf.yml` 里 `read: CONVENTIONS.md`（支持列表 `read: [CONVENTIONS.md, other.txt]`）。
- **AGENTS.md**：Aider **没有专门的 AGENTS.md 自动发现**，但因为支持任意文件名，`read: AGENTS.md`（写进 `.aider.conf.yml`）即可接入；官网 AGENTS.md 亦如此推荐（有一个 2025-07 的 issue 建议官方把 AGENTS.md 列为推荐默认名，因「无需改代码，只需改文档」）。

### 5.5 Zed（Rules 已退役 → Instructions + Skills）

- **重大变化**：Zed **1.4.2（2026-05 下旬）退役了旧的 Rules Library**——可复用 Rules 变成 **Skills**（归 16 号文档），always-on Rules 变成 **Instructions**（含个人/项目 `AGENTS.md`）。
- **AGENTS.md 双级**：同时支持**项目级 `AGENTS.md`**（仓库根）与**全局/个人 `AGENTS.md`**（macOS/Linux `~/.config/zed/AGENTS.md`，Windows `%APPDATA%\Zed\AGENTS.md`）；据称是首个在单一原生实现里同时支持两级的编辑器。项目指令与个人 AGENTS.md 冲突时项目胜出。
- **兼容多种文件名**：历史上为跨工具兼容支持多个指令文件名（`.rules`、`.cursorrules`、`CLAUDE.md` 等），按列表**第一个命中的生效**；社区正讨论是否把 `AGENTS.md` 提到最高优先级（目前 Zed 偏好编辑器专属文件在前）。v1.4.0+ 会把旧 Rules 自动迁移（默认 Rules 追加到全局 AGENTS.md，非默认 Rules 变全局 skill）。

### 5.6 Gemini CLI

- **默认文件 `GEMINI.md`**：层级加载并全部拼接进 system prompt——全局 `~/.gemini/GEMINI.md` → 项目及祖先目录 → 工具访问文件时的本地/子目录（越具体越优先）；footer 显示已加载的 context 文件数。
- **`@path` 导入**：`@./components/coding-style.md` 之类，把大文件拆成小块；**只支持 `.md`**（Memory Import Processor）。
- **文件名可配**：默认 `GEMINI.md`，可在 `settings.json` 用 **`contextFileName`** 改名——因此**可以配置成读 `AGENTS.md`**（这是 Gemini CLI 与 AGENTS.md 标准接轨的方式）。
- **命令**：`/memory show`（看拼接后的完整记忆）、`/memory refresh`（重扫重载）、`/memory add <text>`（追加到全局 `~/.gemini/GEMINI.md`）。

---

## 六、llms.txt 与 llms-full.txt：喂知识，不是给指令

这是与上面所有「指令文件」**本质不同**的一类：`llms.txt` 由 fast.ai 的 **Jeremy Howard 于 2024-09-03 提出**（`llmstxt.org`），是**放在站点根 `/llms.txt`、给 LLM 在推理时（inference time）读的、关于「这个网站/文档有什么、在哪」的策展索引**。

- **规范结构**（严格顺序，全用 Markdown）：可选 BOM → **H1 项目名（唯一必填）** → **blockquote 摘要** → 零或多个自由 Markdown 段落/列表 → 零或多个 **H2 引出的「文件列表」**，每项是 `[name](url): 可选备注`。名为 `Optional` 的 H2 小节表示「上下文吃紧时可跳过的次要内容」。
- **`llms-full.txt`**：把所有被链接页面的 Markdown **全文拼接成一个大文件**，供想「一口气吞下全部文档」的 Agent 使用。它最初由 **Mintlify 与 Anthropic 合作**做出来（Anthropic 需要不解析 HTML 就把整份文档喂给 LLM），效果好后并入 `llmstxt.org` 标准。对比规模：Anthropic 的 `llms.txt` 约 8,364 tokens、`llms-full.txt` 约 481,349 tokens（数量级示意）。
- **与指令文件的根本区别**：`llms.txt` 面向**站点/文档、喂的是知识与导航**；`CLAUDE.md`/`AGENTS.md` 面向**代码仓库、给的是行为指令**。前者回答「资料在哪」，后者回答「怎么干活」。也别和 `robots.txt`（限制爬取）、`sitemap.xml`（列全部页面）混淆——`llms.txt` 是**为 LLM 策展的精简概览**，专治上下文窗口有限。
- **采用现状（务实看待）**：
  - 最大推手是 **Mintlify 于 2024-11-20 给所有托管文档站一键铺开**，让 Anthropic、Cursor、Coinbase、Pinecone、Windsurf 等一夜之间都有了这个文件。已知采用者还包括 Stripe、Cloudflare、Vercel、Supabase、LangGraph、OpenAI 等（多为开发者向公司）。
  - 但整体采用率仅约 **10%**（SE Ranking 对 30 万域名的研究，据第三方引用）；**主流 LLM 爬虫基本不主动抓取**（OpenAI/Google/Anthropic 的爬虫都不怎么请求它），**Google 已公开明确不支持**（2025-07 Gary Illyes 表态，John Mueller 拿它类比失败的 keywords meta tag）；有研究称对「被引用」无统计显著收益。
  - **真正在用它的是 IDE/编码 Agent**（Cursor、Continue、Cline）与部分 MCP 集成——这恰恰是我们的相关人群。共识：**它是「便宜的基础设施」，值得顺手做，但别当作 SEO/引用杠杆**；价值在「让 AI 准确理解你的产品/文档、减少 RAG 的 token」。

---

## 七、frontmatter / YAML 约定的共性

把各家「rules」文件的 frontmatter 拉平看，会发现字段高度趋同——都是在解决同三件事：**「这条规则什么时候生效」「给 Agent 的一句自述」「是否恒定注入」**。

| 工具 | 文件/目录 | 「作用范围」字段 | 「描述」字段 | 「恒定/触发」字段 |
|---|---|---|---|---|
| Cursor | `.cursor/rules/*.mdc` | `globs` | `description` | `alwaysApply`（布尔） |
| Claude Code | `.claude/rules/*.md` | `paths` | —（用文件名/正文） | 无 `paths` = 恒定 |
| GitHub Copilot | `.github/instructions/*.instructions.md` | `applyTo` | —（正文） | 另有 `excludeAgent` |
| Windsurf | `.windsurf/rules/*.md` | `globs` | `description` | `trigger`（4 态） |
| Cline | `.clinerules/*.md` | `paths` | —（正文） | 无 frontmatter = 恒定 |
| **AGENTS.md** | 仓库根/子目录 | **无 frontmatter**（靠**目录位置**决定作用域） | 无 | 就近覆盖 |

归纳三条共性：
1. **glob/路径作用域是标配**，只是字段名各异（`globs`/`paths`/`applyTo`）、glob 语义大同小异（`**/*.ts`、大括号展开）。
2. **「always vs 按需 vs 手动 vs 智能」四态**是反复出现的心智模型（Cursor 四类型、Windsurf `trigger` 四态、Claude 的 path-scoped vs 无条件）。
3. **`description` 字段服务于「Agent 自主决定要不要读这条规则」**（Cursor Agent Requested、Windsurf model_decision）——这是 frontmatter 里最「AI 特有」的一格。
4. 反例是 **AGENTS.md 故意不要 frontmatter**，用「文件放在哪个目录」代替「glob 写什么」来表达作用域——这也是它能跨工具的原因。

**编辑器要读懂的元数据面就这么大**：一个 `description`、一个 glob 字段、一个 always/trigger 开关，外加 Copilot 的 `excludeAgent`——完全可以做成表单。

---

## 八、什么样的指令文件才算「好」

综合 Anthropic 官方 CLAUDE.md 指南与高质量社区经验（HumanLayer、多篇 2026 best-practices），共识清单：

- **短**：CLAUDE.md 官方目标 < 200 行；社区共识 < 300 行、越短越好（HumanLayer 的根文件 < 60 行）。核心原因只有一个——**它每次会话都进上下文，和你的对话抢注意力，越长遵守度越差**。
- **具体、可验证，别写「志向」**：「Server components by default; 只在真需要时加 'use client'」这种能测的，胜过「写干净的代码」这种正确的废话（Claude 本来就想写干净代码）。
- **解释「为什么」**：原因不是废话，是 Claude 处理边缘情况时的泛化依据——带理由的规则（"我们曾因过度 client 化把 LCP 拖到 8 秒"）能迁移到相似场景，不带理由的一换语境就被忽略。
- **普适**：因为进每次会话，内容要尽量对**所有任务**都适用；别把「怎么建新数据库 schema」这种局部指令塞进来，干扰无关任务。
- **别塞满命令**：贪多求全会稀释重点、结果更差。
- **结构化**：用标题和 bullet 分组；必要时用 `IMPORTANT` / `YOU MUST` 强调关键规则以提高遵守度（Anthropic 内部做法）。
- **当代码维护**：进 PR 审查、随代码演进、像重构臃肿模块一样裁剪——一条六个月前的过时规则，今天仍在塑造每次回答。
- **渐进披露（progressive disclosure）**：项目变大就拆——自动化规则 → hooks，多步工作流 → Skills，共享片段 → `.claude/rules/` + `@import`，局部规则 → path-scoped。让 Agent「只在需要时」看到任务/局部指令，而非全部塞进根文件。

---

## 九、格局判断：收敛还是碎片化？

**结论：内容层在收敛，机制层仍碎片化——两股力同时存在。**

- **收敛的证据**：`AGENTS.md` 已是被 24+ 工具原生读取、Linux Foundation 背书、60,000+ 仓库采用的跨工具最大公约数；连各家自己的编辑器（Cursor、Copilot、Zed、Windsurf、Gemini CLI 可配）都主动去读它；实践共识明确——**单一真相源放 `AGENTS.md`，工具专属配置放各自的 rules 文件，Claude Code 用 `@AGENTS.md` 桥接**。
- **仍碎片化的证据**：规则目录名（`.cursor/rules` / `.claude/rules` / `.windsurf/rules` / `.clinerules` / `.roo/rules` / `.github/instructions`）、frontmatter schema（`globs` vs `paths` vs `applyTo`；`alwaysApply` vs `trigger`）、字符上限（Windsurf 12k/6k、CLAUDE.md 200 行）、层级路径与优先级规则**各不相同**；`GEMINI.md`、`CONVENTIONS.md` 各自为政；Claude Code 坚持 `CLAUDE.md`；同源的 Cline/Roo/Kilo 都用不同目录名。加上工具本身在洗牌（**Roo Code 2026-04 停运、Zed 1.4.2 退役 Rules**），格式仍在演进。
- **净判断**：`AGENTS.md` 是「大家共读的散文正文」，各家 rules 是「工具专属的结构化补充（主要提供 glob 作用域与 always/按需的注入控制）」。这个「一个通用散文层 + N 个结构化元数据层」的二元格局，短期内不会合并成单一规范。
- **对编辑器意味着什么**：这正是我们「人 ↔ AI Agent 的 Markdown 界面」定位的核心价值面。**把 `AGENTS.md` 与 `CLAUDE.md` 当一等公民**、同时**理解各家 frontmatter 的那几个字段**、并帮用户**管好散落在多层目录里的一堆规则文件**——这件事目前没有任何一款「好看的原生编辑器」在做。收敛（AGENTS.md）降低了「需要支持的格式种类」的风险，碎片化（各家 rules + frontmatter + glob + 层级）则正好是**编辑器能创造价值的地方**：把碎片化的复杂度用 UI 吸收掉。

---

## 对我们编辑器的启示

- **把 `CLAUDE.md` 与 `AGENTS.md` 当一等公民**：专属文件图标/徽标、在「新建」菜单里直接可选、打开时顶部显示「这是给 Agent 读的指令文件（会被 X 工具加载）」的上下文条；识别 `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` / `*.mdc` / `*.instructions.md` / `.windsurfrules` / `CONVENTIONS.md` / `llms.txt` 这一整族文件名。
- **模板库**：内置各格式的高质量起步模板——`AGENTS.md`（Project overview / Build & test / Code style / Security 小节）、`CLAUDE.md`（含 `@AGENTS.md` 桥接段）、`.cursor/rules/*.mdc`（三字段 frontmatter 骨架）、`.github/copilot-instructions.md` 与 `*.instructions.md`（带 `applyTo`）、`GEMINI.md`、`llms.txt`（H1 + blockquote + H2 文件列表的规范骨架）。模板本身也是最好的「格式教学」。
- **frontmatter 表单化编辑**：检测文件类型后，把 YAML frontmatter 渲染成表单——`description` 文本框、`globs`/`paths`/`applyTo` 的 glob 输入、`alwaysApply` 开关或 Windsurf `trigger`/Cursor 四类型的下拉、Copilot `excludeAgent` 多选。源码与表单双向同步（呼应我们混合渲染的双内核思路）。
- **glob 感知（杀手级细节）**：对 `globs`/`paths`/`applyTo` 做**实时校验 + 匹配预览**——「这条规则当前匹配到仓库里的这 N 个文件」live 列表，配路径自动补全；把 Claude 的 `[` bracket 转义、大括号展开等易错点做成即时提示。这是「懂 Markdown 也懂 Agent 语义」的最直观体现。
- **多文件规则管理面板**：一个侧栏聚合展示仓库里所有 Agent 指令文件——各级 `CLAUDE.md`、`.claude/rules/`、`.cursor/rules/`、`.github/instructions/`、嵌套 `AGENTS.md`——标出各自作用域、触发条件（always / glob / manual / agent-requested）、以及**合并后的加载顺序与优先级**，并**高亮相互冲突的规则**（呼应官方「两条规则冲突 Claude 会任选」的痛点）。做「给定某个文件，Agent 实际会看到的有效指令集是什么」的预览（相当于图形化的 `/context`、`/memory show`）。
- **`@import` / 导入图可视化**：解析 CLAUDE.md 的 `@path` 与 Gemini 的 `@file.md`，显示导入关系图、点击跳转被导入文件、**对超过 4 跳深度给出警告**、对「import 不省 token」这类官方要点做提示。
- **字段与规范校验（linter）**：按各工具 schema 校验 frontmatter——Cursor 只认 `description`/`globs`/`alwaysApply`，出现未知字段就警告；Copilot `excludeAgent` 只能取 `code-review`/`cloud-agent`；`llms.txt` 结构顺序（H1→blockquote→H2 列表）校验；**字符/行数上限提醒**（Windsurf 12k/6k、CLAUDE.md ~200 行、`MEMORY.md` 200 行/25KB）。再叠一层「最佳实践 lint」：过长、纯志向式空话、疑似矛盾项的软提醒。
- **AGENTS.md ↔ CLAUDE.md 桥接助手**：一键在 `CLAUDE.md` 顶部生成 `@AGENTS.md` 导入 stub，或建立 symlink（并提示 Windows 需要开发者模式）；提供「让这个仓库同时满足 Claude Code / Codex / Cursor / Copilot」的一键脚手架，把「一个真相源 + 各工具薄壳」的社区最佳实践产品化。
- **从文库生成 `llms.txt` / `llms-full.txt`**：既然我们本就管理着一个 `.md` 文件夹，可提供「按目录 + 每个文件的 frontmatter `description` 自动生成规范 `llms.txt` 索引、并拼接出 `llms-full.txt`」的命令——把 Mintlify 对托管文档做的事，下放给本地文库作者。
- **保持克制、划清边界**：本编辑器只做「静态文件的编写、校验、组织」；真正的**协议接入（MCP）、可复用能力（Skills）、多步工作流**分别是 15/16/17 号文档的范畴，编辑器对它们的角色是「舒服地编写其配套的 Markdown/frontmatter」，而非内置运行时。
- **跟踪格式演进、避免押注单一工具**：Roo Code 停运、Zed 退役 Rules、Windsurf 归 Cognition、Cursor 弃用 `.cursorrules`——格式仍在洗牌。把「支持哪些格式」做成**数据驱动的可配置表**（文件名 → frontmatter schema → glob 语义 → 上限），新增/调整一个工具只改配置、不改代码，才跟得上这个每季度都在变的领域。
