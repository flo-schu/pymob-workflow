
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
        mkdir "results/{wildcards.scenario}/reports" 
        cd "results/{wildcards.scenario}"
        pandoc --extract-media reports/media/{params.case_study}_{wildcards.scenario} report.md -o reports/{params.case_study}_{wildcards.scenario}.tex
        pandoc --extract-media reports/media/{params.case_study}_{wildcards.scenario} report.md -o reports/{params.case_study}_{wildcards.scenario}.html
        cd ../..
        """