FROM flink:1.20.1-scala_2.12-java11

# Download connector libraries
RUN wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.4.0-1.20/flink-connector-kafka-3.4.0-1.20.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-base/1.20.1/flink-connector-base-1.20.1.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.8.0/kafka-clients-3.8.0.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/com/github/luben/zstd-jni/1.5.7-2/zstd-jni-1.5.7-2.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch7/3.0.1-1.17/flink-sql-connector-elasticsearch7-3.0.1-1.17.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-json/1.20.1/flink-json-1.20.1.jar; \
    chown -R flink:flink /opt/flink/lib