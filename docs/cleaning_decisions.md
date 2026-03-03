# Data Cleaning Decisions — Bronze Layer

This document records every cleaning decision made during the Bronze sprint,
with reasoning for each choice. Decisions are final unless noted otherwise.

---

## Type Conversions

BigQuery auto-detected most column types correctly during CSV upload.
Only two columns required explicit casting:

| Table | Column | Auto-Detected | Cast To | Reason |
|-------|--------|--------------|---------|--------|
| raw_games_ps | gameid | STRING | INT64 | All other tables have INT64 gameid — needed for join consistency |
| raw_prices_xbox | jpy | STRING | FLOAT64 | 100% null column detected as STRING — cast for schema consistency with other price tables |

All other columns were correctly auto-detected:
- gameid (Steam, Xbox, all prices): INT64 ✓
- Price columns (usd, eur, gbp, jpy, rub): FLOAT64 ✓
- release_date / date_acquired: DATE ✓
- Text fields (title, developers, publishers, genres, supported_languages): STRING ✓

## Name Standardization

| Field | Transformation | Reason |
|-------|---------------|--------|
| title | LOWER(TRIM()) | Consistent matching across platforms (same game, different capitalization) |
| publishers | LOWER(TRIM()) | Publisher name matching across platforms. List brackets preserved — parsing is Silver layer work. |
| developers | LOWER(TRIM()) | Developer name matching across platforms. Same approach as publishers. |
| genres | Not standardized | Used for categorization, not cross-platform joins. Parsed in Silver. |
| supported_languages | Not standardized | Not used for publisher analysis. High null rates (54–63%) make it unreliable. |
| platform (PS only) | Not standardized | Kept original case (PS3, PS4, PS5, PS Vita) — categorical, not a text match field. |

## Null Handling

### Games Tables

| Table | Column | Null Count | % | Decision | Reason |
|-------|--------|-----------|---|----------|--------|
| PS | developers | 17 | 0.1% | KEEP | Self-published/unlisted — relevant for indie analysis |
| PS | publishers | 11 | 0.0% | KEEP | Same as above |
| PS | genres | 142 | 0.6% | KEEP | Untagged games are a real category |
| PS | supported_languages | 12,537 | 54.2% | KEEP | Not critical for publisher analysis |
| Steam | title | 3 | 0.0% | **DROP** | Game without title is unusable. 3 rows = negligible loss. |
| Steam | developers | 5,559 | 5.7% | KEEP | Likely playtest/demo entries — valuable for "incomplete metadata" analysis |
| Steam | publishers | 5,941 | 6.0% | KEEP | Same reasoning — null publisher is meaningful (self-published or unlisted) |
| Steam | genres | 5,549 | 5.6% | KEEP | Dropping would bias toward well-cataloged (major publisher) titles |
| Steam | supported_languages | 5,506 | 5.6% | KEEP | Not used for publisher analysis |
| Xbox | developers | 576 | 5.5% | KEEP | Consistent with Steam treatment |
| Xbox | publishers | 545 | 5.2% | KEEP | Consistent with Steam treatment |
| Xbox | genres | 605 | 5.8% | KEEP | Consistent with Steam treatment |
| Xbox | supported_languages | 6,647 | 63.4% | KEEP | Not critical, too sparse to be useful |

### Price Tables

| Table | Column | Null Count | % | Decision | Reason |
|-------|--------|-----------|---|----------|--------|
| PS | usd | 13,565 | 21.6% | KEEP | Null = free-to-play OR not sold in USD. Both are meaningful. |
| PS | eur | 15,552 | 24.8% | KEEP | Same — regional availability signal |
| PS | gbp | 14,179 | 22.6% | KEEP | Same |
| PS | jpy | 35,778 | 57.0% | KEEP | Many games not sold in Japan |
| PS | rub | 51,905 | 82.6% | KEEP | Most games not priced in RUB |
| Xbox | usd | 6,635 | 29.3% | KEEP | Same reasoning as PS |
| Xbox | eur | 7,369 | 32.6% | KEEP | Same |
| Xbox | gbp | 6,826 | 30.2% | KEEP | Same |
| Xbox | jpy | 22,638 | **100%** | KEEP | Xbox has no JPY pricing data at all. Kept for schema consistency. |
| Xbox | rub | 8,261 | 36.5% | KEEP | Same reasoning as PS |
| Steam | (all prices) | varies | varies | KEEP | Same reasoning — null price ≠ missing data |

**Key design decision:** Price nulls are NOT replaced with 0. Zero would falsely equate "not sold in this region" with "free-to-play." The distinction matters for pricing strategy analysis in the Gold layer.

## Schema Differences Across Platforms

| Difference | Detail | Impact |
|-----------|--------|--------|
| PS games has `platform` column | Values: PS3, PS4, PS5, PS Vita | Silver layer adds platform tags to Steam/Xbox |
| Steam/Xbox games lack `platform` column | All rows are single platform | Add 'Steam'/'Xbox' literal in Silver unified view |
| PS games gameid auto-detected as STRING | Other tables got INT64 | Explicit CAST in Bronze script 01 |
| Xbox prices jpy auto-detected as STRING | 100% null column | SAFE_CAST in Bronze script 01 |

## Publisher/Developer List Format

**Issue:** Publishers and developers stored as Python-style list strings: `['Publisher Name']`
Multi-value example: `['Ziggurat Interactive', 'Beep Japan']`
**Decision:** To be resolved in Sprint 2 with REPLACE + SPLIT + UNNEST in BigQuery
**Reason:** LOWER(TRIM()) applied in Bronze preserves the bracket format. Full parsing (extracting individual publisher names) is Silver layer work — it requires SPLIT/UNNEST which is a structural transformation, not a cleaning step.

---

*Last updated: 2026-03-02 — Sprint 1 Bronze complete*
