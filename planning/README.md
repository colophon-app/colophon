# planning/ —— Colophon 的规划与执行文档

> 与 [`../docs/`](../docs/)（市场调研）区分：**`docs/` 是「别人怎么做的」，`planning/` 是「我们怎么做」。**

## 本文件夹里有什么

- **[PRD.md](PRD.md)** —— 产品需求：做什么、为什么、给谁、范围、定位、技术选型、开源运营。
- **[ROADMAP.md](ROADMAP.md)** —— 开发路线图：分几个阶段、每阶段目标与「完成定义」、每个排期决定的理由。
- **`M0/`、`M1/` …** —— 每个里程碑一个文件夹，**进入该阶段时才创建**（见下）。

## 每个里程碑文件夹的约定（`Mx/`）

进入某里程碑时，在 `planning/` 下建 `Mx/`，固化该阶段的全部执行信息。标准结构：

| 文件 | 内容 |
|---|---|
| `overview.md` | 从 PRD + ROADMAP 提炼出的该阶段**目标、范围（做/不做）、完成定义、依赖** |
| `research.md` | 针对本阶段具体工作的调研（用 workflow 跑）：**前人失败教训（要避开的坑）+ 优秀实践（要抄的做法）+ 本阶段需要的技术细节** |
| `plan.md` | 细化到可执行的**开发步骤 + 任务清单（`- [ ]` 复选框）+「注意事项 / 坑」小节**。越细越好 |
| `decisions.md`（可选） | 本阶段过程中做的决定及其理由（ADR-lite），随做随记 |

## 启动一个里程碑的流程

1. 读 [PRD.md](PRD.md) + [ROADMAP.md](ROADMAP.md)。
2. 把该阶段范围固化进 `Mx/overview.md`。
3. 跑一个**针对本阶段的调研 workflow** → `Mx/research.md`（失败教训 + 优秀实践 + 技术细节，尽量取一手来源）。
4. 细化成 `Mx/plan.md`（步骤 + 任务清单 + 注意事项）。
5. 执行；边做边勾 `plan.md` 的复选框、把决定记进 `decisions.md`。

## 两条原则（为什么这么做）

- **调研按需、逐阶段做，不一次性全做。** M0 的签名公证/CI 现在查最有用；M3 的细节现在查会浪费——工具在变、且我们会从 M0–M2 学到东西。每进入一个阶段，用最新信息查那个阶段。
- **我们的开发过程本身在 dogfood 路线 B。** 我们写 Markdown 计划/规格（`overview`/`plan`）指挥 Agent，Agent 产出 Markdown 调研（`research`）交我们审——这正是 [`../docs/17`](../docs/17-human-agent-workflows.md)、[`../docs/19`](../docs/19-route-b-blueprint.md) 里「人 ↔ Agent 的 Markdown 循环」。`plan.md` 的复选框、`research.md` 的 Agent 产出、`decisions.md` 的决策记录，都是产品未来要支持的真实工作流。**我们自己就是第一个用户。**
