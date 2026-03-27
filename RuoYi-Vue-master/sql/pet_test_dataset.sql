SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS biz_social_friend (
  friend_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '好友关系ID',
  user_id               BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  friend_user_id        BIGINT UNSIGNED NOT NULL COMMENT '好友用户ID',
  pet_id                BIGINT UNSIGNED NOT NULL COMMENT '当前用户宠物ID',
  friend_pet_id         BIGINT UNSIGNED NOT NULL COMMENT '好友宠物ID',
  source_match_id       BIGINT UNSIGNED NOT NULL COMMENT '来源社交记录ID',
  status                CHAR(1) NOT NULL DEFAULT '0' COMMENT '状态（0正常）',
  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (friend_id),
  UNIQUE KEY uk_social_friend_pair (pet_id, friend_pet_id),
  KEY idx_social_friend_user (user_id),
  KEY idx_social_friend_match (source_match_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='宠物好友关系表';

SET @social_match_has_invite_type = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_social_match' AND COLUMN_NAME = 'invite_type'
);
SET @social_match_sql = IF(
  @social_match_has_invite_type = 0,
  'ALTER TABLE biz_social_match ADD COLUMN invite_type VARCHAR(32) DEFAULT ''线下互动'' COMMENT ''邀请类型''',
  'SELECT 1'
);
PREPARE social_stmt FROM @social_match_sql;
EXECUTE social_stmt;
DEALLOCATE PREPARE social_stmt;

SET @social_match_has_event_time = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_social_match' AND COLUMN_NAME = 'event_time'
);
SET @social_event_time_sql = IF(
  @social_match_has_event_time = 0,
  'ALTER TABLE biz_social_match ADD COLUMN event_time DATETIME DEFAULT NULL COMMENT ''约定活动时间''',
  'SELECT 1'
);
PREPARE social_stmt FROM @social_event_time_sql;
EXECUTE social_stmt;
DEALLOCATE PREPARE social_stmt;

SET @social_match_has_event_location = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'biz_social_match' AND COLUMN_NAME = 'event_location'
);
SET @social_event_location_sql = IF(
  @social_match_has_event_location = 0,
  'ALTER TABLE biz_social_match ADD COLUMN event_location VARCHAR(255) DEFAULT '''' COMMENT ''约定地点''',
  'SELECT 1'
);
PREPARE social_stmt FROM @social_event_location_sql;
EXECUTE social_stmt;
DEALLOCATE PREPARE social_stmt;

TRUNCATE TABLE biz_social_friend;
TRUNCATE TABLE biz_social_match;
TRUNCATE TABLE biz_health_alert;
TRUNCATE TABLE biz_health_record;
TRUNCATE TABLE biz_pet_info;

-- 1) 宠物档案（12只，覆盖犬猫和多标签交集）
INSERT INTO biz_pet_info
(owner_user_id, pet_name, pet_gender, breed, birthday, age_month, weight_kg, avatar_url, social_tags, health_note, status, create_by, update_by)
VALUES
(1, '奶糖', '1', '金毛', '2023-04-15', 35, 26.50, '', '金毛,活泼,亲人,户外,飞盘', '体能好，社交意愿强', '0', 'admin', 'admin'),
(1, '豆包', '0', '柴犬', '2023-08-10', 31, 11.20, '', '柴犬,活泼,亲人,室内,零食', '有点挑食', '0', 'admin', 'admin'),
(1, '糯米', '1', '布偶', '2024-01-20', 26, 4.60, '', '布偶,安静,粘人,室内,逗猫棒', '性格温顺', '0', 'admin', 'admin'),
(1, '花卷', '0', '边牧', '2022-11-02', 40, 19.10, '', '边牧,聪明,活泼,飞盘,训练', '学习能力强', '0', 'admin', 'admin'),
(1, '年糕', '1', '英短', '2023-12-12', 27, 5.10, '', '英短,安静,室内,晒太阳,陪伴', '胆小慢热', '0', 'admin', 'admin'),
(1, '雪球', '0', '萨摩耶', '2023-03-08', 36, 22.80, '', '萨摩耶,活泼,户外,亲人,奔跑', '掉毛较多', '0', 'admin', 'admin'),
(2, '可乐', '0', '金毛', '2023-05-01', 34, 25.90, '', '金毛,活泼,飞盘,户外,游泳', '喜欢互动', '0', 'ry', 'ry'),
(2, '团子', '1', '布偶', '2024-02-05', 25, 4.30, '', '布偶,安静,室内,陪伴,挑食', '喜欢安静环境', '0', 'ry', 'ry'),
(2, '阿布', '0', '金毛', '2022-09-20', 42, 29.40, '', '金毛,亲人,户外,护食,巡回', '运动量大', '0', 'ry', 'ry'),
(2, '泡芙', '1', '柯基', '2023-10-18', 29, 12.40, '', '柯基,活泼,亲人,短腿,零食', '贪吃需控重', '0', 'ry', 'ry'),
(2, '奥利奥', '0', '暹罗', '2023-11-11', 28, 4.90, '', '暹罗,好奇,室内,逗猫棒,互动', '精力充沛', '0', 'ry', 'ry'),
(2, '豆乳', '1', '比熊', '2024-03-03', 24, 7.20, '', '比熊,亲人,室内,散步,美容', '毛发需定期打理', '0', 'ry', 'ry');

-- 2) 健康记录（20条，覆盖正常/异常组合，便于测试筛选和展示）
INSERT INTO biz_health_record
(pet_id, record_date, weight_kg, food_intake_g, defecation_status, mental_status, symptom_desc, is_abnormal, create_by, update_by)
VALUES
(1, '2026-03-10', 26.40, 450.00, '0', '0', '状态稳定', '0', 'admin', 'admin'),
(1, '2026-03-12', 26.50, 430.00, '1', '1', '排便偏软', '1', 'admin', 'admin'),
(1, '2026-03-14', 26.30, 420.00, '0', '2', '精神萎靡，活动减少', '1', 'admin', 'admin'),

(2, '2026-03-10', 11.30, 240.00, '0', '0', '正常', '0', 'admin', 'admin'),
(2, '2026-03-13', 11.20, 210.00, '1', '2', '排便异常且精神差', '1', 'admin', 'admin'),

(3, '2026-03-11', 4.60, 120.00, '0', '0', '正常', '0', 'admin', 'admin'),
(3, '2026-03-14', 4.55, 100.00, '0', '2', '食欲一般，精神萎靡', '1', 'admin', 'admin'),

(4, '2026-03-12', 19.10, 360.00, '0', '0', '训练后恢复正常', '0', 'admin', 'admin'),
(5, '2026-03-12', 5.10, 130.00, '0', '0', '正常', '0', 'admin', 'admin'),
(6, '2026-03-12', 22.70, 390.00, '1', '0', '排便次数偏多', '1', 'admin', 'admin'),

(7, '2026-03-10', 25.90, 440.00, '0', '0', '正常', '0', 'ry', 'ry'),
(7, '2026-03-13', 25.80, 410.00, '1', '1', '排便偏稀', '1', 'ry', 'ry'),
(8, '2026-03-11', 4.30, 115.00, '0', '0', '正常', '0', 'ry', 'ry'),
(8, '2026-03-14', 4.20, 90.00, '0', '2', '精神不佳', '1', 'ry', 'ry'),
(9, '2026-03-11', 29.30, 500.00, '0', '0', '状态良好', '0', 'ry', 'ry'),
(9, '2026-03-15', 29.10, 470.00, '1', '2', '双异常', '1', 'ry', 'ry'),
(10, '2026-03-12', 12.30, 260.00, '0', '0', '正常', '0', 'ry', 'ry'),
(11, '2026-03-13', 4.90, 110.00, '0', '0', '正常', '0', 'ry', 'ry'),
(12, '2026-03-13', 7.20, 180.00, '0', '1', '精神一般', '0', 'ry', 'ry'),
(12, '2026-03-15', 7.10, 150.00, '1', '2', '排便异常+精神差', '1', 'ry', 'ry');

-- 3) 预警数据（8条，与异常记录关联）
INSERT INTO biz_health_alert
(pet_id, record_id, alert_type, alert_level, alert_content, alert_time, process_status, process_note, create_by, update_by)
SELECT r.pet_id, r.record_id, '4',
       CASE
         WHEN r.defecation_status='1' AND r.mental_status='2' THEN '3'
         WHEN r.defecation_status='1' OR r.mental_status='2' THEN '2'
         ELSE '1'
       END AS alert_level,
       CASE
         WHEN r.defecation_status='1' AND r.mental_status='2' THEN '健康预警：排便异常且精神萎靡，建议尽快线下就诊。'
         WHEN r.defecation_status='1' THEN '健康预警：排便状态异常，请持续观察。'
         WHEN r.mental_status='2' THEN '健康预警：精神状态萎靡，请关注食欲与活动量。'
         ELSE '健康提示：请持续记录。'
       END AS alert_content,
       DATE_ADD(r.create_time, INTERVAL 10 MINUTE),
       '0', '',
       r.create_by, r.update_by
FROM biz_health_record r
WHERE r.is_abnormal='1'
ORDER BY r.record_id
LIMIT 8;

-- 4) 社交邀请样本（8条，覆盖待发送/已发送/已接受/已拒绝）
INSERT INTO biz_social_match
(initiator_user_id, receiver_user_id, initiator_pet_id, receiver_pet_id, match_score, matched_tags, status, invite_type, invite_message, invite_time, event_time, event_location, response_time, create_by, update_by)
VALUES
(1, 2, 1, 7, 80, '金毛,活泼,户外,飞盘', '1', '一起遛宠', '一起去公园飞盘吧～', '2026-03-15 10:00:00', '2026-03-17 18:00:00', '滨江公园', NULL, 'admin', 'admin'),
(1, 2, 1, 9, 60, '金毛,亲人,户外', '2', '一起遛宠', '周末组队遛狗吗？', '2026-03-15 11:00:00', '2026-03-18 09:30:00', '社区草坪', '2026-03-15 11:30:00', 'admin', 'admin'),
(1, 2, 3, 8, 60, '布偶,安静,室内', '1', '经验交流', '可以一起玩逗猫棒', '2026-03-15 12:00:00', '2026-03-18 20:00:00', '猫咖包间', NULL, 'admin', 'admin'),
(2, 1, 7, 1, 80, '金毛,活泼,户外,飞盘', '3', '一起遛宠', '今天约跑步？', '2026-03-15 13:00:00', '2026-03-16 07:30:00', '江边步道', '2026-03-15 13:20:00', 'ry', 'ry'),
(2, 1, 8, 3, 60, '布偶,安静,室内', '1', '经验交流', '猫友互访交流~', '2026-03-15 13:30:00', '2026-03-19 15:00:00', '宠物友好咖啡馆', NULL, 'ry', 'ry'),
(2, 1, 10, 2, 60, '活泼,亲人,零食', '0', '宠友聚会', '来一场小短腿聚会', NULL, '2026-03-20 16:00:00', '社区活动室', NULL, 'ry', 'ry'),
(1, 2, 6, 7, 60, '活泼,户外,亲人', '1', '一起遛宠', '一起晨跑？', '2026-03-15 14:10:00', '2026-03-18 06:30:00', '小区门口', NULL, 'admin', 'admin'),
(1, 2, 2, 10, 60, '活泼,亲人,零食', '2', '宠友聚会', '交换零食测评', '2026-03-15 15:00:00', '2026-03-19 14:00:00', '萌宠乐园', '2026-03-15 15:25:00', 'admin', 'admin');

INSERT INTO biz_social_friend
(user_id, friend_user_id, pet_id, friend_pet_id, source_match_id, status, create_by, update_by)
VALUES
(1, 2, 1, 9, 2, '0', 'admin', 'admin'),
(2, 1, 9, 1, 2, '0', 'ry', 'ry'),
(1, 2, 2, 10, 8, '0', 'admin', 'admin'),
(2, 1, 10, 2, 8, '0', 'ry', 'ry');

SET FOREIGN_KEY_CHECKS = 1;
