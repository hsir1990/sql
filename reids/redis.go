一般redis不让其他地方连接，因为服务上的代码直接可以调用就好了，别人调用就很不友好了






https://blog.csdn.net/qq_32907195/article/details/121224784

设置redis访问（AUTH）密码

大叶子不小

于 2021-11-09 11:39:01 发布

55
 收藏
文章标签： redis
版权
在服务器上，这里以linux服务器为例，为redis配置密码。

1.第一种方式 （当前这种linux配置redis密码的方法是一种临时的，如果redis重启之后密码就会失效，）

（1）首先进入redis，如果没有开启redis则需要先开启：
[root@iZ94jzcra1hZ bin]# redis-cli -p 6379
127.0.0.1:6379> 
（2）查看当前redis有没有设置密码：
127.0.0.1:6379> config get requirepass
1) "requirepass"
2) ""
（3）为以上显示说明没有密码，那么现在来设置密码：
127.0.0.1:6379> config set requirepass abcdefg
OK
127.0.0.1:6379> 
（4）再次查看当前redis就提示需要密码：
127.0.0.1:6379> config get requirepass
(error) NOAUTH Authentication required.
127.0.0.1:6379>

2.第二种方式 （永久方式）
需要永久配置密码的话就去redis.conf的配置文件中找到requirepass这个参数，如下配置：

修改redis.conf配置文件　　

# requirepass foobared
requirepass 123   指定密码123

保存后重启redis就可以了

连接redis

1.redis-cli连接redis

[root@iZ2ze3zda3caeyx6pn7c5zZ bin]# redis-cli
127.0.0.1:6379> keys *
(error) NOAUTH Authentication required.
127.0.0.1:6379> auth 123        //指定密码
OK
127.0.0.1:6379> keys *
1) "a"
2) "cit"
3) "clist"
4) "1"
127.0.0.1:6379>
————————————————
版权声明：本文为CSDN博主「大叶子不小」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_32907195/article/details/121224784



https://help.aliyun.com/document_detail/336852.html?spm=a2c4g.11186623.0.0.5dd3602ahAAv6M
在RDMA增强型实例上部署Redis
更新时间：2021-11-09 17:42
产品详情
相关技术圈
我的收藏
使用弹性RDMA网卡（ERI）可以获得超低的延迟，更快地处理请求。本文介绍在RDMA增强型实例上分别部署eRDMA版Redis和社区版Redis，并压测处理请求的能力。

部署eRDMA版Redis
本步骤中以实例A作为Redis客户端，实例B作为Redis服务端。eRDMA版Redis需要配合已启用ERI的网卡使用（本文中简称RDMA网卡），实例配置示例如下：
规格：ecs.c7re.8xlarge
镜像：Alibaba Cloud Linux 2.1903 LTS 64位
实例属于同一安全组，默认内网互通
实例挂载了RDMA网卡，设备号为eth1
说明 请确保实例已完成ERI相关的配置，具体操作，请参见使用ERI。
实例B RDMA网卡的主私有IP：192.168.5.44
远程连接实例A和实例B。
分别为实例A和实例B安装eRDMA版Redis。
下载eRDMA版Redis的安装包。
wget https://redis-demo.oss-cn-hangzhou.aliyuncs.com/redis-rdma-beta1.tar.gz
解压安装包。
tar -xf redis-rdma-beta1.tar.gz
解压后得到redis-server、redis-cli、redis-benchmark文件。
查看实例的路由表，如果未优先使用RDMA网卡，则需要修改路由表设置。
示例如下图所示，实例所在网段为192.168.5.0，但192.168.5.0网段收发请求会优先使用主网卡（eth0），因此需要修改路由表，确保优先使用RDMA网卡（eth1）。route
修改路由表的命令示例如下：
route del -net 192.168.5.0 netmask 255.255.255.0 metric 0 dev eth0 && \
route add -net 192.168.5.0 netmask 255.255.255.0 metric 1000 dev eth0
在实例B上启动Redis服务端。
./redis-server --rdma-bind 192.168.5.44 --rdma-port 6389 --protected-mode no --save
说明 192.168.5.44为实例B RDMA网卡的主私有IP，6389为需要监听的端口，请您在自行测试时按实际情况替换。
您也可以使用taskset命令将进程运行在指定的CPU上，例如：
taskset -c 0-1 ./redis-server --rdma-bind 192.168.5.44 --rdma-port 6389 --protected-mode no --save
start-redis-rdma
在Redis客户端上测试连接和访问Redis服务端。
连接Redis服务端。
./redis-cli -h 192.168.5.44 -p 6389 --rdma
使用redis-benchmark进行压测。
以下命令模拟从100个客户端向服务端发送1,000,000次SET命令的请求：
./redis-benchmark -h 192.168.5.44 -p 6389 --rdma -n 1000000 -t set -c 100
您也可以启动多个压测进程进行混合压测，参考以上步骤再部署1个Redis客户端，在2个Redis客户端上分别启动多个压测进程，然后在Redis服务端上查看OPS。
在Redis客户端上同时启动8个SET压测进程的示例命令：
./redis-benchmark -h 192.168.5.44 -p 6389 --rdma -n 100000000 -t set --threads 8 -c 100
在Redis客户端上同时启动8个GET压测进程的示例命令：
./redis-benchmark -h 192.168.5.44 -p 6389 --rdma -n 100000000 -t get --threads 8 -c 100
在Redis服务端上查看OPS的示例命令：
./redis-cli -h 192.168.5.44  -p 6389 --rdma info | grep instantaneous_ops_per_sec
说明 请新打开一个远程连接窗口，然后输入查看命令。
部署社区版Redis
本步骤中以实例C作为Redis客户端，实例D作为Redis服务端。实例配置示例如下：
规格：ecs.c7re.8xlarge
镜像：Alibaba Cloud Linux 2.1903 LTS 64位
实例属于同一安全组，默认内网互通
实例D主网卡的主私有IP：192.168.5.49
远程连接实例C和实例D。
分别为实例C和实例D安装社区版Redis。
下载社区版Redis的安装包。
wget https://github.com/redis/redis/archive/refs/tags/6.2.5.zip
更多版本，请参见Redis Github项目地址。

解压安装包并进入文件目录。
unzip 6.2.5.zip && cd redis-6.2.5 
编译安装Redis。
make -j
在实例D上启动Redis服务端。
./src/redis-server --bind 192.168.5.49 --port 6379 --protected-mode no --save
说明 192.168.5.49为实例D主网卡的主私有IP，6379为需要监听的端口，请您在自行测试时按实际情况替换。
community-redis-server
在Redis客户端上测试连接和访问Redis服务端。
连接Redis服务端。
./src/redis-cli -h 192.168.5.49 -p 6379
使用redis-benchmark进行压测。
以下命令模拟从100个客户端向服务端发送1,000,000次SET命令的请求：
./src/redis-benchmark -h 192.168.5.49 -p 6379 -n 1000000 -t set -c 100
您也可以启动多个压测进程进行混合压测，参考以上步骤再部署1个Redis客户端，在2个Redis客户端上分别启动多个压测进程，然后在Redis服务端上查看OPS。
在Redis客户端上同时启动8个SET压测进程的示例命令：
./src/redis-benchmark -h 192.168.5.49 -p 6379 -n 100000000 -t set --threads 8 -c 100
在Redis客户端上同时启动8个GET压测进程的示例命令：
./src/redis-benchmark -h 192.168.5.49 -p 6379 -n 1000000 -t get --threads 8 -c 100
在Redis服务端上查看OPS的示例命令：
./src/redis-cli -h 192.168.5.49 -p 6379 info | grep instantaneous_ops_per_sec