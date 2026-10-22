# =====================================================================
# config.R -- all analysis choices in one place (paper defaults)
# =====================================================================
PANEL_CSV  <- "data/GHSL_wide_panel_2000_2025_with_NTL_complete.csv"
SHP_PATH   <- "data/GHSL_UCDB_2025_Final.shp"   # used only if panel lacks lon/lat

WINDOWS    <- list(c(2000, 2005), c(2005, 2010), c(2010, 2015),
                   c(2015, 2020), c(2020, 2025))  # labelled by end year
ALPHA      <- 1.5     # baseline distance-decay exponent (Section 3.3)
MIN_N      <- 5       # minimum cities per country to classify (Section 2)
ALPHA_GRID <- c(1.0, 2.0)  # sensitivity values (Section 5.2)
