FROM amazoncorretto:17-alpine-jdk

WORKDIR /app

# 验证当前 Java 版本（可保留）
RUN java -version

# —— 核心修改 1：在 alpine 系统中安装若依所需的字体库 ——
RUN apk add --no-cache fontconfig ttf-dejavu

# 复制并重命名 jar 包
COPY ruoyi-admin/target/ruoyi-admin.jar app.jar

# —— 核心修改 2：建议将 CMD 改为 ENTRYPOINT，并加入 Java 无头模式参数 ——
ENTRYPOINT ["java", "-Djava.awt.headless=true", "-jar", "app.jar"]
