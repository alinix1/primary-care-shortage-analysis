# Project Overview

## Primary Care Shortage Analysis

**Beyond Access: A Multi-Source Analysis of Primary Care Shortages, Chronic Disease Burden, and Preventable Healthcare Costs Across US Counties**

## Overview

ETL pipeline analyzing how primary care physician shortages correlate with chronic disease burden and preventable healthcare costs across 3,143 US counties using Snowflake, dbt, SQL, and Plotly.

## Problem Statement

## Research Questions

- Do primary care HPSA counties have higher rates of multiple chronic diseases?
- What is the excess cost of preventable hospitalizations in counties with primary care shortages?
- Which counties have the combination of primary care shortage, high disease prevalence, and high costs?
- Do FQHCs (Federally Qualified Health Centers) reduce hospitalization rates in primary care deserts?
- ROI analysis: Cost savings from FQHC investment
- What's the geographic distribution of healthcare deserts (by state/region)?

## Methodology

## Key Insights

## Recommendations

## Data Sources

- CDC PLACES
  - Centers for Disease Control and Prevention (CDC)
  - County-level
  - Chronic disease burden, pre/post COVID

- HRSA Health Professional Shortage Areas (HPSA)
  - Health Resources & Services Administration (HRSA)
  - County-level
  - Shortage designations

- HRSA Medically Underserved Areas/Populations (MUA/P)
  - Health Resources & Services Administration (HRSA)
  - County-level
  - Overall medical underservice

- HRSA Health Center Service Delivery and Look-Alike Sites (FQHCs)
  - Health Resources & Services Administration (HRSA)
  - Site-level (address), aggregated to county
  - FQHC locations

- County Health Rankings & Roadmaps (CHR)
  - University of Wisconsin Population Health Institute
  - County-level
  - PCPs per capita, preventable hospitalizations, outcomes

- US Census Bureau-American Community Survey (ACS)
  - US Census Bureau
  - County-level
  - Insurance coverage, income

- USDA Rural-Urban Continuum Codes (RUCC)
  - USDA Economic Research Service (ERS)
  - County-level
  - Rural/urban classification

## Technologies

- **Data Warehouse:** Snowflake
- **Data Transformation:** dbt (Data Build Tool)
- **Analysis:** SQL
- **Visualization:** Plotly
- **Version Control:** Git/GitHub

## Timeline

- **Week 1:** Project setup, Snowflake configuration, data acquisition
- **Week 2:** dbt models (staging and analytics)
- **Week 3:** SQL analysis, interactive dashboard visualization development
- **Week 4:** Documentation, portfolio preparation

## Deliverables

- County-level interactive maps (visualizations)
- Jupyter notebook with full analysis workflow

## Author

Ali Nix | MPH Biostatistics | Aspiring Data Analyst
