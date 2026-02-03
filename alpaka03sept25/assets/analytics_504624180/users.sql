/* @bruin

name: analytics_504624180.users
type: bq.source
description: |
  User dimension table with one row per unique user.
  Contains first-touch user attributes captured at initial session.
  Extracted from Firebase/GA4 raw events tables, taking the first event per user.

materialization:
  type: table
  strategy: create+replace

depends:
  - analytics_504624180.events

columns:
  - name: event_date
    type: DATE
    description: Date of the user's first recorded session
  - name: user_id
    type: STRING
    description: Unique identifier for the player (UUID format, set by the game)
  - name: user_pseudo_id
    type: STRING
    description: Firebase/GA4 anonymous identifier (persists across sessions)
  - name: version
    type: STRING
    description: App version at first session (e.g., '0.1.2', '0.1.6')
  - name: operating_system_version
    type: STRING
    description: Device OS version at first session (e.g., 'iOS 18.6.2')
  - name: mobile_brand_name
    type: STRING
    description: Device manufacturer (currently 'Apple' for all iOS users)
  - name: mobile_model_name
    type: STRING
    description: Device model (e.g., 'iPhone X', 'iPhone 15 Pro Max', 'iPad Pro')
  - name: country
    type: STRING
    description: "User's country at first session (top: United States, Türkiye, Germany)"
  - name: ga_session_id
    type: INT64
    description: GA4 session identifier for the user's first session

@bruin */

WITH first_events AS (
  SELECT
    user_id,
    PARSE_DATE('%Y%m%d', event_date) as event_date,
    event_timestamp,
    user_pseudo_id,
    app_info.version as version,
    device.operating_system_version,
    device.mobile_brand_name,
    device.mobile_model_name,
    geo.country,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id' LIMIT 1) as ga_session_id,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_timestamp) as rn
  FROM `alpaka03sept25.analytics_504624180.events_*`
  WHERE user_id IS NOT NULL
)
SELECT
  event_date,
  user_id,
  user_pseudo_id,
  version,
  operating_system_version,
  mobile_brand_name,
  mobile_model_name,
  country,
  ga_session_id
FROM first_events
WHERE rn = 1
