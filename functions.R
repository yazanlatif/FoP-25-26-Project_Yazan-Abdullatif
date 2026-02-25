# functions.R
library(dplyr)
library(ggplot2)

# Function to calculate glycemic metrics
calculate_metrics <- function(data) {
  TIR_UPPER <- 180
  TIR_LOWER <- 70
  TITR_UPPER <- 140
  
  data %>%
    summarise(
      n_readings = n(),
      min_glucose = min(glucose),
      q1_glucose = quantile(glucose, 0.25)[[1]],
      med_glucose = median(glucose),
      q3_glucose = quantile(glucose, 0.75)[[1]],
      max_glucose = max(glucose),
      mean_glucose = mean(glucose),
      sd_glucose = sd(glucose),
      cv_glucose = sd_glucose / mean_glucose,
      TIR = sum(glucose >= TIR_LOWER & glucose <= TIR_UPPER) / n() * 100,
      TITR = sum(glucose >= TIR_LOWER & glucose <= TITR_UPPER) / n() * 100
    )
}

# Function for time series plot
plot_timeseries <- function(data) {
  ggplot(data, aes(x = timestamp, y = glucose)) +
    geom_line(linewidth = 0.3, alpha = 0.8, colour = "blue") +
    geom_hline(yintercept = c(70, 180), linetype = "dashed", colour = "gray40") +
    labs(x = "Date and time", y = "Glucose (mg/dL)", title = "historic glucose over time") +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%d %b") +
    theme_minimal()
}

# Function for box plot
plot_boxplot <- function(data, metrics) {
  ggplot(data, aes(y = glucose)) +
    geom_boxplot(fill = "skyblue", alpha = 0.7, width = 0.3) +
    annotate("rect",
             xmin = -Inf,
             xmax = Inf,
             ymin = 70, ymax = 180,
             fill = "green", alpha = 0.1) +
    geom_hline(yintercept = c(70, 180), linetype = "dashed", color = "darkgreen") +
    labs(
      title = "Glucose Distribution - Box Plot",
      subtitle = paste("TIR:", round(metrics$TIR, 1), 
                       "% | Mean:", round(metrics$mean_glucose, 1), "mg/dL"),
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
}

# Function for histogram
plot_histogram <- function(data, metrics) {
  ggplot(data, aes(x = glucose)) +
    geom_histogram(binwidth = 5, fill = "orange", color = "white", alpha = 0.8) +
    geom_vline(xintercept = c(70, 140, 180), 
               linetype = "dashed", 
               color = c("red", "orange", "darkgreen"),
               size = 0.7) +
    geom_vline(xintercept = metrics$mean_glucose, 
               color = "blue", size = 1, linetype = "solid") +
    geom_vline(xintercept = metrics$med_glucose,
               color = "purple", size = 1, linetype = "dotted") +
    annotate("text", x = metrics$mean_glucose + 8, y = 50, 
             label = "Mean", angle = 90, color = "blue", size = 3) +
    annotate("text", x = metrics$med_glucose - 8, y = 50, 
             label = "Median", angle = 90, color = "purple", size = 3) +
    labs(
      title = "Histogram - distribution",
      subtitle = paste("n =", metrics$n_readings, "readings |",
                       "Mean:", round(metrics$mean_glucose, 1), "mg/dL |",
                       "Median:", round(metrics$med_glucose, 1), "mg/dL"),
      x = "Glucose (mg/dL)",
      y = "Frequency"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40")
    )
}