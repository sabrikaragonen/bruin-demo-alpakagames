/* @bruin

name: analytics_504624180.level_funnel
type: bq.source
description: |
  Level funnel analysis table joining level_start and level_end events.
  Calculates win/fail counts, durations, enemy kills, and game type classification
  (HigherLevel, SameLevel, LowerLevel) based on player era vs opponent era.
  Enriched with user install attributes from bi_retention_with_session_info.

materialization:
  type: table
  strategy: create+replace

depends:
  - analytics_504624180.bi_retention_with_session_info

columns:
  - name: user_id
    type: STRING
    description: User identifier
  - name: event_timestamp
    type: DATE
    description: Date of the level event
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
  - name: op_era
    type: INT64
    description: Opponent era level
  - name: player_era
    type: INT64
    description: Player era level
  - name: universe
    type: INT64
    description: Universe identifier
  - name: game_type
    type: STRING
    description: "Match type based on era comparison: HigherLevel, SameLevel, or LowerLevel"
  - name: level_start
    type: INT64
    description: Number of distinct levels started
  - name: enemy_killed
    type: INT64
    description: Total enemies killed across levels
  - name: win_count
    type: INT64
    description: Number of levels won
  - name: fail_count
    type: INT64
    description: Number of levels failed
  - name: win_level_duration_sec
    type: FLOAT64
    description: Total duration of won levels in seconds
  - name: fail_level_duration_sec
    type: FLOAT64
    description: Total duration of failed levels in seconds
  - name: win_level_in_game_user_level
    type: INT64
    description: Sum of in-game user level for won levels
  - name: fail_level_in_game_user_level
    type: INT64
    description: Sum of in-game user level for failed levels
  - name: level_end
    type: INT64
    description: Number of levels completed (win or fail)

@bruin */

WITH a AS (
  SELECT
    s.event_name,
    s.user_id,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_timestamp,
    event_timestamp AS event_timestamp_v2,
    install_date,
    version,
    operating_system_version,
    mobile_brand_name,
    mobile_model_name,
    country,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'op_era') AS op_era,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'era') AS player_era,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'universe') AS universe,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'in_game_user_level') AS in_game_user_level,
    (SELECT ep.value.double_value FROM UNNEST(event_params) ep WHERE ep.key = 'starting_hp') * 100 AS starting_hp,
    (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'match_id') AS match_id,
    (SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'enemy_killed') AS enemy_killed,
    (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'level_result') AS level_result,
    (SELECT ep.value.double_value FROM UNNEST(event_params) ep WHERE ep.key = 'game_duration') AS level_duration
  FROM `alpaka03sept25.analytics_504624180.events_*` s
  JOIN `alpaka03sept25.analytics_504624180.bi_retention_with_session_info` a
    ON a.user_id = s.user_id AND retention_day = 0
  WHERE event_name IN ('level_start', 'level_end')
    AND DATE(TIMESTAMP_MICROS(event_timestamp)) >= DATE('2025-12-15')
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
)

SELECT
  ls.user_id,
  ls.event_timestamp,
  ls.install_date,
  ls.version,
  ls.operating_system_version,
  ls.mobile_model_name,
  ls.country,
  ls.op_era,
  ls.player_era,
  ls.universe,
  CASE
    WHEN ls.op_era > ls.player_era THEN 'HigherLevel'
    WHEN ls.op_era = ls.player_era THEN 'SameLevel'
    WHEN ls.op_era < ls.player_era THEN 'LowerLevel'
  END AS game_type,
  COUNT(DISTINCT ls.match_id) AS level_start,
  SUM(le.enemy_killed) AS enemy_killed,
  SUM(CASE WHEN le.level_result = 'win' THEN 1 ELSE 0 END) AS win_count,
  SUM(CASE WHEN le.level_result = 'fail' THEN 1 ELSE 0 END) AS fail_count,
  SUM(CASE WHEN le.level_result = 'win' THEN le.level_duration ELSE 0 END) AS win_level_duration_sec,
  SUM(CASE WHEN le.level_result = 'fail' THEN le.level_duration ELSE 0 END) AS fail_level_duration_sec,
  SUM(CASE WHEN le.level_result = 'win' THEN le.in_game_user_level ELSE 0 END) AS win_level_in_game_user_level,
  SUM(CASE WHEN le.level_result = 'fail' THEN le.in_game_user_level ELSE 0 END) AS fail_level_in_game_user_level,
  SUM(CASE WHEN le.level_result IS NOT NULL THEN 1 ELSE 0 END) AS level_end
FROM (SELECT * FROM a WHERE event_name = 'level_start') ls
LEFT JOIN (SELECT * FROM a WHERE event_name = 'level_end') le
  ON ls.user_id = le.user_id AND ls.match_id = le.match_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
