# Flink SQL CLI docker

This folder contains a `Dockerfile` based on `flink:1.10-scala_2.11` with addition set up to facilitate the process to submit SQL commands via the `bin/sql-client.sh embedded`.

This work is based on the tutorial at http://wuchong.me/blog/2020/02/25/demo-building-real-time-application-with-flink-sql/. See also the github repo https://github.com/wuchong/flink-sql-demo/. Here we pack the tools in a docker instead of running on the host computer.

We start with the `flink:1.10-scala_2.11` docker using
```sh
docker run -it flink:1.10-scala_2.11 /bin/bash
```
Once logged in, here is the process to get ready in `bash`

```sh
# per the tutorial, install the additional connectors, etc.
wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.10.0/flink-json-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.10.0/flink-sql-connector-kafka_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch6_2.11/1.10.0/flink-sql-connector-elasticsearch6_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-jdbc_2.11/1.10.0/flink-jdbc_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.48/mysql-connector-java-5.1.48.jar

# install vim
apt-get update
apt-get install vim
# change the taskmanager.numberOfTaskSlots from 1 to 10
sed -i 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: 10/' conf/flink-conf.yaml
# use vi to verify
# vi conf/flink-conf.yaml
```
----
## Docker file

```dockerfile
FROM flink:1.10.0-scala_2.11

# install additional JARs
WORKDIR /opt/flink/
RUN wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.10.0/flink-json-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.10.0/flink-sql-connector-kafka_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch6_2.11/1.10.0/flink-sql-connector-elasticsearch6_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-jdbc_2.11/1.10.0/flink-jdbc_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.48/mysql-connector-java-5.1.48.jar

# install vim
RUN apt-get update && apt-get install vim
# change the taskmanager.numberOfTaskSlots from 1 to 10
RUN sed -i 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: 10/' \
    conf/flink-conf.yaml
```

## Check Kafka data source
Logging in to the Kafka docker:
```sh
docker-compose exec kafka bash
```
then
```sh
kafka-console-consumer.sh --topic user_behavior --bootstrap-server kafka:9094 --from-beginning --max-messages 10
```

## Flink SQL CLI usage
Logging in to the FlinkCLI docker:
```sh
docker-compose exec flinkcli bash
```
then
```sh
bin/sql-client.sh embedded
```

If all goes well you should see

![Flink Welcome Screen](https://img.alicdn.com/tfs/TB1H1bewlr0gK0jSZFnXXbRRXXa-1696-1512.png)

----
## Error messages

```
Flink SQL> INSERT INTO buy_cnt_per_hour
> SELECT HOUR(TUMBLE_START(ts, INTERVAL '1' HOUR)), COUNT(*)
> FROM user_behavior
> WHERE behavior = 'buy'
> GROUP BY TUMBLE(ts, INTERVAL '1' HOUR);
[INFO] Submitting SQL update statement to the cluster...


Exception in thread "main" org.apache.flink.table.client.SqlClientException: Unexpected exception. This is a bug. Please consider filing an issue.
        at org.apache.flink.table.client.SqlClient.main(SqlClient.java:190)
Caused by: java.lang.RuntimeException: Error running SQL job.
        at org.apache.flink.table.client.gateway.local.LocalExecutor.executeUpdateInternal(LocalExecutor.java:606)
        at org.apache.flink.table.client.gateway.local.LocalExecutor.executeUpdate(LocalExecutor.java:527)
        at org.apache.flink.table.client.cli.CliClient.callInsert(CliClient.java:537)
        at org.apache.flink.table.client.cli.CliClient.callCommand(CliClient.java:299)
        at java.util.Optional.ifPresent(Optional.java:159)
        at org.apache.flink.table.client.cli.CliClient.open(CliClient.java:200)
        at org.apache.flink.table.client.SqlClient.openCli(SqlClient.java:125)
        at org.apache.flink.table.client.SqlClient.start(SqlClient.java:104)
        at org.apache.flink.table.client.SqlClient.main(SqlClient.java:178)
Caused by: java.util.concurrent.ExecutionException: org.apache.flink.runtime.client.JobSubmissionException: Failed to submit JobGraph.
        at java.util.concurrent.CompletableFuture.reportGet(CompletableFuture.java:357)
        at java.util.concurrent.CompletableFuture.get(CompletableFuture.java:1908)
        at org.apache.flink.table.client.gateway.local.LocalExecutor.executeUpdateInternal(LocalExecutor.java:603)
        ... 8 more
Caused by: org.apache.flink.runtime.client.JobSubmissionException: Failed to submit JobGraph.
        at org.apache.flink.client.program.rest.RestClusterClient.lambda$submitJob$7(RestClusterClient.java:359)
        at java.util.concurrent.CompletableFuture.uniExceptionally(CompletableFuture.java:884)
        at java.util.concurrent.CompletableFuture$UniExceptionally.tryFire(CompletableFuture.java:866)
        at java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:488)
        at java.util.concurrent.CompletableFuture.completeExceptionally(CompletableFuture.java:1990)
        at org.apache.flink.runtime.concurrent.FutureUtils.lambda$retryOperationWithDelay$8(FutureUtils.java:287)
        at java.util.concurrent.CompletableFuture.uniWhenComplete(CompletableFuture.java:774)
        at java.util.concurrent.CompletableFuture$UniWhenComplete.tryFire(CompletableFuture.java:750)
        at java.util.concurrent.CompletableFuture.postComplete(CompletableFuture.java:488)
        at java.util.concurrent.CompletableFuture.completeExceptionally(CompletableFuture.java:1990)
        at org.apache.flink.runtime.rest.RestClient.lambda$submitRequest$1(RestClient.java:342)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.DefaultPromise.notifyListener0(DefaultPromise.java:500)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.DefaultPromise.notifyListeners0(DefaultPromise.java:493)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.DefaultPromise.notifyListenersNow(DefaultPromise.java:472)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.DefaultPromise.notifyListeners(DefaultPromise.java:413)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.DefaultPromise.setValue0(DefaultPromise.java:538)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.DefaultPromise.setFailure0(DefaultPromise.java:531)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.DefaultPromise.tryFailure(DefaultPromise.java:111)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.AbstractNioChannel$AbstractNioUnsafe.fulfillConnectPromise(AbstractNioChannel.java:323)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.AbstractNioChannel$AbstractNioUnsafe.finishConnect(AbstractNioChannel.java:339)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:685)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:632)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:549)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:511)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.SingleThreadEventExecutor$5.run(SingleThreadEventExecutor.java:918)
        at org.apache.flink.shaded.netty4.io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74)
        at java.lang.Thread.run(Thread.java:748)
Caused by: org.apache.flink.runtime.concurrent.FutureUtils$RetryException: Could not complete the operation. Number of retries has been exhausted.
        at org.apache.flink.runtime.concurrent.FutureUtils.lambda$retryOperationWithDelay$8(FutureUtils.java:284)
        ... 21 more
Caused by: java.util.concurrent.CompletionException: org.apache.flink.shaded.netty4.io.netty.channel.AbstractChannel$AnnotatedConnectException: Connection refused: localhost/127.0.0.1:8081
        at java.util.concurrent.CompletableFuture.encodeThrowable(CompletableFuture.java:292)
        at java.util.concurrent.CompletableFuture.completeThrowable(CompletableFuture.java:308)
        at java.util.concurrent.CompletableFuture.uniCompose(CompletableFuture.java:957)
        at java.util.concurrent.CompletableFuture$UniCompose.tryFire(CompletableFuture.java:940)
        ... 19 more
Caused by: org.apache.flink.shaded.netty4.io.netty.channel.AbstractChannel$AnnotatedConnectException: Connection refused: localhost/127.0.0.1:8081
Caused by: java.net.ConnectException: Connection refused
        at sun.nio.ch.SocketChannelImpl.checkConnect(Native Method)
        at sun.nio.ch.SocketChannelImpl.finishConnect(SocketChannelImpl.java:714)
        at org.apache.flink.shaded.netty4.io.netty.channel.socket.nio.NioSocketChannel.doFinishConnect(NioSocketChannel.java:327)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.AbstractNioChannel$AbstractNioUnsafe.finishConnect(AbstractNioChannel.java:336)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:685)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:632)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:549)
        at org.apache.flink.shaded.netty4.io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:511)
        at org.apache.flink.shaded.netty4.io.netty.util.concurrent.SingleThreadEventExecutor$5.run(SingleThreadEventExecutor.java:918)
        at org.apache.flink.shaded.netty4.io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74)
        at java.lang.Thread.run(Thread.java:748)

Shutting down the session...
done.
root@eb013f576a2d:/opt/flink#
```
