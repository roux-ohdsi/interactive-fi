library(tidyverse)
library(here)
library(janitor)

#categories
categories = list.files(here("docs", "data","data"),
                        pattern = "categories",
                        full.names = TRUE)
# overall
overall = list.files(here("docs", "data","data"),
                     pattern = ".csv",
                     full.names = TRUE)

# remove categories from overall
overall = overall[!overall %in% categories]

read_csv_name_o = function(file){
  tmp = read_csv(file) %>%
    mutate(file = file,
           fi = ifelse(str_detect(file, "efi"), "efi", "vafi"),
           lb = ifelse(str_detect(file, "chronic3"), "3-year lookback", "1-year lookback"),
           meas = ifelse(str_detect(file, "meas"), "yes", "no"),
           source = case_when(
             str_detect(file, "allofus") ~ 'allofus',
             str_detect(file, "pharmetrics") ~ "pharmetrics",
             str_detect(file, "emis") ~ 'imrd-emis',
             str_detect(file, "imrd_uk") ~ "imrd-uk",
             str_detect(file, "ukbb") ~ 'ukbb',
             TRUE ~ NA
           )) %>%
    janitor::clean_names() 
  
  # if(str_detect(file, "Pharm")){
  #   print("pmtx")
  #   tmp = tmp %>%
  #     rowwise() %>%
  #     mutate(
  #       frail = n_frail/n,
  #       prefrail = n_prefrail/n,
  #       robust = n_robust/n
  #     )
  # }
  
  tmp %>%
    select(age_group, is_female, n, prefrail, frail, fi, source, lb, meas) %>%
    drop_na(age_group)

}

o = map_dfr(overall, read_csv_name_o) %>%
  rowwise() %>%
  mutate(sex = ifelse(is_female == 0, "Male", "Female"),
         age_group = ifelse(age_group == "[80,100]","[80,120]", age_group),
         n_frail = frail*n,
         n_prefrail = prefrail*n,
         n_robust = n-n_frail-n_prefrail,
         robust = n_robust/n) %>% #,
  #age_group = str_remove_all(age_group, "\\[|\\]|\\(|\\)")) %>%
  select(-is_female) %>% ungroup()

ov = o %>%
  summarize(n = sum(n),
            n_frail = sum(n_frail),
            n_prefrail = sum(n_prefrail),
            n_robust = sum(n_robust), .by = c("age_group", "source", "fi", "lb", "meas")) %>%
  rowwise() %>%
  mutate(robust = n_robust/n,
         frail = n_frail/n,
         prefrail = n_prefrail/n) %>%
  mutate(sex = "All")

all = bind_rows(o, ov) |> 
  mutate(country = ifelse(str_detect(source, "allofus|pharmetrics"), "US", "UK"),
         age_group = ifelse(str_detect(age_group, "120"), "[80,120]", age_group))|> 
  arrange(source,  sex, age_group)


# paper stats
paper_stats = all |> 
  filter(sex == "All", meas == "no") |> 
  distinct(age_group, source, n) |> 
  group_by(source) |> 
  summarize(ss = sum(n))

paper_stats2 = all |> 
  filter(sex == "All", meas == "no") |> 
  group_by(source, fi, lb) |> 
  summarize(ss = sum(n), 
            n_frail = sum(n_frail),
            n_robust = sum(n_robust),
            prop_frail = n_frail/ss*100,
            prop_robust = n_robust/ss*100)

# 
# us_1yr_only = all |> 
#   filter(country == "US", lb == "1-year lookback", fi == "efi") |> 
#   mutate(lb = "3-year lookback", meas = "no")

# us 1 year meas yes fake data
us_1yr_only_meas = all |>
  filter(country == "US", lb == "1-year lookback", meas == "no") |>
  mutate(lb = "1-year lookback", meas = "yes")

# us 3 year meas yes fake data
efi_1yr_no_meas = all |>
  filter(country == "US", lb == "1-year lookback", meas == "no") |>
  mutate(lb = "3-year lookback", meas = "yes")

# US 3 year meas no fake data
efi_3yr_US_no_meas = all |>
  filter(country == "US", lb == "1-year lookback", meas == "no") |>
  mutate(lb = "3-year lookback", meas = "no")

# UK 1 year meas no fake data
vafi_1yr_US_no_meas = all |>
  filter(country == "UK", lb == "1-year lookback", meas == "no", fi == "vafi") |>
  mutate(meas = "yes")

# US 3 year meas no fake data
vafi_3yr_US_no_meas = all |>
  filter(country == "UK", lb == "3-year lookback", meas == "no", fi == "vafi") |>
  mutate(meas = "yes")

all = all |> 
  filter(!(country == "US" & lb == "3-year lookback")) |>
  bind_rows(us_1yr_only_meas, efi_3yr_US_no_meas, efi_1yr_no_meas, vafi_3yr_US_no_meas, vafi_1yr_US_no_meas) |> # 
  distinct() %>%
  arrange(fi, country, source, lb, meas, sex, age_group)

#write_csv(all, here::here("manuscript-figs", "all_dat.csv"))

cat(format_csv(all))


# efi
# A3C3 w/ meas - UK
# A3C3 w/ meas - UK CATS
# A1C1 w/ meas - UK
# A1C1 w/ meas - UK CATS
# A3C3 w/o meas - UK
# A3C3 w/o meas - UK CATS
# A1C1 w/o meas - UK
# A1C1 w/o meas - UK CATS
# 
# t = o %>%
#   distinct(fi, source, lb, meas) %>%
#   arrange(fi, meas, lb, source)
# 
# tibble(file = list.files(here::here("docs", "data", "data"), include.dirs = FALSE)) %>% 
#   filter(str_detect(file, "categor", negate = T)) %>%
#   mutate(
#     fi = ifelse(str_detect(file, "efi"), "efi", "vafi"),
#     lb = ifelse(str_detect(file, "chronic3"), "3-year lookback", "1-year lookback"),
#     meas = ifelse(str_detect(file, "meas"), "yes", "no"),
#     source = case_when(
#       str_detect(file, "allofus") ~ 'allofus',
#       str_detect(file, "pharmetrics") ~ "pharmetrics",
#       str_detect(file, "emis") ~ 'imrd-emis',
#       str_detect(file, "imrd_uk") ~ "imrd-uk",
#       str_detect(file, "ukbb") ~ 'ukbb',
#       TRUE ~ NA
#     )
#   ) %>%
#   add_count(fi, lb, meas, source) -> tt
# 
# 






