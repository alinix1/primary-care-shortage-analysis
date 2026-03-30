WITH source AS (
    SELECT *
    FROM {{ source('raw_data', 'HRSA_HPSA_RAW') }}
    WHERE COMMON_STATE_COUNTY_FIPS_CODE IS NOT NULL
),

final AS (
    SELECT
        LPAD(CAST(COMMON_STATE_COUNTY_FIPS_CODE AS VARCHAR), 5, '0')   AS county_fips,
        HPSA_STATUS                                                      AS hpsa_status,
        HPSA_SCORE                                                       AS hpsa_score,
        HPSA_DEGREE_OF_SHORTAGE                                         AS hpsa_degree_of_shortage,
        CASE 
            WHEN HPSA_SHORTAGE < 0 THEN NULL
            ELSE HPSA_SHORTAGE 
        END                                                   AS hpsa_shortage,
        RURAL_STATUS                                                     AS rural_status,
        "% of Population Below 100% Poverty"                           AS pct_poverty,
        CASE WHEN HPSA_STATUS = 'Designated' THEN TRUE ELSE FALSE END  AS is_hpsa_designated     
    FROM source
)

SELECT * FROM final