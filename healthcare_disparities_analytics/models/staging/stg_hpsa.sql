WITH source AS (
    SELECT *
    FROM {{ source('raw_data', 'HRSA_HPSA_RAW') }}
    WHERE COMMON_STATE_COUNTY_FIPS_CODE IS NOT NULL
        AND HPSA_STATUS = 'Designated'
),

final AS (
    SELECT
        LPAD(CAST(COMMON_STATE_COUNTY_FIPS_CODE AS VARCHAR), 5, '0')   AS county_fips,
        HPSA_STATUS                                                    AS hpsa_status,
        HPSA_SCORE                                                     AS hpsa_score,
        HPSA_DEGREE_OF_SHORTAGE                                        AS hpsa_degree_of_shortage,
        CASE 
            WHEN HPSA_SHORTAGE < 0 THEN NULL
            ELSE HPSA_SHORTAGE 
        END                                                            AS hpsa_shortage,
        HPSA_FTE                                                       AS hpsa_fte,                                                      
        RURAL_STATUS                                                   AS rural_status,
        "% of Population Below 100% Poverty"                           AS pct_poverty,
        HPSA_ESTIMATED_UNDERSERVED_POPULATION                          AS hpsa_underserved_population,
        HPSA_DESIGNATION_POPULATION                                    AS hpsa_designation_population,
        TRUE                                                           AS is_hpsa_designated
        
    FROM source
)

SELECT * FROM final