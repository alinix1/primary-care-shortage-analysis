-- Analysis: FQHC density vs preventable hospitalization rates controlling for shortage status
-- Description: Examines whether FQHC presence reduces preventable hospitalizations
--              both overall and within shortage/non-shortage county groups
-- Tables: county_health_profile, access_impact_analysis
-- Last updated: 2026-04-10

-- 1. Overall: FQHC presence vs avg excess preventable stays
SELECT
    ch.has_fqhc,
    COUNT(*)                                        AS county_count,
    ROUND(AVG(ch.excess_preventable_stays), 1)      AS avg_excess_stays,
    ROUND(AVG(ch.est_excess_stays_count), 0)        AS avg_est_excess_count
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE ch
GROUP BY ch.has_fqhc
ORDER BY ch.has_fqhc DESC;

-- 2. Controlling for shortage status: FQHC effectiveness within each shortage group
SELECT
    ai.fqhc_access_group,
    COUNT(*)                                        AS county_count,
    ROUND(AVG(ch.excess_preventable_stays), 1)      AS avg_excess_stays,
    ROUND(AVG(ch.est_excess_stays_count), 0)        AS avg_est_excess_count,
    ROUND(AVG(ch.hpsa_score), 1)                    AS avg_hpsa_score
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE ch
JOIN PCP_SHORTAGE_ANALYTICS.RAW_DATA.ACCESS_IMPACT_ANALYSIS ai
    ON ch.county_fips = ai.county_fips
GROUP BY ai.fqhc_access_group
ORDER BY avg_excess_stays DESC;