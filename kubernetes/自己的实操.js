1.用命令行安装minikube

New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing


$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath.Split(';') -inotcontains 'C:\minikube'){ `
  [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine) `
}



-----1.每个服务器都要安装k8s
-----开始安装
-----你也可以试下 这个项目，用脚本快速搭建 K8S 裸机集群
-----当然，为了更好的理解，你应该先手动搭建一次

# 每个节点分别设置对应主机名
hostnamectl set-hostname master
hostnamectl set-hostname node1
hostnamectl set-hostname node2
# 所有节点都修改 hosts
vim /etc/hosts
172.16.32.2 node1
172.16.32.6 node2
172.16.0.4 master
# 所有节点关闭 SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
所有节点确保防火墙关闭
systemctl stop firewalld
systemctl disable firewalld

添加安装源（所有节点）

# 添加 k8s 安装源
cat <<EOF > kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
mv kubernetes.repo /etc/yum.repos.d/

# 添加 Docker 安装源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
安装所需组件（所有节点）
yum install -y kubelet kubeadm kubectl docker-ce

启动 kubelet、docker，并设置开机启动（所有节点）

systemctl enable kubelet
systemctl start kubelet
systemctl enable docker
systemctl start docker
修改 docker 配置（所有节点）

# kubernetes 官方推荐 docker 等使用 systemd 作为 cgroupdriver，否则 kubelet 启动不了
cat <<EOF > daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": ["https://ud6340vz.mirror.aliyuncs.com"]
}
EOF
mv daemon.json /etc/docker/

# 重启生效
systemctl daemon-reload
systemctl restart docker
用 kubeadm 初始化集群（仅在主节点跑），

# 初始化集群控制台 Control plane
# 失败了可以用 kubeadm reset 重置
kubeadm init --image-repository=registry.aliyuncs.com/google_containers

# 记得把 kubeadm join xxx 保存起来
# 忘记了重新获取：kubeadm token create --print-join-command

# 复制授权文件，以便 kubectl 可以有权限访问集群
# 如果你其他节点需要访问集群，需要从主节点复制这个文件过去其他节点
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 在其他机器上创建 ~/.kube/config 文件也能通过 kubectl 访问到集群
有兴趣了解 kubeadm init 具体做了什么的，可以 查看文档

把工作节点加入集群（只在工作节点跑）

kubeadm join 172.16.32.10:6443 --token xxx --discovery-token-ca-cert-hash xxx
安装网络插件，否则 node 是 NotReady 状态（主节点跑）

# 很有可能国内网络访问不到这个资源，你可以网上找找国内的源安装 flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
查看节点，要在主节点查看（其他节点有安装 kubectl 也可以查看）
image.png

-----上面的操作主要是，给每个节点命名，包括master，
-----然后修改每个主机的host，
-----安装所需要的组件
-----给master主机点安装初始化集群
-----将工作节点加入集群
-----安装网络插件让他们跑起来

-----2.部署到集群中

-----运行一个pod
kubectl run testapp --image=ccr.ccs.tencentyun.com/k8s-tutorial/test-k8s:v1


Pod
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  # 定义容器，可以多个
  containers:
    - name: test-k8s # 容器名字
      image: ccr.ccs.tencentyun.com/k8s-tutorial/test-k8s:v1 # 镜像
Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  # 部署名字
  name: test-k8s
spec:
  replicas: 2
  # 用来查找关联的 Pod，所有标签都匹配才行
  selector:
    matchLabels:
      app: test-k8s
  # 定义 Pod 相关数据
  template:
    metadata:
      labels:
        app: test-k8s
    spec:
      # 定义容器，可以多个
      containers:
      - name: test-k8s # 容器名字
        image: ccr.ccs.tencentyun.com/k8s-tutorial/test-k8s:v1 # 镜像


-----有3种方式创建pod，其中Deployment 通过 label 关联起来 Pods


部署应用演示
部署一个 nodejs web 应用，源码地址：Github

# 部署应用
kubectl apply -f app.yaml
# 查看 deployment
kubectl get deployment
# 查看 pod
kubectl get pod -o wide
# 查看 pod 详情
kubectl describe pod pod-name
# 查看 log
kubectl logs pod-name
# 进入 Pod 容器终端， -c container-name 可以指定进入哪个容器。
kubectl exec -it pod-name -- bash
# 伸缩扩展副本
kubectl scale deployment test-k8s --replicas=5
# 把集群内端口映射到节点
kubectl port-forward pod-name 8090:8080
# 查看历史
kubectl rollout history deployment test-k8s
# 回到上个版本
kubectl rollout undo deployment test-k8s
# 回到指定版本
kubectl rollout undo deployment test-k8s --to-revision=2
# 删除部署
kubectl delete deployment test-k8s
Pod 报错解决
如果你运行 kubectl describe pod/pod-name 发现 Events 中有下面这个错误

networkPlugin cni failed to set up pod "test-k8s-68bb74d654-mc6b9_default" network: open /run/flannel/subnet.env: no such file or directory
在每个节点创建文件/run/flannel/subnet.env写入以下内容，配置后等待一会就好了

FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
更多命令
# 查看全部
kubectl get all
# 重新部署
kubectl rollout restart deployment test-k8s
# 命令修改镜像，--record 表示把这个命令记录到操作历史中
kubectl set image deployment test-k8s test-k8s=ccr.ccs.tencentyun.com/k8s-tutorial/test-k8s:v2-with-error --record
# 暂停运行，暂停后，对 deployment 的修改不会立刻生效，恢复后才应用设置
kubectl rollout pause deployment test-k8s
# 恢复
kubectl rollout resume deployment test-k8s
# 输出到文件
kubectl get deployment test-k8s -o yaml >> app2.yaml
# 删除全部资源
kubectl delete all --all
更多官网关于 Deployment 的介绍

将 Pod 指定到某个节点运行：nodeselector
限定 CPU、内存总量：文档

apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
工作负载分类
Deployment
适合无状态应用，所有pod等价，可替代
StatefulSet
有状态的应用，适合数据库这种类型。
DaemonSet
在每个节点上跑一个 Pod，可以用来做节点监控、节点日志收集等
Job & CronJob
Job 用来表达的是一次性的任务，而 CronJob 会根据其时间规划反复运行。
文档

现存问题
每次只能访问一个 pod，没有负载均衡自动转发到不同 pod
访问还需要端口转发
Pod 重创后 IP 变了，名字也变了
下节我们讲解如何解决。

-----创建多个pod是他是一个一个的启动，一个一个的销毁，一个k8s节点可以有多个pod，一个 Pod 可以包含一个或多个容器
-----以上是各种命令的使用，多注意deployment的使用


-----3.server

特性
Service 通过 label 关联对应的 Pod
Servcie 生命周期不跟 Pod 绑定，不会因为 Pod 重创改变 IP
提供了负载均衡功能，自动转发流量到不同 Pod
可对集群外部提供访问端口
集群内部可通过服务名字访问


创建 Service
创建 一个 Service，通过标签test-k8s跟对应的 Pod 关联上
service.yaml

apiVersion: v1
kind: Service
metadata:
  name: test-k8s
spec:
  selector:
    app: test-k8s
  type: ClusterIP
  ports:
    - port: 8080        # 本 Service 的端口
      targetPort: 8080  # 容器端口
应用配置 kubectl apply -f service.yaml
查看服务 kubectl get svc
kubernetes service
查看服务详情 kubectl describe svc test-k8s，可以发现 Endpoints 是各个 Pod 的 IP，也就是他会把流量转发到这些节点。
kubernetes endpoints

服务的默认类型是ClusterIP，只能在集群内部访问，我们可以进入到 Pod 里面访问：
kubectl exec -it pod-name -- bash
curl http://test-k8s:8080

如果要在集群外部访问，可以通过端口转发实现（只适合临时测试用）：
kubectl port-forward service/test-k8s 8888:8080

如果你用 minikube，也可以这样minikube service test-k8s

对外暴露服务
上面我们是通过端口转发的方式可以在外面访问到集群里的服务，如果想要直接把集群服务暴露出来，我们可以使用NodePort 和 Loadbalancer 类型的 Service

apiVersion: v1
kind: Service
metadata:
  name: test-k8s
spec:
  selector:
    app: test-k8s
  # 默认 ClusterIP 集群内可访问，NodePort 节点可访问，LoadBalancer 负载均衡模式（需要负载均衡器才可用）
  type: NodePort
  ports:
    - port: 8080        # 本 Service 的端口
      targetPort: 8080  # 容器端口
      nodePort: 31000   # 节点端口，范围固定 30000 ~ 32767
应用配置 kubectl apply -f service.yaml
在节点上，我们可以 curl http://localhost:31000/hello/easydoc 访问到应用
并且是有负载均衡的，网页的信息可以看到被转发到了不同的 Pod

hello easydoc 

IP lo172.17.0.8, hostname: test-k8s-68bb74d654-962lh
如果你是用 minikube，因为是模拟集群，你的电脑并不是节点，节点是 minikube 模拟出来的，所以你并不能直接在电脑上访问到服务

Loadbalancer 也可以对外提供服务，这需要一个负载均衡器的支持，因为它需要生成一个新的 IP 对外服务，否则状态就一直是 pendding，这个很少用了，后面我们会讲更高端的 Ingress 来代替它。

多端口
多端口时必须配置 name， 文档

apiVersion: v1
kind: Service
metadata:
  name: test-k8s
spec:
  selector:
    app: test-k8s
  type: NodePort
  ports:
    - port: 8080        # 本 Service 的端口
      name: test-k8s    # 必须配置
      targetPort: 8080  # 容器端口
      nodePort: 31000   # 节点端口，范围固定 30000 ~ 32767
    - port: 8090
      name: test-other
      targetPort: 8090
      nodePort: 32000
总结
ClusterIP
默认的，仅在集群内可用

NodePort
暴露端口到节点，提供了集群外部访问的入口
端口范围固定 30000 ~ 32767

LoadBalancer
需要负载均衡器（通常都需要云服务商提供，裸机可以安装 METALLB 测试）
会额外生成一个 IP 对外服务
K8S 支持的负载均衡器：负载均衡器

Headless
适合数据库
clusterIp 设置为 None 就变成 Headless 了，不会再分配 IP，后面会再讲到具体用法
官网文档

-----server有4种分类
-----暴露服务的不同的形式，比如允许外部访问和不允许外部访问，负载均衡等等

-----5.StatefulSet
-----StatefulSet 是用来管理有状态的应用，例如数据库。
------前面我们部署的应用，都是不需要存储数据，不需要记住状态的，可以随意扩充副本，每个副本都是一样的，可替代的。
------而像数据库、Redis 这类有状态的，则不能随意扩充副本。
------StatefulSet 会固定每个 Pod 的名字

------下面是创建了3个pod，没有的话，会从远程拉取，分别是mongodb-0，mongodb-1，mongodb-2
------自己可以通过命令，在通过不同的名字去分别链接mongodb

部署 StatefulSet 类型的 Mongodb
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: mongodb
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
        - name: mongo
          image: mongo:4.4
          # IfNotPresent 仅本地没有镜像时才远程拉，Always 永远都是从远程拉，Never 永远只用本地镜像，本地没有则报错
          imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
spec:
  selector:
    app: mongodb
  type: ClusterIP
  # HeadLess
  clusterIP: None
  ports:
    - port: 27017
      targetPort: 27017
kubectl apply -f mongo.yaml

StatefulSet 特性
Service 的 CLUSTER-IP 是空的，Pod 名字也是固定的。
Pod 创建和销毁是有序的，创建是顺序的，销毁是逆序的。
Pod 重建不会改变名字，除了IP，所以不要用IP直连
statefulset.png

Endpoints 会多一个 hostname
endpoints

访问时，如果直接使用 Service 名字连接，会随机转发请求
要连接指定 Pod，可以这样pod-name.service-name
运行一个临时 Pod 连接数据测试下
kubectl run mongodb-client --rm --tty -i --restart='Never' --image docker.io/bitnami/mongodb:4.4.10-debian-10-r20 --command -- bash

Web 应用连接 Mongodb
在集群内部，我们可以通过服务名字访问到不同的服务
指定连接第一个：mongodb-0.mongodb

mongodbweb.png

image.png

问题
pod 重建后，数据库的内容丢失了
下节，我们讲解如何解决这个问题。


-----给mongo加上主从关系就可以都连上使用了，这节需要配test-k8s项目来测试

-----4.数据持久化
-----kubernetes 集群不会为你处理数据的存储，我们可以为数据库挂载一个磁盘来确保数据的安全。-----你可以选择云存储、本地磁盘、NFS。

-----本地磁盘：可以挂载某个节点上的目录，但是这需要限定 pod 在这个节点上运行
-----云存储：不限定节点，不受集群影响，安全稳定；需要云服务商提供，裸机集群是没有的。
-----NFS：不限定节点，不受集群影响

----实现数据持久化，可以挂在到目录



hostPath 挂载示例
把节点上的一个目录挂载到 Pod，但是已经不推荐使用了，文档
配置方式简单，需要手动指定 Pod 跑在某个固定的节点。
仅供单节点测试使用；不适用于多节点集群。
minikube 提供了 hostPath 存储，文档

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
        - name: mongo
          image: mongo:4.4
          # IfNotPresent 仅本地没有镜像时才远程拉，Always 永远都是从远程拉，Never 永远只用本地镜像，本地没有则报错
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - mountPath: /data/db # 容器里面的挂载路径
              name: mongo-data    # 卷名字，必须跟下面定义的名字一致
      volumes:
        - name: mongo-data              # 卷名字
          hostPath:
            path: /data/mongo-data      # 节点上的路径
            type: DirectoryOrCreate     # 指向一个目录，不存在时自动创建
更高级的抽象
持久卷

Storage Class (SC)
将存储卷划分为不同的种类，例如：SSD，普通磁盘，本地磁盘，按需使用。文档

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  iopsPerGB: "10"
  fsType: ext4
Persistent Volume (PV)
描述卷的具体信息，例如磁盘大小，访问模式。文档，类型，Local 示例

apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodata
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem  # Filesystem（文件系统） Block（块）
  accessModes:
    - ReadWriteOnce       # 卷可以被一个节点以读写方式挂载
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /root/data
  nodeAffinity:
    required:
      # 通过 hostname 限定在某个节点创建存储卷
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node2
Persistent Volume Claim (PVC)
对存储需求的一个申明，可以理解为一个申请单，系统根据这个申请单去找一个合适的 PV
还可以根据 PVC 自动创建 PV。

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodata
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "local-storage"
  resources:
    requests:
      storage: 2Gi
为什么要这么多层抽象
更好的分工，运维人员负责提供好存储，开发人员不需要关注磁盘细节，只需要写一个申请单。
方便云服务商提供不同类型的，配置细节不需要开发者关注，只需要一个申请单。
动态创建，开发人员写好申请单后，供应商可以根据需求自动创建所需存储卷。
腾讯云示例
腾讯云创建kubernetes pvc

本地磁盘示例
不支持动态创建，需要提前创建好

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
        image: mongo:5.0
        imagePullPolicy: IfNotPresent
        name: mongo
        volumeMounts:
          - mountPath: /data/db
            name: mongo-data
      volumes:
        - name: mongo-data
          persistentVolumeClaim:
             claimName: mongodata
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
spec:
  clusterIP: None
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: mongodb
  type: ClusterIP
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodata
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem  # Filesystem（文件系统） Block（块）
  accessModes:
    - ReadWriteOnce       # 卷可以被一个节点以读写方式挂载
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /root/data
  nodeAffinity:
    required:
      # 通过 hostname 限定在某个节点创建存储卷
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node2
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodata
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "local-storage"
  resources:
    requests:
      storage: 2Gi
问题
当前数据库的连接地址是写死在代码里的，另外还有数据库的密码需要配置。
下节，我们讲解如何解决。


-----比较新的是通过开发控制pvc文件，然后运维控制pv文件，这样可以使项目分工明确

-----6.ConfigMap & Secret
-----通过配置文件来控制密码等公共操作，里面的密码和名字一般都要加密

ConfigMap
数据库连接地址，这种可能根据部署环境变化的，我们不应该写死在代码里。
Kubernetes 为我们提供了 ConfigMap，可以方便的配置一些变量。文档

本文档课件需配套 视频 一起学习

configmap.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: mongo-config
data:
  mongoHost: mongodb-0.mongodb
# 应用
kubectl apply -f configmap.yaml
# 查看
kubectl get configmap mongo-config -o yaml
configmap.png

Secret
一些重要数据，例如密码、TOKEN，我们可以放到 secret 中。文档，配置证书

注意，数据要进行 Base64 编码。Base64 工具

secret.yaml

apiVersion: v1
kind: Secret
metadata:
  name: mongo-secret
# Opaque 用户定义的任意数据，更多类型介绍 https://kubernetes.io/zh/docs/concepts/configuration/secret/#secret-types
type: Opaque
data:
  # 数据要 base64。https://tools.fun/base64.html
  mongo-username: bW9uZ291c2Vy
  mongo-password: bW9uZ29wYXNz
# 应用
kubectl apply -f secret.yaml
# 查看
kubectl get secret mongo-secret -o yaml
image.png

使用方法
作为环境变量使用
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
        - name: mongo
          image: mongo:4.4
          # IfNotPresent 仅本地没有镜像时才远程拉，Always 永远都是从远程拉，Never 永远只用本地镜像，本地没有则报错
          imagePullPolicy: IfNotPresent
          env:
          - name: MONGO_INITDB_ROOT_USERNAME
            valueFrom:
              secretKeyRef:
                name: mongo-secret
                key: mongo-username
          - name: MONGO_INITDB_ROOT_PASSWORD
            valueFrom:
              secretKeyRef:
                name: mongo-secret
                key: mongo-password
          # Secret 的所有数据定义为容器的环境变量，Secret 中的键名称为 Pod 中的环境变量名称
          # envFrom:
          # - secretRef:
          #     name: mongo-secret
挂载为文件（更适合证书文件）
挂载后，会在容器中对应路径生成文件，一个 key 一个文件，内容就是 value，文档

apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
-----配置文件与yaml其他的文件都是有联系的，node项目中链接mogodb的IP和端口就可以直接访问
-----7.Helm & 命名空间
-----Helm是一个软件库类似与npm

介绍
Helm类似 npm，pip，docker hub, 可以理解为是一个软件库，可以方便快速的为我们的集群安装一些第三方软件。
使用 Helm 我们可以非常方便的就搭建出来 MongoDB / MySQL 副本集群，YAML 文件别人都给我们写好了，直接使用。官网，应用中心

本文档课件需配套 视频 一起学习

安装 Helm
安装 文档
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

安装 MongoDB 示例
# 安装
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-mongo bitnami/mongodb

# 指定密码和架构
helm install my-mongo bitnami/mongodb --set architecture="replicaset",auth.rootPassword="mongopass"

# 删除
helm ls
heml delete my-mongo

# 查看密码
kubectl get secret my-mongo-mongodb -o json
kubectl get secret my-mongo-mongodb -o yaml > secret.yaml

# 临时运行一个包含 mongo client 的 debian 系统
kubectl run mongodb-client --rm --tty -i --restart='Never' --image docker.io/bitnami/mongodb:4.4.10-debian-10-r20 --command -- bash

# 进去 mongodb
mongo --host "my-mongo-mongodb" -u root -p mongopass

# 也可以转发集群里的端口到宿主机访问 mongodb
kubectl port-forward svc/my-mongo-mongodb 27017:27018
命名空间
如果一个集群中部署了多个应用，所有应用都在一起，就不太好管理，也可以导致名字冲突等。
我们可以使用 namespace 把应用划分到不同的命名空间，跟代码里的 namespace 是一个概念，只是为了划分空间。

# 创建命名空间
kubectl create namespace testapp
# 部署应用到指定的命名空间
kubectl apply -f app.yml --namespace testapp
# 查询
kubectl get pod --namespace kube-system
可以用 kubens 快速切换 namespace

# 切换命名空间
kubens kube-system
# 回到上个命名空间
kubens -
# 切换集群
kubectx minikube
image.png


-----通过helm安装MongoDB上面有例子，也能实现挂载
-----如果一个集群中部署了多个应用，所有应用都在一起，就不太好管理，也可以导致名字冲突等。
我们可以使用 namespace 把应用划分到不同的命名空间，跟代码里的 namespace 是一个概念，只是为了划分空间。

------可以用 kubens 快速切换 namespace

-----7.Ingress
-----他的目的是不暴露端口，一般用户通过访问域名，通过负载均衡器然后通过Ingress，去传达到各个位置

介绍
Ingress 为外部访问集群提供了一个 统一 入口，避免了对外暴露集群端口；
功能类似 Nginx，可以根据域名、路径把请求转发到不同的 Service。
可以配置 https

本文档课件需配套 视频 一起学习

跟 LoadBalancer 有什么区别？
LoadBalancer 需要对外暴露端口，不安全；
无法根据域名、路径转发流量到不同 Service，多个 Service 则需要开多个 LoadBalancer；
功能单一，无法配置 https

2.png

使用
要使用 Ingress，需要一个负载均衡器 + Ingress Controller
如果是裸机（bare metal) 搭建的集群，你需要自己安装一个负载均衡插件，可以安装 METALLB
如果是云服务商，会自动给你配置，否则你的外部 IP 会是 “pending” 状态，无法使用。

文档：Ingress
Minikube 中部署 Ingress Controller：nginx
Helm 安装： Nginx

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-example
spec:
  ingressClassName: nginx
  rules:
  - host: tools.fun
    http:
      paths:
      - path: /easydoc
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 4200
      - path: /svnbucket
        pathType: Prefix
        backend:
          service:
            name: service2
            port:
              number: 8080
腾讯云配置 Ingress 演示

-----Ingress主要作用不暴露接口，
和LoadBalancer区别是 LoadBalancer需要对外暴露端口，不安全；
无法根据域名、路径转发流量到不同 Service，多个 Service 则需要开多个 LoadBalancer；
功能单一，无法配置 https

