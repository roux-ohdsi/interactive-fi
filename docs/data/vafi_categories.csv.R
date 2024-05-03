library(tidyverse)
library(here)

cats = list.files(here("docs", "data","data", "vafi"),
           pattern = "categories",
           full.names = TRUE)

read_csv_name = function(file){
  read_csv(file) %>%
    mutate(file = file) 
}

t = map_dfr(cats, read_csv_name) %>%
  mutate(total = count, #ifelse(str_detect(file, "aou|pharm"), count, total),
         prop = percent, #ifelse(str_detect(file, "aou|pharm"), percent, prop),
         n = total/prop, #ifelse(str_detect(file, "aou|pharm"), total/prop, n),
         n = ifelse(is.nan(n), 0, n)) %>%
  select(-count, -percent, -N) %>%
  mutate(source = case_when(
    str_detect(file, "pharmetrics") ~ "Pharmetrics",
    str_detect(file, "aou") ~ "AOU",
    str_detect(file, "emis") ~ "IMRD EMIS",
    str_detect(file, "imrd_uk") ~ "IMRD UK",
    str_detect(file, "ukbb") ~ "UKBB",
    TRUE ~ NA
  )) %>% rowwise() %>%
  mutate(sex = ifelse(is_female == 0, "Male", "Female"),
         age_group = ifelse(str_detect(age_group, "100"),"[80,120]", age_group)) %>% #,
         #age_group = str_remove_all(age_group, "\\[|\\]|\\(|\\)")) %>%
  select(-file, -is_female) %>% ungroup()

tv = t %>%
  summarize(n = sum(n),
            total = sum(total, na.rm = T), .by = c("age_group", "source", "category")) %>%
  rowwise() %>%
  mutate(prop = ifelse(n == 0, 0, total/n)) %>%
  mutate(sex = "All")

all = bind_rows(t, tv) %>% mutate(fi = "vafi")

cat(format_csv(all))

