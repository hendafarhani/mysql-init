-- 01_init.sql
ALTER USER 'root'@'%' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS ride_requests_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'microgo_user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON ride_requests_db.* TO 'microgo_user'@'%';

FLUSH PRIVILEGES;
