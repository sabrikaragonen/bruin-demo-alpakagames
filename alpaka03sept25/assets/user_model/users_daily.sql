/* @bruin

type: bq.sql
description: The users_daily table contains daily user-level metrics and dimensions. The underlying table is partitioned by date and clustered by user_id. This table is used for reporting and ad-hoc analysis.

materialization:
  type: table
  strategy: time_interval
  incremental_key: dt
  time_granularity: date
  partition_by: dt
  cluster_by:
    - user_id

depends:
  - events.events

columns:
  - name: user_id
    type: STRING
    description: The user ID
    primary_key: true
  - name: dt
    type: DATE
    description: The date of the event
    primary_key: true
  - name: platform
    type: STRING
    description: The platform (Android, iOS, Web). Gets the first platform used by the user in the day.

@bruin */

SELECT
  user_id, --TODO: change to user_pseudo_id if needed
  dt,
  min_by(platform, ts) as platform, --TODO: Gets the first platform used by the user. Change it, or convert to dimension if needed.

  -- User Attributes
  array_agg(app_version ignore nulls order by ts limit 1)[safe_offset(0)] as daily_first_app_version,
  array_agg(app_version ignore nulls order by ts desc limit 1)[safe_offset(0)] as daily_last_app_version,
  array_agg(geo.country ignore nulls order by ts limit 1)[safe_offset(0)] as daily_first_country,
  array_agg(geo.country ignore nulls order by ts desc limit 1)[safe_offset(0)] as daily_last_country,
  coalesce(array_agg(device.mobile_brand_name ignore nulls order by ts limit 1)[safe_offset(0)], 'unknown') as daily_first_device_brand,
  coalesce(array_agg(device.mobile_brand_name ignore nulls order by ts desc limit 1)[safe_offset(0)], 'unknown') as daily_last_device_brand,
  coalesce(array_agg(device.mobile_model_name ignore nulls order by ts limit 1)[safe_offset(0)], 'unknown') as daily_first_device_model,
  coalesce(array_agg(device.mobile_model_name ignore nulls order by ts desc limit 1)[safe_offset(0)], 'unknown') as daily_last_device_model,
  coalesce(array_agg(device.language ignore nulls order by ts limit 1)[safe_offset(0)], 'unknown') as daily_first_device_language,
  coalesce(array_agg(device.language ignore nulls order by ts desc limit 1)[safe_offset(0)], 'unknown') as daily_last_device_language,
  array_agg(device.operating_system_version ignore nulls order by ts limit 1)[safe_offset(0)] as daily_first_os_version,
  array_agg(device.operating_system_version ignore nulls order by ts desc limit 1)[safe_offset(0)] as daily_last_os_version,

  -- Session Attributes
  count(*) as events,
  min(ts) as min_ts,
  max(ts) as max_ts,
  countif(event_name not in ("session_start", "user_engagement", "firebase_campaign", "ad_reward", "session_ping")) > 0 as engaged,
  countif(event_name = "session_start" or event_name = "session_started") as session_starts,
  min(session_number) as min_session_number,
  max(session_number) as max_session_number,
  timestamp_diff(max(ts), min(ts), second) as session_duration_sec,
  sum(engagement_time_sec) as total_engagement_time_sec,
  array_agg(if(event_name not in ("user_engagement", "session_ping"), event_name, null) ignore nulls order by ts limit 1)[safe_offset(0)] as daily_first_event,
  array_agg(if(event_name not in ("user_engagement", "session_ping"), event_name, null) ignore nulls order by ts desc limit 1)[safe_offset(0)] as daily_last_event,

  -- Revenue and Transactions
  countif(event_name in ("inter_paid", "rewarded_paid", "rw_showed", "interstitial_showed")) as ad_imp_cnt,
  countif(event_name in ("inter_paid", "interstitial_showed", "interstitial_ready", "interstitial_clicked", "interstitial_complete")) as inters,
  countif(event_name in ("rewarded_paid", "rw_showed", "rw_clicked", "rw_completed", "rw_ready", "rw_recieved")) as rewardeds,
  countif(event_name in ("inter_paid", "rewarded_paid", "rw_showed", "interstitial_showed")) as ad_shows,
  sum(coalesce(revenue, 0)) as ad_rev,
  sum(if(event_name in ("inter_paid", "interstitial_showed", "interstitial_ready", "interstitial_clicked", "interstitial_complete"), coalesce(revenue, 0), 0)) as inter_rev,
  sum(if(event_name in ("rewarded_paid", "rw_showed", "rw_clicked", "rw_completed", "rw_ready", "rw_recieved"), coalesce(revenue, 0), 0)) as rewarded_rev,
  countif(event_name in ("iap_complete_client", "iap_confirmed")) as transactions,
  coalesce(sum(if(event_name in ("iap_complete_client", "iap_confirmed"), event_value_in_usd, 0)), 0) as iap_rev,
  sum(coalesce(revenue, 0)) + coalesce(sum(if(event_name in ("iap_complete_client", "iap_confirmed"), event_value_in_usd, 0)), 0) as total_rev,

  -- Gameplay Metrics
  countif(event_name = "level_start") as level_starts,
  countif(event_name = "level_end") as level_ends,
  countif(event_name = "level_end" and level_result = "win") as level_wins,
  countif(event_name = "level_end" and level_result = "fail") as level_fails,
  sum(if(event_name = "level_end", game_duration, null)) as total_level_duration_sec,
  sum(if(event_name = "level_end", enemy_killed, 0)) as total_enemies_killed,
  sum(if(event_name = "level_end", elite_killed, 0)) as total_elites_killed,
  max(if(event_name = "level_end", in_game_user_level, null)) as max_user_level,
  max(if(event_name = "level_end", era, null)) as max_era,
  max(if(event_name = "level_end", op_era, null)) as max_op_era,

  -- Game Economy Metrics
  countif(event_name in ("game_economy_source", "game_economy_sink")) as economy_transactions,
  sum(if(event_name = "game_economy_source", transaction, 0)) as economy_earned,
  sum(if(event_name = "game_economy_sink", abs(transaction), 0)) as economy_spent,
  countif(event_name = "game_economy_source") as economy_source_count,
  countif(event_name = "game_economy_sink") as economy_sink_count,
  {%- for currency in ['dollar', 'purple_gem', 'gold_coin', 'green_coin', 'energy', 'skill_token'] %}
  max(if(event_name in ("game_economy_source", "game_economy_sink"), {{ currency }}_balance, null)) as max_{{ currency }}_balance,
  {%- endfor %}

  -- Inventory and Progression Metrics
  countif(event_name = "inventory_chest_open") as chests_opened,
  countif(event_name = "inventory_levelup") as inventory_levelups,
  countif(event_name = "inventory_merge") as inventory_merges,
  countif(event_name = "skill_upgrade") as skill_upgrades,
  countif(event_name = "skill_pack_open") as skill_packs_opened,
  countif(event_name = "skill_token_exchange") as skill_token_exchanges,
  countif(event_name = "weapon_upgrade") as weapon_upgrades,
  countif(event_name = "weapon_skill_unlock") as weapon_skills_unlocked,
  countif(event_name = "weapon_attributes") as weapon_attributes_views,
  countif(event_name = "ulti_upgrade") as ulti_upgrades,
  countif(event_name = "ulti_triggered") as ulti_triggers,
  countif(event_name = "picked_skill") as skills_picked,
  countif(event_name = "evolve") as evolves,
  countif(event_name = "revive") as revives,
  countif(event_name = "travel") as travels,
  countif(event_name = "boss_fight") as boss_fights,
  countif(event_name = "boss_fight" and state = "win") as boss_wins,
  countif(event_name = "damage_taken") as damage_events,

  -- Screen Navigation Metrics
  countif(event_name = "open_screen") as screen_opens,
  countif(event_name = "screen_view") as screen_views,

  -- Skill Usage Metrics (from level_end events)
  {%- for skill in ['fireball', 'lightning', 'blackhole', 'meteor', 'hurricane', 'hook', 'ulti', 'rage', 'protectiveshield', 'frostpool', 'homingarrow', 'powerbeam', 'electrocute', 'spiketrail'] %}
  sum(if(event_name = "level_end", skill_{{ skill }}, 0)) as skill_{{ skill }}_uses,
  {%- endfor %}

  -- Level Progression
  min(if(event_name = "level_end", in_game_user_level, null)) as min_user_level,

  -- End of Day Currency Balances (last known balance of the day)
  {%- for currency in ['dollar', 'purple_gem', 'gold_coin', 'green_coin', 'energy', 'skill_token'] %}
  array_agg({{ currency }}_balance ignore nulls order by ts desc limit 1)[safe_offset(0)] as eod_{{ currency }}_balance,
  {%- endfor %}

from events.events
where user_id is not null --TODO: change to user_pseudo_id if needed
  and event_name not in ("app_remove", "os_update", "app_clear_data", "app_update", "app_exception")
  and dt between '{{ start_date }}' and '{{ end_date }}'
group by 1,2
