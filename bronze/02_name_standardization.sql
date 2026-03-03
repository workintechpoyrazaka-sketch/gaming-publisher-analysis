-- ============================================================
-- File: 02_name_standardization.sql
-- Layer: Bronze
-- Purpose: Standardize text fields with LOWER(TRIM()) to enable
--          consistent matching across platforms (same game or
--          publisher appearing with different capitalization)
-- Depends on: bronze_games_ps, bronze_games_steam, bronze_games_xbox
-- Creates: Updates bronze_games_* tables in place
-- Author: Poi
-- Date: 2026-03-02
-- Notes: Applied to title, publishers, and developers — the three
--        fields used for cross-platform matching. Genres and
--        supported_languages left as-is (not used for joins).
--        Publisher/developer list strings like ['Erik Games'] become
--        ['erik games'] — the bracket/quote parsing happens in Silver.
-- ============================================================


-- ============================================================
-- PS GAMES
-- ============================================================
CREATE OR REPLACE TABLE `gaming_project.bronze_games_ps` AS
SELECT
  gameid,
  LOWER(TRIM(title))       AS title,
  platform,                 -- PS-specific: PS3, PS4, PS5, PS Vita (keep original case)
  LOWER(TRIM(developers))  AS developers,
  LOWER(TRIM(publishers))  AS publishers,
  genres,                   -- not standardized: used for categorization, not matching
  supported_languages,      -- not standardized: not used for cross-platform joins
  release_date
FROM `gaming_project.bronze_games_ps`;


-- ============================================================
-- STEAM GAMES
-- ============================================================
CREATE OR REPLACE TABLE `gaming_project.bronze_games_steam` AS
SELECT
  gameid,
  LOWER(TRIM(title))       AS title,
  LOWER(TRIM(developers))  AS developers,
  LOWER(TRIM(publishers))  AS publishers,
  genres,
  supported_languages,
  release_date
FROM `gaming_project.bronze_games_steam`;


-- ============================================================
-- XBOX GAMES
-- ============================================================
CREATE OR REPLACE TABLE `gaming_project.bronze_games_xbox` AS
SELECT
  gameid,
  LOWER(TRIM(title))       AS title,
  LOWER(TRIM(developers))  AS developers,
  LOWER(TRIM(publishers))  AS publishers,
  genres,
  supported_languages,
  release_date
FROM `gaming_project.bronze_games_xbox`;
