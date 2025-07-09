-- init.sql
ALTER USER 'root'@'%' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON . TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS ride_sharing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'microgo_user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON ride_sharing.* TO 'microgo_user'@'%';

FLUSH PRIVILEGES;