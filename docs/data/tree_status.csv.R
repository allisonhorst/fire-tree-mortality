library(tidyverse)
library(janitor)

trees <- read_csv('docs/data/FTM_trees.csv') |> 
  clean_names()

bark <- read_csv('docs/data/Species_BarkThickness.csv') |> 
  clean_names() |> 
  select(genus_species, bt_coef)

# Keep the 4 species with highest count in dataset
treeCount <- trees |> count(genus_species) |> arrange(-n) |> head(20) |> filter(n > 1e4)

treeSub <- trees |> 
  filter(genus_species %in% treeCount$genus_species) |> 
  mutate(common_name = case_when(genus_species == 'Pinus_ponderosa' ~ 'Ponderosa pine',
                                 genus_species == 'Pseudotsuga_menziesii' ~ 'Douglas fir',
                                 genus_species == 'Pinus_contorta' ~ 'Lodgepole pine',
                                 genus_species == 'Abies_concolor' ~ 'White fir')) |> 
  mutate(genus_species = str_replace(genus_species, pattern = '_', replacement = ' ')) |> 
  pivot_longer(cols = yr0status:yr10status, 
               names_to = 'yr_post_fire',
               values_to = 'status') |> # 0 = alive, 1 = dead
  mutate(yr_post_fire = readr::parse_number(yr_post_fire)) |> 
  mutate(status = fct_relevel(case_when(status == 0 ~ 'live',
                            status == 1 ~ 'dead'), 'live')) |> 
  drop_na(status) |> 
  filter(times_burned == 1) |> 
  left_join(bark) |> 
  select(-species, 
         -dataset, 
         -times_burned,
         -id,
         -plot,
         -tree_num,
         -unit,
         -genus,
         -species_name,
         -subspecies
         ) |>
  select(common_name, yr_fire_name, dbh_cm, ht_m, bt_coef, yr_post_fire, status) |>
  drop_na(yr_post_fire, status, ht_m) |>
  mutate(yr_post_fire = as.numeric(yr_post_fire))

cat(format_csv(treeSub))