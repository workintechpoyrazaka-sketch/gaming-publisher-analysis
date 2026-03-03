-- ============================================================
-- File: 06_publisher_dashboard.sql
-- Layer: Gold
-- Purpose: Comprehensive dashboard for top 20 publishers by
--          game count. All KPIs in one view.
-- Depends on: silver_master_publishers, silver_games_publishers_parsed,
--             gold_genre_specialization, gold_platform_strategy
-- Creates: gold_top20_dashboard
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Top 20 by game_count excluding unknown.
--        Pulls top genre from gold_genre_specialization.
--        One row = one publisher profile card for presentation.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_top20_dashboard` AS

WITH top20 AS (
  SELECT publisher, game_count
  FROM `fast-archive-478610-v8.gaming_project.silver_master_publishers`
  WHERE publisher != 'unknown'
  ORDER BY game_count DESC
  LIMIT 20
),

-- Per-platform game counts for each top 20 publisher
platform_detail AS (
  SELECT
    publisher,
    COUNTIF(platform_group = 'PS') AS ps_games,
    COUNTIF(platform_group = 'Steam') AS steam_games,
    COUNTIF(platform_group = 'Xbox') AS xbox_games
  FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
  WHERE publisher IN (SELECT publisher FROM top20)
  GROUP BY publisher
),

-- Top genre per publisher
top_genre AS (
  SELECT publisher, genre AS top_genre, genre_share_pct AS top_genre_pct
  FROM `fast-archive-478610-v8.gaming_project.gold_genre_specialization`
  WHERE genre_rank = 1
    AND publisher IN (SELECT publisher FROM top20)
)

SELECT
  m.publisher,
  m.game_count,
  m.platform_count,
  m.platforms,
  pd.ps_games,
  pd.steam_games,
  pd.xbox_games,
  m.avg_usd,
  m.min_usd,
  m.max_usd,
  tg.top_genre,
  tg.top_genre_pct,
  m.genre_count AS genre_combinations,
  m.earliest_release,
  m.latest_release,
  s.platform_strategy,
  CASE
    WHEN m.game_count >= 100 THEN 'major'
    WHEN m.game_count >= 10 THEN 'mid-tier'
    ELSE 'indie'
  END AS publisher_tier
FROM top20 t
JOIN `fast-archive-478610-v8.gaming_project.silver_master_publishers` m
  ON t.publisher = m.publisher
JOIN platform_detail pd
  ON t.publisher = pd.publisher
JOIN top_genre tg
  ON t.publisher = tg.publisher
JOIN `fast-archive-478610-v8.gaming_project.gold_platform_strategy` s
  ON t.publisher = s.publisher
ORDER BY m.game_count DESC;
