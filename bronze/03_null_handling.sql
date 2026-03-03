-- ============================================================
-- File: 03_null_handling.sql
-- Layer: Bronze
-- Purpose: Audit null values across all tables and apply handling
--          decisions. Each decision is documented with reasoning.
-- Depends on: bronze_games_ps, bronze_games_steam, bronze_games_xbox,
--             bronze_prices_ps, bronze_prices_steam, bronze_prices_xbox
-- Creates: Updates bronze_games_steam (drops 3 titleless rows).
--          All other tables unchanged — nulls retained by design.
-- Author: Poi
-- Date: 2026-03-02
-- Notes: Most nulls are KEPT because they carry meaning:
--        - Null prices = free-to-play or not sold in that region
--        - Null publishers = indie/self-published or unlisted
--        - Null genres = untagged on the platform
--        See docs/cleaning_decisions.md for the full reasoning table.
-- ============================================================


-- ============================================================
-- SECTION 1: NULL AUDIT QUERIES
-- Run these to verify counts before and after. Not CREATE statements.
-- ============================================================

-- Games null audit
SELECT
  'PS' AS platform,
  COUNT(*) AS total_rows,
  COUNTIF(title IS NULL)               AS null_title,
  COUNTIF(developers IS NULL)          AS null_developers,
  COUNTIF(publishers IS NULL)          AS null_publishers,
  COUNTIF(genres IS NULL)              AS null_genres,
  COUNTIF(supported_languages IS NULL) AS null_languages,
  COUNTIF(release_date IS NULL)        AS null_release_date
FROM `gaming_project.bronze_games_ps`

UNION ALL

SELECT
  'Steam',
  COUNT(*),
  COUNTIF(title IS NULL),
  COUNTIF(developers IS NULL),
  COUNTIF(publishers IS NULL),
  COUNTIF(genres IS NULL),
  COUNTIF(supported_languages IS NULL),
  COUNTIF(release_date IS NULL)
FROM `gaming_project.bronze_games_steam`

UNION ALL

SELECT
  'Xbox',
  COUNT(*),
  COUNTIF(title IS NULL),
  COUNTIF(developers IS NULL),
  COUNTIF(publishers IS NULL),
  COUNTIF(genres IS NULL),
  COUNTIF(supported_languages IS NULL),
  COUNTIF(release_date IS NULL)
FROM `gaming_project.bronze_games_xbox`;


-- Prices null audit
SELECT
  'PS' AS platform,
  COUNT(*) AS total_rows,
  COUNTIF(usd IS NULL) AS null_usd,
  COUNTIF(eur IS NULL) AS null_eur,
  COUNTIF(gbp IS NULL) AS null_gbp,
  COUNTIF(jpy IS NULL) AS null_jpy,
  COUNTIF(rub IS NULL) AS null_rub,
  COUNTIF(date_acquired IS NULL) AS null_date
FROM `gaming_project.bronze_prices_ps`

UNION ALL

SELECT
  'Steam',
  COUNT(*),
  COUNTIF(usd IS NULL),
  COUNTIF(eur IS NULL),
  COUNTIF(gbp IS NULL),
  COUNTIF(jpy IS NULL),
  COUNTIF(rub IS NULL),
  COUNTIF(date_acquired IS NULL)
FROM `gaming_project.bronze_prices_steam`

UNION ALL

SELECT
  'Xbox',
  COUNT(*),
  COUNTIF(usd IS NULL),
  COUNTIF(eur IS NULL),
  COUNTIF(gbp IS NULL),
  COUNTIF(jpy IS NULL),
  COUNTIF(rub IS NULL),
  COUNTIF(date_acquired IS NULL)
FROM `gaming_project.bronze_prices_xbox`;


-- ============================================================
-- SECTION 2: NULL HANDLING ACTIONS
-- ============================================================

-- ACTION 1: Drop Steam games with null titles (3 rows)
-- Reasoning: A game without a title is unusable for analysis.
--            Only 3 rows affected (0.003%) — negligible data loss.
CREATE OR REPLACE TABLE `gaming_project.bronze_games_steam` AS
SELECT *
FROM `gaming_project.bronze_games_steam`
WHERE title IS NOT NULL;

-- ACTION 2: All other nulls are RETAINED (no action needed)
--
-- KEPT: publishers/developers nulls (PS: 11-17, Steam: 5.5K-5.9K, Xbox: 545-576)
--   Why: Null publisher ≠ missing data. It means self-published, indie, or unlisted.
--        These games matter for the "indie vs major publisher" analysis in Gold layer.
--
-- KEPT: genres nulls (PS: 142, Steam: 5,549, Xbox: 605)
--   Why: Untagged games are a real category. Dropping them would bias genre analysis
--        toward well-cataloged titles (typically major publishers).
--
-- KEPT: supported_languages nulls (PS: 54%, Xbox: 63%)
--   Why: Not critical for publisher analysis. High null rate makes this field
--        unreliable — noted for Sprint 2 if language analysis is needed.
--
-- KEPT: price nulls (usd 21-29%, eur 25-33%, gbp 22-30%, jpy 57-100%, rub 36-83%)
--   Why: Null price = free-to-play OR not sold in that currency/region.
--        This is meaningful business data: "game has no USD price" tells us something
--        about the publisher's regional strategy. Replacing with 0 would falsely
--        categorize regional unavailability as free-to-play.
--
-- KEPT: Xbox jpy (100% null)
--   Why: Xbox prices simply aren't available in JPY for any game in this dataset.
--        Column kept for schema consistency across the three price tables.
