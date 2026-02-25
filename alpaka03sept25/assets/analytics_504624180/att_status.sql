/* @bruin

name: analytics_504624180.att_status
type: bq.source
description: |
  App Tracking Transparency (ATT) status per user.
  Extracts the ATT consent status from custom events collected via Adjust/Firebase.

materialization:
  type: table
  strategy: create+replace

columns:
  - name: status
    type: STRING
    description: ATT consent status value
  - name: uuid
    type: STRING
    description: User identifier

@bruin */

SELECT
  REPLACE(JSON_QUERY(json_field, '$.status'), '"', '') AS status,
  user_id AS uuid
FROM `alpaka03sept25-prd-39uz.event_collection.custom_events`
WHERE DATE(event_timestamp) >= DATE("2025-02-03")
  AND event_name = 'att_status'
GROUP BY 1, 2
