-- ============================================================
-- File: 01_type_conversions.sql
-- Layer: Bronze
-- Purpose: Convert raw CSV types to consistent BigQuery types
--          across all platform tables (PS, Steam, Xbox)
-- Depends on: raw_games_ps, raw_games_steam, raw_games_xbox,
--             raw_prices_ps, raw_prices_steam, raw_prices_xbox
-- Creates: bronze_games_ps, bronze_games_steam, bronze_games_xbox,
--          bronze_prices_ps, bronze_prices_steam, bronze_prices_xbox
-- Author: Poi
-- Date: 2026-03-02
-- Notes: BigQuery auto-detected most types on upload. Only two
--        columns need explicit casting:
--          - raw_games_ps.gameid: STRING → INT64
--          - raw_prices_xbox.jpy: STRING → FLOAT64
--        All other columns pass through as-is with correct types.
-- ============================================================


-- ============================================================
-- GAMES TABLES
-- ============================================================

-- PS Games: gameid uploaded as STRING — cast to INT64 for join consistency
CREATE OR REPLACE TABLE `gaming_project.bronze_games_ps` AS
SELECT
  CAST(gameid AS INT64)  AS gameid,   -- only games table where gameid is STRING
  title,
  platform,                           -- PS-only column: PS3, PS4, PS5, PS Vita
  developers,
  publishers,
  genres,
  supported_languages,
  release_date                        -- already DATE
FROM `gaming_project.raw_games_ps`
WHERE SAFE_CAST(gameid AS INT64) IS NOT NULL;  -- 1 row had CSV parse error (title with quotes shifted into gameid column)


-- Steam Games: all types already correct from auto-detect
CREATE OR REPLACE TABLE `gaming_project.bronze_games_steam` AS
SELECT
  gameid,                             -- already INT64
  title,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date                        -- already DATE
FROM `gaming_project.raw_games_steam`;


-- Xbox Games: all types already correct from auto-detect
CREATE OR REPLACE TABLE `gaming_project.bronze_games_xbox` AS
SELECT
  gameid,                             -- already INT64
  title,
  developers,
  publishers,
  genres,
  supported_languages,
  release_date                        -- already DATE
FROM `gaming_project.raw_games_xbox`;


-- ============================================================
-- PRICE TABLES
-- ============================================================

-- PS Prices: all types already correct
CREATE OR REPLACE TABLE `gaming_project.bronze_prices_ps` AS
SELECT
  gameid,                             -- already INT64
  usd,                                -- already FLOAT64
  eur,                                -- already FLOAT64
  gbp,                                -- already FLOAT64
  jpy,                                -- already FLOAT64
  rub,                                -- already FLOAT64
  date_acquired                       -- already DATE
FROM `gaming_project.raw_prices_ps`;


-- Steam Prices: all types already correct
CREATE OR REPLACE TABLE `gaming_project.bronze_prices_steam` AS
SELECT
  gameid,                             -- already INT64
  usd,                                -- already FLOAT64
  eur,                                -- already FLOAT64
  gbp,                                -- already FLOAT64
  jpy,                                -- already FLOAT64
  rub,                                -- already FLOAT64
  date_acquired                       -- already DATE
FROM `gaming_project.raw_prices_steam`;


-- Xbox Prices: jpy uploaded as STRING — cast to FLOAT64
CREATE OR REPLACE TABLE `gaming_project.bronze_prices_xbox` AS
SELECT
  gameid,                             -- already INT64
  usd,                                -- already FLOAT64
  eur,                                -- already FLOAT64
  gbp,                                -- already FLOAT64
  SAFE_CAST(jpy AS FLOAT64) AS jpy,  -- STRING → FLOAT64 (100% null, kept for schema consistency)
  rub,                                -- already FLOAT64
  date_acquired                       -- already DATE
FROM `gaming_project.raw_prices_xbox`;
