/* @bruin

name: analytics_504624180.ga4_Events_504624180
type: bq.sql
description: |
  GA4 events summary report view. Contains event-level metrics aggregated by event name.
  View over p_ga4_Events_504624180.

materialization:
  type: view

columns:
  - name: eventName
    type: STRING
    description: Name of the event (e.g., page_view, session_start, purchase)
  - name: eventCount
    type: INTEGER
    description: Total number of times this event was triggered
  - name: eventCountPerUser
    type: FLOAT
    description: Average number of times each user triggered this event
  - name: totalRevenue
    type: FLOAT
    description: Total revenue attributed to this event
  - name: totalUsers
    type: INTEGER
    description: Number of unique users who triggered this event
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
FROM `alpaka03sept25.analytics_504624180.p_ga4_Events_504624180`
