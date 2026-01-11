/* @bruin
name: analytics_504624180.ga4_Audiences_504624180
type: bq.sql
description: |
  GA4 audiences report view. Shows audience membership with session and revenue metrics.
  This is a view over the partitioned table p_ga4_Audiences_504624180.

materialization:
  type: view

columns:
  - name: audienceName
    type: STRING
    description: Name of the GA4 audience
  - name: averageSessionDuration
    type: FLOAT
    description: Average duration of user sessions in seconds
  - name: newUsers
    type: INTEGER
    description: Number of first-time users in this audience
  - name: screenPageViewsPerSession
    type: FLOAT
    description: Average page/screen views per session
  - name: sessions
    type: INTEGER
    description: Total number of sessions
  - name: totalRevenue
    type: FLOAT
    description: Total revenue from this audience
  - name: totalUsers
    type: INTEGER
    description: Total users in this audience
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
FROM `alpaka03sept25.analytics_504624180.p_ga4_Audiences_504624180`
