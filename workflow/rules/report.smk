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
        mkdir -p "results/{wildcards.scenario}/reports" 
        cd "results/{wildcards.scenario}"
        pandoc --extract-media reports/media/{params.case_study}_{wildcards.scenario} report.md -o reports/{params.case_study}_{wildcards.scenario}.tex
        pandoc --extract-media reports/media/{params.case_study}_{wildcards.scenario} report.md --standalone -o reports/{params.case_study}_{wildcards.scenario}.html
        cd ../..
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
        echo "{input.reports}"
        echo "{output.zip_file}"
        scripts/zip_report.sh {output.zip_file} {params.scenarios} &> {log}
        """
