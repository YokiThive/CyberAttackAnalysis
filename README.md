# Cyber Intrusion Detection and Classification in R

## Overview
This project was developed for a Programming for Data Analysis assignment to explore cyber intrusion detection using the UNSW-NB15 dataset. The analysis focuses on identifying patterns that differentiate normal network traffic from malicious activity, with particular attention to variables such as `sbytes` and `sjit`.

The project includes data cleaning, missing value handling, outlier treatment, statistical testing, correlation analysis, and visualizations to better understand cyber attack behaviour.

## Features
- Cleaned raw network traffic data in R
- Removed invalid characters from numeric fields
- Replaced missing numeric values using median imputation
- Applied IQR-based outlier handling to reduce the impact of extreme values
- Predicted missing `label` values using Random Forest
- Predicted missing `attack_cat` values for attack records
- Performed Pearson and Spearman correlation analysis
- Used Mann-Whitney U tests to compare selected features against attack presence
- Built data visualizations including:
  - Boxplots
  - Violin plots
  - Scatter plots
  - Correlation heatmaps

## Tech Stack
- **Language:** R
- **IDE:** RStudio
- **Libraries:**
  - `ggplot2`
  - `dplyr`
  - `randomForest`
  - `caret`
  - `corrplot`
  - `caTools`

## What I Learned
- How to preprocess real-world cybersecurity datasets in R
- How to clean inconsistent numeric values and handle missing data
- How to use IQR to reduce the effect of outliers
- How Random Forest can be used not only for classification, but also for imputing missing labels
- How to compare variables statistically using non-parametric tests like Mann-Whitney U
- How to interpret correlation matrices using both Pearson and Spearman methods
- How to communicate data insights clearly through visualizations
- How data analysis can support decision-making in cybersecurity

## Key Analysis Focus
This project mainly investigates the relationship between:
- `sbytes` and cyber attack presence
- `sjit` and cyber attack presence
- attack categories and their behavioural differences in network traffic

## Project Outcome
The analysis shows how selected network traffic features can help distinguish normal activity from potential cyber attacks. It also demonstrates the importance of proper preprocessing and feature analysis before building more advanced detection models.

## Disclaimer
This project was completed as part of an academic assignment. It is intended for learning and analytical purposes.
