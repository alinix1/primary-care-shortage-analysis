{{
    config(
        materialized='table'
    )
}}

/*
    priority_counties_ranking.sql
    Grain: one row per county_fips
    Builds on access_impact_analysis to rank counties by intervention opportunity.
    Priority score (0-100) is a weighted composite of 5 components.
    Higher score = greater need for intervention.
*/

WITH base AS (
    SELECT * FROM {{ ref('access_impact_analysis') }}
),

-- Calculate percentile ranks for each component
ranked AS (
    SELECT
        *,

        -- 1. Shortage burden (higher HPSA score = higher priority)
        ROUND(PERCENT_RANK() OVER (
            ORDER BY COALESCE(hpsa_score, 0) ASC
        ) * 100, 1)                                             AS shortage_score,

        -- 2. Disease burden (composite of all disease severity rates)
        ROUND(PERCENT_RANK() OVER (
            ORDER BY (
                COALESCE(diabetes_pct, 0) +
                COALESCE(hypertension_pct, 0) +
                COALESCE(heart_disease_pct, 0) +
                COALESCE(obesity_pct, 0) +
                COALESCE(copd_pct, 0) +
                COALESCE(depression_pct, 0) +
                COALESCE(stroke_pct, 0) +
                COALESCE(cancer_pct, 0) +
                COALESCE(arthritis_pct, 0) +
                COALESCE(asthma_pct, 0) +
                COALESCE(high_cholesterol_pct, 0)
            ) ASC
        ) * 100, 1) 
        AS disease_score,                                          

        -- 3. Hospitalization outcome (higher excess stays = higher priority)
        ROUND(PERCENT_RANK() OVER (
            ORDER BY COALESCE(excess_preventable_stays, 0) ASC
        ) * 100, 1)                                             AS outcome_score,

        -- 4. PCP access gap (fewer PCPs = higher priority; invert rank)
        ROUND((1 - PERCENT_RANK() OVER (
            ORDER BY COALESCE(pcp_per_100k, 0) DESC NULLS LAST
        )) * 100, 1)                                            AS pcp_gap_score,

        -- 5. Uninsured burden (higher uninsured = higher priority)
        ROUND(PERCENT_RANK() OVER (
            ORDER BY COALESCE(uninsured_pct, 0) ASC
        ) * 100, 1)                                             AS uninsured_score

    FROM base
),

-- Calculate weighted composite priority score
scored AS (
    SELECT
        *,
        ROUND(
            (shortage_score  * 0.20) +
            (pcp_gap_score   * 0.20) +
            (outcome_score   * 0.25) +
            (disease_score   * 0.25) +
            (uninsured_score * 0.10)
        , 1)                                                    AS priority_score
    FROM ranked
),

final AS (
    SELECT
        -- Rankings
        RANK() OVER (
            ORDER BY priority_score DESC NULLS LAST
        )                                                       AS priority_rank,

        RANK() OVER (
            PARTITION BY state_abbr
            ORDER BY priority_score DESC NULLS LAST
        )                                                       AS priority_rank_in_state,

        -- Identifiers
        county_fips,
        county_name,
        state_abbr,
        state_name,
        total_population,

        -- Priority scoring
        priority_score,
        shortage_score,
        disease_score,
        outcome_score,
        pcp_gap_score,
        uninsured_score,

        -- Intervention tier
        CASE
            WHEN priority_score >= 80 THEN 'Tier 1 - Critical Priority'
            WHEN priority_score >= 60 THEN 'Tier 2 - High Priority'
            WHEN priority_score >= 40 THEN 'Tier 3 - Moderate Priority'
            WHEN priority_score >= 20 THEN 'Tier 4 - Low Priority'
            ELSE 'Tier 5 - Adequate Access'
        END                                                     AS intervention_tier,

        -- Access context
        is_hpsa_designated,
        hpsa_severity_tier,
        hpsa_score,
        is_medically_underserved,
        is_dual_designated,
        has_fqhc,
        fqhc_coverage_tier,
        pcp_per_100k,
        pop_per_pcp,

        -- Outcomes
        preventable_stays_rate,
        excess_preventable_stays,
        above_national_avg_hosp,
        life_expectancy,
        black_white_hosp_gap,
        hispanic_white_hosp_gap,
        has_racial_disparity,

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
        urban_rural_category,
        uninsured_pct,
        median_household_income,
        children_in_poverty_pct,
        vulnerability_score,

        -- Estimated admissions preventable if county reached national average
        est_excess_stays_count                                  AS admissions_preventable

    FROM scored
)

SELECT * FROM final
ORDER BY priority_rank ASC