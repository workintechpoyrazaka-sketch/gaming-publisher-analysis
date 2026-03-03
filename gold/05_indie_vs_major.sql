-- ============================================================
-- File: 05_indie_vs_major.sql
-- Layer: Gold
-- Purpose: Compare indie vs major publishers across survival
--          metrics, pricing gaps, platform dependency, and
--          genre choices.
-- Depends on: silver_master_publishers, silver_games_publishers_parsed
-- Creates: gold_indie_vs_major
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Publisher tiers defined by game_count thresholds:
--        major (100+), mid-tier (10-99), indie (1-9).
--        Data-driven proxy - no external publisher classification.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_indie_vs_major` AS

WITH tiered AS (
  SELECT
    publisher,
    game_count,
    platform_count,
    platforms,
    avg_usd,
    genre_count,
    CASE
      WHEN publisher = 'unknown' THEN 'self-published'
      WHEN game_count >= 100 THEN 'major'
      WHEN game_count >= 10 THEN 'mid-tier'
      ELSE 'indie'
    END AS publisher_tier
  FROM `fast-archive-478610-v8.gaming_project.silver_master_publishers`
),

-- Platform dependency: what pct of each tier games are on each platform
platform_breakdown AS (
  SELECT
    t.publisher_tier,
    p.platform_group,
    COUNT(DISTINCT p.gameid) AS games_on_platform
  FROM tiered t
  JOIN `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed` p
    ON t.publisher = p.publisher
  GROUP BY t.publisher_tier, p.platform_group
)

-- Main output: tier-level summary
SELECT
  publisher_tier,
  COUNT(*) AS publisher_count,
  SUM(game_count) AS total_games,
  ROUND(AVG(game_count), 1) AS avg_games_per_publisher,
  ROUND(AVG(avg_usd), 2) AS avg_price_usd,
  ROUND(AVG(platform_count), 2) AS avg_platform_count,
  ROUND(AVG(genre_count), 1) AS avg_genre_diversity,
  ROUND(COUNTIF(platform_count = 1) * 100.0 / COUNT(*), 1)
    AS pct_single_platform
FROM tiered
GROUP BY publisher_tier
ORDER BY
  CASE publisher_tier
    WHEN 'major' THEN 1
    WHEN 'mid-tier' THEN 2
    WHEN 'indie' THEN 3
    WHEN 'self-published' THEN 4
  END;
