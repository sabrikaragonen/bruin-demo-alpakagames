# Alpaka Firebase Analytics Pipeline

This pipeline processes Firebase/GA4 events from the `alpaka03sept25` project and transforms them into structured analytics tables.

## Pipeline Overview

- **Start Date**: 2025-12-17
- **Schedule**: Daily
- **Data Source**: Firebase Analytics export to BigQuery (`analytics_504624180.events_*`)
- **Destination**: BigQuery datasets (`events`, `user_model`)

## Assets

### Events Layer
- `events.events_json` - Raw JSON extraction from Firebase events (partitioned by `event_date`)
- `events.events` - Structured view with all event parameters extracted and typed

### User Model Layer
- `user_model.users_daily` - Daily user-level metrics and dimensions (partitioned by `dt`, clustered by `user_id`)
- `user_model.users` - Lifetime user aggregations (clustered by `user_id`)

## Events Catalog

### Core Gameplay Events (Most Important)

#### `level_start`
- **Description**: Player starts a level
- **Key Parameters**: 
  - `game_level` (INT64)
  - `in_game_user_level` (INT64)
  - `era` (INT64)
  - `op_era` (INT64)
  - `universe` (INT64)
  - `match_id` (STRING)
  - `starting_hp` (FLOAT64)
  - `level_enemy_goal` (INT64)
  - Currency balances: `dollar_balance`, `purple_gem_balance`, `gold_coin_balance`, `green_coin_balance`, `energy_balance`, `skill_token_balance`

#### `level_end`
- **Description**: Player completes or fails a level
- **Key Parameters**: 
  - `level_result` (STRING) - "win" or "fail"
  - `game_duration` (FLOAT64)
  - `enemy_killed` (INT64)
  - `elite_killed` (INT64)
  - `in_game_user_level` (INT64)
  - `era` (INT64)
  - `op_era` (INT64)
  - `match_id` (STRING)
  - Skill usage counts: `BlackHole`, `Electrocute`, `Fireball`, `FrostPool`, `HomingArrow`, `Hook`, `Hurricane`, `Lightning`, `Meteor`, `PowerBeam`, `ProtectiveShield`, `Rage`, `SpikeTrail`, `Ulti` (all INT64)
  - Currency balances

#### `boss_fight`
- **Description**: Boss fight event
- **Key Parameters**: 
  - `state` (STRING) - "win" or "failed"
  - `elapsed_time` (FLOAT64)
  - `st1` through `st10` (various types) - Skill/timeline data

#### `damage_taken`
- **Description**: Player takes damage
- **Key Parameters**: 
  - `enemy_at_scene` (INT64)
  - `match_id` (STRING)
  - Currency balances

#### `evolve`
- **Description**: Player evolves character/item
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `revive`
- **Description**: Player revives
- **Key Parameters**: Currency balances

#### `travel`
- **Description**: Player travels between areas
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

### Monetization Events

#### `iap_complete_client`
- **Description**: IAP purchase completed on client
- **Key Parameters**: 
  - `productId` (STRING)
  - `adjust_token` (STRING)
  - `iso_currency_code` (STRING) - "USD" or "TRY"
  - `localized_price` (STRING)
  - `localized_price_string` (STRING)
  - `is_restored_for_free` (STRING)
  - `transaction_id` (STRING)

#### `iap_confirmed`
- **Description**: IAP purchase confirmed
- **Key Parameters**: `product_id` (STRING), `transaction_id` (STRING)

#### `iap_purchase_button_clicked`
- **Description**: IAP purchase button clicked
- **Key Parameters**: 
  - `productId` (STRING)
  - `st1` through `st4` (various types)

#### `iap_pending`
- **Description**: IAP purchase pending
- **Key Parameters**: `transaction_id` (STRING), `product_id` (STRING)

#### `iap_failed` / `iap_failed_client`
- **Description**: IAP purchase failed
- **Key Parameters**: 
  - `failedDetails` (STRING)
  - `failure_reason` (STRING)
  - `reason` (STRING)
  - `product_id` (STRING)
  - `transaction_id` (STRING)

#### `rewarded_paid`
- **Description**: Rewarded ad paid revenue event
- **Key Parameters**: 
  - `ad_format` (STRING) - "REWARDED"
  - `ad_type` (STRING) - "REWARDED"
  - `ad_id` (STRING)
  - `ad_unit_id` (STRING)
  - `ad_unit_identifier` (STRING)
  - `creative_id` (STRING)
  - `creative_identifier` (STRING)
  - `network_name` (STRING)
  - `network_placement` (STRING)
  - `dsp_name` (STRING)
  - `source` (STRING)
  - `revenue` (FLOAT64)
  - `revenue_precision` (STRING)
  - Currency balances

#### `inter_paid`
- **Description**: Interstitial ad paid revenue event
- **Key Parameters**: 
  - `ad_network` (STRING)
  - `ad_unit_identifier` (STRING)
  - `unit_id` (STRING)
  - `creative_identifier` (STRING)
  - `dsp_name` (STRING)
  - `revenue` (FLOAT64)
  - `revenue_precision` (STRING)

#### `rw_ready` / `rw_showed` / `rw_clicked` / `rw_completed` / `rw_recieved`
- **Description**: Rewarded ad lifecycle events
- **Key Parameters**: Similar to `rewarded_paid`:
  - `ad_id` (STRING)
  - `ad_unit_id` (STRING)
  - `creative_id` (STRING)
  - `network_name` (STRING)
  - `waterfall_info` (STRING)
  - `waterfall_name` (STRING)
  - `revenue` (FLOAT64)

#### `interstitial_ready` / `interstitial_showed` / `interstitial_clicked` / `interstitial_complete`
- **Description**: Interstitial ad lifecycle events
- **Key Parameters**: 
  - `ad_format` (STRING) - "INTER"
  - `ad_unit_id` (STRING)
  - `creative_id` (STRING)
  - `network_name` (STRING)
  - `revenue` (FLOAT64)
  - `game_level` (INT64)

#### `ad_reward`
- **Description**: Ad reward received
- **Key Parameters**: `reward_value` (INT64)

#### `ad_is_not_ready` / `rewarded_load_failed`
- **Description**: Ad errors/failures
- **Key Parameters**: `code` (STRING), `message` (STRING), `mediated_network_error_code` (INT64)

### Progression & Inventory Events

#### `level_start`
- **Description**: Player starts a level
- **Key Parameters**: 
  - `game_level` (INT64)
  - `in_game_user_level` (INT64)
  - `era` (INT64)
  - `op_era` (INT64)
  - `universe` (INT64)
  - `match_id` (STRING)
  - `starting_hp` (FLOAT64)
  - `level_enemy_goal` (INT64)
  - Currency balances: `dollar_balance`, `purple_gem_balance`, `gold_coin_balance`, `green_coin_balance`, `energy_balance`, `skill_token_balance`

#### `level_end`
- **Description**: Player completes or fails a level
- **Key Parameters**: 
  - `level_result` (STRING) - "win" or "fail"
  - `game_duration` (FLOAT64)
  - `enemy_killed` (INT64)
  - `elite_killed` (INT64)
  - `in_game_user_level` (INT64)
  - `era` (INT64)
  - `op_era` (INT64)
  - `match_id` (STRING)
  - Skill usage counts: `BlackHole`, `Electrocute`, `Fireball`, `FrostPool`, `HomingArrow`, `Hook`, `Hurricane`, `Lightning`, `Meteor`, `PowerBeam`, `ProtectiveShield`, `Rage`, `SpikeTrail`, `Ulti` (all INT64)
  - Currency balances

#### `boss_fight`
- **Description**: Boss fight event
- **Key Parameters**: 
  - `state` (STRING) - "win" or "failed"
  - `elapsed_time` (FLOAT64)
  - `st1` through `st10` (various types) - Skill/timeline data

#### `damage_taken`
- **Description**: Player takes damage
- **Key Parameters**: 
  - `enemy_at_scene` (INT64)
  - `match_id` (STRING)
  - Currency balances

#### `evolve`
- **Description**: Player evolves character/item
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `revive`
- **Description**: Player revives
- **Key Parameters**: Currency balances

#### `travel`
- **Description**: Player travels between areas
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `inventory_chest_open`
- **Description**: Player opens a chest
- **Key Parameters**: 
  - `chest_type` (STRING) - "regular" or "epic"
  - `item_name` (STRING)
  - `item_rank` (INT64)
  - `item_type` (STRING)
  - `open_type` (STRING) - "Ad", "Free", "Gem"
  - `upgrade_currency_amount` (INT64)
  - Currency balances

#### `inventory_levelup`
- **Description**: Inventory item leveled up
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `inventory_merge`
- **Description**: Items merged
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `skill_upgrade`
- **Description**: Skill upgraded
- **Key Parameters**: 
  - `cost` (INT64 or STRING)
  - `st1` through `st10` (various types)
  - Currency balances

#### `skill_pack_open`
- **Description**: Skill pack opened
- **Key Parameters**: 
  - `package_name` (STRING) - "Small" or "Large"
  - `cost` (INT64 or STRING)
  - `skill_5` (STRING)
  - `st1` through `st10` (STRING)
  - `purple_coin_balance` (INT64)
  - Currency balances

#### `skill_token_exchange`
- **Description**: Skill tokens exchanged
- **Key Parameters**: Currency balances, `skill_token_balance` (INT64)

#### `picked_skill`
- **Description**: Player picks a skill
- **Key Parameters**: Currency balances, `st1` through `st10`

#### `weapon_upgrade`
- **Description**: Weapon upgraded
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `weapon_skill_unlock`
- **Description**: Weapon skill unlocked
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `weapon_attributes`
- **Description**: Weapon attributes viewed
- **Key Parameters**: 
  - `synergy` (STRING) - e.g., "Execute", "UltiDoubleJump", "FreeSkill"
  - `match_id` (STRING)
  - Currency balances

#### `ulti_upgrade`
- **Description**: Ultimate ability upgraded
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `ulti_triggered`
- **Description**: Ultimate ability used
- **Key Parameters**: Currency balances, `era`, `op_era`, `universe`

#### `ulti_ready_button_click`
- **Description**: Ultimate ready button clicked
- **Key Parameters**: Currency balances

### Game Economy Events

#### `game_economy_source`
- **Description**: Currency earned
- **Key Parameters**: 
  - `transaction` (INT64)
  - `transaction_name` (STRING)
  - `type` (INT64)
  - `balance` (INT64)
  - `level_info` (STRING)
  - Currency balances: `dollar_balance`, `purple_gem_balance`, `gold_coin_balance`, `green_coin_balance`, `energy_balance`, `skill_token_balance`

#### `game_economy_sink`
- **Description**: Currency spent
- **Key Parameters**: Same as `game_economy_source`


### Screen Navigation Events

#### `open_screen` / `screen_opened`
- **Description**: Screen opened
- **Key Parameters**: 
  - `screen_name` (STRING) - e.g., "BattlePage", "SkillPage", "InventoryPage"
  - `source_screen_name` (STRING)
  - `user_level` (INT64)

#### `tap_on_locked_tab`
- **Description**: User tapped on locked tab
- **Key Parameters**: `st1` (various types)

#### `one_time_pack_clicked`
- **Description**: One-time purchase pack clicked
- **Key Parameters**: Currency balances

#### `user_false_click`
- **Description**: False click detected
- **Key Parameters**: Currency balances, `st1` through `st4`

### Session & App Lifecycle Events

#### `session_start` / `session_started`
- **Description**: Session begins
- **Key Parameters**: 
  - `ga_session_id` (INT64)
  - `ga_session_number` (INT64)
  - `session_engaged` (INT64)
  - `session_id` (STRING)

#### `session_ended` / `session_paused` / `session_resumed`
- **Description**: Session lifecycle events
- **Key Parameters**: `session_id` (STRING), `pause_duration` (FLOAT64)

#### `app_open` / `first_open`
- **Description**: App opened or first open
- **Key Parameters**: `ga_session_id` (INT64), `ga_session_number` (INT64)

#### `app_update` / `app_remove` / `app_exception` / `os_update`
- **Description**: App lifecycle and system events
- **Key Parameters**: `previous_app_version` (STRING), `previous_os_version` (STRING), `fatal` (INT64)

## Important Parameters by Category

### Currency Balances
Available on most gameplay events:
- `dollar_balance` (INT64)
- `purple_gem_balance` (INT64)
- `gold_coin_balance` (INT64)
- `green_coin_balance` (INT64)
- `energy_balance` (INT64)
- `skill_token_balance` (INT64)
- `gold_balance` (INT64)
- `purple_coin_balance` (INT64)

### Game Progression
- `era` (INT64) - Player era (0-4)
- `op_era` (INT64) - Opponent era (0-4)
- `universe` (INT64) - Universe identifier
- `in_game_user_level` (INT64) - User level in game
- `user_level` (INT64) - User level
- `game_level` (INT64) - Current game level
- `level_result` (STRING) - "win" or "fail"
- `level_enemy_goal` (INT64) - Enemy kill goal for level

### Skills
- `skill_5` (STRING) - Skill name
- `st1` through `st10` (various types) - Skill/timeline data
- Skill usage counts: `BlackHole`, `Electrocute`, `Fireball`, `FrostPool`, `HomingArrow`, `Hook`, `Hurricane`, `Lightning`, `Meteor`, `PowerBeam`, `ProtectiveShield`, `Rage`, `SpikeTrail`, `Ulti` (all INT64)

### Revenue
- `revenue` (FLOAT64) - Revenue amount
- `revenue_precision` (STRING) - "exact" or other
- `event_value_in_usd` (FLOAT64) - Event value in USD

### Device & Geo
Available as STRUCTs:
- `device.*` - Device information (advertising_id, mobile_brand_name, mobile_model_name, operating_system, etc.)
- `geo.*` - Geographic information (country, city, continent, region, etc.)
- `privacy_info.*` - Privacy settings (ads_storage, analytics_storage, uses_transient_token)

### Session & Firebase Parameters (Less Critical)
- `ga_session_id` (INT64) - GA4 session identifier
- `ga_session_number` (INT64) - Session number for user
- `engagement_time_msec` (INT64) - Engagement time in milliseconds
- `engaged_session_event` (INT64) - Whether session is engaged

## Running the Pipeline

### Full Pipeline Run
```bash
bruin run .
```

### Run Specific Date Range
```bash
bruin run . --start-date 2025-12-17 --end-date 2026-02-02
```

### Full Refresh (recreate tables)
```bash
bruin run . --full-refresh
```

### Validate Pipeline
```bash
bruin validate .
```

## Data Model

### events.events_json
- Partitioned by: `event_date`
- Source: `analytics_504624180.events_*` (date-sharded tables)
- Contains: Raw JSON strings for event_params, user_properties, device, geo, app_info

### events.events
- Type: View
- Source: `events.events_json`
- Contains: All event parameters extracted and typed

### user_model.users_daily
- Type: Table (incremental)
- Partitioned by: `dt`
- Clustered by: `user_id`
- Incremental key: `dt`
- Contains: Daily user-level aggregations

### user_model.users
- Type: Table (full refresh)
- Clustered by: `user_id`
- Contains: Lifetime user aggregations with retention metrics

## Notes

- All events exclude: `app_remove`, `os_update`, `app_clear_data`, `app_update`, `app_exception` from user metrics
- User identification uses `user_id` (can be changed to `user_pseudo_id` if needed)
- Session duration calculated using `timestamp_diff` between min and max timestamps
- Engagement defined as events excluding: `session_start`, `user_engagement`, `firebase_campaign`, `ad_reward`, `session_ping`
