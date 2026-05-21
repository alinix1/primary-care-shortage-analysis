WITH source AS (
    SELECT *
    FROM {{ source('raw_data', 'COUNTY_HEALTH_RANKINGS_RAW') }}
    WHERE "5-digit FIPS Code" NOT IN ('00000', '01000')  -- filter national and state level rows
    AND "5-digit FIPS Code" != 'fipscode'                -- filter metadata row
    AND "5-digit FIPS Code" IS NOT NULL
),

final AS (
    SELECT
        "5-digit FIPS Code"                                         AS county_fips,
        STATE_ABBREVIATION                                          AS state_abbr,
        NAME                                                        AS county_name,
        RELEASE_YEAR                                                AS year,

        -- Preventable hospital stays (per 100,000 Medicare enrollees)
        ROUND(CAST(PREVENTABLE_HOSPITAL_STAYS_RAW_VALUE AS FLOAT), 1)       AS preventable_stays_rate,
        CAST(PREVENTABLE_HOSPITAL_STAYS_CI_LOW AS FLOAT)                    AS preventable_stays_ci_low,
        CAST(PREVENTABLE_HOSPITAL_STAYS_CI_HIGH AS FLOAT)                   AS preventable_stays_ci_high,

         -- NULL indicates data suppressed for low-population counties
        CASE
            WHEN PREVENTABLE_HOSPITAL_STAYS_RAW_VALUE IS NULL THEN 1
            ELSE 0
        END                                                                   AS preventable_stays_suppressed,

        -- By race/ethnicity (equity analysis)
        CAST("Preventable Hospital Stays (AIAN)" AS FLOAT)                  AS preventable_stays_aian,
        CAST("Preventable Hospital Stays (Asian/Pacific Islander)" AS FLOAT) AS preventable_stays_asian,
        CAST("Preventable Hospital Stays (Black)" AS FLOAT)                 AS preventable_stays_black,
        CAST("Preventable Hospital Stays (Hispanic)" AS FLOAT)              AS preventable_stays_hispanic,
        CAST("Preventable Hospital Stays (White)" AS FLOAT)                 AS preventable_stays_white,

        -- Mortality outcomes
        ROUND(CAST(LIFE_EXPECTANCY_RAW_VALUE AS FLOAT), 1)                    AS life_expectancy,
        ROUND(CAST("Premature Age-Adjusted Mortality raw value" AS FLOAT), 1) AS premature_age_adj_mortality,
        ROUND(CAST(INFANT_MORTALITY_RAW_VALUE AS FLOAT), 1)                   AS infant_mortality_rate,
        ROUND(CAST(CHILD_MORTALITY_RAW_VALUE AS FLOAT), 1)                    AS child_mortality_rate


    FROM source
)

SELECT * FROM final