-- Inspect dataset structure
SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
LIMIT 10;


-- Check number of rows
SELECT COUNT(*) FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
--------------------------------------------------------------------------------------
-- 4,295,584 total rows in the dataset
--------------------------------------------------------------------------------------


-- Check for any user_pseudo_id NULL values
-- Since all user_id values are NULL, we will use user_pseudo_id since it's the true unique identifier for each user
SELECT
  COUNT(*)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE user_pseudo_id IS NULL;
--------------------------------------------------------------------------------------
-- 0 NULL values (for user_pseudo_id)
--------------------------------------------------------------------------------------


-- How many distinct users in the dataset?
SELECT
  COUNT(DISTINCT user_pseudo_id)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
--------------------------------------------------------------------------------------
-- 270,154 distinct users
-- -- With 4,295,584 total rows in the dataset, this equates to ~15.9 events per user (which is reasonable).
--------------------------------------------------------------------------------------


-- Check date range of dataset
SELECT
  MIN(event_date),
  MAX(event_date)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
--------------------------------------------------------------------------------------
-- Earliest date: 2020-11-01
-- Latest date:   2021-01-31
-- -- This is a 3-month period
--------------------------------------------------------------------------------------