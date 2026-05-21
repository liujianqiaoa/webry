git add .;git commit -m "fix:ruoyi";git branch;git push -u origin main;

docker build --no-cache -t dogfooding .

docker images

docker run -d -p 8080:8080 --name web my-app:v1

# 分别启动 5 个容器，映射宿主机 2221-2225 端口
docker run -d -p 2231:8080 -p 2221:22 --name env-1 dogfooding
docker run -d -p 2232:8080 -p 2222:22 --name env-2 dogfooding
docker run -d -p 2233:8080 -p 2223:22 --name env-3 dogfooding
docker run -d -p 2234:8080 -p 2224:22 --name env-4 dogfooding
docker run -d -p 2235:8080 -p 2225:22 --name env-5 dogfooding

docker logs web

docker logs --tail 20 env-1

mvn clean

mvn install

mvn package


git add .;git diff --cached > /app/p1-r1-gpt5.4.patch
git add .;git diff --cached > /app/p1-r2-gemini-3.1.patch
git add .;git diff --cached > /app/p1-r3-deepseek-v4.patch
git add .;git diff --cached > /app/p1-r4-doubao-seed-2.0.patch
git add .;git diff --cached > /app/p1-r5-minmax-m2.7.patch



docker cp env-1:/app/p1-r1-gpt5.4.patch ./
docker cp env-1:/app/p1-r2-gemini-3.1.patch ./
docker cp env-1:/app/p1-r3-deepseek-v4.patch ./
docker cp env-1:/app/p1-r1-doubao-seed-2.0.patch ./
docker cp env-1:/app/p1-r5-minmax-m2.7.patch ./


java -Xms256m -Xmx512m -Dfile.encoding=utf-8 -Djava.awt.headless=true -jar ./ruoyi-admin/target/ruoyi-admin.jar


