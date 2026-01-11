/* @bruin
name: analytics_504624180.ga4_DemographicDetails_504624180
type: bq.sql
description: |
  GA4 demographic details report view. Contains user demographics (age, gender, location)
  with engagement metrics. View over p_ga4_DemographicDetails_504624180.

materialization:
  type: view

columns:
  - name: brandingInterest
    type: STRING
    description: User's branding interest category from Google's affinity audience taxonomy
  - name: city
    type: STRING
    description: City from which the user activity originated
  - name: country
    type: STRING
    description: Country from which the user activity originated
  - name: language
    type: STRING
    description: Language setting of the user's browser or device
  - name: region
    type: STRING
    description: Geographic region (state/province) of the user
  - name: userAgeBracket
    type: STRING
    description: Age range of the user (e.g., 18-24, 25-34, 35-44)
  - name: userGender
    type: STRING
    description: Gender of the user (male, female, unknown)
  - name: activeUsers
    type: INTEGER
    description: Number of distinct active users
  - name: engagedSessions
    type: INTEGER
    description: Sessions with engagement (>10s, conversion, or 2+ page views)
  - name: engagementRate
    type: FLOAT
    description: Ratio of engaged sessions to total sessions
  - name: eventCount
    type: INTEGER
    description: Total number of events triggered
  - name: keyEvents
    type: FLOAT
    description: Number of key events (conversions) recorded
  - name: newUsers
    type: INTEGER
    description: Number of first-time users
  - name: totalRevenue
    type: FLOAT
    description: Total revenue from purchases, subscriptions, and ads
  - name: userEngagementDuration
    type: FLOAT
    description: Total engagement time in seconds
  - name: userKeyEventRate
    type: FLOAT
    description: Key events per user
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
FROM `alpaka03sept25.analytics_504624180.p_ga4_DemographicDetails_504624180`
