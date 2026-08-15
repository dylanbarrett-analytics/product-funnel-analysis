-- Find the totals for each stage (across all users)
CREATE OR REPLACE VIEW funnel.funnel_counts AS
SELECT
  SUM(session_start) AS session_start,
  SUM(view_item) AS view_item,
  SUM(add_to_cart) AS add_to_cart,
  SUM(begin_checkout) AS begin_checkout,
  SUM(purchase) AS purchase
FROM funnel.user_journeys_filtered;
--------------------------------------------------------------------------------------
-- session_start: 267,116 users started a session
-- view_item:      60,354 users reached this stage
-- add_to_cart:    12,435 users reached this stage
-- begin_checkout:  9,614 users reached this stage
-- purchase:        4,389 users reached this stage
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- Overall conversion rate: 1.64% (users who purchased / users who started a session)
--------------------------------------------------------------------------------------


-- Unpivot columns into rows (to create a summary table)
CREATE OR REPLACE VIEW funnel.funnel_unpivoted AS
SELECT
  'Session Start' AS stage,
  session_start AS users
FROM funnel.funnel_counts
UNION ALL
SELECT
  'View Item' AS stage,
  view_item AS users
FROM funnel.funnel_counts
UNION ALL
SELECT
  'Add to Cart' AS stage,
  add_to_cart AS users
FROM funnel.funnel_counts
UNION ALL
SELECT
  'Begin Checkout' AS stage,
  begin_checkout AS users
FROM funnel.funnel_counts
UNION ALL
SELECT
  'Purchase' AS stage,
  purchase AS users
FROM funnel.funnel_counts
ORDER BY users DESC;


-- Create shopping funnel summary table
CREATE OR REPLACE VIEW funnel.funnel_final AS
SELECT
  stage,
  users,
  ROUND(
    users * 100.0 / MAX(users) OVER ()
  , 2) AS cumulative_conversion,
  ROUND(
    100 - (
    (LAG(users) OVER (ORDER BY users DESC) - users) * 100.0
    /
    LAG(users) OVER (ORDER BY users DESC)
        )
  , 2) AS stage_conversion,
  ROUND(
    (LAG(users) OVER (ORDER BY users DESC) - users) * 100.0
    /
    LAG(users) OVER (ORDER BY users DESC)
  , 2) AS dropoff_rate
FROM funnel.funnel_unpivoted
GROUP BY 1, 2
ORDER BY 2 DESC;
--------------------------------------------------------------------------------------
-- The highest drop-off rates were:
-- -- View Item     -> Add to Cart (79.4%)
-- -- Session Start -> View Item   (77.4%)
--------------------------------------------------------------------------------------
-- Both of these "stage transitions" will be further investigated
--------------------------------------------------------------------------------------