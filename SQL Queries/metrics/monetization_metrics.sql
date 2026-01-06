WITH activated_users AS (
  -- Activated user base with segmentation
  SELECT
    uc.id AS user_id,
    uc.country AS origin_countrY
  FROM `lemfi-case.data.users_clean` AS uc
),

base AS (
  SELECT
    created_at_date as date,
    origin_country,
    tc.user_id,
    tc.currency, tc.exchange_currency, tc.amount, fx.for_1_usd,
    SAFE_DIVIDE(amount, for_1_usd) AS amount_usd
  FROM `lemfi-case.data.transactions_clean` as tc
  LEFT JOIN `lemfi-case.data.fx_clean` as fx
    ON fx.currency = tc.currency AND fx.date = tc.created_at_date
  INNER JOIN activated_users as au 
    ON au.user_id = tc.user_id
  WHERE status_group = 'SUCCESS')


SELECT
  FORMAT_DATE('%Y-%m', date) AS month,
  origin_country,
  COUNT(DISTINCT user_id) AS mau,
  SUM(amount_usd) AS fx_volume_usd,

  -- revenue
  SUM(amount_usd) * 0.001  AS revenue_01_pct,
  SUM(amount_usd) * 0.0025 AS revenue_025_pct,
  SUM(amount_usd) * 0.005  AS revenue_05_pct,

  -- ARPU
  SAFE_DIVIDE(SUM(amount_usd) * 0.001,  COUNT(DISTINCT user_id)) AS arpu_01_pct,
  SAFE_DIVIDE(SUM(amount_usd) * 0.0025, COUNT(DISTINCT user_id)) AS arpu_025_pct,
  SAFE_DIVIDE(SUM(amount_usd) * 0.005,  COUNT(DISTINCT user_id)) AS arpu_05_pct

FROM base
GROUP BY month, origin_country
ORDER BY month, origin_country;
