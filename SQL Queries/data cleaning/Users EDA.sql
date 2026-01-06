-- USERS

-- Table is stored in AWS and is updated once a new user registeres in the app, which can happen some time after user downloaded the app. Data is for the period from January 2021 till November 2021. Date is a timestamp when user registered in the app, ID is User ID assigned by the system, Country is selected by a user and is verified by geocode of the submitted number when user receives a verification code. Is Verified status is updated depending on if user has passed KYC (initially stands on None or False), after which he/she can use our service (needs to be reverified periodically) and Is Blocked shows whether user is blocked for suspected fraudulant activity by our compliance and security teams. Source is assigned through the attribution platform using Appsflyer based on user ID communicated to the attribution platform by our app. In case where user is not associated with Facebook or Google activity, status is set to Organic.					

CREATE OR REPLACE VIEW `lemfi-case.data.users_clean` AS
SELECT * FROM (
  SELECT
    SAFE.PARSE_DATE('%d-%b-%y', day_created_at) AS day_created_at,
    source, id,
    country, is_verified, is_blocked
  FROM `lemfi-case.data.users`
)
WHERE source != 'Source';

-- NULLS
SELECT *
FROM `lemfi-case.data.users_clean`
WHERE day_created_at IS NULL
   OR source IS NULL
   OR id IS NULL
   OR country IS NULL
   OR is_verified IS NULL
   OR is_blocked IS NULL;

-- DUPLICATES
SELECT COUNT(*) as _n
FROM `lemfi-case.data.users_clean`
  GROUP BY id
  HAVING _n > 1; 


-- CHECK MIN MAX DATES
-- FROM 2021-01-01 to 2021-11-30
SELECT
  MIN(day_created_at) AS min_date,
  MAX(day_created_at) AS max_date
FROM `lemfi-case.data.users_clean`;

-- CHECK VALUES OF BLOCKED STATUS
SELECT 
 COUNT(*), is_blocked
 FROM `lemfi-case.data.users_clean`
 GROUP BY is_blocked;

-- CHECK VALUES OF VERIFIED STATUS
SELECT 
 COUNT(*), is_verified
 FROM `lemfi-case.data.users_clean`
 GROUP BY is_verified; # Pending: 29 obs
