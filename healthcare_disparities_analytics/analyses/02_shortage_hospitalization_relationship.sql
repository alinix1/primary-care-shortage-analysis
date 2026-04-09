-- Analysis: Relationship between primary care shortage severity and preventable hospitalization rates
-- Description: Examines whether higher HPSA severity correlates with higher preventable 
--              hospitalization rates across counties. Uses three approaches:
--              1. Pearson correlation coefficient (hpsa_score vs excess_preventable_stays)
--              2. Correlation matrix (hpsa_score vs chronic disease measures)
--              3. Quartile analysis (shortage severity trend vs hospitalization rates)
-- Tables: county_health_profile
-- Last updated: 2026-04-09
-- Key finding: HPSA score weakly predicts hospitalization rates (r=0.18) but moderately 
--              predicts chronic disease prevalence (diabetes r=0.39, hypertension r=0.36),
--              suggesting shortage severity impacts outcomes through chronic disease burden
--              rather than directly driving hospitalizations.

-- 1. Pearson Correlation: HPSA score vs excess preventable stays
SELECT CORR(hpsa_score, excess_preventable_stays) AS correlation
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE hpsa_score IS NOT NULL 
  AND excess_preventable_stays IS NOT NULL;

-- 2. Correlation matrix: HPSA score vs chronic disease measures
SELECT 
    CORR(hpsa_score, excess_preventable_stays)  AS hpsa_vs_hosp,
    CORR(hpsa_score, diabetes_pct)              AS hpsa_vs_diabetes,
    CORR(hpsa_score, obesity_pct)               AS hpsa_vs_obesity,
    CORR(hpsa_score, hypertension_pct)          AS hpsa_vs_hypertension
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE hpsa_score IS NOT NULL;

-- 3. Quartile analysis: shortage severity trend vs hospitalization rates
SELECT
    hpsa_quartile,
    ROUND(AVG(hpsa_score), 1)               AS avg_hpsa_score,
    ROUND(AVG(excess_preventable_stays), 1) AS avg_excess_stays,
    COUNT(*)                                AS county_count
FROM (
    SELECT
        hpsa_score,
        excess_preventable_stays,
        NTILE(4) OVER (ORDER BY hpsa_score) AS hpsa_quartile
    FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
    WHERE hpsa_score IS NOT NULL
) subq
GROUP BY hpsa_quartile
ORDER BY hpsa_quartile;