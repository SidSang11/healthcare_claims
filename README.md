# Claims Analytics Dashboard

This repository demonstrates an end-to-end claims analytics workflow leveraging AWS Athena partitioning, SQL-based exploratory data analysis, and an interactive Tableau dashboard for visualizing billing performance and trends.

## Project Overview
This project ingests raw claims data, renames and cleans fields, and writes it into a partitioned Athena table for fast querying. A suite of SQL scripts then performs exploratory data analysis—covering completeness checks, summary statistics, distributions, temporal trends, and top-N rankings.

## Data Preparation & Athena Partitioning
1. **Rename & Preview**  
   A SQL step renames raw CSV columns for clarity and previews the first 10 rows.  
2. **Create Partitioned Table**  
   Using `PARTITIONED BY (date_of_service)` stores data in S3 folders per month, reducing scan costs.  
3. **Manage Partitions**  
   `ALTER TABLE … ADD PARTITION` commands automatically pick up new months as they land in S3.

## Exploratory Data Analysis (EDA)
- **Null-Value Summary**: Counts missing entries in each column to flag data gaps.  
- **Numeric Stats**: Computes min, max, mean, and standard deviation for billed, allowed, and paid amounts.  
- **Categorical Profiles**: Reports distributions of claim statuses, reason codes, and insurance types.  
- **Temporal Trends**: Tracks month-over-month claim volumes and averages to reveal seasonality.  
- **Percentile Analysis**: Uses approximate percentiles to understand claim size spread.

## SQL Scripts
All queries live in the `sql/` folder, one script per analysis:
- `01_null_value_summary.sql`
- `02_numeric_summary_stats.sql`
- `03_distinct_value_counts.sql`
- `04_claim_status_distribution.sql`
- `05_top_reason_codes.sql`
- `06_insurance_type_distribution.sql`
- `07_monthly_claim_volume.sql`
- `08_monthly_avg_billed.sql`
- `09_billed_amount_percentiles.sql`
- `10_day_of_week_claims.sql`

## Tableau Dashboard
The `tableau/` folder contains a packaged workbook (`dashboard.twbx`) with:
- Dual-axis line charts for billing vs. payment trends  
- Stacked bars for paid, allowed, and billed amounts by insurance type  
- Pie charts for claim status distributions by insurance type  
- Histograms and box plots for claim size and efficiency variation  
- A combined dashboard with filters and interactive actions

## Project Structure
