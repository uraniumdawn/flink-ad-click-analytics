# Ad Click Analytics: Real-Time CTR Data Pipeline

This project sets up a complete **real-time analytics pipeline** using **Apache Flink**, **Kafka**, **Elasticsearch**, and **Kibana**.
The pipeline computes **Click-Through Rate (CTR)** 
for ad campaigns, unique users, revenue and detects CTR anomalies in 1-minute windows.
---

## Components

| Component      | Description                           | URL                    |
|----------------|---------------------------------------|------------------------|
| Flink          | Streaming engine for data processing  | http://localhost:8081  |
| Kafka          | Message broker for streaming events   | -                      |
| Kafka UI       | UI for observing Kafka topics         | http://localhost:20065 |
| Elasticsearch  | Stores Ad-Click Analytics metrics     | http://localhost:9200  |
| Kibana         | Dashboards                            | http://localhost:5601  |
| Data Generator | Generate fake data for pipeline       | -                      |

---

## Getting Started

### 1. Launch the Environment

```bash
docker-compose up --build
```

This starts:
- Flink (JobManager + TaskManager)
- Kafka + Kafka UI
- Elasticsearch
- Kibana with preloaded dashboards
- Flink SQL Client container (for submitting jobs)

### 2. Submit Fling SQL jobs

```bash
docker exec -it sql-client bash -c './bin/sql-client.sh embedded -i /opt/flink/sql/init.sql -f /opt/flink/sql/job.sql'
```
---

## Flink

The Flink jobs:
- Reads from source Kafka topics
- Joins and aggregates events in 1-minute windows
- Calculates CTR per campaign
- Count unique users per device type in 1-minute windows
- Calculate amount of revenue for each Ad campaign
- Detects CTR anomalies (`ctr > 0.5`)
- Outputs results to Kafka and Elasticsearch
---

## Source

### Kafka topics

| Topic                   | Description             |
|-------------------------|-------------------------|
| `ad-impressions`        | Ad impression events    |
| `ad-clicks`             | Ad click events         |

---

## Sink

| Topic                   | Index                  | Description                  |
|-------------------------|------------------------|------------------------------|
| `ctr-metrics`           | `ctr_metrics`          | CTR per campaign             |
| `unique-users-metrics`  | `unique_users_metrics` | Unique users per device type |
| `revenue-metrics`       | `revenue_metrics`      | Revenue for each Ad campaign |
| `ctr-anomalies`         | `ctr_anomalies`        | CTR anomalies                |

---

## Kibana Dashboard

### Dashboard Features:
- Dashboard available on this [link](http://localhost:5601/app/dashboards#/view/b75fe0f0-1ec5-11f0-81f5-6bb97eff8ee7?_g=(filters:!())
- CTR per campaign plotted over 1-minute windows
- Time window filters (e.g., “Last 1 hour”)
- Dashboard and index pattern are **auto-imported** during startup
---

## Notes
- **There might need some time while data is arrived into Elasticsearch and be reflected on the Dashboard**
- Flink job emits CTR metrics with timestamp fields `window_start` and `window_end`
- Elasticsearch auto-mapping converts ISO timestamps correctly
- All time series analysis is based on `window_start` field
---

## Need Help?

Feel free to open an issue or reach out if you need help customizing this pipeline for your use case!




