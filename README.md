# 本地知识库

这是一个由 Codex 维护、可用 Obsidian 浏览的本地知识库。它遵循「原始资料 → 结构化 Wiki → 维护规则」的三层模式；所有内容均为普通文件，适合 Git 版本管理与跨设备迁移。

## 日常使用

1. 把新资料放进 `raw/inbox/`（不要直接修改已有的归档资料）。
2. 对 Codex 说：「收录 `raw/inbox/文件名` 到知识库」，并说明希望重点关注什么（如无说明，我会提炼核心观点、事实、关系和不确定性）。
3. 我会把资料归档到 `raw/sources/`，创建/更新 `wiki/` 页面、`wiki/index.md` 与 `wiki/log.md`。原始资料始终保留并作为引用依据。
4. 定期说：「对知识库进行 lint 审查」。先运行 `tools/lint.ps1`，再由我审阅语义问题并修复经你确认的内容。

完整规则见 [AGENTS.md](AGENTS.md)。

## 打开与迁移

- 用 Obsidian 直接“打开文件夹作为仓库”：`D:\AIKarpathyWorkSpace`。
- 此目录已经是 Git 仓库后，建议定期提交并推送至你自己的私有远端；迁移时克隆仓库即可。
- 若资料含隐私或大文件，请在提交/同步前审查 `raw/`；本系统不自动上传任何内容。

## 目录

- `raw/`：原始资料，按规则只读、不可由我修改。
- `wiki/`：可持续演进的 Markdown 知识图谱。
- `tools/`：本地维护工具；当前包括结构 lint。
- `AGENTS.md`：Codex 的知识库 schema 与收录、查询、lint 工作流。

## 健康检查

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\lint.ps1
```

报告默认写入 `reports/`（该目录不会纳入 Git）。使用 `-NoReport` 可只在终端显示。Lint 检查结构、元数据、内部链接、索引一致性与来源引用；“矛盾、陈旧结论、缺失概念”等语义问题由 Codex 在 lint 审查中进一步检查。

