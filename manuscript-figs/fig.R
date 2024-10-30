library(tidyverse)
library(here)
library(table1)

l = list.files(here::here("docs", "data", "data"),
               include.dirs = FALSE, pattern = "acute1-chronic1", full.names = TRUE)

l = l[str_detect(l, "categories|meas", negate = TRUE)]

l2 = list.files(here::here("docs", "data", "data"),
               include.dirs = FALSE, pattern = "acute1-chronic1", full.names = FALSE)

l2 = l2[str_detect(l2, "categories|meas", negate = TRUE)]

# read in and combine all csv files in the vector l
df = l %>% 
  map_dfr(read_csv, .id = "source") %>% 
  mutate(source = str_remove(source, ".csv")) |> 
  mutate(n = ifelse(is.na(n), N, n)) |> 
  select(-N) |> 
  # add the vector l2 for each numeric value in source by position
  mutate(source = l2[as.numeric(source)]) |> 
  mutate(
    fi = ifelse(str_detect(source, "efi"), "efi", "vafi"),
    age_group = ifelse(age_group == "[80,100]", "[80,120]", age_group),
    source = case_when(
    str_detect(source, "allofus") ~ 'All of Us',
    str_detect(source, "pharmetrics") ~ "Pharmetrics+",
    str_detect(source, "emis") ~ 'IMRD-EMIS',
    str_detect(source, "imrd_uk") ~ "IMRD-THIN",
    str_detect(source, "ukbb") ~ 'UK BioBank',
    TRUE ~ NA
  )) |> 
  rename(sex = is_female) 

unique(df$age_group)

# df_lim = df |> 
#   filter(fi == "vafi") 

df_table = df |> 
  select(1:n_robust, fi) |> 
  pivot_wider(
    names_from = fi,
    values_from = n_prefrail:n_robust
  ) |>
  pivot_longer(cols = n_prefrail_vafi:n_robust_efi, names_to = "frailty", values_to = "n_") |> 
  mutate(sex = ifelse(sex == 1, "Female", "Male"),
         frailty = str_remove(frailty, "n_"),
         # frailty = factor(
         #      str_remove(frailty, "n_"),
         #      levels = c("robust", "prefrail", "frail")),
         source = factor(source,
                         levels = c("Pharmetrics+", "All of Us", "IMRD-EMIS", "IMRD-THIN", "UK BioBank"))) |> 
  separate(frailty, into = c("frailty", "fi"), sep = "_") |>
  # expand to create as many rows for each category in name based on value
  uncount(n_) |> 
  group_by(fi) |> 
  mutate(id = row_number()) |> 
  pivot_wider(names_from = fi, values_from = frailty) |>
  select(-n)

head(df_table)


label(df_table$age_group)   <- "Age"
label(df_table$sex)   <- "Sex"
label(df_table$vafi)    <- "VAFI Frailty Category"
label(df_table$efi)    <- "eFI Frailty Category"
label(df_table$source) <- "Data Source"

units(df_table$age_group)   <- "years"
units(df_table$sex)    <- "at birth"

t1 = table1(~ sex + age_group + efi + vafi | source, data = df_table, overall = FALSE, big.mark=",")
t1
library(flextable)

t1flex(t1) %>% save_as_docx(path = here::here("manuscript-figs", "table1.docx"), landscape = TRUE)


