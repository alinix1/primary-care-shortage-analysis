WITH county_data AS (
    SELECT
        ch.state_abbr,
        ch.state_name,
        ch.county_fips,
        ch.is_hpsa_designated,
        ch.is_medically_underserved,
        ch.is_dual_designated,
        ch.excess_preventable_stays,
        ch.pcp_per_100k,
        ch.uninsured_pct,
        ch.children_in_poverty_pct,
        ch.disease_burden_level,
        pr.priority_score
    FROM {{ ref('county_health_profile') }} ch
    JOIN {{ ref('priority_counties_ranking') }} pr
        ON ch.county_fips = pr.county_fips
)

SELECT
    state_abbr,
    state_name,
    COUNT(*)                                                            AS total_counties,
    SUM(is_hpsa_designated)                                             AS hpsa_counties,
    SUM(is_medically_underserved)                                       AS muap_counties,
    SUM(is_dual_designated)                                             AS dual_designated_counties,
    ROUND(AVG(excess_preventable_stays), 1)                             AS avg_excess_stays,
    ROUND(AVG(priority_score), 1)                                       AS avg_priority_score,
    ROUND(AVG(pcp_per_100k), 1)                                         AS avg_pcp_per_100k,
    ROUND(AVG(uninsured_pct), 1)                                        AS avg_uninsured_pct,
    ROUND(AVG(children_in_poverty_pct), 1)                              AS avg_poverty_pct,
    SUM(CASE WHEN disease_burden_level = 'High' THEN 1 ELSE 0 END)      AS high_burden_counties
FROM county_data
GROUP BY state_abbr, state_name
ORDER BY avg_excess_stays DESC