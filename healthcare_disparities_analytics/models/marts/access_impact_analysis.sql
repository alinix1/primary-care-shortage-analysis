{{
    config(
        materialized='table'
    )
}}

/*
    access_impact_analysis.sql
    Grain: one row per county_fips
    Builds on county_health_profile to analyze the relationship
    between access barriers and health outcomes.
*/

WITH base AS (
    SELECT * FROM {{ ref('county_health_profile') }}
),

final AS (
    SELECT
        -- Identifiers
        county_fips,
        county_name,
        state_abbr,
        state_name,
        total_population,

        -- Access flags
        is_hpsa_designated,
        hpsa_severity_tier,
        hpsa_score,
        is_medically_underserved,
        is_dual_designated,
        has_fqhc,
        fqhc_site_count,
        fqhc_coverage_tier,
        pcp_per_100k,
        pop_per_pcp,

        -- Outcomes
        preventable_stays_rate,
        excess_preventable_stays,
        est_excess_stays_count,
        above_national_avg_hosp,
        life_expectancy,
        premature_age_adj_mortality,
        black_white_hosp_gap,
        hispanic_white_hosp_gap,

        -- Disease burden
        disease_burden_level,
        disease_count,
        diabetes_pct,
        hypertension_pct,
        heart_disease_pct,
        obesity_pct,
        copd_pct,
        depression_pct,
        stroke_pct,
        cancer_pct,
        arthritis_pct,
        asthma_pct,
        high_cholesterol_pct,

        -- Demographics
        pct_rural,
        rucc_code,
        rucc_description,
        urban_rural_category,
        uninsured_pct,
        median_household_income,
        children_in_poverty_pct,

        -- ── Urban/Rural classification ────────────────────────────────
        CASE
            WHEN pct_rural >= 50 THEN 'Rural'
            WHEN pct_rural >= 25 THEN 'Mixed'
            ELSE 'Urban'
        END                                                     AS urban_rural_class,

        -- ── Shortage severity group ───────────────────────────────────
        CASE
            WHEN is_dual_designated = 1                         THEN 'Dual Designated'
            WHEN hpsa_severity_tier = 'Critical'                THEN 'Critical HPSA'
            WHEN hpsa_severity_tier IN ('High', 'Moderate')     THEN 'Moderate-High HPSA'
            WHEN is_hpsa_designated = 1                         THEN 'Low HPSA'
            ELSE 'Not Designated'
        END                                                     AS shortage_group,

        -- ── FQHC effectiveness flag ───────────────────────────────────
        -- Shortage county with FQHC = safety net present
        CASE
            WHEN is_hpsa_designated = 1 AND has_fqhc = 1 THEN 'Shortage + FQHC'
            WHEN is_hpsa_designated = 1 AND has_fqhc = 0 THEN 'Shortage, No FQHC'
            WHEN is_hpsa_designated = 0 AND has_fqhc = 1 THEN 'No Shortage + FQHC'
            ELSE 'No Shortage, No FQHC'
        END                                                     AS fqhc_access_group,

        -- ── High burden + low access flag ────────────────────────────
        CASE
            WHEN disease_burden_level = 'High'
             AND is_hpsa_designated = 1
            THEN 1 ELSE 0
        END                                                     AS high_burden_low_access,

       -- ── Racial disparity flag ─────────────────────────────────────
        CASE
            WHEN black_white_hosp_gap > 0 THEN 1 ELSE 0
        END                                                     AS has_racial_disparity,

        -- ── Vulnerability score (0–5) ─────────────────────────────────
        (
            CASE WHEN is_hpsa_designated = 1        THEN 1 ELSE 0 END +
            CASE WHEN is_medically_underserved = 1  THEN 1 ELSE 0 END +
            CASE WHEN has_fqhc = 0                  THEN 1 ELSE 0 END +
            CASE WHEN above_national_avg_hosp = 1   THEN 1 ELSE 0 END +
            CASE WHEN disease_burden_level = 'High' THEN 1 ELSE 0 END
        )                                                       AS vulnerability_score

    FROM base
)

SELECT * FROM final
ORDER BY vulnerability_score DESC, excess_preventable_stays DESC NULLS LAST