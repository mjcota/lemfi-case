-- ============================================================
-- TOTAL ROI CURVE (no segmentation)
-- - Anchor = registration date (users_clean.day_created_at)
-- - Benefits = cumulative revenue proxy from SUCCESS tx (USD) within 180d
-- - Costs = total acquisition cost (flat line)
-- - 3 fee scenarios: 0.1% / 0.25% / 0.5%
-- ============================================================

#CREATE OR REPLACE VIEW `lemfi-case.data.roi_curve` AS

WITH users_base AS (
  -- 1 row per user with registration anchor
  SELECT
    id AS user_id,
    day_created_at AS registered_at     -- DATE
  FROM `lemfi-case.data.users_clean`
),

tx_usd AS (
  -- SUCCESS transactions converted to USD using fx_clean
  -- fx_clean.for_1_usd = "units of currency per 1 USD"
  -- So amount_usd = amount / for_1_usd
  SELECT
    tc.user_id,
    tc.created_at_date AS tx_date,      -- DATE
    tc.currency,
    tc.amount,
    fx.for_1_usd,
    SAFE_DIVIDE(tc.amount, fx.for_1_usd) AS amount_usd
  FROM `lemfi-case.data.transactions_clean` tc
  LEFT JOIN `lemfi-case.data.fx_clean` fx
    ON fx.currency = tc.currency
   AND fx.date = tc.created_at_date      -- ✅ join by date
  WHERE tc.status_group = 'SUCCESS'
),

rev_day AS (
  -- Daily (day-since-registration) FX volume in USD, TOTAL (no segmentation)
  SELECT
    DATE_DIFF(tx.tx_date, ub.registered_at, DAY) AS day_since_anchor,
    SUM(tx.amount_usd) AS fx_volume_usd_day
  FROM users_base ub
  JOIN tx_usd tx
    ON tx.user_id = ub.user_id
   AND tx.tx_date >= ub.registered_at
   AND tx.tx_date <= DATE_ADD(ub.registered_at, INTERVAL 180 DAY) -- horizon
  GROUP BY 1
),

day_axis AS (
  -- Build a complete x-axis: 0..180 days so the curve doesn't have gaps
  SELECT
    d AS day_since_anchor
  FROM UNNEST(GENERATE_ARRAY(0, 180)) AS d
),

rev_filled AS (
  -- Fill missing days with 0 revenue to get smooth cumulative curves
  SELECT
    a.day_since_anchor,
    COALESCE(r.fx_volume_usd_day, 0) AS fx_volume_usd_day
  FROM day_axis a
  LEFT JOIN rev_day r
    ON r.day_since_anchor = a.day_since_anchor
),

rev_cum AS (
  -- Cumulative FX volume (USD) across day-since-anchor
  SELECT
    day_since_anchor,
    SUM(fx_volume_usd_day) OVER (
      ORDER BY day_since_anchor
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cum_fx_volume_usd
  FROM rev_filled
),

all_costs AS (
  -- Total acquisition cost (USD) across the whole observed period
  -- Note: if your cost table includes organic, you can still keep it;
  -- here we just sum everything since we're not segmenting.
  SELECT
    SUM(cost) AS total_acq_cost_usd
  FROM `lemfi-case.data.cost_clean`
),

final AS (
  SELECT
    r.day_since_anchor,

    -- COST CURVE (flat line): cumulative cost is constant across day_since_anchor
    COALESCE(c.total_acq_cost_usd, 0) AS cum_cost_usd,

    -- BENEFIT CURVES (cumulative revenue) for 3 scenarios
    r.cum_fx_volume_usd * 0.001  AS cum_revenue_01pct,
    r.cum_fx_volume_usd * 0.0025 AS cum_revenue_025pct,
    r.cum_fx_volume_usd * 0.005  AS cum_revenue_05pct,

    -- ROI(t) = (cum_revenue(t) - cost) / cost
    -- If cost = 0, ROI is NULL (avoid dividing by 0)
    SAFE_DIVIDE(r.cum_fx_volume_usd * 0.001  - COALESCE(c.total_acq_cost_usd, 0),
                NULLIF(COALESCE(c.total_acq_cost_usd, 0), 0)) AS roi_01pct,

    SAFE_DIVIDE(r.cum_fx_volume_usd * 0.0025 - COALESCE(c.total_acq_cost_usd, 0),
                NULLIF(COALESCE(c.total_acq_cost_usd, 0), 0)) AS roi_025pct,

    SAFE_DIVIDE(r.cum_fx_volume_usd * 0.005  - COALESCE(c.total_acq_cost_usd, 0),
                NULLIF(COALESCE(c.total_acq_cost_usd, 0), 0)) AS roi_05pct,

    -- Payback day = earliest day where cum_revenue >= cost (within 0..180)
    MIN(IF(r.cum_fx_volume_usd * 0.001  >= COALESCE(c.total_acq_cost_usd, 0), r.day_since_anchor, NULL))
      OVER () AS payback_day_01pct,

    MIN(IF(r.cum_fx_volume_usd * 0.0025 >= COALESCE(c.total_acq_cost_usd, 0), r.day_since_anchor, NULL))
      OVER () AS payback_day_025pct,

    MIN(IF(r.cum_fx_volume_usd * 0.005  >= COALESCE(c.total_acq_cost_usd, 0), r.day_since_anchor, NULL))
      OVER () AS payback_day_05pct

  FROM rev_cum r
  CROSS JOIN all_costs c  -- 1-row table; CROSS JOIN is simplest/cleanest
)

-- Final output = curve-ready table (one row per day)
SELECT *
FROM final
ORDER BY day_since_anchor;

