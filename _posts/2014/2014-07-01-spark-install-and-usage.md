---
layout: post

title:  Spark安装和使用

description: 本文主要记录 Spark 的安装过程配置过程并测试 Spark 的一些基本使用方法。

keywords:  

category: spark

tags: [spark]

published: true

---

本文主要记录 Spark 的安装过程配置过程并测试 Spark 的一些基本使用方法。为了方便，这里使用 CDH 的 yum 源方式来安装 Spark，注意本文安装的 Spark 版本为 1.1。

- 操作系统：CentOs 6.4
- CDH 版本：5.2.0
- Spark 版本：1.1

关于 yum 源的配置以及 hadoop 的安装，请参考[使用yum安装CDH Hadoop集群](/2013/04/06/install-cloudera-cdh-by-yum)。

# 1. Spark 安装

选择一个节点来安装 Spark ，首先查看 Spark 相关的包有哪些：

```bash
$ yum list |grep spark
spark-core.noarch                 1.1.0+cdh5.2.0+56-1.cdh5.2.0.p0.35.el6 @cdh
spark-history-server.noarch       1.1.0+cdh5.2.0+56-1.cdh5.2.0.p0.35.el6 @cdh
spark-master.noarch               1.1.0+cdh5.2.0+56-1.cdh5.2.0.p0.35.el6 @cdh
spark-python.noarch               1.1.0+cdh5.2.0+56-1.cdh5.2.0.p0.35.el6 @cdh
spark-worker.noarch               1.1.0+cdh5.2.0+56-1.cdh5.2.0.p0.35.el6 @cdh
hue-spark.x86_64                  3.6.0+cdh5.2.0+509-1.cdh5.2.0.p0.37.el6
```

以上包作用如下：

- spark-core: spark 核心功能
- spark-worker: spark-worker 初始化脚本
- spark-master: spark-master 初始化脚本
- spark-python: spark 的 Python 客户端
- hue-spark: spark 和 hue 集成包
- spark-history-server

安装脚本如下：

```bash
$ sudo yum install spark-core spark-master spark-worker spark-python spark-history-server
```

# 2. 配置

## 修改配置文件

设置环境变量，在 `.bashrc` 中加入下面一行，并使其生效：

```properties
export SPARK_HOME=/usr/lib/spark
```

可以修改配置文件 `/etc/spark/conf/spark-env.sh`，其内容如下，你可以根据需要做一些修改。

```bash
export STANDALONE_SPARK_MASTER_HOST=`hostname`

export SPARK_MASTER_IP=$STANDALONE_SPARK_MASTER_HOST

### Let's run everything with JVM runtime, instead of Scala
export SPARK_LAUNCH_WITH_SCALA=0
export SPARK_LIBRARY_PATH=${SPARK_HOME}/lib
export SCALA_LIBRARY_PATH=${SPARK_HOME}/lib
export SPARK_MASTER_WEBUI_PORT=18080
export SPARK_MASTER_PORT=7077
export SPARK_WORKER_PORT=7078
export SPARK_WORKER_WEBUI_PORT=18081
export SPARK_WORKER_DIR=/var/run/spark/work
export SPARK_LOG_DIR=/var/log/spark

if [ -n "$HADOOP_HOME" ]; then
  export SPARK_LIBRARY_PATH=$SPARK_LIBRARY_PATH:${HADOOP_HOME}/lib/native
fi


export HIVE_CONF_DIR=${HIVE_CONF_DIR:-/etc/hive/conf}
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-/etc/hadoop/conf}


### Comment above 2 lines and uncomment the following if
### you want to run with scala version, that is included with the package
#export SCALA_HOME=${SCALA_HOME:-/usr/lib/spark/scala}
#export PATH=$PATH:$SCALA_HOME/bin
```

## 配置 Spark History Server

执行下面命令：

```bash
$ sudo -u hdfs hadoop fs -mkdir /user/spark
$ sudo -u hdfs hadoop fs -mkdir /user/spark/applicationHistory
$ sudo -u hdfs hadoop fs -chown -R spark:spark /user/spark
$ sudo -u hdfs hadoop fs -chmod 1777 /user/spark/applicationHistory
```
在 Spark 客户端创建 `/etc/spark/conf/spark-defaults.conf`：

```bash
cp /etc/spark/conf/spark-defaults.conf.template /etc/spark/conf/spark-defaults.conf
```

在 `/etc/spark/conf/spark-defaults.conf` 添加两行：

```properties
spark.eventLog.dir=/user/spark/applicationHistory
spark.eventLog.enabled=true
```

如果想 YARN ResourceManager 访问 Spark History Server ，则添加一行：

```properties
spark.yarn.historyServer.address=http://HISTORY_HOST:HISTORY_PORT
```

# 3. 启动和停止

启动脚本：

```bash
$ sudo service spark-master start
$ sudo service spark-worker start
```

停止脚本：

```bash
$ sudo service spark-worker stop
$ sudo service spark-master stop
```

当然，你还可以设置开机启动：

```bash
$ sudo chkconfig spark-worker on
$ sudo chkconfig spark-master on
```

运行日志保存在 `/var/log/spark`，你可以通过`<http://IP:18080/>`（我这里 IP 为 cdh1）访问 spark master 的 web 界面

当然，你也可以使用 spark 自带的脚本来启动和停止，这些脚本在 `/usr/lib/spark/sbin` 目录下：

```bash
$ ls /usr/lib/spark/sbin
slaves.sh        spark-daemons.sh  start-master.sh  stop-all.sh
spark-config.sh  spark-executor    start-slave.sh   stop-master.sh
spark-daemon.sh  start-all.sh      start-slaves.sh  stop-slaves.sh
```

例如，你也可以通过下面脚本启动master：

```bash
$ cd /usr/lib/spark/sbin
$ ./start-master.sh
```

类似地，通过下面命令启动worker：

```bash
./bin/spark-class org.apache.spark.deploy.worker.Worker spark://IP:18080
```

# 4. 测试

## 运行测试例子

运行 Spark 自带的 Example，在 spark home 目录运行：

```bash
$ ./bin/run-example SparkPi 10
ls: cannot access /usr/lib/spark/lib/spark-examples-*hadoop*.jar: No such file or directory
Failed to find Spark examples assembly in /usr/lib/spark/lib or /usr/lib/spark/examples/target
You need to build Spark before running this program
```

出现上面异常，需要把 examples/lib 目录拷贝到 /usr/lib/spark 目录下，然后再运行。

```bash
cd /usr/lib/spark
cp -r examples/lib .
```

你还可以运行 spark shell 的交互模式：

```bash
$ ./bin/spark-shell --master local[2]

Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ / __/  _/
   /___/ .__/\_,_/_/ /_/\_\   version 1.1.0
      /_/

Using Scala version 2.10.4 (Java HotSpot(TM) 64-Bit Server VM, Java 1.6.0_45)
Type in expressions to have them evaluated.

Spark context available as sc.

scala>

```

通过 Python API 来运行交互模式：

```bash
$ ./bin/pyspark --master local[2]

Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ / __/  _/
   /__ / .__/\_,_/_/ /_/\_\   version 1.1.0
      /_/

Using Python version 2.6.6 (r266:84292, Jan 22 2014 09:42:36)
SparkContext available as sc.
>>>
```

你也可以运行 Python 编写的应用(注意：**使用 yum 安装 cdh5.2后，spark 的 home 目录下不存在 examples/src/ 目录**)：

```bash
$ ./bin/spark-submit examples/src/main/python/pi.py 10
```

## 在集群上运行

Spark 目前支持三种集群管理模式：

- Standalone
- Apache Mesos
- Hadoop YARN

### Standalone 模式

你可以通过 spark-shel l运行下面的 wordcount 例子，因为 hdfs 上的输入和输出文件都涉及到用户的访问权限，故这里使用 hive 用户来启动 spark-shell：

读取 hdfs 的一个例子：

```bash
$ echo "hello world" >test.txt
$ hadoop fs -put test.txt /tmp

$ spark-shell
scala> val file = sc.textFile("hdfs://cdh1:8020/tmp/test.txt")
scala> file.count()
```

更复杂的一个例子，运行 mapreduce 统计单词数：

```bash
$ spark-shell
scala> val file = sc.textFile("hdfs://cdh1:8020/tmp/test.txt")
scala> val counts = file.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _)
scala> counts.saveAsTextFile("hdfs://cdh1:8020/tmp/output")
```

运行过程中，可能会出现下面的错误：

```
14/10/24 14:51:40 WARN hdfs.BlockReaderLocal: The short-circuit local reads feature cannot be used because libhadoop cannot be loaded.
14/10/24 14:51:40 ERROR lzo.GPLNativeCodeLoader: Could not load native gpl library
java.lang.UnsatisfiedLinkError: no gplcompression in java.library.path
	at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1738)
	at java.lang.Runtime.loadLibrary0(Runtime.java:823)
	at java.lang.System.loadLibrary(System.java:1028)
	at com.hadoop.compression.lzo.GPLNativeCodeLoader.<clinit>(GPLNativeCodeLoader.java:32)
	at com.hadoop.compression.lzo.LzoCodec.<clinit>(LzoCodec.java:71)
	at java.lang.Class.forName0(Native Method)
	at java.lang.Class.forName(Class.java:249)
	at org.apache.hadoop.conf.Configuration.getClassByNameOrNull(Configuration.java:1836)
	at org.apache.hadoop.conf.Configuration.getClassByName(Configuration.java:1801)
	at org.apache.hadoop.io.compress.CompressionCodecFactory.getCodecClasses(CompressionCodecFactory.java:128)
```

该异常的解决方法可以参考 [Spark连接Hadoop读取HDFS问题小结](http://blog.csdn.net/pelick/article/details/11599391) 这篇文章。

解决方法：

```bash
cp /usr/lib/hadoop/lib/native/libgplcompression.so $JAVA_HOME/jre/lib/amd64/
cp /usr/lib/hadoop/lib/native/libhadoop.so $JAVA_HOME/jre/lib/amd64/
cp /usr/lib/hadoop/lib/native/libsnappy.so $JAVA_HOME/jre/lib/amd64/
```

运行完成之后，你可以查看 `hdfs://cdh1:8020/tmp/output` 目录下的文件内容。

```bash
$ hadoop fs -cat /tmp/output/part-00000
(hello,1)
(world,1)
```

另外，spark-shell 后面还可以加上其他参数，例如指定 IP 和端口、运行核数：

```bash
$ spark-shell --master spark://cdh1:7077 --cores 2
scala>
```

另外，也可以使用 spark-submit 以 Standalone 模式运行 SparkPi 程序：

```bash
$ spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode client --master spark://cdh1:7077 /usr/lib/spark/examples/lib/spark-examples-1.1.0-cdh5.2.0-hadoop2.5.0-cdh5.2.0.jar 10
```

### Spark on Yarn

以 YARN 客户端方式运行 SparkPi 程序：

```bash
$ spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode client --master yarn /usr/lib/spark/examples/lib/spark-examples-1.1.0-cdh5.2.0-hadoop2.5.0-cdh5.2.0.jar 10
```

以 YARN 集群方式运行 SparkPi 程序：

```bash
$ spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode cluster --master yarn /usr/lib/spark/examples/lib/spark-examples-1.1.0-cdh5.2.0-hadoop2.5.0-cdh5.2.0.jar 10
```

运行在 YARN 集群之上的时候，可以手动把 spark-assembly 相关的 jar 包拷贝到 hdfs 上去，然后设置 `SPARK_JAR` 环境变量：

```bash
$ hdfs dfs -mkdir -p /user/spark/share/lib
$ hdfs dfs -put $SPARK_HOME/assembly/lib/spark-assembly_*.jar  /user/spark/share/lib/spark-assembly.jar

$ SPARK_JAR=hdfs://<nn>:<port>/user/spark/share/lib/spark-assembly.jar
```

# 5. Spark-SQL

Spark 安装包中包括了 Spark-SQL ，运行 spark-sql 命令，出现下面异常：

```bash
$ cd /usr/lib/spark/bin
$ ./spark-sql
java.lang.ClassNotFoundException: org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver
	at java.net.URLClassLoader$1.run(URLClassLoader.java:202)
	at java.security.AccessController.doPrivileged(Native Method)
	at java.net.URLClassLoader.findClass(URLClassLoader.java:190)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:306)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:247)
	at java.lang.Class.forName0(Native Method)
	at java.lang.Class.forName(Class.java:247)
	at org.apache.spark.deploy.SparkSubmit$.launch(SparkSubmit.scala:319)
	at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:75)
	at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)

Failed to load Spark SQL CLI main class org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver.
You need to build Spark with -Phive.
```

从上可以知道  Spark-SQL 编译时没有集成 Hive，故需要重新编译 spark 源代码。

## 编译 Spark-SQL

下载代码：

```bash
$ git clone git@github.com:cloudera/spark.git
$ cd spark
$ git checkout -b origin/cdh5-1.1.0_5.2.0
```

编译代码，集成 yarn 和 hive，有三种方式：

```bash
$ sbt/sbt -Dhadoop.version=2.5.0-cdh5.2.0 -Pyarn -Phive assembly
```

等很长很长一段时间，会提示错误。

改为 maven 编译：

修改根目录下的 pom.xml，添加一行 `<module>sql/hive-thriftserver</module>`：

```xml
<modules>
    <module>core</module>
    <module>bagel</module>
    <module>graphx</module>
    <module>mllib</module>
    <module>tools</module>
    <module>streaming</module>
    <module>sql/catalyst</module>
    <module>sql/core</module>
    <module>sql/hive</module>
    <module>sql/hive-thriftserver</module> <!--添加的一行-->
    <module>repl</module>
    <module>assembly</module>
    <module>external/twitter</module>
    <module>external/kafka</module>
    <module>external/flume</module>
    <module>external/flume-sink</module>
    <module>external/zeromq</module>
    <module>external/mqtt</module>
    <module>examples</module>
  </modules>
```

然后运行：

```bash
$ export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"
$ mvn -Pyarn -Dhadoop.version=2.5.0-cdh5.2.0 -Phive -DskipTests clean package
```

如果编译成功之后， 会在 assembly/target/scala-2.10 目录下生成：spark-assembly-1.1.0-cdh5.2.0.jar，在 examples/target/scala-2.10 目录下生成：spark-examples-1.1.0-cdh5.2.0.jar

但是，经测试 cdh5.2.0 版本中的 spark 的 sql/hive-thriftserver 模块存在编译错误，最后无法编译成功，故需要等到 cloudera 官方更新源代码或者等待下一个 cdh 版本集成 spark-sql。

如果编译成功了，则将 spark-assembly-1.1.0-cdh5.2.0.jar 拷贝到 /usr/lib/spark/assembly/lib 目录，然后再来运行 spark-sql。
