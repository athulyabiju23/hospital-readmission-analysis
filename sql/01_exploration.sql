-- data exploration queries
-- checking whats in each table and finding messy values

SELECT [Measure ID], COUNT(*) as cnt 
FROM raw_unplanned_visits 
GROUP BY [Measure ID];

SELECT [Excess Readmission Ratio], COUNT(*) as cnt
FROM raw_hrrp
WHERE [Excess Readmission Ratio] IS NULL 
GROUP BY [Excess Readmission Ratio];

SELECT Score, COUNT(*) as cnt
FROM raw_unplanned_visits
WHERE Score = 'Not Available' OR Score IS NULL
GROUP BY Score;

SELECT 'hospital_info' as tbl, COUNT(DISTINCT [Facility ID]) as cnt FROM raw_hospital_info
UNION ALL
SELECT 'hrrp', COUNT(DISTINCT [Facility ID]) FROM raw_hrrp
UNION ALL
SELECT 'unplanned_visits', COUNT(DISTINCT [Facility ID]) FROM raw_unplanned_visits;

SELECT [Measure ID],
       COUNT(*) as total,
       SUM(CASE WHEN Score != 'Not Available' AND Score IS NOT NULL THEN 1 ELSE 0 END) as has_data,
       SUM(CASE WHEN Score = 'Not Available' OR Score IS NULL THEN 1 ELSE 0 END) as missing
FROM raw_unplanned_visits
WHERE [Measure ID] LIKE 'READM_30%'
GROUP BY [Measure ID];
