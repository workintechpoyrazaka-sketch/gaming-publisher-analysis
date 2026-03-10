# Findings Summary — Gaming Publisher Analysis

*A business-audience summary of key results from analyzing 131,884 games across Steam, PlayStation, and Xbox.*

---

## The Big Picture

The gaming publishing market is radically fragmented. No single publisher dominates any platform. The top known publisher on Steam holds just 0.52% market share. Instead, the market is shaped by two fundamentally different business models operating side by side — and a massive structural divide between major and indie publishers that has deepened over the past decade.

---

## Finding 1 — Radical Fragmentation

Across all three platforms, market share is extremely dispersed. Even the largest publishers by game count hold less than 1% of their primary platform. This is not a winner-take-all market — it is a long-tail ecosystem where thousands of small publishers coexist alongside a handful of well-known names.

## Finding 2 — Two Winning Business Models

The top 20 publishers by volume split cleanly into two archetypes:

- **AAA Model** (EA, Ubisoft, Sega): Operate across all three platforms, price games at $22–30, and rely on brand recognition and franchise value.
- **Volume Model** (Eastasiasoft, Ratalaika Games): Concentrate on PlayStation and Xbox, flood the market with budget titles at $2–8, and achieve massive output. Eastasiasoft alone has published 1,356 games — nearly double EA's 684.

Both models are commercially viable. Neither is displacing the other.

## Finding 3 — The Platform Gap

95% of all publishers operate on a single platform. The 2% that operate across all three platforms publish 15x more games, charge 2x the price, and cover 7x more genres than single-platform publishers. Multi-platform operation is the clearest structural indicator of publisher scale.

## Finding 4 — The Scissors Pattern (2015–2024)

Over the past decade, indie and major publishers diverged sharply:

- Indie publisher count grew 8.5x, but average prices stayed flat at ~$8.
- Major publisher output grew 5.7x, AND they raised prices by 46%.
- The price gap between major and indie titles doubled from $7.47 to $14.54.

This pattern — volume converging while prices diverge — suggests majors are leveraging brand premium while indies compete on accessibility.

## Finding 5 — Platform Pricing Personalities

Each platform has a distinct pricing profile:

- **Steam:** 82% budget titles. The accessibility platform.
- **Xbox:** Mid-tier dominated. The balanced platform.
- **PlayStation:** A unique volume-budget model driven by trophy-hunting publisher ecosystems (Eastasiasoft, Ratalaika).

## Finding 6 — Indie Lock-In

96.6% of indie publishers (1–9 games) are locked to a single platform. Only 25% of major publishers face the same constraint. The barrier to multi-platform publishing is structural, not just financial — it requires operational capacity that most small publishers lack.

## Finding 7 — Statistical Confirmation

A Welch's t-test confirms the major-indie price gap (~$8) is statistically significant at p < 0.001. This is not sampling noise — it reflects a real, systematic pricing difference between publisher tiers.

## Finding 8 — Machine Learning Validation

Three ML models converge on one story:

- **K-Means clustering** found four natural publisher segments without any labels — independently matching the AAA/Volume/Mid/Indie tiers defined in SQL.
- **Random Forest classification** proved publisher tier is predictable from observable features (price, platform count, genre diversity) with high accuracy.
- **Logistic Regression** identified game count as the strongest driver of multi-platform expansion — price and genre diversity also contribute, but volume is the primary signal.

## Finding 9 — The Eastasiasoft Surprise

Eastasiasoft is the #1 publisher by game count globally (1,356 games) with zero Steam presence. This challenges the assumption that Steam is the default publishing platform. PlayStation's trophy ecosystem has created a parallel market that rewards high-volume budget publishing.

---

## Implications

- **For publishers:** Multi-platform operation is the strongest predictor of scale, but the Volume model proves you don't need premium pricing to succeed at scale.
- **For platforms:** Steam's open-access model creates fragmentation. PlayStation's trophy ecosystem enables a unique publisher strategy that doesn't exist elsewhere.
- **For analysts:** Tier definitions are analytical choices. Documenting and validating those choices (as done here with K-Means confirmation) is as important as the analysis itself.

---

*Full methodology, SQL queries, Python notebooks, and visualizations available in the [project repository](https://github.com/workintechpoyrazaka-sketch/gaming-publisher-analysis).*
