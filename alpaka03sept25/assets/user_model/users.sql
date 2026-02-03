/* @bruin

name: user_model.users
type: bq.sql
materialization:
  type: table
  strategy: create+replace
  cluster_by: 
    - user_id

depends:
  - user_model.users_daily

description:
  The users table contains user-level metrics and dimensions.
  The underlying table is clustered by user_id.
  This table is used for reporting and ad-hoc analysis.

columns:
  - name: user_id
    type: STRING
    description: The user ID
    primary_key: true

@bruin */

WITH
t1 as 
( 
  SELECT
    user_id,
    min(dt) as install_dt,

    min_by(platform, dt) as platform,
    max_by(platform, dt) as last_platform,
    array_agg(daily_first_app_version ignore nulls order by dt limit 1)[safe_offset(0)] as first_app_version,
    array_agg(daily_last_app_version ignore nulls order by dt desc limit 1)[safe_offset(0)] as last_app_version,
    array_agg(daily_first_country ignore nulls order by dt limit 1)[safe_offset(0)] as first_country,
    array_agg(daily_last_country ignore nulls order by dt desc limit 1)[safe_offset(0)] as last_country,
    coalesce(array_agg(daily_first_device_brand ignore nulls order by dt limit 1)[safe_offset(0)], 'unknown') as first_device_brand,
    coalesce(array_agg(daily_last_device_brand ignore nulls order by dt desc limit 1)[safe_offset(0)], 'unknown') as last_device_brand,
    coalesce(array_agg(daily_first_device_model ignore nulls order by dt limit 1)[safe_offset(0)], 'unknown') as first_device_model,
    coalesce(array_agg(daily_last_device_model ignore nulls order by dt desc limit 1)[safe_offset(0)], 'unknown') as last_device_model,
    coalesce(array_agg(daily_first_device_language ignore nulls order by dt limit 1)[safe_offset(0)], 'unknown') as first_device_language,
    coalesce(array_agg(daily_last_device_language ignore nulls order by dt desc limit 1)[safe_offset(0)], 'unknown') as last_device_language,
    array_agg(daily_first_os_version ignore nulls order by dt limit 1)[safe_offset(0)] as first_os_version,
    array_agg(daily_last_os_version ignore nulls order by dt desc limit 1)[safe_offset(0)] as last_os_version,
    array_agg(daily_first_event ignore nulls order by dt limit 1)[safe_offset(0)] as first_event,
    array_agg(daily_last_event ignore nulls order by dt desc limit 1)[safe_offset(0)] as last_event,
    
    sum(events) as events,
    array_agg(dt order by dt) as active_dates,
    array_agg(case when engaged then dt end ignore nulls order by dt) as active_dates_engaged,
    min(min_session_number) as min_session_number,
    max(max_session_number) as max_session_number,
    sum(session_starts) as session_starts,
    sum(session_duration_sec) as session_duration_sec,
    sum(total_engagement_time_sec) as total_engagement_time_sec,

    min(min_ts) as min_ts,
    max(max_ts) as max_ts,

    -- REVENUE
    sum(ad_imp_cnt) as ad_imp_cnt,
    sum(inters) as inters,
    sum(rewardeds) as rewardeds,
    sum(ad_shows) as ad_shows,
    sum(ad_rev) as ad_rev,
    sum(inter_rev) as inter_rev,
    sum(rewarded_rev) as rewarded_rev,
    sum(transactions) as transactions,
    sum(iap_rev) as iap_rev,
    sum(total_rev) as total_rev,

    -- GAMEPLAY METRICS
    sum(level_starts) as level_starts,
    sum(level_ends) as level_ends,
    sum(level_wins) as level_wins,
    sum(level_fails) as level_fails,
    sum(total_level_duration_sec) as total_level_duration_sec,
    sum(total_enemies_killed) as total_enemies_killed,
    sum(total_elites_killed) as total_elites_killed,
    max(max_user_level) as max_user_level,
    max(max_era) as max_era,
    max(max_op_era) as max_op_era,

    -- GAME ECONOMY METRICS
    sum(economy_transactions) as economy_transactions,
    sum(economy_earned) as economy_earned,
    sum(economy_spent) as economy_spent,
    sum(economy_source_count) as economy_source_count,
    sum(economy_sink_count) as economy_sink_count,
    {%- for currency in ['dollar', 'purple_gem', 'gold_coin', 'green_coin', 'energy', 'skill_token'] %}
    max(max_{{ currency }}_balance) as max_{{ currency }}_balance,
    {%- endfor %}

    -- INVENTORY AND PROGRESSION METRICS
    sum(chests_opened) as chests_opened,
    sum(inventory_levelups) as inventory_levelups,
    sum(inventory_merges) as inventory_merges,
    sum(skill_upgrades) as skill_upgrades,
    sum(skill_packs_opened) as skill_packs_opened,
    sum(skill_token_exchanges) as skill_token_exchanges,
    sum(weapon_upgrades) as weapon_upgrades,
    sum(weapon_skills_unlocked) as weapon_skills_unlocked,
    sum(weapon_attributes_views) as weapon_attributes_views,
    sum(ulti_upgrades) as ulti_upgrades,
    sum(ulti_triggers) as ulti_triggers,
    sum(skills_picked) as skills_picked,
    sum(evolves) as evolves,
    sum(revives) as revives,
    sum(travels) as travels,
    sum(boss_fights) as boss_fights,
    sum(boss_wins) as boss_wins,
    sum(damage_events) as damage_events,

    -- SCREEN NAVIGATION METRICS
    sum(screen_opens) as screen_opens,
    sum(screen_views) as screen_views,

    -- SKILL USAGE METRICS
    {%- for skill in ['fireball', 'lightning', 'blackhole', 'meteor', 'hurricane', 'hook', 'ulti', 'rage', 'protectiveshield', 'frostpool', 'homingarrow', 'powerbeam', 'electrocute', 'spiketrail'] %}
    sum(skill_{{ skill }}_uses) as skill_{{ skill }}_uses,
    {%- endfor %}

    -- MONETIZATION DATES
    min(if(transactions > 0, dt, null)) as first_iap_dt,
    min(if(rewardeds > 0, dt, null)) as first_rewarded_ad_dt,

    -- LEVEL PROGRESSION DATES
    min(if(level_wins > 0, dt, null)) as first_level_win_dt,

    -- ACTIVITY DATES
    max(dt) as last_active_dt,

    -- LAST KNOWN CURRENCY BALANCES (from last active day)
    {%- for currency in ['dollar', 'purple_gem', 'gold_coin', 'green_coin', 'energy', 'skill_token'] %}
    array_agg(eod_{{ currency }}_balance ignore nulls order by dt desc limit 1)[safe_offset(0)] as last_{{ currency }}_balance,
    {%- endfor %}

    -- DAILY METRICS ARRAY (for cohorted analysis)
    array_agg(struct(
      dt,
      session_starts,
      total_engagement_time_sec,
      ad_shows,
      ad_rev,
      transactions,
      iap_rev,
      total_rev,
      level_starts,
      level_ends,
      level_wins,
      level_fails
    ) order by dt) as daily_metrics,
 
  from `user_model.users_daily`
  group by 1
),

-- Calculate favorite skill and skill diversity
{%- set skills = ['fireball', 'lightning', 'blackhole', 'meteor', 'hurricane', 'hook', 'ulti', 'rage', 'protectiveshield', 'frostpool', 'homingarrow', 'powerbeam', 'electrocute', 'spiketrail'] %}
t2 as (
  select 
    *,
    -- Favorite skill (most used)
    case greatest(
      {%- for skill in skills %}
      skill_{{ skill }}_uses{{ "," if not loop.last else "" }}
      {%- endfor %}
    )
      {%- for skill in skills %}
      when skill_{{ skill }}_uses then '{{ skill }}'
      {%- endfor %}
      else null
    end as favorite_skill,
    -- Skill diversity (count of skills used at least once)
    (
      {%- for skill in skills %}
      if(skill_{{ skill }}_uses > 0, 1, 0){{ " + " if not loop.last else "" }}
      {%- endfor %}
    ) as skill_diversity
  from t1
)
select * except(daily_metrics),

  -- RETENTION METRICS (cohorted)
  {%- for day_n in (range(1,8)|list) + [14,21,28,30,60,90] %}
  case 
    when install_dt < current_date - {{ day_n }} 
    then coalesce((select 1 from unnest(daily_metrics) where dt = install_dt + {{ day_n }}), 0)
  end as ret_d{{ day_n }},
  {%- endfor %}

  -- CUMULATIVE COHORTED METRICS
  {%- for day_n in (range(0,8)|list) + [14,21,28,30,60,90] %}
  {%- for metric in ['session_starts', 'total_engagement_time_sec', 'ad_shows', 'ad_rev', 'transactions', 'iap_rev', 'total_rev', 'level_starts', 'level_ends', 'level_wins', 'level_fails'] %}
  case when install_dt < current_date - {{ day_n }} then coalesce((select sum({{ metric }}) from unnest(daily_metrics) where dt <= install_dt + {{ day_n }}), 0) end as {{ metric }}_d{{ day_n }},
  {%- endfor %}
  {%- endfor %}

from t2
