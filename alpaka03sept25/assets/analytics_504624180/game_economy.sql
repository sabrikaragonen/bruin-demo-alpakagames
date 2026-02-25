/* @bruin

name: analytics_504624180.game_economy
type: bq.source
description: |
  Game economy events table tracking all currency sources and sinks.
  Joins game_economy_source and game_economy_sink events with user install attributes
  from bi_retention_with_session_info. Maps numeric currency types to human-readable names.

materialization:
  type: table
  strategy: create+replace

depends:
  - analytics_504624180.bi_retention_with_session_info

columns:
  - name: event_name
    type: STRING
    description: Economy event type (game_economy_sink or game_economy_source)
  - name: user_id
    type: STRING
    description: User identifier
  - name: event_timestamp
    type: DATE
    description: Date of the economy event
  - name: event_timestamp_crontime
    type: INT64
    description: Raw event timestamp in microseconds
  - name: install_date
    type: DATE
    description: User's install date
  - name: version
    type: STRING
    description: App version at install
  - name: operating_system_version
    type: STRING
    description: Device OS version at install
  - name: mobile_model_name
    type: STRING
    description: Device model at install
  - name: country
    type: STRING
    description: User's country at install
  - name: transaction_name
    type: STRING
    description: Name of the economy transaction
  - name: transaction
    type: INT64
    description: Transaction amount
  - name: balance
    type: INT64
    description: Currency balance after transaction
  - name: currency_type
    type: STRING
    description: "Currency type name: Gold, Money, PurpleGem, BlueGem, ItemLevelUpStone, or GreenGem"

@bruin */

WITH a AS (
  SELECT
    s.event_name,
    s.user_id,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_timestamp,
    event_timestamp AS event_timestamp_crontime,
    install_date,
    version,
    operating_system_version,
    mobile_brand_name,
    mobile_model_name,
    country,
    (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'transaction_name') AS transaction_name,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'transaction') AS transaction,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'type') AS currency_type,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'balance') AS balance
  FROM `alpaka03sept25.analytics_504624180.events_intraday_*` s
  JOIN `alpaka03sept25.analytics_504624180.bi_retention_with_session_info` a
    ON a.user_id = s.user_id AND retention_day = 0
  WHERE event_name IN ('game_economy_sink', 'game_economy_source')
    AND DATE(TIMESTAMP_MICROS(event_timestamp)) >= DATE('2025-12-15')
)

SELECT
  event_name,
  user_id,
  event_timestamp,
  event_timestamp_crontime,
  install_date,
  version,
  operating_system_version,
  mobile_model_name,
  country,
  transaction_name,
  transaction,
  balance,
  CASE
    WHEN currency_type = 0 THEN 'Gold'
    WHEN currency_type = 1 THEN 'Money'
    WHEN currency_type = 2 THEN 'PurpleGem'
    WHEN currency_type = 3 THEN 'BlueGem'
    WHEN currency_type = 4 THEN 'ItemLevelUpStone'
    WHEN currency_type = 5 THEN 'GreenGem'
  END AS currency_type
FROM a
