# Promotion Progression Analysis in R

This repository contains R code for analysing career progression patterns across the EU staff categories SC, AST, and AD.
It demonstrates real-world data cleaning, transformation, and visualisation techniques using the tidyverse.

The scripts were written in RStudio 2025.05 and are fully reproducible.

promotion_analysis.R: Main script: data transformation and waiting-time computation

plot_promotion_results.R: Visualisation script: SC/AST/AD dual-axis plots

promos.xlsx: Fully anonymised dataset of promotions from 2015-2025

README.md: Project documentation (this file)

## Overview
European institutions use hierarchical staff categories (SC, AST, AD) with multiple grade levels.
This project analyses how long, on average, it takes staff to move from one grade to the next within each category.

## The analysis:
- Reads a dataset where:
    - Rows = persons
    - Columns = yearly promotions (2015–2025)
    - Cell values = promotion grades (e.g. SC1, AST5, AD7)
- Converts the dataset to a tidy long format
- Identifies all grade transitions
- Handles special cases:
    - Persons with only one promotion are excluded
    - Cross-category moves (e.g. AST → AD) are excluded
    - Grade jumps (e.g. AD5 → AD8) are split into fractional multi-step promotions
- Computes:
    - Average waiting years between each grade step
    - Effective number of persons contributing to each step

## The visualisation:
The plotting script generates three dual-axis charts:
- Left Y-axis: Average waiting time (years)
- Right Y-axis: Effective number of persons
- Bars → number of persons
- Line → average waiting time
- X-axis → grade transitions (e.g. 2–3, 3–4, …)

Each category is shown in its own chart (SC, AST, AD)

## How to run:
1. Load your dataset as a tibble/data.frame named promos.xlsx (first column = person ID, next columns = years 2015–2025)
2. Run:
  source("analysis.R")
  results
3. Produce visualisations:
  source("plotting.R")
  plot_SC
  plot_AST
  plot_AD

## Required packages:
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(ggplot2)

## Data privacy note:
The file `promos.xlsx` contains fully anonymised data.  
All personal names have been replaced with random numeric identifiers, and no information exists that could be used to re-identify individuals. The dataset contains only grade categories and years. It is therefore considered non-personal data under the GDPR.
