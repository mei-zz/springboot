SET NAMES utf8mb4;

INSERT INTO sys_menu(menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
VALUES
(2100, '宠物社区', 0, 1, 'pet', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'pets', 'admin', NOW(), '宠物社区菜单'),
(2101, '宠物档案', 2100, 1, 'info', 'pet/info/index', NULL, 1, 0, 'C', '0', '0', 'biz:pet:list', 'example', 'admin', NOW(), '宠物档案'),
(2102, '健康记录', 2100, 2, 'health', 'pet/health/index', NULL, 1, 0, 'C', '0', '0', 'biz:health:list', 'edit', 'admin', NOW(), '健康记录'),
(2103, '健康预警', 2100, 3, 'alert', 'pet/alert/index', NULL, 1, 0, 'C', '0', '0', 'biz:alert:list', 'message', 'admin', NOW(), '健康预警'),
(2104, '社交推荐', 2100, 4, 'social', 'pet/social/index', NULL, 1, 0, 'C', '0', '0', 'biz:social:list', 'peoples', 'admin', NOW(), '社交推荐'),
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

INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
VALUES (1, 2100), (1, 2101), (1, 2102), (1, 2103), (1, 2104), (1, 2105), (1, 2106), (1, 2107);

INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
VALUES (2, 2100), (2, 2101), (2, 2102), (2, 2103), (2, 2104), (2, 2105), (2, 2106);

