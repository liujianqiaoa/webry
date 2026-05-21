#!/bin/bash
set -e

# 强制在运行期注入环境，死锁 Java 17
export JAVA_HOME=/opt/java/openjdk
export PATH=$JAVA_HOME/bin:$PATH

# 率先在后台拉起 SSH 服务，供 Trae 连接
echo "=== 正在启动 SSH 服务，供 Trae 连接 ==="
service ssh start

# 验证环境
echo "=== 容器当前环境验证 ==="
java -version
mvn -v

# 1. 确保 MySQL 服务处于启动状态
echo "=== 正在尝试拉起 MySQL 服务 ==="
service mysql start || true

# 改用纯原生 bash 探测 3306 端口是否开放
echo "=== 等待 MySQL 端口 3306 响应... ==="
FOR_COUNT=0
while ! (echo > /dev/tcp/127.0.0.1/3306) >/dev/null 2>&1; do
    sleep 1
    FOR_COUNT=$((FOR_COUNT+1))
    if [ $FOR_COUNT -gt 30 ]; then
        echo "❌ 错误：MySQL 启动超时！"
        exit 1
    fi
done

# 2. 检测 ry 业务数据库状态
echo "=== 正在检测 ry 业务数据库状态 ==="
DB_EXISTS=$(mysql -u root -proot -e "SHOW DATABASES LIKE 'ry';" 2>/dev/null || mysql -u root -e "SHOW DATABASES LIKE 'ry';" 2>/dev/null || echo "")

if [ -z "$DB_EXISTS" ]; then
    echo "=== 🚨 检测到 ry 数据库不存在，开始进行首次初始化及数据导入 ==="

    # 尝试无密码或旧密码修改 localhost 的 root 密码
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;" 2>/dev/null || \
    mysql -u root -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;" 2>/dev/null

    # 💡【核心修正】：采用 MySQL 8.0 纯原生标准的 IF NOT EXISTS 语法，彻底移除不兼容的 Linux 杂质
    mysql -u root -proot -e "
    CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
    ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
    CREATE DATABASE IF NOT EXISTS \`ry\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    FLUSH PRIVILEGES;
    "

    # SQL 路径保底兼容判断
    SQL_DIR="/app/sql"
    if [ ! -d "$SQL_DIR" ] && [ -d "/app/environment/sql" ]; then SQL_DIR="/app/environment/sql"; fi
    if [ ! -d "$SQL_DIR" ] && [ -d "../sql" ]; then SQL_DIR="../sql"; fi

    echo "=== 开始导入若依核心 SQL 脚本 ==="
    if [ -f "$SQL_DIR/ry_20260319.sql" ]; then
        echo "正在导入 ry_20260319.sql ..."
        mysql -u root -proot ry < "$SQL_DIR/ry_20260319.sql"
    elif ls $SQL_DIR/ry_*.sql >/dev/null 2>&1; then
        echo "正在通配导入 ry_*.sql ..."
        mysql -u root -proot ry < $SQL_DIR/ry_*.sql
    else
        echo "❌ 警告：未找到主业务 SQL 脚本！"
    fi

    if [ -f "$SQL_DIR/quartz.sql" ]; then
        echo "正在导入 quartz.sql ..."
        mysql -u root -proot ry < "$SQL_DIR/quartz.sql"
    fi

    echo "=== ✨ 数据库初始化及若依数据导入大获全胜！ ==="
else
    echo "=== 已经存在 ry 业务数据库，跳过初始化，直接保持运行 ==="
fi

# 3. 启动若依 Java 后端或死锁守卫
if [ -f "/app/app.jar" ]; then
    echo "=== 正在拉起 RuoYi 后端服务 ==="
    java -Dfile.encoding=utf-8 -Djava.awt.headless=true -jar /app/app.jar
else
    echo "=== 💡 未在 /app 下检测到预编译的 app.jar，强行启动后台守护，静待 Trae 连入手动进行 mvn 编译 ==="
    tail -f /dev/null
fi