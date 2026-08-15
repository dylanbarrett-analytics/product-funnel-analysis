-- SESSION START -> VIEW ITEM
--------------------------------------------------------------------------------------
-- Check users by stage (for each device type)
CREATE OR REPLACE VIEW funnel.device_drill_down_2 AS
SELECT
  ee.device.category AS device,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.add_to_cart = 1
                THEN uj.user_pseudo_id
              END) AS add_to_cart_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each device type
SELECT
  device,
  view_item_users,
  add_to_cart_users,
  ROUND(
    100 - (add_to_cart_users * 100.0 / view_item_users)
  , 1) AS drop_off_rate
FROM funnel.device_drill_down_2;
--------------------------------------------------------------------------------------
-- Drop-off rate by device type:
-- -- desktop: 78.7%
-- -- mobile:  78.0%
-- -- tablet:  78.9%
--------------------------------------------------------------------------------------
-- Results are consistent. Device type is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------




-- Check users by stage (for each traffic source)
CREATE OR REPLACE VIEW funnel.source_drill_down_2 AS
SELECT
  ee.traffic_source AS source,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.add_to_cart = 1
                THEN uj.user_pseudo_id
              END) AS add_to_cart_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each traffic source
SELECT
  source,
  view_item_users,
  add_to_cart_users,
  ROUND(
    100 - SAFE_DIVIDE(add_to_cart_users * 100.0, view_item_users)
  , 1) AS drop_off_rate
FROM funnel.source_drill_down_2;
--------------------------------------------------------------------------------------
-- Drop-off rate by traffic source:
-- -- direct: 74.7%
-- -- Google: 76.8%
-- -- other:  74.6%
--------------------------------------------------------------------------------------
-- Results are consistent. Traffic source is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------





-- Check users by stage (for each medium)
CREATE OR REPLACE VIEW funnel.medium_drill_down_2 AS
SELECT
  ee.traffic_source.medium AS medium,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.add_to_cart = 1
                THEN uj.user_pseudo_id
              END) AS add_to_cart_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each device type
SELECT
  medium,
  view_item_users,
  add_to_cart_users,
  ROUND(
    100 - (add_to_cart_users * 100.0 / view_item_users)
  , 1) AS drop_off_rate
FROM funnel.medium_drill_down_2;
--------------------------------------------------------------------------------------
-- Drop-off rate by medium:
-- -- organic:  76.9%
-- -- none:     74.7%
-- -- referral: 72.6%
-- -- CPC:      76.8%
-- -- other:    76.4%
--------------------------------------------------------------------------------------
-- Results are relatively consistent. Medium is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------





-- Check users by stage (for each session number)
CREATE OR REPLACE VIEW funnel.session_number_drill_down_2 AS
SELECT
  (SELECT value.int_value
  FROM UNNEST(ee.event_params)
  WHERE key = 'ga_session_number'
  ) AS session_number,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.add_to_cart = 1
                THEN uj.user_pseudo_id
              END) AS add_to_cart_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each session number
CREATE OR REPLACE VIEW funnel.session_numbers_2 AS
SELECT
  session_number,
  view_item_users,
  add_to_cart_users,
  ROUND(
    100 - (add_to_cart_users * 100.0 / view_item_users)
  , 1) AS drop_off_rate
FROM funnel.session_number_drill_down_2
ORDER BY 1;
--------------------------------------------------------------------------------------
-- Drop-off rate by session number:
-- -- session  1: 79.7%
-- -- session  2: 70.2%
-- -- session  3: 63.6%
-- -- session  4: 59.8%
-- -- session  5: 58.0%
-- -- session  6: 55.8%
-- -- session  7: 55.1%
-- -- session  8: 53.9%
-- -- session  9: 55.0%
-- -- session 10: 55.7%
--------------------------------------------------------------------------------------
-- Drop-off from View Item -> Add to Cart decreases with each additional user session (for the most part).
-- Returning users are increasingly likely to progress to adding to cart, compared to first-time visitors.
--------------------------------------------------------------------------------------
-- However, this decrease is not as sharp as Session Start -> View Item, likely because users who reach
-- the View Item stage are already a more engaged subset of visitors.
--------------------------------------------------------------------------------------





-- Check users by stage (for each operating system)
CREATE OR REPLACE VIEW funnel.os_drill_down_2 AS
SELECT
  ee.device.operating_system AS operating_system,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.add_to_cart = 1
                THEN uj.user_pseudo_id
              END) AS add_to_cart_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each operating system
SELECT
  operating_system,
  view_item_users,
  add_to_cart_users,
  ROUND(
    100 - (add_to_cart_users * 100.0 / view_item_users)
  , 1) AS drop_off_rate
FROM funnel.os_drill_down_2;
--------------------------------------------------------------------------------------
-- Drop-off rate by medium:
-- -- web:       78.6%
-- -- iOS:       77.3%
-- -- Android:   77.8%
-- -- Windows:   78.5%
-- -- Macintosh: 77.7%
-- -- other:     77.3%
--------------------------------------------------------------------------------------
-- Results are consistent. Operating system is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------





-- Check users by stage (for each browser)
CREATE OR REPLACE VIEW funnel.browser_drill_down_2 AS
SELECT
  ee.device.web_info.browser AS browser,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.add_to_cart = 1
                THEN uj.user_pseudo_id
              END) AS add_to_cart_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each browser
SELECT
  browser,
  view_item_users,
  add_to_cart_users,
  ROUND(
    100 - (add_to_cart_users * 100.0 / view_item_users)
  , 1) AS drop_off_rate
FROM funnel.browser_drill_down_2;
--------------------------------------------------------------------------------------
-- Drop-off rate by browser:
-- -- Chrome:          78.8%
-- -- Safari:          78.0%
-- -- Edge:            77.6%
-- -- Android Webview: 75.9%
-- -- Firefox:         79.1%
-- -- other:           76.7%
--------------------------------------------------------------------------------------
-- Results are consistent. Browser is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------