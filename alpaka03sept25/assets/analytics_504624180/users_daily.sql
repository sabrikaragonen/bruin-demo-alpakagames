/* @bruin

name: analytics_504624180.users_daily
type: bq.source
description: |
  Daily user activity fact table with event-level granularity.
  Contains one row per user event per day, spanning all available dates.
  Used for calculating DAU (Daily Active Users) and analyzing user engagement patterns over time.
  Extracted from Firebase/GA4 raw events tables.

materialization:
  type: table
  strategy: time_interval
  incremental_key: event_date
  time_granularity: date
  partition_by: event_date
  cluster_by:
    - user_id
    - event_timestamp

depends:
  - analytics_504624180.events

columns:
  - name: event_date
    type: DATE
    description: Date of the user activity
  - name: event_timestamp
    type: INT64
    description: Unix timestamp in microseconds for precise event ordering
  - name: user_id
    type: STRING
    description: Unique identifier for the player (UUID format)
  - name: user_pseudo_id
    type: STRING
    description: Firebase/GA4 anonymous identifier (persists across sessions)
  - name: version
    type: STRING
    description: App version at time of event (e.g., '0.1.4', '0.1.6')
  - name: operating_system_version
    type: STRING
    description: Device OS version (e.g., 'iOS 26.1')
  - name: mobile_brand_name
    type: STRING
    description: Device manufacturer (e.g., 'Apple')
  - name: mobile_model_name
    type: STRING
    description: Device model (e.g., 'iPhone 15 Pro Max')
  - name: country
    type: STRING
    description: User's country based on geo location
  - name: ga_session_id
    type: INT64
    description: GA4 session identifier for grouping events within a session

@bruin */

SELECT
  PARSE_DATE('%Y%m%d', event_date) as event_date,
  event_timestamp,
  user_id,
  user_pseudo_id,
  app_info.version as version,
  device.operating_system_version,
  device.mobile_brand_name,
  device.mobile_model_name,
  geo.country,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id' LIMIT 1) as ga_session_id
FROM `alpaka03sept25.analytics_504624180.events_*`
WHERE 
  PARSE_DATE('%Y%m%d', _TABLE_SUFFIX) between "{{start_date}}" and "{{end_date}}"
  AND user_id IS NOT NULL
