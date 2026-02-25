/* @bruin

name: analytics_504624180.bi_retention_with_session_info
type: bq.source
description: |
  Retention table with session info. Calculates daily retention metrics per user
  from install date, including session count and engagement duration.
  Used as a base table for revenue_table, game_economy, level_funnel, and currency_exchange_rates.

materialization:
  type: table
  strategy: create+replace

columns:
  - name: install_date
    type: DATE
    description: User's first recorded event date (install date)
  - name: event_date
    type: DATE
    description: Date of activity
  - name: user_id
    type: STRING
    description: User identifier
  - name: user_pseudo_id
    type: STRING
    description: Firebase/GA4 anonymous identifier
  - name: version
    type: STRING
    description: App version at install
  - name: operating_system_version
    type: STRING
    description: Device OS version at install
  - name: mobile_brand_name
    type: STRING
    description: Device manufacturer at install
  - name: mobile_model_name
    type: STRING
    description: Device model at install
  - name: country
    type: STRING
    description: User's country at install
  - name: retention_day
    type: INT64
    description: Days since install (0 = install day)
  - name: session_count
    type: INT64
    description: Number of distinct sessions on that day
  - name: duration_min
    type: FLOAT64
    description: Total engagement duration in minutes for that day

@bruin */

WITH sessions AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    event_timestamp,
    user_id,
    user_pseudo_id,
    app_info.version,
    device.operating_system_version,
    device.mobile_brand_name,
    device.mobile_model_name,
    geo.country,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'ga_session_id') AS ga_session_id
  FROM `alpaka03sept25.analytics_504624180.events_*`
  WHERE DATE(TIMESTAMP_MICROS(event_timestamp)) >= DATE('2025-12-01')
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
),

install AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_timestamp ASC) AS rn
  FROM sessions
  WHERE user_id IS NOT NULL
),

engagement AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    user_id,
    SUM((SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'engagement_time_msec') / (1000 * 60)) AS duration_min
  FROM `alpaka03sept25.analytics_504624180.events_*`
  WHERE DATE(TIMESTAMP_MICROS(event_timestamp)) >= DATE('2025-12-01')
    AND event_name = 'user_engagement'
  GROUP BY 1, 2
),

retention AS (
  SELECT
    i.event_date AS install_date,
    s.event_date AS event_date,
    i.user_id,
    i.user_pseudo_id,
    i.version,
    i.operating_system_version,
    i.mobile_brand_name,
    i.mobile_model_name,
    i.country,
    DATE_DIFF(s.event_date, i.event_date, DAY) AS retention_day,
    COUNT(DISTINCT s.ga_session_id) AS session_count
  FROM install i
  JOIN sessions s ON s.user_id = i.user_id AND rn = 1
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
)

SELECT r.*, duration_min
FROM retention r
LEFT JOIN engagement e ON e.user_id = r.user_id AND e.event_date = r.event_date
WHERE install_date >= DATE('2025-12-16')
