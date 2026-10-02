CREATE DATABASE IF NOT EXISTS perpus_009 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci; 
 
CREATE USER IF NOT EXISTS 'dev_009'@'localhost' 
IDENTIFIED BY 'josjisjos'; 
 
GRANT ALL PRIVILEGES 
ON perpus_009.* 
TO 'dev_009'@'localhost';