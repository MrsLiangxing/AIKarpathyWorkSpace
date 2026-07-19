---
title: Codex 编程自定义指令
type: source
status: active
created: 2026-07-19
updated: 2026-07-19
sources: []
tags: ["codex", "工作方式", "编程"]
raw_path: raw/sources/2026/codex_programming_custom_instructions.txt
source_type: user-provided instruction file
ingested: 2026-07-19
---

# Codex 编程自定义指令

## 原始资料

- 原文件：`raw/sources/2026/codex_programming_custom_instructions.txt`
- 用户指定用途：Codex 自定义指令，适用于编程。

## 摘要

要求编程协作遵循“先理解需求、再小范围修改、最后验证结果”的方式：避免过度设计和无关改动；优先简单稳妥的方案；改动必须可追溯到当前任务；完成后说明改动、验证和风险。

## 可核查事实与主张

- 需求明确且风险低时直接执行；有歧义时说明理解并只问一个关键问题。
- 只实现当前所需内容，不为未提出的未来场景引入复杂架构、依赖或抽象。
- 保持现有代码风格，不顺手重构、改格式、改命名或删除未完全理解的代码。
- 修 bug 要复现、定位、小范围修复并验证；新增功能要说明入口和使用方式。
- 不在代码、测试、文档、日志、diff 或回复中暴露真实敏感信息。

## 限制与不确定性

这是用户的偏好与协作规范，不覆盖系统、开发者、仓库规则或安全规则；与更高优先级规则冲突时，应遵循更高优先级规则。

## 影响的页面

- [[concepts/codex-programming-style|Codex 编程工作方式]]

