SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Restore minimal system menu tree required for user management.
INSERT INTO sys_menu
(menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
VALUES
(1, '系统管理', 0, 1, 'system', NULL, '', 1, 0, 'M', '0', '0', '', 'system', 'admin', NOW(), '系统管理目录'),
(100, '用户管理', 1, 1, 'user', 'system/user/index', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', NOW(), '用户管理菜单')
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

INSERT IGNORE INTO sys_menu
(menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
VALUES
(1000, '用户查询', 100, 1, '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', NOW(), ''),
(1001, '用户新增', 100, 2, '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', NOW(), ''),
(1002, '用户修改', 100, 3, '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', NOW(), ''),
(1003, '用户删除', 100, 4, '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', NOW(), ''),
(1004, '用户导出', 100, 5, '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', NOW(), ''),
(1005, '用户导入', 100, 6, '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', NOW(), ''),
(1006, '重置密码', 100, 7, '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', NOW(), '');

-- For easy verification in this project, grant user management menus to all three roles.
INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
VALUES
(1, 1), (1, 100), (1, 1000), (1, 1001), (1, 1002), (1, 1003), (1, 1004), (1, 1005), (1, 1006),
(2, 1), (2, 100), (2, 1000),
(3, 1), (3, 100), (3, 1000);

SET FOREIGN_KEY_CHECKS = 1;
