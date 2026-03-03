-- ============================================================
-- File: 02_games_with_prices.sql
-- Layer: Silver
-- Purpose: Join unified games with latest price per game per
--          platform. Uses LEFT JOIN so games without price
--          records are kept (free-to-play or missing data).
-- Depends on: silver_unified_games, bronze_prices_ps,
--             bronze_prices_steam, bronze_prices_xbox
-- Creates: silver_games_with_prices
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Multiple price rows exist per game (price history).
--        We take only the most recent price per game per platform
--        using ROW_NUMBER partitioned by gameid.
--        PS sub-platforms (PS3/PS4/PS5/Vita) all map to one
--        price table — joined via platform_group.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.silver_games_with_prices` AS

-- Step 1: UNION ALL price tables with platform group tags
WITH all_prices AS (
  SELECT gameid, date_acquired, usd, eur, gbp, jpy, rub,
         'PS' AS platform_group
  FROM `fast-archive-478610-v8.gaming_project.bronze_prices_ps`
  UNION ALL
  SELECT gameid, date_acquired, usd, eur, gbp, jpy, rub,
         'Steam' AS platform_group
  FROM `fast-archive-478610-v8.gaming_project.bronze_prices_steam`
  UNION ALL
  SELECT gameid, date_acquired, usd, eur, gbp, jpy, rub,
         'Xbox' AS platform_group
  FROM `fast-archive-478610-v8.gaming_project.bronze_prices_xbox`
),

-- Step 2: Keep only the latest price per game per platform
latest_prices AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY gameid, platform_group
      ORDER BY date_acquired DESC
    ) AS price_rank
  FROM all_prices
),

ranked_prices AS (
  SELECT * EXCEPT(price_rank)
  FROM latest_prices
  WHERE price_rank = 1
),

-- Step 3: Add platform_group to unified games for join key
games_with_group AS (
  SELECT *,
    CASE
      WHEN platform IN ('PS3', 'PS4', 'PS5', 'PS Vita') THEN 'PS'
      ELSE platform  -- Steam, Xbox already match
    END AS platform_group
  FROM `fast-archive-478610-v8.gaming_project.silver_unified_games`
)

-- Step 4: LEFT JOIN — keep all games even without prices
SELECT
  g.gameid,
  g.title,
  g.publishers,
  g.developers,
  g.genres,
  g.release_date,
  g.platform,
  g.platform_group,
  p.date_acquired AS price_date,
  p.usd,
  p.eur,
  p.gbp,
  p.jpy,
  p.rub
FROM games_with_group g
LEFT JOIN ranked_prices p
  ON g.gameid = p.gameid
  AND g.platform_group = p.platform_group;
