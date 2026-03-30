WITH source AS (
    SELECT *
    FROM {{ source('raw_data', 'HRSA_MUAP_RAW') }}
    WHERE COMMON_STATE_COUNTY_FIPS_CODE IS NOT NULL
),

final AS (
    SELECT
        LPAD(CAST(COMMON_STATE_COUNTY_FIPS_CODE AS VARCHAR), 5, '0')   AS county_fips,
        CAST(IMU_SCORE AS FLOAT)                                        AS imu_score,
        CAST(PROVIDERS_PER_1000_POPULATION AS FLOAT)                   AS providers_per_1000,
        CAST(PERCENTAGE_OF_POPULATION_AGE_65_AND_OVER AS FLOAT)        AS pct_age_65_over,
        CAST("Percent of Population with Incomes at or Below 100 Percent of the U.S. Federal Poverty Level" AS FLOAT) AS pct_poverty,
        CAST("Designation Population in a Medically Underserved Area/Population (MUA/P)" AS FLOAT) AS designated_population,
        POPULATION_TYPE                                                  AS population_type,

        -- Underserved flag
        CASE WHEN IMU_SCORE <= 62 THEN TRUE ELSE FALSE END             AS is_medically_underserved

    FROM source
)

SELECT * FROM final