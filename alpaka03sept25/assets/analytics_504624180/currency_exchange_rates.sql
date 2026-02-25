/* @bruin

name: analytics_504624180.currency_exchange_rates
type: bq.source
description: |
  Currency exchange rates table used to convert IAP revenue to USD.
  Generates one row per date for USD-USD (rate=1) and USD-TRY (rate=43.415).

materialization:
  type: table
  strategy: create+replace

depends:
  - analytics_504624180.bi_retention_with_session_info

columns:
  - name: rate_date
    type: DATE
    description: Date for the exchange rate
  - name: base_currency
    type: STRING
    description: Base currency code (always USD)
  - name: target_currency
    type: STRING
    description: Target currency code (USD or TRY)
  - name: exchange_rate
    type: FLOAT64
    description: Exchange rate from base to target currency
  - name: loaded_at
    type: TIMESTAMP
    description: Timestamp when the rate was loaded

@bruin */

SELECT
  event_date AS rate_date,
  'USD' AS base_currency,
  'USD' AS target_currency,
  1 AS exchange_rate,
  CURRENT_TIMESTAMP() AS loaded_at
FROM `alpaka03sept25.analytics_504624180.bi_retention_with_session_info`
GROUP BY 1, 2, 3, 4, 5

UNION DISTINCT

SELECT
  event_date,
  'USD',
  'TRY',
  43.415,
  CURRENT_TIMESTAMP()
FROM `alpaka03sept25.analytics_504624180.bi_retention_with_session_info`
GROUP BY 1, 2, 3, 4, 5
