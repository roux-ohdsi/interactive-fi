library(tidyverse)
library(here)
library(janitor)

overall = list.files(here("docs", "data","data", "efi"),
                     pattern = "efi.csv",
                     full.names = TRUE)

read_csv_name_o = function(file){
  tmp = read_csv(file) %>%
    mutate(file = file) %>%
    janitor::clean_names() 
  
  if(str_detect(file, "Pharm")){
    print("pmtx")
    tmp = tmp %>%
      rowwise() %>%
      mutate(
        frail = n_frail/n,
        prefrail = n_prefrail/n,
        robust = n_robust/n
      )
  }
  
  tmp %>%
    select(age_group, is_female, n, prefrail, frail, file)

}

o = map_dfr(overall, read_csv_name_o) %>%
  mutate(source = case_when(
    str_detect(file, "pharmetrics") ~ "Pharmetrics",
    str_detect(file, "aou") ~ "AOU",
    str_detect(file, "emis") ~ "IMRD EMIS",
    str_detect(file, "imrd_uk") ~ "IMRD UK",
    str_detect(file, "ukbb") ~ "UKBB",
    TRUE ~ NA
  )) %>% rowwise() %>%
  mutate(sex = ifelse(is_female == 0, "Male", "Female"),
         age_group = ifelse(age_group == "[80,100)","[80,120]", age_group),
         n_frail = frail*n,
         n_prefrail = prefrail*n,
         n_robust = n-n_frail-n_prefrail,
         robust = n_robust/n) %>% #,
  #age_group = str_remove_all(age_group, "\\[|\\]|\\(|\\)")) %>%
  select(-file, -is_female) %>% ungroup()

ov = o %>%
  summarize(n = sum(n),
            n_frail = sum(n_frail),
            n_prefrail = sum(n_prefrail),
            n_robust = sum(n_robust), .by = c("age_group", "source")) %>%
  rowwise() %>%
  mutate(robust = n_robust/n,
         frail = n_frail/n,
         prefrail = n_prefrail/n) %>%
  mutate(sex = "All")

all = bind_rows(o, ov) |> 
  mutate(country = ifelse(str_detect(source, "AOU|Pharm"), "US", "UK"))|> 
  arrange(source,  sex, age_group)

cat(format_csv(all))
