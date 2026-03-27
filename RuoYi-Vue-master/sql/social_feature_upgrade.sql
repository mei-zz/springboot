SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
  KEY idx_social_friend_match (source_match_id),
  CONSTRAINT fk_social_friend_pet FOREIGN KEY (pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_social_friend_friend_pet FOREIGN KEY (friend_pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_social_friend_match FOREIGN KEY (source_match_id) REFERENCES biz_social_match (match_id)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='宠物好友关系表';

SET FOREIGN_KEY_CHECKS = 1;
