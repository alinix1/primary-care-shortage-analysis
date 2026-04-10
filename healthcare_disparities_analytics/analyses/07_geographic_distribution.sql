-- Analysis: Geographic distribution of counties with primary care shortage and high chronic disease burden
-- Description: Identifies which states have the highest concentration of counties
--              with coinciding primary care shortages and high chronic disease burden
-- Table: county_health_profile
-- Last updated: 2026-04-10

SELECT
    state_abbr,
    COUNT(*)                                            AS total_counties,
    SUM(CASE WHEN is_hpsa_designated = 1 
        AND disease_burden_level = 'High' 
        THEN 1 ELSE 0 END)                             AS shortage_high_burden_counties,
    ROUND(SUM(CASE WHEN is_hpsa_designated = 1 
        AND disease_burden_level = 'High' 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1)     AS pct_counties_affected,
    ROUND(AVG(excess_preventable_stays), 1)            AS avg_excess_stays
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
GROUP BY state_abbr
HAVING shortage_high_burden_counties > 0
ORDER BY shortage_high_burden_counties DESC
LIMIT 15;