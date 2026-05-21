FROM eclipse-temurin:17-jre-jammy

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 1. 更换阿里源并安装最基础的组件，同时直接把 openssh-server 和 git、procps 装好
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y fontconfig fonts-dejavu netcat-openbsd openssh-server git procps maven && \
    rm -rf /var/lib/apt/lists/*

# 2. 【核心注入】一键配置容器内的 SSH 服务
RUN mkdir /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# 3. 把 SQL 文件夹、Jar 包和启动脚本全部复制进去
COPY sql /app/sql
COPY ruoyi-admin/target/ruoyi-admin.jar app.jar
COPY entrypoint.sh /app/entrypoint.sh
COPY . /app/


RUN chmod +x /app/entrypoint.sh

# 暴露 8080 (若依), 3306 (MySQL), 22 (SSH)
EXPOSE 8080 3306 22

ENTRYPOINT ["/app/entrypoint.sh"]