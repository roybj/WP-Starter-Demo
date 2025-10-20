-- WordPress Development Database Initialization

-- Create additional databases if needed
CREATE DATABASE IF NOT EXISTS wordpress_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant permissions for test database
GRANT ALL PRIVILEGES ON wordpress_test.* TO 'wp_user'@'%';

-- Create additional development user
CREATE USER IF NOT EXISTS 'dev_user'@'%' IDENTIFIED BY 'dev_password';
GRANT ALL PRIVILEGES ON wordpress_dev.* TO 'dev_user'@'%';
GRANT ALL PRIVILEGES ON wordpress_test.* TO 'dev_user'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- MySQL 8.0+ settings for WordPress optimization
-- Note: innodb_file_format and innodb_large_prefix were removed in MySQL 8.0
-- These settings are now defaults in MySQL 8.0+