/* @bruin

name: analytics_504624180.ga4_TrafficAcquisition_504624180
type: bq.sql
description: |
  GA4 traffic acquisition report view. Shows how sessions were acquired by source,
  medium, and campaign. View over p_ga4_TrafficAcquisition_504624180.

materialization:
  type: view

columns:
  - name: sessionCampaignName
    type: STRING
    description: Marketing campaign name that drove the session
  - name: sessionDefaultChannelGroup
    type: STRING
    description: Default channel grouping (Organic Search, Paid Search, Direct, etc.)
  - name: sessionMedium
    type: STRING
    description: Marketing medium (organic, cpc, referral, email)
  - name: sessionPrimaryChannelGroup
    type: STRING
    description: Primary channel group classification
  - name: sessionSource
    type: STRING
    description: Traffic source (google, facebook, direct)
  - name: sessionSourceMedium
    type: STRING
    description: Combined source/medium
  - name: sessionSourcePlatform
    type: STRING
    description: Platform of the traffic source
  - name: engagedSessions
    type: INTEGER
    description: Sessions with engagement (>10s, conversion, or 2+ views)
  - name: engagementRate
    type: FLOAT
    description: Ratio of engaged sessions to total sessions
  - name: eventCount
    type: INTEGER
    description: Total events triggered in these sessions
  - name: eventsPerSession
    type: FLOAT
    description: Average events per session
  - name: keyEvents
    type: FLOAT
    description: Number of conversion events
  - name: sessionKeyEventRate
    type: FLOAT
    description: Conversion rate per session
  - name: sessions
    type: INTEGER
    description: Total number of sessions
  - name: totalRevenue
    type: FLOAT
    description: Total revenue from these sessions
  - name: userEngagementDurationPerSession
    type: FLOAT
    description: Average engagement time per session in seconds
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
FROM `alpaka03sept25.analytics_504624180.p_ga4_TrafficAcquisition_504624180`
