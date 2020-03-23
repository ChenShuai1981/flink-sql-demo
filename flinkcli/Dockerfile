FROM flink:1.10.0-scala_2.11

# install additional JARs
WORKDIR /opt/flink/
RUN wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.10.0/flink-json-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.10.0/flink-sql-connector-kafka_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch6_2.11/1.10.0/flink-sql-connector-elasticsearch6_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-jdbc_2.11/1.10.0/flink-jdbc_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.48/mysql-connector-java-5.1.48.jar

# install vim
RUN apt-get update && apt-get -y install vim
# change the taskmanager.numberOfTaskSlots from 1 to 10
RUN sed -i 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: 10/' \
    conf/flink-conf.yaml
