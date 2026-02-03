/* @bruin

name: events.events
type: bq.sql
materialization:
    type: view
description:
    The events table contains all events and parameters from the Firebase Analytics export.
    The underlying table is partitioned by date and clustered by event_name.
    This table is used for ad-hoc analysis and is not used for reporting.
depends:
  - events.events_json
@bruin */

select
  app,
  platform,
  dt,
  ts,
  user_first_touch_ts,
  user_pseudo_id,
  user_id,
  event_name,
  app_version,
  event_params,
  user_properties,
  if(array_length(experiments) > 0, (select json_object(array_agg(cast(e.id as string)), array_agg(cast(e.value as string))) from unnest(experiments) as e), JSON "{}") as experiments,
  struct(
    lax_string(device.advertising_id) as advertising_id,
    lax_string(device.browser) as browser,
    lax_string(device.browser_version) as browser_version,
    lax_string(device.category) as category,
    lax_bool(device.is_limited_ad_tracking) as is_limited_ad_tracking,
    lax_string(device.language) as language,
    lax_string(device.mobile_brand_name) as mobile_brand_name,
    lax_string(device.mobile_marketing_name) as mobile_marketing_name,
    lax_string(device.mobile_model_name) as mobile_model_name,
    lax_string(device.mobile_os_hardware_model) as mobile_os_hardware_model,
    lax_string(device.operating_system) as operating_system,
    lax_string(device.operating_system_version) as operating_system_version,
    lax_int64(device.time_zone_offset_seconds) / 3600 as time_zone_offset,
    lax_string(device.vendor_id) as vendor_id,
    lax_string(device.web_info) as web_info
  ) as device,
  struct(
    lax_string(geo.city) as city,
    lax_string(geo.continent) as continent,
    lax_string(geo.country) as country,
    lax_string(geo.metro) as metro,
    lax_string(geo.region) as region,
    lax_string(geo.sub_continent) as sub_continent
  ) as geo,
  struct(
    lax_string(privacy_info.ads_storage) as ads_storage,
    lax_string(privacy_info.analytics_storage) as analytics_storage,
    lax_string(privacy_info.uses_transient_token) as uses_transient_token
  ) as privacy_info,
  event_server_timestamp_offset,
  event_value_in_usd,

  -- FIREBASE
  lax_string(event_params.firebase_screen) as screen,
  lax_string(event_params.firebase_previous_screen) as previous_screen,
  lax_string(event_params.firebase_screen_class) as screen_class,
  lax_string(event_params.firebase_previous_class) as previous_screen_class,
  lax_int64(event_params.ga_session_id) as session_id,
  lax_int64(event_params.ga_session_number) as session_number,
  lax_int64(event_params.engaged_session_event) as engaged_session_event,
  lax_int64(event_params.engagement_time_msec) / 1000 as engagement_time_sec,
  lax_string(event_params.firebase_event_origin) as event_origin,
  lax_string(event_params.firebase_conversion) as firebase_conversion,
  lax_int64(event_params.entrances) as entrances,
  lax_int64(event_params.session_engaged) as session_engaged,
  lax_int64(event_params.previous_first_open_count) as previous_first_open_count,
  lax_int64(event_params.update_with_analytics) as update_with_analytics,
  lax_int64(event_params.system_app) as system_app,
  lax_int64(event_params.system_app_update) as system_app_update,
  lax_string(event_params.source) as source,
  lax_string(event_params.campaign_info_source) as campaign_info_source,
  lax_string(event_params.medium) as medium,
  lax_string(event_params.previous_app_version) as previous_app_version,
  lax_string(event_params.previous_os_version) as previous_os_version,
  lax_int64(event_params.firebase_error) as firebase_error,
  lax_int64(event_params.fatal) as fatal,
  lax_int64(event_params.timestamp) as timestamp,
  lax_string(event_params.error_value) as error_value,
  lax_string(event_params.term) as term,
  lax_int64(event_params.firebase_previous_id) as firebase_previous_id,
  lax_int64(event_params.firebase_screen_id) as firebase_screen_id,

  -- ADVERTISING
  lax_string(event_params.adUnitIdentifier) as ad_unit_identifier,
  lax_string(event_params.ad_format) as ad_format,
  lax_string(event_params.ad_id) as ad_id,
  lax_string(event_params.ad_network) as ad_network,
  lax_string(event_params.ad_type) as ad_type,
  lax_string(event_params.ad_unit_id) as ad_unit_id,
  lax_string(event_params.creative_id) as creative_id,
  lax_string(event_params.creative_identifier) as creative_identifier,
  lax_string(event_params.dsp_name) as dsp_name,
  lax_string(event_params.network) as network,
  lax_string(event_params.network_name) as network_name,
  lax_string(event_params.network_placement) as network_placement,
  lax_string(event_params.unit_id) as unit_id,
  lax_string(event_params.waterfall_info) as waterfall_info,
  lax_string(event_params.waterfall_name) as waterfall_name,
  lax_int64(event_params.mediated_network_error_code) as mediated_network_error_code,

  -- CAMPAIGN
  lax_string(event_params.campaign) as campaign,
  lax_string(event_params.campaign_id) as campaign_id,
  lax_string(event_params.content) as campaign_content,
  lax_int64(event_params.click_timestamp) as campaign_click_timestamp,

  -- GAME ECONOMY
  lax_int64(event_params.balance) as balance,
  lax_int64(event_params.dollar_balance) as dollar_balance,
  lax_int64(event_params.energy_balance) as energy_balance,
  lax_int64(event_params.gold_balance) as gold_balance,
  lax_int64(event_params.gold_coin_balance) as gold_coin_balance,
  lax_int64(event_params.green_coin_balance) as green_coin_balance,
  lax_int64(event_params.purple_coin_balance) as purple_coin_balance,
  lax_int64(event_params.purple_gem_balance) as purple_gem_balance,
  lax_int64(event_params.skill_token_balance) as skill_token_balance,
  lax_int64(event_params.transaction) as transaction,
  lax_string(event_params.transaction_name) as transaction_name,
  lax_int64(event_params.type) as transaction_type,
  lax_int64(event_params.cost) as cost,

  -- GAMEPLAY
  lax_float64(event_params.elapsed_time) as elapsed_time,
  lax_int64(event_params.elite_killed) as elite_killed,
  lax_int64(event_params.enemy_at_scene) as enemy_at_scene,
  lax_int64(event_params.enemy_killed) as enemy_killed,
  lax_int64(event_params.era) as era,
  lax_int64(event_params.op_era) as op_era,
  lax_int64(event_params.universe) as universe,
  lax_float64(event_params.game_duration) as game_duration,
  lax_int64(event_params.game_level) as game_level,
  lax_int64(event_params.in_game_user_level) as in_game_user_level,
  lax_int64(event_params.user_level) as user_level,
  lax_int64(event_params.level_enemy_goal) as level_enemy_goal,
  lax_string(event_params.level_info) as level_info,
  lax_string(event_params.level_result) as level_result,
  lax_string(event_params.match_id) as match_id,
  lax_float64(event_params.starting_hp) as starting_hp,
  lax_string(event_params.state) as state,

  -- INVENTORY
  lax_string(event_params.chest_type) as chest_type,
  lax_string(event_params.item_name) as item_name,
  lax_int64(event_params.item_rank) as item_rank,
  lax_string(event_params.item_type) as item_type,
  lax_string(event_params.open_type) as open_type,
  lax_int64(event_params.upgrade_currency_amount) as upgrade_currency_amount,

  -- IN-APP PURCHASE
  lax_string(event_params.adjust_token) as adjust_token,
  lax_string(event_params.failedDetails) as iap_failed_details,
  lax_string(event_params.failure_reason) as iap_failure_reason,
  lax_string(event_params.is_restored_for_free) as iap_is_restored_for_free,
  lax_string(event_params.iso_currency_code) as iap_iso_currency_code,
  lax_string(event_params.localized_price) as iap_localized_price,
  lax_string(event_params.localized_price_string) as iap_localized_price_string,
  lax_string(event_params.productId) as iap_product_id,
  lax_string(event_params.product_id) as iap_product_id_alt,
  lax_string(event_params.reason) as iap_reason,
  lax_string(event_params.transaction_id) as iap_transaction_id,

  -- REVENUE
  lax_float64(event_params.revenue) as revenue,
  lax_string(event_params.revenue_precision) as revenue_precision,

  -- REWARDS
  lax_int64(event_params.reward_value) as reward_value,

  -- SCREENS
  lax_string(event_params.screen_name) as screen_name,
  lax_string(event_params.source_screen_name) as source_screen_name,

  -- SESSION
  lax_string(event_params.session_id) as session_id_string,
  lax_float64(event_params.pause_duration) as pause_duration,

  -- SKILLS
  lax_string(event_params.skill_5) as skill_5,
  lax_string(event_params.st1) as st1,
  lax_string(event_params.st2) as st2,
  lax_string(event_params.st3) as st3,
  lax_string(event_params.st4) as st4,
  lax_string(event_params.st5) as st5,
  lax_string(event_params.st6) as st6,
  lax_string(event_params.st7) as st7,
  lax_string(event_params.st8) as st8,
  lax_string(event_params.st9) as st9,
  lax_string(event_params.st10) as st10,
  lax_int64(event_params.BlackHole) as skill_blackhole,
  lax_int64(event_params.Electrocute) as skill_electrocute,
  lax_int64(event_params.Fireball) as skill_fireball,
  lax_int64(event_params.FrostPool) as skill_frostpool,
  lax_int64(event_params.HomingArrow) as skill_homingarrow,
  lax_int64(event_params.Hook) as skill_hook,
  lax_int64(event_params.Hurricane) as skill_hurricane,
  lax_int64(event_params.Lightning) as skill_lightning,
  lax_int64(event_params.Meteor) as skill_meteor,
  lax_int64(event_params.PowerBeam) as skill_powerbeam,
  lax_int64(event_params.ProtectiveShield) as skill_protectiveshield,
  lax_int64(event_params.Rage) as skill_rage,
  lax_int64(event_params.SpikeTrail) as skill_spiketrail,
  lax_int64(event_params.Ulti) as skill_ulti,

  -- WEAPONS
  lax_string(event_params.synergy) as weapon_synergy,

  -- OTHER
  lax_string(event_params.code) as code,
  lax_string(event_params.message) as message,
  lax_string(event_params.package_name) as package_name,
  lax_string(event_params.status) as status

from `events.events_json` 
