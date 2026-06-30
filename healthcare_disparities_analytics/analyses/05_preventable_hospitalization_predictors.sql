-- Analysis: Alternative predictors of excess preventable hospitalizations
-- Description: Examines three additional measures of primary care access and disease burden
--              as predictors of excess preventable stays:
--              1. IMU score (underserved status) vs excess preventable stays
--              2. Disease burden level (High/Moderate/Low) vs average excess stays
--              3. PCP rate per 100k (PCP ratio) vs excess preventable stays
-- Tables: county_health_profile
-- Last updated: 2026-06-30
-- Key findings:
--              IMU score shows negligible correlation with hospitalizations (r=0.03),
--              suggesting IMU designation does not predict preventable stays the way
--              HPSA score does (r=0.18). Disease burden level is the strongest predictor
--              — high burden counties average 481.9 excess stays vs -368.5 for low burden
--              counties, a difference of 850 stays. PCP rate shows a weak negative
--              correlation (r=-0.16), confirming that more PCPs per 100k is associated
--              with fewer excess preventable stays, as expected.

-- Underserved status
SELECT CORR(imu_score_worst, excess_preventable_stays) AS imu_vs_hosp
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE imu_score_worst IS NOT NULL
    AND excess_preventable_stays IS NOT NULL;

-- Disease burden level
SELECT disease_burden_level,
       ROUND(AVG(excess_preventable_stays), 1) AS avg_excess_stays,
       COUNT(*) AS county_count
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE disease_burden_level IS NOT NULL
    AND disease_burden_level != 'Insufficient Data'
GROUP BY disease_burden_level
ORDER BY avg_excess_stays DESC;

-- Correlation: PCP supply vs excess preventable hospitalizations
SELECT CORR(pcp_per_100k, excess_preventable_stays) AS pcp_vs_hosp
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE pcp_per_100k IS NOT NULL
    AND excess_preventable_stays IS NOT NULL;