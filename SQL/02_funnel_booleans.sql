-- View all event_name values
SELECT
  event_name
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY event_name;
--------------------------------------------------------------------------------------
-- view_promotion, select_item, first_visit, begin_checkout, session_start, user_engagement,
-- view_item, add_shipping_info, click, add_to_cart, page_view, scroll, select_promotion, purchase,
-- add_payment_info, view_search_results, view_item_list
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- Of these 17 "stages", only 5 stages will be included in the "shopping funnel":
--------------------------------------------------------------------------------------
-- session_start -> view_item -> add_to_cart -> begin_checkout -> purchase
--------------------------------------------------------------------------------------


-- Check number of events for each of the 5 stages
-- Check number of distinct users for each of the 5 stages
SELECT
  event_name,
  COUNT(*) AS num_events,
  COUNT(DISTINCT user_pseudo_id) AS num_distinct_users,
  ROUND(
    COUNT(*) * 1.0 / COUNT(DISTINCT user_pseudo_id)
  , 1) AS num_events_per_distinct_user
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'purchase')
GROUP BY 1
ORDER BY CASE
            WHEN event_name = 'session_start'  THEN 1
            WHEN event_name = 'view_item'      THEN 2
            WHEN event_name = 'add_to_cart'    THEN 3
            WHEN event_name = 'begin_checkout' THEN 4
            WHEN event_name = 'purchase'       THEN 5
          END;
--------------------------------------------------------------------------------------
-- session_start: 354,970 events | 267,116 users | 1.3 events per user
-- view_item:     386,068 events |  61,252 users | 6.3 events per user
-- add_to_cart:    58,543 events |  12,545 users | 4.7 events per user
-- begin_checkout: 38.757 events |   9,715 users | 4.0 events per user
-- purchase:        5,692 events |   4,419 users | 1.3 events per user
--------------------------------------------------------------------------------------


-- Pivot event_name rows into columns, creating booleans for each user's 5 stages
CREATE OR REPLACE VIEW funnel.user_journeys AS
SELECT
  user_pseudo_id,
  MAX(CASE
        WHEN event_name = 'session_start' THEN 1 ELSE 0
      END) AS session_start,
  MAX(CASE
        WHEN event_name = 'view_item' THEN 1 ELSE 0
      END) AS view_item,
  MAX(CASE
        WHEN event_name = 'add_to_cart' THEN 1 ELSE 0
      END) AS add_to_cart,
  MAX(CASE
        WHEN event_name = 'begin_checkout' THEN 1 ELSE 0
      END) AS begin_checkout,
  MAX(CASE
        WHEN event_name = 'purchase' THEN 1 ELSE 0
      END) AS purchase
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY user_pseudo_id;


-- Validate how many users reached each stage without starting a session
SELECT
  SUM(CASE
          WHEN session_start = 0 AND view_item = 1 THEN 1 ELSE 0
      END) AS view_item_users,
  SUM(CASE
          WHEN session_start = 0 AND add_to_cart = 1 THEN 1 ELSE 0
      END) AS add_to_cart_users,
  SUM(CASE
          WHEN session_start = 0 AND begin_checkout = 1 THEN 1 ELSE 0
      END) AS begin_checkout_users,
  SUM(CASE
          WHEN session_start = 0 AND purchase = 1 THEN 1 ELSE 0
      END) AS purchase_users            
FROM funnel.user_journeys;
--------------------------------------------------------------------------------------
-- view_item:      898 users reached stage w/o starting a session
-- add_to_cart:    110 users reached stage w/o starting a session
-- begin_checkout: 101 users reached stage w/o starting a session
-- purchase:        30 users reached stage w/o starting a session
--------------------------------------------------------------------------------------


-- Confirm total number of users
SELECT COUNT(*) FROM funnel.user_journeys;
--------------------------------------------------------------------------------------
-- 270,154 total users
--------------------------------------------------------------------------------------


-- Validate one row per user (results should be exactly the same)
SELECT
  COUNT(*),
  COUNT(DISTINCT user_pseudo_id)
FROM funnel.user_journeys;
--------------------------------------------------------------------------------------
-- 270,154 | 270,154 (correct)
--------------------------------------------------------------------------------------


-- Confirm each column only contains 0 or 1
SELECT
  MAX(session_start),
  MAX(view_item),
  MAX(add_to_cart),
  MAX(begin_checkout),
  MAX(purchase)
FROM funnel.user_journeys;
--------------------------------------------------------------------------------------
-- session_start:  yes
-- view_item:      yes
-- add_to_cart:    yes
-- begin_checkout: yes
-- purchase:       yes
--------------------------------------------------------------------------------------


-- Confirm that user counts are the same, post-pivot
SELECT
  SUM(session_start),
  SUM(view_item),
  SUM(add_to_cart),
  SUM(begin_checkout),
  SUM(purchase)
FROM funnel.user_journeys;
--------------------------------------------------------------------------------------
-- session_start:  267,116 users (correct)
-- view_item:       61,252 users (correct)
-- add_to_cart:     12,545 users (correct)
-- begin_checkout:   9,715 users (correct)
-- purchase:         4,419 users (correct)
--------------------------------------------------------------------------------------

-- Confirm number of users who started a session
SELECT COUNT(*)
FROM funnel.user_journeys
WHERE session_start = 1;
--------------------------------------------------------------------------------------
-- 267,116 users started a session
--------------------------------------------------------------------------------------
-- -- 3,308 users did not start a session. They will be filtered out
--------------------------------------------------------------------------------------


-- Save this filtered user journey table as a view
CREATE OR REPLACE VIEW funnel.user_journeys_filtered AS
SELECT *
FROM funnel.user_journeys
WHERE session_start = 1;


-- Double-check number of users who started a session
SELECT COUNT(*) FROM funnel.user_journeys_filtered;
--------------------------------------------------------------------------------------
-- 267,116 users started a session (correct)
--------------------------------------------------------------------------------------


-- Validate the filter (confirm that there are zero rows with session_start = 0)
SELECT
  COUNT(*)
FROM funnel.user_journeys_filtered
WHERE session_start = 0;
--------------------------------------------------------------------------------------
-- 0 rows where session_start = 0
--------------------------------------------------------------------------------------


-- Confirm that the number of users decreases at every stage
SELECT
  SUM(session_start),
  SUM(view_item),
  SUM(add_to_cart),
  SUM(begin_checkout),
  SUM(purchase)
FROM funnel.user_journeys_filtered;
--------------------------------------------------------------------------------------
-- session_start:  267,116 users
-- view_item:       60,354 users
-- add_to_cart:     12,435 users
-- begin_checkout:   9,614 users
-- purchase:         4,389 users
--------------------------------------------------------------------------------------
-- The number of users does decrease at every stage
--------------------------------------------------------------------------------------


-- Validate that the filtered table has 1 row per user (results should be exactly the same)
SELECT
  COUNT(*),
  COUNT(DISTINCT user_pseudo_id)
FROM funnel.user_journeys_filtered;
--------------------------------------------------------------------------------------
-- 267,116 | 267,116 (correct)
--------------------------------------------------------------------------------------