library(readxl)
library(dplyr)
library(BSol.mapR)

credits <- paste("Contains OS data \u00A9 Crown copyright and database right\n",
                 # Get current year
                 format(Sys.Date(), "%Y"),
                 ". Source: Office for National Statistics licensed under the Open Government\nLicence v.3.0.",
                 " Walking speed estimtates based on Asher et. al (2012)."
)

census <- read_excel("../data/BSol-census-age-sex-lsoa.xlsx") %>%
  mutate(
    Age = `Age (B) (7 categories)`,
    LSOA21 = `Lower layer Super Output Areas Code`,
    Sex = `Sex (2 categories)`
  ) %>%
  select(LSOA21, Age, Sex, Observation)

too_slow <- data.frame(
  Age = c(unique(census$Age), unique(census$Age)),
  Sex = c(rep("Male", 7), rep("Female", 7)),
  fraction = c(0.0, 0.77, 0.82, 0.87, 0.91, 0.98, 0.98,
               0.0, 0.87, 0.89, 0.96, 0.98, 1.00, 1.00)
)

too_slow_perc <- census %>%
  left_join(
    too_slow,
    by = join_by(Age, Sex)
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
  map_title = "Residents with Walking Impairment (%)\n(Unable to walk at 1.2m/s)",
  credits = credits,
  style = "cont"
)
map
save_map(map, "../output/walking-speed-map.png")


#############################################################
#           Percentage of residents aged 65+                #
#############################################################

total <- census %>%
  group_by(LSOA21) %>%
  summarize(total = sum(Observation))

older_adults <- census %>%
  filter(!grepl("under", Age)) %>%
  group_by(LSOA21) %>%
  summarize(OA = sum(Observation))

older_adult_perc <- total %>%
  left_join(older_adults,
            by = join_by(LSOA21)) %>%
  mutate(
    OA_perc = 100 * OA / total
  )

OA_map <- plot_map(
  older_adult_perc,
  "OA_perc",
  "LSOA21",
  map_title = "Residents Aged 65+ (%)",
  style = "cont"
)
OA_map
save_map(OA_map, "../output/older-adults-map.png")