-- Check users by stage (for each session number)
CREATE OR REPLACE VIEW funnel.session_number_drill_down_4 AS
SELECT
  (SELECT value.int_value
  FROM UNNEST(ee.event_params)
  WHERE key = 'ga_session_number'
  ) AS session_number,
  COUNT(DISTINCT
              CASE
                WHEN uj.begin_checkout = 1
                THEN uj.user_pseudo_id
              END) AS begin_checkout_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.purchase = 1
                THEN uj.user_pseudo_id
              END) AS purchase_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each session number
CREATE OR REPLACE VIEW funnel.session_numbers_4 AS
SELECT
  session_number,
  begin_checkout_users,
  purchase_users,
  ROUND(
    100 - SAFE_DIVIDE(purchase_users * 100.0, begin_checkout_users)
  , 1) AS drop_off_rate
FROM funnel.session_number_drill_down_4
ORDER BY 1;
--------------------------------------------------------------------------------------
-- Drop-off rate by session number:
-- -- session  1: 57.8%
-- -- session  2: 37.7%
-- -- session  3: 34.9%
-- -- session  4: 33.1%
-- -- session  5: 31.7%
-- -- session  6: 30.2%
-- -- session  7: 30.3%
-- -- session  8: 30.4%
-- -- session  9: 30.2%
-- -- session 10: 28.3%
--------------------------------------------------------------------------------------
-- Drop-off from Begin Checkout -> Purchase generally decreases with each additional user session.
-- The behavioral gap between first-time and returning users is smaller at the bottom of the funnel.
--------------------------------------------------------------------------------------