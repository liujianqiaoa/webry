# 使用官方带 Java 17 和 Ubuntu 环境的基础镜像，直接避开系统层弹窗和安装限制
FROM eclipse-temurin:17-jre-jammy

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 1. 更换阿里源并只安装最基础的组件
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y fontconfig fonts-dejavu netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# 2. 把 SQL 文件夹、Jar 包和启动脚本全部复制进去
COPY sql /app/sql
COPY ruoyi-admin/target/ruoyi-admin.jar app.jar
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

EXPOSE 8080 3306

ENTRYPOINT ["/app/entrypoint.sh"]