# scripts/Species_top_traded_2024
# Purpose: Identify which species was traded the most and make a ggplot.
# Display: All key results are printed to the R Console, and the plot appears in the Plots pane.
# Assumptions:
#   - You already imported the CSV in R, and it is available as an object named `dat`.
#   - Column names in `Parrot_Trade` include at least:
#       "Taxon", "Importer reported quantity"
#     Optionally: "Term", "Unit", "Year".
#   - We use importer-reported quantities for consistency.

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

# --- Helper to print nice section headers in Console -----------------------
section <- function(title) {
  bar <- paste(rep("=", nchar(title) + 8), collapse = "")
  cat("\n", bar, "\n", "==  ", title, "  ==\n", bar, "\n", sep = "")
}

# 1) Light validation -------------------------------------------------------
needed_cols <- c("Taxon", "Importer.reported.quantity")
missing_cols <- setdiff(needed_cols, names(Parrot_Trade_2024))
if (length(missing_cols) > 0) {
  stop("The following columns are missing in `Parrot_Trade_2025`: ",
       paste(missing_cols, collapse = ", "),
       "/nPlease check your imported data frame.")
}

# 2) Optional filtering for year/term/unit (kept simple and explicit) -------
dat_clean <- Parrot_Trade_2024

if ("Year" %in% names(dat_clean)) {
  dat_clean <- dat_clean %>% filter(Year == 2024)
}

# Focus on counts of individual animals (comment these out if not desired)
if ("Term" %in% names(dat_clean)) {
  dat_clean <- dat_clean %>% filter(Term == "live")
}
if ("Unit" %in% names(dat_clean)) {
  dat_clean <- dat_clean %>%
    filter(is.na(Unit) | Unit == "Number of specimens")
}

# 3) Ensure quantity is numeric ---------------------------------------------
dat_clean <- dat_clean %>%
  mutate(`Importer.reported.quantity` = suppressWarnings(
    as.numeric(`Importer.reported.quantity`)
  ))

# 4) Summarise by species ----------------------------------------------------
species_totals <- dat_clean %>%
  group_by(Taxon) %>%
  summarise(total_importer_qty = sum(`Importer.reported.quantity`, na.rm = TRUE),
            .groups = "drop") %>%
  arrange(desc(total_importer_qty))

top_species <- species_totals %>% slice(1)
top15 <- species_totals %>% slice_head(n = 15)

# 5) Console outputs (clearly labeled) --------------------------------------
section("Data checks")
cat("Rows in original `dat`:", nrow(Parrot_Trade_2024), "\n")
cat("Rows after filters     :", nrow(dat_clean), "\n")
cat("Unique species (filtered):", dplyr::n_distinct(dat_clean$Taxon), "\n")

section("Answer: Which species was traded the most in the EU?")
if (nrow(top_species) == 0) {
  cat("No rows after filtering. Consider relaxing filters for Year/Term/Unit.\n")
} else {
  cat("Using importer-reported quantities:\n")
  cat("Top species:", top_species$Taxon[1], "\n")
  cat("Quantity   :", format(top_species$total_importer_qty[1], big.mark = ","), "\n")
}

section("Top 15 species (table)")
print(top15, n = 15, width = Inf)

# 6) Save outputs to disk (tables + figure) ---------------------------------
dir.create("outputs", showWarnings = FALSE)
dir.create("outputs/tables", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)

utils::write.csv(species_totals,
                 "C:/Users/Deepankar Mahabale/Documents/What Next/Projects/CITES Parrot Trade/2024/CITES-EU-Pscittacine-Trade-2024/outputs/tables/species_totals_importer_reported.csv",
                 row.names = FALSE)

# 7) Plot: visible in Plots pane AND saved to file --------------------------
section("Plot: Top 15 species by importer-reported quantity (live, 2024)")

p <- ggplot(top15, aes(x = reorder(Taxon, total_importer_qty),
                       y = total_importer_qty)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 15 species by importer-reported quantity (live, 2024)",
    x = NULL,
    y = "Number of specimens (importer-reported)"
  ) +
  theme_minimal(base_size = 12)

# Ensure the plot appears in the Plots pane in both interactive and scripted runs:
print(p)

ggsave("C:/Users/Deepankar Mahabale/Documents/What Next/Projects/CITES Parrot Trade/2024/CITES-EU-Pscittacine-Trade-2024/outputs/figures/top_species_importer_reported.png",
       plot = p, width = 8, height = 6, dpi = 300)

section("Done")
cat("Saved table: outputs/tables/species_totals_importer_reported.csv\n")
cat("Saved plot : outputs/figures/top_species_importer_reported.png\n\n")
