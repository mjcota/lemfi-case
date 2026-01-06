-- Transactions 

-- Transaction table represents exchange transaction data performed by users that are registered and verified in our app. Transaction data is for the users in the User Table from the point when users started using the app and till 28th of June 2023. Each transaction has a unique Transaction ID, User ID is the same as ID in the User table and User ID in the default transfer country table. Created date indicates when transaction was initiated. Status shows if transaction was Successful (considered success if status contains this word) / Pending / Failed with variety of different corresponding substatuses. Currency represents the currency in which amount in reflected in the table. Exchange currency indicates currency into which exchange transaction was done.						

CREATE OR REPLACE VIEW `lemfi-case.data.transactions_clean` AS
SELECT
  SAFE.PARSE_TIMESTAMP('%d/%m/%Y %H:%M', created_at) AS created_at,
  DATE(SAFE.PARSE_TIMESTAMP('%d/%m/%Y %H:%M', created_at)) AS created_at_date,
  transaction_id,
  user_id,

  -- NEW: status_clean
  CASE
    WHEN status IS NULL THEN NULL
    WHEN UPPER(status) = 'PENDINGG' THEN 'PENDING'
    WHEN UPPER(status) = 'TRANSFER-FAILEDS' THEN 'TRANSFER-FAILED'
    WHEN UPPER(status) IN ('SUCCESSFUL','FAILED','START','PENDING') THEN UPPER(status)
    WHEN UPPER(status) IN ('TRANSFER-SUCCESSFUL','TRANSFER-FAILED','TRANSFER-PENDING') THEN UPPER(status)
    ELSE UPPER(status)
  END AS status,

  -- NEW: status_group
  CASE
    WHEN status IS NULL THEN 'UNKNOWN'
    WHEN UPPER(status) IN ('SUCCESSFUL','TRANSFER-SUCCESSFUL') THEN 'SUCCESS'
    WHEN UPPER(status) IN ('FAILED','TRANSFER-FAILED','TRANSFER-FAILEDS') THEN 'FAILED'
    WHEN UPPER(status) IN ('PENDING','PENDINGG','TRANSFER-PENDING') THEN 'PENDING'
    WHEN UPPER(status) = 'START' THEN 'START'
    ELSE 'OTHER'
  END AS status_group,

  currency,
  exchange_currency,
  SAFE_CAST(NULLIF(amount, '-') AS NUMERIC) AS amount
FROM `lemfi-case.data.transactions`
WHERE transaction_id != 'Transaction ID';


-- NULLS
SELECT *
FROM `lemfi-case.data.transactions_clean`
WHERE created_at IS NULL 
  OR created_at_date IS NULL
  OR transaction_id IS NULL
  OR user_id IS NULL OR  status IS NULL
  OR currency IS NULL;

-- DUPLICATES
SELECT COUNT(*) as _n
FROM `lemfi-case.data.transactions_clean`
GROUP BY transaction_id
HAVING _n > 1; 

-- CHECK MIN MAX DATES
-- FROM 2021-01-03 to 2023-06-27
SELECT
  MIN(created_at_date) AS min_date,
  MAX(created_at_date) AS max_date
FROM `lemfi-case.data.transactions_clean`;

-- CHECK VALUES OF CURRENCY
# 5 CURRENCIES
SELECT 
 COUNT(*), currency
 FROM `lemfi-case.data.transactions_clean`
 GROUP BY currency;

-- CHECK VALUES OF EXCHANGE CURRENCY
# 13 EXCHANGE CURRENCIES
SELECT 
 COUNT(*), exchange_currency
 FROM `lemfi-case.data.transactions_clean`
 GROUP BY exchange_currency; 

-- CHECK VALUES OF STATUS
# Strings were corrected above.
SELECT 
 COUNT(*), status
 FROM `lemfi-case.data.transactions_clean`
 GROUP BY status; 

SELECT 
 COUNT(*), status_group
 FROM `lemfi-case.data.transactions_clean`
 GROUP BY status_group; 

-- UNIQUE USERS:
# 14,655 
SELECT
  COUNT(DISTINCT user_id) as n_users
 FROM `lemfi-case.data.transactions_clean`;




