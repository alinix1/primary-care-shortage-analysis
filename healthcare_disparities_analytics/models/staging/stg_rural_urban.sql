WITH source AS (
    SELECT *
    FROM {{ source('raw_data', 'USDA_RUCC_RAW') }}
    WHERE FIPS != 'FIPS'  -- filter metadata row
    AND FIPS IS NOT NULL
),

pivoted AS (
    SELECT
        FIPS                                                            AS county_fips,
        STATE                                                           AS state_abbr,
        COUNTY_NAME                                                     AS county_name,
        MAX(CASE WHEN ATTRIBUTE = 'RUCC_2023' THEN VALUE END)          AS rucc_code,
        MAX(CASE WHEN ATTRIBUTE = 'Population_2020' THEN VALUE END)    AS population_2020,
        MAX(CASE WHEN ATTRIBUTE = 'Description' THEN VALUE END)        AS rucc_description
    FROM source
    GROUP BY 1, 2, 3
),

final AS (
    SELECT
        county_fips,
        state_abbr,
        county_name,
        CAST(rucc_code AS INTEGER)                                      AS rucc_code,
        CAST(population_2020 AS INTEGER)                               AS population_2020,
        rucc_description,

        -- Rural/urban classification based on RUCC code
        CASE
            WHEN CAST(rucc_code AS INTEGER) <= 3 THEN 'Metro'
            WHEN CAST(rucc_code AS INTEGER) <= 5 THEN 'Micropolitan'
            ELSE 'Rural'
        END AS urban_rural_category

    FROM pivoted
)

SELECT * FROM final