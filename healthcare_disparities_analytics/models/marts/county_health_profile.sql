{{
    config(
        materialized='table'
    )
}}

/*
    county_health_profile.sql
    Grain: one row per county_fips
    Joins all staging and intermediate models on county_fips.
    Base table is stg_chronic_disease (CDC PLACES 2025).
*/

WITH disease AS (
    SELECT * FROM {{ ref('stg_chronic_disease') }}
),

hosp AS (
    SELECT * FROM {{ ref('stg_hospitalizations') }}
),

pca AS (
    SELECT * FROM {{ ref('stg_primary_care_access') }}
),

demo AS (
    SELECT * FROM {{ ref('stg_demographics') }}
),

hpsa AS (
    SELECT * FROM {{ ref('int_hpsa_by_county') }}
),

muap AS (
    SELECT * FROM {{ ref('int_muap_by_county') }}
),

fqhc AS (
    SELECT * FROM {{ ref('int_fqhc_by_county') }}
),

rucc AS (
    SELECT * FROM {{ ref('stg_rural_urban') }}
),

national_baseline AS (
    SELECT
        ROUND(AVG(preventable_stays_rate), 1)    AS national_avg_preventable_stays,
        ROUND(STDDEV(preventable_stays_rate), 1) AS national_stddev_preventable_stays
    FROM {{ ref('stg_hospitalizations') }}
    WHERE preventable_stays_rate IS NOT NULL
),

final AS (
    SELECT
        -- Identifiers
        d.county_fips,
        d.county_name,
        d.statedesc                                             AS state_name,
        d.stateabbr                                             AS state_abbr,

        -- Demographics
        demo.total_population,
        demo.pct_65_older,
        demo.median_household_income,
        demo.children_in_poverty_pct,
        demo.income_inequality_ratio,
        demo.unemployment_pct,
        demo.uninsured_pct,
        demo.uninsured_adults_pct,
        demo.uninsured_children_pct,
        demo.pct_black,
        demo.pct_hispanic,
        demo.pct_asian,
        demo.pct_white,
        demo.pct_rural,

        -- Chronic disease burden
        d.diabetes_pct,
        d.hypertension_pct,
        d.heart_disease_pct,
        d.copd_pct,
        d.asthma_pct,
        d.obesity_pct,
        d.depression_pct,
        d.stroke_pct,
        d.kidney_disease_pct,
        d.high_cholesterol_pct,
        d.cancer_pct,
        d.arthritis_pct,
        d.fair_poor_health_pct,
        d.no_physical_activity_pct,
        d.food_insecurity_pct,
        d.no_transport_pct,
        d.disease_count,
        d.has_multimorbidity,
        d.disease_burden_level,

        -- Primary care access
        pca.pcp_per_100k,
        pca.other_pcp_per_100k,
        pca.pop_per_pcp,
        pca.pop_per_other_pcp,
        pca.pop_per_mental_health,
        pca.pop_per_dentist,

        -- HPSA designation
        COALESCE(hpsa.is_hpsa_designated, 0)                   AS is_hpsa_designated,
        hpsa.hpsa_score,
        hpsa.hpsa_shortage,
        ROUND(hpsa.hpsa_fte_total, 1)                          AS hpsa_fte_total,
        ROUND(hpsa.hpsa_designated_population, 0)              AS hpsa_designated_population,
        ROUND(hpsa.hpsa_underserved_population, 0)             AS hpsa_underserved_population,
        ROUND(hpsa.hpsa_avg_pct_poverty, 1)                    AS hpsa_avg_pct_poverty,
        COALESCE(hpsa.has_rural_designation, 0)                AS has_rural_designation,
        COALESCE(hpsa.hpsa_severity_tier, 'Not Designated')    AS hpsa_severity_tier,

        -- MUAP designation
        COALESCE(muap.is_medically_underserved, 0)             AS is_medically_underserved,
        ROUND(muap.imu_score_worst, 1)                         AS imu_score_worst,
        ROUND(muap.imu_score_avg, 1)                           AS imu_score_avg,
        COALESCE(muap.muap_severity_tier, 'Not Designated')    AS muap_severity_tier,
        ROUND(muap.muap_designated_population, 0)              AS muap_designated_population,

        -- Dual designated flag
        CASE
            WHEN COALESCE(hpsa.is_hpsa_designated, 0) = 1
             AND COALESCE(muap.is_medically_underserved, 0) = 1
            THEN 1 ELSE 0
        END                                                     AS is_dual_designated,

        -- FQHC safety net
        COALESCE(fqhc.has_fqhc, 0)                            AS has_fqhc,
        COALESCE(fqhc.fqhc_site_count, 0)                     AS fqhc_site_count,
        COALESCE(fqhc.fqhc_org_count, 0)                      AS fqhc_org_count,
        COALESCE(fqhc.fqhc_coverage_tier, 'No Coverage')      AS fqhc_coverage_tier,
        ROUND(fqhc.avg_operating_hours_per_week, 1)            AS fqhc_avg_hours_per_week,

        -- RUCC rural/urban classification
        rucc.rucc_code,
        rucc.rucc_description,
        rucc.urban_rural_category,

       -- Hospitalizations & mortality
        ROUND(hosp.preventable_stays_rate, 1)           AS preventable_stays_rate,
        ROUND(hosp.preventable_stays_aian, 1)           AS preventable_stays_aian,
        ROUND(hosp.preventable_stays_asian, 1)          AS preventable_stays_asian,
        ROUND(hosp.preventable_stays_black, 1)          AS preventable_stays_black,
        ROUND(hosp.preventable_stays_hispanic, 1)       AS preventable_stays_hispanic,
        ROUND(hosp.preventable_stays_white, 1)          AS preventable_stays_white,
        ROUND(hosp.life_expectancy, 1)                  AS life_expectancy,
        ROUND(hosp.premature_age_adj_mortality, 1)      AS premature_age_adj_mortality,
        ROUND(hosp.infant_mortality_rate, 1)            AS infant_mortality_rate,
        ROUND(hosp.child_mortality_rate, 1)             AS child_mortality_rate,

        -- Excess preventable hospitalizations
        ROUND(
            hosp.preventable_stays_rate - nb.national_avg_preventable_stays
        , 1)                                                    AS excess_preventable_stays,

        CASE
            WHEN hosp.preventable_stays_rate > nb.national_avg_preventable_stays
            THEN 1 ELSE 0
        END                                                     AS above_national_avg_hosp,

        -- Estimated excess stays as absolute count
        ROUND(
            GREATEST(
                COALESCE(hosp.preventable_stays_rate, 0) - nb.national_avg_preventable_stays,
                0
            ) * COALESCE(demo.total_population, 0) / 100000
        , 0)                                                    AS est_excess_stays_count,

        -- Racial disparity gaps
        ROUND(
            hosp.preventable_stays_black - hosp.preventable_stays_white
        , 1)                                                    AS black_white_hosp_gap,

        ROUND(
            hosp.preventable_stays_hispanic - hosp.preventable_stays_white
        , 1)                                                    AS hispanic_white_hosp_gap

    FROM disease d
    LEFT JOIN hosp                ON d.county_fips = hosp.county_fips
    LEFT JOIN pca                 ON d.county_fips = pca.county_fips
    LEFT JOIN demo                ON d.county_fips = demo.county_fips
    LEFT JOIN hpsa                ON d.county_fips = hpsa.county_fips
    LEFT JOIN muap                ON d.county_fips = muap.county_fips
    LEFT JOIN fqhc                ON d.county_fips = fqhc.county_fips
    LEFT JOIN rucc                ON d.county_fips = rucc.county_fips
    CROSS JOIN national_baseline nb
    WHERE d.county_fips IS NOT NULL
)

SELECT * FROM final