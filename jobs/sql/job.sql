-- CRT calculation
-- 1. Join Windowed Impression with Windowed Click by impression_id;
-- 2. Group by campaign_id and windowed timestamps;
-- 3. Count showed and clicked impressions within time frame and calculate CTR;
-- 4. Save to View

CREATE VIEW ctr_metrics_vw AS 
SELECT
    i.campaign_id,
    count(i.impression_id) AS showed,
    count(CASE WHEN c.impression_id IS NOT NULL THEN c.impression_id END) AS clicked,
    round(cast(count(CASE WHEN c.impression_id IS NOT NULL THEN c.impression_id END) AS DOUBLE)/count(i.impression_id), 5) AS ctr,
    i.window_start,
    i.window_end,
    PROCTIME() AS proctime
FROM 
    (SELECT * FROM TABLE(TUMBLE(TABLE ad_impressions, DESCRIPTOR(event_timestamp_ltz), INTERVAL '1' MINUTE))) AS i
LEFT JOIN
    (SELECT * FROM TABLE(TUMBLE(TABLE ad_clicks, DESCRIPTOR(event_timestamp_ltz), INTERVAL '1' MINUTE))) AS c
ON
    i.impression_id = c.impression_id AND
    i.window_start = c.window_start AND
    i.window_end = c.window_end
GROUP BY
    i.campaign_id,
    i.window_start,
    i.window_end;

-- Detect anomalies (CTR > 0.5)
CREATE VIEW ctr_anomalies_vw AS
SELECT 
    campaign_id,
    anomaly_ctr,
    anomaly_start,
    anomaly_end
FROM 
    ctr_metrics_vw
MATCH_RECOGNIZE (
    PARTITION BY campaign_id
    ORDER BY proctime
    MEASURES
        A.ctr AS anomaly_ctr,
        A.window_start AS anomaly_start,
        A.window_end AS anomaly_end
    ONE ROW PER MATCH
    AFTER MATCH SKIP TO NEXT ROW
    PATTERN (A)
    DEFINE
        A AS A.ctr > 0.5
);
-- -----------------------------------------------------------------------------------------------------------------------------
-- Calculating unique User that clicked the ad
-- 1. Join Windowed Impression with Windowed Click by impression_id;
-- 2. Group by campaign_id, device_type and windowed timestamps;
-- 3. Count uniques users;
-- 4. Save to View

CREATE VIEW unique_users_metrics_vw AS
SELECT
    i.campaign_id,
    i.device_type,
    count(DISTINCT c.user_id) AS unique_users,
    i.window_start,
    i.window_end
FROM 
    (SELECT * FROM TABLE(TUMBLE(TABLE ad_impressions, DESCRIPTOR(event_timestamp_ltz), INTERVAL '1' MINUTE))) AS i
INNER JOIN
    (SELECT * FROM TABLE(TUMBLE(TABLE ad_clicks, DESCRIPTOR(event_timestamp_ltz), INTERVAL '1' MINUTE))) AS c
ON
    i.impression_id = c.impression_id AND
    i.window_start = c.window_start AND
    i.window_end = c.window_end
GROUP BY
    i.campaign_id,
    i.device_type,
    i.window_start,
    i.window_end;
-- -----------------------------------------------------------------------------------------------------------------------------
-- Calculatin revenue by campaign
-- 1. Join Windowed Impression with Windowed Click by impression_id;
-- 2. Group by campaign_id, device_type and windowed timestamps;
-- 3. Sum the cost of each clicked ad;
-- 4. Save to View

CREATE VIEW revenue_metrics_vw AS
SELECT
    i.campaign_id,
    i.device_type,
    sum(i.cost) AS revenue,
    i.window_start,
    i.window_end
FROM 
    (SELECT * FROM TABLE(TUMBLE(TABLE ad_impressions, DESCRIPTOR(event_timestamp_ltz), INTERVAL '1' MINUTE))) AS i
INNER JOIN
    (SELECT * FROM TABLE(TUMBLE(TABLE ad_clicks, DESCRIPTOR(event_timestamp_ltz), INTERVAL '1' MINUTE))) AS c
ON
    i.impression_id = c.impression_id AND
    i.window_start = c.window_start AND
    i.window_end = c.window_end
GROUP BY
    i.campaign_id,
    i.device_type,
    i.window_start,
    i.window_end;
-- -----------------------------------------------------------------------------------------------------------------------------
-- Sink metrics to Kafka and Elasticsearch

SET 'pipeline.name' = 'Ad-Click Analytics';
EXECUTE STATEMENT SET
BEGIN
    INSERT INTO ctr_metrics 
    SELECT 
        campaign_id,
        showed,
        clicked,
        ctr,
        window_start,
        window_end
    FROM ctr_metrics_vw;
        
    INSERT INTO ctr_metrics_es
    SELECT 
        campaign_id,
        showed,
        clicked,
        ctr,
        window_start,
        window_end
    FROM ctr_metrics_vw;
    
    INSERT INTO ctr_anomalies SELECT * FROM ctr_anomalies_vw;
    INSERT INTO ctr_anomalies_es SELECT * FROM ctr_anomalies_vw;

    INSERT INTO unique_users_metrics SELECT * FROM unique_users_metrics_vw;
    INSERT INTO unique_users_metrics_es SELECT * FROM unique_users_metrics_vw;
    
    INSERT INTO revenue_metrics SELECT * FROM revenue_metrics_vw;
    INSERT INTO revenue_metrics_es SELECT * FROM revenue_metrics_vw;
END;