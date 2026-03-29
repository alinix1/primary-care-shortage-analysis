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
        CAST(PREVENTABLE_HOSPITAL_STAYS_RAW_VALUE AS FLOAT)        AS preventable_stays_rate,

        -- By race/ethnicity (equity analysis)
        CAST("Preventable Hospital Stays (AIAN)" AS FLOAT)                  AS preventable_stays_aian,
        CAST("Preventable Hospital Stays (Asian/Pacific Islander)" AS FLOAT) AS preventable_stays_asian,
        CAST("Preventable Hospital Stays (Black)" AS FLOAT)                 AS preventable_stays_black,
        CAST("Preventable Hospital Stays (Hispanic)" AS FLOAT)              AS preventable_stays_hispanic,
        CAST("Preventable Hospital Stays (White)" AS FLOAT)                 AS preventable_stays_white

    FROM source
)

SELECT * FROM final