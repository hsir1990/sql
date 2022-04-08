注意： 
1.外键字段在创建的时候就应该与主表的类型完全一致（长度等），否则创建外键会报错。
2.外键创建中关键字的references不是reference
3.主表子表必须都是InnoDB的表！

//主表是user，从表是balance
alter table balance add foreign key(uid) references user(id)

一般情况下
balance 表中的插入数据，uid 一定是user表中的id的值，否则插入不了，无论那种情况都不能插入

删除user表中的数据，一定是balance里没有user的id的值，才能删除，否则报错

NULL、RESTRICT、NO ACTION
删除：从表记录不存在时，主表才可以删除。
更新：从表记录不存在时，主表才可以更新。

CASCADE
删除：删除主表时自动删除从表。
更新：更新主表时自动更新从表。

SET NULL
删除：删除主表时自动更新从表值为NULL。
更新：更新主表时自动更新从表值为NULL。


组合使用
外键约束使用最多的两种情况无外乎：

1）父表更新时子表也更新，父表删除时如果子表有匹配的项，删除失败；

2）父表更新时子表也更新，父表删除时子表匹配的项也删除。

前一种情况，在外键定义中，我们使用ON UPDATE CASCADE ON DELETE RESTRICT；后一种情况，可以使用ON UPDATE CASCADE ON DELETE CASCADE;。

但无论什么约束情况，  主表不存在的主键子表也是不能插入相应的外键的，  这是所有外键约束的基本原则。




-- cascade
-- 英 [kæˈskeɪd]   美 [kæˈskeɪd]  
-- n.
-- 大量;小瀑布(尤指一连串瀑布中的一支);倾泻;流注;大簇的下垂物;倾泻（或涌出）的东西
-- vi.
-- 倾泻;流注;大量落下;大量垂悬
-- 第三人称单数： cascades复数： cascades现在分词： cascading过去式： cascaded过去分词： cascaded
-- 记忆技巧：casc〔= cas〕落下；降临 + ade 表动作的结果 →〔水〕落下 → 小瀑布

https://blog.csdn.net/nakiri_arisu/article/details/79718442
【数据库基础】Foreign Key的使用及其优缺点

转身雪人

于 2018-03-27 20:08:21 发布

26984
 收藏 42
分类专栏： DB
版权

DB
专栏收录该内容
12 篇文章0 订阅
订阅专栏
Foreign Key(外键)是数据库的一个很重要的概念。当两张表存在关联字段的时候，利用外键可以保证主表和从表的一致性和完整性。但是由于外键是Constraint，肯定会对表的新增删除修改产生性能的影响，所以到底使不使用，什么时候使用，该怎么用需要慎重考虑。

使用外键的优缺点

如何建立外键
假设我们有张主表user表，表结构如下


我们希望以id这个字段作为别的表的外键关联一张子表balance。 balance表记录着user的账户余额以及币种。表结构如下


这里的uid就是user表的id字段。

我们可以通过

   create table balance(
   ...
   foreign key(uid) references user(id)
) ...
1
2
3
4
5
或者如果balance表已经建好了，通过alter语句来添加外键。

 alter table balance add foreign key(uid) references user(id);
1
2
值得注意的是:
1. 外键字段在创建的时候就应该与主表的类型完全一致(长度啊等)，否则创建外键会报错
2. 外键创建中关键字的references不是reference, 有一个字母s。
3. 主表子表必须都是InnoDB的表！

我们来看一下balance表是否创建好了外键
show create table balance;



看到 CONSTRAINT `balance_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `user` (`id`) 看来是创建好了。

等一下，注意到了没？ 由于创建了外键，mysql自动的为uid字段设置了索引。。 这点也需要了解一下。。

接下来我们来看外键的作用。。。

如何利用外键约束
我们试着往balance表中添加几条数据


uid=1和2的情况对应了user表中’yf’和’huangxiang’ 所以数据插入是没问题的。

接下来我们插入主表不存在的uid试试

结果发现是不行的，外键阻止我们这种错误的操作。都没这个user你怎么往它的账户上打钱？

如果我们删除子表中已经关联上的主表数据呢
比如我们试着删除’yf’这个user。


哈哈，不行吧？ 除非你把子表关联的数据全部删除，你才能删除该条主表的数据。

同样，update操作也会因为外键限制操作失败，这里就不展示了。

外键进阶
参考

https://my.oschina.net/sallency/blog/465079

我们刚才讨论的情况，都是建立在

删除：从表记录不存在时，主表才可以删除。删除从表，主表不变
更新：从表记录不存在时，主表才可以更新。更新从表，主表不变

然而我们可以自定义外键的规则，比如我们删除了主表的某条数据，子表相应的数据都会被删除等。

NULL、RESTRICT、NO ACTION
删除：从表记录不存在时，主表才可以删除。
更新：从表记录不存在时，主表才可以更新。

CASCADE
删除：删除主表时自动删除从表。
更新：更新主表时自动更新从表。

SET NULL
删除：删除主表时自动更新从表值为NULL。
更新：更新主表时自动更新从表值为NULL。

如果子表试图创建一个在父表中不存在的外键值，InnoDB会拒绝任何INSERT或UPDATE操作。如果父表试图UPDATE或者DELETE任何子 表中存在或匹配的外键值，最终动作取决于外键约束定义中的ON UPDATE和ON DELETE选项。InnoDB支持5种不同的动作，如果没有指定ON DELETE或者ON UPDATE，默认的动作为RESTRICT也就是我们上面的例子

cascade关键字
为了测试cascade作用，我们再创建一个tongbu_balance表.


然后复制balance表已有的数据到tongbu_balance表
insert into tongbu_balance select * from balance;

然后我们试着删除主表中的’huangxiang’ …
删除前两表的状态如下


↓↓↓↓↓↓↓↓↓↓删除后↓↓↓↓↓↓↓↓↓↓


子表中’huangxiang’对应的uid=2的数据全部也跟着删除了…

同样当我们UPDATE主表的时候，子表也会跟着UPDATE.. 这里就不做演示了。。

当我们想自定义规则的时候，注意用 ON UPDATE/DELETE 规则 这样的语法限定外键就好了。。。

组合使用
外键约束使用最多的两种情况无外乎：

1）父表更新时子表也更新，父表删除时如果子表有匹配的项，删除失败；

2）父表更新时子表也更新，父表删除时子表匹配的项也删除。

前一种情况，在外键定义中，我们使用ON UPDATE CASCADE ON DELETE RESTRICT；后一种情况，可以使用ON UPDATE CASCADE ON DELETE CASCADE;。

但无论什么约束情况，主表不存在的主键子表也是不能插入相应的外键的，这是所有外键约束的基本原则。
————————————————
版权声明：本文为CSDN博主「转身雪人」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/nakiri_arisu/article/details/79718442