library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(purrr)
library(ggplot2)
library(tidyverse)

# loading data --------
raw <- read_csv("YazanAbdullatif_glucose_10-2-2026.csv")
raw_data_sample <- raw %>%
  head(15)
write_csv(raw_data_sample, "raw_data_sample.csv")
# raw and skipping first row containing metadata
raw1 <- read_csv("YazanAbdullatif_glucose_10-2-2026.csv", skip = 1)

# sample with first 15 rows
raw1_data_sample <- raw1 %>%
  head(15) %>%
  mutate(`Device Timestamp` = as.character(`Device Timestamp`))  # Format for CSV

# View the sample
print(raw1_data_sample)

# Save as a new CSV file
write_csv(raw1_data_sample, "raw1_data_sample.csv")
str(raw1)

# ----------- data cleaning

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
  # Sort by time - ascening
  arrange(timestamp)

# view the results
view(cleaned_data)
str(cleaned_data)

cleaned_data_sample <- cleaned_data %>%
  head(20) %>%
  mutate(timestamp = format(timestamp, "%Y-%m-%d %H:%M"))
cleaned_data_sample

# Save as a new CSV file to be uploaded to Github
write_csv(cleaned_data_sample, "cleaned_data_sample.csv")

# Time series plot-------------

timeplot <- ggplot(cleaned_data, aes(x = timestamp, y = glucose)) +
  geom_line(linewidth = 0.3, alpha = 0.8, colour = "blue") +
  geom_hline(yintercept = c(70, 180), linetype = "dashed", colour = "gray40") +
  labs(x = "Date and time", y = "Glucose (mg/dL)", title = "historic glucose over time") +
  scale_x_datetime(date_breaks = "1 day", date_labels = "%d %b",
                   limits = as.POSIXct(c("2026-01-28", "2026-02-10")))
timeplot
# ------------------
# Glycemic Metrics

# Defining glucose ranges

TIR_UPPER <- 180 # upper limit for time in range
TIR_LOWER <- 70  # lowerlimit for TIR and TITR
TITR_UPPER <- 140 # upper limit for TITR

# Calculate glycemic metrics (with AI assistance)
glycemic_metrics <- cleaned_data %>%
  summarise(
    days_of_data = as.numeric(difftime(max(timestamp), min(timestamp), units = "days")),
    n_readings = n(), # count total number of readings
    
    min_glucose = min(glucose),
    q1_glucose = quantile(glucose, 0.25)[[1]],
    med_glucose = median(glucose),
    q3_glucose = quantile(glucose, 0.75)[[1]],
    max_glucose = max(glucose),
    mean_glucose = mean(glucose),
    sd_glucose = sd(glucose),
    cv_glucose = sd_glucose / mean_glucose,
    
    TIR = sum(glucose >= TIR_LOWER & glucose <= TIR_UPPER) / n() * 100, # percentage of time spent in TIR
    TITR = sum(glucose >= TIR_LOWER & glucose <= TITR_UPPER) / n() * 100 # percentage of time spent in TITR
  )

View(glycemic_metrics)

# ------- Box plot

box_plot <- ggplot(cleaned_data, aes(y = glucose)) +
  geom_boxplot(fill = "skyblue", alpha = 0.7, width = 0.3) +
  annotate("rect",
           xmin = -Inf,
           xmax = Inf,
           ymin = 70, ymax = 180,
           fill = "green", alpha = 0.1) +
  geom_hline(yintercept = c(70, 180), linetype = "dashed", color = "darkgreen") +
  labs(
    title = "Glucose Distribution - Box Plot",
    subtitle = paste("TIR:", round(glycemic_metrics$TIR, 1), 
                     "% | Mean:", round(glycemic_metrics$mean_glucose, 1), "mg/dL"),
    y = "Glucose (mg/dL)",
    x = ""
  ) +
  ylim(40, 250) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40"),
    axis.text.x = element_blank()
  )

print(box_plot)

# ----- Histogram
histo <- ggplot(cleaned_data, aes(x = glucose)) +
  geom_histogram(binwidth = 5, fill = "orange", color = "white", alpha = 0.8) +
  geom_vline(xintercept = c(70, 140, 180), 
             linetype = "dashed", 
             color = c("red", "orange", "darkgreen"),
             size = 0.7) +
  geom_vline(xintercept = glycemic_metrics$mean_glucose, 
             color = "blue", size = 1, linetype = "solid") +
  geom_vline(xintercept = glycemic_metrics$med_glucose,
             color = "purple", size = 1, linetype = "dotted") +
  annotate("text", x = glycemic_metrics$mean_glucose + 8, y = 50, 
           label = "Mean", angle = 90, color = "blue", size = 3) +
  annotate("text", x = glycemic_metrics$med_glucose - 8, y = 50, 
           label = "Median", angle = 90, color = "purple", size = 3) +
  labs(
    title = "Histogram - distribution",
    subtitle = paste("n =", glycemic_metrics$n_readings, "readings |",
                     "Mean:", round(glycemic_metrics$mean_glucose, 1), "mg/dL |",
                     "Median:", round(glycemic_metrics$med_glucose, 1), "mg/dL"),
    x = "Glucose (mg/dL)",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40")
  )

histo
# Save Plots

# Create figures folder if it doesn't exist
if(!dir.exists("figures")) dir.create("figures")

# Save the time series plot
ggsave("figures/timeseries.png", plot = timeplot, width = 12, height = 4, dpi = 300)

# Save the box plot
ggsave("figures/boxplot.png", plot = box_plot, width = 8, height = 6, dpi = 300)

# Save the histogram
ggsave("figures/histogram.png", plot = histo, width = 10, height = 6, dpi = 300)

# Save metrics as CSV
write_csv(glycemic_metrics, "figures/glycemic_metrics.csv")
# Results and Interpretation
# Simple Summary and Conclusion
