library(tidyverse)
library(here)

cats = list.files(here("docs", "data","data"),
           pattern = "categories",
           full.names = TRUE)

# read_csv_name = function(file){
#   read_csv(file) %>%
#     mutate(file = file) 
# }
# 

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
  
  tmp #%>%
    #select(age_group, is_female, n, prefrail, frail, fi, source)
  
}

t = map_dfr(cats, read_csv_name_o) %>%
  rename(total = count,
         prop = percent) %>% 
  rowwise() %>%
  mutate(sex = ifelse(is_female == 0, "Male", "Female"),
         age_group = ifelse(str_detect(age_group, "80,"),"[80,100]", age_group)) %>% #,
         #age_group = str_remove_all(age_group, "\\[|\\]|\\(|\\)")) %>%
  select(-file, -is_female) %>% ungroup()

tv = t %>%
  summarize(n = sum(n),
            total = sum(total, na.rm = T), .by = c("age_group", "source", "category", "fi", "lb", "meas")) %>%
  rowwise() %>%
  mutate(prop = ifelse(n == 0, 0, total/n)) %>%
  mutate(sex = "All")

all = bind_rows(t, tv) |> 
  mutate(country = ifelse(str_detect(source, "allofus|pharmetrics"), "US", "UK"),
                          age_group = ifelse(str_detect(age_group, "120"), "[80,100]", age_group))|> 
  arrange(source,  sex, age_group)

us_1yr_only = all |> 
  filter(country == "US", lb == "1-year lookback", meas == "no") |> 
  mutate(lb = "3-year lookback")

us_1yr_only_meas = all |> 
  filter(country == "US", lb == "1-year lookback", meas == "no") |> 
  mutate(meas = "yes")

us_3yr_only_meas = all |> 
  filter(country == "US", lb == "1-year lookback", meas == "no") |> 
  mutate(lb = "3-year lookback", meas = "yes")

all = all |> 
  filter(!(country == "US" & lb == "3-year lookback")) |> 
  bind_rows(us_1yr_only, us_1yr_only_meas, us_3yr_only_meas)

cat(format_csv(all))

