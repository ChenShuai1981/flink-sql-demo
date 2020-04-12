# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04
MAINTAINER Apache Software Foundation <dev@zeppelin.apache.org>

ENV Z_VERSION="0.9.0-preview1"

ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    Z_HOME="/zeppelin" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ZEPPELIN_ADDR="0.0.0.0"

RUN echo "$LOG_TAG update and install basic packages" && \
    apt-get -y update && \
    apt-get install -y locales && \
    locale-gen $LANG && \
    apt-get install -y software-properties-common && \
    apt -y autoclean && \
    apt -y dist-upgrade && \
    apt-get install -y build-essential

RUN echo "$LOG_TAG install tini related packages" && \
    apt-get install -y wget curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN echo "$LOG_TAG Install java8" && \
    apt-get -y update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# should install conda first before numpy, matploylib since pip and python will be installed by conda
RUN echo "$LOG_TAG Install miniconda3 related packages" && \
    apt-get -y update && \
    apt-get install -y bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion && \
    echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

ENV PATH /opt/conda/bin:$PATH

RUN echo "$LOG_TAG Install python related packages" && \
    apt-get -y update && \
    apt-get install -y python-dev python-pip && \
    apt-get install -y gfortran && \
    # numerical/algebra packages
    apt-get install -y libblas-dev libatlas-dev liblapack-dev && \
    # font, image
    apt-get install -y libpng-dev libfreetype6-dev libxft-dev && \
    # for tkinter
    apt-get install -y python-tk libxml2-dev libxslt-dev zlib1g-dev && \
    hash -r && \
    conda config --set always_yes yes --set changeps1 no && \
    conda update -q conda && \
    conda info -a && \
    conda config --add channels conda-forge && \
    pip install -q pycodestyle==2.5.0 && \
    pip install -q numpy==1.17.3 pandas==0.25.0 scipy==1.3.1 grpcio==1.19.0 bkzep==0.6.1 hvplot==0.5.2 protobuf==3.10.0 pandasql==0.7.3 ipython==7.8.0 matplotlib==3.0.3 ipykernel==5.1.2 jupyter_client==5.3.4 bokeh==1.3.4 panel==0.6.0 holoviews==1.12.3 pycodestyle==2.5.0 apache_beam==2.15.0

RUN echo "$LOG_TAG Install R related packages" && \
    echo "PATH: $PATH" && \
    ls /opt/conda/bin && \
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | tee -a /etc/apt/sources.list && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | apt-key add - && \
    apt-get -y update && \
    apt-get -y --allow-unauthenticated install r-base r-base-dev && \
    R -e "install.packages('evaluate', repos = 'https://cloud.r-project.org')" && \
    R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('IRkernel', repos = 'https://cloud.r-project.org');IRkernel::installspec()" && \
    R -e "install.packages('shiny', repos = 'https://cloud.r-project.org')" && \
    # for devtools, Rcpp
    apt-get -y install libcurl4-gnutls-dev libssl-dev && \
    R -e "install.packages('devtools', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" && \
    Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')"

# Install kubectl
RUN apt-get update && apt-get install -y apt-transport-https 
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

RUN echo "$LOG_TAG Cleanup" && \
    apt-get autoclean && \
    apt-get clean

RUN echo "$LOG_TAG Download Zeppelin binary" && \
    wget --quiet -O /tmp/zeppelin-${Z_VERSION}-bin-all.tgz http://archive.apache.org/dist/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-all.tgz && \
    tar -zxvf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    rm -rf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    mkdir -p ${Z_HOME} && \
    mv /zeppelin-${Z_VERSION}-bin-all/* ${Z_HOME}/ && \
    chown -R root:root ${Z_HOME} && \
    mkdir -p ${Z_HOME}/logs ${Z_HOME}/run ${Z_HOME}/webapps && \
    # Allow process to edit /etc/passwd, to create a user entry for zeppelin
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    # Give access to some specific folders
    chmod -R 775 "${Z_HOME}/logs" "${Z_HOME}/run" "${Z_HOME}/notebook" "${Z_HOME}/conf" && \
    # Allow process to create new folders (e.g. webapps)
    chmod 775 ${Z_HOME}

# Gary Feng: Install local Flink 1.10
# from https://github.com/apache/flink-docker/blob/346809e6cab2ca0ac702fb4d2bf56afb6ee3c437/1.10/scala_2.11-debian/Dockerfile
# Install dependencies
RUN set -ex; \
  apt-get update; \
  apt-get -y install libsnappy1v5 gettext-base; \
  rm -rf /var/lib/apt/lists/*

# Configure Flink version
ENV FLINK_VERSION=1.10.0 \
    SCALA_VERSION=2.11 \
    GPG_KEY=BB137807CEFBE7DD2616556710B12A1F89C115E8

# Prepare environment
ENV FLINK_HOME=/opt/flink
ENV PATH=$FLINK_HOME/bin:$PATH
# RUN groupadd --system --gid=9999 flink && \
#     useradd --system --home-dir $FLINK_HOME --uid=9999 --gid=flink flink
WORKDIR $FLINK_HOME

ENV FLINK_URL_FILE_PATH=flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_${SCALA_VERSION}.tgz
# Not all mirrors have the .asc files
ENV FLINK_TGZ_URL=https://www.apache.org/dyn/closer.cgi?action=download&filename=${FLINK_URL_FILE_PATH} \
    FLINK_ASC_URL=https://www.apache.org/dist/${FLINK_URL_FILE_PATH}.asc

# Install Flink
RUN set -ex; \
  wget -nv -O flink.tgz "$FLINK_TGZ_URL"; \
  wget -nv -O flink.tgz.asc "$FLINK_ASC_URL";

RUN  tar -xf flink.tgz --strip-components=1; \
  rm flink.tgz; \
  \
  chmod -R 775 "${FLINK_HOME}/log" "${FLINK_HOME}/conf" "${FLINK_HOME}/lib" && \
  chown -R 775 $FLINK_HOME;

# install https://repo1.maven.org/maven2/org/apache/flink/flink-shaded-hadoop-2/2.8.3-10.0/flink-shaded-hadoop-2-2.8.3-10.0.jar
RUN wget -P /opt/flink/lib https://repo1.maven.org/maven2/org/apache/flink/flink-shaded-hadoop-2/2.8.3-10.0/flink-shaded-hadoop-2-2.8.3-10.0.jar

# install Jupyter etc.
RUN pip install -q jupyter grpcio protobuf

# Install additional JARs for mysql and flink
RUN wget -P ./lib/ https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.48/mysql-connector-java-5.1.48.jar | \    
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/avro/avro/1.8.2/avro-1.8.2.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-avro/1.10.0/flink-avro-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-avro/1.10.0/flink-avro-1.10.0-sql-jar.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-compress/1.10.0/flink-compress-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-cassandra_2.11/1.10.0/flink-connector-cassandra_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-filesystem_2.11/1.10.0/flink-connector-filesystem_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-hive_2.11/1.10.0/flink-connector-hive_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka_2.11/1.10.0/flink-connector-kafka_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka-base_2.11/1.10.0/flink-connector-kafka-base_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kinesis_2.11/1.10.0/flink-connector-kinesis_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-nifi_2.11/1.10.0/flink-connector-nifi_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-rabbitmq_2.11/1.10.0/flink-connector-rabbitmq_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-csv/1.10.0/flink-csv-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-csv/1.10.0/flink-csv-1.10.0-sql-jar.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-hadoop-compatibility_2.11/1.10.0/flink-hadoop-compatibility_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-hbase_2.11/1.10.0/flink-hbase_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-hcatalog_2.11/1.10.0/flink-hcatalog_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-jdbc_2.11/1.10.0/flink-jdbc_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.10.0/flink-json-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-metrics-core/1.10.0/flink-metrics-core-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-metrics-jmx_2.11/1.10.0/flink-metrics-jmx_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-metrics-prometheus_2.11/1.10.0/flink-metrics-prometheus_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-parquet_2.11/1.10.0/flink-parquet_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-python_2.11/1.10.0/flink-python_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.10.0/flink-sql-connector-kafka_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch6_2.11/1.10.0/flink-sql-connector-elasticsearch6_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-table-planner_2.11/1.10.0/flink-table-planner_2.11-1.10.0.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/2.1.1/kafka-clients-2.1.1.jar | \
    wget -P ./lib/ https://repo1.maven.org/maven2/org/apache/kafka/kafka-streams/2.1.1/kafka-streams-2.1.1.jar

WORKDIR /

# end Gary Feng

COPY log4j.properties ${Z_HOME}/conf/

USER 1000

EXPOSE 6123 8081 8080

ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]