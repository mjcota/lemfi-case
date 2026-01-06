-- Default Transfer Country Table (AWS)

-- Default transfer country table is stored in AWS, comes from the app and is selected by user to determine his/her frequent destination country where money is sent. Typically used as a good indicator of where user intends to send money before transaction flow starts.		

CREATE OR REPLACE VIEW `lemfi-case.data.default_transfer_country_clean` AS
SELECT *
FROM (
  SELECT
    SAFE.PARSE_DATE('%d-%b-%y', day_created_at) AS day_created_at,
    user_id,
    country
  FROM `lemfi-case.data.default_transfer_country`
)
WHERE user_id NOT IN ('User ID', 'Total');

-- NULLS
SELECT *
FROM `lemfi-case.data.default_transfer_country_clean`
WHERE day_created_at IS NULL
  OR user_id IS NULL
  OR country IS NULL;

-- DUPLICATES
SELECT COUNT(*) as _n
FROM `lemfi-case.data.default_transfer_country_clean`
  GROUP BY user_id
  HAVING _n > 1; 

-- CHECK MIN MAX DATES
-- FROM 2021-01-01 to 2021-11-30
SELECT
  MIN(day_created_at) AS min_date,
  MAX(day_created_at) AS max_date
FROM `lemfi-case.data.default_transfer_country_clean`;


-- CHECK UNIQUE VALUES OF COUNTRIES
-- 7 COUNTRIES 
SELECT 
 COUNT(*), country
 FROM `lemfi-case.data.default_transfer_country_clean`
 GROUP BY country;
