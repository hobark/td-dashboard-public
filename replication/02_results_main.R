# =====================================================================
# 02_results_main.R -- reproduces the paper's main empirical results
#   Table 1  : typology composition by window            (Section 4.1)
#   Stats    : Connected Periphery vs Structurally Lagging (Section 4.2)
#   Figure 4 : what LSE reveals among lagging cities      (Section 4.2)
#   Figure 5 : typology composition by region / income    (Section 4.3)
#   Figure 6 : four system-aware categories               (Section 4.4)
# Input : output/td_city_panel.csv   (from 01_classify.R)
# =====================================================================
source("R/functions.R")
source("config.R")

res <- read.csv("output/td_city_panel.csv")
r25 <- res[res$period == 2025, ]
TYPES <- c("Leading", "Pressure", "Sprawl", "Lagging")
HEAD  <- c("Anchor", "Isolated Pole", "Connected Periphery", "Structurally Lagging")
TCOL  <- c(Leading = "#2E8B57", Pressure = "#1F8AA6", Sprawl = "#8E5AA8", Lagging = "#D9694F")
HCOL  <- c("Anchor" = "#2E8B57", "Isolated Pole" = "#5A6B78",
           "Connected Periphery" = "#D9822B", "Structurally Lagging" = "#C0392B")

## ---- Table 1: composition by window (Section 4.1) ------------------
tab1 <- round(100 * prop.table(table(res$period, factor(res$type, TYPES)), 1), 1)
print(tab1)
write.csv(tab1, "output/table1_composition_by_window.csv")
# Expected 2025 row: Leading 35.0, Pressure 31.9, Sprawl 8.0, Lagging 25.2.

## ---- Section 4.2: the CP vs SL comparison ---------------------------
acc <- lagging_access(r25, radius = 100)
acc <- merge(acc, r25[, c("ID_UC_G0", "MT_POP_TOT_2025")], by = "ID_UC_G0")
cp <- acc[acc$sysaware == "Connected Periphery", ]
sl <- acc[acc$sysaware == "Structurally Lagging", ]
s42 <- data.frame(
  group  = c("Connected Periphery", "Structurally Lagging"),
  n      = c(nrow(cp), nrow(sl)),
  median_pop          = c(median(cp$MT_POP_TOT_2025), median(sl$MT_POP_TOT_2025)),
  median_dist_nearest = c(median(cp$dist_nearest_leading), median(sl$dist_nearest_leading)),
  median_leading_100km = c(median(cp$n_leading_100km), median(sl$n_leading_100km)))
print(s42)
write.csv(s42, "output/section42_cp_vs_sl.csv", row.names = FALSE)
# Expected: n 601 / 729; median pop ~176,000 / ~182,000;
#           median distance 48 km / 86 km; leading within 100 km: 3 / 1.

## ---- Figure 4 -------------------------------------------------------
r25$LSE_pct <- pct_within(r25$LSE, r25$country)
lag <- merge(r25[r25$type == "Lagging", c("ID_UC_G0", "LSE_pct", "sysaware")],
             acc[, c("ID_UC_G0", "dist_nearest_leading")], by = "ID_UC_G0")
png("output/figure4_what_lse_reveals.png", width = 2400, height = 1000, res = 200)
par(mfrow = c(1, 2), mar = c(4.2, 4.2, 3, 1))
brk <- seq(0, 1, by = 0.04)
hist(lag$LSE_pct[lag$sysaware == "Structurally Lagging"], breaks = brk,
     col = "#8A959C", border = "white", xlab = "LSE, within-country percentile rank",
     ylab = "lagging cities", main = "(a) The split among lagging cities")
hist(lag$LSE_pct[lag$sysaware == "Connected Periphery"], breaks = brk,
     col = "#D9822B", border = "white", add = TRUE)
abline(v = 0.5, lty = 2); legend("topleft", bty = "n",
       fill = c("#D9822B", "#8A959C"),
       legend = c(sprintf("Connected Periphery (n=%d)", nrow(cp)),
                  sprintf("Structurally Lagging (n=%d)", nrow(sl))))
boxplot(dist_nearest_leading ~ factor(sysaware,
        c("Connected Periphery", "Structurally Lagging")), data = lag,
        outline = FALSE, col = c("#D9822B", "#8A959C"),
        ylab = "distance to nearest leading city (km)", xlab = "",
        main = "(b) Access to the national leading set")
text(1:2, s42$median_dist_nearest, sprintf("median %.0f km", s42$median_dist_nearest),
     pos = 3, font = 2)
dev.off()

## ---- Figures 5 and 6: stacked compositions --------------------------
stack_fig <- function(mat, cols, file, main, xlab) {
  png(file, width = 2400, height = 1100, res = 200)
  par(mar = c(4.2, 16, 3, 6), xpd = TRUE)
  barplot(t(mat), horiz = TRUE, col = cols, border = "white",
          las = 1, xlab = xlab, main = main, xlim = c(0, 100))
  legend("bottom", inset = c(0, -0.22), horiz = TRUE, bty = "n",
         fill = cols, legend = colnames(mat), cex = 0.85)
  dev.off()
}
regs <- rev(c("South Asia", "Sub-Saharan Africa", "Middle East & North Africa",
              "East Asia & Pacific", "Latin America & Caribbean",
              "Europe & Central Asia", "North America"))
m5 <- 100 * prop.table(table(r25$wb_region, factor(r25$type, TYPES)), 1)[regs, ]
stack_fig(m5, TCOL, "output/figure5_typology_by_region.png",
          "Urban growth typology, 2025 window", "% of classified cities")
h  <- r25[r25$sysaware %in% HEAD, ]
m6 <- 100 * prop.table(table(h$wb_region, factor(h$sysaware, HEAD)), 1)[regs, ]
stack_fig(m6, HCOL, "output/figure6_sysaware_by_region.png",
          "The four system-aware categories, 2025 window",
          "% of Leading + Lagging cities")
write.csv(m5, "output/figure5_data_region.csv"); write.csv(m6, "output/figure6_data_region.csv")
m5i <- 100 * prop.table(table(r25$wb_income, factor(r25$type, TYPES)), 1)
m6i <- 100 * prop.table(table(h$wb_income,  factor(h$sysaware, HEAD)), 1)
write.csv(m5i, "output/figure5_data_income.csv"); write.csv(m6i, "output/figure6_data_income.csv")

message("02_results_main.R done; see output/.")
