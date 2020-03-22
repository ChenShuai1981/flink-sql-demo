# Flink SQL Demo

Based on http://wuchong.me/blog/2020/02/25/demo-building-real-time-application-with-flink-sql/
----
## Installation

From the blog above

该 Docker Compose 中包含的容器有：

- DataGen: 数据生成器。容器启动后会自动开始生成用户行为数据，并发送到 Kafka 集群中。默认每秒生成 1000 条数据，持续生成约 3 小时。也可以更改 docker-compose.yml 中 datagen 的 speedup 参数来调整生成速率（重启 docker compose 才能生效）。
- MySQL: 集成了 MySQL 5.7 ，以及预先创建好了类目表（category），预先填入了子类目与顶级类目的映射关系，后续作为维表使用。
- Kafka: 主要用作数据源。DataGen 组件会自动将数据灌入这个容器中。
- Zookeeper: Kafka 容器依赖。
- Elasticsearch: 主要存储 Flink SQL 产出的数据。
- Kibana: 可视化 Elasticsearch 中的数据。

在启动容器前，建议修改 Docker 的配置，将资源调整到 4GB 以及 4核。启动所有的容器，只需要在 docker-compose.yml 所在目录下运行如下命令。
```
docker-compose up -d
```
该命令会以 detached 模式自动启动 Docker Compose 配置中定义的所有容器。你可以通过 docker ps 来观察上述的五个容器是否正常启动了。 也可以访问 http://localhost:5601/ 来查看 Kibana 是否运行正常。

另外可以通过如下命令停止所有的容器：
```
docker-compose down
```

