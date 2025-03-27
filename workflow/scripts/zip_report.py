import os
import sys
import zipfile

def zip_scenarios(zip_file_relative, scenarios):
    # Define the base directory
    case_study_dir = os.getcwd()
    case_study = os.path.basename(case_study_dir)
    base_dir = os.path.dirname(zip_file_relative)

    # Create a directory to store the zip files if it doesn't exist
    os.makedirs(base_dir, exist_ok=True)

    # Define the name of the zip file
    zip_file = os.path.join(case_study_dir, zip_file_relative)
    print(f"Zip file will be created/updated at: {zip_file}")
    print(f"Scenarios to process: {scenarios}")

    # Initialize the zip file
    with zipfile.ZipFile(zip_file, 'w') as zf:  # 'w' to create a new zip file
        # Loop through each scenario directory
        for scenario in scenarios:
            reports_dir = os.path.join("results", scenario, "reports")
            if os.path.isdir(reports_dir):
                print(f"Zipping contents of: {reports_dir}")
                
                # Zip the contents of the reports directory
                for root, _, files in os.walk(reports_dir):
                    for file in files:
                        file_path = os.path.join(root, file)
                        # Write file to zip file, preserving the directory structure
                        zf.write(file_path, os.path.relpath(file_path, os.path.dirname(reports_dir)))
            else:
                print(f"Directory {reports_dir} does not exist.")

print(snakemake.output)
print(snakemake.params)
print(snakemake.input)

zip_scenarios(
    snakemake.output.zip_file, 
    snakemake.params.scenarios
)