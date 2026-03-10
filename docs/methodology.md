# Methodology — Gaming Publisher Analysis

## Research Questions

1. Which publishers dominate which platforms, and by how much?
2. Do multi-platform publishers structurally outperform single-platform ones?
3. How do pricing strategies differ by publisher tier and platform?
4. What genre specializations exist among top publishers?
5. How has the publisher landscape changed over time (2015–2024)?
6. Can machine learning models predict publisher tier and platform expansion from observable features?

## Data Source

**Kaggle "Gaming Profiles 2025"** — approximately 60GB covering three major gaming platforms:
- Steam: ~98,000 games
- PlayStation: ~23,000 games
- Xbox: ~10,000 games
- **Total:** 131,884 games mapped to 51,193 unique publishers

## Pipeline: Bronze → Silver → Gold → Python

The analysis follows a medallion architecture adapted for BigQuery, with Python handling statistical testing and visualization.

### Bronze Layer — Clean & Validate

Each platform's raw CSV was uploaded into BigQuery as a separate table. Cleaning steps:

- **Steam (179MB):** File exceeded BigQuery's upload limit. Split into two CSVs via PowerShell, uploaded separately, recombined with `UNION ALL`.
- **PlayStation:** One malformed row identified via `INFORMATION_SCHEMA` column count mismatch. Filtered out (CSV parse error shifted columns).
- **Xbox:** Clean upload, no issues.
- **Schema validation:** `INFORMATION_SCHEMA.COLUMNS` used to verify column names, types, and row counts before any analysis.
- **NULL price handling:** NULL prices were preserved, not replaced with $0. A NULL price means free-to-play or data unavailable — analytically distinct from a $0 price point.
- **Titleless rows:** 3 Steam rows with no game title dropped (0.003% of data). No analytical value without identification.

### Silver Layer — Unify, Join & Parse

Four tables built in sequence to create a single unified publisher dataset:

1. **silver_unified_games** — `UNION ALL` across all three platforms with a `platform` tag column added. 131,884 rows.
2. **silver_games_with_prices** — `LEFT JOIN` to price tables using `ROW_NUMBER() OVER (PARTITION BY gameid ORDER BY date DESC)` to select only the most recent price per game. LEFT JOIN ensures games without price data are retained.
3. **silver_games_publishers_parsed** — Publisher list strings parsed from Python-style format (`['Activision']`) into individual rows. Games with multiple publishers are exploded into separate rows (137,204 rows).
4. **silver_master_publishers** — One row per publisher with aggregated metrics: game count, platform count, average price, genre count.

**The parsing challenge:** Publisher fields were stored as Python-style list strings with mixed quoting (`['EA']`, `["Bethesda's Studio"]`). A naive comma split breaks on names containing commas (e.g., "Co., Ltd."). The solution uses `REGEXP_REPLACE` to convert the quote-comma-quote delimiter pattern to a safe `|||` separator, then `SPLIT` on `|||`, then `UNNEST` to explode into rows. This same pattern was reused identically for genre parsing in the Gold layer.

### Gold Layer — Deep Analysis

Seven SQL scripts producing nine analysis tables:

| # | Table | Purpose |
|---|-------|---------|
| 1 | `gold_market_share` | Publisher market share by platform using `COUNT` + percentage calculation |
| 2 | `gold_platform_strategy` | Comparison of single vs multi-platform publisher performance |
| 3 | `gold_pricing_strategy` | Price tier distribution (budget/mid/premium) by platform and publisher tier |
| 4 | `gold_publisher_genre_parsed` + `gold_genre_specialization` | Genre parsing (reusing Silver pattern) + specialization metrics |
| 5 | `gold_indie_vs_major` | Structural comparison of indie (1–9 games), mid-tier (10–99), and major (100+) publishers |
| 6 | `gold_top20_dashboard` | Complete profile of the 20 largest publishers by game count |
| 7 | `gold_release_patterns` | Year-over-year trends (2015–2024) by publisher tier |

**Analytical definitions (no external classification available):**
- **Publisher tiers:** Major (100+ games), Mid-tier (10–99 games), Indie (1–9 games) — validated against known publishers (EA, Ubisoft confirmed as major; small studios confirmed as indie).
- **Price tiers:** Budget (<$10), Mid ($10–30), Premium (>$30).
- **"Unknown" publishers:** Excluded from tier analysis but tracked as a self-published segment.

### Python Phase — Statistics, ML & Visualization

All Python work executed in Google Colab. Seven Gold-layer CSVs exported from BigQuery and loaded into Pandas.

**Statistical Testing:**
- Welch's t-test comparing major vs indie publisher average prices. Result: statistically significant difference (p < 0.001), confirming the ~$8 price gap is not due to chance.

**Unsupervised Machine Learning:**
- K-Means clustering (K=4, selected via elbow method) on standardized publisher features (game count, avg price, platform count, genre count). Independently validated the AAA vs Volume publisher archetypes discovered in SQL analysis.

**Supervised Machine Learning:**
- **Random Forest Classifier:** Predicts publisher tier (major/mid/indie) from average price, platform count, and genre diversity. `class_weight='balanced'` handles extreme class imbalance (49K+ indies vs ~105 majors). `stratify=y` in train/test split preserves class proportions.
- **Logistic Regression:** Predicts single vs multi-platform operation. Features: game count, average price, genre diversity. Platform count excluded from features to prevent data leakage (it IS the target). Coefficients provide directional interpretation.

**Visualization:**
10 Plotly charts + 5 ML charts exported as PNG at 2x resolution. All charts designed for presentation embedding and README display.

## Tools & Environment

| Tool | Role |
|------|------|
| Google BigQuery | SQL analysis — window functions, REGEXP parsing, CTEs, partitioning |
| Python / Pandas | Data manipulation, aggregation, ML feature preparation |
| Plotly | Interactive and publication-quality chart generation |
| scipy.stats | Welch's t-test for hypothesis testing |
| scikit-learn | KMeans, RandomForestClassifier, LogisticRegression |
| Google Colab | Notebook execution (pinned: `plotly==5.18.0`, `kaleido==0.2.1`) |
| Git / GitHub | Version control with atomic, typed commits |

## Reproducibility

All SQL files, the Jupyter notebook, exported charts, and raw data references are available in this repository. See the main [README.md](../README.md) for step-by-step reproduction instructions.
