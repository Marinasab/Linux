#!/usr/bin/env Rscript

# Define log file path within the container
log_path <- "/app/5_R_outputs.txt"

# Initialize log file with a header
writeLines("R Analysis Log", con = log_path)

# Load CSV data from the file created by the Bash script
data_table <- read.csv("example.csv", header = TRUE)

# Function to write logs to both console and file
record_log <- function(text) {
  cat(text, "\n")
  write(text, file = log_path, append = TRUE)
}

# Function to sort data by weight in ascending order
sort_weight_data <- function() {
  sorted_result <- data_table[order(data_table$Weight, decreasing = FALSE), ]
  record_log("\nArranging Data by Weight (Low to High):")
  record_log(capture.output(print(sorted_result)))
  record_log("--- Finished Sorting by Weight ---")
}

# Function to calculate total weight per species
sum_weight_by_type <- function() {
  total_weights <- aggregate(Weight ~ Species, data = data_table, FUN = sum)
  record_log("\nCalculating Total Weight per Species:")
  record_log(capture.output(print(total_weights)))
  record_log("--- Finished Total Weight Calculation ---")
}

# Function to count records per species
count_type_records <- function() {
  type_counts <- table(data_table$Species)
  record_log("\nCounting Records for Each Species:")
  record_log(capture.output(print(type_counts)))
  record_log("--- Finished Species Record Count ---")
}

# Function to count males and females
count_gender_totals <- function() {
  gender_totals <- table(data_table$Sex)
  record_log("\nCounting Males and Females:")
  record_log(capture.output(print(gender_totals)))
  record_log("--- Finished Gender Count ---")
}

# Interactive menu function with a different style
display_choices <- function() {
  while (TRUE) {
    cat("\nAvailable Actions:\n")
    cat("1. Sort Data by Weight\n")
    cat("2. Calculate Total Weight by Species\n")
    cat("3. Count Records per Species\n")
    cat("4. Count Males and Females\n")
    cat("5. Quit\n")
    cat("Choose an action (1-5): ")
    flush.console()  # Ensure prompt appears immediately
    user_input <- as.integer(readLines("stdin", n = 1))
    
    if (is.na(user_input) || length(user_input) == 0) {
      record_log("Error: Please enter a valid number (1-5).")
      next
    }
    
    if (user_input == 1) sort_weight_data()
    else if (user_input == 2) sum_weight_by_type()
    else if (user_input == 3) count_type_records()
    else if (user_input == 4) count_gender_totals()
    else if (user_input == 5) {
      record_log("Analysis completed and shutting down")
      break
    } else {
      record_log("Invalid selection. Please choose 1-5.")
    }
  }
}

# Start the interactive menu
display_choices()
