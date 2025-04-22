SET 'sql-client.execution.result-mode'='table';
SET 'execution.runtime-mode'='streaming';
SET 'table.exec.state.ttl'='600000';
SET 'parallelism.default' = '4';

-- Define available database
CREATE DATABASE ad_metrics;
USE ad_metrics;

-- Define Tables
CREATE TABLE ad_impressions (
    impression_id STRING,
    user_id STRING,
    campaign_id STRING,
    ad_id STRING,
    device_type STRING,
    browser STRING,
    event_timestamp BIGINT,
    event_timestamp_ltz AS TO_TIMESTAMP_LTZ(event_timestamp, 3),
    proctime AS PROCTIME(),
    cost DECIMAL(10, 2),
    WATERMARK FOR event_timestamp_ltz AS event_timestamp_ltz - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'ad-impressions',
    'properties.bootstrap.servers' = 'kafka:9092',
    'format' = 'json',
    'properties.group.id' = 'ad-impressions.group.id.v1',
    'scan.startup.mode' = 'earliest-offset',
    'json.ignore-parse-errors' = 'true',
    'json.fail-on-missing-field' = 'false',
    'json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE ad_clicks (
    click_id STRING,
    impression_id STRING,
    user_id STRING,
    event_timestamp BIGINT,
    event_timestamp_ltz AS TO_TIMESTAMP_LTZ(event_timestamp, 3),
    proctime AS PROCTIME(),
    WATERMARK FOR event_timestamp_ltz AS event_timestamp_ltz - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'ad-clicks',
    'properties.bootstrap.servers' = 'kafka:9092',
    'format' = 'json',
    'properties.group.id' = 'ad-clicks.group.id.v1',
    'scan.startup.mode' = 'earliest-offset',
    'json.ignore-parse-errors' = 'true',
    'json.fail-on-missing-field' = 'false',
    'json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE ctr_metrics (
    campaign_id STRING,
    showed BIGINT NOT NULL,
    clicked BIGINT NOT NULL,
    ctr DOUBLE NOT NULL,
    window_start TIMESTAMP_LTZ(3),
    window_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'ctr-metrics',
    'properties.bootstrap.servers' = 'kafka:9092',
    'key.format' = 'raw',
    'key.fields' = 'campaign_id',
    'value.format' = 'json',
    'value.json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE ctr_metrics_es (
    campaign_id STRING,
    showed BIGINT NOT NULL,
    clicked BIGINT NOT NULL,
    ctr DOUBLE NOT NULL,
    window_start TIMESTAMP_LTZ(3),
    window_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://elasticsearch:9200',
    'index' = 'ctr_metrics',
    'json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE ctr_anomalies (
    campaign_id STRING,
    ctr DOUBLE NOT NULL,
    anomaly_start TIMESTAMP_LTZ(3),
    end_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'ctr-anomalies',
    'properties.bootstrap.servers' = 'kafka:9092',
    'value.format' = 'json',
    'key.format' = 'raw',
    'key.fields' = 'campaign_id',
    'value.format' = 'json',
    'value.json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE ctr_anomalies_es (
    campaign_id STRING,
    anomaly_ctr DOUBLE NOT NULL,
    anomaly_start TIMESTAMP_LTZ(3),
    anomaly_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://elasticsearch:9200',
    'index' = 'ctr_anomalies',
    'json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE unique_users_metrics (
    campaign_id STRING,
    device_type STRING,
    unique_users BIGINT NOT NULL,
    window_start TIMESTAMP_LTZ(3),
    window_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'unique-users-metrics',
    'properties.bootstrap.servers' = 'kafka:9092',
    'value.format' = 'json',
    'key.format' = 'raw',
    'key.fields' = 'campaign_id',
    'value.format' = 'json',
    'value.json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE unique_users_metrics_es (
    campaign_id STRING,
    device_type STRING,
    unique_users BIGINT NOT NULL,
    window_start TIMESTAMP_LTZ(3),
    window_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://elasticsearch:9200',
    'index' = 'unique_users_metrics',
    'json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE revenue_metrics (
    campaign_id STRING,
    device_type STRING,
    revenue DECIMAL(10, 2),
    window_start TIMESTAMP_LTZ(3),
    window_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'revenue-metrics',
    'properties.bootstrap.servers' = 'kafka:9092',
    'value.format' = 'json',
    'key.format' = 'raw',
    'key.fields' = 'campaign_id',
    'value.format' = 'json',
    'value.json.timestamp-format.standard' = 'ISO-8601'
);

CREATE TABLE revenue_metrics_es (
    campaign_id STRING,
    device_type STRING,
    revenue DECIMAL(10, 2),
    window_start TIMESTAMP_LTZ(3),
    window_end TIMESTAMP_LTZ(3)
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://elasticsearch:9200',
    'index' = 'revenue_metrics',
    'json.timestamp-format.standard' = 'ISO-8601'
);
