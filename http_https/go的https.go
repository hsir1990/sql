
ssl发展到3.0的时候，tls1.0开始基于3.1开始使用

https://blog.csdn.net/charles_neil/article/details/111878101

TLS与SSL的关系
本文简要记录了TLS与SSL的关系，包括发展、相同点与不同点，没有技术细节。

发展历史
摘自百度百科，还有这里

1994年Netscape公司推出HTTPS，使用SSL1.0加密，这是起源。

1995年，SSL2.0，被发现有严重漏洞。

1996年，SSL3.0，得到大规模应用。

1999年，IETF将SSL3.0进行标准化，基于SSL3.0制定了TLS1.0标准。

TLS1.0 通常被标示为SSL 3.1，对应的TLS1.1是SSL3.2，TLS1.2是SSL3.3。

所以也就是说，TLS是基于SSL发展而来的。

截至到2020年SSL最新版本为3.0，TLS最新版本为1.3，主流浏览器已经抛弃对TLS1.0以及TLS1.1的支持。

所以要研究的话，就研究TLS1.2及以上版本吧。

相同点
目的一致
TLS和SSL的目的一致，都是为了加强浏览器和服务器之间的通信安全，他们都位于传输层的TCP协议之上。

结构一致
TLS和SSL都由两个协议组成：

记录协议，用于提供机密性和消息完整性
握手协议，用于建立安全的连接
不同点
TLS和SSL只在一些微小的地方存在不同，比如支持的加密算法等，可以参考这篇文章（虽然我没看懂），或者直接看RFC文档。由于本文目标是介绍TLS和SSL大体上的关系，并不打算介绍过多技术细节，故此处不进一步展开。
————————————————
版权声明：本文为CSDN博主「sha256sum」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/charles_neil/article/details/111878101






https://blog.csdn.net/weixin_40592935/article/details/81948654






Go实战--golang中使用HTTPS以及TSL(.crt、.key、.pem区别以及crypto/tls包介绍)

小小一剑侠

于 2018-08-22 18:02:39 发布

1252
 收藏 3
分类专栏： golang

golang
专栏收录该内容
40 篇文章0 订阅
订阅专栏
 
HTTP与HTTPS
在WWDC 2016上，苹果在发布iOS 9的同时也向开发者传递了一个消息，那就是到2017年1月1日时App Store中所有应用都必须启用 App Transport Security应用程序安全传输协议，从而提升应用和系统安全性。

HTTPS是Hyper Text Transfer Protocol Secure的缩写，相比http，多了一个secure，这一个secure是怎么来的呢？这是由TLS（SSL）提供的。

https和http都属于应用层，基于TCP（以及UDP）协议。但是不同的是： 
HTTP 缺省工作在TCP协议80端口 
HTTPS缺省工作在TCP协议443端口

通俗一句话：相比http，https对于大部分人来说，意味着比较安全。

TLS
安全传输层协议（TLS）用于在两个通信应用程序之间提供保密性和数据完整性。 
The TLS/SSL is a public/private key infrastructure (PKI). For most common cases, each client and server must have a private key.

TLS与SSL的差异

SSLv2 and SSLv3 are completely different (and both are now considered insecure). SSLv3 and TLSv1.0 are very similar, but have a few differences.

You could consider TLSv1.0 as SSLv3.1

版本号：TLS记录格式与SSL记录格式相同，但版本号的值不同，TLS的版本1.0使用的版本号为SSLv3.1。

报文鉴别码：SSLv3.0和TLS的MAC算法及MAC计算的范围不同。TLS使用了RFC-2104定义的HMAC算法。SSLv3.0使用了相似的算法，两者差别在于SSLv3.0中，填充字节与密钥之间采用的是连接运算，而HMAC算法采用的是异或运算。但是两者的安全程度是相同的。

伪随机函数：TLS使用了称为PRF的伪随机函数来将密钥扩展成数据块，是更安全的方式。

报警代码：TLS支持几乎所有的SSLv3.0报警代码，而且TLS还补充定义了很多报警代码，如解密失败（decryption_failed）、记录溢出（record_overflow）、未知CA（unknown_ca）、拒绝访问（access_denied）等。

密文族和客户证书：SSLv3.0和TLS存在少量差别，即TLS不支持Fortezza密钥交换、加密算法和客户证书。

certificate_verify和finished消息：SSLv3.0和TLS在用certificate_verify和finished消息计算MD5和SHA-1散列码时，计算的输入有少许差别，但安全性相当。

加密计算：TLS与SSLv3.0在计算主密值（master secret）时采用的方式不同。

填充：用户数据加密之前需要增加的填充字节。在SSL中，填充后的数据长度要达到密文块长度的最小整数倍。而在TLS中，填充后的数据长度可以是密文块长度的任意整数倍（但填充的最大长度为255字节），这种方式可以防止基于对报文长度进行分析的攻击。

openssl 
openssl(www.openssl.org) 是sslv2,sslv3,tlsv1的一份完整实现,内部包含了大量加密算法程序.其命令行提供了丰富的加密,验证,证书生成等功能,甚至可以用其建立 一个完整的CA.与其同时,它也提供了一套完整的库函数,可用开发用SSL/TLS的通信程序.

插曲： 
2016年10月18日，锤子科技CEO罗永浩在锤子手机发布会上，宣布将200多万元门票收入，以及原计划成立的 Smartisan 公益基金近100万元，全部捐赠给 OpenSSL 基金会和 OpenBSD 基金会。

crt、key以及pem的区别以及生成
crt — Alternate synonymous most common among *nix systems .pem (pubkey).

csr — Certficate Signing Requests (synonymous most common among *nix systems).

cer — Microsoft alternate form of .crt, you can use MS to convert .crt to .cer (DER encoded .cer, or base64[PEM] encoded cer).

pem = The PEM extension is used for different types of X.509v3 files which contain ASCII (Base64) armored data prefixed with a «—– BEGIN …» line. These files may also bear the cer or the crt extension.

der — The DER extension is used for binary DER encoded certificates.

证书(Certificate) .cer .crt 
私钥(Private Key).key 
证书签名请求(Certificate sign request) .csr 
至于pem和der，是编码方式，以上三类均可以使用这两种编码方式，因此.pem和.der(少见)不一定是以上三种(Cert,Key,CSR)中的某一种

PEM - Privacy Enhanced Mail,打开看文本格式,以”—–BEGIN…”开头, “—–END…”结尾,内容是BASE64编码. 
查看PEM格式证书的信息:openssl x509 -in certificate.pem -text -noout 
Apache和*NIX服务器偏向于使用这种编码格式.

DER - Distinguished Encoding Rules,打开看是二进制格式,不可读. 
查看DER格式证书的信息:openssl x509 -in certificate.der -inform der -text -noout 
Java和Windows服务器偏向于使用这种编码格式.

x509 
X.509是一种非常通用的证书格式。所有的证书都符合ITU-T X.509国际标准，因此(理论上)为一种应用创建的证书可以用于任何其他符合X.509标准的应用。

x509证书一般会用到三类文，key，csr，crt。 
Key 是私用密钥openssl格，通常是rsa算法。 
Csr 是证书请求文件，用于申请证书。在制作csr文件的时，必须使用自己的私钥来签署申，还可以设定一个密钥。 
crt是CA认证后的证书文，（windows下面的，其实是crt），签署人用自己的key给你签署的凭证。

生成.key 
rsa算法：

ECDSA算法：

生成.crt

需要输入一些信息：

生成pem和key

crypto/tls包介绍
golang中为我们提供了tls包： 
Package tls partially implements TLS 1.2, as specified in RFC 5246.

func LoadX509KeyPair

LoadX509KeyPair reads and parses a public/private key pair from a pair of files. The files must contain PEM encoded data. The certificate file may contain intermediate certificates following the leaf certificate to form a certificate chain. On successful return, Certificate.Leaf will be nil because the parsed form of the certificate is not retained.

type Config 
A Config structure is used to configure a TLS client or server. After one has been passed to a TLS function it must not be modified. A Config may be reused; the tls package will also not modify it.

这里主要关注一下Certificates，是我们要用到的。

func Listen

Listen creates a TLS listener accepting connections on the given network address using net.Listen. The configuration config must be non-nil and must include at least one certificate or else set GetCertificate.

func Dial

Dial connects to the given network address using net.Dial and then initiates a TLS handshake, returning the resulting TLS connection. Dial interprets a nil configuration as equivalent to the zero configuration; see the documentation of Config for the defaults.

应用
通过golang生成pem 
github上的代码：https://github.com/levigross/go-mutual-tls/blob/master/generate_client_cert.go

golang中使用HTTPS

浏览器访问： 
https://localhost/hello 
不要疑问，出现了访问12306的效果，很正常，因为这是我们自己做的证书。 
关于 为何从12306.cn订票时浏览器总是提醒证书不受信任？请看知乎上的讨论，很精彩： 
https://www.zhihu.com/question/25334635

golang中使用tls 
server.go

client.go

这里编写client代码时候需要注意：InsecureSkipVerify: true 
也就是说上面的代码中客户端不对服务端的证书进行验证。 
go实现的Client端默认也是要对服务端传过来的数字证书进行校验的，但客户端提示：这个证书是由不知名CA签发的！ 

https://www.studygolang.com/articles/10776?fr=sidebar