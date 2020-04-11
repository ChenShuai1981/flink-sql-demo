FROM flink:1.10.0-scala_2.11

# install additional JARs
WORKDIR /opt/flink/
RUN wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.10.0/flink-json-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.10.0/flink-sql-connector-kafka_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch6_2.11/1.10.0/flink-sql-connector-elasticsearch6_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-jdbc_2.11/1.10.0/flink-jdbc_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.48/mysql-connector-java-5.1.48.jar

RUN wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-avro/1.10.0/flink-avro-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-avro/1.10.0/flink-avro-1.10.0-sql-jar.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-compress/1.10.0/flink-compress-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-cassandra_2.11/1.10.0/flink-connector-cassandra_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-filesystem_2.11/1.10.0/flink-connector-filesystem_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-hive_2.11/1.10.0/flink-connector-hive_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka-base_2.11/1.10.0/flink-connector-kafka-base_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kinesis_2.11/1.10.0/flink-connector-kinesis_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-nifi_2.11/1.10.0/flink-connector-nifi_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-rabbitmq_2.11/1.10.0/flink-connector-rabbitmq_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-csv/1.10.0/flink-csv-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-csv/1.10.0/flink-csv-1.10.0-sql-jar.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-hadoop-compatibility_2.11/1.10.0/flink-hadoop-compatibility_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-hbase_2.11/1.10.0/flink-hbase_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-hcatalog_2.11/1.10.0/flink-hcatalog_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-parquet_2.11/1.10.0/flink-parquet_2.11-1.10.0.jar | \
    # wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-python_2.11/1.10.0/flink-python_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.10.0/flink-sql-connector-kafka_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch6_2.11/1.10.0/flink-sql-connector-elasticsearch6_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-table-planner_2.11/1.10.0/flink-table-planner_2.11-1.10.0.jar 

# install vim
RUN apt-get update && apt-get -y install vim
# change the taskmanager.numberOfTaskSlots from 1 to 10
RUN sed -i 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: 10/' \
    conf/flink-conf.yaml
