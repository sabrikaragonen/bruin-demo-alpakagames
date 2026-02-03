/* @bruin

name: analytics_504624180.revenue_table
type: bq.source
description: |
  Revenue aggregation table combining revenue events with user install attributes.
  Contains revenue from ads (inter_paid, rewarded_paid) and in-app purchases (iap_complete_client).
  Includes user install date, version, device info, and country for cohort analysis.

materialization:
  type: table
  strategy: time_interval
  incremental_key: dt
  time_granularity: timestamp
  partition_by: dt
  cluster_by:
    - user_id
    - event_name

depends:
  - events.events
  - user_model.users

columns:
  - name: install_date
    type: DATE
    description: User's install date (first session date)
  - name: version
    type: STRING
    description: App version at install
  - name: operating_system_version
    type: STRING
    description: Operating system version at install
  - name: mobile_model_name
    type: STRING
    description: Device model name at install
  - name: country
    type: STRING
    description: User's country at install
  - name: user_id
    type: STRING
    description: User identifier
  - name: event_name
    type: STRING
    description: Revenue event name (inter_paid, rewarded_paid, iap_complete_client)
  - name: network_name
    type: STRING
    description: Ad network name (for ad revenue events) or IAP product ID (for IAP events)
  - name: dt
    type: TIMESTAMP
    description: Event timestamp
  - name: currency
    type: STRING
    description: Currency code (USD, TRY, etc.)
  - name: revenue
    type: FLOAT64
    description: Revenue amount in USD
  - name: ad_count
    type: INT64
    description: Count of ad events (1 for ad events, NULL for IAP)

@bruin */

WITH user_installs AS (
  SELECT
    user_id,
    install_dt as install_date,
    first_app_version as version,
    first_os_version as operating_system_version,
    first_device_model as mobile_model_name,
    first_country as country
  FROM user_model.users
),
revenue_events AS (
  SELECT
    e.user_id,
    e.ts as dt,
    e.event_name,
    CASE 
      WHEN e.event_name IN ('inter_paid', 'rewarded_paid', 'rw_clicked', 'rw_completed', 'rw_ready', 'rw_recieved', 'rw_showed', 'interstitial_ready', 'interstitial_showed') 
      THEN e.network_name
      WHEN e.event_name = 'iap_complete_client' 
      THEN e.iap_product_id
      ELSE NULL
    END as network_name,
    CASE 
      WHEN e.event_name = 'iap_complete_client' 
      THEN e.iap_iso_currency_code
      ELSE 'USD'
    END as currency,
    COALESCE(e.revenue, e.event_value_in_usd, 0) as revenue,
    CASE 
      WHEN e.event_name IN ('inter_paid', 'rewarded_paid', 'rw_clicked', 'rw_completed', 'rw_ready', 'rw_recieved', 'rw_showed', 'interstitial_ready', 'interstitial_showed') 
      THEN 1
      ELSE NULL
    END as ad_count
  FROM events.events e
  WHERE e.event_name IN ('inter_paid', 'rewarded_paid', 'iap_complete_client')
    AND (e.revenue IS NOT NULL OR e.event_value_in_usd IS NOT NULL)
    AND e.user_id IS NOT NULL
)
SELECT
  COALESCE(ui.install_date, DATE(re.dt)) as install_date,
  COALESCE(ui.version, re.user_id) as version, -- Fallback if user not in users table
  ui.operating_system_version,
  ui.mobile_model_name,
  ui.country,
  re.user_id,
  re.event_name,
  re.network_name,
  re.dt,
  re.currency,
  re.revenue,
  re.ad_count
FROM revenue_events re
LEFT JOIN user_installs ui ON re.user_id = ui.user_id
WHERE re.dt BETWEEN '{{ start_date }}' AND '{{ end_date }}'
