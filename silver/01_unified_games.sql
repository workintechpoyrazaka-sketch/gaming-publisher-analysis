-- ============================================================
-- File: 01_unified_games.sql
-- Layer: Silver
-- Purpose: Unify all three platform game tables into one table
--          with a platform identifier column
-- Depends on: bronze_games_ps, bronze_games_steam, bronze_games_xbox
-- Creates: silver_unified_games
-- Author: Poi
-- Date: 2026-03-03
-- Notes: PS has a native 'platform' column (PS3/PS4/PS5/Vita).
--        Steam and Xbox get a single platform tag.
--        Publisher/developer list strings left unparsed here.
--        Parsing happens in 03_publisher_parsed.sql after joins.
--        Column set narrowed to fields needed for publisher analysis.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.silver_unified_games` AS

WITH ps_games AS (
  SELECT
    gameid,
    title,
    publishers,
    developers,
    genres,
    release_date,
    platform  -- native column: PS3, PS4, PS5, PS Vita
  FROM `fast-archive-478610-v8.gaming_project.bronze_games_ps`
),

steam_games AS (
  SELECT
    gameid,
    title,
    publishers,
    developers,
    genres,
    release_date,
    'Steam' AS platform
  FROM `fast-archive-478610-v8.gaming_project.bronze_games_steam`
),

xbox_games AS (
  SELECT
    gameid,
    title,
    publishers,
    developers,
    genres,
    release_date,
    'Xbox' AS platform
  FROM `fast-archive-478610-v8.gaming_project.bronze_games_xbox`
)

SELECT * FROM ps_games
UNION ALL
SELECT * FROM steam_games
UNION ALL
SELECT * FROM xbox_games;
