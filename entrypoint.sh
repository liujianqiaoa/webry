#!/bin/bash
set -e

# 💡 【新增】：容器启动时，率先在后台把刚才配置好的 SSH 服务跑起来
echo "=== 正在启动 SSH 服务，供 Trae 连接 ==="
service ssh start

# 1. 动态安装 MySQL 8
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "=== 正在首次启动，安装并初始化 MySQL 8.0 ==="
    apt-get update && apt-get install -y mysql-server

    # 启动数据库
    service mysql start

    # 等待 MySQL 完全就绪
    while ! nc -z localhost 3306; do sleep 1; done

    echo "=== 开始配置 MySQL 权限及导入若依初始数据 ==="
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"
    mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS \`ry\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
    mysql -u root -proot ry < /app/sql/ry_20260319.sql
    mysql -u root -proot ry < /app/sql/quartz.sql
    echo "=== 数据库初始化大获全胜！ ==="
else
    # 非第一次运行，直接启动存在的 MySQL 服务即可
    service mysql start
    while ! nc -z localhost 3306; do sleep 1; done
fi

# 2. 启动若依 Java 后端
echo "=== 正在拉起 RuoYi 后端服务 ==="
java -Djava.awt.headless=true -jar /app/app.jar