# Replication package

**Measuring territorial development from publicly available data: a typology
of cities and their exposure to growth** (Letters in Spatial and Resource
Sciences, submitted).

This package reproduces every empirical number and figure reported in the
paper from two input files. It contains no data cleaning or merging; the
inputs are the compiled analysis panel and the urban-centre shapefile.

## Requirements

* R >= 4.0. Base R only, with one exception: the **sf** package is needed
  only if the panel CSV does not already contain `lon`/`lat` columns
  (coordinates are then derived from the shapefile).
* No internet access required. No randomness: every result is deterministic.

## Inputs (place in `data/`)

1. `GHSL_wide_panel_2000_2025_with_NTL_complete.csv` -- one row per urban
   centre (5,423 rows) with: `ID_UC_G0`, `GC_CNT_GAD` (country), `wb_region`,
   `wb_income`, `GC_UCN_MAI` (name), `MT_POP_TOT_{2000..2025}`,
   `MT_BUS_TOT_{2000..2025}`, `NTL_SUM_{2000..2025}` at five-year epochs,
   and (optionally) `lon`, `lat`.
2. `GHSL_UCDB_2025_Final.shp` (+ `.dbf`, `.shx`, `.prj`) -- urban-centre
   polygons containing `ID_UC_G0`. Used only to derive centroids if the
   panel lacks coordinates.

Sources: GHSL Urban Centre Database R2024A (population, built-up,
delineation); harmonised DMSP-OLS/VIIRS night-time lights (Li et al. 2020);
World Bank FY2025 regional and income classification.

## How to run

```
Rscript 00_run_all.R
```

or run `01_classify.R`, `02_results_main.R`, `03_robustness.R` in order.
Total runtime is a few minutes on a laptop.

## Scripts

| File | Purpose | Paper location |
|---|---|---|
| `config.R` | all analysis choices (windows, alpha = 1.5, min-N = 5) | Sections 2, 3.3 |
| `R/functions.R` | typology rule, weights, exposure (MA/LSE), labels | Section 3 |
| `01_classify.R` | coordinates + classification, all five windows | Sections 2-3 |
| `02_results_main.R` | Table 1; CP-vs-SL statistics; Figures 4, 5, 6 | Sections 4.1-4.4 |
| `03_robustness.R` | alpha and split sensitivity; persistence; MA comparison | Sections 4.1, 5.2; the "accompanying materials" of Section 4.2 |

## Expected outputs (checks for a successful replication)

* `output/td_city_panel.csv`: 26,410 rows (5,282 cities x 5 windows);
  71 countries (141 cities) excluded by the min-N rule.
* Table 1, 2025 row: Leading 35.0 / Pressure 31.9 / Sprawl 8.0 / Lagging 25.2 (%).
* Section 4.2: 601 Connected Peripheries vs 729 Structurally Lagging;
  median population ~176,000 vs ~182,000; median distance to nearest leading
  city 48 km vs 86 km; median leading cities within 100 km: 3 vs 1.
* Robustness: Spearman rho(LSE) vs baseline 0.964 (alpha = 1.0) and 0.976
  (alpha = 2.0), exposure-class changes 6-7%; median-vs-tercile split moves
  16.5% (16.7% mechanical); type persistence 39-43% across windows;
  MA-vs-LSE Spearman rho = 0.623 with 28.5% of lagging cities reclassified
  (379 flips: 192 mass-rich/growth-poor + 187 growth-rich/mass-poor).

Small differences in the last decimal can arise from BLAS/OS variation;
anything larger indicates an input or environment problem.

## Notes

* Everything is computed **within country**: z-scores, the leading set, the
  exposure sums, and the median split. The global picture is a mosaic of
  national classifications, not a global ranking.
* To substitute network travel time for great-circle distance, replace
  `haversine_km()` in `R/functions.R` with a travel-time matrix; nothing
  else changes. To change the decay family, edit `decay_weights()`.
* An interactive dashboard accompanying the paper (`TD_Global_Dashboard.html`)
  visualises the same classification across windows.

## Citation

[Author] (2026). Measuring territorial development from publicly available
data: a typology of cities and their exposure to growth. *Letters in Spatial
and Resource Sciences* (submitted). Replication package.
