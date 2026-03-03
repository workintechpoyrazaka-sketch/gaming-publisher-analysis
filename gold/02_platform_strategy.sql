-- ============================================================
-- File: 02_platform_strategy.sql
-- Layer: Gold
-- Purpose: Segment publishers by platform strategy — single-platform
--          vs multi-platform. Compares size, pricing, and genre
--          diversity across strategy types.
--          Answers: "Do multi-platform publishers outperform
--          single-platform ones? Where do single-platform
--          publishers concentrate?"
-- Depends on: silver_master_publishers
-- Creates: gold_platform_strategy
-- Author: Poi
-- Date: 2026-03-03
-- Notes: platform_count from silver_master_publishers (1/2/3).
--        Strategy labels: single-platform, dual-platform, tri-platform.
--        'unknown' excluded — no meaningful platform strategy signal.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_platform_strategy` AS

WITH strategy_labeled AS (
  SELECT
    publisher,
    game_count,
    platform_count,
    platforms,
    avg_usd,
    genre_count,
    CASE
      WHEN platform_count = 1 THEN 'single-platform'
      WHEN platform_count = 2 THEN 'dual-platform'
      WHEN platform_count = 3 THEN 'tri-platform'
    END AS platform_strategy
  FROM `fast-archive-478610-v8.gaming_project.silver_master_publishers`
  WHERE publisher != 'unknown'
)

SELECT
  s.*,
  -- Rank within strategy group by game count
  RANK() OVER (
    PARTITION BY platform_strategy
    ORDER BY game_count DESC
  ) AS strategy_rank
FROM strategy_labeled s
ORDER BY platform_count DESC, game_count DESC;
