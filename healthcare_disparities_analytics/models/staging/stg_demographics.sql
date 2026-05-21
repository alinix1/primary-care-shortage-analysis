WITH source AS (
    SELECT *
    FROM {{ source('raw_data', 'COUNTY_HEALTH_RANKINGS_RAW') }}
    WHERE "5-digit FIPS Code" NOT IN ('00000', '01000')
    AND "5-digit FIPS Code" != 'fipscode'
    AND "5-digit FIPS Code" IS NOT NULL
),

final AS (
    SELECT
        "5-digit FIPS Code"                                     AS county_fips,
        STATE_ABBREVIATION                                      AS state_abbr,
        NAME                                                    AS county_name,
        RELEASE_YEAR                                            AS year,

        -- Population
        CAST(POPULATION_RAW_VALUE AS FLOAT)                    AS total_population,

        -- Age  
        ROUND(CAST("% 65 and Older raw value" AS FLOAT) * 100, 1)            AS pct_65_older,

        -- Income & poverty
        CAST(MEDIAN_HOUSEHOLD_INCOME_RAW_VALUE AS FLOAT)                    AS median_household_income,
        ROUND(CAST(CHILDREN_IN_POVERTY_RAW_VALUE AS FLOAT) * 100, 1)        AS children_in_poverty_pct,
        ROUND(CAST(INCOME_INEQUALITY_RAW_VALUE AS FLOAT), 1)                AS income_inequality_ratio,
        ROUND(CAST(UNEMPLOYMENT_RAW_VALUE AS FLOAT) * 100, 1)               AS unemployment_pct,

        -- Insurance coverage
        ROUND(CAST(UNINSURED_RAW_VALUE AS FLOAT) * 100, 1)                    AS uninsured_pct,
        ROUND(CAST(UNINSURED_ADULTS_RAW_VALUE AS FLOAT) * 100, 1)             AS uninsured_adults_pct,
        ROUND(CAST(UNINSURED_CHILDREN_RAW_VALUE AS FLOAT) * 100, 1)           AS uninsured_children_pct,

        -- NULL indicates no uninsured data available for this county
         CASE
            WHEN UNINSURED_RAW_VALUE IS NULL THEN 1
            ELSE 0
        END                                                                    AS uninsured_suppressed,


        -- Race/ethnicity composition
        ROUND(CAST("% Non-Hispanic Black raw value" AS FLOAT) * 100, 1)  AS pct_black,
        ROUND(CAST("% Hispanic raw value" AS FLOAT) * 100, 1)            AS pct_hispanic,
        ROUND(CAST("% Asian raw value" AS FLOAT) * 100, 1)               AS pct_asian,
        ROUND(CAST("% Non-Hispanic White raw value" AS FLOAT) * 100, 1)  AS pct_white,

        -- Rural/urban
        ROUND(CAST("% Rural raw value" AS FLOAT) * 100, 1)                   AS pct_rural

    FROM source
)

SELECT * FROM final