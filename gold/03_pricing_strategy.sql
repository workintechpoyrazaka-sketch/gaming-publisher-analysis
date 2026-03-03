-- ============================================================
-- File: 03_pricing_strategy.sql
-- Layer: Gold
-- Purpose: Analyze publisher pricing strategies across platforms.
--          Segments publishers into price tiers (budget/mid/premium)
--          and compares pricing behavior per platform.
--          Answers: "How do publishers price differently across
--          platforms? Who charges premium vs budget?"
-- Depends on: silver_games_publishers_parsed
-- Creates: gold_pricing_strategy
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Only games with non-null USD prices included — null
--        means free-to-play or missing, not $0.
--        Price tiers: budget (<$10), mid ($10-30), premium (>$30).
--        Per-publisher-per-platform granularity so we can see
--        if a publisher prices differently on PS vs Steam vs Xbox.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_pricing_strategy` AS

WITH publisher_platform_pricing AS (
  -- Per publisher per platform: avg, median proxy, spread
  SELECT
    publisher,
    platform_group,
    COUNT(DISTINCT gameid) AS priced_game_count,
    ROUND(AVG(usd), 2) AS avg_usd,
    ROUND(MIN(usd), 2) AS min_usd,
    ROUND(MAX(usd), 2) AS max_usd,
    ROUND(MAX(usd) - MIN(usd), 2) AS price_range,
    -- Price tier distribution within this publisher-platform combo
    COUNTIF(usd < 10) AS budget_count,
    COUNTIF(usd >= 10 AND usd <= 30) AS mid_count,
    COUNTIF(usd > 30) AS premium_count
  FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
  WHERE usd IS NOT NULL
    AND publisher != 'unknown'
  GROUP BY publisher, platform_group
)

SELECT
  *,
  -- Dominant tier based on where most games fall
  CASE
    WHEN budget_count >= mid_count AND budget_count >= premium_count THEN 'budget'
    WHEN mid_count >= budget_count AND mid_count >= premium_count THEN 'mid-tier'
    WHEN premium_count >= budget_count AND premium_count >= mid_count THEN 'premium'
  END AS dominant_tier,
  -- Price consistency: does this publisher charge similar prices?
  CASE
    WHEN price_range <= 5 THEN 'tight'
    WHEN price_range <= 20 THEN 'moderate'
    ELSE 'wide'
  END AS price_spread
FROM publisher_platform_pricing
ORDER BY priced_game_count DESC;
