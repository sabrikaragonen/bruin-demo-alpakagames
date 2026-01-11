/* @bruin
name: analytics_504624180.ga4_PagesAndScreens_504624180
type: bq.sql
description: |
  GA4 pages and screens report view. Shows page/screen level engagement metrics.
  View over p_ga4_PagesAndScreens_504624180.

materialization:
  type: view

columns:
  - name: contentGroup
    type: STRING
    description: Content group category for the page/screen
  - name: unifiedPagePathScreen
    type: STRING
    description: Page path (web) or screen class (app)
  - name: unifiedScreenClass
    type: STRING
    description: Page title (web) or screen class (app)
  - name: unifiedScreenName
    type: STRING
    description: Page title (web) or screen name (app)
  - name: activeUsers
    type: INTEGER
    description: Number of distinct active users
  - name: eventCount
    type: INTEGER
    description: Total events on this page/screen
  - name: keyEvents
    type: FLOAT
    description: Number of key events (conversions)
  - name: screenPageViews
    type: INTEGER
    description: Total page/screen views
  - name: screenPageViewsPerUser
    type: FLOAT
    description: Average views per user
  - name: totalRevenue
    type: FLOAT
    description: Total revenue from this page/screen
  - name: userEngagementDuration
    type: FLOAT
    description: Total engagement time in seconds
  - name: _LATEST_DATE
    type: DATE
    description: Most recent date of data refresh
  - name: _DATA_DATE
    type: DATE
    description: Date partition of the data
@bruin */

SELECT
  *,
  DATE('2026-01-10') AS _LATEST_DATE,
  DATE(_PARTITIONTIME) AS _DATA_DATE
FROM `alpaka03sept25.analytics_504624180.p_ga4_PagesAndScreens_504624180`
