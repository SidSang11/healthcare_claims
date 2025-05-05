# Claims Analytics Dashboard

This repository demonstrates an end-to-end claims analytics workflow leveraging AWS (IAM, S3 Buckets, Glue and Athena), SQL-based data analysis, and an interactive Tableau dashboard for visualizing claims and trends.

## Project Overview
This project ingests raw claims data, renames and cleans fields, and writes it into a partitioned table for fast querying. A suite of SQL scripts then performs exploratory data analysis—covering completeness checks, summary statistics, distributions, temporal trends, and top-N rankings.

## Data Preparation & Athena Partitioning
1. **Rename & Preview**  
   A SQL step renames raw CSV columns for clarity.  
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
claims-analytics-dashboard/
├── data/                   Raw and cleaned CSVs  
├── sql/                    One SQL script per analysis  
├── tableau/                Tableau workbook (.twbx)  
├── images/                 Dashboard screenshots  
├── docs/                   Supplementary documentation  
└── README.md               Project overview and instructions  

## Insights & Conclusions

### 1. Data Quality & Completeness
- Minimal missing values in key fields (claim_id, billed_amount, paid_amount), confirming the data is ready for analysis.

### 2. Claim Size Distribution
- Billed amounts range from \$10 to \$5,000+, with a mean of \$350 and a standard deviation of \$180.
- 25th, 50th, and 75th percentiles sit at \$120, \$330, and \$550, defining small, medium, and large claim segments.

### 3. Insurance-Type Profiles
- Three insurance categories account for over 80% of claims, with Commercial leading in both volume and dollars.
- Government plans show the largest unpaid segments and greatest variability in % paid.

### 4. Claim Status & Reason Codes
- Paid claims represent 72% of records; Denied ~15%; Pending ~13%.
- Top 10 reason codes explain 60% of denials, highlighting a focused set of common issues.

### 5. Temporal Trends
- Monthly claim volumes rose steadily from January through June, then plateaued, indicating a spring utilization surge.
- An 8% drop in average billed amount in April (despite higher volumes) signals a shift toward lower-cost services.

### 6. Provider & Patient Concentration
- Over 1,200 providers and 4,500 patients in the dataset.
- Top 25 providers generate ~30% of billed dollars, underscoring revenue concentration.

### 7. Payment Efficiency Trends
- Dual-axis lines revealed a widening gap between billed and paid in May, flagging emerging delays or policy changes.
- Commercial plans maintain high, consistent %-paid values; Government plans are more variable and lower overall.

## Recommendations

1. **Engage High-Value Providers**  
   Negotiate volume-based contracts or performance incentives with the top 25 providers who drive 30% of billed dollars.

2. **Optimize Government Plan Workflows**  
   Investigate common denial reasons and streamline appeals to improve and stabilize payment rates.

3. **Audit Large Claims**  
   Implement routine reviews for claims above the 75th percentile (\$550+) to detect potential overbilling or fraud.

4. **Plan for Seasonality**  
   Allocate resources for the spring surge in volumes and address the April dip in average claim size.

5. **Monitor Payment Gaps**  
   Set up alerts on billing vs. payment trends to catch widening efficiency gaps early, especially around policy or system changes.


