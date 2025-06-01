CREATE DATABASE finascope;
CREATE USER 'finascope_app'@'%' IDENTIFIED BY 'finascope_app_password';
GRANT ALL PRIVILEGES ON finascope.* TO 'finascope_app'@'%';
FLUSH PRIVILEGES;
