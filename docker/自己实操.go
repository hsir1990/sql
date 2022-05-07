windows安装桌面版
1.下载地址  https://docs.docker.com/desktop/windows/install/
2.需要一个安装微软开发的Hyper-V虚拟机,先装虚拟器，在转docker，去任务管理器查看虚拟器是否开启，如果有安卓等虚拟器就不用安装了，
然后加入自己的虚拟器不能全选，在任务管理没有开启虚拟化，需要进入dios，联想笔记本按F2，然后再升级了一下wsl，其实根据docker的错误提示来就行，
，同时还按了linux的承载，然后开始虚拟化可用，在进行安装docker


需要自己去设计镜像源

3.安装redis
redis现在也有win版本了
去https://hub.docker.com/_/redis搜redis


docker run -d -p 6379:6379 --name redis redis:latest
--name给容器命名
-d在后台运行这个容器
-p 把端口暴露出来
前面的6379是宿主机的

可知在docker桌面版上使用命令行
4.安装安装 Wordpress ，其中有依赖
我们通过docker-compose.yml  操作

用powerShell打开，输入 docker-compose up -d

5制作自己的镜像  在test-docker中操作

编写 Dockerfile
#需要node，以nond为底
FROM node:11
#一个维护者
MAINTAINER hsir1990

# 复制代码
ADD . /app

# 设置容器启动后的默认运行目录
WORKDIR /app

# 运行命令，安装依赖
# RUN 命令可以有多个，但是可以用 && 连接多个命令来减少层级。
# 例如 RUN npm install && cd /app && mkdir logs
RUN npm install --registry=https://registry.npm.taobao.org

# CMD 指令只能一个，是容器启动后执行的命令，算是程序的入口。
# 如果还需要运行其他命令可以用 && 连接，也可以写成一个shell脚本去执行。
# 例如 CMD cd /app && ./start.sh
CMD node app.js






Build 为镜像（安装包）和运行，打包
编译 docker build -t test:v1 .
 test 项目的名字，v1版本号  .点代表当前目录
 -t指定名字和版本


 运行 docker run -p 8080:8080 --name test-hello test:v1
 可以运行 自己的项目

 6几种挂载方式
 
 bind mount 直接把宿主机目录映射到容器内，适合挂代码目录和配置文件。可挂到多个容器上

 volume 由容器创建和管理，创建在宿主机，所以删除容器不会丢失，官方推荐，更高效，Linux 文件系统，适合存储数据库数据。可挂到多个容器上
 
 tmpfs mount 适合存储临时文件，存宿主机内存中。不可多容器共享。


 
 挂载演示  （注意路径）
bind mount 方式用绝对路径 -v D:/code:/app

volume 方式，只需要一个名字 -v db-data:/app

示例：
docker run -p 8080:8080 --name test-hello -v D:/code:/app -d test:v1

 docker run -p 8081:8080 --name test-hello -v F:/work/go/src/sql/docker/test-docker:/app -d test:v1


 修改的代码，在docker已经变了，但是需要重启才能生效

 7.多容器访问
 --容器与容器不通，所以要创建虚拟网络


 创建一个名为test-net的网络：
docker network create test-net

运行 Redis 在 test-net 网络中，别名redis
docker run -d --name redis --network test-net --network-alias redis redis:latest

运行 Web 项目，使用同个网络
docker run -p 8082:8080 --name test -v F:/work/go/src/sql/docker/test-docker:/app --network test-net -d test:v1



docker ps 查看当前运行中的容器
docker images 查看镜像列表
docker rm container-id 删除指定 id 的容器
docker stop/start container-id 停止/启动指定 id 的容器
docker rmi image-id 删除指定 id 的镜像
docker volume ls 查看 volume 列表
docker network ls 查看网络列表
8.docker-compose
桌面版本就不用在安装一遍了，docker-compose目的也是为了容器之间互通

编写脚本
要把项目依赖的多个服务集合到一起，我们需要编写一个docker-compose.yml文件，描述依赖哪些服务
参考文档：https://docs.docker.com/compose/

version: "3.7"

services:
  app:
    build: ./  //构建
    ports:
      - 80:8080 //设置端口
    volumes:
      - ./:/app
    environment:
      - TZ=Asia/Shanghai
  redis:
    image: redis:5.0.13  //直接去库里获取
    volumes:
      - redis:/data   //设置挂载
    environment:
      - TZ=Asia/Shanghai  //设置上海时间

volumes:
  redis:
容器默认时间不是北京时间，增加 TZ=Asia/Shanghai 可以改为北京时间


跑起来
在docker-compose.yml 文件所在目录，执行：docker-compose up就可以跑起来了。
命令参考：https://docs.docker.com/compose/reference/up/

在后台运行只需要加一个 -d 参数docker-compose up -d
查看运行状态：docker-compose ps
停止运行：docker-compose stop
重启：docker-compose restart
重启单个服务：docker-compose restart service-name
进入容器命令行：docker-compose exec service-name sh
查看容器运行log：docker-compose logs [service-name]

9.发布和部署
--先去hub.docker.com去创建一个自己的库

先登录
docker login -u hsir1990
win下登陆了用 winpty docker login -u hsir1990


新建一个tag，名字必须跟你注册账号一样
docker tag test:v1 hsir1990/test:v1

推上去
docker push hsir1990/test:v1

部署试下
docker run -dp 8083:8080 hsir1990/test:v1

docker-compose 中也可以直接用这个镜像了
version: "3.7"

services:
  app:
#    build: ./
    image: helloguguji/test:v1  //直接用的镜像
    ports:
      - 80:8080
    volumes:
      - ./:/app
    environment:
      - TZ=Asia/Shanghai
  redis:
    image: redis:5.0.13
    volumes:
      - redis:/data
    environment:
      - TZ=Asia/Shanghai

volumes:
  redis:



  9备份和迁移数据
  迁移方式介绍
  容器中的数据，如果没有用挂载目录，删除容器后就会丢失数据。
  前面我们已经讲解了如何 挂载目录
  如果你是用bind mount直接把宿主机的目录挂进去容器，那迁移数据很方便，直接复制目录就好了
  如果你是用volume方式挂载的，由于数据是由容器创建和管理的，需要用特殊的方式把数据弄出来。
  
  本文档课件配套 视频教程
  
  备份和导入 Volume 的流程
  备份：
  
  运行一个 ubuntu 的容器，挂载需要备份的 volume 到容器，并且挂载宿主机目录到容器里的备份目录。
  运行 tar 命令把数据压缩为一个文件
  把备份文件复制到需要导入的机器
  导入：
  
  运行 ubuntu 容器，挂载容器的 volume，并且挂载宿主机备份文件所在目录到容器里
  运行 tar 命令解压备份文件到指定目录
  备份 MongoDB 数据演示
  运行一个 mongodb，创建一个名叫mongo-data的 volume 指向容器的 /data 目录
  docker run -p 27018:27017 --name mongo -v mongo-data:/data -d mongo:4.4
  
  运行一个 Ubuntu 的容器，挂载mongo容器的所有 volume，映射宿主机的 backup 目录到容器里面的 /backup 目录，然后运行 tar 命令把数据压缩打包
  docker run --rm --volumes-from mongo -v d:/backup:/backup ubuntu tar cvf /backup/backup.tar /data/
  
  最后你就可以拿着这个 backup.tar 文件去其他地方导入了。
  
  恢复 Volume 数据演示
  运行一个 ubuntu 容器，挂载 mongo 容器的所有 volumes，然后读取 /backup 目录中的备份文件，解压到 /data/ 目录
  docker run --rm --volumes-from mongo -v d:/backup:/backup ubuntu bash -c "cd /data/ && tar xvf /backup/backup.tar --strip 1"
  注意，volumes-from 指定的是容器名字
  strip 1 表示解压时去掉前面1层目录，因为压缩时包含了绝对路径
  
  觉得老师讲得不错的话，记得点赞、关注、分享，鼓励下老师
  你们的鼓励会让老师更加有动力继续创造更多更好的内容
