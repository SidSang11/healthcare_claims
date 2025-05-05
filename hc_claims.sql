-- These SQL queries are for querrying appropriate tables for further data analysis and visualizations after EDA and cleaning.

-- 1. This query renames raw columns for clarity and previews.
SELECT
  "Claim ID"           AS claim_id,
  "Provider ID"        AS provider_id,
  "Patient ID"         AS patient_id,
  "Date of Service"    AS date_of_service,
  "Billed Amount"      AS billed_amount,
  "Allowed Amount"     AS allowed_amount,
  "Paid Amount"        AS paid_amount,
  "Insurance Type"     AS insurance_type,
  "Procedure Code"     AS procedure_code,
  "Diagnosis Code"     AS diagnosis_code,
  "Claim Status"       AS claim_status,
  "Reason Code"        AS reason_code,
  "Follow-up Required" AS follow_up_required,
  "AR Status"          AS ar_status,
  "Outcome"            AS outcome
FROM "db_claims"."claims_raw_data"
LIMIT 10;

-- 2. This query creates a cleaned external table with renamed columns for analysis.
CREATE TABLE "db_claims"."db_claims_renamed" WITH (
  format = 'TEXTFILE',
  external_location = 's3://claims-data-us-east-2/db_claims_renamed/',
  field_delimiter = ','
) AS
SELECT
  "Claim ID"           AS claim_id,
  "Provider ID"        AS provider_id,
  "Patient ID"         AS patient_id,
  "Date of Service"    AS date_of_service,
  "Billed Amount"      AS billed_amount,
  "Allowed Amount"     AS allowed_amount,
  "Paid Amount"        AS paid_amount,
  "Insurance Type"     AS insurance_type,
  "Procedure Code"     AS procedure_code,
  "Diagnosis Code"     AS diagnosis_code,
  "Claim Status"       AS claim_status,
  "Reason Code"        AS reason_code,
  "Follow-up Required" AS follow_up_required,
  "AR Status"          AS ar_status,
  "Outcome"            AS outcome
FROM "db_claims"."claims_raw_data";

-- 3. This query counts the number of claims for each reason code.
SELECT
  reason_code,
  COUNT(*) AS "num_claims"
FROM db_claims_renamed
GROUP BY reason_code
ORDER BY "num_claims" DESC;

-- 4. This query shows claim count, total paid, and % paid of billed by insurance type.
SELECT
  insurance_type,
  COUNT(*) AS "num_claims",
  SUM(paid_amount) AS "total_paid",
  ROUND(CAST(SUM(paid_amount) AS DOUBLE)/NULLIF(SUM(billed_amount), 0)*100, 2) AS "%_paid_of_billed"
FROM db_claims_renamed
GROUP BY insurance_type
ORDER BY total_paid DESC;

-- 5. This query aggregates monthly claim counts, total paid, % paid of billed, and avg billed amount.
SELECT 
  date_format(date_trunc('month', CAST(date_parse(date_of_service,'%m/%d/%y') AS date)), '%Y-%m') AS "claim_month", 
  COUNT(*) AS "num_claims", 
  SUM(paid_amount) AS "total_paid", 
  ROUND(CAST(SUM(paid_amount) AS DOUBLE)/NULLIF(SUM(billed_amount),0)*100,2) AS "%_paid_of_billed", 
  ROUND(AVG(billed_amount), 2) AS "avg_billed_amount"
FROM db_claims_renamed
GROUP BY date_format(date_trunc('month', CAST(date_parse(date_of_service,'%m/%d/%y') AS date)), '%Y-%m')
ORDER BY "claim_month";

-- 6. This query breaks down claim volume and payment efficiency by insurance type and AR status.
SELECT
  insurance_type,
  ar_status,
  COUNT(*) AS "num_claims",
  SUM(billed_amount) AS "total_billed",
  SUM(paid_amount) AS "total_paid",
  ROUND(CAST(SUM(paid_amount) AS DOUBLE)/NULLIF(SUM(billed_amount), 0)*100, 2) AS "%_paid_of_billed"
FROM db_claims_renamed
GROUP BY insurance_type, ar_status
ORDER BY insurance_type, "total_billed" DESC;

-- 7. This query repeats the AR status breakdown by insurance, highlighting billing vs. payment by status.
SELECT
  insurance_type,
  ar_status,
  COUNT(*) AS "num_claims",
  SUM(billed_amount) AS "total_billed",
  SUM(paid_amount) AS "total_paid",
  ROUND(CAST(SUM(paid_amount) AS DOUBLE)/NULLIF(SUM(billed_amount), 0)*100, 2) AS "%_paid_of_billed"
FROM db_claims_renamed
GROUP BY insurance_type, ar_status
ORDER BY insurance_type, "total_billed" DESC;

-- 8. This query ranks and retrieves the top 5 highest‐billed claims for each insurance type.
SELECT
  claim_id,
  insurance_type,
  billed_amount,
  rank
FROM (
  SELECT
    claim_id,
    insurance_type,
    billed_amount,
    RANK() OVER (PARTITION BY insurance_type ORDER BY billed_amount DESC) AS rank
  FROM db_claims_renamed
) t
WHERE rank <= 5
ORDER BY insurance_type, rank;

-- 9. This query computes month‐over‐month percent change in total billed amounts.
WITH monthly AS (
  SELECT 
    date_format(date_trunc('month', CAST(date_parse(date_of_service,'%m/%d/%y') AS date)), '%Y-%m') AS claim_month,
    SUM(billed_amount) AS monthly_billed
  FROM db_claims_renamed
  GROUP BY date_format(date_trunc('month', CAST(date_parse(date_of_service,'%m/%d/%y') AS date)), '%Y-%m')
),
monthly_lag AS (
  SELECT 
    claim_month,
    monthly_billed,
    LAG(monthly_billed) OVER (
      ORDER BY CAST(concat(substr(claim_month,1,4),'-',substr(claim_month,6,2),'-01') AS date)
    ) AS prev_billed
  FROM monthly
)
SELECT
  claim_month,
  monthly_billed,
  prev_billed,
  ROUND((CAST(monthly_billed AS DOUBLE) - CAST(prev_billed AS DOUBLE))/NULLIF(CAST(prev_billed AS DOUBLE), 0)*100, 2) AS "%_change"
FROM monthly_lag
ORDER BY claim_month;
