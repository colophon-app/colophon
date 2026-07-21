# MCP 深度解剖：一个 Markdown 编辑器的 MCP server 该做什么

> 总体观察：Model Context Protocol（MCP，Anthropic 2024-11 提出，2025 年成为事实标准）到 2026 年中已经从「一个连接标准」长成「生产级连接层」——当前正式版规范是 **2025-11-25**，官方 Registry 上线一年内收录近 2000 个 server，MCP Apps（可交互 UI 扩展）也在 2026-01-26 作为第一个官方扩展落地。对我们（路线 B）而言，MCP 是把「编辑器 ↔ 外部 Agent」这条线做成协议而非聊天框的关键：我们不生成内容，而是把用户的 Markdown 文库**和正在编辑的实时状态**以标准接口暴露给用户已经在用的 Claude Code / Cursor / Claude Desktop / Codex。
>
> 扫描现有十余个笔记类 MCP server 后有三个反直觉的结论：(1) 它们几乎清一色只用了 MCP 三原语里的 **Tools**，Resources 用得极少、Prompts 几乎无人用——这是巨大空白；(2) 它们几乎都是「无头」的数据库/文件访问器，**没有一个暴露「用户此刻在看哪篇、选中了哪段」的活动编辑器状态**（只有 IDE 侧的 JetBrains/VS Code MCP 做了），而这恰是「编辑器」区别于「一堆 .md」的独占资产；(3) 写操作普遍是裸文本或行级替换，**没有人做基于语法树（AST/SourceRange）的结构化编辑**——而这正是 swift-markdown 给我们的隐藏红利（09、13 号文档）。本文据此反推我们该暴露什么。
>
> 分工说明：文件格式转换归 14 号，Agent Skills 归 16 号，竞品整体产品分析归 18 号；本文只在「MCP 能力维度」提及这些 server。

---

## 一、MCP 2026 现状（依据 modelcontextprotocol.io 官方规范 2025-11-25）

### 1.1 基本模型：host / client / server 三方 + JSON-RPC 2.0

MCP 是一个基于 **JSON-RPC 2.0** 的两侧协议，围绕 host（宿主应用，如 Claude Desktop）、client（宿主内为每个 server 开的连接）、server（能力提供方）建模。数据层定义了生命周期管理与核心原语；一个 client 通常对一个 server。协议本身「wire-format 无关」，只要求传的是合法 JSON-RPC。能力在 `initialize` 握手时通过 capability negotiation 声明——server 声明支持哪些原语（`tools`/`resources`/`prompts`）以及是否支持 `listChanged`/`subscribe` 等子能力。

### 1.2 三大服务器原语：Tools / Resources / Prompts

这三者的核心区别不在数据，而在**「谁来控制调用」**，这决定了各自的适用场景：

| 原语 | 控制方 | 语义 | 类比 | 关键方法 | 适用场景 |
|---|---|---|---|---|---|
| **Tools** | **模型控制**（model-controlled） | 可执行动作，可有副作用 | POST/函数调用 | `tools/list`、`tools/call` | 让 Agent「做事」：搜索、读、写、改、删、重命名 |
| **Resources** | **应用控制**（application-controlled） | 只读数据源，不应有副作用 | GET/文件 | `resources/list`、`resources/read`、`resources/templates/list`、`resources/subscribe` | 让宿主把上下文喂给模型：当前文档、文库结构、选区 |
| **Prompts** | **用户控制**（user-controlled） | 预置的模板化工作流 | slash 命令 | `prompts/list`、`prompts/get` | 用户主动触发的模板操作：`/summarize`、`/weekly-digest` |

细节（对我们设计直接相关）：

- **Tools**：每个 tool 有 `name`、可选 `title`（展示名）、`description`、`inputSchema`（JSON Schema，默认 2020-12）、可选 `outputSchema` + `structuredContent`（2025-06-18 引入的结构化输出，server 返回结构化 JSON，client 可按 schema 校验）。Tool 结果可含 text/image/audio、**`resource_link`**（返回 URI 而非内联全文，省 token）与**内嵌 resource**。关键是 **`annotations`**（行为提示）：`readOnlyHint`、`destructiveHint`、`idempotentHint`、`openWorldHint`——让 client/Agent 无需试错就知道哪个 tool 只读、哪个有破坏性、哪个可安全重试。规范明确：客户端**必须**把非可信 server 的 annotations 当作不可信。错误分两类——协议错误（未知 tool、schema 不符）与工具执行错误（`isError:true`，供模型自我纠正）。2025-11-25 还加了 `icons` 与 `execution.taskSupport`（见 1.7 Tasks）。
- **Resources**：每个 resource 由 **URI** 唯一标识，含 `name`/`title`/`description`/`mimeType`/`size`。支持 **resource templates**（`resources/templates/list`，用 RFC 6570 URI 模板如 `file:///{path}`，参数可经 completion API 补全）。支持**订阅**：`resources/subscribe` + `notifications/resources/updated`——server 内容变化时主动推送，这对「活动文档/选区随用户操作实时变化」是天生契合的机制。标准 URI scheme 有 `file://`、`https://`、`git://`，也允许自定义 scheme。`annotations` 含 `audience`（user/assistant）、`priority`（0–1）、`lastModified`（ISO 8601）。
- **Prompts**：面向用户显式选择，典型形态是 **slash command**。含 `arguments`（可 required、可经 completion 补全），`prompts/get` 返回一组 `messages`（role + content，content 可内嵌 resource）。这是唯一「用户主动、可预测」的原语——把「用户常做的 AI 操作」固化成可发现、可补全参数的模板。

### 1.3 客户端原语：Roots / Sampling / Elicitation

对称地，client 也向 server 暴露三种能力：

- **Roots**（`roots/list`）：client 告诉 server「你被允许访问的文件系统边界/工作区」。是限定 server 作用范围的安全机制——与其给 server 全盘访问，不如声明具体的 root 目录。对我们：这正是「把 server 锁在用户选定的 vault 文件夹内」的协议级手段。
- **Sampling**（`sampling/createMessage`）：server 反过来请求 client 侧的 LLM 补全一段——让 server 借用宿主的模型与额度，人类可审阅/编辑/拒绝该请求。
- **Elicitation**（2025-06-18 引入，`elicitation/create`）：server 在操作中途向用户**直接提问/索取结构化输入**，经 capability 协商、受用户同意门控；client 必须显示是哪个 server 在问，并提供拒绝/取消。对我们：这是「Agent 要写文件前，弹一个原生确认」的标准通道，但注意规范要求索取凭据时用 URL mode 而非表单。

> **演进提示（未定稿）**：MCP 下一版规范正处于候选阶段，方向包括无状态（stateless）内核、把上述 server 发起的请求（roots/list、sampling/createMessage、elicitation/create）统一改为「多轮请求（Multi Round-Trip）」模式，并**提议弃用 Roots / Sampling / Logging**（弃用有至少 12 个月缓冲期，不等于移除）。这些名字和字段可能变化，本文以 **2025-11-25 正式版**为准来设计；我们的接口应尽量不把核心逻辑压在 Sampling/Roots 上，以降低未来迁移成本。

### 1.4 传输：stdio（本地）vs Streamable HTTP（远程）

规范当前定义两种标准传输（都传 JSON-RPC 2.0，可互换迁移）：

- **stdio**：面向**本地进程**。client 把 server 作为子进程启动，写其 stdin、读其 stdout。硬性约束：**stdout 只能是协议流量**，任何日志/杂输出写进 stdout 都会污染消息流、破坏解析（社区最常见的故障源）——日志走 stderr。client **应尽量优先支持 stdio**。这是绝大多数本地工具（Claude Code、Cursor、Codex、Claude Desktop 扩展）的默认接法。
- **Streamable HTTP**：面向**远程服务**。单一 HTTP 端点同时支持 POST（client→server）与 GET（可选开 SSE 流接收 server→client 的主动消息）；会话可选，靠 server 在初始化时下发 `Mcp-Session-Id`、client 后续回带。它取代了旧的 HTTP+SSE 双连接方案（HTTP+SSE 在 2025-03-26 已被标记弃用）。**只有 HTTP 传输才谈得上真正的鉴权**（OAuth 2.1，见 1.6）。

对我们编辑器：本地 macOS app 与本地 Agent 同机，**stdio 是主路径**（客户端兼容性最好）；localhost 上的 Streamable HTTP 是可选备胎（给只会 HTTP 的客户端，或未来远程访问）。详见第四章。

### 1.5 官方 MCP Registry 现状

官方 **MCP Registry**（registry.modelcontextprotocol.io）于 **2025-09-08 预览上线**，由 MCP 开源社区共有（Anthropic、GitHub、PulseMCP、Microsoft 等维护）。它是一个**元注册表（metaregistry）**：只托管 server 的元数据/发现信息，不托管代码或二进制；提供开放的 API 规范，允许任何人建兼容的子注册表（sub-registry）并联邦。自 9 月上线到年底增长约 407%、逼近 2000 条目。仍是 preview，可能有破坏性变更或数据重置。对我们：发布后可把我们的 server 登记进去以获得发现性；但不必依赖它做分发（我们的 server 随 app 走）。

### 1.6 权限 / 授权模型

MCP 的授权是**传输层**能力，且**只为 HTTP 传输定义**：

- **stdio 传输：规范明确「不应」走 OAuth**，而是**从环境（environment）取凭据**。这对我们极重要——本地 stdio server 的「权限」不是 OAuth，而是**宿主 app 自己的同意 UI + 文件作用域**在把关（这正是 Bear「只有你安装并开启 Connector/MCP server 后才连」、Obsidian 插件用 API key 的现实做法）。
- **HTTP 传输：OAuth 2.1**。MCP server 被归类为 **OAuth 2.1 Resource Server**：必须实现 Protected Resource Metadata（RFC 9728）以指明授权服务器位置；client 必须用 **Resource Indicators（RFC 8707）** 的 `resource` 参数把 token 绑定到特定 server（防止 token 被跨服务复用）；必须用 **PKCE（S256）**；server 必须校验 token 的 audience 是自己、**禁止 token passthrough**（把收到的 client token 原样转发给上游 API，是「confused deputy」的温床）。授权是**可选**的：本地个人工具通常不实现完整 OAuth，靠 stdio + 本地同意即可。

**结论**：作为本地编辑器 server，我们不做 OAuth，走 stdio + app 原生同意/作用域；若开 localhost HTTP，用一个本地 bearer token/API key（Obsidian Local REST API 的做法）即可，不必上完整 OAuth 2.1。

### 1.7 2026 的两个既成新变量

- **Tasks（任务化执行）**：已进入 2025-11-25 正式版。tool 定义里的 `execution.taskSupport`（`forbidden`/`optional`/`required`）声明该 tool 是否支持「任务增强执行」——即长耗时操作可异步化、可查询进度/结果，而非死等一次 `tools/call` 返回。对我们：批量重构、全库索引、长文改写等可声明为 task。
- **MCP Apps（SEP-1865，`io.modelcontextprotocol/ui`）**：**已于 2026-01-26 作为第一个官方扩展落地**（统一了社区 mcp-ui 与 OpenAI Apps SDK）。机制：tool 用 `_meta.ui.resourceUri` 指向一个 `ui://` 资源（MVP 内容类型 `text/html;profile=mcp-app`），宿主在**沙箱 iframe** 里渲染，UI 与宿主用 JSON-RPC over postMessage 双向通信。Claude、Claude Desktop、ChatGPT、VS Code Copilot 等已支持。对我们：这给了「在 Agent 对话里直接渲染一张 **diff 预览卡片 / 文档大纲 / 表格编辑器**」的标准途径——但它是可选扩展、需协商，属 V2+ 的加分项。

---

## 二、现有笔记 / Markdown 类 MCP server 全扫描（逐个列暴露能力）

> 说明：以下能力名尽量用各仓库/文档里的**真实 tool 名**；同一 app 常有多个第三方实现，能力有差异。这是「它们暴露了什么」的横向普查，不是产品评测（评测归 18 号）。

### 2.1 官方 filesystem 参考实现（`@modelcontextprotocol/server-filesystem`，MIT）

MCP 官方参考 server，最能代表「通用文件读写」基线。暴露 tools：`read_file`、`read_multiple_files`（批量，比逐个高效）、`write_file`（整文件覆盖，危险）、**`edit_file`（行级选择性编辑，返回 git 风格 diff——「只改三行不动其余」）**、`create_directory`、`list_directory`、`list_directory_with_sizes`、`directory_tree`、`move_file`、`delete_file`、`get_file_info`、`search_files`、`list_allowed_directories`。作用域靠命令行参数或 **Roots** 限定（sandbox），**默认非只读**（能写/覆盖/移动）。它给 tool 打了 read-only / idempotent / destructive 提示。**要点**：`edit_file` 是行级 + 模式匹配，不是语法树级——这是全行业的通病。

### 2.2 Obsidian 家族（多实现，均依赖 Local REST API 社区插件）

- **MarkusPfundstein/mcp-obsidian**（最流行）：`list_files_in_vault`、`list_files_in_dir`、`get_file_contents`、`search`（全库文本查询）、**`patch_content`（相对某标题/块引用/frontmatter 字段插入内容）**、`append_content`（追加到新/现有文件）、`delete_file`。
- **cyanheads/obsidian-mcp-server**（14 个 tool，功能最全，STDIO 或 Streamable HTTP）：readers 取笔记/元数据、writers 创建或**外科式编辑**、managers 调和 tags/frontmatter，外加一个受控的「命令面板派发」逃生口。搜索 tool 名 `obsidian_search_notes`，支持三模式：text / JSONLogic / **BM25 排序的 Omnisearch**。
- **coddingtonbear/obsidian-local-rest-api（插件内置 MCP server）**：官方插件现已自带 MCP server（端点 `/mcp/`，**Streamable HTTP + API key**），跑在 Obsidian 内、直接拿到活动文件、周期笔记、命令面板等**实时元数据**——这是 Obsidian 阵营里最接近「活动状态」的实现。搜索端点：`/search/simple`（内置模糊搜索，返回文件名+评分片段）、`/search/`（JsonLogic 表达式对每篇的 frontmatter/tags/path/content 求值）。
- **PublikPrinciple/obsidian-mcp-rest**：`listNotes`、`readNote`、`writeNote`、`searchNotes`、`getMetadata`。
- **j-shelfwood/obsidian-local-rest-api-mcp**：`get_note`、`list_notes`、`get_metadata_keys` 等，搜索支持 scope（content/filename/tags）+ path_filter 的**范围化检索**。
- **jacksteamdev/obsidian-mcp-tools**：语义搜索 + 自定义 Templater prompts。

### 2.3 Bear 2.8（官方内置，2026-04，macOS-only）

Bear 一次性给了三件套（08、13 号文档已提及，此处列 MCP 能力）：**BearCLI**（捆绑在 app 内的命令行，暴露每个笔记操作：`search`、`read`、`create`、`append`、`tag`、`pin`、`attach`、`archive`、`trash`）、**Claude Connector**（一键装，本质是 BearCLI 之上的 Claude 集成）、**MCP Server**（`bearcli mcp-server`，给 Claude Code/IDE 等 MCP 客户端；client 连上后发现全部操作：search/read/create/tag…）。全部**本地**读写 Bear 数据库；**不 opt-in 不连接、无批量上传**，Agent 只看到某次查询返回的笔记；**加密笔记可列出但永不被读/改**；可用 tags 做可见性控制（**Only tags / Exclude tags**，如把 `private` 加入 Exclude）。**这是与我们定位最接近的官方先例**——原生 app 内置 MCP server + 一个 CLI 作为统一底座。

### 2.4 Basic Memory（basicmachines-co，MCP 原生的本地 Markdown 知识图谱）

不是「给已有 app 加 MCP」，而是**为 MCP 而生**的本地 Markdown 知识库——最值得深挖的能力样本。它把纯 Markdown 里的模式抽成语义：文件=Entity、每个 Entity 有 Observations（事实）、Relations 连接实体成**知识图谱**，用 SQLite 做索引、`memory://` URL 跨工具引用实体、文件↔图谱双向同步。tools（分组）：
- 内容：`write_note`（防误覆盖）、`read_note`、`edit_note`（增量编辑：append/prepend 等，缺失时自动建）、`move_note`（保持 DB 一致）、`delete_note`、`read_content`（读原始文本/图片/二进制）、`view_note`（渲染为工件）。
- 搜索发现：`search`、`search_notes`、**`recent_activity`（按时间线找最近更新）**、`list_directory`。
- **知识图谱：`build_context`（沿 `memory://` URL 按可配深度遍历关系图）**、`canvas`（生成 Obsidian canvas）。
- 项目：`list_memory_projects`、`create_memory_project`、`get_current_project`、`sync_status`。
- Schema：`schema_infer`、`schema_validate`、`schema_diff`。

关键工程点：升级到 **FastMCP 3.0 + tool annotations**，每个 tool 都带 `readOnlyHint`/`destructiveHint`/`idempotentHint`/`openWorldHint`，让 Agent 渐进发现、不靠猜、不烧 token——这是我们该照抄的规范。

### 2.5 Logseq（多实现，依赖 Logseq HTTP API）

- **apw124/logseq-mcp**：`logseq` 命名空间下 `get_all_pages`、`get_page`、`create_page`、`delete_page` 及块级操作；**journal 页只要按日期格式建即自动标记**。
- **dailydaniel/mcp-server-logseq**（PyPI）：`logseq_insert_block`（父块/页 + 内容）、`logseq_edit_block`、`logseq_create_page`（可 `journal:true`）。
- **griederer/logseq-mcp-tools**：`create_page`、`insert_block`、`search`、**`create_journal_page`**、`get_todos`（按状态分组）、`update_block`（改 TODO 状态）、`set_page_property`/`get_page_properties`。
- **joelhooks/logseq-mcp-tools**（分析向）：除 CRUD 外，**汇总某日期区间的 journal**、**找引用某页的所有页（反链）**、跑 DataScript 自然语言查询、分析图谱找缺口/建议连接。
- **ergut/mcp-logseq**：`list_pages`、`get_page_content`、`search`、`query`，加**可选本地/OpenAI 兼容 embedding 的语义向量搜索**与 DB-mode 支持。

### 2.6 Apple Notes（多实现，AppleScript/JXA + 可选直读 SQLite）

- **sweetrb/apple-notes-mcp**：AppleScript + 直读 NoteStore SQLite（拿 AppleScript 拿不到的：pin 状态、checklist 标记、废纸篓/恢复态、预览片段、密码提示）。已知 Apple 限制：**AppleScript 无法创建真正的 Apple Notes checklist**。
- **taylorarndt/apple-notes-mcp**：`search`、`read`、`create`、`update`、`move`、`delete`；列账户/文件夹；跨账户移动用 copy-then-delete 规避 Core Data 报错。
- **PsychQuant/che-apple-notes-mcp**（Swift，双轨）：**24 个 tool**（folders、notes CRUD、search、batch、分享可见性、undo/redo）；**SQLite 直读 1000+ 笔记 <10ms、AppleScript 写 ~50ms/次**（写 SQLite 会毁 CloudKit 同步，故写全走 AppleScript）；无 Full Disk Access 时读自动回退 AppleScript。
- **Dan8Oren/mcp-apple-notes**：JXA + **语义搜索**：`index-notes`（先建本地语义索引）、`list-folders`、`list-notes`、`search-notes`（语义+全文混合）、`get-note`、`create-note`；全本地无 API key。

### 2.7 Joplin（alondmnt/joplin-mcp，FastMCP + joppy，经 Web Clipper 本地 HTTP API）

**25 个 tool**，覆盖 notes/notebooks/tags 的 CRUD + 搜索 + 废纸篓 + 文件导入（MD/HTML/CSV/JEX）：`find_notes`、`create_note`、`update_note`、`edit_note`、`delete_note`；notebook 四件套；tag 五件套（含 `get_tags_by_note`）；`import_from_file`。**安全设计值得抄**：**notebook allowlist**（基于模式的访问控制，只有匹配的 notebook 可见，`find_notes` 结果按可访问性过滤，被挡时报通用「Notebook not accessible」不泄露名字/ID）；**每个 tool 可用环境变量 `JOPLIN_TOOL_<NAME>=true|false` 单独开关**。

### 2.8 markdownify / markitdown 类（「万物转 Markdown」）

- **zcaceres/markdownify-mcp**：把 PDF/图片/音频/网页/YouTube 等转 Markdown，如 `youtube-to-markdown`、`get-markdown-file`。
- Microsoft **markitdown** 亦有 MCP 封装。这类属「输入侧机械转换」（路线 A），深入归 14 号；MCP 维度上它们是纯 Tools、无状态、无 vault 概念。

### 2.9 VMark（xiaolai，编辑器自带 MCP server，08 号文档重点）

Tauri 桌面 Markdown 编辑器，**原生内置 MCP server**（仓库内有 `vmark-mcp-server/` 与 `.mcp.json`），Settings → Integrations 一键为每个助手安装，官方支持 Claude Desktop / Claude Code / Codex CLI / Gemini CLI 直接连入读写当前文档。**其具体暴露的 tool 名未见公开文档**（需读源码）——但定位与我们完全一致：**「人与 AI 共读写同一批纯文本」，AI 集成是协议而非聊天框**。这是最直接的原型，也是竞争窗口的警报。

### 2.10 NoteGen（codexu/note-gen，Tauri，跨平台 AI 笔记）

**主要作为 MCP client**：支持连接外部 MCP server 做高级工作流，并把重复流程做成 Skills；AI 直接读当前笔记与本地笔记做改写/检索/整理（capture → 本地 Markdown → AI）。**其是否/如何内置对外 MCP server、暴露哪些 tool，未见公开文档**（写「未知」，不臆测）。它给我们的启示是「编辑器也可以是 client」（见第四章 4.2）。

### 2.11 IDE 侧对照：JetBrains 内置 MCP server（给我们「活动编辑器状态」的范本）

笔记类 server 全是「无头」的，**唯有 IDE 侧把活动编辑器状态做成了 MCP 能力**，这正是我们要学的差异点。JetBrains IDE 内置（默认开启）的 MCP server 暴露（据官方文档与 Docker MCP 目录）：返回**所有打开中的编辑器**文件路径、取**当前活动文件的绝对路径**、取**当前活动文件的完整内容**、取**当前选中文本**，以及**替换当前选区**的写 tool；可在 Settings | Tools | MCP Server | Exposed Tools 里逐个开关。此外 Claude Code 的 JetBrains 插件跑一个名为 `ide` 的本地 MCP server，自动把**当前选区 + 活动文件路径**作为上下文注入每次 prompt，并在 IDE 原生 diff viewer 里开 diff。

> 结论先行：笔记 app 的 MCP server ≈「文件系统 + 搜索 + 标签」；IDE 的 MCP server 才有「活动文档/选区」。我们是编辑器，**应当两者都要**——把「无头文库访问」和「活动编辑器状态」在同一个 server 里合并暴露。

---

## 三、归纳：最常暴露的能力集合与明显空白

### 3.1 能力矩阵（横向普查）

| 能力 | filesystem | Obsidian | Bear | Basic Memory | Logseq | Apple Notes | Joplin | JetBrains(IDE) |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| search（全文/文件名） | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| read note | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅(活动文件) |
| create note | ✅(write) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| append | — | ✅ | ✅ | ✅ | ✅(block) | 部分 | ✅ | — |
| 外科式编辑（按标题/块） | 行级 | ✅(patch) | — | ✅(edit_note) | ✅(block) | — | ✅(edit) | 替换选区 |
| **结构化/AST 编辑** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| list / 目录树 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅(folders) | ✅ | ✅(open editors) |
| list recent（按日/时间线） | — | — | 部分 | ✅ | ✅(journal) | — | — | — |
| backlinks / 反链 | — | 部分 | — | ✅(graph) | ✅ | — | — | — |
| by-tag / 标签管理 | — | ✅ | ✅ | ✅(frontmatter) | ✅(property) | — | ✅ | — |
| metadata / frontmatter | ✅(info) | ✅ | — | ✅ | ✅ | ✅(SQLite) | ✅ | — |
| move / rename（修引用） | ✅(move) | — | — | ✅ | — | ✅(copy-del) | — | — |
| delete / trash | ✅ | ✅ | ✅(trash) | ✅ | ✅ | ✅ | ✅(trash) | — |
| 语义 / 向量搜索 | — | 部分 | — | — | 部分 | 部分 | — | — |
| 命令面板 / 执行命令 | — | ✅(逃生口) | — | — | — | — | — | ✅ |
| **活动文档 / 选区** | ❌ | 部分(内置插件) | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| tool annotations（hint） | ✅ | 部分 | — | ✅(FastMCP3) | — | — | — | 部分 |
| 用 Resources 原语 | 少 | 少 | — | 少 | — | — | — | — |
| 用 Prompts 原语 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

### 3.2 最常暴露的能力集合（「行业公约」）

几乎每个 server 都提供、我们必须对齐的**基线七件套**：`search`、`read`、`create`、`append`、`list`、`delete/trash`、`metadata/tags`。较成熟的再加：外科式编辑（按标题/块）、`move/rename`、`recent/by-date`、`backlinks`、语义搜索。安全上的成熟做法：**作用域限定**（Roots / allowlist / Only-tags）、**逐 tool 开关**、**tool annotations 打 hint**、**跳过加密/私密内容**。

### 3.3 明显空白（= 我们的机会）

1. **没有人做基于语法树的结构化编辑。** 现状是 `write_file`（整篇覆盖，最危险）、行级 `edit_file`、或按标题/块的 `patch`。**无一按 Markdown AST 节点 + SourceRange 精确定位与改写**。我们有 swift-markdown 的不可变值类型 AST + 精确 SourceRange + Visitor/Rewriter（09 号文档），可以做 `apply_edit`：以「第 2 个二级标题下那段有序列表的第 3 项」这种**结构坐标**定位，改完仍是合法 Markdown，并可做 **AST 等价性/合法性校验**（13 号 mdformat 思路）后才落盘——这是裸文本 diff 给不了的安全性与精度。
2. **没有笔记 server 暴露活动编辑器状态。** 「用户此刻在编辑哪篇、选中哪段、光标在哪」只有 IDE 侧有。这是编辑器的独占资产：让 Agent「润色我选中的这段」「在我光标处插入表格」「解释当前文档」，且改动**即时渲染**（VMark 已证明可行）。
3. **Prompts 原语几乎全行业闲置。** 上面所有 server 都只堆 Tools，无一暴露 Prompts。而 Prompts 恰是「把用户高频 AI 操作固化成可发现、参数可补全的 slash 命令」的官方通道——`/weekly-digest`、`/spec-from-notes`、`/turn-into-table` 直接出现在 Claude Code/Desktop 的命令里。零竞争。
4. **Resources 原语用得极少。** 大家把「读文档」也做成 Tool，却很少用 Resources 把「当前文档/文库结构/选区」作为**可订阅的上下文**暴露给宿主自动注入。Resources + `subscribe`/`updated` 天生适合「随用户操作实时变化的编辑器状态」。
5. **确认交互没有协议化。** 写/删普遍靠「客户端自己弹确认」，没人用 **Elicitation** 在 server 侧发起「要不要应用这处改动？」的结构化确认，更没人用 **MCP Apps** 渲染 diff 预览卡片。我们可以把「diff 预览 + 逐块接受/拒绝 + 一键回滚」做成 server 侧的一等交互。
6. **`get_outline`（大纲/TOC）几乎无人做成一等 tool。** Agent 要理解长文结构只能读全文烧 token；一个返回结构化标题树的 tool（配 `outputSchema`）能大幅省 token、提升定位精度。

---

## 四、我们是 server 还是 client：角色厘清

### 4.1 主要角色：**server**——把「文库 + 活动编辑器状态」暴露给外部 Agent

这是路线 B 的核心，也是 08/13 号文档 AI 分层的「第 2 层（协议层）」。我们不承担推理成本、不背隐私责任，复用用户已付费的 Claude Code / Cursor / Claude Desktop / Codex。相对所有竞品的差异化是**同一个 server 同时暴露两类能力**：
- **无头文库访问**（对齐笔记类 server 的基线七件套 + 结构化编辑）；
- **活动编辑器状态**（对齐 IDE 的 active file / selection，且改动即时渲染）。

### 4.2 次要角色：**client**——编辑器自身 AI 侧栏消费外部 MCP server

08/13 号文档规划的「BYOK 对话侧栏 / 相关笔记 / RAG」这一层，其内部实现可以让**我们的 app 作为 MCP client** 去连外部 server（如 filesystem、web fetch、用户自己的工具），给自带 Agent 扩能力。NoteGen 就是这么用 MCP 的（2.10）。但这属于「我们自建 AI 功能」的范畴，与路线 B 的「不自建、只做界面」有张力——**建议 client 角色仅作可选项、后置**，优先把 server 角色做深做对。

### 4.3 传输与部署形态（关键决策）

三种可选形态，推荐组合：

| 形态 | 机制 | 优点 | 缺点 |
|---|---|---|---|
| **A. stdio launcher（推荐主路径）** | 随 app 分发一个轻量 helper 二进制（类 `bearcli mcp-server`），Agent 以子进程 stdio 启动它；helper 经本地 IPC 与运行中的 app 通信以拿到活动状态，app 未开时可退化为直接读 vault 文件 | 客户端兼容性最好（Claude Code/Cursor/Codex 默认 stdio）；无端口、无鉴权复杂度；符合规范「优先 stdio」 | 需维护 helper↔app 的 IPC；stdout 必须干净 |
| **B. localhost Streamable HTTP（可选备胎）** | app 自身在 `127.0.0.1` 起一个 MCP 端点（类 Obsidian Local REST API 的 `/mcp/`），用本地 bearer token 鉴权 | app 即 server，活动状态最自然；给只会 HTTP 的客户端 | 需管端口/token；跨机暴露要极谨慎 |
| C. 纯文件访问（兜底） | 不跑 server，仅靠通用 filesystem MCP 指向 vault | 零成本 | 丢掉活动状态与结构化编辑等全部差异化 |

**推荐**：以 **A（stdio launcher）为主**、**B（localhost HTTP）为可选**；**C 不作为我们的方案**（那等于放弃差异化）。鉴权按 1.6：stdio 用 app 原生同意 + 作用域，不上 OAuth；localhost HTTP 用本地 token。**默认不跨机远程暴露**，远程访问为显式 opt-in 的高级项。

---

## 五、安全 / 权限模型：Agent 写你的文件需要什么

### 5.1 威胁模型（2026 的共识）

- **Lethal trifecta（Simon Willison）**：当一个 Agent 同时具备①访问私有数据②接触不可信内容③对外通信能力时，就构成数据外泄原语。**我们的 server 提供的正是①（你的整个 vault）**。我们无法管住 Agent 的另两项（它读的网页、它的发信 tool），但**必须把①的爆炸半径压到最小**。
- **Tool poisoning / rug pull**：恶意 server 把指令藏在 tool description/metadata 里，或先发布干净 tool、后续静默更新为恶意。**我们是本体 app 分发的 server，tool 定义静态可控**——这条我们天然免疫，但要保证不动态从网络拉 tool 描述。
- **Confused deputy**：Agent 在其合法权限内被诱导做了部署者没打算让它做的事（如被文档里的注入指令诱导去读私密笔记并写进报告）。**最难防**，因为全在合法权限内——只能靠最小权限 + 逐操作确认 + 审计。
- **Prompt injection via 笔记内容**：用户 vault 里的 Markdown 本身可能含注入指令（尤其是从网上剪藏的）。我们把这些内容喂给 Agent 时，等于把不可信内容送进②。

### 5.2 我们的对策（工程化，呼应 13 号隐私红线）

1. **作用域最小化**：server 只在用户**显式选定的 vault 文件夹**内工作；尊重 client 传来的 **Roots**；提供文件夹级 **allowlist/denylist** 与**标签级 exclude**（照抄 Bear 的 Only-tags/Exclude-tags、Joplin 的 notebook allowlist）。默认排除 `.git`、`.env`、密钥类文件与**加密/受保护笔记**（Bear：加密笔记可列不可读）。
2. **读写分级 + 破坏性操作确认**：给每个 tool 打 **annotations**（`readOnlyHint`/`destructiveHint`/`idempotentHint`）。读类在作用域内可默许；**写/移动/删一律要确认**。确认走 **Elicitation**（server 侧发起结构化确认）或 app 原生对话；删除**默认进废纸篓不硬删**（13 号红线：绝不永久删）。
3. **结构化编辑降低误伤**：`apply_edit` 走 AST 而非盲覆盖，落盘前做**合法性/等价性校验**；每次写都产出**可预览 diff**，用户可逐块接受/拒绝。
4. **会话级 checkpoint + 撤销**：一次 Agent 会话开始前打**检查点**（对接 13 号的版本历史/内置 Git），整段会话可**一键回滚**；配合编辑器自身的自动保存与文件系统版本历史。
5. **全量审计日志**：记录每一次 `tools/call`（谁、何时、改了哪篇、diff 摘要），规范也建议为审计而 log。
6. **只读模式开关 + 逐 tool 开关**：一个全局「AI 只读」总闸；每个 tool 可单独禁用（Joplin `JOPLIN_TOOL_<NAME>` 模式）。
7. **不做 token passthrough、不跨机默认暴露、localhost token 短时有效**：若启用 HTTP 形态，严格遵循 1.6。
8. **人在环路是硬要求而非 SHOULD**：规范只说「SHOULD 有人在环」，我们把**敏感/不可逆操作的人工确认设为强制**（社区对 spec 用词过弱的批评是对的）。

### 5.3 确认交互的形态

- 基线：**Elicitation** 弹原生确认（显示是哪个操作、影响哪篇、diff 摘要，提供拒绝/取消）。
- 进阶（V2+）：用 **MCP Apps** 在 Agent 对话里直接渲染一张**沙箱 iframe 的 diff 预览卡片 / 大纲导航 / 表格编辑器**，逐块接受——把「diff 预览后应用」（08 号交互清单第 13 项）做成协议级、跨客户端的一等体验。

---

## 我们 MCP server 的接口草案

> 设计原则：①**三原语齐用**（不像同行只用 Tools）；②所有 tool 打全 **annotations**（读/写/破坏/幂等 hint，照 Basic Memory FastMCP 3.0）；③读多篇/列结构类返回 `structuredContent` + `outputSchema`；④搜索结果用 `resource_link` 指向 `note://` 省 token；⑤写类默认走确认 + diff + 可回滚；⑥**编辑写操作一律基于 swift-markdown 的 AST/SourceRange**，而非裸文本替换（09、13 号）。命名可直接作为设计起点。

### Tools（模型可调用的动作）

**发现 / 读取（read-only）**
- `search_notes(query, scope?, tags?, path?, limit?)` — 全文/文件名/标签范围检索，返回命中片段 + `resource_link`（对齐行业基线，融合 j-shelfwood 的 scope 化搜索）。
- `read_note(path|id, range?)` — 读整篇或指定行/节范围。
- `read_multiple_notes(paths[])` — 批量读取（filesystem 的效率教训）。
- `get_outline(path)` — 返回文档标题层级树/TOC（`outputSchema` 结构化，基于 AST；填补行业空白，省 token）。
- `list_notes(folder?, recursive?, sort?)` — 列目录/文库结构。
- `list_recent(timeframe?, limit?)` — 按最近修改列出（Basic Memory `recent_activity`）。
- `get_backlinks(path)` — 反向链接列表（wiki 链接图，对接 13 号反链面板）。
- `get_note_metadata(path)` — frontmatter / 标签 / 字数 / 时间戳（`outputSchema`）。
- `semantic_search(query, limit?)` — 本地 embedding 语义检索（V2，对接 13 号相关笔记/RAG；本地向量库如 LanceDB）。

**写入 / 编辑（需确认 + diff）**
- `create_note(path, content, frontmatter?)` — 新建；已存在则报错防误覆盖（Basic Memory `write_note` guard）。
- `append_to_note(path, content, section?)` — 追加，可指定到某标题节末尾。
- **`apply_edit(path, edits[])`** — **核心差异化**：基于语法树节点/SourceRange 的结构化替换/插入/删除；落盘前做 Markdown 合法性/AST 等价校验；返回 diff。
- `insert_at_heading(path, heading, content, position)` — 在指定标题下插入（Obsidian `patch_content` 的语义化、AST 化版本）。
- `set_frontmatter(path, kv)` / `add_tags(path, tags)` / `remove_tags(path, tags)` — 元数据/标签管理。
- `move_note(from, to)` / `rename_note(path, newName)` — 移动/重命名并**自动修复全库 wiki 链接引用**（13 号 Marksman 语义）。
- `delete_note(path, toTrash=true)` — 删除，默认进废纸篓（destructiveHint，不硬删）。

**机械转换（路线 A 的轻量能力，深入归 14 号）**
- `format_note(path)` — 保存即格式化（表格对齐、列表规整），AST 等价校验。
- `convert_to_markdown(source)` — 粘贴/文件转 Markdown（markdownify 类）。

**活动编辑器（IDE 范本，笔记 app 空白区）**
- `get_active_note()` — 当前正在编辑的文档路径 + 内容。
- `get_selection()` — 当前选区文本 + 结构范围（含所属标题/行号）。
- `replace_selection(content)` — 替换选区（diff 预览 + 确认，即时渲染）。
- `apply_edit_to_active(edits[])` — 对活动文档做结构化编辑并即时渲染。
- `open_note(path, reveal_heading?)` — 在编辑器中打开/定位到某文档或标题。

### Resources（应用提供的、可订阅的只读上下文）

- `note://{path}`（**resource template**，路径可经 completion 补全）— 单篇文档内容。
- `editor://active` — 当前活动文档；**可 `subscribe`**，随用户切换/编辑推送 `updated`。
- `editor://selection` — 当前选区；**可 `subscribe`**，随选择变化推送。
- `vault://structure` — 当前文库的目录/大纲树（供宿主自动注入上下文）。
- `vault://recent` — 最近文档列表。
- `vault://tags` — 标签索引。
- `outline://{path}` — 某文档的结构化大纲。
- （用 `file://` 或自定义 scheme；`annotations` 带 `lastModified`/`priority`/`audience`。）

### Prompts（用户触发的模板化 slash 命令，全行业空白）

- `/summarize-note` — 总结当前/指定文档（参数：note，可补全）。
- `/polish-selection` — 按项目写作规范润色选区。
- `/make-toc` — 为当前文档生成目录。
- `/extract-tasks` — 从文档抽取待办为任务清单。
- `/weekly-digest` — 汇总本周笔记（Logseq/Bear 的按日聚合语义）。
- `/spec-from-notes` — 把散记整理成规格文档（面向开发者：CLAUDE.md/AGENTS.md/spec 场景，路线 B 的招牌用例）。
- `/turn-into-table` — 选中文本转 Markdown 表格（路线 A 机械活）。
- （参数经 completion API 补全，如 note 路径、标题；`prompts/get` 返回含内嵌 resource 的 messages。）

---

## 参考来源（一手，2026-07 访问）

- MCP 规范 2025-11-25：Tools / Resources / Prompts / Transports / Authorization（modelcontextprotocol.io/specification/2025-11-25/...）
- MCP Registry 预览公告（blog.modelcontextprotocol.io，2025-09-08）
- MCP Apps SEP-1865（blog.modelcontextprotocol.io 2026-01-26；github.com/modelcontextprotocol/ext-apps）
- 官方 filesystem server（github.com/modelcontextprotocol/servers/tree/main/src/filesystem）
- Obsidian：MarkusPfundstein/mcp-obsidian、cyanheads/obsidian-mcp-server、coddingtonbear/obsidian-local-rest-api（内置 MCP）
- Bear 2.8：blog.bear.app/2026/04/bear-2-8-bearcli-claude-connector-and-mcp-server/
- Basic Memory：github.com/basicmachines-co/basic-memory、docs.basicmemory.com
- Logseq：apw124/logseq-mcp、dailydaniel/mcp-server-logseq、griederer/logseq-mcp-tools、ergut/mcp-logseq
- Apple Notes：sweetrb、taylorarndt、PsychQuant/che-apple-notes-mcp、Dan8Oren/mcp-apple-notes
- Joplin：github.com/alondmnt/joplin-mcp
- JetBrains MCP：jetbrains.com/help/idea/mcp-server.html
- 安全：Simon Willison「lethal trifecta」、OWASP MCP Security Cheat Sheet、MCP Security Best Practices
- markdownify：github.com/zcaceres/markdownify-mcp；VMark：github.com/xiaolai/vmark；NoteGen：github.com/codexu/note-gen
