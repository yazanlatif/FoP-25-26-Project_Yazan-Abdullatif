# test_functions.R

source("functions.R")

# Create small test data
test_data <- data.frame(
  timestamp = seq(ymd_hms("2026-01-01 00:00:00"), by = "5 min", length.out = 10),
  glucose = c(100, 110, 120, 130, 140, 135, 125, 115, 105, 95)
)

# Test metrics function
metrics <- calculate_metrics(test_data)
print("Metrics function works:")
print(metrics)

# Test plot functions
p1 <- plot_timeseries(test_data)
p2 <- plot_boxplot(test_data, metrics)
p3 <- plot_histogram(test_data, metrics)

print("All plot functions work!")