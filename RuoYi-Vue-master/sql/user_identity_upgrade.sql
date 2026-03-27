SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Add third identity role: merchant service provider.
INSERT INTO sys_role
(role_id, role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
VALUES
(3, '服务商家', 'merchant', 3, '2', 1, 1, '0', '0', 'admin', NOW(), '宠物服务商家角色')
ON DUPLICATE KEY UPDATE
role_name = VALUES(role_name),
role_key = VALUES(role_key),
status = '0',
del_flag = '0',
update_by = 'admin',
update_time = NOW();

-- Add merchant test user (password follows admin for easy login test).
INSERT INTO sys_user
(user_id, dept_id, user_name, nick_name, user_type, password, status, del_flag, create_by, create_time, remark)
VALUES
(
  3,
  100,
  'pet_merchant',
  'PetMerchant',
  '01',
  (SELECT password FROM (SELECT password FROM sys_user WHERE user_id = 1 LIMIT 1) t),
  '0',
  '0',
  'admin',
  NOW(),
  '服务商家测试账号'
)
ON DUPLICATE KEY UPDATE
nick_name = VALUES(nick_name),
user_type = VALUES(user_type),
status = '0',
del_flag = '0',
update_by = 'admin',
update_time = NOW();

INSERT IGNORE INTO sys_user_role (user_id, role_id) VALUES (3, 3);

-- Grant pet community menus to merchant role, exclude audit center.
INSERT IGNORE INTO sys_role_menu(role_id, menu_id)
VALUES
(3, 2100), (3, 2101), (3, 2102), (3, 2103), (3, 2104), (3, 2105), (3, 2106),
(3, 2151), (3, 2152), (3, 2161), (3, 2162), (3, 2163);

SET FOREIGN_KEY_CHECKS = 1;
