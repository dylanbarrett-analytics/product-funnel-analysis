# Product Funnel Analysis

---

## **Introduction**

A **product funnel** tracks how users progress through a sequence of events leading to a purchase (or conversion). Analyzing this progression can reveal where users are most likely to exit the journey, or **drop off**.

In this study, users were tracked through **five stages** of an e-commerce shopping funnel:
<br>
<br>

<p align="center">
<strong>Session Start</strong> → <strong>View Item</strong> → <strong>Add to Cart</strong> → <strong>Begin Checkout</strong> → <strong>Purchase</strong>
</p>
<br>

**Drop-Off Rate** measures the percentage of users **who do not progress** to the next funnel stage.

---

## **Table of Contents**

1. [Introduction](#introduction)
2. [About the Data](#about-the-data)
3. [Project Goals](#project-goals)
4. [Tools Used](#tools-used)
5. [Project Files](#project-files)
6. [Step 1: Initial Data Checks](#step-1-initial-data-checks)
7. [Step 2: Build the Shopping Funnel](#step-2-build-the-shopping-funnel)
8. [Step 3a: Overall Funnel Drop-Off](#step-3a-overall-funnel-drop-off)
9. [Step 3b: Field Testing](#step-3b-field-testing)
10. [Step 4: Drop-Off by User Session Number](#step-4-drop-off-by-user-session-number)
11. [Step 5: First-Session Drop-Off](#step-5-first-session-drop-off)
12. [Dashboard](#dashboard)
13. [Recommendations](#recommendations)
14. [Tableau Dashboard Link](#tableau-dashboard-link)

---

## **About the Data**

This analysis uses the **Google Analytics 4 Obfuscated Sample E-commerce Dataset**, which is available via BigQuery.

> The raw dataset contains event-level e-commerce activity, including user identifiers, event types, timestamps, session information, traffic information, and other attributes that describe user behavior.

---

## **Project Goals**

1. **Track user progression through the shopping funnel** (from Session Start to Purchase).
2. **Identify the funnel transitions with the highest drop-off rates**.
3. **Investigate user and session characteristics associated with the highest drop-off transitions**.
4. **Identify meaningful behavioral patterns** that could help explain where funnel progression breaks down. 

---

## **Tools Used**

- ![SQL](https://img.shields.io/badge/SQL-blue) (via **BigQuery**): Data loading, cleaning, merging, and analysis
- ![Tableau](https://img.shields.io/badge/Tableau-blue): Dashboard design and final visualizations

---

## **Project Files**

### **BigQuery**
- [`01_initial_checks.sql`](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/SQL/01_initial_checks.sql)
Initial data exploration and validation
- [`02_funnel_booleans.sql`](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/SQL/02_funnel_booleans.sql)
Created user-level flags for each stage of the shopping funnel
- [`03_funnel_summary.sql`](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/SQL/03_funnel_summary.sql)
Calculated user counts and drop-off rates across the funnel stages
- [`04_transition_1.sql`](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/SQL/04_transition_1.sql)
Analyzed Session Start → View Item drop-off across user and session characteristics
- [`05_transition_2.sql`](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/SQL/05_transition_2.sql)
Analyzed View Item → Add to Cart drop-off across user and session characteristics
- [`06_transition_3.sql`](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/SQL/06_transition_3.sql)
Analyzed Add to Cart → Begin Checkout drop-off across user and session characteristics
- [`07_transition_4.sql`](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/SQL/07_transition_4.sql)
Analyzed Begin Checkout → Purchase drop-off across user and session characteristics

### **Documentation**
- `README.md`: Project documentation

---

## **Step 1: Initial Data Checks**

The analysis started with several validation checks on the raw GA4 e-commerce dataset.

The dataset contained **4,295,584 event rows**, representing **270,154 distinct users** over a three-month period from **November 1, 2020 through January 31, 2021**.

Since the dataset's `user_id` field was unavailable, `user_pseudo_id` was used as the unique user identifier.

> No NULL values were found in `user_pseudo_id`.

---

## **Step 2: Build the Shopping Funnel**

There were 17 available event types, but only five were selected to best represent the shopping funnel:
<br>
<br>

<p align="center">
<strong>Session Start</strong> → <strong>View Item</strong> → <strong>Add to Cart</strong> → <strong>Begin Checkout</strong> → <strong>Purchase</strong>
</p>
<br>
<br>

Since the original dataset was at **event grain**, users could appear across many rows. Therefore, the data was transformed to **user grain**.

This created one row per user with Boolean indicators showing whether or not that user reached each of the five funnel stages (1 = stage reached, 0 = stage not reached).

> For example, one user's journey may be:
<p align="center">
  <strong>Session Start = 1</strong> →
  <strong>View Item = 1</strong> →
  <strong>Add to Cart = 0</strong> →
  <strong>Begin Checkout = 0</strong> →
  <strong>Purchase = 0</strong>
</p>

> This means that the user reached both Session Start and View Item, but then "dropped off" before reaching Add to Cart (and the subsequent stages).

Also, users without a recorded Session Start (i.e., Session Start = 0) were filtered out so that every analyzed funnel journey began from the same defined starting point. This resulted in a final population of **267,116 users**, and user counts decreased at each subsequent stage (as expected).

---

## **Step 3a: Overall Funnel Drop-Off**

User counts were aggregated across the five stages:

![Funnel Stage User Counts](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/images/funnel_stage_user_counts.png)

Drop-off rates were then calculated for each **transition** (between consecutive stages of the shopping funnel).

> For example, Session Start → View Item is the first transition of the funnel. View Item → Add to Cart is the second transition, and so on.

![Funnel Transition Drop-Off Rates](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/images/01_dropoff_across_funnel.png)

**The highest drop-off rates occurred early in the funnel**, before users reached Add to Cart:
- Session Start → View Item: 77.4%
- View Item → Add to Cart: 79.4%

Since these two transitions had the highest drop-off rates, they were selected for further investigation.

---

## **Step 3b: Field Testing**

Several available fields were tested to determine if any particular user or session characteristics were associated with these high drop-off rates.

Device type, traffic source, medium, operating system, and browser produced consistent drop-off rates across both transitions, suggesting that none of these fields was a primary driver of the high early-funnel drop-offs.

However, **session number revealed a much stronger pattern**.

---

## **Step 4: Drop-Off by User Session Number**

**Session number** indicates which shopping session a user is on, with Session 1 being their first session, Session 2 their second, and so on.

![Funnel Transition Drop-Off Rates](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/images/02_dropoff_by_session_number.png)

As seen in the chart above, **drop-off generally decreased as users returned for additional sessions**.

Therefore, users were increasingly likely to progress through the shopping funnel as they returned for more sessions.

Perhaps most significantly, **drop-off rates were at their highest in Session 1** (across all transitions), so Session 1 was selected for even further investigation.

---

## **Step 5: First-Session Drop-Off**

![Funnel Transition Drop-Off Rates](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/images/03_dropoff_first_user_session.png)

**First-session drop-off is concentrated at the top of the funnel, before users reach Add to Cart**. Once users reached Add to Cart, they were much more likely to continue progressing.

⭐ **Key Insight:** Combined with the decline in drop-off across later user sessions, this suggests that **a user's first shopping experience** is the biggest area for improvement.

---

### **Dashboard**

![Dashboard Screenshot](https://github.com/dylanbarrett-analytics/product-funnel-analysis/blob/main/images/Product_Funnel_Analysis_dashboard.png)

---

### **Recommendations**

1. **Prioritize improving the first shopping experience (leading up to Add to Cart)** for new users

2. **Investigate website navigation and product discoverability**

3. **Investigate product page design and usability**

---

## **Tableau Dashboard Link**

🔗 [View the Dashboard on Tableau Public](https://public.tableau.com/app/profile/dylan.barrett1539/viz/ProductFunnelAnalysis_17860601693010/Dashboard?publish=yes)
