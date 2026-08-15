-- Check users by stage (for each session number)
CREATE OR REPLACE VIEW funnel.session_number_drill_down_3 AS
SELECT
  (SELECT value.int_value
  FROM UNNEST(ee.event_params)
  WHERE key = 'ga_session_number'
  ) AS session_number,
  COUNT(DISTINCT
              CASE
                WHEN uj.add_to_cart = 1
                THEN uj.user_pseudo_id
              END) AS add_to_cart_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.begin_checkout = 1
                THEN uj.user_pseudo_id
              END) AS begin_checkout_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each session number
CREATE OR REPLACE VIEW funnel.session_numbers_3 AS
SELECT
  session_number,
  add_to_cart_users,
  begin_checkout_users,
  ROUND(
    100 - SAFE_DIVIDE(begin_checkout_users * 100.0, add_to_cart_users)
  , 1) AS drop_off_rate
FROM funnel.session_number_drill_down_3
ORDER BY 1;
--------------------------------------------------------------------------------------
-- Drop-off rate by session number:
-- -- session  1: 26.1%
-- -- session  2: 24.0%
-- -- session  3: 15.8%
-- -- session  4: 10.8%
-- -- session  5:  5.9%
-- -- session  6:  3.3%
-- -- session  7:  0.8%
-- -- session  8:  0.4%
-- -- session  9:   --%
-- -- session 10:   --%
--------------------------------------------------------------------------------------
-- Drop-off from Add to Cart -> Begin Checkout generally decreases with each additional user session.
-- The behavioral gap between first-time and returning users continues to narrow deeper into the funnel.
--------------------------------------------------------------------------------------