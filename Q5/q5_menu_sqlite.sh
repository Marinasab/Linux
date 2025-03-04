#!/bin/bash

# Define output file name as required
OUTPUT_LOG="5_output.txt"
CURRENT_CSV=""

# Simple function to log messages to both console and file
log_entry() {
    echo "$1" | tee -a "$OUTPUT_LOG"
}

# Function to display all entries for a specific species and sex, and calculate average weight
analyze_species_gender() {
    if verify_csv; then
        read -p "Enter species (OT or PF or NA): " species
        read -p "Enter sex (M or F): " gender
        log_entry "Listing entries for species '$species' and sex '$gender' in $CURRENT_CSV:"
        sqlite3 "$CURRENT_CSV" "SELECT * FROM entries WHERE Species = '$species' AND Sex = '$gender';" | tee -a "$OUTPUT_LOG"
        avg_weight=$(sqlite3 "$CURRENT_CSV" "SELECT AVG(Weight) FROM entries WHERE Species = '$species' AND Sex = '$gender';" | awk '{printf "%.2f", $1}')
        echo "Average weight for $species and sex $gender: $avg_weight" | tee -a "$OUTPUT_LOG"
        log_entry "Shown entries and average weight for species '$species' and sex '$gender': $avg_weight"
    fi
}

# Save current CSV to a new file
save_csv_copy() {
    if verify_csv; then
        read -p "Name the new database file for saving: " new_file
        cp "$CURRENT_CSV" "$new_file"
        log_entry "Saved data to new database: $new_file"
    fi
}

# Update the weight of a row by its index (adjusting for header)
modify_weight() {
    if verify_csv; then
        read -p "Enter the row number to update: " row_num
        read -p "Enter the new weight value: " new_weight
        # Get the row ID (assuming row_num matches the rowid in SQLite)
        row_id=$(sqlite3 "$CURRENT_CSV" "SELECT rowid FROM entries LIMIT 1 OFFSET $((row_num - 1));" | awk '{print $1}')
        if [ -n "$row_id" ]; then
            sqlite3 "$CURRENT_CSV" "UPDATE entries SET Weight = $new_weight WHERE rowid = $row_id;"
            log_entry "Updated weight for row $row_num to $new_weight in $CURRENT_CSV"
        else
            log_entry "Row $row_num not found in $CURRENT_CSV"
        fi
    fi
}

# Display all CSV content with numbered lines, excluding header
view_csv_list() {
    if verify_csv; then
        log_entry "Showing database content with line numbers from $CURRENT_CSV:"
        sqlite3 "$CURRENT_CSV" "SELECT * FROM entries;" | awk 'NR==1 {print $0; next} {print NR-1 ". " $0}' | tee -a "$OUTPUT_LOG"
        log_entry "Completed displaying database data"
    fi
}

# Function to display all entries for a specific species and calculate average weight
analyze_species_weight() {
    if verify_csv; then
        read -p "Enter species to search (OT or PF or NA): " species
        log_entry "Listing entries for species '$species' in $CURRENT_CSV:"
        sqlite3 "$CURRENT_CSV" "SELECT * FROM entries WHERE Species = '$species';" | tee -a "$OUTPUT_LOG"
        avg_weight=$(sqlite3 "$CURRENT_CSV" "SELECT AVG(Weight) FROM entries WHERE Species = '$species';" | awk '{printf "%.2f", $1}')
        echo "Average weight for $species: $avg_weight" | tee -a "$OUTPUT_LOG"
        log_entry "Shown entries and average weight for species '$species': $avg_weight"
    fi
}

# Add a new entry to the CSV file
add_entry() {
    if verify_csv; then
        read -p "What is the collection date (Month / Day format): " date
        read -p "What is the species type (OT or PF or NA): " species
        read -p "What is the sex (Mor F): " gender
        read -p "What is the weight: " weight
        sqlite3 "$CURRENT_CSV" "INSERT INTO entries (Date_collected, Species, Sex, Weight) VALUES ('$date', '$species', '$gender', $weight);"
        log_entry "Added entry: $date,$species,$gender,$weight to $CURRENT_CSV"
    fi
}

# Remove a row by its index (adjusting for header)
remove_row() {
    if verify_csv; then
        read -p "Enter the row number to remove: " row_num
        # Get the row ID (assuming row_num matches the rowid in SQLite)
        row_id=$(sqlite3 "$CURRENT_CSV" "SELECT rowid FROM entries LIMIT 1 OFFSET $((row_num - 1));" | awk '{print $1}')
        if [ -n "$row_id" ]; then
            sqlite3 "$CURRENT_CSV" "DELETE FROM entries WHERE rowid = $row_id;"
            log_entry "Removed row $row_num from $CURRENT_CSV"
        else
            log_entry "Row $row_num not found in $CURRENT_CSV"
        fi
    fi
}

# Verify if a CSV file exists and is accessible
verify_csv() {
    if [ -z "$CURRENT_CSV" ] || [ ! -f "$CURRENT_CSV" ]; then
        log_entry "Alert: No database file exists. Use option 1 to create one."
        return 1
    fi
    return 0
}

# Create a new CSV file with user input for filename
new_csv_file() {
    read -p "Choose a name for the database file: " file_name
    # Create the SQLite database and table if they don't exist
    sqlite3 "$file_name" "CREATE TABLE IF NOT EXISTS entries (Date_collected TEXT, Species TEXT, Sex TEXT, Weight REAL);"
    CURRENT_CSV="$file_name"
    log_entry "Generated new database file: $file_name with table 'entries'"
}

# Display menu and handle user choices
show_menu() {
    while true; do
        echo "Choose an option:"
        echo "1. CREATE CSV by name"
        echo "2. Display all CSV DATA with row INDEX"
        echo "3. Read user input for new row"
        echo "4. Read Species (e.g. OT) and display all items of that species and the AVG weight"
        echo "5. Read Species and Sex (M/F) and display all items of species-sex"
        echo "6. Save last output to new CSV file"
        echo "7. Delete row by row index"
        echo "8. Update weight by row index"
        echo "9. Exit"
        read -p "Enter your choice (1-9): " choice

        case $choice in
            1) new_csv_file ;;
            2) view_csv_list ;;
            3) add_entry ;;
            4) analyze_species_weight ;;
            5) analyze_species_gender ;;
            6) save_csv_copy ;;
            7) remove_row ;;
            8) modify_weight ;;
            9) log_entry "Program terminated"; exit 0 ;;
            *) log_entry "Invalid choice. Please select 1-9." ;;
        esac
    done
}

# Launch the menu
show_menu
