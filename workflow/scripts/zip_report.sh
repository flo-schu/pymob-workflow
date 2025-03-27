#!/bin/bash

# Separate the first argument and gather the rest into an array
zip_file_relative="$1"
shift  # Remove the first argument from the list
# The remaining arguments will now be accessible via "$@"

# Convert the remaining arguments into an array
SCENARIOS=("$@")

# Define the base directory
case_study_dir="$PWD"
case_study=$(basename "$PWD")
base_dir=$(dirname "$PWD")

# Create a directory to store the zip files if it doesn't exist
mkdir -p "${base_dir}"

# Define the name of the zip file
zip_file="${case_study_dir}/${zip_file_relative}$"
echo "$zip_file"
echo "$SCENARIOS"

# Loop through each scenario directory
for scenario in "${SCENARIOS[@]}"; do
    if [ -d "results/$scenario/reports" ]; then
        echo "zipping $scenario/reports/*"
        
        # Zip the contents of the reports directory
        cd "results/$scenario/"
        zip -r "$zip_file" "reports/"*
        cd "$case_study_dir"
    fi
done