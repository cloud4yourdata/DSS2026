CREATE DATABASE IF NOT EXISTS DSS2026;
USE DSS2026;

SELECT version();

DROP TABLE IF EXISTS InputTable;
CREATE TABLE IF NOT EXISTS InputTable
(
    Key UInt8,
    Value UInt8 
)
ENGINE = MergeTree
ORDER BY Key;

DROP TABLE IF EXISTS TableEven;
CREATE TABLE IF NOT EXISTS TableEven
(
    Key UInt8,
    Value UInt8,
    Timestamp DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY Key;

---Filtering even odd
DROP TABLE IF EXISTS TableEven;
CREATE TABLE IF NOT EXISTS TableEven
(
    Key UInt8,
    Value UInt8,
    Timestamp DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY Key;

DROP TABLE IF EXISTS TableOdd;
CREATE TABLE IF NOT EXISTS TableOdd
(
    Key UInt8,
    Value UInt8,
    Timestamp DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY Key;
--Event
DROP VIEW IF EXISTS mv_TableEven;
CREATE MATERIALIZED VIEW mv_TableEven
TO TableEven
AS
SELECT * FROM InputTable WHERE Key % 2 = 0;

--Odd
DROP VIEW IF EXISTS mv_TableOdd;
CREATE MATERIALIZED VIEW mv_TableOdd
TO TableOdd
AS
SELECT * FROM InputTable WHERE Key % 2 <> 0;

---Transformation
DROP TABLE IF EXISTS TableX100;
CREATE TABLE IF NOT EXISTS TableX100
(
    Key UInt8,
    Value UInt16,
    Timestamp DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY Key;

DROP VIEW IF EXISTS mv_TableX100;
CREATE MATERIALIZED VIEW mv_TableX100
TO TableX100
AS
SELECT Key,Value * 100 AS Value FROM InputTable;

DROP TABLE IF EXISTS TableX100Negative;
CREATE TABLE IF NOT EXISTS TableX100Negative
(
    Key UInt8,
    Value Int16,
    Timestamp DateTime DEFAULT now()
)
ENGINE = MergeTree
ORDER BY Key;

DROP VIEW IF EXISTS mv_TableX100Negative;
CREATE MATERIALIZED VIEW mv_TableX100Negative
TO TableX100Negative
AS
SELECT Key,Value * (-1) AS Value FROM TableX100;

---Roll-up
DROP TABLE IF EXISTS TableAgg;
CREATE TABLE IF NOT EXISTS TableAgg 
(
    Key UInt8,
    AvgValue AggregateFunction(avg,UInt8)
)
ENGINE = AggregatingMergeTree()
ORDER BY Key;

DROP VIEW IF EXISTS mv_TableAgg;
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_TableAgg 
TO TableAgg
AS 
SELECT 
 Key,
 avgState(Value) AS AvgValue
FROM InputTable
GROUP BY ALL; 

