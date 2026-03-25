-- joining all 3 tables and running analysis

-- master table: hospital info + HRRP penalty data
DROP TABLE IF EXISTS master_hospital;
CREATE TABLE master_hospital AS
SELECT 
    h.[Facility ID],
    h.[Facility Name],
    h.city,
    h.State,
    h.county,
    h.[Hospital Type],
    h.[Hospital Ownership],
    h.ownership_category,
    h.overall_rating,
    h.[Emergency Services],
    p.[Measure Name] as condition,
    p.excess_readmission_ratio,
    p.num_discharges,
    p.num_readmissions
FROM clean_hospital_info h
INNER JOIN clean_hrrp p ON h.[Facility ID] = p.[Facility ID];

-- which conditions have the highest excess readmissions?
SELECT condition,
       COUNT(*) as hospitals_with_data,
       ROUND(AVG(excess_readmission_ratio), 4) as avg_err,
       SUM(CASE WHEN excess_readmission_ratio > 1.0 THEN 1 ELSE 0 END) as num_above_expected,
       ROUND(100.0 * SUM(CASE WHEN excess_readmission_ratio > 1.0 THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_above
FROM master_hospital
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY condition
ORDER BY avg_err DESC;

-- for-profit vs non-profit vs government
SELECT ownership_category,
       COUNT(DISTINCT [Facility ID]) as num_hospitals,
       ROUND(AVG(excess_readmission_ratio), 4) as avg_err,
       SUM(CASE WHEN excess_readmission_ratio > 1.0 THEN 1 ELSE 0 END) as excess_count
FROM master_hospital
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY ownership_category
ORDER BY avg_err DESC;

-- star rating vs readmission performance
SELECT overall_rating,
       COUNT(DISTINCT [Facility ID]) as num_hospitals,
       ROUND(AVG(excess_readmission_ratio), 4) as avg_err,
       SUM(CASE WHEN excess_readmission_ratio > 1.0 THEN 1 ELSE 0 END) as excess_count
FROM master_hospital
WHERE overall_rating IS NOT NULL
  AND excess_readmission_ratio IS NOT NULL
GROUP BY overall_rating
ORDER BY overall_rating;

-- worst offenders: hospitals failing on 4+ conditions
SELECT [Facility ID], 
       [Facility Name], 
       State, 
       ownership_category,
       overall_rating,
       COUNT(*) as conditions_measured,
       SUM(CASE WHEN excess_readmission_ratio > 1.0 THEN 1 ELSE 0 END) as conditions_above_expected,
       ROUND(AVG(excess_readmission_ratio), 4) as avg_err
FROM master_hospital
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY [Facility ID], [Facility Name], State, ownership_category, overall_rating
HAVING conditions_above_expected >= 4
ORDER BY conditions_above_expected DESC, avg_err DESC;
