# Territorial Development Index: Global Explorer

**Live dashboard: https://hobark.github.io/td-dashboard-public/**

**New here? Start with the [guide](GUIDE.md): the idea in two questions, worked examples for Morocco, Egypt and Saudi Arabia, and what each setting does.**

An interactive map of 5,282 urban centres in 101 countries, classified by how they grow and by their exposure to growth elsewhere in their own national urban system, over five growth windows from 2000 to 2025.

## What the tool measures

**1. A four-cell growth typology.** Within each country, every city is classified by which dimension of its growth leads, using within-country standardised growth rates:

| Type | Signature |
|---|---|
| Leading | economic activity (nighttime lights) grows fastest |
| Pressure | population grows faster than economic activity |
| Sprawl | built-up area grows faster than economic activity |
| Lagging | below the national average on all three |

**2. Leading-Spillover Exposure (LSE).** A distance-weighted sum of the economic mass of a country's *leading* cities. Classical market access asks how much economic mass sits near a city; LSE asks how much *growth* does. Two neighbours of equal size and distance count the same under market access even if one is booming and the other shrinking. LSE counts only the booming one.

**3. A system-aware typology.** Crossing own growth with exposure separates places a one-dimensional label lumps together:

| | High LSE | Low LSE |
|---|---|---|
| **Leading** | Anchor | Isolated Pole |
| **Lagging** | Connected Periphery | Structurally Lagging |

## Using the explorer

- Pick a region and country in the left panel, or click any city on the map, to open a written country profile and a sortable city table
- Hover a city for its yearly growth in lights, population and built-up area, its exposure percentile and its distance to the nearest leading city
- Switch between the system-aware view and the growth typology; click a legend entry to hide or show a category

**Adjustable settings.** Every map, count and profile recomputes in the browser when a setting changes. A status line reports how many cities change category relative to the paper's settings, and "Reset to paper settings" restores them.

| Setting | Meaning | Paper setting |
|---|---|---|
| Growth window | Period over which growth is measured; any five-year window or the long run 2000 to 2025 | 2020 to 2025 |
| Distance decay | How fast a leading city's pull fades: gravity (exponent α), exponential (bandwidth in km) or a hard cut-off radius | Gravity, α = 1.5 |
| Mass of leading cities | Night lights, or population where electrification is incomplete or activity largely informal | Night lights |
| High-exposure threshold | Within-country exposure percentile above which a city counts as highly exposed | 50th (median) |
| Minimum cities per country | Countries with fewer urban centres are left unclassified | 5 |
| Leading requires absolute growth | Whether a Leading city's lights must actually grow, not just decline less than the national average | Off |

Each country profile also reports typical city spacing and suggests an exponential bandwidth suited to that country's geography.

Everything is computed within each country, so each map is a mosaic of national classifications, not a global ranking. Regions follow World Bank groupings, with Afghanistan and Pakistan under Middle East, North Africa, Afghanistan & Pakistan (MENAAP).

The previous fixed-parameter dashboard remains at [classic.html](https://hobark.github.io/td-dashboard-public/classic.html).

## Data

All inputs are open and global:

- Urban centres, population, and built-up area: GHSL Urban Centre Database (R2024A), European Commission Joint Research Centre
- Economic activity: harmonised DMSP-OLS/VIIRS nighttime lights (Li et al. 2020)
- Regions and income groups: World Bank FY2025 classification
- Country borders: Natural Earth

Countries with fewer than five urban centres are not classified.

## Replication

The `replication/` folder holds the R scripts that produce the classification and the paper's results from the compiled city panel and the urban-centre shapefile. See `replication/README.md`. Input data files are not included in this repository.

## Citation

Park, H. (2026). Measuring territorial development from publicly available data: a typology of cities and their exposure to growth. Manuscript submitted for publication.

## Author

Hogeun Park, World Bank
