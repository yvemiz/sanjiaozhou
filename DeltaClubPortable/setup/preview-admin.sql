INSERT INTO admin (username, password, nickname, avatar, role, phone, status, login_fail_count, deleted)
VALUES ('preview', '$2a$10$xrziRWov/keOhWKeggniVuxaXY0khzJr/X0qz57tDCl5MWo6Aie5q', '本地预览管理员', '', 'BOTH', '', 1, 0, 0)
ON DUPLICATE KEY UPDATE password=VALUES(password), nickname=VALUES(nickname), role='BOTH', status=1,
  login_fail_count=0, lock_time=NULL, deleted=0;
