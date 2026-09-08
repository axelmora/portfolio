library(tidyverse)
library(gt)

format_ip <- function(outs) {
  innings <- floor(outs / 3)
  remainder <- outs %% 3
  return(as.numeric(paste0(innings, ".", remainder)))
}
# ---- 1. Load data ----------------------------------------------------------
raw <- read_csv("docs/vs_lhb.csv", show_col_types = FALSE)
raw <- raw %>%
  mutate(
    IP = format_ip(Outs))

# ---- 2. Identify qualified starters (SP) with >= 52 IP overall ------------
overall <- raw %>%
  filter(split_type == "Overall", role == "SP") %>%
  filter(IP >= 74.4) %>%
  transmute(
    pitcher_id, Name, Team, pitch_hand, age, birth_country,
    GS, IP_ov = IP, W, L, ERA_ov = ERA, WHIP_ov = WHIP,
    BAA_ov = BAA, `K%_ov` = `K%`, `BB%_ov` = `BB%`, `HR9_ov` = `HR/9`
  )

# ---- 3. Pull the vs_LHB split for those same pitchers ---------------------
vs_lhb <- raw %>%
  filter(split_type == "vs_LHB", pitcher_id %in% overall$pitcher_id) %>%
  transmute(
    pitcher_id, IP_lhb = IP, BAA_lhb = BAA,
    `K%_lhb` = `K%`, `BB%_lhb` = `BB%`, HR9_lhb = `HR/9`,
    `GO%_lhb` = `GO%`, `AO%_lhb` = `AO%`, Whiff_lhb = `Whiff%`
  )

# ---- 4. Join, rank (best vs LHB = lowest BAA, then highest K%) and keep top 10 ----
tbl <- overall %>%
  inner_join(vs_lhb, by = "pitcher_id") %>%
  arrange(BAA_lhb, desc(`K%_lhb`)) %>%
  select(-pitcher_id) %>%
  mutate(Rank = row_number(), .before = Name) %>%
  slice_head(n = 20)

# ---- 5. Build the gt table -------------------------------------------------
gt_tbl <- tbl %>%
  gt() %>%
  tab_header(
    title = "Best LMB Starting Pitchers vs. Left-Handed Batters",
    subtitle = "2026 Season · From teams no longer in the playoffs · Minimum 74.4 IP overall · Top 20, sorted by BAA vs LHB"
  ) %>%
  tab_spanner(label = "Pitcher Info", columns = c(Rank, Name, Team, pitch_hand, age, birth_country)) %>%
  tab_spanner(label = "Overall", columns = c(GS, IP_ov, W, L, ERA_ov, WHIP_ov, BAA_ov, `K%_ov`, `BB%_ov`, HR9_ov)) %>%
  tab_spanner(label = "vs LHB", columns = c(IP_lhb, BAA_lhb, `K%_lhb`, `BB%_lhb`, HR9_lhb, `GO%_lhb`, `AO%_lhb`, Whiff_lhb)) %>%
  cols_label(
    Rank = "Rank", Name = "Name", Team = "Team", pitch_hand = "Throws", age = "Age", birth_country = "Country",
    GS = "GS", IP_ov = "IP", W = "W", L = "L", ERA_ov = "ERA", WHIP_ov = "WHIP",
    BAA_ov = "BAA", `K%_ov` = "K%", `BB%_ov` = "BB%", HR9_ov = "HR/9",
    IP_lhb = "IP", BAA_lhb = "BAA", `K%_lhb` = "K%", `BB%_lhb` = "BB%",
    HR9_lhb = "HR/9", `GO%_lhb` = "GO%", `AO%_lhb` = "AO%", Whiff_lhb = "Whiff%"
  ) %>%
  fmt_number(columns = c(IP_ov, IP_lhb), decimals = 1) %>%
  fmt_number(columns = c(ERA_ov, WHIP_ov), decimals = 2) %>%
  fmt_number(columns = c(BAA_ov, BAA_lhb), decimals = 3) %>%
  fmt_percent(columns = c(`K%_ov`, `BB%_ov`, `K%_lhb`, `BB%_lhb`, `GO%_lhb`, `AO%_lhb`, Whiff_lhb),
              scale_values = FALSE, decimals = 1) %>%
  fmt_number(columns = c(HR9_ov, HR9_lhb), decimals = 2) %>%
  data_color(
    columns = BAA_lhb,
    colors = scales::col_numeric(palette = c("#1a9850", "#ffffbf", "#d73027"), domain = NULL)
  ) %>%
  cols_align(align = "center", columns = -c(Name, Team, birth_country)) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_spanners(everything())
  ) %>%
  tab_source_note(source_note = "Source: LMB 2026 pitching splits by Axel Mora") %>%
  opt_table_font(font = google_font("Roboto")) %>%
  opt_row_striping()

gt_tbl

# ---- 6. Save output (optional) --------------------------------------------
gtsave(gt_tbl, "docs/starters_vs_lhb.html")



summary_table <- read_csv("docs/summary_table.csv", show_col_types = FALSE)
summary_tabl_gt <- summary_table[,-1] %>%
  gt() %>%
  tab_header(
    title = "USA-born players' in LMP and Caribbean Series",
    subtitle = "Roster count by season and event type"
  ) %>%
  fmt_number(columns = -season, decimals = 0) %>%
  tab_source_note(source_note = "Source: MLB Stats API") %>%
  opt_table_font(font = google_font("Roboto")) %>%
  opt_row_striping()
summary_tabl_gt
gtsave(summary_tabl_gt, "docs/usa_players_lmp.html")