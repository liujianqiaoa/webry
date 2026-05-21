# 使用官方带完整 javac 编译链的 JDK 17 基础镜像
FROM eclipse-temurin:17-jdk-jammy

ENV DEBIAN_FRONTEND=noninteractive

# 强行锁死系统环境变量使用官方自带的 JDK 17
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /app

# 1. 💡【绝杀瘦身】：剔除了极其容易卡 502 的 netcat-openbsd 组件，进一步精简安装包
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && \
    apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        fontconfig \
        fonts-dejavu \
        openssh-server \
        git \
        procps \
        wget \
        ca-certificates \
        mysql-server && \
    rm -rf /var/lib/apt/lists/*

# 2. 下载并安装独立绿色版 Maven 3.9.6
RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar -xzf /tmp/maven.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-3.9.6/bin/mvn /usr/bin/mvn && \
    rm -f /tmp/maven.tar.gz

# 3. 强行固化 Maven 的环境指向，死锁 Java 17
ENV MAVEN_HOME=/opt/apache-maven-3.9.6
RUN mkdir -p /etc/maven && \
    echo "JAVA_HOME=/opt/java/openjdk" > /etc/maven/mavenrc && \
    echo "export JAVA_HOME=/opt/java/openjdk" >> /etc/bash.bashrc && \
    echo "export PATH=/opt/java/openjdk/bin:\$PATH" >> /etc/bash.bashrc && \
    echo "export MAVEN_HOME=/opt/apache-maven-3.9.6" >> /etc/bash.bashrc

# 4. 配置 SSH 服务
RUN mkdir /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# 5. 拷贝当前目录所有文件到容器中
COPY . /app/

RUN chmod +x /app/entrypoint.sh

EXPOSE 8080 3306 22

ENTRYPOINT ["/app/entrypoint.sh"]