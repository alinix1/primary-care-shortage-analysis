{{
    config(
        materialized='view'
    )
}}

WITH hpsa AS (
    SELECT * FROM {{ ref('stg_hpsa') }}
),

aggregated AS (
    SELECT
        county_fips,
        1                                                                AS is_hpsa_designated,
        COUNT(*)                                                         AS hpsa_designation_count,
        MAX(hpsa_score)                                                  AS hpsa_score,
        ROUND(MAX(hpsa_shortage), 1)                                     AS hpsa_shortage,
        ROUND(SUM(hpsa_fte), 2)                                          AS hpsa_fte_total,
        ROUND(SUM(hpsa_designation_population), 0)                       AS hpsa_designated_population,
        SUM(hpsa_underserved_population)                                 AS hpsa_underserved_population,
        ROUND(AVG(pct_poverty), 1)                                       AS hpsa_avg_pct_poverty,
        MAX(CASE WHEN rural_status = 'Rural' THEN 1 ELSE 0 END)         AS has_rural_designation
    FROM hpsa
    GROUP BY county_fips
),

final AS (
    SELECT
        county_fips,
        is_hpsa_designated,
        hpsa_designation_count,
        hpsa_score,
        hpsa_shortage,
        hpsa_fte_total,
        hpsa_designated_population,
        hpsa_underserved_population,
        hpsa_avg_pct_poverty,
        has_rural_designation,
        CASE
            WHEN hpsa_score >= 20 THEN 'Critical'
            WHEN hpsa_score >= 14 THEN 'High'
            WHEN hpsa_score >= 7  THEN 'Moderate'
            WHEN hpsa_score >  0  THEN 'Low'
            ELSE 'Not Designated'
        END AS hpsa_severity_tier
    FROM aggregated
)

SELECT * FROM final