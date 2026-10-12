# 团队协同与 PR 审查测试用例文档

本文档用于测试 GitHub 仓库 `yvemiz/sanjiaozhou` 的分支保护与代码审查规则（Rulesets）。

## 测试目标
1. 验证团队成员在特性分支（`feature/*`）开发后的推送能力。
2. 验证目标分支为 `main` 时，GitHub 是否强制要求至少 1 位有权限的审批人通过 Pull Request (PR) 审批。
3. 验证未获批准前，主分支处于受保护状态。
