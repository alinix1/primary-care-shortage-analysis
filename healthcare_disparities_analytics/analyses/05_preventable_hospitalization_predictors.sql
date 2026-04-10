-- Underserved status
SELECT CORR(imu_score_worst, excess_preventable_stays) AS imu_vs_hosp
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE imu_score_worst IS NOT NULL;

-- Disease burden
SELECT disease_burden_level,
       ROUND(AVG(excess_preventable_stays), 1) AS avg_excess_stays,
       COUNT(*) AS county_count
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
GROUP BY disease_burden_level
ORDER BY avg_excess_stays DESC;

-- PCP ratio
SELECT CORR(pcp_per_100k, excess_preventable_stays) AS pcp_vs_hosp
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE pcp_per_100k IS NOT NULL;