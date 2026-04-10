-- Analysis: Counties with triple burden - shortage + high disease + preventable hospitalizations
-- Description: Identifies counties with primary care shortage, high chronic disease burden,
--              and above average preventable hospitalization rates
-- Tables: county_health_profile, access_impact_analysis
-- Last updated: 2026-04-09

SELECT
    ch.county_fips,
    ch.county_name,
    ch.state_abbr,
    ch.hpsa_severity_tier,
    ch.disease_burden_level,
    ch.excess_preventable_stays,
    ch.est_excess_stays_count,
    ai.vulnerability_score,
    ai.shortage_group,
    ch.urban_rural_category
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE ch
JOIN PCP_SHORTAGE_ANALYTICS.RAW_DATA.ACCESS_IMPACT_ANALYSIS ai 
    ON ch.county_fips = ai.county_fips
WHERE ch.is_hpsa_designated = 1
    AND ch.disease_burden_level = 'High'
    AND ch.above_national_avg_hosp = 1
ORDER BY ai.vulnerability_score DESC, ch.excess_preventable_stays DESC
LIMIT 25;