git add .;git commit -m "fix:ruoyi";git branch;git push -u origin main;

docker build -t my-app:v1 .

docker images

docker run -d -p 8080:8080 --name web my-app:v1
