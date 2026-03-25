-- cleaning CMS data
-- converting Not Available to NULL, casting types, filtering measures

DROP TABLE IF EXISTS clean_hrrp;
CREATE TABLE clean_hrrp AS
SELECT 
    [Facility ID], [Facility Name], State, [Measure Name],
    CASE 
        WHEN [Excess Readmission Ratio] IS NULL THEN NULL
        WHEN [Excess Readmission Ratio] = '' THEN NULL
        ELSE CAST([Excess Readmission Ratio] AS REAL)
    END as excess_readmission_ratio,
    CASE
        WHEN [Number of Discharges] IS NULL THEN NULL
        WHEN [Number of Discharges] = '' THEN NULL
        ELSE CAST([Number of Discharges] AS INTEGER)
    END as num_discharges,
    CASE
        WHEN [Number of Readmissions] IS NULL THEN NULL
        ELSE CAST([Number of Readmissions] AS INTEGER)
    END as num_readmissions
FROM raw_hrrp;

DROP TABLE IF EXISTS clean_hospital_info;
CREATE TABLE clean_hospital_info AS
SELECT 
    [Facility ID], [Facility Name], [City/Town] as city, State,
    [ZIP Code], [County/Parish] as county, [Hospital Type], [Hospital Ownership],
    [Emergency Services],
    CASE 
        WHEN [Hospital overall rating] = 'Not Available' THEN NULL
        ELSE CAST([Hospital overall rating] AS INTEGER)
    END as overall_rating,
    CASE
        WHEN [Hospital Ownership] LIKE '%non-profit%' THEN 'Non-Profit'
        WHEN [Hospital Ownership] LIKE '%Proprietary%' THEN 'For-Profit'
        WHEN [Hospital Ownership] LIKE '%Government%' THEN 'Government'
        WHEN [Hospital Ownership] LIKE '%Tribal%' THEN 'Tribal'
        ELSE 'Other'
    END as ownership_category
FROM raw_hospital_info;

DROP TABLE IF EXISTS clean_readmissions;
CREATE TABLE clean_readmissions AS
SELECT 
    [Facility ID], [Facility Name], State, [Measure ID], [Measure Name],
    CASE WHEN Score = 'Not Available' THEN NULL ELSE CAST(Score AS REAL) END as readmission_rate,
    CASE WHEN Denominator = 'Not Available' THEN NULL ELSE CAST(Denominator AS INTEGER) END as num_discharges,
    [Compared to National]
FROM raw_unplanned_visits
WHERE [Measure ID] LIKE 'READM_30%';
