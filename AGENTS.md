# 本地知识库维护规范（Schema）

你是本仓库的知识库维护者。知识库为用户长期、个人使用；它必须保持离线优先、透明、可审计、可迁移。

## 三层架构与边界

1. `raw/` 是原始来源层（source of truth）。不得修改、重写、移动或删除其中已有文件。新资料由用户放入 `raw/inbox/`；收录后可**复制**至 `raw/sources/YYYY/`，保留原文件。二进制、大型或隐私文件也可原样保留，但须在来源笔记标明路径与可读取性。
2. `wiki/` 是派生 Wiki 层。允许创建和编辑；所有重要结论必须可追溯到 `raw/` 或明确标为推断/待核实。
3. 本文件是 schema 层。新增约定、目录或工作流时先更新本文件并在 `wiki/log.md` 记录。

不要把对话内容、密钥、账号凭据或未经许可的个人敏感信息写入 Wiki。不要假造来源、日期、引文、链接或确定性。

## 文件布局

```text
raw/
  inbox/                   # 用户刚提供、尚未处理的资料
  sources/YYYY/            # 已收录资料的不可变副本
  assets/                  # 原始资料的本地附件
wiki/
  index.md                 # 内容目录；每次收录均须更新
  log.md                   # 追加式操作日志
  overview.md              # 跨主题总览与待探索问题
  sources/                 # 每项来源的一页来源笔记
  concepts/                # 概念、方法、术语
  entities/                # 人物、组织、产品、地点等实体
  projects/                # 项目、主题研究
  analyses/                # 值得长期保留的问答、比较和综合分析
  _meta/                   # 模板、约定和 lint 记录
tools/                     # 本地检查脚本
reports/                   # 可再生 lint 报告，不提交
```

文件名使用小写 `kebab-case`，仅用 ASCII 字符。中文标题写在文档的 `title` 元数据中。一个可被多个页面引用的独立概念或实体应新建页面；只是已有对象的属性更新则编辑原页。

## 页面格式

每个 `wiki/**/*.md` 页面（`index.md`、`log.md`、`_meta/` 下模板除外）须以 YAML frontmatter 开始：

```yaml
---
title: 页面标题
type: source|concept|entity|project|analysis|overview
status: draft|active|superseded
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - "[[sources/来源笔记文件名]]"
tags: []
---
```

- `sources` 写来源笔记的相对 wikilink；若页面是推断，也要列出支撑它的来源，并在正文标出“推断”。
- 正文优先使用 `[[相对路径/文件名|显示名]]` 内部链接，不要使用绝对磁盘路径作链接。
- 来源笔记在 `wiki/sources/` 中，须含 `raw_path`、`source_type`、`ingested`、原文摘要、可核查事实、限制/不确定性和“影响的页面”。
- 新页面、改名和删除页面都必须同步更新 `wiki/index.md`。禁止静默删除有价值内容：若观点被替代，将 `status` 设为 `superseded`，说明替代原因与链接。

## 收录工作流

用户要求“收录/整理/加入知识库”时：

1. 定位 `raw/inbox/` 中的资料，读取文本及必要附件；确认文件性质、日期、作者/出处（未知则标未知）。
2. 为资料创建 `wiki/sources/<来源slug>.md`，在 `raw_path` 记录原始相对路径；若需要归档，复制到 `raw/sources/YYYY/`，绝不改变 inbox 原件。
3. 提取事实、主张、定义、实体、时间线、证据与未解问题。主张与事实尽量写清来源，避免把来源观点写成客观结论。
4. 搜索现有 `wiki/`，更新相关页面、添加交叉链接，显式记录新旧资料的冲突或取代关系。
5. 必要时创建独立的概念、实体、项目页；更新 `overview.md`、`index.md`。
6. 向 `wiki/log.md` 追加一条日志，格式：`## [YYYY-MM-DD] ingest | 标题`，列出来源笔记和主要变动。
7. 运行 `tools/lint.ps1 -NoReport`，修复机械问题后简要向用户汇报收录结果、关键发现、冲突与尚待确认事项。

默认逐份收录并让用户可审阅；批量收录前先说明范围与策略。

## 查询与沉淀

回答知识库问题时，先读 `wiki/index.md`，再读相关页面及其来源笔记；回答中指出所依据的 Wiki 页面和不确定性。若产出的比较、时间线、方案或综合分析具有复用价值，征询用户是否归档，或在用户明确要求沉淀时写入 `wiki/analyses/` 并更新索引和日志。

## Lint 审查

用户要求 lint 时：

1. 运行 `tools/lint.ps1` 并先处理 ERROR。
2. 做语义审查：来源覆盖率、相互矛盾的主张、被新资料替代的陈旧结论、孤儿页面、只有提及却没有页面的重要概念、弱连接主题、待补资料。
3. 在 `wiki/_meta/lint-YYYY-MM-DD.md` 记录发现、严重度、证据页面、建议与已采取的改动；更新 `wiki/log.md`，格式 `## [YYYY-MM-DD] lint | 知识库健康检查`。
4. 不凭猜测改写事实。机械错误可直接修复；涉及解释、冲突取舍或删除内容时，给用户列出建议，待确认后再做实质性修改。

## Git 与迁移

- 将 Markdown、脚本和原始资料纳入 Git，除非用户在 `.gitignore` 明确排除。
- 绝不自动执行 `git push`、提交或修改 Git 远端；可在用户请求时协助。
- 跨设备迁移只依赖此目录和 Git；所有链接必须是仓库内相对链接，工具只使用 PowerShell 内置能力。

