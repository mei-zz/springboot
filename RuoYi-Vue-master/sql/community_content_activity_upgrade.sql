SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS biz_content_post (
  content_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '内容ID',
  creator_user_id       BIGINT UNSIGNED NOT NULL COMMENT '发布用户ID',
  pet_id                BIGINT UNSIGNED NOT NULL COMMENT '发布宠物ID',
  content_type          VARCHAR(32) NOT NULL DEFAULT '日常动态' COMMENT '内容类型',
  title                 VARCHAR(100) NOT NULL COMMENT '标题',
  summary               VARCHAR(255) DEFAULT '' COMMENT '摘要',
  content_text          TEXT COMMENT '正文内容',
  tags                  VARCHAR(255) DEFAULT '' COMMENT '标签（逗号分隔）',
  media_url             VARCHAR(500) DEFAULT '' COMMENT '媒体链接',
  status                CHAR(1) NOT NULL DEFAULT '0' COMMENT '状态（0正常 1禁用）',
  review_status         CHAR(1) NOT NULL DEFAULT '0' COMMENT '审核状态（0待审 1通过 2拒绝）',
  review_by             VARCHAR(64) DEFAULT '' COMMENT '审核人',
  review_time           DATETIME DEFAULT NULL COMMENT '审核时间',
  review_note           VARCHAR(500) DEFAULT '' COMMENT '审核备注',
  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (content_id),
  KEY idx_content_creator (creator_user_id),
  KEY idx_content_pet (pet_id),
  KEY idx_content_review (review_status),
  CONSTRAINT fk_content_pet FOREIGN KEY (pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区内容发布表';

CREATE TABLE IF NOT EXISTS biz_community_activity (
  activity_id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '活动ID',
  creator_user_id       BIGINT UNSIGNED NOT NULL COMMENT '发起用户ID',
  title                 VARCHAR(100) NOT NULL COMMENT '活动标题',
  activity_type         VARCHAR(32) NOT NULL DEFAULT '线下遛宠' COMMENT '活动类型',
  location              VARCHAR(255) DEFAULT '' COMMENT '活动地点',
  start_time            DATETIME NOT NULL COMMENT '开始时间',
  end_time              DATETIME NOT NULL COMMENT '结束时间',
  pet_size_limit        VARCHAR(16) DEFAULT '不限' COMMENT '宠物体型限制',
  max_participants      INT DEFAULT 0 COMMENT '人数上限（0不限）',
  current_participants  INT DEFAULT 0 COMMENT '当前人数',
  status                CHAR(1) NOT NULL DEFAULT '0' COMMENT '状态（0草稿 1进行中 2结束 3已拒绝）',
  review_status         CHAR(1) NOT NULL DEFAULT '0' COMMENT '审核状态（0待审 1通过 2拒绝）',
  review_by             VARCHAR(64) DEFAULT '' COMMENT '审核人',
  review_time           DATETIME DEFAULT NULL COMMENT '审核时间',
  review_note           VARCHAR(500) DEFAULT '' COMMENT '审核备注',
  description           VARCHAR(1000) DEFAULT '' COMMENT '活动说明',
  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (activity_id),
  KEY idx_activity_creator (creator_user_id),
  KEY idx_activity_review (review_status),
  KEY idx_activity_time (start_time, end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区活动表';

CREATE TABLE IF NOT EXISTS biz_activity_signup (
  signup_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '报名ID',
  activity_id           BIGINT UNSIGNED NOT NULL COMMENT '活动ID',
  user_id               BIGINT UNSIGNED NOT NULL COMMENT '报名用户ID',
  pet_id                BIGINT UNSIGNED NOT NULL COMMENT '报名宠物ID',
  status                CHAR(1) NOT NULL DEFAULT '0' COMMENT '状态（0有效 1取消）',
  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (signup_id),
  UNIQUE KEY uk_activity_user_pet (activity_id, user_id, pet_id),
  KEY idx_signup_user (user_id),
  KEY idx_signup_pet (pet_id),
  CONSTRAINT fk_signup_activity FOREIGN KEY (activity_id) REFERENCES biz_community_activity (activity_id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_signup_pet FOREIGN KEY (pet_id) REFERENCES biz_pet_info (pet_id)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动报名表';

INSERT INTO sys_menu(menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
VALUES
(2105, '内容发布', 2100, 5, 'content', 'pet/content/index', NULL, 1, 0, 'C', '0', '0', 'biz:content:list', 'edit', 'admin', NOW(), '社区内容发布'),
(2106, '社区活动', 2100, 6, 'activity', 'pet/activity/index', NULL, 1, 0, 'C', '0', '0', 'biz:activity:list', 'date', 'admin', NOW(), '社区活动管理'),
(2107, '审核中心', 2100, 7, 'audit', 'pet/audit/index', NULL, 1, 0, 'C', '0', '0', 'biz:audit:list', 's-check', 'admin', NOW(), '内容与活动审核')
ON DUPLICATE KEY UPDATE
menu_name = VALUES(menu_name),
parent_id = VALUES(parent_id),
order_num = VALUES(order_num),
path = VALUES(path),
component = VALUES(component),
menu_type = VALUES(menu_type),
visible = VALUES(visible),
status = VALUES(status),
perms = VALUES(perms),
icon = VALUES(icon),
update_by = 'admin',
update_time = NOW();

INSERT IGNORE INTO sys_menu(menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
VALUES
(2151, '内容查询', 2105, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'biz:content:query', '#', 'admin', NOW(), ''),
(2152, '内容新增', 2105, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'biz:content:add', '#', 'admin', NOW(), ''),
(2161, '活动查询', 2106, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'biz:activity:query', '#', 'admin', NOW(), ''),
(2162, '活动新增', 2106, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'biz:activity:add', '#', 'admin', NOW(), ''),
(2163, '活动报名', 2106, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'biz:activity:signup', '#', 'admin', NOW(), ''),
(2171, '审核查询', 2107, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'biz:audit:query', '#', 'admin', NOW(), ''),
(2172, '审核操作', 2107, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'biz:audit:review', '#', 'admin', NOW(), '');

INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
VALUES
(1, 2105), (1, 2106), (1, 2107),
(1, 2151), (1, 2152),
(1, 2161), (1, 2162), (1, 2163),
(1, 2171), (1, 2172);

SET FOREIGN_KEY_CHECKS = 1;
