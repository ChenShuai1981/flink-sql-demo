
-- Gary Feng, March, 2020
--   Example from http://wuchong.me/blog/2020/02/25/demo-building-real-time-application-with-flink-sql/
-- You an copy parts of these code and paste in the Flink SQL CLI
--   Try paste in one SQL command at a time. 

-- Notes
--  #1 make sure you use `kafka:2181` for linking to kafka docker
--  #2 don't use `localhost:9200` for ES connection; see below. We
--    use ipconfig to find the IP address 192.168.56.1
--    consider using the @IPAddress='192.168.56.1' as local var

-- source connection
-- DROP TABLE user_behavior;
-- source data from user_behavior.log in the datagen docker, 54M
-- https://github.com/garyfeng/flink-sql-submit/blob/master/src/main/resources/user_behavior.log
-- docker run jark/datagen:0.1 head /opt/datagen/user_behavior.log
--   782827,3335233,1080785,pv,1511712207
--   966696,2018032,2920476,buy,1511712207
--   108016,483057,1868423,pv,1511712207
--   ...

DROP TABLE  IF EXISTS user_behavior;

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

-- SELECT * FROM user_behavior; 


-- sink 
DROP TABLE  IF EXISTS buy_cnt_per_hour;
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
DROP TABLE  IF EXISTS cumulative_uv;

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

-- 在 SQL CLI 中创建 MySQL 表，后续用作维表查询。
DROP TABLE  IF EXISTS category_dim;

CREATE TABLE category_dim (
    sub_category_id BIGINT,  -- 子类目
    parent_category_id BIGINT -- 顶级类目
) WITH (
    'connector.type' = 'jdbc',
    'connector.url' = 'jdbc:mysql://192.168.56.1:3306/flink',
    'connector.table' = 'category',
    'connector.driver' = 'com.mysql.jdbc.Driver',
    'connector.username' = 'root',
    'connector.password' = '123456',
    'connector.lookup.cache.max-rows' = '5000',
    'connector.lookup.cache.ttl' = '10min'
);

-- 同时我们再创建一个 Elasticsearch 表，用于存储类目统计结果。

CREATE TABLE top_category (
    category_name STRING,  -- 类目名称
    buy_cnt BIGINT  -- 销量
) WITH (
    'connector.type' = 'elasticsearch',
    'connector.version' = '6',
    'connector.hosts' = 'http://192.168.56.1:9200',
    'connector.index' = 'top_category',
    'connector.document-type' = 'user_behavior',
    'format.type' = 'json',
    'update-mode' = 'upsert'
);

-- 第一步我们通过维表关联，补全类目名称。我们仍然使用 CREATE VIEW 将该查询注册成一个视图，简化逻辑。维表关联使用 temporal join 语法，可以查看文档了解更多：https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/table/streaming/joins.html#join-with-a-temporal-table

CREATE VIEW rich_user_behavior AS
SELECT U.user_id, U.item_id, U.behavior, 
  CASE C.parent_category_id
    WHEN 1 THEN '服饰鞋包'
    WHEN 2 THEN '家装家饰'
    WHEN 3 THEN '家电'
    WHEN 4 THEN '美妆'
    WHEN 5 THEN '母婴'
    WHEN 6 THEN '3C数码'
    WHEN 7 THEN '运动户外'
    WHEN 8 THEN '食品'
    ELSE '其他'
  END AS category_name
FROM user_behavior AS U LEFT JOIN category_dim FOR SYSTEM_TIME AS OF U.proctime AS C
ON U.category_id = C.sub_category_id;

-- 最后根据 类目名称分组，统计出 buy 的事件数，并写入 Elasticsearch 中。

INSERT INTO top_category
SELECT category_name, COUNT(*) buy_cnt
FROM rich_user_behavior
WHERE behavior = 'buy'
GROUP BY category_name;
