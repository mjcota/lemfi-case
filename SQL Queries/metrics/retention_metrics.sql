-- RETENTION METRICS

-- UNBOUNDED RETENTION (Return On or After)
-- Anchor: Activation date (first SUCCESS tx)
-- Active user: ≥1 SUCCESS transaction
-- Windows: 7d, 15d, 30d, 45d, 60d, 75d, 90d

CREATE OR REPLACE VIEW `lemfi-case.data.retention_metrics_unbouded_daily_by_corridor` AS

WITH first_success_tx AS (
  -- First SUCCESS transaction = activation date
  SELECT
    user_id,
    MIN(created_at_date) AS activated_at
  FROM `lemfi-case.data.transactions_clean`
  WHERE status_group = 'SUCCESS'
  GROUP BY user_id
),

activated_users AS (
  -- Activated user base with segmentation
  SELECT
    u.id AS user_id,
    fst.activated_at,
    u.country AS origin_country,
    u.source
  FROM first_success_tx fst
  INNER JOIN `lemfi-case.data.users_clean` u
    ON u.id = fst.user_id
),

user_activity_after_activation AS (
  -- All SUCCESS activity after activation
  SELECT DISTINCT
    au.user_id,
    au.activated_at, au.origin_country,
    DATE_DIFF(tr.created_at_date, au.activated_at, DAY) AS days_since_activation
  FROM activated_users au
  INNER JOIN `lemfi-case.data.transactions_clean` tr
    ON tr.user_id = au.user_id
   AND tr.status_group = 'SUCCESS'
   AND tr.created_at_date >= au.activated_at
),

unbounded_flags AS (
  -- For each user, flag if they returned ON or AFTER each window
  SELECT
    user_id,
    activated_at, origin_country,

    -- Unbounded retention flags (Return on or after):
-- "retained_14d" means: user had ANY activity on day >= 14 after activation (i.e., came back on/after day 14)

MAX(CASE WHEN days_since_activation >=  14 THEN 1 ELSE 0 END) AS retained_14d,
MAX(CASE WHEN days_since_activation >=  28 THEN 1 ELSE 0 END) AS retained_28d,
MAX(CASE WHEN days_since_activation >=  42 THEN 1 ELSE 0 END) AS retained_42d,
MAX(CASE WHEN days_since_activation >=  56 THEN 1 ELSE 0 END) AS retained_56d,
MAX(CASE WHEN days_since_activation >=  70 THEN 1 ELSE 0 END) AS retained_70d,
MAX(CASE WHEN days_since_activation >=  84 THEN 1 ELSE 0 END) AS retained_84d,
MAX(CASE WHEN days_since_activation >=  98 THEN 1 ELSE 0 END) AS retained_98d,
MAX(CASE WHEN days_since_activation >= 112 THEN 1 ELSE 0 END) AS retained_112d,
MAX(CASE WHEN days_since_activation >= 126 THEN 1 ELSE 0 END) AS retained_126d,
MAX(CASE WHEN days_since_activation >= 140 THEN 1 ELSE 0 END) AS retained_140d,
MAX(CASE WHEN days_since_activation >= 154 THEN 1 ELSE 0 END) AS retained_154d,
MAX(CASE WHEN days_since_activation >= 168 THEN 1 ELSE 0 END) AS retained_168d,
MAX(CASE WHEN days_since_activation >= 182 THEN 1 ELSE 0 END) AS retained_182d,
MAX(CASE WHEN days_since_activation >= 196 THEN 1 ELSE 0 END) AS retained_196d,
MAX(CASE WHEN days_since_activation >= 210 THEN 1 ELSE 0 END) AS retained_210d,
MAX(CASE WHEN days_since_activation >= 224 THEN 1 ELSE 0 END) AS retained_224d,
MAX(CASE WHEN days_since_activation >= 238 THEN 1 ELSE 0 END) AS retained_238d,
MAX(CASE WHEN days_since_activation >= 252 THEN 1 ELSE 0 END) AS retained_252d,
MAX(CASE WHEN days_since_activation >= 266 THEN 1 ELSE 0 END) AS retained_266d,
MAX(CASE WHEN days_since_activation >= 280 THEN 1 ELSE 0 END) AS retained_280d,
MAX(CASE WHEN days_since_activation >= 294 THEN 1 ELSE 0 END) AS retained_294d,
MAX(CASE WHEN days_since_activation >= 308 THEN 1 ELSE 0 END) AS retained_308d,
MAX(CASE WHEN days_since_activation >= 322 THEN 1 ELSE 0 END) AS retained_322d,
MAX(CASE WHEN days_since_activation >= 336 THEN 1 ELSE 0 END) AS retained_336d,
MAX(CASE WHEN days_since_activation >= 350 THEN 1 ELSE 0 END) AS retained_350d,
MAX(CASE WHEN days_since_activation >= 360 THEN 1 ELSE 0 END) AS retained_360d


  FROM user_activity_after_activation
  GROUP BY user_id, activated_at, origin_country
)

SELECT
  -- Cohort definition
  FORMAT_DATE('%Y-%m', activated_at) AS activation_month_cohort, 
  origin_country,

  -- Base size

  COUNT(DISTINCT user_id) AS activated_users,
  -- Counts (numerators)
SUM(retained_14d)  AS returning_14d,
SUM(retained_28d)  AS returning_28d,
SUM(retained_42d)  AS returning_42d,
SUM(retained_56d)  AS returning_56d,
SUM(retained_70d)  AS returning_70d,
SUM(retained_84d)  AS returning_84d,
SUM(retained_98d)  AS returning_98d,
SUM(retained_112d) AS returning_112d,
SUM(retained_126d) AS returning_126d,
SUM(retained_140d) AS returning_140d,
SUM(retained_154d) AS returning_154d,
SUM(retained_168d) AS returning_168d,
SUM(retained_182d) AS returning_182d,
SUM(retained_196d) AS returning_196d,
SUM(retained_210d) AS returning_210d,
SUM(retained_224d) AS returning_224d,
SUM(retained_238d) AS returning_238d,
SUM(retained_252d) AS returning_252d,
SUM(retained_266d) AS returning_266d,
SUM(retained_280d) AS returning_280d,
SUM(retained_294d) AS returning_294d,
SUM(retained_308d) AS returning_308d,
SUM(retained_322d) AS returning_322d,
SUM(retained_336d) AS returning_336d,
SUM(retained_350d) AS returning_350d,
SUM(retained_360d) AS returning_360d,

-- Unbounded retention rates (Return on or after)
SAFE_DIVIDE(SUM(retained_14d),  COUNT(DISTINCT user_id)) AS retention_14d,
SAFE_DIVIDE(SUM(retained_28d),  COUNT(DISTINCT user_id)) AS retention_28d,
SAFE_DIVIDE(SUM(retained_42d),  COUNT(DISTINCT user_id)) AS retention_42d,
SAFE_DIVIDE(SUM(retained_56d),  COUNT(DISTINCT user_id)) AS retention_56d,
SAFE_DIVIDE(SUM(retained_70d),  COUNT(DISTINCT user_id)) AS retention_70d,
SAFE_DIVIDE(SUM(retained_84d),  COUNT(DISTINCT user_id)) AS retention_84d,
SAFE_DIVIDE(SUM(retained_98d),  COUNT(DISTINCT user_id)) AS retention_98d,
SAFE_DIVIDE(SUM(retained_112d), COUNT(DISTINCT user_id)) AS retention_112d,
SAFE_DIVIDE(SUM(retained_126d), COUNT(DISTINCT user_id)) AS retention_126d,
SAFE_DIVIDE(SUM(retained_140d), COUNT(DISTINCT user_id)) AS retention_140d,
SAFE_DIVIDE(SUM(retained_154d), COUNT(DISTINCT user_id)) AS retention_154d,
SAFE_DIVIDE(SUM(retained_168d), COUNT(DISTINCT user_id)) AS retention_168d,
SAFE_DIVIDE(SUM(retained_182d), COUNT(DISTINCT user_id)) AS retention_182d,
SAFE_DIVIDE(SUM(retained_196d), COUNT(DISTINCT user_id)) AS retention_196d,
SAFE_DIVIDE(SUM(retained_210d), COUNT(DISTINCT user_id)) AS retention_210d,
SAFE_DIVIDE(SUM(retained_224d), COUNT(DISTINCT user_id)) AS retention_224d,
SAFE_DIVIDE(SUM(retained_238d), COUNT(DISTINCT user_id)) AS retention_238d,
SAFE_DIVIDE(SUM(retained_252d), COUNT(DISTINCT user_id)) AS retention_252d,
SAFE_DIVIDE(SUM(retained_266d), COUNT(DISTINCT user_id)) AS retention_266d,
SAFE_DIVIDE(SUM(retained_280d), COUNT(DISTINCT user_id)) AS retention_280d,
SAFE_DIVIDE(SUM(retained_294d), COUNT(DISTINCT user_id)) AS retention_294d,
SAFE_DIVIDE(SUM(retained_308d), COUNT(DISTINCT user_id)) AS retention_308d,
SAFE_DIVIDE(SUM(retained_322d), COUNT(DISTINCT user_id)) AS retention_322d,
SAFE_DIVIDE(SUM(retained_336d), COUNT(DISTINCT user_id)) AS retention_336d,
SAFE_DIVIDE(SUM(retained_350d), COUNT(DISTINCT user_id)) AS retention_350d,
SAFE_DIVIDE(SUM(retained_360d), COUNT(DISTINCT user_id)) AS retention_360d


FROM unbounded_flags
GROUP BY  origin_country, activation_month_cohort
ORDER BY activation_month_cohort;



-- ============================================
-- BRACKETED RETENTION (Return On - Custom)
-- Anchor: Activation date (first SUCCESS tx)
-- Active user: ≥1 SUCCESS transaction
-- Brackets:
--   0–7, 8–15, 16–30, 31–45, 46–60, 61–75, 76–90
-- ============================================

CREATE OR REPLACE VIEW `lemfi-case.data.retention_metrics_bracketed_daily_by_corridor` AS


WITH first_success_tx AS (
  -- Activation date per user
  SELECT
    user_id,
    MIN(created_at_date) AS activated_at
  FROM `lemfi-case.data.transactions_clean`
  WHERE status_group = 'SUCCESS'
  GROUP BY user_id
),

activated_users AS (
  -- Activated cohort with dimensions
  SELECT
    u.id AS user_id,
    fst.activated_at,
    u.country AS origin_country,
    u.source
  FROM first_success_tx fst
  INNER JOIN `lemfi-case.data.users_clean` u
    ON u.id = fst.user_id
),

activity_after_activation AS (
  -- All SUCCESS activity after activation
  SELECT DISTINCT
    au.user_id,
    au.activated_at, au.origin_country,
    DATE_DIFF(tr.created_at_date, au.activated_at, DAY) AS days_since_activation
  FROM activated_users au
  INNER JOIN `lemfi-case.data.transactions_clean` tr
    ON tr.user_id = au.user_id
   AND tr.status_group = 'SUCCESS'
   AND tr.created_at_date >= au.activated_at
),

bracket_flags AS (
  -- Flag activity per bracket (1 if user active in that window)
  SELECT
    user_id,
    activated_at, origin_country,

   -- Bracketed retention flags:
-- User is counted in a bucket if they had ANY activity within that days-since-activation range.

MAX(CASE WHEN days_since_activation BETWEEN   0 AND  13 THEN 1 ELSE 0 END) AS b_0_13,
MAX(CASE WHEN days_since_activation BETWEEN  14 AND  27 THEN 1 ELSE 0 END) AS b_14_27,
MAX(CASE WHEN days_since_activation BETWEEN  28 AND  41 THEN 1 ELSE 0 END) AS b_28_41,
MAX(CASE WHEN days_since_activation BETWEEN  42 AND  55 THEN 1 ELSE 0 END) AS b_42_55,
MAX(CASE WHEN days_since_activation BETWEEN  56 AND  69 THEN 1 ELSE 0 END) AS b_56_69,
MAX(CASE WHEN days_since_activation BETWEEN  70 AND  83 THEN 1 ELSE 0 END) AS b_70_83,
MAX(CASE WHEN days_since_activation BETWEEN  84 AND  97 THEN 1 ELSE 0 END) AS b_84_97,
MAX(CASE WHEN days_since_activation BETWEEN  98 AND 111 THEN 1 ELSE 0 END) AS b_98_111,
MAX(CASE WHEN days_since_activation BETWEEN 112 AND 125 THEN 1 ELSE 0 END) AS b_112_125,
MAX(CASE WHEN days_since_activation BETWEEN 126 AND 139 THEN 1 ELSE 0 END) AS b_126_139,
MAX(CASE WHEN days_since_activation BETWEEN 140 AND 153 THEN 1 ELSE 0 END) AS b_140_153,
MAX(CASE WHEN days_since_activation BETWEEN 154 AND 167 THEN 1 ELSE 0 END) AS b_154_167,
MAX(CASE WHEN days_since_activation BETWEEN 168 AND 181 THEN 1 ELSE 0 END) AS b_168_181,
MAX(CASE WHEN days_since_activation BETWEEN 182 AND 195 THEN 1 ELSE 0 END) AS b_182_195,
MAX(CASE WHEN days_since_activation BETWEEN 196 AND 209 THEN 1 ELSE 0 END) AS b_196_209,
MAX(CASE WHEN days_since_activation BETWEEN 210 AND 223 THEN 1 ELSE 0 END) AS b_210_223,
MAX(CASE WHEN days_since_activation BETWEEN 224 AND 237 THEN 1 ELSE 0 END) AS b_224_237,
MAX(CASE WHEN days_since_activation BETWEEN 238 AND 251 THEN 1 ELSE 0 END) AS b_238_251,
MAX(CASE WHEN days_since_activation BETWEEN 252 AND 265 THEN 1 ELSE 0 END) AS b_252_265,
MAX(CASE WHEN days_since_activation BETWEEN 266 AND 279 THEN 1 ELSE 0 END) AS b_266_279,
MAX(CASE WHEN days_since_activation BETWEEN 280 AND 293 THEN 1 ELSE 0 END) AS b_280_293,
MAX(CASE WHEN days_since_activation BETWEEN 294 AND 307 THEN 1 ELSE 0 END) AS b_294_307,
MAX(CASE WHEN days_since_activation BETWEEN 308 AND 321 THEN 1 ELSE 0 END) AS b_308_321,
MAX(CASE WHEN days_since_activation BETWEEN 322 AND 335 THEN 1 ELSE 0 END) AS b_322_335,
MAX(CASE WHEN days_since_activation BETWEEN 336 AND 349 THEN 1 ELSE 0 END) AS b_336_349,
MAX(CASE WHEN days_since_activation BETWEEN 350 AND 360 THEN 1 ELSE 0 END) AS b_350_360


  FROM activity_after_activation
  GROUP BY user_id, activated_at, origin_country
)

SELECT
  -- Cohort
 FORMAT_DATE('%Y-%m', activated_at) AS activation_month_cohort,
 origin_country,

  -- Denominator
  COUNT(DISTINCT user_id) AS activated_users,
  -- Counts per bucket (numerators)
SUM(b_0_13)    AS ret_0_13,
SUM(b_14_27)   AS ret_14_27,
SUM(b_28_41)   AS ret_28_41,
SUM(b_42_55)   AS ret_42_55,
SUM(b_56_69)   AS ret_56_69,
SUM(b_70_83)   AS ret_70_83,
SUM(b_84_97)   AS ret_84_97,
SUM(b_98_111)  AS ret_98_111,
SUM(b_112_125) AS ret_112_125,
SUM(b_126_139) AS ret_126_139,
SUM(b_140_153) AS ret_140_153,
SUM(b_154_167) AS ret_154_167,
SUM(b_168_181) AS ret_168_181,
SUM(b_182_195) AS ret_182_195,
SUM(b_196_209) AS ret_196_209,
SUM(b_210_223) AS ret_210_223,
SUM(b_224_237) AS ret_224_237,
SUM(b_238_251) AS ret_238_251,
SUM(b_252_265) AS ret_252_265,
SUM(b_266_279) AS ret_266_279,
SUM(b_280_293) AS ret_280_293,
SUM(b_294_307) AS ret_294_307,
SUM(b_308_321) AS ret_308_321,
SUM(b_322_335) AS ret_322_335,
SUM(b_336_349) AS ret_336_349,
SUM(b_350_360) AS ret_350_360,

-- Bracketed retention rates (share of activated users who returned within each 14-day window)
SAFE_DIVIDE(SUM(b_0_13),    COUNT(DISTINCT user_id)) AS retention_0_13,
SAFE_DIVIDE(SUM(b_14_27),   COUNT(DISTINCT user_id)) AS retention_14_27,
SAFE_DIVIDE(SUM(b_28_41),   COUNT(DISTINCT user_id)) AS retention_28_41,
SAFE_DIVIDE(SUM(b_42_55),   COUNT(DISTINCT user_id)) AS retention_42_55,
SAFE_DIVIDE(SUM(b_56_69),   COUNT(DISTINCT user_id)) AS retention_56_69,
SAFE_DIVIDE(SUM(b_70_83),   COUNT(DISTINCT user_id)) AS retention_70_83,
SAFE_DIVIDE(SUM(b_84_97),   COUNT(DISTINCT user_id)) AS retention_84_97,
SAFE_DIVIDE(SUM(b_98_111),  COUNT(DISTINCT user_id)) AS retention_98_111,
SAFE_DIVIDE(SUM(b_112_125), COUNT(DISTINCT user_id)) AS retention_112_125,
SAFE_DIVIDE(SUM(b_126_139), COUNT(DISTINCT user_id)) AS retention_126_139,
SAFE_DIVIDE(SUM(b_140_153), COUNT(DISTINCT user_id)) AS retention_140_153,
SAFE_DIVIDE(SUM(b_154_167), COUNT(DISTINCT user_id)) AS retention_154_167,
SAFE_DIVIDE(SUM(b_168_181), COUNT(DISTINCT user_id)) AS retention_168_181,
SAFE_DIVIDE(SUM(b_182_195), COUNT(DISTINCT user_id)) AS retention_182_195,
SAFE_DIVIDE(SUM(b_196_209), COUNT(DISTINCT user_id)) AS retention_196_209,
SAFE_DIVIDE(SUM(b_210_223), COUNT(DISTINCT user_id)) AS retention_210_223,
SAFE_DIVIDE(SUM(b_224_237), COUNT(DISTINCT user_id)) AS retention_224_237,
SAFE_DIVIDE(SUM(b_238_251), COUNT(DISTINCT user_id)) AS retention_238_251,
SAFE_DIVIDE(SUM(b_252_265), COUNT(DISTINCT user_id)) AS retention_252_265,
SAFE_DIVIDE(SUM(b_266_279), COUNT(DISTINCT user_id)) AS retention_266_279,
SAFE_DIVIDE(SUM(b_280_293), COUNT(DISTINCT user_id)) AS retention_280_293,
SAFE_DIVIDE(SUM(b_294_307), COUNT(DISTINCT user_id)) AS retention_294_307,
SAFE_DIVIDE(SUM(b_308_321), COUNT(DISTINCT user_id)) AS retention_308_321,
SAFE_DIVIDE(SUM(b_322_335), COUNT(DISTINCT user_id)) AS retention_322_335,
SAFE_DIVIDE(SUM(b_336_349), COUNT(DISTINCT user_id)) AS retention_336_349,
SAFE_DIVIDE(SUM(b_350_360), COUNT(DISTINCT user_id)) AS retention_350_360

FROM bracket_flags
GROUP BY  origin_country, activation_month_cohort
ORDER BY activation_month_cohort;
