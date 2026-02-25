# Process_data.R


library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(purrr)
library(ggplot2)
library(tidyverse)

# Read from raw_data_small/
raw1 <- read_csv("raw_data_small/raw_1_skipped.csv")

cleaned_data <- raw1 %>%
  # Keep only historic glucose readings
  filter(`Record Type` == 0) %>%
  # Select only needed columns (historic glucose and timestamps)
  select(
    timestamp = `Device Timestamp`,
    glucose = `Historic Glucose mg/dL`
  ) %>%
  # Convert timestamp to POSIXct
  mutate(
    timestamp = dmy_hm(timestamp),
    glucose = as.numeric(glucose)
  ) %>%
  # Remove missing glucose values
  filter(!is.na(glucose)) %>%
  # Sort by time - ascending
  arrange(timestamp)


# Save full cleaned data
write_csv(cleaned_data, "raw_data_small/clean_data_full.csv")
str(cleaned_data)
