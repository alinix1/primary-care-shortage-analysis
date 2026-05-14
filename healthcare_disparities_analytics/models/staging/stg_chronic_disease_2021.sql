WITH source AS (
    SELECT * 
    FROM {{ source('raw_data', 'CDC_PLACES_2021_RAW') }}
    WHERE LOCATIONNAME IS NOT NULL  -- filter 60 null locations
    AND DATA_VALUE_TYPE = 'Age-adjusted prevalence' -- filters by 'Age-adjusted prevalence' and removes crude prevalence duplicates
),

pivoted AS (
    SELECT
        YEAR,
        STATEABBR,
        STATEDESC,
        LOCATIONNAME AS county_name,
        LPAD(CAST(LOCATIONID AS VARCHAR), 5, '0') AS county_fips,
        TOTALPOPULATION AS total_population,

        -- Chronic disease prevalence rates
        MAX(CASE WHEN MEASURE = 'Arthritis among adults aged >=18' THEN DATA_VALUE END) AS arthritis_pct,
        MAX(CASE WHEN MEASURE = 'Cancer (non-skin) or melanoma among adults aged >=18 years' THEN DATA_VALUE END) AS cancer_pct,
        MAX(CASE WHEN MEASURE = 'Chronic obstructive pulmonary disease among adults aged >=18 years' THEN DATA_VALUE END) AS copd_pct,
        MAX(CASE WHEN MEASURE = 'Coronary heart disease among adults aged >=18 years' THEN DATA_VALUE END) AS heart_disease_pct,
        MAX(CASE WHEN MEASURE = 'Current asthma among adults aged >=18 years' THEN DATA_VALUE END) AS asthma_pct,
        MAX(CASE WHEN MEASURE = 'Depression among adults aged >=18 years' THEN DATA_VALUE END) AS depression_pct,
        MAX(CASE WHEN MEASURE = 'Diagnosed diabetes among adults aged >=18 years' THEN DATA_VALUE END) AS diabetes_pct,
        MAX(CASE WHEN MEASURE = 'High blood pressure among adults aged >=18 years' THEN DATA_VALUE END) AS hypertension_pct,
        MAX(CASE WHEN MEASURE = 'High cholesterol among adults aged >=18 who have been screened in the past 5 years' THEN DATA_VALUE END) AS high_cholesterol_pct,
        MAX(CASE WHEN MEASURE = 'Obesity among adults aged >=18 years' THEN DATA_VALUE END) AS obesity_pct,
        MAX(CASE WHEN MEASURE = 'Stroke among adults aged >=18 years' THEN DATA_VALUE END) AS stroke_pct,
        MAX(CASE WHEN MEASURE = 'All teeth lost among adults aged >=65 years' THEN DATA_VALUE END) AS tooth_loss_pct,

          -- Access & lifestyle indicators (matched to 2025 where possible)
        MAX(CASE WHEN MEASURE = 'Visits to doctor for routine checkup within the past year among adults aged >=18 years' THEN DATA_VALUE END) AS routine_checkup_pct,
        MAX(CASE WHEN MEASURE = 'No leisure-time physical activity among adults aged >=18 years' THEN DATA_VALUE END) AS no_physical_activity_pct,
        MAX(CASE WHEN MEASURE = 'Fair or poor self-rated health status among adults aged >=18 years' THEN DATA_VALUE END) AS fair_poor_health_pct,
        NULL AS food_insecurity_pct,    -- not available in 2021 CDC PLACES release
        NULL AS no_transport_pct        -- not available in 2021 CDC PLACES release

    FROM source
    GROUP BY 1, 2, 3, 4, 5, 6
),

final AS (
    SELECT
        *,

        -- Count how many diseases have data (not null)
        (
            CASE WHEN arthritis_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN cancer_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN copd_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN heart_disease_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN asthma_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN depression_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN diabetes_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN hypertension_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN high_cholesterol_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN obesity_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN stroke_pct IS NOT NULL THEN 1 ELSE 0 END
        ) AS disease_count,

        -- Multi-morbidity flag (2+ chronic diseases reported)
        CASE 
            WHEN (
                CASE WHEN arthritis_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN cancer_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN copd_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN heart_disease_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN asthma_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN depression_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN diabetes_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN hypertension_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN high_cholesterol_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN obesity_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN stroke_pct IS NOT NULL THEN 1 ELSE 0 END +
                CASE WHEN tooth_loss_pct IS NOT NULL THEN 1 ELSE 0 END

            ) >= 2 THEN TRUE 
            ELSE FALSE 
        END AS has_multimorbidity,

        -- Disease burden category
        CASE
            WHEN diabetes_pct IS NULL AND heart_disease_pct IS NULL AND stroke_pct IS NULL AND obesity_pct IS NULL AND hypertension_pct IS NULL AND copd_pct IS NULL THEN 'Insufficient Data'
            WHEN diabetes_pct > 12 OR heart_disease_pct > 7 OR stroke_pct > 4 OR obesity_pct > 38 OR hypertension_pct > 36 OR copd_pct > 9 THEN 'High'
            WHEN diabetes_pct > 10 OR heart_disease_pct > 6 OR stroke_pct > 3 OR obesity_pct > 36 OR hypertension_pct > 32 OR copd_pct > 7 THEN 'Moderate'
            ELSE 'Low'
        END AS disease_burden_level

    FROM pivoted
)

SELECT * FROM final