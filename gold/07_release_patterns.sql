-- ============================================================
-- File: 07_release_patterns.sql
-- Layer: Gold
-- Purpose: Analyze publisher release timing -- yearly output,
--          release acceleration/deceleration, and pricing trends
--          over time.
-- Depends on: silver_games_publishers_parsed, silver_master_publishers
-- Creates: gold_release_patterns
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Uses release_date year extraction. Games with null
--        release_date excluded. Grouped by publisher tier
--        for trend comparison. Only years 2000+ included.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_release_patterns` AS

WITH yearly_releases AS (
  SELECT
    publisher,
    platform_group,
    EXTRACT(YEAR FROM release_date) AS release_year,
    COUNT(DISTINCT gameid) AS games_released,
    ROUND(AVG(usd), 2) AS avg_usd_that_year
  FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
  WHERE release_date IS NOT NULL
    AND EXTRACT(YEAR FROM release_date) >= 2000
  GROUP BY publisher, platform_group, release_year
),

-- Add publisher tier for trend grouping
tiered_yearly AS (
  SELECT
    yr.*,
    CASE
      WHEN yr.publisher = 'unknown' THEN 'self-published'
      WHEN m.game_count >= 100 THEN 'major'
      WHEN m.game_count >= 10 THEN 'mid-tier'
      ELSE 'indie'
    END AS publisher_tier
  FROM yearly_releases yr
  JOIN `fast-archive-478610-v8.gaming_project.silver_master_publishers` m
    ON yr.publisher = m.publisher
)

SELECT * FROM tiered_yearly
ORDER BY release_year, publisher_tier, games_released DESC;
