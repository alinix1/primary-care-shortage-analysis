WITH chr_source AS (
    SELECT *
    FROM {{ source('raw_data', 'COUNTY_HEALTH_RANKINGS_RAW') }}
    WHERE "5-digit FIPS Code" NOT IN ('00000', '01000')
    AND "5-digit FIPS Code" != 'fipscode'
    AND "5-digit FIPS Code" IS NOT NULL
),

final AS (
    SELECT
        "5-digit FIPS Code"                                                          AS county_fips,
        STATE_ABBREVIATION                                                           AS state_abbr,
        NAME                                                                         AS county_name,
        RELEASE_YEAR                                                                 AS year,

        -- Provider ratios (population per provider)
        ROUND(CAST(PRIMARY_CARE_PHYSICIANS_RAW_VALUE AS FLOAT) * 100000, 1)                           AS pcp_per_100k,
        ROUND(CAST(OTHER_PRIMARY_CARE_PROVIDERS_RAW_VALUE AS FLOAT) * 100000, 1)                      AS other_pcp_per_100k,
 
        ROUND(CAST("Ratio of population to primary care physicians." AS FLOAT), 1)                         AS pop_per_pcp,
        ROUND(CAST("Ratio of population to primary care providers other than physicians." AS FLOAT), 1)    AS pop_per_other_pcp,
        ROUND(CAST("Ratio of population to mental health providers." AS FLOAT), 1)                         AS pop_per_mental_health,
        ROUND(CAST("Ratio of population to dentists." AS FLOAT), 1)                                        AS pop_per_dentist

    FROM chr_source
)

SELECT * FROM final