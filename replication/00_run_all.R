# =====================================================================
# 00_run_all.R -- runs the full replication in order.
# From the package root:  Rscript 00_run_all.R
# =====================================================================
source("01_classify.R")        # ~1-3 min: classification, all windows
source("02_results_main.R")    # seconds: Table 1, Sec 4.2 stats, Figures 4-6
source("03_robustness.R")      # ~1-2 min: alpha/split/persistence/MA
message("Replication complete. All outputs in output/.")
