
-- Gary Feng, March, 2020
--   Example from http://wuchong.me/blog/2020/02/25/demo-building-real-time-application-with-flink-sql/
-- You an copy parts of these code and paste in the Flink SQL CLI
--   Try paste in one SQL command at a time. 

-- Notes
--  #1 make sure you use `kafka:2181` for linking to kafka docker
--  #2 don't use `localhost:9200` for ES connection; see below

-- source connection
DROP TABLE user_behavior;

CREATE TABLE user_behavior (
    user_id BIGINT,
    item_id BIGINT,
    category_id BIGINT,
    behavior STRING,
    ts TIMESTAMP(3),
    proctime as PROCTIME(),
    WATERMARK FOR ts as ts - INTERVAL '5' SECOND
) WITH (
    'connector.type' = 'kafka',
    'connector.version' = 'universal',
    'connector.topic' = 'user_behavior',
    'connector.startup-mode' = 'earliest-offset',
    'connector.properties.zookeeper.connect' = 'kafka:2181',
    'connector.properties.bootstrap.servers' = 'kafka:9094',
    'format.type' = 'json'
);

SELECT * FROM user_behavior; 


-- sink 
DROP TABLE buy_cnt_per_hour;
-- see https://github.com/garyfeng/flink-sql-demo/issues/1
--   for why you can't use localhost here
CREATE TABLE buy_cnt_per_hour ( 
    hour_of_day BIGINT,
    buy_cnt BIGINT
) WITH (
    'connector.type' = 'elasticsearch',
    'connector.version' = '6',
    'connector.hosts' = 'http://192.168.56.1:9200',
    'connector.index' = 'buy_cnt_per_hour',
    'connector.document-type' = 'user_behavior',
    'connector.bulk-flush.max-actions' = '1', 
    'format.type' = 'json', 
    'update-mode' = 'append'
);

-- query
--   need to be pasted to the Flink SQL CLI separately. 
INSERT INTO buy_cnt_per_hour
SELECT HOUR(TUMBLE_START(ts, INTERVAL '1' HOUR)), COUNT(*)
FROM user_behavior
WHERE behavior = 'buy'
GROUP BY TUMBLE(ts, INTERVAL '1' HOUR);


------

CREATE TABLE cumulative_uv (
    time_str STRING,
    uv BIGINT
) WITH (
    'connector.type' = 'elasticsearch',
    'connector.version' = '6',
    'connector.hosts' = 'http://192.168.56.1:9200',
    'connector.index' = 'cumulative_uv',
    'connector.document-type' = 'user_behavior',
    'format.type' = 'json',
    'update-mode' = 'upsert'
);

CREATE VIEW uv_per_10min AS
SELECT 
  MAX(SUBSTR(DATE_FORMAT(ts, 'HH:mm'),1,4) || '0') OVER w AS time_str, 
  COUNT(DISTINCT user_id) OVER w AS uv
FROM user_behavior
WINDOW w AS (ORDER BY proctime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);

INSERT INTO cumulative_uv
SELECT time_str, MAX(uv)
FROM uv_per_10min
GROUP BY time_str;

-- CUP gets to 50% for about 20 sec and then dropped back.

------

