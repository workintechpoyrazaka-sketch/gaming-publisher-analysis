# Data Cleaning Decisions — Bronze Layer

This document records every cleaning decision made during the Bronze sprint,
with reasoning for each choice. Decisions are final unless noted otherwise.

---

## Type Conversions

| Column | Original Type | Converted To | Reason |
|--------|--------------|--------------|--------|
| usd, eur, gbp, jpy, rub | STRING | FLOAT64 | Price columns must be numeric for aggregation and comparison |
| release_date | STRING | DATE | Enables time-based analysis (release patterns, trends) |
| date_acquired (prices) | STRING | DATE | Enables price timeline analysis |

## Name Standardization

| Field | Transformation | Reason |
|-------|---------------|--------|
| title | LOWER(TRIM()) | Consistent matching across platforms (same game, different capitalization) |
| publishers | LOWER(TRIM()) | Publisher name matching across platforms |
| developers | LOWER(TRIM()) | Developer name matching across platforms |

## Null Handling

| Table | Column | Null Count | % | Decision | Reason |
|-------|--------|-----------|---|----------|--------|
| | | | | | |

<!-- Fill in during Sprint 1 as you audit each table -->

## Publisher/Developer List Format

**Issue:** Publishers and developers stored as Python-style list strings: `['Publisher Name']`
**Decision:** To be resolved in Sprint 2 — SPLIT/UNNEST approach planned
**Reason:** To be documented when implemented

---

*Last updated: 2026-02-28*
