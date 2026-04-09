-- Analysis: Do HPSA counties have higher chronic disease prevalence?
-- Description: Compares average chronic disease rates between HPSA-designated 
--              and non-designated counties across 6 conditions
-- Table: county_health_profile
-- Last updated: 2026-04-09

SELECT 
    is_hpsa_designated,
    ROUND(AVG(diabetes_pct), 2)       AS avg_diabetes_pct,
    ROUND(AVG(heart_disease_pct), 2)  AS avg_heart_disease_pct,
    ROUND(AVG(obesity_pct), 2)        AS avg_obesity_pct,
    ROUND(AVG(hypertension_pct), 2)   AS avg_hypertension_pct,
    ROUND(AVG(copd_pct), 2)           AS avg_copd_pct,
    ROUND(AVG(depression_pct), 2)     AS avg_depression_pct,
    COUNT(*)                          AS county_count
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
GROUP BY is_hpsa_designated
ORDER BY is_hpsa_designated DESC;