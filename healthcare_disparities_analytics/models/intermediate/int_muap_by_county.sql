{{
    config(
        materialized='view'
    )
}}

WITH muap AS (
    SELECT * FROM {{ ref('stg_muap') }}
),

aggregated AS (
    SELECT
        county_fips,
        1                                                       AS is_medically_underserved,
        COUNT(*)                                                AS muap_designation_count,
        MIN(imu_score)                                          AS imu_score_worst,
        ROUND(AVG(imu_score), 1)                                AS imu_score_avg,
        ROUND(MIN(providers_per_1000) * 1000, 1)                AS providers_per_1000_worst,
        MAX(pct_poverty)                                        AS pct_poverty_worst,
        MAX(pct_age_65_over)                                    AS pct_age_65_over,
        ROUND(MAX(infant_mortality_rate), 1)                    AS infant_mortality_rate,
        SUM(designated_population)                              AS muap_designated_population
    FROM muap
    GROUP BY county_fips
),

final AS (
    SELECT
        county_fips,
        is_medically_underserved,
        muap_designation_count,
        imu_score_worst,
        imu_score_avg,
        providers_per_1000_worst,
        pct_poverty_worst,
        pct_age_65_over,
        infant_mortality_rate,
        muap_designated_population,
        CASE
            WHEN imu_score_worst < 40 THEN 'Severely Underserved'
            WHEN imu_score_worst < 55 THEN 'Highly Underserved'
            WHEN imu_score_worst < 62 THEN 'Underserved'
            ELSE 'Not Designated'
        END                                                     AS muap_severity_tier
    FROM aggregated
)

SELECT * FROM final