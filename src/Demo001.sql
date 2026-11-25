USE DSS2026;
SHOW TABLES IN DSS2026;
---Initial status
SELECT 'InputTable' AS TableName, COUNT() FROM InputTable
UNION ALL
SELECT 'TableEven' AS TableName, COUNT() FROM TableEven
UNION ALL
SELECT 'TableOdd' AS TableName, COUNT() FROM TableOdd
UNION ALL
SELECT 'TableX100' AS TableName, COUNT() FROM TableX100
UNION ALL
SELECT 'TableX100' AS TableName, COUNT() FROM TableX100Negative
UNION ALL
SELECT 'TableAgg' AS TableName, COUNT() FROM TableAgg;

--Insert into InputTable
INSERT INTO InputTable (Key,Value)
VALUES
(1,4),
(1,6),
(2,10),
(3,12);

--Table Status
SELECT 'InputTable' AS TableName, COUNT() FROM InputTable
UNION ALL
SELECT 'TableEven' AS TableName, COUNT() FROM TableEven
UNION ALL
SELECT 'TableOdd' AS TableName, COUNT() FROM TableOdd
UNION ALL
SELECT 'TableX100' AS TableName, COUNT() FROM TableX100
UNION ALL
SELECT 'TableX100' AS TableName, COUNT() FROM TableX100Negative
UNION ALL
SELECT 'TableAgg' AS TableName, COUNT() FROM TableAgg;
---
SELECT * FROM TableEven;

SELECT * FROM TableAgg;

SELECT Key,
  avgMerge(AvgValue) AS AvgValue
 FROM TableAgg
GROUP BY Key

/*INSERT NEW DATA*/
INSERT INTO InputTable (Key,Value)
VALUES
(1,8),
(2,20);

/*CHECKING TableAgg*/
SELECT * FROM TableAgg;

/*TableAgg Final Agg Query*/
SELECT Key,
  avgMerge(AvgValue) AS AvgValue
 FROM TableAgg
GROUP BY Key
