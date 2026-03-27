SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS biz_social_match;
DROP TABLE IF EXISTS biz_health_alert;
DROP TABLE IF EXISTS biz_health_record;
DROP TABLE IF EXISTS biz_pet_info;

CREATE TABLE biz_pet_info (
  pet_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '宠物ID',
  owner_user_id     BIGINT UNSIGNED NOT NULL COMMENT '主人用户ID（可关联sys_user.user_id）',
  pet_name          VARCHAR(64) NOT NULL COMMENT '宠物昵称',
  pet_gender        CHAR(1) NOT NULL DEFAULT '2' COMMENT '性别（0公 1母 2未知）',
  breed             VARCHAR(64) DEFAULT '' COMMENT '品种',
  birthday          DATE DEFAULT NULL COMMENT '出生日期',
  age_month         INT DEFAULT NULL COMMENT '月龄',
  weight_kg         DECIMAL(6,2) DEFAULT NULL COMMENT '当前体重(kg)',
  avatar_url        VARCHAR(255) DEFAULT '' COMMENT '宠物头像URL',
  social_tags       VARCHAR(255) NOT NULL DEFAULT '' COMMENT '社交标签（逗号分隔，如金毛,活泼）',
  health_note       VARCHAR(500) DEFAULT '' COMMENT '健康备注',
  status            CHAR(1) NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',

  create_by         VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by         VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark            VARCHAR(500) DEFAULT NULL COMMENT '备注',

  PRIMARY KEY (pet_id),
  KEY idx_pet_owner_user_id (owner_user_id),
  KEY idx_pet_status (status),
  KEY idx_pet_social_tags (social_tags)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='宠物档案表';

CREATE TABLE biz_health_record (
  record_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '健康记录ID',
  pet_id                BIGINT UNSIGNED NOT NULL COMMENT '宠物ID',
  record_date           DATE NOT NULL COMMENT '记录日期',
  weight_kg             DECIMAL(6,2) DEFAULT NULL COMMENT '体重(kg)',
  food_intake_g         DECIMAL(8,2) DEFAULT NULL COMMENT '饮食量(g)',
  defecation_status     CHAR(1) NOT NULL DEFAULT '0' COMMENT '排便状态（0正常 1异常）',
  mental_status         CHAR(1) NOT NULL DEFAULT '0' COMMENT '精神状态（0良好 1一般 2萎靡）',
  symptom_desc          VARCHAR(500) DEFAULT '' COMMENT '症状描述',
  is_abnormal           CHAR(1) NOT NULL DEFAULT '0' COMMENT '是否异常（0否 1是）',

  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',

  PRIMARY KEY (record_id),
  UNIQUE KEY uk_pet_record_date (pet_id, record_date),
  KEY idx_record_pet_id (pet_id),
  KEY idx_record_is_abnormal (is_abnormal),
  CONSTRAINT fk_health_record_pet
    FOREIGN KEY (pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康记录表';

CREATE TABLE biz_health_alert (
  alert_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  pet_id                BIGINT UNSIGNED NOT NULL COMMENT '宠物ID',
  record_id             BIGINT UNSIGNED DEFAULT NULL COMMENT '关联健康记录ID',
  alert_type            CHAR(1) NOT NULL DEFAULT '4' COMMENT '预警类型（0体重 1饮食 2排便 3精神 4综合）',
  alert_level           CHAR(1) NOT NULL DEFAULT '1' COMMENT '预警等级（1提示 2预警 3严重）',
  alert_content         VARCHAR(500) NOT NULL COMMENT '预警内容',
  alert_time            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预警时间',
  process_status        CHAR(1) NOT NULL DEFAULT '0' COMMENT '处理状态（0未处理 1已处理）',
  process_note          VARCHAR(500) DEFAULT '' COMMENT '处理说明',

  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',

  PRIMARY KEY (alert_id),
  KEY idx_alert_pet_id (pet_id),
  KEY idx_alert_time (alert_time),
  KEY idx_alert_status (process_status),
  CONSTRAINT fk_health_alert_pet
    FOREIGN KEY (pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_health_alert_record
    FOREIGN KEY (record_id) REFERENCES biz_health_record (record_id)
    ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康预警表';

CREATE TABLE biz_social_match (
  match_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '匹配记录ID',
  initiator_user_id     BIGINT UNSIGNED NOT NULL COMMENT '发起人用户ID',
  receiver_user_id      BIGINT UNSIGNED NOT NULL COMMENT '接收人用户ID',
  initiator_pet_id      BIGINT UNSIGNED NOT NULL COMMENT '发起人宠物ID',
  receiver_pet_id       BIGINT UNSIGNED NOT NULL COMMENT '接收人宠物ID',
  match_score           INT NOT NULL DEFAULT 0 COMMENT '匹配度（0-100）',
  matched_tags          VARCHAR(255) DEFAULT '' COMMENT '匹配标签（逗号分隔）',
  status                CHAR(1) NOT NULL DEFAULT '0' COMMENT '状态（0待发送 1已发送 2已接受 3已拒绝）',
  invite_type           VARCHAR(32) DEFAULT '线下互动' COMMENT '邀请类型',
  invite_message        VARCHAR(255) DEFAULT '' COMMENT '邀请附言',
  invite_time           DATETIME DEFAULT NULL COMMENT '发送邀请时间',
  event_time            DATETIME DEFAULT NULL COMMENT '约定活动时间',
  event_location        VARCHAR(255) DEFAULT '' COMMENT '约定地点',
  response_time         DATETIME DEFAULT NULL COMMENT '响应时间',

  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',

  PRIMARY KEY (match_id),
  KEY idx_match_initiator_user (initiator_user_id),
  KEY idx_match_receiver_user (receiver_user_id),
  KEY idx_match_score (match_score),
  KEY idx_match_status (status),
  CONSTRAINT fk_social_match_initiator_pet
    FOREIGN KEY (initiator_pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_social_match_receiver_pet
    FOREIGN KEY (receiver_pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社交互动表';

CREATE TABLE biz_social_friend (
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
