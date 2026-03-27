-- =========================================
-- 宠物社区业务表 + 菜单注册
-- =========================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS biz_social_match;
DROP TABLE IF EXISTS biz_health_alert;
DROP TABLE IF EXISTS biz_health_record;
DROP TABLE IF EXISTS biz_pet_info;

CREATE TABLE biz_pet_info (
  pet_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '宠物ID',
  owner_user_id     BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '主人用户ID',
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
  KEY idx_pet_status (status)
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
  KEY idx_record_pet_id (pet_id),
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
  KEY idx_alert_status (process_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康预警表';

CREATE TABLE biz_social_match (
  match_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '匹配记录ID',
  initiator_user_id     BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '发起人用户ID',
  receiver_user_id      BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '接收人用户ID',
  initiator_pet_id      BIGINT UNSIGNED NOT NULL COMMENT '发起人宠物ID',
  receiver_pet_id       BIGINT UNSIGNED NOT NULL COMMENT '接收人宠物ID',
  match_score           INT NOT NULL DEFAULT 0 COMMENT '匹配度（0-100）',
  matched_tags          VARCHAR(255) DEFAULT '' COMMENT '匹配标签（逗号分隔）',
  status                CHAR(1) NOT NULL DEFAULT '0' COMMENT '状态（0待发送 1已发送 2已接受 3已拒绝）',
  invite_message        VARCHAR(255) DEFAULT '' COMMENT '邀请附言',
  invite_time           DATETIME DEFAULT NULL COMMENT '发送邀请时间',
  response_time         DATETIME DEFAULT NULL COMMENT '响应时间',
  create_by             VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by             VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark                VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (match_id),
  KEY idx_match_initiator (initiator_pet_id),
  KEY idx_match_receiver (receiver_pet_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社交互动表';

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================
-- 菜单注册（宠物健康管理模块）
-- =========================================
-- 一级菜单：宠物管理
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2100, '宠物管理', 0, 5, 'pet', NULL, '', 1, 0, 'M', '0', '0', '', 'peoples', 'admin', sysdate(), '', NULL, '宠物健康管理及社交平台');

-- 二级菜单：宠物档案
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2101, '宠物档案', 2100, 1, 'info', 'pet/info/index', '', 1, 0, 'C', '0', '0', 'biz:pet:list', 'clipboard', 'admin', sysdate(), '', NULL, '宠物档案管理');

-- 二级菜单：健康记录
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2102, '健康记录', 2100, 2, 'health', 'pet/health/index', '', 1, 0, 'C', '0', '0', 'biz:health:list', 'documentation', 'admin', sysdate(), '', NULL, '宠物健康记录');

-- 二级菜单：健康预警
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2103, '健康预警', 2100, 3, 'alert', 'pet/alert/index', '', 1, 0, 'C', '0', '0', 'biz:alert:list', 'warning', 'admin', sysdate(), '', NULL, '宠物健康预警');

-- 二级菜单：社交推荐
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2104, '社交推荐', 2100, 4, 'social', 'pet/social/index', '', 1, 0, 'C', '0', '0', 'biz:social:list', 'star', 'admin', sysdate(), '', NULL, '宠物社交推荐');

-- 按钮权限：宠物档案
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2111, '宠物档案查询', 2101, 1, '#', '', '', 1, 0, 'F', '0', '0', 'biz:pet:query', '#', 'admin', sysdate(), '', NULL, '');
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2112, '宠物档案新增', 2101, 2, '#', '', '', 1, 0, 'F', '0', '0', 'biz:pet:add', '#', 'admin', sysdate(), '', NULL, '');
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2113, '宠物档案修改', 2101, 3, '#', '', '', 1, 0, 'F', '0', '0', 'biz:pet:edit', '#', 'admin', sysdate(), '', NULL, '');
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2114, '宠物档案删除', 2101, 4, '#', '', '', 1, 0, 'F', '0', '0', 'biz:pet:remove', '#', 'admin', sysdate(), '', NULL, '');

-- 按钮权限：健康记录
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2121, '健康记录查询', 2102, 1, '#', '', '', 1, 0, 'F', '0', '0', 'biz:health:query', '#', 'admin', sysdate(), '', NULL, '');
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2122, '健康记录新增', 2102, 2, '#', '', '', 1, 0, 'F', '0', '0', 'biz:health:add', '#', 'admin', sysdate(), '', NULL, '');
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES (2123, '健康记录删除', 2102, 3, '#', '', '', 1, 0, 'F', '0', '0', 'biz:health:remove', '#', 'admin', sysdate(), '', NULL, '');

-- 测试数据
INSERT INTO biz_pet_info (pet_id, owner_user_id, pet_name, pet_gender, breed, weight_kg, avatar_url, social_tags, health_note, status, create_by, update_by)
VALUES
(1, 1, '奶糖', '0', '金毛', 28.5, '', '金毛,活泼,亲人,户外', '', '0', 'admin', 'admin'),
(2, 1, '球球', '0', '边牧', 18.2, '', '聪明,活泼,飞盘,运动', '', '0', 'admin', 'admin'),
(3, 1, '豆包', '1', '布偶猫', 4.8, '', '安静,粘人,猫友好,乖巧', '', '0', 'admin', 'admin'),
(4, 1, '可乐', '0', '柯基', 12.3, '', '柯基,活泼,萌,户外', '', '0', 'admin', 'admin'),
(5, 1, '花生', '1', '英短', 5.2, '', '肥宅,美食,安静,乖巧', '', '0', 'admin', 'admin');
