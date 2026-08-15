-- SESSION START -> VIEW ITEM
--------------------------------------------------------------------------------------
-- Check users by stage (for each device type)
CREATE OR REPLACE VIEW funnel.device_drill_down_1 AS
SELECT
  ee.device.category AS device,
  COUNT(DISTINCT
              CASE
                WHEN uj.session_start = 1
                THEN uj.user_pseudo_id
              END) AS session_start_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each device type
SELECT
  device,
  session_start_users,
  view_item_users,
  ROUND(
    100 - (view_item_users * 100.0 / session_start_users)
  , 1) AS drop_off_rate
FROM funnel.device_drill_down_1;
--------------------------------------------------------------------------------------
-- Drop-off rate by device type:
-- -- desktop: 76.8%
-- -- mobile:  76.7%
-- -- tablet:  75.9%
--------------------------------------------------------------------------------------
-- Results are consistent. Device type is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------





-- Check users by stage (for each traffic source)
CREATE OR REPLACE VIEW funnel.source_drill_down_1 AS
SELECT
  ee.traffic_source.source AS source,
  COUNT(DISTINCT
              CASE
                WHEN uj.session_start = 1
                THEN uj.user_pseudo_id
              END) AS session_start_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each traffic source
SELECT
  source,
  session_start_users,
  view_item_users,
  ROUND(
    100 - (view_item_users * 100.0 / session_start_users)
  , 1) AS drop_off_rate
FROM funnel.source_drill_down;
--------------------------------------------------------------------------------------
-- Drop-off rate by traffic source:
-- -- direct: 72.6%
-- -- Google: 75.1%
-- -- other:  74.4%
--------------------------------------------------------------------------------------
-- Results are consistent. Traffic source is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------





-- Check users by stage (for each medium)
CREATE OR REPLACE VIEW funnel.medium_drill_down_1 AS
SELECT
  ee.traffic_source.medium AS medium,
  COUNT(DISTINCT
              CASE
                WHEN uj.session_start = 1
                THEN uj.user_pseudo_id
              END) AS session_start_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each medium
SELECT
  medium,
  session_start_users,
  view_item_users,
  ROUND(
    100 - (view_item_users * 100.0 / session_start_users)
  , 1) AS drop_off_rate
FROM funnel.medium_drill_down_1;
--------------------------------------------------------------------------------------
-- Drop-off rate by medium:
-- -- organic:  74.8%
-- -- none:     72.6%
-- -- referral: 68.3%
-- -- CPC:      75.2%
-- -- other:    75.6%
--------------------------------------------------------------------------------------
-- Results are relatively consistent. Medium is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------





-- Check users by stage (for each session number)
CREATE OR REPLACE VIEW funnel.session_number_drill_down_1 AS
SELECT
  (SELECT value.int_value
  FROM UNNEST(ee.event_params)
  WHERE key = 'ga_session_number'
  ) AS session_number,
  COUNT(DISTINCT
              CASE
                WHEN uj.session_start = 1
                THEN uj.user_pseudo_id
              END) AS session_start_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each session number
CREATE OR REPLACE VIEW funnel.session_numbers_1 AS
SELECT
  session_number,
  session_start_users,
  view_item_users,
  ROUND(
    100 - (view_item_users * 100.0 / session_start_users)
  , 1) AS drop_off_rate
FROM funnel.session_number_drill_down_1
ORDER BY 1;
--------------------------------------------------------------------------------------
-- Drop-off rate by session number:
-- -- session  1: 78.2%
-- -- session  2: 56.2%
-- -- session  3: 41.4%
-- -- session  4: 33.5%
-- -- session  5: 28.4%
-- -- session  6: 25.3%
-- -- session  7: 22.9%
-- -- session  8: 21.9%
-- -- session  9: 20.7%
-- -- session 10: 19.9%
--------------------------------------------------------------------------------------
-- Drop-off from Session Start -> View Item decreases substantially with each additional user session.
-- Returning users are increasingly likely to progress to viewing an item, compared to first-time visitors.
--------------------------------------------------------------------------------------





-- Check users by stage (for each operating system)
CREATE OR REPLACE VIEW funnel.os_drill_down_1 AS
SELECT
  ee.device.operating_system AS operating_system,
  COUNT(DISTINCT
              CASE
                WHEN uj.session_start = 1
                THEN uj.user_pseudo_id
              END) AS session_start_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each operating system
SELECT
  operating_system,
  session_start_users,
  view_item_users,
  ROUND(
    100 - (view_item_users * 100.0 / session_start_users)
  , 1) AS drop_off_rate
FROM funnel.os_drill_down_1;
--------------------------------------------------------------------------------------
-- Drop-off rate by medium:
-- -- web:       77.0%
-- -- iOS:       76.3%
-- -- Android:   76.2%
-- -- Windows:   76.0%
-- -- Macintosh: 75.8%
-- -- other:     76.5%
--------------------------------------------------------------------------------------
-- Results are consistent. Operating system is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------





-- Check users by stage (for each browser)
CREATE OR REPLACE VIEW funnel.browser_drill_down_1 AS
SELECT
  ee.device.web_info.browser AS browser,
  COUNT(DISTINCT
              CASE
                WHEN uj.session_start = 1
                THEN uj.user_pseudo_id
              END) AS session_start_users,
  COUNT(DISTINCT
              CASE
                WHEN uj.view_item = 1
                THEN uj.user_pseudo_id
              END) AS view_item_users,
FROM funnel.user_journeys_filtered uj
JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` ee
  ON uj.user_pseudo_id = ee.user_pseudo_id
GROUP BY 1;


-- Find drop-off rate for each browser
SELECT
  browser,
  session_start_users,
  view_item_users,
  ROUND(
    100 - (view_item_users * 100.0 / session_start_users)
  , 1) AS drop_off_rate
FROM funnel.browser_drill_down_1;
--------------------------------------------------------------------------------------
-- Drop-off rate by browser:
-- -- Chrome:          76.9%
-- -- Safari:          76.6%
-- -- Edge:            76.4%
-- -- Android Webview: 75.3%
-- -- Firefox:         76.8%
-- -- other:           76.8%
--------------------------------------------------------------------------------------
-- Results are consistent. Browser is unlikely to be the primary driver of the high drop-off.
--------------------------------------------------------------------------------------