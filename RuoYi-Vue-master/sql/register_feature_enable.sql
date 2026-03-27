SET NAMES utf8mb4;

-- Enable frontend registration entry and backend /register endpoint.
UPDATE sys_config
SET config_value = 'true',
    update_by = 'admin',
    update_time = NOW()
WHERE config_key = 'sys.account.registerUser';

