rule report:
    input:
        unpack(_get_input_rule_report) 

    output:
        f"results/{{scenario}}/reports/{config['case_study']}_{{scenario}}.tex", 
        f"results/{{scenario}}/reports/{config['case_study']}_{{scenario}}.html", 
    
    conda: config["pymob_infer"]["conda_env"]
    
    log: "logs/compile_report_{scenario}.log"

    params:
        case_study=config["case_study"],
    shell: """
        wd_base=$PWD
        mkdir -p "results/{wildcards.scenario}/reports" 

        # execute pandoc in results for tex generation
        cd "results/{wildcards.scenario}"
        pandoc --extract-media reports/media/{params.case_study}_{wildcards.scenario} report.md -o reports/{params.case_study}_{wildcards.scenario}.tex
        
        # execute pandoc in reports for html generation, so that the media are in media/...
        cd "reports"
        pandoc --resource-path .. --extract-media media/{params.case_study}_{wildcards.scenario} report.md --standalone -o {params.case_study}_{wildcards.scenario}.html
        
        # go back to the beginning
        cd wd_base
        """

rule combine_report_casestudy:
    input:
        reports=_get_input_rule_report_combination 
    output: 
        zip_file=f"results/_reports/{config['case_study']}_{current_datetime()}.zip",
        log=f"results/_reports/log"
    conda: config["pymob_infer"]["conda_env"]
    log: "logs/combine_report.log"
    params:
        case_study=config["case_study"],
        scenarios=config["scenarios"]
    shell: """
        # Separate the first argument and gather the rest into an array
        zip_file_relative="{output.zip_file}"

        # Convert the remaining arguments into an array
        SCENARIOS="{input.scenarios}"

        # Define the base directory
        case_study_dir="$PWD"
        case_study=$(basename "$PWD")
        base_dir=$(dirname "{output.zip_file}")

        # Create a directory to store the zip files if it doesn't exist
        mkdir -p "$base_dir"

        # Define the name of the zip file
        zip_file="$case_study_dir/$zip_file_relative$"
        echo "$zip_file"
        echo "$SCENARIOS"

        # Loop through each scenario directory
        for scenario in "$SCENARIOS"; do
            if [ -d "results/$scenario/reports" ]; then
                echo "zipping $scenario/reports/*"
                
                # Zip the contents of the reports directory
                cd "results/$scenario/"
                zip -r "$zip_file" "reports/"*
                cd "$case_study_dir"
            fi
        done
        """
    
