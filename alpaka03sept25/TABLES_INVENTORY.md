# BigQuery Tables Inventory

This document lists all tables found in BigQuery and their corresponding assets in the repository.

## Tables by Dataset

### analytics_504624180

#### Source Tables (Firebase Export)
- `events_YYYYMMDD` - Date-sharded Firebase events tables (source data, not assets)
- `events_intraday_YYYYMMDD` - Intraday Firebase events tables (source data, not assets)

#### Analytics Tables

| Table Name | Asset File | Type | Status |
|------------|-----------|------|--------|
| `bi_retention_with_session_info` | `bi_retention_with_session_info.asset.yml` | bq.source | ✅ Exists |
| `currency_exchange_rates` | `currency_exchange_rates.asset.yml` | bq.source | ✅ **Created** |
| `events` | `events.asset.yml` | bq.source | ✅ Exists |
| `ga4_Audiences_504624180` | `ga4_audiences.sql` | bq.sql (view) | ✅ Exists |
| `ga4_DemographicDetails_504624180` | `ga4_demographic_details.sql` | bq.sql (view) | ✅ Exists |
| `ga4_EcommercePurchases_504624180` | `ga4_ecommerce_purchases.sql` | bq.sql (view) | ✅ Exists |
| `ga4_Events_504624180` | `ga4_events.sql` | bq.sql (view) | ✅ Exists |
| `ga4_LandingPage_504624180` | `ga4_landing_page.sql` | bq.sql (view) | ✅ Exists |
| `ga4_PagesAndScreens_504624180` | `ga4_pages_and_screens.sql` | bq.sql (view) | ✅ Exists |
| `ga4_Promotions_504624180` | `ga4_promotions.sql` | bq.sql (view) | ✅ Exists |
| `ga4_TechDetails_504624180` | `ga4_tech_details.sql` | bq.sql (view) | ✅ Exists |
| `ga4_TrafficAcquisition_504624180` | `ga4_traffic_acquisition.sql` | bq.sql (view) | ✅ Exists |
| `ga4_UserAcquisition_504624180` | `ga4_user_acquisition.sql` | bq.sql (view) | ✅ Exists |
| `game_economy` | `game_economy.asset.yml` | bq.source | ✅ Exists |
| `level_funnel` | `level_funnel.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_Audiences_504624180` | `p_ga4_audiences_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_DemographicDetails_504624180` | `p_ga4_demographicdetails_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_EcommercePurchases_504624180` | `p_ga4_ecommercepurchases_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_Events_504624180` | `p_ga4_events_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_LandingPage_504624180` | `p_ga4_landingpage_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_PagesAndScreens_504624180` | `p_ga4_pagesandscreens_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_Promotions_504624180` | `p_ga4_promotions_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_TechDetails_504624180` | `p_ga4_techdetails_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_TrafficAcquisition_504624180` | `p_ga4_trafficacquisition_504624180.asset.yml` | bq.source | ✅ Exists |
| `p_ga4_UserAcquisition_504624180` | `p_ga4_useracquisition_504624180.asset.yml` | bq.source | ✅ Exists |
| `revenue_table` | `revenue_table.sql` | bq.sql (table) | ✅ **Created** |
| `users` | `users.asset.yml` | bq.source | ✅ Exists |
| `users_daily` | `users_daily.asset.yml` | bq.source | ✅ Exists |

### events

| Table Name | Asset File | Type | Status |
|------------|-----------|------|--------|
| `events` | `events.sql` | bq.sql (view) | ✅ Exists |
| `events_json` | `events_json.sql` | bq.sql (table) | ✅ Exists |
| `test` | N/A | Unknown | ⚠️ Test table, may be temporary |

### user_model

| Table Name | Asset File | Type | Status |
|------------|-----------|------|--------|
| `users` | `users.sql` | bq.sql (table) | ✅ Exists |
| `users_daily` | `users_daily.sql` | bq.sql (table) | ✅ Exists |

## Newly Created Assets

### currency_exchange_rates.asset.yml
- **Type**: bq.source (external reference table)
- **Description**: Currency exchange rates reference table with daily rates for various currencies
- **Location**: `assets/analytics_504624180/currency_exchange_rates.asset.yml`
- **Note**: This appears to be loaded from an external source (exchange rate API) based on the `loaded_at` timestamp

### revenue_table.sql
- **Type**: bq.sql (derived table)
- **Description**: Revenue aggregation table combining revenue events with user install attributes
- **Location**: `assets/analytics_504624180/revenue_table.sql`
- **Dependencies**: `events.events`, `user_model.users`
- **Note**: SQL query inferred from table structure. May need adjustment based on actual source query.

## Query History

Attempted to retrieve creation queries from BigQuery query history but:
- Query history access via `INFORMATION_SCHEMA.JOBS_BY_PROJECT` returned no results
- This could be due to:
  - Tables created outside the 90-day query history window
  - Tables created via DDL statements or external tools
  - Permission limitations

## Recommendations

1. **currency_exchange_rates**: Verify the data source and update mechanism. If it's loaded from an external API, consider creating an ingestion asset.

2. **revenue_table**: The SQL query was inferred from table structure. Review and adjust if needed:
   - Verify join logic with `user_model.users`
   - Confirm currency conversion logic
   - Check if `network_name` mapping is correct for IAP events

3. **events.test**: Investigate if this is a temporary test table that should be removed or if it needs an asset.

4. **Query History**: For future tables, consider:
   - Documenting creation queries in code comments
   - Storing DDL statements in version control
   - Using Bruin assets from the start instead of manual table creation
