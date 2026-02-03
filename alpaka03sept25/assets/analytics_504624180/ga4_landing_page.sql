/* @bruin

name: analytics_504624180.ga4_LandingPage_504624180
type: bq.sql
description: |
  GA4 landing page report view. Shows performance metrics by landing page.
  View over p_ga4_LandingPage_504624180.

materialization:
  type: view

columns:
  - name: landingPage
    type: STRING
    description: The page path associated with the first pageview in a session
  - name: activeUsers
    type: INTEGER
    description: Number of distinct users who visited
  - name: keyEvents
    type: FLOAT
    description: Number of key events (conversions) that occurred
  - name: newUsers
    type: INTEGER
    description: Number of first-time users
  - name: sessionKeyEventRate
    type: FLOAT
    description: Percentage of sessions with a key event
  - name: sessions
    type: INTEGER
    description: Total number of sessions
  - name: totalRevenue
    type: FLOAT
    description: Total revenue from these landing pages
  - name: userEngagementDurationPerSession
    type: FLOAT
    description: Average engagement time per session
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
FROM `alpaka03sept25.analytics_504624180.p_ga4_LandingPage_504624180`
