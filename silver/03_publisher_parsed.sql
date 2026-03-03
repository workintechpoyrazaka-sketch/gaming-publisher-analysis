-- ============================================================
-- File: 03_publisher_parsed.sql
-- Layer: Silver
-- Purpose: Parse publisher list strings into individual rows.
--          Each game-publisher combination becomes one row.
--          Games with 2 publishers become 2 rows.
-- Depends on: silver_games_with_prices
-- Creates: silver_games_publishers_parsed
-- Author: Poi
-- Date: 2026-03-03
-- Notes: Publisher fields stored as Python-style lists:
--        ['name'] or ["name's studio"] with mixed quoting.
--        All three platforms use single quotes for clean names
--        and double quotes when the name contains an apostrophe.
--        Delimiter pattern: any-quote, comma, space, any-quote.
--        REGEXP_REPLACE converts to safe ||| delimiter before SPLIT.
--        Games with NULL or whitespace-only publishers tagged as
--        'unknown' for indie/self-published analysis.
-- ============================================================

CREATE OR REPLACE TABLE `fast-archive-478610-v8.gaming_project.silver_games_publishers_parsed` AS

WITH parsed AS (
  SELECT
    gameid,
    title,
    publishers AS publishers_raw,
    developers,
    genres,
    release_date,
    platform,
    platform_group,
    price_date,
    usd, eur, gbp, jpy, rub,
    TRIM(REGEXP_REPLACE(publisher_raw, r"""^['"]|['"]$""", ''))
      AS publisher
  FROM `fast-archive-478610-v8.gaming_project.silver_games_with_prices`,
  UNNEST(
    SPLIT(
      REGEXP_REPLACE(
        REPLACE(REPLACE(publishers, '[', ''), ']', ''),
        r"""['"], ['"]""",
        '|||'
      ),
      '|||'
    )
  ) AS publisher_raw
  WHERE publishers IS NOT NULL
),

-- Fix any whitespace-only publishers that TRIM reduced to empty string
cleaned AS (
  SELECT * EXCEPT(publisher),
    CASE
      WHEN publisher = '' THEN 'unknown'
      ELSE publisher
    END AS publisher
  FROM parsed
)

SELECT * FROM cleaned

UNION ALL

-- Keep NULL-publisher games as 'unknown' for indie analysis
SELECT
  gameid,
  title,
  publishers AS publishers_raw,
  developers,
  genres,
  release_date,
  platform,
  platform_group,
  price_date,
  usd, eur, gbp, jpy, rub,
  'unknown' AS publisher
FROM `fast-archive-478610-v8.gaming_project.silver_games_with_prices`
WHERE publishers IS NULL;
