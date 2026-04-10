-- Analysis: Poverty and race as moderators of preventable hospitalization rates
-- Description: Examines whether poverty (children in poverty, uninsured rate) and 
--              racial disparity gaps correlate with excess preventable hospitalization 
--              rates at the county level
-- Table: county_health_profile
-- Last updated: 2026-04-10

SELECT
    CORR(uninsured_pct, excess_preventable_stays)           AS uninsured_vs_hosp,
    CORR(children_in_poverty_pct, excess_preventable_stays) AS poverty_vs_hosp,
    CORR(black_white_hosp_gap, excess_preventable_stays)    AS black_white_gap_vs_hosp,
    CORR(hispanic_white_hosp_gap, excess_preventable_stays) AS hispanic_white_gap_vs_hosp
FROM PCP_SHORTAGE_ANALYTICS.RAW_DATA.COUNTY_HEALTH_PROFILE
WHERE excess_preventable_stays IS NOT NULL;