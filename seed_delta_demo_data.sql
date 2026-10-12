-- 更新已有用户信息
UPDATE user SET nickname = '三角洲特勤探长' WHERE id = 377;
UPDATE user SET nickname = '长弓摸金老炮' WHERE id = 376;

-- 清空旧模拟数据
DELETE FROM complaint WHERE id > 0;
DELETE FROM withdraw WHERE id > 0;
DELETE FROM delta_game.order WHERE id > 0;
DELETE FROM player WHERE id >= 10;

-- 插入特战干员
INSERT INTO player (id, openid, nickname, avatar, real_name, phone, skill_tags, game_level, service_types, avg_rating, order_count, complete_rate, status, is_online, deleted)
VALUES 
(10, 'wx_player_001', 'GTI_暗夜红狼', 'https://api.dicebear.com/7.x/bottts/svg?seed=redwolf', '张建军', '13911112222', '突击手,红卡房清场,全装攻坚', '烽火统帅5星 / 撤离率74%', '零号大坝,长弓溪谷,航天基地', 4.95, 128, 99.2, 'APPROVED', 1, 0),
(11, 'wx_player_002', '威龙突破手_老K', 'https://api.dicebear.com/7.x/bottts/svg?seed=vyron', '王凯', '13922223333', '重甲猛攻,身法突破,连麦报点', '烽火统帅3星 / 撤离率69%', '零号大坝,巴克什', 4.90, 96, 98.5, 'APPROVED', 1, 0),
(12, 'wx_player_003', '骇爪侦察_林峰', 'https://api.dicebear.com/7.x/bottts/svg?seed=hackclaw', '林峰', '13933334444', '侦察报点,曼德尔砖夺取,点位教学', '统帅2星 / 撤离率72%', '航天基地,长弓溪谷', 4.98, 85, 100.0, 'APPROVED', 1, 0),
(13, 'wx_player_004', '特勤支援_蜂医宁', 'https://api.dicebear.com/7.x/bottts/svg?seed=medic', '宁致远', '13944445555', '战术治疗,远程救助,特勤升级', '战区上校 / 撤离率66%', '特勤处升级,黑鹰坠落', 5.00, 0, 100.0, 'PENDING', 0, 0);

-- 插入特战订单
INSERT INTO delta_game.order 
(id, order_no, user_id, product_id, product_name, amount, game_account, contact, remark, extra_fields, player_id, status, start_time, created_at)
VALUES
(1, 'DF202610120001', 377, 101, '【零号大坝】极速撤离 · 保底200万哈夫币摸金', 38.00, 'PC-WeGame | 微信区 | GTI_猎手#8888', '13800000001', '老板闭麦跟随，干员主搜主攻', '{"登录平台":"PC端-WeGame","游戏大区":"微信区","预期保底":"保底200万哈夫币","战备方案":"干员自带全装"}', 10, 'COMPLETED', NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 3 HOUR),
(2, 'DF202610120002', 377, 102, '【长弓溪谷】全装护航 · 保底500万纯利+红卡房攻坚', 78.00, 'PC-WeGame | 微信区 | GTI_猎手#8888', '13800000001', '开麦实时报点，直奔山庄与酒店红卡房', '{"登录平台":"PC端-WeGame","游戏大区":"微信区","预期保底":"保底500万哈夫币","语音连麦":"开麦实时报点"}', 10, 'IN_PROGRESS', NOW() - INTERVAL 30 MINUTE, NOW() - INTERVAL 40 MINUTE),
(3, 'DF202610120003', 376, 103, '【航天基地】核心实验区突破 · 曼德尔砖必定带出', 158.00, '移动端-iOS | QQ区 | 航天先锋#7712', '13800138000', '必须带出曼德尔砖，已自备密码卡', '{"登录平台":"移动端-iOS","游戏大区":"QQ区","预期保底":"必夺曼德尔砖"}', NULL, 'PAID', NULL, NOW() - INTERVAL 15 MINUTE),
(4, 'DF202610120004', 377, 201, '【全面战场】军衔直升 · 上校晋升【特战统帅】纯手打', 128.00, 'PC-Steam | 微信区 | DeltaStriker#1022', '13800000001', '冲刺全面战场统帅，要求纯手工无科技', '{"登录平台":"PC端-Steam","游戏大区":"微信区","目标段位":"特战统帅"}', NULL, 'ASSIGNED', NULL, NOW() - INTERVAL 5 MINUTE);

-- 插入干员提现申请
INSERT INTO withdraw (id, player_id, account_id, amount, status, pay_method, created_at)
VALUES (1, 10, 1, 580.00, 'PENDING', 'WECHAT', NOW() - INTERVAL 1 HOUR);

-- 插入客诉记录
INSERT INTO complaint (id, order_id, user_id, player_id, type, content, status, created_at)
VALUES (1, 1, 377, 10, 'SERVICE_QUALITY', '撤离路线遭遇伏击，干员主动掩护牺牲，协商补打一局长弓溪谷', 'PENDING', NOW() - INTERVAL 20 MINUTE);
