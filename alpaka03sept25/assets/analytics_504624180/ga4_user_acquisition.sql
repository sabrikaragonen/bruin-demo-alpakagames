/* @bruin

name: analytics_504624180.ga4_UserAcquisition_504624180
type: bq.source
description: |
  GA4 user acquisition report view. Shows how new users were first acquired.
  Attributes users to their original acquisition source. View over p_ga4_UserAcquisition_504624180.

materialization:
  type: view

columns:
  - name: firstUserCampaignName
    type: STRING
    description: Campaign that first acquired the user
  - name: firstUserDefaultChannelGroup
    type: STRING
    description: Default channel group of first acquisition
  - name: firstUserMedium
    type: STRING
    description: Medium of first user acquisition
  - name: firstUserPrimaryChannelGroup
    type: STRING
    description: Primary channel group of first acquisition
  - name: firstUserSource
    type: STRING
    description: Source that first acquired the user
  - name: firstUserSourceMedium
    type: STRING
    description: Combined first source/medium
  - name: firstUserSourcePlatform
    type: STRING
    description: Platform of first acquisition source
  - name: activeUsers
    type: INTEGER
    description: Number of active users from this source
  - name: engagedSessions
    type: INTEGER
    description: Engaged sessions from users acquired via this source
  - name: eventCount
    type: INTEGER
    description: Total events from users acquired via this source
  - name: keyEvents
    type: FLOAT
    description: Conversions from users acquired via this source
  - name: newUsers
    type: INTEGER
    description: New users acquired via this source
  - name: totalRevenue
    type: FLOAT
    description: Lifetime revenue from users acquired via this source
  - name: totalUsers
    type: INTEGER
    description: Total users acquired via this source
  - name: userEngagementDuration
    type: FLOAT
    description: Total engagement time from these users
  - name: userKeyEventRate
    type: FLOAT
    description: Conversion rate for users from this source
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
FROM `alpaka03sept25.analytics_504624180.p_ga4_UserAcquisition_504624180`
