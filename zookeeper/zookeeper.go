假如王老师有100T的资料要放到服务器上，而你的服务器只有1个T，所有需要100台机器构成，这样就形成了分布式服务器

java分布式用到的框架
pig  hive  hadoop

zookeeper作为铲屎官为这些动物服务

znode  只能存够1Mb，不能存大量的数据

nginx也能让网络通过域名分配去访问哪个服务器

zookeeper提供了软负载均衡，nginx最牛逼的就是提供负载均衡

3个服务器安装3个zookeeper，那么10台服务器呢?


xsync同步到分发到其他服务器的脚本，需要安装  yum install -y rsync ，配好后，直接用一个命令就可以分发了

写流程的时候，只要半数成功，就会通知成功

客户端 写的接入是floller，floller没有写权限，需要转给leader，然后让leader去写，最后成功了，在让follower告诉客户端