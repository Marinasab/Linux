#!/bin/bash

# Set paths with new names
WORK_DIR=~/Linux_Course_Work/Q4
VENV_PATH=~/plant_env
CSV_FILE="$1"
LOG_FILE="./growth_logs.txt"

# Log function with simpler name
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M') - $1" >> "$LOG_FILE"
}

# Create VENV if not exists
if [ ! -d "$VENV_PATH" ]; then
  log_message "Creating new virtual env at $VENV_PATH"
  python3 -m venv "$VENV_PATH" || { log_message "Failed to create virtual env!"; exit 1; }
else
  log_message "Virtual env already exists at $VENV_PATH"
fi

# Activate VENV
source "$VENV_PATH/bin/activate" || { log_message "Failed to activate virtual env!"; exit 1; }

# Create deps file if not exists
DEPS_LIST="$WORK_DIR/required_libs.txt"
if [ ! -f "$DEPS_LIST" ]; then
  log_message "Creating dependencies file at $DEPS_LIST"
  echo "matplotlib" > "$DEPS_LIST"
  echo "numpy" >> "$DEPS_LIST"
  echo "pandas" >> "$DEPS_LIST"
  log_message "Dependencies file created"
fi

# Install dependencies
log_message "Installing dependencies from $DEPS_LIST"
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r "$DEPS_LIST" || {
  log_message "Dependency installation failed!"
  deactivate
  exit 1
}

# Check if CSV exists
[ -f "$CSV_FILE" ] || { log_message "CSV file $CSV_FILE not found!"; deactivate; exit 1; }

# Process CSV and generate plots
log_message "Processing CSV: $CSV_FILE"
while IFS=',' read -r plant_name height_data leaf_count weight_data; do
  [[ "$plant_name" == "Plant" ]] && continue

  log_message "Processing plant: $plant_name"

  # Create plant folder if not exists
  PLANT_DIR="$WORK_DIR/$plant_name"
  [ -d "$PLANT_DIR" ] || { mkdir "$PLANT_DIR"; log_message "Created folder for $plant_name at $PLANT_DIR"; }

  # Remove quotes from data
  heights=($(echo "$height_data" | tr -d '"'))
  leaves=($(echo "$leaf_count" | tr -d '"'))
  weights=($(echo "$weight_data" | tr -d '"'))

  # Run Python script with new name (improved_plant.py)
  log_message "Running script for $plant_name with height=${heights[*]}, leaf_count=${leaves[*]}, dry_weight=${weights[*]}"
  python3 "$WORK_DIR/improved_plant.py" --plant "$plant_name" --height "${heights[@]}" --leaf_count "${leaves[@]}" --dry_weight "${weights[@]}" || {
    log_message "Script failed for $plant_name!"
    continue
  }

  # Move plot files to plant folder
  for file in "${plant_name}_scatter.png" "${plant_name}_histogram.png" "${plant_name}_line_plot.png"; do
    mv "$WORK_DIR/$file" "$PLANT_DIR/"
  done
  log_message "Plots for $plant_name moved to $PLANT_DIR"
done < "$CSV_FILE"

log_message "Completed processing all plants."
deactivate
