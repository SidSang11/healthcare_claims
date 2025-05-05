-- 1. null_value_summary.sql
-- This query counts missing (NULL) values for each column to assess data completeness.
SELECT
  SUM(CASE WHEN claim_id           IS NULL THEN 1 ELSE 0 END) AS claim_id_nulls,
  SUM(CASE WHEN provider_id        IS NULL THEN 1 ELSE 0 END) AS provider_id_nulls,
  SUM(CASE WHEN patient_id         IS NULL THEN 1 ELSE 0 END) AS patient_id_nulls,
  SUM(CASE WHEN date_parse(date_of_service,'%m/%d/%y') IS NULL THEN 1 ELSE 0 END) AS date_of_service_nulls,
  SUM(CASE WHEN billed_amount      IS NULL THEN 1 ELSE 0 END) AS billed_amount_nulls,
  SUM(CASE WHEN allowed_amount     IS NULL THEN 1 ELSE 0 END) AS allowed_amount_nulls,
  SUM(CASE WHEN paid_amount        IS NULL THEN 1 ELSE 0 END) AS paid_amount_nulls,
  SUM(CASE WHEN insurance_type     IS NULL THEN 1 ELSE 0 END) AS insurance_type_nulls,
  SUM(CASE WHEN procedure_code     IS NULL THEN 1 ELSE 0 END) AS procedure_code_nulls,
  SUM(CASE WHEN diagnosis_code     IS NULL THEN 1 ELSE 0 END) AS diagnosis_code_nulls,
  SUM(CASE WHEN claim_status       IS NULL THEN 1 ELSE 0 END) AS claim_status_nulls,
  SUM(CASE WHEN reason_code        IS NULL THEN 1 ELSE 0 END) AS reason_code_nulls,
  SUM(CASE WHEN follow_up_required IS NULL THEN 1 ELSE 0 END) AS follow_up_required_nulls,
  SUM(CASE WHEN ar_status          IS NULL THEN 1 ELSE 0 END) AS ar_status_nulls,
  SUM(CASE WHEN outcome            IS NULL THEN 1 ELSE 0 END) AS outcome_nulls
FROM db_claims_renamed;

-- 2. numeric_summary_stats.sql
-- This query computes min, max, average, and standard deviation for the three amount fields (billed_amount, allowed_amount and paid_amount).
SELECT
  MIN(billed_amount)       AS min_billed,
  MAX(billed_amount)       AS max_billed,
  ROUND(AVG(billed_amount),2)   AS avg_billed,
  ROUND(stddev_pop(billed_amount),2) AS stddev_billed,
  MIN(allowed_amount)      AS min_allowed,
  MAX(allowed_amount)      AS max_allowed,
  ROUND(AVG(allowed_amount),2)  AS avg_allowed,
  ROUND(stddev_pop(allowed_amount),2) AS stddev_allowed,
  MIN(paid_amount)         AS min_paid,
  MAX(paid_amount)         AS max_paid,
  ROUND(AVG(paid_amount),2)     AS avg_paid,
  ROUND(stddev_pop(paid_amount),2)  AS stddev_paid
FROM db_claims_renamed;

-- 3. distinct_value_counts.sql
-- This query reports the number of distinct values in key categorical columns such as provider_idpatient_id, outcome and so on.
SELECT
  COUNT(DISTINCT provider_id)    AS provider_count,
  COUNT(DISTINCT patient_id)     AS patient_count,
  COUNT(DISTINCT insurance_type) AS insurance_type_count,
  COUNT(DISTINCT procedure_code) AS procedure_code_count,
  COUNT(DISTINCT diagnosis_code) AS diagnosis_code_count,
  COUNT(DISTINCT claim_status)   AS claim_status_count,
  COUNT(DISTINCT reason_code)    AS reason_code_count,
  COUNT(DISTINCT ar_status)      AS ar_status_count,
  COUNT(DISTINCT outcome)        AS outcome_count
FROM db_claims_renamed;

-- 4. claim_status_distribution.sql
-- This query shows how claims are distributed across different claim statuses.
SELECT
  claim_status,
  COUNT(*) AS num_claims,
  ROUND(CAST(COUNT(*) AS DOUBLE)
    / NULLIF((SELECT COUNT(*) FROM db_claims_renamed),0)*100,2) AS pct_of_total
FROM db_claims_renamed
GROUP BY claim_status
ORDER BY num_claims DESC;

-- 5. top_reason_codes.sql
-- This query identifies the top 10 reason codes by claim frequency.
SELECT
  reason_code,
  COUNT(*)     AS num_claims,
  SUM(billed_amount) AS total_billed
FROM db_claims_renamed
GROUP BY reason_code
ORDER BY num_claims DESC
LIMIT 10;

-- 6. insurance_type_distribution.sql
-- This query summarizes claim counts, total billed, and average billed by insurance type.
SELECT
  insurance_type,
  COUNT(*)              AS num_claims,
  SUM(billed_amount)    AS total_billed,
  ROUND(AVG(billed_amount),2) AS avg_billed
FROM db_claims_renamed
GROUP BY insurance_type
ORDER BY total_billed DESC;

-- 7. monthly_claim_volume.sql
-- This query counts the number of claims for each calendar month.
SELECT
  date_format(date_trunc('month',CAST(date_parse(date_of_service,'%m/%d/%y') AS date)),'%Y-%m')
    AS claim_month,
  COUNT(*) AS num_claims
FROM db_claims_renamed
GROUP BY date_format(date_trunc('month',CAST(date_parse(date_of_service,'%m/%d/%y') AS date)),'%Y-%m')
ORDER BY claim_month;

-- 8. monthly_avg_billed.sql
-- This query calculates the average billed amount per claim each month.
SELECT
  date_format(date_trunc('month',CAST(date_parse(date_of_service,'%m/%d/%y') AS date)),'%Y-%m')
    AS claim_month,
  ROUND(AVG(billed_amount),2) AS avg_billed_amount
FROM db_claims_renamed
GROUP BY date_format(date_trunc('month',CAST(date_parse(date_of_service,'%m/%d/%y') AS date)),'%Y-%m')
ORDER BY claim_month;

-- 9. billed_amount_percentiles.sql
-- This query returns the 25th, 50th, and 75th percentiles of billed_amount for distribution insight.
WITH q AS (
  SELECT approx_percentile(billed_amount, ARRAY[0.25,0.5,0.75]) AS quantiles
  FROM db_claims_renamed
)
SELECT
  quantiles[1] AS q1_billed,
  quantiles[2] AS median_billed,
  quantiles[3] AS q3_billed
FROM q;

-- 10. day_of_week_claims.sql
-- This query shows claim counts for each day of the week to spot weekday vs. weekend patterns.
SELECT
  date_format(CAST(date_parse(date_of_service,'%m/%d/%y') AS date), '%W') AS day_of_week,
  COUNT(*) AS num_claims
FROM db_claims_renamed
GROUP BY date_format(CAST(date_parse(date_of_service,'%m/%d/%y') AS date), '%W')
ORDER BY num_claims DESC;
