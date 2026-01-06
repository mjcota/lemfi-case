
-- COST

-- Table contains extract from Google Ads Manager and Facebook Audience Network consoles via the API. Data is imported daily automatically via API into Google Big Query into a table A that overwrites the contents of that table with new data and then the data is appended into table B where history is stored. Facebook Ads Manager data is updated manually on the daily basis into google sheets and is then appended into the cost table. Date field shows the date of the new user acquisition and Source shows whether data came from GA or FB. Cost emerges when used clicks on the ad and is reflected in USD.	

CREATE OR REPLACE VIEW `lemfi-case.data.cost_clean` AS
-- DATA TYPES AND NULLS --
SELECT *
FROM (
  SELECT
  -- Parse date like '07-Feb-21'
  PARSE_DATE('%d-%b-%y', date) AS date,
  -- Normalize source (optional but good practice)
  LOWER(source) AS source,
  -- Convert cost, treating '-' as NULL
  SAFE_CAST(NULLIF(cost, '-') AS NUMERIC) AS cost
FROM `lemfi-case.data.cost`
WHERE date != 'Date'
)
ORDER BY date DESC;


-- CHECK POTENTIAL GAPS IN DATES.
WITH ordered_costs AS (
  SELECT
    date,
    source,
    cost,
    -- Use LAG to look at the previous row's date within the ordered sequence
    LAG(date) OVER (ORDER BY date) AS previous_date
  FROM `lemfi-case.data.cost_clean`
)
SELECT
  date,
  previous_date,
  -- Calculate the difference in days
  DATE_DIFF(date, previous_date, DAY) AS day_gap
FROM ordered_costs
-- We only care about gaps greater than 1 day
WHERE DATE_DIFF(date, previous_date, DAY) > 1;
-- Two dates without consecutive observations. 

-- CHECK MIN MAX DATES
SELECT
  MIN(date) AS min_date,
  MAX(date) AS max_date
FROM `lemfi-case.data.cost_clean`;

-- CHECK COST VALUES
SELECT
  MAX(cost) AS max_cost,
  MIN(cost) AS min_cost,
  AVG(cost) AS avg_cost,
  APPROX_QUANTILES(cost, 100)[OFFSET(50)] AS median_cost
FROM `lemfi-case.data.cost_clean`;

-- CHECK UNIQUE VALUES OF SOURCES
SELECT 
 DISTINCT source as sources
 FROM `lemfi-case.data.cost_clean`;



