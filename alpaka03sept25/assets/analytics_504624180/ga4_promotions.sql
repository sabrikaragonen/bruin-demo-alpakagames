/* @bruin

name: analytics_504624180.ga4_Promotions_504624180
type: bq.source
description: |
  GA4 promotions report view. Shows promotion performance metrics.
  View over p_ga4_Promotions_504624180.

materialization:
  type: view

columns:
  - name: _LATEST_DATE
    type: DATE
    description: Most recent date of data refresh
  - name: _DATA_DATE
    type: DATE
    description: Date partition of the data
  - name: itemListPosition
    type: STRING
  - name: itemPromotionCreativeName
    type: STRING
  - name: itemPromotionId
    type: STRING
  - name: itemPromotionName
    type: STRING
  - name: itemPromotionClickThroughRate
    type: FLOAT
  - name: itemRevenue
    type: FLOAT
  - name: itemsAddedToCart
    type: INTEGER
  - name: itemsCheckedOut
    type: INTEGER
  - name: itemsClickedInPromotion
    type: INTEGER
  - name: itemsPurchased
    type: INTEGER
  - name: itemsViewedInPromotion
    type: INTEGER

@bruin */

SELECT
    *,
    DATE('2026-01-10') AS _LATEST_DATE,
    DATE(_PARTITIONTIME) AS _DATA_DATE
FROM `alpaka03sept25.analytics_504624180.p_ga4_Promotions_504624180`
