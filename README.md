# 《三角洲行动》微信小程序接单与特战护航平台

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Vue](https://img.shields.io/badge/Vue.js-3.4+-4FC08D.svg)](https://vuejs.org/)
[![UniApp](https://img.shields.io/badge/UniApp-Vue3-2B9939.svg)](https://uniapp.dcloud.net.cn/)
[![Element Plus](https://img.shields.io/badge/Element%20Plus-2.6+-409EFF.svg)](https://element-plus.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1.svg)](https://www.mysql.com/)
[![Redis](https://img.shields.io/badge/Redis-7.0-DC382D.svg)](https://redis.io/)

一套专注于腾讯战术射击游戏**《三角洲行动》（Delta Force）**的微信小程序接单与特战护航服务平台。项目涵盖客户端微信小程序、移动端客服/打手端、PC端运营管理后台与PC端客服工作台，形成“客户下单、客服调度、特战干员护航、资金托管、完单结算、客诉仲裁”的完整业务闭环。

---

## 目录

- [一、业务定位与核心特色](#一业务定位与核心特色)
- [二、项目结构说明](#二项目结构说明)
- [三、环境要求](#三环境要求)
- [四、本地快速启动指引](#四本地快速启动指引)
  - [1. 数据库准备](#1-数据库准备)
  - [2. 后端服务启动 (`delta-game`)](#2-后端服务启动-delta-game)
  - [3. PC 管理端前端启动 (`delta-admin-ui`)](#3-pc-管理端前端启动-delta-admin-ui)
  - [4. 小程序端启动 (`delta-mp`)](#4-小程序端启动-delta-mp)
- [五、测试账号与登录凭证](#五测试账号与登录凭证)
- [六、项目代码提交与分支管理规范](#六项目代码提交与分支管理规范)
  - [1. 分支管理策略](#1-分支管理策略)
  - [2. 团队协同与 PR 提交流程](#2-团队协同与-pr-提交流程)
  - [3. Git Commit 提交信息规范](#3-git-commit-提交信息规范)
  - [4. 代码评审与合并准则](#4-代码评审与合并准则)
- [七、开源与授权说明](#七开源与授权说明)

---

## 一、业务定位与核心特色

平台彻底脱离传统通用代练的生搬硬套，全面贴合《三角洲行动》真实游戏玩法：

1. **四大核心战术板块深度适配**：
   * **烽火地带·护航摸金**：零号大坝、长弓溪谷、航天基地、巴克什、曼德尔砖争夺。保底带出 200W~1000W 哈夫币，干员自带全装进图清场。
   * **全面战场·段位冲榜**：特战统帅晋升冲榜、全兵种（突击/工程/支援/侦察）枪皮与熟练度快速挑战挑战。
   * **战术特训·车队连麦**：金牌特勤导师按小时组排，实时语音连麦报点、安全撤离路线教学与带打。
   * **特勤处·任务成就**：防空雷达、工作台、技术部门全套升级材料定向搜集与战役成就。
2. **四重履约保障体系**：
   * 🛡️ **纯手打承诺**：严禁任何第三方违规科技，保障账号安全。
   * 💼 **掉装全额包赔**：意外撤离失败，由平台和干员共同包赔装损或全额补打。
   * 💰 **未达保底补打**：哈夫币或曼德尔砖未达成约定目标，不计入完成。
   * 🔒 **平台资金托管**：老板确认安全撤离后方予结算分账，避免跑单纠纷。
3. **低耦合动态表单引擎**：
   * 各地图战区支持独立配置动态表单（登录平台 WeGame/Steam/iOS/安卓、游戏大区、角色名/纯数字ID、战备方案、预期保底收益、连麦开麦方式等），父分类字段自动向下继承。
4. **多端权限隔离与协同**：
   * 微信小程序端：老板端、认证干员端（抢单/提交进度/收益提现）、移动客服端（现场调度/客诉调解）。
   * PC 端：超级管理员总控台（商品配置/分类树/财务审核/干员入驻审批）与专职客服协同工作台。

---

## 二、项目结构说明

```text
├── delta-game/                     # 后端工程 (Spring Boot 3.2+ Maven 多模块)
│   ├── delta-admin/                # 管理端与主启动入口 (端口 8081)
│   ├── delta-common/               # 通用工具类、统一响应、基础常量
│   ├── delta-cs/                   # 客服工作流与协同模块
│   ├── delta-message/              # 消息通知、系统广播、订阅消息
│   ├── delta-order/                # 订单生命周期与状态机
│   ├── delta-pay/                  # 微信支付、余额支付、退款与资金托管
│   ├── delta-player/               # 特战干员资质认证、档案与接单控制
│   ├── delta-product/              # 商品库、战区分类树、动态表单引擎
│   ├── delta-system/               # 系统配置、数据字典、操作日志
│   ├── delta-user/                 # 用户鉴权、个人资料管理
│   └── pom.xml                     # Maven 根配置
│
├── delta-mp/                       # 前台小程序工程 (UniApp Vue 3 + Vite)
│   ├── pages/                      # 用户端核心页面 (首页/分类/详情/下单/我的)
│   ├── pages-cs/                   # 移动客服端页面 (工作台/订单/工单调解/干员)
│   ├── pages-player/               # 特战干员端页面 (接单大厅/履约/认证入驻)
│   ├── components/                 # 战术 HUD 卡片、导航栏等公共组件
│   └── uni.scss                    # 三角洲行动战术琥珀金/深蓝黑主题样式
│
├── delta-admin-ui/                 # PC 管理后台工程 (Vue 3 + Vite + Element Plus)
│   ├── src/views/                  # 运营总控看板、商品、分类、订单、干员、提现等
│   └── src/router/                 # 路由定义与基于角色的动态鉴权守卫
│
├── docs/                           # 项目设计文档、部署指引与配置手册
├── delta_game.sql                  # 基础数据库建表脚本
├── setup_delta_force.sql           # 三角洲行动专用战区、商品与表单配置脚本
├── seed_delta_demo_data.sql        # 演示用特战干员、订单流水与测试数据
└── README.md                       # 项目主说明文档
```

---

## 三、环境要求

| 组件 | 最低版本要求 | 推荐配置 |
| :--- | :--- | :--- |
| **Node.js** | `>= 18.18.0` | Node.js 20 LTS (包含 npm / pnpm) |
| **Java JDK** | `>= 17` | OpenJDK 17 或 Temurin 17 |
| **Maven** | `>= 3.8.0` | Apache Maven 3.9+ |
| **MySQL** | `>= 8.0` | MySQL 8.0+ (字符集: `utf8mb4`) |
| **Redis** | `>= 7.0` | Redis 7.0+ (内存缓存与即时消息支撑) |
| **微信开发者工具** | 最新稳定版 | 用于导入编译后的小程序产物真机预览 |

---

## 四、本地快速启动指引

### 1. 数据库准备

启动本地 MySQL 8.0 服务，创建数据库 `delta_game` 并按顺序导入 SQL 脚本：

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库并按序导入脚本
mysql> CREATE DATABASE delta_game CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
mysql> USE delta_game;
mysql> SOURCE d:/vs_project/sanjiaozhou/delta-master/delta_game.sql;
mysql> SOURCE d:/vs_project/sanjiaozhou/delta-master/setup_delta_force.sql;
mysql> SOURCE d:/vs_project/sanjiaozhou/delta-master/seed_delta_demo_data.sql;
```

启动本地 Redis 7.0 服务并保持在默认端口 `6379`。

---

### 2. 后端服务启动 (`delta-game`)

进入 `delta-game` 目录，配置数据库连接（如需要可修改 `delta-admin/src/main/resources/application-dev.yml`），执行编译与启动：

```bash
cd delta-game

# 编译打包工程
mvn clean package -DskipTests

# 启动 Spring Boot 主工程
java -jar delta-admin/target/delta-admin.jar --spring.profiles.active=dev
```

* 后端服务成功启动后，监听端口为 `http://localhost:8081`。

---

### 3. PC 管理端前端启动 (`delta-admin-ui`)

进入 `delta-admin-ui` 目录，安装依赖并启动 Vite 开发服务器：

```bash
cd delta-admin-ui

# 安装依赖
npm install

# 启动本地开发服务 (支持代理请求至 8081 端口)
npm run dev
```

* 本地访问地址：`http://localhost:3000`

---

### 4. 小程序端启动 (`delta-mp`)

进入 `delta-mp` 目录，安装依赖：

```bash
cd delta-mp

# 安装依赖
npm install
```

#### 模式 A：H5 浏览器快速调试预览
```bash
npm run dev:h5
```
* 本地访问地址：`http://localhost:5173`（建议使用 Chrome 开启移动端视口调试）。

#### 模式 B：微信开发者工具真机调试
```bash
# 编译生成微信小程序开发产物
npm run dev:mp-weixin
```
* 打开 **微信开发者工具** ➔ **导入项目** ➔ 目录选择 `delta-mp/dist/dev/mp-weixin` ➔ 填写测试 AppID 即可运行。

---

## 五、测试账号与登录凭证

| 终端 | 访问地址 | 登录方式 | 凭证 / 验证码 | 角色权限 |
| :--- | :--- | :--- | :--- | :--- |
| **PC 管理后台** | `http://localhost:3000` | 账号密码登录 | 账号: `preview`<br>密码: `DeltaPreview2026!` | **超级管理员** (商品/战区/订单/财务/干员审批) |
| **PC 客服工作台** | `http://localhost:3000` | 角色切换为“客服” | 账号: `preview`<br>密码: `DeltaPreview2026!` | **专职客服** (在线接待/改派/客诉仲裁) |
| **小程序用户端** | `http://localhost:5173` | 手机号验证码登录 | 手机号: 任意手机号 (如 `13800000001`)<br>验证码: `123456` | **普通玩家** (浏览/选品/下单/连麦/验收) |
| **小程序干员端** | `http://localhost:5173` | 个人中心 ➔ 干员认证 | 已预设干员张建军 (手机 `13911112222`) | **特战干员** (接单大厅/履约提交/提现) |

---

## 六、项目代码提交与分支管理规范

为保障项目在团队多人协作中的稳定性和代码质量，本项目严格遵循 Git 团队协作工作流：

### 1. 分支管理策略

* **`main` 分支（核心受保护分支）**：
  * 作为线上发布与生产基线分支，**严禁任何人直接向 `main` 分支执行 `git push` 操作**。
  * **权限控制**：仅项目拥有者（Project Owner / Maintainer）具备将代码合并（Merge）入 `main` 分支的权限。
* **特性分支（Feature Branches）**：
  * 命名规范：`feature/功能名称`（如：`feature/radar-hud-ui`、`feature/wechat-pay-refund`）。
  * 团队成员开发新需求时，必须基于最新的 `main` 分支开辟新分支开发。
* **修复分支（Hotfix / Bugfix Branches）**：
  * 命名规范：`fix/缺陷描述`（如：`fix/order-timeout-dispatch`）。
* **重构与测试分支**：
  * 命名规范：`refactor/模块名称`、`test/模块名称`。

---

### 2. 团队协同与 PR 提交流程

所有团队成员开发代码必须遵循如下 5 步协同规范：

```text
[本地 main 分支] 
       │ 
       ▼ git pull origin main (保持最新)
[创建新分支] feature/xxx 
       │ 
       ▼ 开发、本地自测通过
[提交代码] git commit (符合 Conventional Commits 规范)
       │ 
       ▼ 推送至远程个人特性分支
[推送分支] git push origin feature/xxx
       │ 
       ▼ 在 GitHub 发起 Pull Request (PR) -> main
[发起 PR] 填写变更描述与关联 Issue
       │ 
       ▼ 项目负责人 Code Review 与冲突检查
[PR 审查] (若有意见则修改后追加提交)
       │ 
       ▼ 项目负责人审批通过
[Merge 合并] 项目负责人执行 Squash and Merge 入 main 分支
```

---

### 3. Git Commit 提交信息规范

Commit 提交信息统一采用业内通用的 **Conventional Commits** 规范，格式如下：

```text
<type>(<scope>): <subject>

[可选 body 正文]
[可选 footer 关联 Issue]
```

#### Type 常用类型清单：
* **`feat`**：新增业务功能（如：`feat(order): 新增指定特战干员下单与指派逻辑`）
* **`fix`**：修复缺陷（如：`fix(pay): 修复支付超时未关单的状态异常`）
* **`docs`**：仅文档修改（如：`docs: 更新部署手册与分支协同规范`）
* **`style`**：代码格式变动，不影响业务逻辑（空格、格式化、补全分号等）
* **`refactor`**：代码重构，既不是修复缺陷也不是新增功能
* **`perf`**：性能优化（如优化 SQL 查询、前端组件渲染防抖等）
* **`test`**：新增或修改测试用例
* **`chore`**：构建流程、依赖变动或辅助工具变动（如调整 `.gitignore`、更新依赖版本）

#### 规范提交示例：
```bash
git commit -m "feat(category): 新增三角洲行动四大模式与二级战区分类树"
git commit -m "fix(player): 修复新干员入驻申请表单缺少撤离率验证的问题"
git commit -m "docs(readme): 补充 GitHub 分支保护配置与本地启动步骤"
```

---

### 4. 代码评审与合并准则

1. **自测通过**：发起 PR 前必须在本地确保前端无构建错误（`npm run build`）、后端无编译失败（`mvn test`）。
2. **原子性提交**：一个 PR 原则上只解决一个特定业务需求或缺陷，避免大而全的巨型 PR。
3. **消除合并冲突**：若在开发期间 `main` 分支已有更新，PR 发起人需在本地先 `git fetch origin main` 并 rebase / merge，排查解决冲突后再推送到 PR。
4. **负责人核准**：PR 必须获得项目负责人的至少 1 个 Approve 评价，方可合并进 `main` 分支。

---

## 七、开源与授权说明

本项目遵循 [MIT License](LICENSE) 协议发布，可自由用于学习、定制和商业化二次开发。
