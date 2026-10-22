# =====================================================================
# 03_robustness.R -- reproduces Section 5.2 and the accompanying-materials
# comparison with market access referenced in Section 4.2.
#   (a) alpha sensitivity: LSE rank stability and exposure-class changes
#   (b) median vs tercile exposure split
#   (c) period-to-period type persistence (Section 4.1)
#   (d) MA vs LSE: Spearman rho and lagging reclassification share
# Inputs: output/td_city_panel.csv, data/<panel csv>
# =====================================================================
source("R/functions.R")
source("config.R")

res   <- read.csv("output/td_city_panel.csv")
panel <- read.csv(PANEL_CSV)
if (!all(c("lon", "lat") %in% names(panel)))
  panel <- merge(panel, unique(res[, c("ID_UC_G0", "lon", "lat")]), by = "ID_UC_G0")
r25 <- res[res$period == 2025, ]
lines_out <- c()
say <- function(...) { s <- sprintf(...); message(s); lines_out <<- c(lines_out, s) }

## ---- (a) alpha sensitivity ------------------------------------------
w25 <- WINDOWS[[length(WINDOWS)]]
base <- r25[order(r25$ID_UC_G0), ]
for (a in ALPHA_GRID) {
  alt <- run_classification(panel, list(w25), a, MIN_N)
  alt <- alt[order(alt$ID_UC_G0), ]
  stopifnot(identical(alt$ID_UC_G0, base$ID_UC_G0))
  rho  <- cor(base$LSE, alt$LSE, method = "spearman")
  flip <- mean(base$high_LSE != alt$high_LSE)
  flag <- base$type == "Lagging"
  say("alpha %.1f vs %.1f: Spearman rho(LSE) = %.3f | exposure-class changes: %.1f%% all, %.1f%% of lagging",
      a, ALPHA, rho, 100 * flip, 100 * mean(base$high_LSE[flag] != alt$high_LSE[flag]))
}
# Expected: rho 0.964 (alpha 1.0) and 0.976 (alpha 2.0); changes ~6-7%.

## ---- (b) median vs tercile split ------------------------------------
terc <- run_classification(panel, list(w25), ALPHA, MIN_N, split = "tercile")
terc <- terc[order(terc$ID_UC_G0), ]
say("median vs tercile split: exposure-class changes %.1f%% (mechanical benchmark 16.7%%)",
    100 * mean(base$high_LSE != terc$high_LSE))

## ---- (c) type persistence across consecutive windows ----------------
tw <- reshape(res[, c("ID_UC_G0", "period", "type")], idvar = "ID_UC_G0",
              timevar = "period", direction = "wide")
pers <- sapply(seq_len(length(WINDOWS) - 1), function(k) {
  a <- paste0("type.", WINDOWS[[k]][2]); b <- paste0("type.", WINDOWS[[k + 1]][2])
  mean(tw[[a]] == tw[[b]])
})
say("type persistence across consecutive windows: %s (random-agreement baseline ~29%%)",
    paste(sprintf("%.1f%%", 100 * pers), collapse = ", "))

## ---- (d) MA vs LSE (accompanying-materials comparison) --------------
r25$MA_pct  <- pct_within(r25$MA,  r25$country)
r25$LSE_pct <- pct_within(r25$LSE, r25$country)
say("Spearman rho, MA vs LSE (within-country percentile ranks, pooled): %.3f",
    cor(r25$MA_pct, r25$LSE_pct, method = "spearman"))
r25$hi_MA <- ave(r25$MA, r25$country, FUN = function(v) v >= median(v)) == 1
lag <- r25[r25$type == "Lagging", ]
say("lagging cities reclassified (connected <-> structural) when LSE replaces MA: %.1f%% of %d",
    100 * mean(lag$hi_MA != lag$high_LSE), nrow(lag))
# Expected: rho = 0.623; 28.5% of 1,330 (192 mass-rich/growth-poor + 187 growth-rich/mass-poor).

writeLines(lines_out, "output/robustness_summary.txt")
message("03_robustness.R done; see output/robustness_summary.txt")
