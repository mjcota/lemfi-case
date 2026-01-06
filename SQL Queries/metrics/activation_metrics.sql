-- Cohort-based activation metrics (registration day as the cohort anchor)
-- Logic:
--   1) The cohort anchor is the user registration date (users.day_created_at).
--      We attribute activation outcomes back to the registration cohort to match acquisition reporting.
--   2) "Activated / First transaction" is defined as the user's FIRST SUCCESSFUL transaction date
--      (transactions_clean.status_group = 'SUCCESS').
--      Rationale: failed/pending/start do not represent a completed value event for the user.
--   3) days_to_activate = days between registration date and first successful transaction date.
--   4) activated_7d / activated_30d flags indicate whether the user activated within 7 / 30 days.
--   5) IMPORTANT: If the query filters to only users with a SUCCESS transaction,
--      then it represents activation SPEED among activated users (not activation rate vs all registered).
--      To compute true "% activated within X days" over all registered users,
--      keep all users in the cohort and set flags to 0 when no SUCCESS transaction exists.

CREATE OR REPLACE VIEW `lemfi-case.data.activation_grouped` AS

WITH destination AS(
  SELECT country as destination_country,
  user_id
FROM  `lemfi-case.data.default_transfer_country_clean`
),


users_transactions AS (
  SELECT
    id as user_id,
    tr.created_at_date as transaction_at,
    us.day_created_at as registered_at,
    us.source, us.country, destination.destination_country
FROM `lemfi-case.data.users_clean` as us
LEFT JOIN  `lemfi-case.data.transactions_clean` as tr
ON us.id = tr.user_id
LEFT JOIN destination ON destination.user_id = us.id
WHERE status_group = 'SUCCESS'),

first_transaction AS (
SELECT
  user_id, source, country, destination_country, 
  MIN(registered_at) AS registered_at,
  MIN(transaction_at) AS first_transaction,
  DATE_DIFF(
    MIN(transaction_at),                 
    MIN(registered_at),                       
    DAY
  ) AS days_to_activate
FROM users_transactions
GROUP BY user_id, source, country, destination_country),

activations AS (
SELECT
  first_transaction.user_id,
  first_transaction.registered_at,
  first_transaction.first_transaction,
  first_transaction.days_to_activate,
  first_transaction.source,
  first_transaction.country as origin_country,
  first_transaction.destination_country as destination_country,
  -- Activated within 7 days
  CASE
    WHEN days_to_activate <= 7 THEN 1
    ELSE 0
  END AS activated_7d,
  -- Activated within 30 days
  CASE
    WHEN days_to_activate <= 30 THEN 1
    ELSE 0
  END AS activated_30d
FROM first_transaction)

SELECT 
 FORMAT_DATE('%Y-%m', registered_at) AS created_month_cohort,
 FORMAT_DATE('%Y-%m', first_transaction) AS transaction_month_cohort,
 COUNT(user_id) as user_n, origin_country, destination_country, source,
 SUM(activated_7d) as activated_7d,
 SUM(activated_30d) as activated_30d
FROM activations
GROUP BY origin_country, destination_country, source, created_month_cohort, transaction_month_cohort;





