library(readxl)
library(dplyr)
library(BSol.mapR)

credits <- paste("Contains OS data \u00A9 Crown copyright and database right\n",
                 # Get current year
                 format(Sys.Date(), "%Y"),
                 ". Source: Office for National Statistics licensed under the Open Government\nLicence v.3.0.",
                 " Walking speed estimtates based on Asher et. al (2012)."
)

census <- read_excel("../data/BSol-census-age-lsoa.xlsx") %>%
  mutate(
    Age = `Age (B) (7 categories)`,
    LSOA21 = `Lower layer Super Output Areas Code`
  ) %>%
  select(LSOA21, Age, Observation)

too_slow <- data.frame(
  Age = unique(census$Age),
  fraction = c(0.0, 0.77, 0.82, 0.87, 0.91, 0.98, 0.98)
)

too_slow_perc <- census %>%
  left_join(
    too_slow,
    by = join_by(Age)
  ) %>%
  mutate(
    too_slow = Observation * fraction
  ) %>%
  group_by(
    LSOA21
  ) %>%
  summarise(
    `Estimated % Walking less than 1.2m/s` = 100*sum(too_slow)/sum(Observation)
  )

map <- plot_map(
  too_slow_perc,
  "Estimated % Walking less than 1.2m/s",
  "LSOA21",
  map_title = "Estimated Percentage of Population Walking less than 1.2m/s",
  credits = credits,
  style = "cont"
)
map
save_map(map, "../figures/walking-speed-map.png")