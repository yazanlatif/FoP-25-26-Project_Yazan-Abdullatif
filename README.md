# FoP-25-26-Project_Yazan-Abdullatif
Final Project for FoP25/26 
# Glucose Dynamics Analysis

This repository contains an analysis of personal continuous glucose monitoring (CGM) data from a FreeStyle Libre 3 sensor.

## Files

- `main_file.qmd` - Main Quarto report with all analysis
- `raw_data_sample.csv` - Sample of raw data (first 15 rows)
- `raw1_data_sample.csv` - Sample of raw data after skipping metadata
- `cleaned_data_sample.csv` - Sample of cleaned data (first 20 rows)
- `figures/` - Folder containing generated plots

## Key Metrics

- Time in Range (70-180 mg/dL): ~99.9%
- Time in Tight Range (70-140 mg/dL): ~98%
- Coefficient of Variation: ~14%

## How to Run

1. Open `main_file.qmd` in RStudio
2. Install required packages: `tidyverse`, `lubridate`
3. Click "Render" to generate the HTML report

## Data Privacy

Only sample data (first 15-20 rows) is included in this repository. Full raw data is kept local for privacy.
