-- FX

-- Table is based on google sheets where rates for the corresponding currency is measured against USD using GOOGLEFINANCE function. 		

CREATE OR REPLACE VIEW `lemfi-case.data.fx_clean` AS
SELECT *
FROM (
  SELECT
  -- Parse date like '07-Feb-21'
  PARSE_DATE('%d-%b-%y', date) AS date,
  -- Convert cost, treating '-' as NULL
  SAFE_CAST(for_1_usd AS NUMERIC) AS for_1_usd,
  currency
FROM `lemfi-case.data.fx`
WHERE date != 'Date'
)
ORDER BY date DESC;

-- NULLS
SELECT *
FROM `lemfi-case.data.fx_clean`
WHERE date IS NULL
  OR currency IS NULL
  OR for_1_usd IS NULL;

-- DUPLICATES
SELECT COUNT(*) as _n
FROM `lemfi-case.data.fx_clean`
  GROUP BY date, currency
  HAVING _n > 1; 

-- CHECK POTENTIAL GAPS IN DATES.
WITH ordered_costs AS (
  SELECT
    date,
    LAG(date) OVER (ORDER BY date) AS previous_date
  FROM 
    (SELECT DISTINCT date as date
    FROM `lemfi-case.data.fx_clean`)
)
SELECT
  date,
  previous_date,
  -- Calculate the difference in days
  DATE_DIFF(date, previous_date, DAY) AS day_gap
FROM ordered_costs 
-- We only care about gaps greater than 1 day
WHERE DATE_DIFF(date, previous_date, DAY) > 1;
-- Lack of data on June. 

-- CHECK MIN MAX DATES
-- FROM 2021-01-01 to 2023-12-31
SELECT
  MIN(date) AS min_date,
  MAX(date) AS max_date
FROM `lemfi-case.data.fx_clean`;

-- CHECK UNIQUE VALUES OF SOURCES
-- 6 CURRENCIES
SELECT 
 COUNT(*), currency
 FROM `lemfi-case.data.fx_clean`
 GROUP BY currency;
