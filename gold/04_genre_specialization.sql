-- ============================================================
-- File: 04_genre_specialization.sql
-- Layer: Gold
-- Purpose: Parse genre list strings and map publisher-genre
--          relationships. Identifies which genres each publisher
--          dominates and measures genre diversity.
--          Answers: "What genres does each publisher specialize
--          in? Who are the genre leaders?"
-- Depends on: silver_games_publishers_parsed
-- Creates: gold_publisher_genre_parsed, gold_genre_specialization
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Genre field uses same Python-style list format as
--        publishers — reuses the same REGEXP_REPLACE/SPLIT/UNNEST
--        parsing pattern from Silver layer.
--        Two-stage query: first parse genres into individual rows,
--        then aggregate publisher-genre combinations.
--        'unknown' publishers included — their genre distribution
--        reveals what indie developers build.
-- ============================================================


-- STAGE 1: Parse genre lists into individual rows
-- One row per game-publisher-genre combination
CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_publisher_genre_parsed` AS

SELECT
  gameid,
  publisher,
  platform_group,
  usd,
  TRIM(REGEXP_REPLACE(genre_raw, r"""^['"]|['"]$""", '')) AS genre
FROM `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed`,
UNNEST(
  SPLIT(
    REGEXP_REPLACE(
      REPLACE(REPLACE(genres, '[', ''), ']', ''),
      r"""['"], ['"]""",
      '|||'
    ),
    '|||'
  )
) AS genre_raw
WHERE genres IS NOT NULL;


-- STAGE 2: Publisher-genre aggregation
-- How many games per publisher per genre, plus genre rank
CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.gold_genre_specialization` AS

WITH publisher_genre_counts AS (
  SELECT
    publisher,
    genre,
    COUNT(DISTINCT gameid) AS game_count,
    ROUND(AVG(usd), 2) AS avg_usd_in_genre
  FROM `fast-archive-478610-v8.gaming_project.gold_publisher_genre_parsed`
  GROUP BY publisher, genre
),

publisher_totals AS (
  SELECT
    publisher,
    SUM(game_count) AS total_genre_entries
  FROM publisher_genre_counts
  GROUP BY publisher
)

SELECT
  pgc.publisher,
  pgc.genre,
  pgc.game_count,
  pgc.avg_usd_in_genre,
  -- What % of this publisher's output is this genre?
  ROUND(pgc.game_count * 100.0 / pt.total_genre_entries, 2) AS genre_share_pct,
  -- Rank genres within publisher (top genre = specialty)
  RANK() OVER (
    PARTITION BY pgc.publisher
    ORDER BY pgc.game_count DESC
  ) AS genre_rank,
  -- Count of distinct genres this publisher works in
  COUNT(*) OVER (PARTITION BY pgc.publisher) AS genre_diversity
FROM publisher_genre_counts pgc
JOIN publisher_totals pt
  ON pgc.publisher = pt.publisher
ORDER BY pgc.publisher, genre_rank;
