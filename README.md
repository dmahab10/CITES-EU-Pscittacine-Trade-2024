# CITES-EU-Pscittacine-Trade-2024
Answering which species was imported the most in the European Union using importer-reported quantities.

# Which species was traded the most?
This project identifies the most-traded species using importer-reported quantities and produces a ggplot.

## How to run
1) Import your CSV into R so it exists as an object called `Parrot_Trade_2024` (do not use read() in code).
2) Install packages once: install.packages(c("dplyr","ggplot2"))
3) Run the script: source("scripts/Species_top_traded_2024.R")

Outputs:
- Console: answer and top-15 table
- Plots pane: bar chart
- Files: outputs/tables/species_totals_importer_reported.csv and outputs/figures/top_species_importer_reported.png
