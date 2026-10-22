# Territorial Development Index: Global Explorer

**Live dashboard: https://hobark.github.io/td-dashboard-public/**

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

## Using the dashboard

- Drag the timeline, or press play, to move across the 2005 to 2025 windows
- Switch between the growth typology and the system-aware view
- Pick a World Bank region to see city counts by country and category
- Scroll to zoom, drag to pan, hover any city for its classification

Everything is computed within each country, so each map is a mosaic of national classifications, not a global ranking.

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
