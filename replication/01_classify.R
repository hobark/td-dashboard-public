# =====================================================================
# 01_classify.R -- coordinates from the shapefile + full classification
# Inputs : data/GHSL_wide_panel_2000_2025_with_NTL_complete.csv
#          data/GHSL_UCDB_2025_Final.shp (+ sidecars)
# Output : output/td_city_panel.csv  (city x window classification)
# =====================================================================
source("R/functions.R")
source("config.R")

## ---- coordinates from the shapefile -------------------------------
# Centroids are computed in the shapefile's projected CRS (planar, valid)
# and transformed to WGS84. If the panel already contains lon/lat columns,
# the shapefile step is skipped.
panel <- read.csv(PANEL_CSV)
if (!all(c("lon", "lat") %in% names(panel))) {
  library(sf)
  uc  <- st_read(SHP_PATH, quiet = TRUE)
  cen <- st_transform(st_centroid(st_geometry(uc)), 4326)
  xy  <- st_coordinates(cen)
  panel <- merge(panel,
                 data.frame(ID_UC_G0 = uc$ID_UC_G0, lon = xy[, 1], lat = xy[, 2]),
                 by = "ID_UC_G0")
}

## ---- classification over all windows ------------------------------
res <- run_classification(panel, WINDOWS, ALPHA, MIN_N)
res <- merge(res,
             panel[, c("ID_UC_G0", "GC_UCN_MAI", "wb_region", "wb_income",
                       "MT_POP_TOT_2025", "lon", "lat")],
             by = "ID_UC_G0")

dir.create("output", showWarnings = FALSE)
write.csv(res, "output/td_city_panel.csv", row.names = FALSE)

message(sprintf("classified %s city-windows (%s cities x %s windows); excluded %s countries (< %s cities, %s cities)",
                format(nrow(res), big.mark = ","),
                length(unique(res$ID_UC_G0)), length(WINDOWS),
                attr(res, "excluded_countries"), MIN_N, attr(res, "excluded_cities")))
# Expected: 26,410 city-windows (5,282 cities x 5 windows); 71 countries / 141 cities excluded.
