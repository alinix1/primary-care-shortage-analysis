# Project Overview

## Primary Care Shortage Analysis

**Beyond Access: A Multi-Source Analysis of Primary Care Shortages, Chronic Disease Burden, and Preventable Hospitalizations Across US Counties**

## Overview

ETL pipeline analyzing how primary care physician shortages correlate with chronic disease burden and preventable hospitalizations across 3,143 US counties using Snowflake, dbt, SQL, and Plotly.

This project investigates the relationship between primary care access, chronic disease prevalence, and preventable hospitalizations across all US counties. Using a multi-source data integration approach, it examines how health professional shortage designations, provider density, and rural/urban classification correlate with chronic disease burden — and how these dynamics shifted before and after COVID-19.

The analysis aims to move beyond simply identifying where shortages exist to quantifying the downstream health and economic consequences of inadequate primary care access.

## Research Questions

- Do primary care HPSA counties have higher rates of multiple chronic diseases?
- What is the relationship between primary care shortages and preventable hospitalization rates in HPSA-designated counties?
- Which counties have the combination of primary care shortage, high disease prevalence, and preventable hospitalizations?
- Do counties with higher FQHC density show lower preventable hospitalization rates, even when controlling for primary care shortage status?
- What is the geographic distribution of counties with coinciding primary care shortages and high chronic disease burden?
- How did chronic disease prevalence change in HPSA vs non-HPSA counties between 2019 and 2023 (pre/post COVID)?

## Methodology

## Key Insights

## Data Sources

- CDC PLACES
  - Source: Centers for Disease Control and Prevention (CDC)
  - Geo: County-level
  - Main metrics: Chronic disease burden, pre/post COVID
  - Key measures: 12 health outcomes (arthritis, asthma, high blood pressure, cancer, high cholesterol, chronic kidney disease, chronic obstructive pulmonary disease, coronary heart disease, depression, diabetes, obesity, stroke), 7 preventive services, 4 health risk behaviors, 7 disabilities, 3 health status measures, 7 health-related social needs

- HRSA Health Professional Shortage Areas (HPSA)
  - Source: Health Resources & Services Administration (HRSA)
  - Geo: County-level
  - Main metrics: Shortage designations
  - Key measures: HPSA Status, HPSA Score, HPSA Discipline Class, Rural Status, HPSA Formal Ratio, HPSA Shortage, HPSA Estimated Underserved Population

- HRSA Medically Underserved Areas/Populations (MUA/P)
  - Source: Health Resources & Services Administration (HRSA)
  - Geo: County-level
  - Main metrics: Overall medical underservice
  - Key measures: MUA/P Status Description, Designation Type, IMU Score, Population Type, Rural Status Description
  - Useful measures: Percent of Population with Income at or Below 100% Poverty, Percentage of Population Age 65 and Over, Infant Mortality Rate, Providers per 1000 Population, Designation Population

- HRSA Health Center Service Delivery and Look-Alike Sites (FQHCs)
  - Source: Health Resources & Services Administration (HRSA)
  - Geo: Site-level (address), aggregated to county
  - Main metrics: FQHC locations
  - Key measures: Health Center Type, Site Status Description, Operating Hours per Week, Geocoding Artifact Address Primary X/Y Coordinate

- County Health Rankings & Roadmaps (CHR)
  - Source: University of Wisconsin Population Health Institute
  - Geo: County-level
  - Main metrics: PCPs per capita, preventable hospitalizations, Insurance coverage, income inequality, poverty rate, outcomes
  - Key measures: Primary Care Physicians raw value, Ratio of population to primary care physicians, Other Primary Care Providers raw value, Ratio of population to primary care providers other than physicians, Preventable Hospital Stays raw value, Uninsured raw value, Income Inequality raw value, Children in Poverty raw value, Median Household Income raw value
  - Useful measures: Preventable Hospital Stays (Black), Preventable Hospital Stays (White), Life Expectancy raw value, % Rural raw value, Population raw value, % Non-Hispanic Black raw value, % Hispanic raw value

- USDA Rural-Urban Continuum Codes (RUCC)
  - Source: USDA Economic Research Service (ERS)
  - Geo: County-level
  - Main metrics: Rural/urban classification
  - Key measures: Attribute, Value -> RUCC_2023 code (1–9), rural/urban description, Population_2020

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
