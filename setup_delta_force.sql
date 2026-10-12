-- 三角洲行动接单平台 数据库专项初始化与迁移脚本
USE delta_game;

-- 1. 更新站点与系统配置
UPDATE sys_config SET config_value = '三角洲特战服务中心' WHERE config_key = 'site_name';
UPDATE sys_config SET config_value = '烽火摸金护航 · 全面战场冲榜 · 战术导师车队' WHERE config_key = 'site_subtitle';
UPDATE sys_config SET config_value = '三角洲行动特战运营管理后台' WHERE config_key = 'site_admin_title';

-- 2. 隐藏其他非三角洲游戏旧分类（避免干扰）
UPDATE category SET status = 0 WHERE id IN (1, 3, 7, 8, 12, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25);

-- 3. 建立三角洲行动专属顶级分类与子分类
-- 清理旧分类避免冲突，或者插入规范分类
DELETE FROM category WHERE id IN (100, 101, 102, 103, 104, 105, 200, 201, 202, 203, 300, 301, 302, 303, 400, 401, 402);

-- 顶级分类
INSERT INTO category (id, name, icon, sort_order, status, parent_id, deleted) VALUES
(100, '烽火地带·护航摸金', '', 1, 1, 0, 0),
(200, '全面战场·段位冲榜', '', 2, 1, 0, 0),
(300, '战术特训·车队连麦', '', 3, 1, 0, 0),
(400, '特勤处·任务成就', '', 4, 1, 0, 0);

-- 子分类 (烽火地带)
INSERT INTO category (id, name, icon, sort_order, status, parent_id, deleted) VALUES
(101, '零号大坝', '', 1, 1, 100, 0),
(102, '长弓溪谷', '', 2, 1, 100, 0),
(103, '巴克什', '', 3, 1, 100, 0),
(104, '航天基地', '', 4, 1, 100, 0),
(105, '曼德尔砖争夺', '', 5, 1, 100, 0);

-- 子分类 (全面战场)
INSERT INTO category (id, name, icon, sort_order, status, parent_id, deleted) VALUES
(201, '排位晋升·统帅冲榜', '', 1, 1, 200, 0),
(202, '兵种专精与战功', '', 2, 1, 200, 0),
(203, 'KD胜率战损维护', '', 3, 1, 200, 0);

-- 子分类 (战术特训)
INSERT INTO category (id, name, icon, sort_order, status, parent_id, deleted) VALUES
(301, '双人/三人小队连麦', '', 1, 1, 300, 0),
(302, '航线点位跑图教学', '', 2, 1, 300, 0),
(303, '全面战场语音开黑', '', 3, 1, 300, 0);

-- 子分类 (特勤处与战役)
INSERT INTO category (id, name, icon, sort_order, status, parent_id, deleted) VALUES
(401, '特勤处部门升级委托', '', 1, 1, 400, 0),
(402, '剧情战役·黑鹰坠落', '', 2, 1, 400, 0);

-- 4. 配置三角洲分类动态下单表单字段 (三端协同)
DELETE FROM category_form_field WHERE category_id IN (100, 200, 300, 400);

-- 烽火地带表单字段
INSERT INTO category_form_field (category_id, field_key, field_label, field_type, options, placeholder, required, sort_order) VALUES
(100, 'game_platform', '登录平台', 'SELECT', 'PC端-WeGame,PC端-Steam,移动端-iOS,移动端-安卓', '请选择登录平台', 1, 1),
(100, 'game_server', '游戏大区', 'SELECT', '微信区,QQ区', '请选择游戏大区', 1, 2),
(100, 'character_id', '干员ID与角色名', 'TEXT', '', '请输入游戏角色名及数字ID（如: 战术干员#88234）', 1, 3),
(100, 'gear_plan', '战备物资方案', 'SELECT', '干员自带全装连麦护航,老板自备装备入场,裸装进图带出保底,特殊物资定制', '请选择战备方案', 1, 4),
(100, 'target_profit', '预期保底收益', 'SELECT', '单局安全撤离,保底带出300万哈夫币,保底带出500万哈夫币,保底带出1000万哈夫币,必夺曼德尔砖', '请选择保底收益', 1, 5),
(100, 'voice_option', '语音连麦', 'SELECT', '开麦实时报点战术指挥,闭麦打字跟随', '请选择语音方式', 1, 6),
(100, 'remark', '特殊要求备注', 'TEXTAREA', '', '可填写配合上线时间、是否动用仓库物资等说明', 0, 7);

-- 全面战场表单字段
INSERT INTO category_form_field (category_id, field_key, field_label, field_type, options, placeholder, required, sort_order) VALUES
(200, 'game_platform', '登录平台', 'SELECT', 'PC端-WeGame,PC端-Steam,移动端-iOS,移动端-安卓', '请选择登录平台', 1, 1),
(200, 'game_server', '游戏大区', 'SELECT', '微信区,QQ区', '请选择游戏大区', 1, 2),
(200, 'character_id', '干员ID与角色名', 'TEXT', '', '请输入游戏角色名及数字ID', 1, 3),
(200, 'current_rank', '当前军衔段位', 'SELECT', '列兵,士官,准尉,少尉,中尉,上尉,少校,中校,上校,准将', '请选择当前段位', 1, 4),
(200, 'target_rank', '目标军衔段位', 'SELECT', '少尉,中尉,上尉,少校,中校,上校,准将,特战统帅', '请选择目标段位', 1, 5),
(200, 'preferred_class', '偏好兵种', 'SELECT', '突击兵,工程兵,侦察兵,支援兵,全能打手自选', '请选择偏好兵种', 0, 6),
(200, 'remark', '代打要求备注', 'TEXTAREA', '', '如有上号验证配合或开打时间请在此备注', 0, 7);

-- 战术特训表单字段
INSERT INTO category_form_field (category_id, field_key, field_label, field_type, options, placeholder, required, sort_order) VALUES
(300, 'game_platform', '登录平台', 'SELECT', 'PC端-WeGame,PC端-Steam,移动端-iOS,移动端-安卓', '请选择登录平台', 1, 1),
(300, 'game_server', '游戏大区', 'SELECT', '微信区,QQ区', '请选择游戏大区', 1, 2),
(300, 'character_id', '干员ID与角色名', 'TEXT', '', '请输入游戏角色名及数字ID', 1, 3),
(300, 'training_focus', '特训重点', 'SELECT', '大坝摸金与撤离线路教学,长弓溪谷架枪点与意识,航天基地核心区卡点攻坚,全系武器改枪与压枪教学', '请选择特训重点', 1, 4),
(300, 'remark', '备注文档', 'TEXTAREA', '', '请填写您想针对性提升的方向', 0, 5);

-- 特勤处与成就表单字段
INSERT INTO category_form_field (category_id, field_key, field_label, field_type, options, placeholder, required, sort_order) VALUES
(400, 'game_platform', '登录平台', 'SELECT', 'PC端-WeGame,PC端-Steam,移动端-iOS,移动端-安卓', '请选择登录平台', 1, 1),
(400, 'game_server', '游戏大区', 'SELECT', '微信区,QQ区', '请选择游戏大区', 1, 2),
(400, 'character_id', '干员ID与角色名', 'TEXT', '', '请输入游戏角色名及数字ID', 1, 3),
(400, 'target_department', '目标部门/成就', 'SELECT', '特勤处全套升级材料收集,靶场/防空雷达升级,技术开发部门全通,黑鹰坠落剧情战役全难度', '请选择目标项目', 1, 4),
(400, 'remark', '委托细节', 'TEXTAREA', '', '补充当前各部门等级与仓库状态', 0, 5);

-- 5. 初始化三角洲行动代表性商品
DELETE FROM product WHERE id IN (101, 102, 103, 104, 201, 202, 301, 401);

INSERT INTO product (id, category_id, name, subtitle, description, cover_image, images, required_player_count, status, sort_order, sales_count, avg_rating, is_recommend, price) VALUES
(101, 101, '【零号大坝】极速撤离 · 保底200万哈夫币摸金', '大坝核心物资搜刮，高经验撤离点护航，掉装包赔', '【服务内容】\n1. 顶级全装特勤干员全程护航，保底带出200万以上哈夫币价值物资\n2. 纯手工操作，绝不使用违规第三方软件\n3. 意外撤离失败全额补打或包赔装损\n4. 支持微信区/QQ区、PC与移动双端', '', '', 1, 1, 1, 286, 5.00, 1, 38.00),

(102, 102, '【长弓溪谷】全装护航 · 保底500万纯利+红卡房攻坚', '山庄/酒店核心红卡房开启，必拿高价值战备', '【服务内容】\n1. 双人金牌打手保驾护航，主攻长弓溪谷高价值防区与红卡房\n2. 保底带出500万哈夫币纯收益，带出金色/红色收藏品\n3. 老板可躺平跟随或自由体验\n4. 绿色纯手打，平台资金担保', '', '', 1, 1, 2, 452, 4.98, 1, 78.00),

(103, 104, '【航天基地】核心实验区突破 · 曼德尔砖必定带出', '核心发射区攻坚，特勤干员夺砖护送撤离', '【服务内容】\n1. 顶级技术干员强攻航天基地核心区\n2. 锁定曼德尔砖破译带出，极速破译极速撤离\n3. 全程火力掩护，安全感拉满\n4. 未带出曼德尔砖无条件免费重新护航', '', '', 1, 1, 3, 198, 5.00, 1, 158.00),

(104, 103, '【巴克什】摸金全流程护航 · 高战备纯利保底', '巴克什街区搜刮与集市突围，稳健保底撤离', '【服务内容】\n1. 熟悉巴克什复杂巷战架构，熟练卡点清理游荡者与敌对干员\n2. 保底带出350万哈夫币物资\n3. 掉落装备全额包赔', '', '', 1, 1, 4, 163, 4.97, 1, 88.00),

(201, 201, '【全面战场】军衔直升 · 上校晋升【特战统帅】纯手打', '王牌战力代打/组排，高效冲分上榜', '【服务内容】\n1. 前职业/高KD统帅干员纯手工冲榜代打\n2. 支持指定突击兵/工程兵/侦察兵专精\n3. 保持高胜率高战损比，安全高效\n4. 平台实时进度汇报，完成即时交号', '', '', 1, 1, 5, 312, 4.99, 1, 128.00),

(202, 202, '【兵种专精】全面战场全兵种枪皮与熟练度快速刷取', '突击/支援/工程/侦察专精挑战，战功速刷', '【服务内容】\n1. 快速完成兵种核心战功指标与枪械迷彩涂装任务\n2. 纯手工绿色对局，战绩优异\n3. 效率交付，按要求定制', '', '', 1, 1, 6, 95, 5.00, 1, 68.00),

(301, 301, '【特战小队】金牌干员车队 · 烽火地带连麦护航（小时单）', '双人/三人满编战术车队，实时连麦报点带打', '【服务内容】\n1. 实力幽默耐心干员全程连麦开黑\n2. 战术报点、意识教学、路线规划、摸金让包\n3. 适合想体验团队战术默契的老板', '', '', 1, 1, 7, 520, 5.00, 1, 60.00),

(401, 401, '【特勤处委托】特勤部门全套升级材料收集与任务通关', '防空雷达/工作台/技术部门全套升级，省心省力', '【服务内容】\n1. 高效搜集特勤处升级所需各类专属工业零配件与贵重物资\n2. 一站式解锁部门功能，节省大量重复刷图时间\n3. 纯手工收集，仓库物品规范摆放', '', '', 1, 1, 8, 89, 4.95, 1, 188.00);

-- 6. 更新公告为三角洲真实业务公告
DELETE FROM notice WHERE id IN (1, 2, 3);
INSERT INTO notice (id, title, content, sort_order, status, popup_display) VALUES
(1, '【平台安全承诺】三角洲特战服务中心全员纯手工绿色护航，严禁任何违规外挂', '<p>尊敬的特战指挥官（老板）：</p><p>本平台所有接单干员均经过严格段位实名认证与反作弊筛查，所有护航/代练对局坚持<strong>100%纯手工绿色操作</strong>，坚决杜绝任何辅助插件与漏洞利用。如遇封号或违规扣分，平台全额先行赔付！</p>', 1, 1, 1),
(2, '【护航保障升级】烽火地带掉装包赔，未达成保底收益全额补打', '<p>在烽火地带摸金护航订单中，若因对局失利导致老板携带装备遗失，干员全额包赔对应战备价值！若对局未达到约定哈夫币保底额度，免费赠送对局直至达标！</p>', 2, 1, 0),
(3, '【特战干员招募】实力指挥官/枪法大师入驻通道已开启，高分成高保障', '<p>欢迎三角洲行动高段位统帅玩家、各大地图熟手摸金干员入驻！平台订单充足，客服24小时极速派单，收入透明提现实时审核！点击“我的-我要入驻”即可提交资质申请。</p>', 3, 1, 0);

