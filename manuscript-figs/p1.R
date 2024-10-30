library(tidyverse)
library(here)
df <- read_csv(here("manuscript-figs", "all_dat.csv"))
df <- df %>%
  mutate(
    age_group = ifelse(age_group == "[80,100]", "[80,120]", age_group),
    source = case_when(
      str_detect(source, "allofus") ~ 'All of Us',
      str_detect(source, "pharmetrics") ~ "Pharmetrics+",
      str_detect(source, "emis") ~ 'IMRD-EMIS',
      str_detect(source, "imrd-uk") ~ "IMRD-THIN",
      str_detect(source, "ukbb") ~ 'UK BioBank',
      TRUE ~ NA
    ),
    source = factor(source,
                    levels = c(
                      "All of Us",
                      "Pharmetrics+",
                      "IMRD-EMIS",
                      "IMRD-THIN",
                      "UK BioBank"
                      )
                    ),
  )

top_plot = df |> 
  filter(meas == "no", lb == "1-year lookback") |> 
  mutate(loc = "top")
  
bottom_plot = df |> 
  filter(meas == "yes", lb == "3-year lookback") |> 
  mutate(loc = "bottom")

pl = bind_rows(top_plot, bottom_plot) |> 
  filter(sex == "All")

pl2 = pl |> 
  select(age_group, n, prefrail, frail, robust, source, fi, loc, country) |>
  pivot_longer(cols = prefrail:robust, names_to = "f_cat", values_to = "prop") |> 
  mutate(age_group_num = readr::parse_number(substr(age_group, start = 1, stop = 3))) |> 
  drop_na(age_group) |> 
  mutate(f_cat = factor(f_cat, levels = c("robust", "prefrail", "frail")))

p1 = pl2|>
  filter(loc == "top") |> 
  ggplot(aes(x = age_group_num, y = prop,
             fill = f_cat, shape = fi, color = f_cat)) +
  geom_point( size=2.5, color = "white") + 
  geom_line() + 
  facet_grid(.~source) +
  theme_minimal(base_size = 14) + 
  theme(
    # remove legend
    legend.position = "none",
    strip.text.y = element_blank(),
    plot.subtitle = element_text(hjust = 1),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8)#,
    #plot.title.position = "plot"
        ) +
  labs(color = "Frailty Category",
       subtitle = expression(italic("1-year lookback, without eFI measurements")),
       fill = "Frailty Category",
       x = "Age Group",
       y = "Prevalence of Frailty Category") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     breaks = seq(0, 1, 0.1)) + 
  scale_x_continuous(breaks = seq(40, 80, 5), labels = unique(pl2$age_group)) +
  scale_color_manual(values = c("#3ca951", "#efb118", "#ff725c")) + 
  scale_fill_manual(values = c("#3ca951", "#efb118", "#ff725c")) +
  scale_shape_manual(values = c(21, 24)) + 
  guides(shape = guide_legend(override.aes = list(color = "black", fill = "black") ) ) 

p2 = pl2|>
  filter(loc == "bottom") |> 
  ggplot(aes(x = age_group_num, y = prop,
             fill = f_cat, shape = fi, color = f_cat)) +
  geom_point( size=2.5, color = "white") + 
  geom_line() + 
  facet_grid(.~source) +
  theme_minimal(base_size = 14) + 
  theme(
    # remove legend
    legend.position = "bottom",
    strip.text.y = element_blank(),
    plot.subtitle = element_text(hjust = 1),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8)
  ) +
  labs(color = "Frailty Category",
       fill = "Frailty Category",
       x = "Age Group",
       subtitle = expression(italic("UK 3-year lookback, with eFI measurements")),
       y = "Prevalence of Frailty Category",
       caption = "Frailty Prevalence by Data Source",
       shape = "Frailty Index") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     breaks = seq(0, 1, 0.1)) + 
  scale_x_continuous(breaks = seq(40, 80, 5), labels = unique(pl2$age_group)) +
  scale_color_manual(values = c("#3ca951", "#efb118", "#ff725c")) + 
  scale_fill_manual(values = c("#3ca951", "#efb118", "#ff725c"))+
  scale_shape_manual(values = c(21, 24)) + 
  guides(shape = guide_legend(override.aes = list(color = "black", fill = "black") ) ) 

library(patchwork)
# collect x axis labels
(p1 / p2)  + plot_layout(axis_titles = "collect")

ggsave(file = here("manuscript-figs", "fig1-big.png"), width = 10, height = 10, dpi = 300)
