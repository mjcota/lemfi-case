-- ENGAGEMENT METRICS (Remittance product)
-- Active user definition: user with >=1 SUCCESS transaction in the period.
-- Outputs:
--   - DAU (daily active transactors)
--   - WAU (calendar week active transactors)
--   - MAU (calendar month active transactors)
--   - Stickiness (DAU/MAU, WAU/MAU)  [DAU/MAU is less meaningful for remittance; WAU/MAU preferred]
--   - Avg SUCCESS transactions per active user (daily/weekly/monthly)

CREATE OR REPLACE VIEW `lemfi-case.data.engagement_metrics_daily_by_corridor` AS

WITH activated_users AS (
  -- Activated user base with segmentation
  SELECT
    id AS user_id,
    country AS origin_country
  FROM `lemfi-case.data.users_clean` 
),

base AS (
  -- 1 row per transaction event (keep only what we need)
  SELECT
    created_at_date AS day, origin_country,
    DATE_TRUNC(created_at_date, WEEK(MONDAY)) AS week_start,
    DATE_TRUNC(created_at_date, MONTH) AS month_start,
    tc.user_id
  FROM `lemfi-case.data.transactions_clean` as tc
  INNER JOIN activated_users as au
    ON au.user_id = tc.user_id
  WHERE status_group = 'SUCCESS'
),

-- DAU
dau AS (
  SELECT
    day, origin_country,
    COUNT(DISTINCT user_id) AS dau,
    COUNT(*) AS tx_d
  FROM base
  GROUP BY day, origin_country
),

-- WAU (calendar week)
wau AS (
  SELECT
    week_start, origin_country,
    COUNT(DISTINCT user_id) AS wau,
    COUNT(*) AS tx_w
  FROM base
  GROUP BY week_start, origin_country
),

-- MAU (calendar month)
mau AS (
  SELECT
    month_start, origin_country,
    COUNT(DISTINCT user_id) AS mau,
    COUNT(*) AS tx_m
  FROM base
  GROUP BY month_start, origin_country
),

-- Bring weekly/monthly denominators down to the day level (so you can chart daily stickiness)
daily_with_wm AS (
  SELECT
    d.day, d.origin_country,
    d.dau,
    d.tx_d,
    d_week.wau, d_week.week_start,
    d_month.mau, d_month.month_start,
    d_week.tx_w,
    d_month.tx_m,

    -- Stickiness ratios
    SAFE_DIVIDE(d.dau, d_month.mau) AS stickiness_dau_mau,
    SAFE_DIVIDE(d_week.wau, d_month.mau) AS stickiness_wau_mau,

    -- Tx per active user (intensity)
    SAFE_DIVIDE(d.tx_d, d.dau) AS tx_per_dau,
    SAFE_DIVIDE(d_week.tx_w, d_week.wau) AS tx_per_wau,
    SAFE_DIVIDE(d_month.tx_m, d_month.mau) AS tx_per_mau
  FROM dau d
  LEFT JOIN wau d_week
    ON DATE_TRUNC(d.day, WEEK(MONDAY)) = d_week.week_start
  LEFT JOIN mau d_month
    ON DATE_TRUNC(d.day, MONTH) = d_month.month_start
)

SELECT *
FROM daily_with_wm
ORDER BY day;

