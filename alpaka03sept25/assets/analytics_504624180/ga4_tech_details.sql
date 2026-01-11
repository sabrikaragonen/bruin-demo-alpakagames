/* @bruin
name: analytics_504624180.ga4_TechDetails_504624180
type: bq.sql
description: |
  GA4 tech details report view. Shows device and browser information with engagement metrics.
  View over p_ga4_TechDetails_504624180.

materialization:
  type: view

columns:
  - name: appVersion
    type: STRING
    description: App version (versionName for Android, short bundle version for iOS)
  - name: browser
    type: STRING
    description: Browser used to view the website
  - name: deviceCategory
    type: STRING
    description: Type of device (Desktop, Tablet, Mobile)
  - name: operatingSystem
    type: STRING
    description: Operating system (Windows, Android, iOS, etc.)
  - name: operatingSystemVersion
    type: STRING
    description: OS version number
  - name: operatingSystemWithVersion
    type: STRING
    description: Combined OS and version (e.g., Android 10)
  - name: platform
    type: STRING
    description: Platform (web, iOS, Android)
  - name: platformDeviceCategory
    type: STRING
    description: Combined platform and device type
  - name: screenResolution
    type: STRING
    description: Screen resolution (e.g., 1920x1080)
  - name: activeUsers
    type: INTEGER
    description: Number of distinct active users
  - name: engagedSessions
    type: INTEGER
    description: Sessions with engagement
  - name: engagementRate
    type: FLOAT
    description: Ratio of engaged sessions to total
  - name: eventCount
    type: INTEGER
    description: Total events triggered
  - name: keyEvents
    type: FLOAT
    description: Number of key events (conversions)
  - name: newUsers
    type: INTEGER
    description: Number of first-time users
  - name: totalRevenue
    type: FLOAT
    description: Total revenue
  - name: userEngagementDuration
    type: FLOAT
    description: Total engagement time in seconds
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
FROM `alpaka03sept25.analytics_504624180.p_ga4_TechDetails_504624180`
