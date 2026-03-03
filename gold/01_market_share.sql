-- ============================================================
-- File: 01_market_share.sql
-- Layer: Gold
-- Purpose: Publisher market share by platform — game count,
--          percentage of platform total, and rank within platform.
--          Answers: "Who dominates where, and by how much?"
-- Depends on: silver_games_publishers_parsed
-- Creates: gold_market_share
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Uses platform_group (PS/Steam/Xbox) not sub-platforms.
--        Share calculated as publisher's games / platform total.
--        Unknown publishers included — they represent indie/
--        self-published market share (significant on Steam).
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_market_share` AS

WITH publisher_platform_counts AS (
  -- Count distinct games per publisher per platform
  SELECT
    publisher,
    platform_group,
    COUNT(DISTINCT gameid) AS game_count
  FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
  GROUP BY publisher, platform_group
),

platform_totals AS (
  -- Total distinct games per platform (denominator for share)
  SELECT
    platform_group,
    COUNT(DISTINCT gameid) AS platform_total
  FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
  GROUP BY platform_group
)

SELECT
  ppc.publisher,
  ppc.platform_group,
  ppc.game_count,
  pt.platform_total,
  ROUND(ppc.game_count * 100.0 / pt.platform_total, 4) AS market_share_pct,
  RANK() OVER (
    PARTITION BY ppc.platform_group
    ORDER BY ppc.game_count DESC
  ) AS platform_rank
FROM publisher_platform_counts ppc
JOIN platform_totals pt
  ON ppc.platform_group = pt.platform_group
ORDER BY ppc.platform_group, platform_rank;
