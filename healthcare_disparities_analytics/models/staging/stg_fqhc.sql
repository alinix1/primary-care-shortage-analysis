WITH source AS (
    SELECT *
    FROM {{ source('raw_data', 'HRSA_FQHC_RAW') }}
    WHERE STATE_AND_COUNTY_FEDERAL_INFORMATION_PROCESSING_STANDARD_CODE IS NOT NULL
    AND SITE_STATUS_DESCRIPTION = 'Active'
),

final AS (
    SELECT
        LPAD(CAST(STATE_AND_COUNTY_FEDERAL_INFORMATION_PROCESSING_STANDARD_CODE AS VARCHAR), 5, '0') AS county_fips,
        SITE_NAME                                                        AS fqhc_name,
        SITE_CITY                                                        AS city,
        SITE_STATE_ABBREVIATION                                         AS state_abbr,
        COMPLETE_COUNTY_NAME                                            AS county_name,
        SITE_STATUS_DESCRIPTION                                         AS site_status, 
        OPERATING_HOURS_PER_WEEK                                        AS operating_hours_per_week,
        HEALTH_CENTER_TYPE_DESCRIPTION                                  AS health_center_type,
        GEOCODING_ARTIFACT_ADDRESS_PRIMARY_X_COORDINATE                 AS longitude,
        GEOCODING_ARTIFACT_ADDRESS_PRIMARY_Y_COORDINATE                 AS latitude

    FROM source
)

SELECT * FROM final