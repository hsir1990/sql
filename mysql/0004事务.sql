 建表的时候,选择 Innodb引擎才支持事务

 #清空表
truncate t_stu_detail;
#回滚，对于truncate无法回滚
rollback;

#修改表结构
alter table t_stu_detail add description varchar(50);
#回滚，对于修改表结构的语句无法回滚
rollback;

transaction
英 [trænˈzækʃn]   美 [trænˈzækʃn]  
n.
交易;处理;业务;买卖;办理
复数： transactions
记忆技巧：trans 变换 + action 行动 → 交换行动 → 交易

https://baijiahao.baidu.com/s?id=1722528612965200674&wfr=spider&for=pc
MYSQL数据库之事务播报文章

尚硅谷教育

发布时间: 2022-01-21 10:14
北京晟程华科教育科技有限公司官方帐号,教育领域爱好者
关注
事务
DCL用来控制数据库的访问，包括如下SQL语句：

GRANT：授予访问权限

REVOKE：撤销访问权限

COMMIT：提交事务处理

ROLLBACK：事务处理回退

SAVEPOINT：设置保存点

LOCK：对数据库的特定部分进行锁定

1、事务

思考：我去银行给朋友汇款,我卡上有1000元,朋友卡上500元,我给朋友转账50元(无手续费),如果,我的钱刚扣,而朋友的钱又没加时,网线断了,怎么办?

1.1事务的ACID特性

原子性(Atomicity)：原子意为最小的粒子，或者说不能再分的事物。数据库事务的不可再分的原则即为原子性。

组成事务的所有查询必须：要么全部执行，要么全部取消（就像上面的银行例子）。

一致性(Consistency)：指数据的规则,在事务前/后应保持一致

隔离性(Isolation)：简单点说，某个事务的操作对其他事务不可见的.

持久性(Durability)：当事务提交完成后，其影响应该保留下来，不能撤消

1.2事务的用法

开启事务(start transaction)

执行sql操作(普通sql操作)

提交/回滚(commit/rollback)

注意:

l 建表的时候,选择 Innodb引擎才支持事务

默认情况下，MySQL是自动提交事务，每次执行一个 SQL 语句时，如果执行成功，就会向数据库自动提交，而不能回滚。如果某一组操作需要在一个事务中，那么需要使用start transaction，一旦rollback或commit就结束当次事务，之后的操作又自动提交。

如果需要在当前会话的整个过程中都取消自动提交事务，进行手动提交事务，就需要设置set autocommit = false;或set autocommit = 0;那样的话每一句SQL都需要手动commit提交才会真正生效。rollback或commit之前的所有操作都视为一个事务，之后的操作视为另一个事务，还需要手动提交或回滚。

和Oracle一样，DDL语句是不能回滚的，并且部分的DDL语句会造成隐式的提交，因此最好事务中不要涉及DDL语句。

#开启手动处理事务模式
#set autocommit = false;
#开始事务（推荐）
start transaction;
#查看当前表的数据
select * from t_stu_detail;
#删除整张表的数据
delete from t_stu_detail;
#查询该表数据，发现显示删除后的结果
select * from t_stu_detail;
#回滚
rollback
#查看当前表的数据，发现又回来了
select * from t_stu_detail;
#删除整张表的数据
delete from t_stu_detail;
#提交事务
commit;
#查看当前表的数据，发现真删除了
select * from t_stu_detail;

#插入一条记录
INSERT INTO t_stu_detail VALUES
(1, '123456789012345678', '1990-01-21', '12345678901', 'a@163.com', '北七家');
#保存还原点1
savepoint point1;
#插入一条记录
INSERT INTO t_stu_detail VALUES
(2, '123456789012345677', '1990-02-21', '12345678902', 'b@163.com', '北七家');
#保存还原点2
savepoint point2;
#查看当前效果
select * from t_stu_detail;
#回滚到某个还原点
rollback to point1;
#提交事务
commit;

#清空表
truncate t_stu_detail;
#回滚，对于truncate无法回滚
rollback;

#修改表结构
alter table t_stu_detail add description varchar(50);
#回滚，对于修改表结构的语句无法回滚
rollback;

1.3数据库的隔离级别

对于同时运行的多个事务（多线程并发）, 当这些事务访问数据库中相同的数据时, 如果没有采取必要的隔离机制, 就会导致各种并发问题: （问题的本质就是线程安全问题，共享数据的问题）

脏读: 对于两个事务 T1, T2, T1 读取了已经被 T2 更新但还没有被提交的字段. 之后, 若 T2 回滚, T1读取的内容就是临时且无效的.

不可重复读: 对于两个事务 T1, T2, T1 读取了一个字段, 然后 T2 更新并提交了该字段. 之后, T1再次读取同一个字段, 值就不同了.

幻读: 对于两个事务 T1, T2, T1 从一个表中读取了一个字段, 然后 T2 在该表中插入、删除了一些新的行. 之后, 如果 T1 再次读取同一个表, 就会多出、少了几行.

数据库事务的隔离性: 数据库系统必须具有隔离并发运行各个事务的能力, 使它们不会相互影响, 避免各种并发问题。一个事务与其他事务隔离的程度称为隔离级别. 数据库规定了多种事务隔离级别, 不同隔离级别对应不同的干扰程度, 隔离级别越高, 数据一致性就越好, 但并发性越弱。

Oracle 支持的 2 种事务隔离级别：READ COMMITED, SERIALIZABLE. Oracle 默认的事务隔离级别为: READ COMMITED

Mysql 支持 4 中事务隔离级别. Mysql 默认的事务隔离级别为: REPEATABLE-READ

每启动一个 mysql 程序, 就会获得一个单独的数据库连接. 每个数据库连接都有一个变量 @@tx_isolation, 表示当前的事务隔离级别.

查看当前的隔离级别: SELECT @@tx_isolation;

查看全局的隔离级别：select @@global.tx_isolation;

设置当前 mySQL 连接的隔离级别: set tx_isolation ='repeatable-read';

设置数据库系统的全局的隔离级别: set global tx_isolation ='read-committed'; [I1]


1.4示例演示

（1）脏读

脏读：进入餐厅发现“梦中情人”旁边座位已经有“帅哥”坐那儿了，正郁闷，打完饭，发现那个位置是空着的，又欣喜若狂，其实刚刚那个“帅哥”只是临时过去打个招呼。





（2）不可重复读

不可重复读：在图书馆门口，发现自己占的位置旁边有位“美女”，等刷完卡，兴冲冲的走到那儿，发现已经变成一“如花”了。





（3）幻读

大学考前画重点，老师说“第一章 xxxxxx概念”，你赶紧找，“天啊，在哪儿啊”，等你画完，就听老师说：“第四章xxxxx”，中间那些你都没听到。





（4）序列化






但是B客户端对A客户端未涉及的表不受影响

1.5锁

（1）行级锁

InnoDB的前三个隔离级别是行级锁




B客户端如果也要对“id=6”的以外行进行修改不用等

（2）表级锁

InnoDB事务隔离级别是序列化，将会发生整张表的锁


2、 分布式事务

减号不是下划线

https://baijiahao.baidu.com/s?id=1646471907227523503&wfr=spider&for=pc
MySQL 经验：一文为你解答 全局锁 和 表锁 到底什么时候会用到播报文章

王者小哆啦

发布时间: 2019-10-04 22:06
关注
从这一节开始，我们进入专栏的第三个 MySQL 知识大类：MySQL 锁。

在上一章（MySQL 索引）中，我们介绍了索引原理、需要添加索引的场景、一些常见索引类型的区别等，以及分享了有些场景 MySQL 会选错索引及选错索引时的处理方式等。通过这些学习，我们知道了提高查询效率的方法。但是，数据库往往是多个用户或者客户端在连接使用的。这时，我们需要考虑一个新的问题：

如何保证数据并发访问的一致性、有效性呢？


MySQL 中，锁就是协调多个用户或者客户端并发访问某一资源的机制，保证数据并发访问时的一致性和有效性。

本章就来介绍一下不同场景下的锁机制。

根据加锁的范围，MySQL 中的锁可分为三类：

全局锁
表级锁
行锁
本节来重点讲解一下全局锁和表锁。

1 全局锁

MySQL 全局锁会关闭所有打开的表，并使用全局读锁锁定所有表。其命令为：FLUSH TABLES WITH READ LOCK;

简称：FTWRL，可以使用下面命令解锁：UNLOCK TABLES;

我们来通过实验理解一下全局锁：


首先创建测试表，并写入数据：

use test;

drop table if exists t14;

CREATE TABLE `t14` (

`id` int(11) NOT NULL AUTO_INCREMENT,

`a` int(11) NOT NULL,

`b` int(11) NOT NULL,

PRIMARY KEY (`id`),

KEY `idx_a` (`a`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

insert into t14(a,b) values(1,1);

进行 FTWRL 实验：


上面的实验中，当 session1 执行 FTWRL 后，本线程 session1 和其它线程 session2 都可以查询，本线程和其它线程都不能更新。

原因是：当执行 FTWRL 后，所有的表都变成只读状态，数据更新或者字段更新将会被阻塞。

那么全局锁一般什么时候会用到呢？

全局锁一般用在整个库（包含非事务引擎表）做备份（mysqldump 或者 xtrabackup）时。也就是说，在整个备份过程中，整个库都是只读的，其实这样风险挺大的。如果是在主库备份，会导致业务不能修改数据；而如果是在从库备份，就会导致主从延迟。

好在 mysqldump 包含一个参数 --single-transaction，可以在一个事务中创建一致性快照，然后进行所有表的备份。因此增加这个参数的情况下，备份期间可以进行数据修改。但是需要所有表都是事务引擎表。所以这也是建议使用 InnoDB 存储引擎的原因之一。

而对于 xtrabackup，可以分开备份 InnoDB 和 MyISAM，或者不执行 --master-data，可以避免使用全局锁。


2 表级锁

表级锁有两种：表锁和元数据锁。

2.1 表锁

表锁使用场景：事务需要更新某张大表的大部分或全部数据。如果使用默认的行锁，不仅事务执行效率低，而且可能造成其它事务长时间锁等待和锁冲突，这种情况下可以考虑使用表锁来提高事务执行速度；
事务涉及多个表，比较复杂，可能会引起死锁，导致大量事务回滚，可以考虑表锁避免死锁。
其中表锁又分为表读锁和表写锁，命令分别是：

表读锁：lock tables t14 read;

表写锁：lock tables t14 write;

下面我们分别用实验验证表读锁和表写锁。

表读锁实验：


从上面的实验我们可以看出，在 session1 中对表 t14 加表读锁，session1 和 session2 都可以查询表 t14 的数据；而 session1 执行更新会报错，session2 执行更新会等待（直到 session1 解锁后才更新成功）。

总结：对表执行 lock tables xxx read （表读锁）时，本线程和其它线程可以读，本线程写会报错，其它线程写会等待。

我们再来看一下表写锁实验：



总结：对表执行 lock tables xxx write （表写锁）时，本线程可以读写，其它线程读写都会阻塞。

2.2 元数据锁

在 MySQL 中，DDL 是不属于事务范畴的。如果事务和 DDL 并行执行同一张表时，可能会出现事务特性被破坏、binlog 顺序错乱等 bug。为了解决这类问题，从 MySQL 5.5.3 开始，引入了元数据锁（Metadata Locking，简称：MDL 锁）。

从上面我们知道，MDL 锁的出现解决了同一张表上事务和 DDL 并行执行时可能导致数据不一致的问题。

但是，我们在工作中，很多情况需要考虑 MDL 的存在，否则可能导致长时间锁等待甚至连接被打满的情况。如下例：


上面的实验中，我们在 session1 查询了表 t14 的数据，其中使用了 sleep(100) ，表示在 100 秒后才会返回结果；然后在 session2 执行 DDL 操作时会等待（原因是 session1 执行期间会对表 t14 加一个 MDL，而 session2 又会跟 session1 争抢 MDL）；而 session3 执行查询时也会继续等待。因此如果 session1 的语句一直没结束，其它所有的查询都会等待。

这种情况下，如果这张表查询比较频繁，很可能短时间把数据库的连接数打满，导致新的连接无法建立而报错，如果是正式业务，影响是非常恐怖的。

当然如果出现这种情况，假如你还有 session 连着数据库，可以 kill 掉 session1 中的语句或者终止 session2 中的 DDL 操作，可以让业务恢复。但是出现这种情况的根源其实是：session1 中有长时间未提交的事务。

因此对于开发来说，在工作中应该尽量避免慢查询、尽量保证事务及时提交、避免大事务等，当然对于 DBA 来说，也应该尽量避免在业务高峰执行 DDL 操作。

