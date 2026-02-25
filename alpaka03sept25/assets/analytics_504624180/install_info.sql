/* @bruin

name: analytics_504624180.install_info
type: bq.source
description: |
  Install attribution table combining in-game Adjust attribution data with
  CSV-uploaded install source data. Resolves network attribution conflicts
  between Organic, Unattributed, and No User Consent by prioritizing
  the CSV-based attribution when available.

materialization:
  type: table
  strategy: create+replace

columns:
  - name: network
    type: STRING
    description: Resolved ad network attribution (e.g., Organic, Unattributed, or paid network name)
  - name: campaign
    type: STRING
    description: Campaign name from attribution
  - name: creative
    type: STRING
    description: Creative name from attribution
  - name: uid
    type: STRING
    description: User identifier

@bruin */

WITH get_mt AS (
  SELECT
    REPLACE(JSON_QUERY(json_field, '$.adjust_adid'), '"', '') AS adid,
    user_id AS uid,
    REPLACE(JSON_QUERY(json_field, '$.network'), '"', '') AS network,
    REPLACE(JSON_QUERY(json_field, '$.campaign'), '"', '') AS campaign,
    REPLACE(JSON_QUERY(json_field, '$.creative'), '"', '') AS creative
  FROM `alpaka03sept25-prd-39uz.event_collection.custom_events`
  WHERE DATE(event_timestamp) >= DATE("2026-02-03")
    AND event_name = 'get_adjust_attribution'
  GROUP BY 1, 2, 3, 4, 5
),

csv_mt AS (
  SELECT campaign_name, network_name, adid, creative_name
  FROM `alpaka03sept25-prd-39uz.event_collection.adjust_install_source`
  WHERE campaign_name NOT LIKE '%{CAMPAIGN_NAME}%'
  GROUP BY 1, 2, 3, 4

  UNION DISTINCT

  SELECT campaign_name, network_name, adid, CAST(NULL AS STRING)
  FROM `alpaka03sept25-prd-39uz.event_collection.adjust_install_source_backup`
  GROUP BY 1, 2, 3, 4
)

SELECT
  CASE
    WHEN g.network = 'Organic' AND m.network_name = 'Organic' THEN 'Organic'
    WHEN g.network = 'Organic' AND m.network_name IN ('No User Consent', 'Unattributed') THEN m.network_name
    WHEN g.network = 'Organic' AND m.network_name NOT IN ('Unattributed', 'Organic', 'No User Consent') THEN m.network_name
    WHEN g.network = 'Unattributed' AND m.network_name IN ('Organic', 'Unattributed') THEN 'Unattributed'
    WHEN g.network = 'Unattributed' AND m.network_name = 'No User Consent' THEN 'No User Consent'
    WHEN g.network = 'Unattributed' AND m.network_name NOT IN ('Unattributed', 'Organic', 'No User Consent') THEN m.network_name
    WHEN g.network = 'No User Consent' AND m.network_name IN ('Organic', 'Unattributed', 'No User Consent') THEN 'No User Consent'
    WHEN g.network = 'No User Consent' AND m.network_name NOT IN ('Unattributed', 'Organic', 'No User Consent') THEN m.network_name
    ELSE g.network
  END AS network,
  COALESCE(g.campaign, m.campaign_name) AS campaign,
  COALESCE(g.creative, m.creative_name) AS creative,
  uid
FROM get_mt g
LEFT JOIN csv_mt m ON g.adid = m.adid
GROUP BY 1, 2, 3, 4
