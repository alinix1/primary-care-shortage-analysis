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

        -- Provider ratios (per 100,000 population)
        ROUND(CAST(PRIMARY_CARE_PHYSICIANS_RAW_VALUE AS FLOAT) * 100000, 1)             AS pcp_per_100k,
        ROUND(CAST(OTHER_PRIMARY_CARE_PROVIDERS_RAW_VALUE AS FLOAT) * 100000, 1)        AS other_pcp_per_100k,
        
        -- NULL indicates no PCP data available for this county
        CASE 
            WHEN PRIMARY_CARE_PHYSICIANS_RAW_VALUE IS NULL THEN 1 
            ELSE 0 
        END                                                       AS pcp_data_suppressed,
        
        -- Provider ratios (population per provider) - nulled when <= 0 (zero/no providers)
        ROUND(CASE 
            WHEN CAST("Ratio of population to primary care physicians." AS FLOAT) <= 0 THEN NULL
            ELSE CAST("Ratio of population to primary care physicians." AS FLOAT)
        END, 1)                                                                      AS pop_per_pcp,

        ROUND(CASE 
            WHEN CAST("Ratio of population to primary care providers other than physicians." AS FLOAT) <= 0 THEN NULL
            ELSE CAST("Ratio of population to primary care providers other than physicians." AS FLOAT)
        END, 1)                                                                      AS pop_per_other_pcp,

        ROUND(CASE 
            WHEN CAST("Ratio of population to mental health providers." AS FLOAT) <= 0 THEN NULL
            ELSE CAST("Ratio of population to mental health providers." AS FLOAT)
        END, 1)                                                                      AS pop_per_mental_health,

        ROUND(CASE 
            WHEN CAST("Ratio of population to dentists." AS FLOAT) <= 0 THEN NULL
            ELSE CAST("Ratio of population to dentists." AS FLOAT)
        END, 1)                                      AS pop_per_dentist

    FROM chr_source
)

SELECT * FROM final