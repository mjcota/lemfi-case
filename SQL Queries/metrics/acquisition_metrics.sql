-- ACQUISITION METRICS --
-- Logic / assumptions:
--   1) Acquisition cost is incurred on the registration day (users.day_created_at).
--   2) "Transacting users" here = users with >= 1 SUCCESS transaction,
--      attributed back to their registration date + acquisition source.
--   3) Organic is forced to cost = 0 (no paid acquisition).
--   4) Add quarter cohort to enable “last quarter” reporting.

CREATE OR REPLACE VIEW `lemfi-case.data.acquisition_metrics_daily_by_source` AS

WITH new_users AS (
  -- Daily new registered users by acquisition source (registration cohort)
  SELECT
    day_created_at,
    source,
    COUNT(DISTINCT id) AS new_registered_users
  FROM `lemfi-case.data.users_clean`
  GROUP BY day_created_at, source
),

transacting_users AS (
  -- Users who EVER transacted successfully, attributed to their registration date and acquisition source.
  -- NOTE: We do NOT use transaction date for grouping because acquisition cost is tied to registration date.
  SELECT
    day_created_at,
    source,
    COUNT(DISTINCT user_id) AS transacting_users
  FROM (
    SELECT DISTINCT
      tr.user_id,
      users.source,
      users.day_created_at
    FROM `lemfi-case.data.transactions_clean` AS tr
    INNER JOIN `lemfi-case.data.users_clean` AS users
      ON tr.user_id = users.id
    WHERE tr.status_group = 'SUCCESS' -- choose SUCCESS for "became transacting user"
  )
  GROUP BY day_created_at, source
),

daily_cost AS (
  -- Daily acquisition cost by source (assumed to be incurred on the registration day)
  SELECT
    date AS day_created_at,
    source,
    cost AS total_acq_cost
  FROM `lemfi-case.data.cost_clean`
)

SELECT
  -- Cohort identifiers
  nu.day_created_at,
  nu.source,

  -- ✅ Quarter cohort based on REGISTRATION date (your cost attribution anchor)
  CONCAT(
    CAST(EXTRACT(YEAR FROM nu.day_created_at) AS STRING),
    '-Q',
    CAST(EXTRACT(QUARTER FROM nu.day_created_at) AS STRING)
  ) AS created_quarter_cohort,

  -- Optional: quarter start date (useful for sorting + Looker filters)
  DATE_TRUNC(nu.day_created_at, QUARTER) AS created_quarter_start,

  -- Base volumes
  nu.new_registered_users,
  tu.transacting_users,

  -- Total acquisition cost (force organic to 0)
  CASE
    WHEN LOWER(nu.source) = 'organic' THEN 0
    ELSE COALESCE(dc.total_acq_cost, 0)
  END AS total_acq_cost,

  -- Windowed totals across ALL sources (same day) for Looker convenience
  SUM(nu.new_registered_users) OVER (PARTITION BY nu.day_created_at) AS new_registered_users_all_sources,

  -- Cost per new registered user
  SAFE_DIVIDE(
    CASE
      WHEN LOWER(nu.source) = 'organic' THEN 0
      ELSE COALESCE(dc.total_acq_cost, 0)
    END,
    nu.new_registered_users
  ) AS cost_per_new_registered_user,

  -- Cost per transacting user (converted user)
  SAFE_DIVIDE(
    CASE
      WHEN LOWER(nu.source) = 'organic' THEN 0
      ELSE COALESCE(dc.total_acq_cost, 0)
    END,
    tu.transacting_users
  ) AS cost_per_transacting_user,


FROM new_users AS nu
LEFT JOIN transacting_users AS tu
  ON nu.day_created_at = tu.day_created_at
  AND nu.source = tu.source
LEFT JOIN daily_cost AS dc
  ON nu.day_created_at = dc.day_created_at
  AND nu.source = dc.source

ORDER BY nu.day_created_at, nu.source;
