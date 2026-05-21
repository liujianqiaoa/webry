git add .;git commit -m "fix:ruoyi";git branch;git push -u origin main;

docker build --no-cache -t dogfooding .

docker images

docker run -d -p 8080:8080 --name web my-app:v1

# 分别启动 5 个容器，映射宿主机 2221-2225 端口
docker run -d -p 2221:8080 -p 2222:22 --name env-1 dogfooding
docker run -d -p 2222:8080 --name env-2 dogfooding
docker run -d -p 2223:8080 --name env-3 dogfooding
docker run -d -p 2224:8080 --name env-4 dogfooding
docker run -d -p 2225:8080 --name env-5 dogfooding

docker logs web

docker logs --tail 20 env-1

mvn clean

mvn install

mvn package



