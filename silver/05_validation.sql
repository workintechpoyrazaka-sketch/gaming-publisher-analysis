-- ============================================================
-- File: 05_validation.sql
-- Layer: Silver
-- Purpose: Validate Silver layer tables for data integrity,
--          row count consistency, and parsing quality.
-- Depends on: silver_unified_games, silver_games_with_prices,
--             silver_games_publishers_parsed, silver_master_publishers
-- Creates: N/A (validation queries only)
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Run these queries after building each Silver table.
--        Expected results documented inline.
-- ============================================================


-- ============================================================
-- CHECK 1: Row count pipeline — numbers should be consistent
-- Expected: unified=131884, with_prices=131884, parsed>131884
-- ============================================================

SELECT 'unified_games' AS source, COUNT(*) AS rows
FROM `fast-archive-478610-v8.gaming_project.silver_unified_games`
UNION ALL
SELECT 'games_with_prices', COUNT(*)
FROM `fast-archive-478610-v8.gaming_project.silver_games_with_prices`
UNION ALL
SELECT 'publishers_parsed', COUNT(*)
FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
UNION ALL
SELECT 'master_publishers', COUNT(*)
FROM `fast-archive-478610-v8.gaming_project.silver_master_publishers`
UNION ALL
SELECT 'null_publishers (unknown)', COUNT(*)
FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
WHERE publisher = 'unknown'
UNION ALL
SELECT 'multi_publisher_extra_rows', COUNT(*) - COUNT(DISTINCT gameid)
FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`;


-- ============================================================
-- CHECK 2: Publisher tier distribution — market concentration
-- Shows the long tail: most publishers have 1 game
-- ============================================================

SELECT
  CASE
    WHEN game_count >= 100 THEN '100+ games'
    WHEN game_count >= 50 THEN '50-99 games'
    WHEN game_count >= 10 THEN '10-49 games'
    WHEN game_count >= 2 THEN '2-9 games'
    ELSE '1 game only'
  END AS publisher_tier,
  COUNT(*) AS publishers,
  SUM(game_count) AS total_games
FROM `fast-archive-478610-v8.gaming_project.silver_master_publishers`
WHERE publisher != 'unknown'
GROUP BY publisher_tier
ORDER BY MIN(game_count) DESC;


-- ============================================================
-- CHECK 3: Top 10 publishers — sanity check on known names
-- EA, Ubisoft, Sega should appear with 3 platforms
-- ============================================================

SELECT publisher, game_count, platform_count, platforms,
       avg_usd, genre_count
FROM `fast-archive-478610-v8.gaming_project.silver_master_publishers`
WHERE publisher != 'unknown'
ORDER BY game_count DESC
LIMIT 10;


-- ============================================================
-- CHECK 4: Parsing artifact check — no garbage in publisher names
-- Expected: 0 rows (empty results)
-- ============================================================

SELECT publisher, COUNT(*) AS cnt
FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`
WHERE publisher = ''
   OR publisher LIKE '%[%'
   OR publisher LIKE '%]%'
   OR publisher LIKE "%''%"
   OR publisher LIKE '%""%'
GROUP BY publisher;


-- ============================================================
-- CHECK 5: Unknown publisher stats
-- ============================================================

SELECT publisher, game_count, platform_count, platforms, avg_usd
FROM `fast-archive-478610-v8.gaming_project.silver_master_publishers`
WHERE publisher = 'unknown';
