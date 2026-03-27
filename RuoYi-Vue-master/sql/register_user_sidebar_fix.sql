SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1) Ensure the common role exists for newly registered users.
INSERT INTO sys_role
(role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
SELECT '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', NOW(), '注册默认角色'
WHERE NOT EXISTS (
  SELECT 1 FROM sys_role WHERE role_key = 'common' AND del_flag = '0'
);

-- 2) Ensure core pet menus exist (minimal set for normal users).
INSERT INTO sys_menu(menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
VALUES
(2100, '宠物社区', 0, 1, 'pet', NULL, NULL, 1, 0, 'M', '0', '0', NULL, 'pets', 'admin', NOW(), '宠物社区菜单'),
(2101, '宠物档案', 2100, 1, 'info', 'pet/info/index', NULL, 1, 0, 'C', '0', '0', 'biz:pet:list', 'example', 'admin', NOW(), '宠物档案'),
(2102, '健康记录', 2100, 2, 'health', 'pet/health/index', NULL, 1, 0, 'C', '0', '0', 'biz:health:list', 'edit', 'admin', NOW(), '健康记录'),
(2103, '健康预警', 2100, 3, 'alert', 'pet/alert/index', NULL, 1, 0, 'C', '0', '0', 'biz:alert:list', 'message', 'admin', NOW(), '健康预警'),
(2104, '社交推荐', 2100, 4, 'social', 'pet/social/index', NULL, 1, 0, 'C', '0', '0', 'biz:social:list', 'peoples', 'admin', NOW(), '社交推荐')
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

-- 3) Grant pet menus to common role by role_key (no hardcoded role_id assumption).
INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r
JOIN sys_menu m ON m.menu_id IN (2100, 2101, 2102, 2103, 2104)
WHERE r.role_key = 'common' AND r.del_flag = '0' AND r.status = '0';

-- 4) Backfill role for existing users without any role assignment.
INSERT INTO sys_user_role(user_id, role_id)
SELECT u.user_id, r.role_id
FROM sys_user u
JOIN sys_role r ON r.role_key = 'common' AND r.del_flag = '0' AND r.status = '0'
LEFT JOIN sys_user_role ur ON ur.user_id = u.user_id
WHERE ur.user_id IS NULL
  AND u.del_flag = '0'
  AND u.user_name <> 'admin';

SET FOREIGN_KEY_CHECKS = 1;

