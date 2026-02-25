
library(readr)
library(dplyr)
library(lubridate)
library(tidyverse)

# raw and skipping first row containing metadata
raw1 <- read_csv("raw_data_large/YazanAbdullatif_glucose_10-2-2026.csv", skip = 1)

# sample with first 15 rows
raw1_data_sample <- raw1 %>%
  head(15) %>%
  mutate(`Device Timestamp` = as.character(`Device Timestamp`))

# Save to raw_data_small/
write_csv(raw1, "raw_data_small/raw_1_skipped.csv")
