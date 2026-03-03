-- ============================================================
-- File: 04_master_publishers.sql
-- Layer: Silver
-- Purpose: Publisher-level aggregation table for publisher
--          dominance, pricing strategy, and genre analysis.
-- Depends on: silver_games_publishers_parsed
-- Creates: silver_master_publishers
-- Author: Poi
-- Date: 2026-03-03
-- Notes: One row per publisher. Multi-publisher games already
--        exploded in parsed table, so a game with 2 publishers
--        counts once for each. 'unknown' = NULL/empty in source.
--        genre_count uses raw genre strings (list format).
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.silver_master_publishers` AS

SELECT
  publisher,
  COUNT(DISTINCT gameid) AS game_count,
  COUNT(DISTINCT platform_group) AS platform_count,
  STRING_AGG(DISTINCT platform_group, ', ' ORDER BY platform_group) AS platforms,
  ROUND(AVG(usd), 2) AS avg_usd,
  ROUND(MIN(usd), 2) AS min_usd,
  ROUND(MAX(usd), 2) AS max_usd,
  COUNT(DISTINCT genres) AS genre_count,
  MIN(release_date) AS earliest_release,
  MAX(release_date) AS latest_release,
  CASE WHEN publisher = 'unknown' THEN TRUE ELSE FALSE END AS is_unknown
FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
GROUP BY publisher;
