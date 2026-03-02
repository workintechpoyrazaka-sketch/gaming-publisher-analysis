# 🎮 Gaming Publisher Analysis: Cross-Platform Market Intelligence

A data-driven competitive intelligence analysis of game publishers across **Steam**, **PlayStation**, and **Xbox** platforms, examining **131,890+ games** to uncover platform dominance patterns, genre specializations, and pricing strategies.

**Key Question:** Which publishers dominate which platforms, and how do their pricing and genre strategies impact market share?

---

## Key Findings

> *Findings will be added as analysis progresses through Sprint 3*

<!-- After Sprint 3, replace with real findings + chart screenshots like:
![Market Share by Platform](presentation/charts/market_share.png)
**Finding 1:** Top 5 publishers control X% of multi-platform titles while indie publishers...
-->

---

## Dataset

| Source | Records | Description |
|--------|---------|-------------|
| Steam Games | 98,249 | Game metadata: publishers, developers, genres, release dates |
| PlayStation Games | 23,151 | PS4, PS5, PS3, PS Vita game catalog |
| Xbox Games | 10,490 | Xbox game catalog |
| Price Tables (3 platforms) | 148,000+ | Pricing in USD, EUR, GBP, JPY, RUB |
| **Total** | **131,890+ games** | **Cross-platform publisher intelligence** |

**Source:** Kaggle — Gaming Profiles 2025 (60GB dataset)

---

## Methodology

### Data Pipeline: Bronze → Silver → Gold

```
Raw CSVs → BigQuery Upload → Type Conversion & Cleaning (Bronze)
    → Cross-Platform Joins & Publisher Parsing (Silver)
        → Market Analysis, Statistics & Visualization (Gold)
```

**Bronze (Data Cleaning):**
CSV ingestion into Google BigQuery. Type conversions (FLOAT64 for prices, DATE for dates). Name standardization with LOWER(TRIM()). Null handling with documented reasoning for each decision.

**Silver (Data Integration):**
Cross-platform MASTER_PUBLISHERS table unifying all game and price data. Publisher name parsing from Python-style list strings using BigQuery's SPLIT and UNNEST functions. Platform tagging for comparative analysis.

**Gold (Analysis & Insight):**
Seven SQL-based analyses covering market share, platform strategy, pricing intelligence, genre specialization, indie vs major publishers, and release timing patterns. Statistical hypothesis testing with scipy. Visualization with Plotly. Publisher tier clustering with K-means.

### Analysis Framework

1. **Market Share** — Publisher game counts and percentage share by platform
2. **Platform Strategy** — Multi-platform vs single-platform publisher segmentation
3. **Pricing Intelligence** — Average pricing by publisher tier, platform, and genre
4. **Genre Specialization** — Publisher-genre dominance mapping and diversity index
5. **Indie vs Major** — Survival analysis, platform dependency, pricing gaps
6. **Release Patterns** — Publisher timing strategies and pricing trends
7. **Statistical Validation** — Hypothesis testing for pricing strategy differences

---

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Database | Google BigQuery | Data warehouse, SQL analysis |
| Data Cleaning | BigQuery SQL | Type conversions, standardization, null handling |
| Data Integration | BigQuery SQL | Cross-platform joins, publisher parsing |
| Analysis | BigQuery SQL + Python (Pandas) | Market analysis, aggregations, statistical tests |
| Visualization | Plotly | Interactive charts for analysis and presentation |
| Statistical Tests | scipy.stats | Hypothesis testing (t-tests, chi-square) |
| Clustering | scikit-learn | Publisher tier segmentation (K-means) |
| Version Control | Git / GitHub | Code management, portfolio documentation |
| Presentation | Google Slides | Final stakeholder deliverable |

---

## Project Structure

```
bronze/          → Raw data cleaning SQL scripts (Sprint 1)
silver/          → Master table creation & cross-platform joins (Sprint 2)
gold/            → Analysis queries — 7 analytical perspectives (Sprint 3)
notebooks/       → Python analysis, visualization & statistical tests (Sprint 3)
presentation/    → Final slides & exported chart assets (Sprint 4)
docs/            → Methodology, cleaning decisions & findings documentation
```

---

## How to Reproduce

1. Download the [Gaming Profiles 2025](https://www.kaggle.com/datasets/artyomkruglov/gaming-profiles-2025-steam-playstation-xbox) dataset from Kaggle
2. Upload CSV files to Google BigQuery (games and prices tables for PS, Steam, Xbox)
3. Run SQL scripts in order: `bronze/01` → `02` → `03` → `silver/01` → ... → `05` → `gold/01` → ... → `07`
4. Export Gold query results as CSVs to `data/exports/`
5. Open Jupyter notebooks in `notebooks/` for visualizations and statistical analysis
6. Charts are exported to `presentation/charts/` for use in the final presentation

---

## What I Learned

> *This section will be completed after the project — honest reflections on the journey.*

<!-- After Mar 7, fill in:
### Challenges
- [e.g., "Learned Python from zero inside a live project with real deadlines"]
- [e.g., "Parsing nested string lists in SQL required creative SPLIT/UNNEST approach"]

### Skills Acquired During This Project
- [e.g., "Pandas for data manipulation — learned in context, not from tutorials"]
- [e.g., "Plotly for professional data visualization"]
- [e.g., "Hypothesis testing with scipy.stats"]

### What I'd Do Differently
- [e.g., "Would allocate more time for data quality audit in Bronze layer"]
-->

---

## Author

**Poi** — Data Analyst | Mathematics Student
*Built as part of Workintech Data Analyst → Data Scientist program (2025–2026)*

<!-- Add your links when ready:
[LinkedIn](your-link) | [GitHub](your-link) | [Portfolio](your-link)
-->

---

*This project analyzes publicly available gaming platform data for educational and portfolio purposes.*
