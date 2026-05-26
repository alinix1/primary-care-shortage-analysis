-- Analysis: Poverty and race as moderators of preventable hospitalization rates
-- Description: Examines whether poverty (children in poverty, uninsured rate) and 
--              racial disparity gaps correlate with excess preventable hospitalization 
--              rates at the county level. Racial gap correlations are computed on a
--              subset of counties with sufficient population data for disparity calculation
--              (736 counties for hispanic-white gap, 1,217 for black-white gap).
-- Table: county_health_profile
-- Last updated: 2026-05-07

-- 1. Poverty and insurance: correlations with excess preventable stays
SELECT
    CORR(uninsured_pct, excess_preventable_stays)           AS uninsured_vs_hosp,
    CORR(children_in_poverty_pct, excess_preventable_stays) AS poverty_vs_hosp
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE excess_preventable_stays IS NOT NULL
    AND uninsured_pct IS NOT NULL
    AND children_in_poverty_pct IS NOT NULL;

-- 2. Racial disparity gaps: correlations with excess preventable stays
--    Note: limited to counties with sufficient population data for disparity calculation
SELECT
    CORR(black_white_hosp_gap, excess_preventable_stays)    AS black_white_gap_vs_hosp,
    CORR(hispanic_white_hosp_gap, excess_preventable_stays) AS hispanic_white_gap_vs_hosp
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE excess_preventable_stays IS NOT NULL
    AND black_white_hosp_gap IS NOT NULL
    AND hispanic_white_hosp_gap IS NOT NULL;