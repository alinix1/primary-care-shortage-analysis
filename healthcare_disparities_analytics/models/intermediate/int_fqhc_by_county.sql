{{
    config(
        materialized='view'
    )
}}

WITH fqhc AS (
    SELECT * FROM {{ ref('stg_fqhc') }}
),

aggregated AS (
    SELECT
        county_fips,
        COUNT(*)                                                AS fqhc_site_count,
        COUNT(DISTINCT fqhc_name)                               AS fqhc_org_count,
        COUNT(DISTINCT city)                                    AS fqhc_cities_covered,
        COUNT(DISTINCT health_center_type)                      AS fqhc_type_count,
        ROUND(AVG(operating_hours_per_week), 1)                 AS avg_operating_hours_per_week,
        ROUND(MAX(operating_hours_per_week), 1)                 AS max_operating_hours_per_week
    FROM fqhc
    GROUP BY county_fips
),

final AS (
    SELECT
        county_fips,
        fqhc_site_count,
        fqhc_org_count,
        fqhc_cities_covered,
        fqhc_type_count,
        avg_operating_hours_per_week,
        max_operating_hours_per_week,
        1                                                       AS has_fqhc,
        CASE
            WHEN fqhc_site_count = 1    THEN 'Minimal'
            WHEN fqhc_site_count <= 3   THEN 'Moderate'
            ELSE 'Strong'
        END                                                     AS fqhc_coverage_tier
    FROM aggregated
)

SELECT * FROM final