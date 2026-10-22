# =====================================================================
# R/functions.R -- shared functions for the replication package
# "Measuring territorial development from publicly available data:
#  a typology of cities and their exposure to growth"
# Base R only. No randomness anywhere: all results are deterministic.
# =====================================================================

#' Great-circle distance matrix (km) from lon/lat vectors (haversine).
haversine_km <- function(lon, lat) {
  r <- pi / 180; lo <- lon * r; la <- lat * r; n <- length(lon)
  dlo <- outer(lo, lo, "-"); dla <- outer(la, la, "-")
  a <- sin(dla / 2)^2 +
       cos(matrix(la, n, n)) * cos(matrix(la, n, n, byrow = TRUE)) * sin(dlo / 2)^2
  2 * 6371 * asin(pmin(1, sqrt(a)))
}

#' Within-country z-score (returns zeros for degenerate sd).
zwithin <- function(x) {
  s <- sd(x); if (is.na(s) || s == 0) rep(0, length(x)) else (x - mean(x)) / s
}

#' Hierarchical four-cell typology rule (paper, Section 3.2).
classify_type <- function(zm, zp, zb) {
  ifelse(zm >= pmax(zp, zb) & zm > 0, "Leading",
  ifelse(zp >  zm           & zp > 0, "Pressure",
  ifelse(zb >  zm           & zb > 0, "Sprawl", "Lagging")))
}

#' Distance-decay weight matrix W = D^(-alpha), diagonal zero.
decay_weights <- function(D, alpha) {
  W <- D^(-alpha); W[!is.finite(W)] <- 0; W
}

#' Exposure sum over a target set: rowSums of W restricted to target columns.
#' MA  = exposure(mass, W, rep(TRUE, n))   (all cities)
#' LSE = exposure(mass, W, leading)        (leading cities only)
exposure <- function(mass, W, target) {
  Wt <- W; Wt[, !target] <- 0; as.numeric(Wt %*% mass)
}

#' Eight-cell system-aware labels (paper, Section 3.4).
sys_label <- function(type, hi) {
  lut <- c("Leading TRUE"  = "Anchor",              "Leading FALSE"  = "Isolated Pole",
           "Lagging TRUE"  = "Connected Periphery", "Lagging FALSE"  = "Structurally Lagging",
           "Pressure TRUE" = "Connected Pressure",  "Pressure FALSE" = "Isolated Pressure",
           "Sprawl TRUE"   = "Connected Sprawl",    "Sprawl FALSE"   = "Isolated Sprawl")
  unname(lut[paste(type, hi)])
}

#' Classify one country for one growth window (t0 -> t1).
#' g: data.frame with lon, lat, GC_CNT_GAD, ID_UC_G0 and the epoch columns.
classify_country_window <- function(g, t0, t1, alpha, split = "median") {
  gM <- log((g[[paste0("NTL_SUM_",    t1)]] + 1) /
            (g[[paste0("NTL_SUM_",    t0)]] + 1))          # log(1+x): zeros retained
  gP <- log(g[[paste0("MT_POP_TOT_", t1)]] / g[[paste0("MT_POP_TOT_", t0)]])
  gB <- log(g[[paste0("MT_BUS_TOT_", t1)]] / g[[paste0("MT_BUS_TOT_", t0)]])
  zM <- zwithin(gM); zP <- zwithin(gP); zB <- zwithin(gB)
  type    <- classify_type(zM, zP, zB)
  leading <- type == "Leading"

  D <- haversine_km(g$lon, g$lat); diag(D) <- 0
  W <- decay_weights(D, alpha)
  mass <- g[[paste0("NTL_SUM_", t1)]]                       # end-year mass
  MA   <- exposure(mass, W, rep(TRUE, nrow(g)))
  LSE  <- exposure(mass, W, leading)

  thr <- if (split == "median") median(LSE) else quantile(LSE, 2/3, names = FALSE)
  hi  <- if (thr > 0) LSE >= thr else rep(FALSE, nrow(g))

  data.frame(ID_UC_G0 = g$ID_UC_G0, period = t1, country = g$GC_CNT_GAD[1],
             z_ntl = zM, z_pop = zP, z_built = zB, type = type,
             MA = MA, LSE = LSE, high_LSE = hi,
             sysaware = sys_label(type, hi),
             stringsAsFactors = FALSE)
}

#' Run the full classification over all countries (>= min_n cities) and windows.
run_classification <- function(panel, windows, alpha, min_n, split = "median") {
  counts <- table(panel$GC_CNT_GAD)
  keep   <- names(counts)[counts >= min_n]
  sub    <- panel[panel$GC_CNT_GAD %in% keep, ]
  out <- do.call(rbind, lapply(windows, function(w) {
    do.call(rbind, lapply(split(sub, sub$GC_CNT_GAD),
                          classify_country_window,
                          t0 = w[1], t1 = w[2], alpha = alpha, split = split))
  }))
  rownames(out) <- NULL
  attr(out, "excluded_countries") <- sum(counts < min_n)
  attr(out, "excluded_cities")    <- sum(counts[counts < min_n])
  out
}

#' Distance from each lagging city to its country's leading set:
#' nearest-leading distance and count of leading cities within `radius` km.
lagging_access <- function(res_window, radius = 100) {
  rows <- lapply(split(res_window, res_window$country), function(g) {
    lead <- g[g$type == "Leading", ]; lag <- g[g$type == "Lagging", ]
    if (nrow(lead) == 0 || nrow(lag) == 0) return(NULL)
    r <- pi / 180
    # vectorised haversine, lag x lead
    dla <- outer(lag$lat, lead$lat, function(a, b) (b - a) * r)
    dlo <- outer(lag$lon, lead$lon, function(a, b) (b - a) * r)
    A <- sin(dla / 2)^2 +
         outer(cos(lag$lat * r), cos(lead$lat * r)) * sin(dlo / 2)^2
    D <- 2 * 6371 * asin(pmin(1, sqrt(A)))
    data.frame(ID_UC_G0 = lag$ID_UC_G0, sysaware = lag$sysaware,
               dist_nearest_leading = apply(D, 1, min),
               n_leading_100km      = rowSums(D <= radius),
               stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}

#' Within-country percentile rank.
pct_within <- function(x, group) ave(x, group, FUN = function(v) rank(v) / length(v))
