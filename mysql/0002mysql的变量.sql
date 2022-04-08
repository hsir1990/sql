1 整型 
取值范围如果加了unsigned，则最大值翻倍，如tinyint unsigned的取值范围为(0~256)。
int(m)里的m是表示SELECT查询结果集中的显示宽度，并不影响实际的取值范围，没有影响到显示的宽度，不知道这个m有什么用。

2浮点型(float和double)
 设一个字段定义为float(6,3)，如果插入一个数123.45678,实际数据库里存的是123.457，但总个数还以实际为准，即6位。整数部分最大是3位，如果插入数12.123456，存储的是12.1234，如果插入12.12，存储的是12.1200.

3、定点数
浮点型在数据库中存放的是近似值，而定点类型在数据库中存放的是精确值。 

decimal(m,d) 参数m<65 是总个数，d<30且 d<m 是小数位。

4、字符串(char,varchar,_text)
char和varchar：
1.char(n) 若存入字符数小于n，则以空格补于其后，查询之时再将空格去掉。所以char类型存储的字符串末尾不能有空格，varchar不限于此。 
2.char(n) 固定长度，char(4)不管是存入几个字符，都将占用4个字节，varchar是存入的实际字符数+1个字节（n<=255）或2个字节(n>255)，
所以varchar(4),存入3个字符将占用4个字节。 
3.char类型的字符串检索速度要比varchar类型的快。
varchar和text： 
1.varchar可指定n，text不能指定，内部存储varchar是存入的实际字符数+1个字节（n<=255）或2个字节(n>255)，text是实际字符数+2个字
节。 
2.text类型不能有默认值。 
3.varchar可直接创建索引，text创建索引要指定前多少个字符。varchar查询速度快于text,在都创建索引的情况下，text的索引似乎不起作用。
 
检查索引速度
char > varchar > text

5.二进制数据(_Blob)

1._BLOB和_text存储方式不同，_TEXT以文本方式存储，英文存储区分大小写，而_Blob是以二进制方式存储，不分大小写。
2._BLOB存储的数据只能整体读出。 
3._TEXT可以指定字符集，_BLOb不用指定字符集。
通过把内容散列，然后当作索引，去查讯

6.日期时间类型
若定义一个字段为timestamp，这个字段里的时间数据会随其他字段修改的时候自动刷新，所以这个数据类型的字段可以存放这条记录最后被修改的时间。


synthetic
英 [sɪnˈθetɪk]   美 [sɪnˈθetɪk]  
adj.
(人工)合成的;人造的;综合(型)的
n.
合成物;合成纤维(织物);合成剂
复数： synthetics
派生词： synthetically adv.
记忆技巧：syn 共同 + thet 放置 + ic …的 → 放在一起的 → 综合的


optimize
英 [ˈɒptɪmaɪz]   美 [ˈɑːptɪmaɪz]  
vt.
优化;使最优化;充分利用
第三人称单数： optimizes现在分词： optimizing过去式： optimized过去分词： optimized
记忆技巧：optim 最好，最佳 + ize 使… → 使…尽可能优化

CHARACTER SET name	指定一个字符集
character
英 [ˈkærəktə(r)]   美 [ˈkærəktər]  
n.
性格;(人、集体的)品质;(地方的)特点;(事物、事件或地方的)特征;勇气;毅力;（地方或人的）与众不同之处，特色;人;名誉;人物，角色;文字，字母，符号
vt.
刻;印;使具有特征
第三人称单数： characters复数： characters现在分词： charactering过去式： charactered过去分词： charactered


Blob
英 [blɒb]   美 [blɑːb]  
肉球;二进制格式;粒子;斑点;不规则气泡

blob
英 [blɒb]   美 [blɑːb]  
n.
(尤指液体的)一点，一滴;(颜色的)一小片，斑点
vt.
弄脏;弄错
第三人称单数： blobs复数： blobs现在分词： blobbing过去式： blobbed过去分词： blobbed

unsigned
英 [ʌnˈsaɪnd]   美 [ənˈsaɪnd]  
adj.
没签名的;未签约的

decimal
英 [ˈdesɪml]   美 [ˈdesɪml]  
adj.
十进制的;小数的;十进位的
n.
小数
复数： decimals


https://www.cnblogs.com/-xlp/p/8617760.html
MySQL 支持多种类型，大致可以分为三类：数值、日期/时间和字符串(字符)类型。

一、MySQL的数据类型
主要包括以下五大类：

整数类型：BIT、BOOL、TINY INT、SMALL INT、MEDIUM INT、 INT、 BIG INT

浮点数类型：FLOAT、DOUBLE、DECIMAL

字符串类型：CHAR、VARCHAR、TINY TEXT、TEXT、MEDIUM TEXT、LONGTEXT、TINY BLOB、BLOB、MEDIUM BLOB、LONG BLOB

日期类型：Date、DateTime、TimeStamp、Time、Year

其他数据类型：BINARY、VARBINARY、ENUM、SET、Geometry、Point、MultiPoint、LineString、MultiLineString、Polygon、GeometryCollection等

 

1、整型

MySQL数据类型	含义（有符号）
tinyint(m)	1个字节  范围(-128~127)
smallint(m)	2个字节  范围(-32768~32767)
mediumint(m)	3个字节  范围(-8388608~8388607)
int(m)	4个字节  范围(-2147483648~2147483647)
bigint(m)	8个字节  范围(+-9.22*10的18次方)
取值范围如果加了unsigned，则最大值翻倍，如tinyint unsigned的取值范围为(0~256)。

 int(m)里的m是表示SELECT查询结果集中的显示宽度，并不影响实际的取值范围，没有影响到显示的宽度，不知道这个m有什么用。

 

2、浮点型(float和double)

MySQL数据类型	含义
float(m,d)	单精度浮点型    8位精度(4字节)     m总个数，d小数位
double(m,d)	双精度浮点型    16位精度(8字节)    m总个数，d小数位
设一个字段定义为float(6,3)，如果插入一个数123.45678,实际数据库里存的是123.457，但总个数还以实际为准，即6位。整数部分最大是3位，如果插入数12.123456，存储的是12.1234，如果插入12.12，存储的是12.1200.

 

3、定点数

浮点型在数据库中存放的是近似值，而定点类型在数据库中存放的是精确值。 

decimal(m,d) 参数m<65 是总个数，d<30且 d<m 是小数位。

 

4、字符串(char,varchar,_text)

MySQL数据类型	含义
char(n)	固定长度，最多255个字符
varchar(n)	固定长度，最多65535个字符
tinytext	可变长度，最多255个字符
text	可变长度，最多65535个字符
mediumtext	可变长度，最多2的24次方-1个字符
longtext	可变长度，最多2的32次方-1个字符
char和varchar：

1.char(n) 若存入字符数小于n，则以空格补于其后，查询之时再将空格去掉。所以char类型存储的字符串末尾不能有空格，varchar不限于此。 

2.char(n) 固定长度，char(4)不管是存入几个字符，都将占用4个字节，varchar是存入的实际字符数+1个字节（n<=255）或2个字节(n>255)，

所以varchar(4),存入3个字符将占用4个字节。 


3.char类型的字符串检索速度要比varchar类型的快。
varchar和text： 

1.varchar可指定n，text不能指定，内部存储varchar是存入的实际字符数+1个字节（n<=255）或2个字节(n>255)，text是实际字符数+2个字

节。 

2.text类型不能有默认值。 

3.varchar可直接创建索引，text创建索引要指定前多少个字符。varchar查询速度快于text,在都创建索引的情况下，text的索引似乎不起作用。

 

5.二进制数据(_Blob)

1._BLOB和_text存储方式不同，_TEXT以文本方式存储，英文存储区分大小写，而_Blob是以二进制方式存储，不分大小写。

2._BLOB存储的数据只能整体读出。 

3._TEXT可以指定字符集，_BLO不用指定字符集。

 

6.日期时间类型

MySQL数据类型	含义
date	日期 '2008-12-2'
time	时间 '12:25:36'
datetime	日期时间 '2008-12-2 22:06:44'
timestamp	自动存储记录修改时间
若定义一个字段为timestamp，这个字段里的时间数据会随其他字段修改的时候自动刷新，所以这个数据类型的字段可以存放这条记录最后被修改的时间。

 

数据类型的属性

 

MySQL关键字	含义
NULL	数据列可包含NULL值
NOT NULL	数据列不允许包含NULL值
DEFAULT	默认值
PRIMARY KEY	主键
AUTO_INCREMENT	自动递增，适用于整数类型
UNSIGNED	无符号
CHARACTER SET name	指定一个字符集
 

二、MYSQL数据类型的长度和范围
各数据类型及字节长度一览表：

数据类型	字节长度	范围或用法
Bit	1	无符号[0,255]，有符号[-128,127]，天缘博客备注：BIT和BOOL布尔型都占用1字节
TinyInt	1	整数[0,255]
SmallInt	2	无符号[0,65535]，有符号[-32768,32767]
MediumInt	3	无符号[0,2^24-1]，有符号[-2^23,2^23-1]]
Int	4	无符号[0,2^32-1]，有符号[-2^31,2^31-1]
BigInt	8	无符号[0,2^64-1]，有符号[-2^63 ,2^63 -1]
Float(M,D)	4	单精度浮点数。天缘博客提醒这里的D是精度，如果D<=24则为默认的FLOAT，如果D>24则会自动被转换为DOUBLE型。
Double(M,D)	8	 双精度浮点。
Decimal(M,D)	M+1或M+2	未打包的浮点数，用法类似于FLOAT和DOUBLE，天缘博客提醒您如果在ASP中使用到Decimal数据类型，直接从数据库读出来的Decimal可能需要先转换成Float或Double类型后再进行运算。
Date	3	以YYYY-MM-DD的格式显示，比如：2009-07-19
Date Time	8	以YYYY-MM-DD HH:MM:SS的格式显示，比如：2009-07-19 11：22：30
TimeStamp	4	以YYYY-MM-DD的格式显示，比如：2009-07-19
Time	3	以HH:MM:SS的格式显示。比如：11：22：30
Year	1	以YYYY的格式显示。比如：2009
Char(M)	M	
定长字符串。
VarChar(M)	M	变长字符串，要求M<=255
Binary(M)	M	类似Char的二进制存储，特点是插入定长不足补0
VarBinary(M)	M	类似VarChar的变长二进制存储，特点是定长不补0
Tiny Text	Max:255	大小写不敏感
Text	Max:64K	大小写不敏感
Medium Text	Max:16M	大小写不敏感
Long Text	Max:4G	大小写不敏感
TinyBlob	Max:255	大小写敏感
Blob	Max:64K	大小写敏感
MediumBlob	Max:16M	大小写敏感
LongBlob	Max:4G	大小写敏感
Enum	1或2	最大可达65535个不同的枚举值
Set	可达8	最大可达64个不同的值
Geometry	 	 
Point	 	 
LineString	 	 
Polygon	 	 
MultiPoint	 	 
MultiLineString	 	 
MultiPolygon	 	 
GeometryCollection	 	 
三、使用建议
1、在指定数据类型的时候一般是采用从小原则，比如能用TINY INT的最好就不用INT，能用FLOAT类型的就不用DOUBLE类型，这样会对MYSQL在运行效率上提高很大，尤其是大数据量测试条件下。

2、不需要把数据表设计的太过复杂，功能模块上区分或许对于后期的维护更为方便，慎重出现大杂烩数据表

3、数据表和字段的起名字也是一门学问

4、设计数据表结构之前请先想象一下是你的房间，或许结果会更加合理、高效

5、数据库的最后设计结果一定是效率和可扩展性的折中，偏向任何一方都是欠妥的

 

选择数据类型的基本原则
前提：使用适合存储引擎。

选择原则：根据选定的存储引擎，确定如何选择合适的数据类型。

下面的选择方法按存储引擎分类：

MyISAM 数据存储引擎和数据列：MyISAM数据表，最好使用固定长度(CHAR)的数据列代替可变长度(VARCHAR)的数据列。
MEMORY存储引擎和数据列：MEMORY数据表目前都使用固定长度的数据行存储，因此无论使用CHAR或VARCHAR列都没有关系。两者都是作为CHAR类型处理的。
InnoDB 存储引擎和数据列：建议使用 VARCHAR类型。

对于InnoDB数据表，内部的行存储格式没有区分固定长度和可变长度列（所有数据行都使用指向数据列值的头指针），因此在本质上，使用固定长度的CHAR列不一定比使用可变长度VARCHAR列简单。因而，主要的性能因素是数据行使用的存储总量。由于CHAR平均占用的空间多于VARCHAR，因 此使用VARCHAR来最小化需要处理的数据行的存储总量和磁盘I/O是比较好的。

下面说一下固定长度数据列与可变长度的数据列。

char与varchar
CHAR和VARCHAR类型类似，但它们保存和检索的方式不同。它们的最大长度和是否尾部空格被保留等方面也不同。在存储或检索过程中不进行大小写转换。

下面的表显示了将各种字符串值保存到CHAR(4)和VARCHAR(4)列后的结果，说明了CHAR和VARCHAR之间的差别：

值	CHAR(4)	存储需求	VARCHAR(4)	存储需求
''	'    '	4个字节	''	1个字节
'ab'	'ab  '	4个字节	'ab '	3个字节
'abcd'	'abcd'	4个字节	'abcd'	5个字节
'abcdefgh'	'abcd'	4个字节	'abcd'	5个字节

请注意上表中最后一行的值只适用不使用严格模式时；如果MySQL运行在严格模式，超过列长度不的值不保存，并且会出现错误。

从CHAR(4)和VARCHAR(4)列检索的值并不总是相同，因为检索时从CHAR列删除了尾部的空格。通过下面的例子说明该差别：
mysql> CREATE TABLE vc (v VARCHAR(4), c CHAR(4));
Query OK, 0 rows affected (0.02 sec)
 
mysql> INSERT INTO vc VALUES ('ab  ', 'ab  ');
Query OK, 1 row affected (0.00 sec)
 
mysql> SELECT CONCAT(v, '+'), CONCAT(c, '+') FROM vc;
+----------------+----------------+
| CONCAT(v, '+') | CONCAT(c, '+') |
+----------------+----------------+
| ab  +          | ab+            |
+----------------+----------------+
1 row in set (0.00 sec)

text和blob
 

在使用text和blob字段类型时要注意以下几点，以便更好的发挥数据库的性能。

①BLOB和TEXT值也会引起自己的一些问题，特别是执行了大量的删除或更新操作的时候。删除这种值会在数据表中留下很大的"空洞"，以后填入这些"空洞"的记录可能长度不同,为了提高性能,建议定期使用 OPTIMIZE TABLE 功能对这类表进行碎片整理.

②使用合成的（synthetic）索引。合成的索引列在某些时候是有用的。一种办法是根据其它的列的内容建立一个散列值，并把这个值存储在单独的数据列中。接下来你就可以通过检索散列值找到数据行了。但是，我们要注意这种技术只能用于精确匹配的查询（散列值对于类似<或>=等范围搜索操作符 是没有用处的）。我们可以使用MD5()函数生成散列值，也可以使用SHA1()或CRC32()，或者使用自己的应用程序逻辑来计算散列值。请记住数值型散列值可以很高效率地存储。同样，如果散列算法生成的字符串带有尾部空格，就不要把它们存储在CHAR或VARCHAR列中，它们会受到尾部空格去除的影响。

合成的散列索引对于那些BLOB或TEXT数据列特别有用。用散列标识符值查找的速度比搜索BLOB列本身的速度快很多。

③在不必要的时候避免检索大型的BLOB或TEXT值。例如，SELECT *查询就不是很好的想法，除非你能够确定作为约束条件的WHERE子句只会找到所需要的数据行。否则，你可能毫无目的地在网络上传输大量的值。这也是 BLOB或TEXT标识符信息存储在合成的索引列中对我们有所帮助的例子。你可以搜索索引列，决定那些需要的数据行，然后从合格的数据行中检索BLOB或 TEXT值。

④把BLOB或TEXT列分离到单独的表中。在某些环境中，如果把这些数据列移动到第二张数据表中，可以让你把原数据表中 的数据列转换为固定长度的数据行格式，那么它就是有意义的。这会减少主表中的碎片，使你得到固定长度数据行的性能优势。它还使你在主数据表上运行 SELECT *查询的时候不会通过网络传输大量的BLOB或TEXT值。

浮点数与定点数
为了能够引起大家的重视，在介绍浮点数与定点数以前先让大家看一个例子：
mysql> CREATE TABLE test (c1 float(10,2),c2 decimal(10,2));
Query OK, 0 rows affected (0.29 sec)

mysql> insert into test values(131072.32,131072.32);
Query OK, 1 row affected (0.07 sec)

mysql> select * from test;
+-----------+-----------+
| c1        | c2        |
+-----------+-----------+
| 131072.31 | 131072.32 |
+-----------+-----------+
1 row in set (0.00 sec)

从上面的例子中我们看到c1列的值由131072.32变成了131072.31，这就是浮点数的不精确性造成的。

在mysql中float、double（或real）是浮点数，decimal（或numberic）是定点数。

浮点数相对于定点数的优点是在长度一定的情况下，浮点数能够表示更大的数据范围；它的缺点是会引起精度问题。在今后关于浮点数和定点数的应用中，大家要记住以下几点：

浮点数存在误差问题；
对货币等对精度敏感的数据，应该用定点数表示或存储；
编程中，如果用到浮点数，要特别注意误差问题，并尽量避免做浮点数比较；
要注意浮点数中一些特殊值的处理。