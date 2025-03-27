rule pymob_infer:
    input:
        unpack(_get_input_rule_pymob_infer)
    output:
        out="results/{scenario}/out.txt", 
        log="results/{scenario}/log.txt", 
        posterior=f"results/{{scenario}}/{config['pymob_infer']['backend']}_posterior.nc", 
        prpc="results/{scenario}/prior_predictive.png", 
        popc="results/{scenario}/posterior_predictive.png", 
        pairs="results/{scenario}/posterior_pairs.png", 
        trace="results/{scenario}/posterior_trace.png", 
        settings="results/{scenario}/settings.cfg", 
        prob_model="results/{scenario}/probability_model.png",
        report="results/{scenario}/report.md", 

    conda: config["pymob_infer"]["conda_env"]

    threads: config["pymob_infer"]["cores"]

    params:
        case_study=config["case_study"],
        cores=config["pymob_infer"]["cores"],
        backend=config["pymob_infer"]["backend"],
        jax_x64=config["pymob_infer"]["jax_x64"],

    log: "logs/pymob_infer_{scenario}.log"
    # TODO: Integrate multistart SVI and multichain nuts
    # TODO: Integrate datalad :) unlock, compute save. Write the last commit 
    # id into the commit message for reproducibility.
    shell: """
        echo "Running Workflow for {input.config}" > {output.out}
        export JAX_ENABLE_X64={params.jax_x64}
        export XLA_FLAGS="--xla_force_host_platform_device_count={params.cores}"
        echo $XLA_FLAGS > {output.out}
        echo $JAX_ENABLE_X64 > {output.out}

        pymob-infer \
            --case_study={params.case_study} \
            --scenario={wildcards.scenario} \
            --package=.. \
            --n_cores {params.cores} \
            --inference_backend={params.backend}
        """

rule compile_report:
    input:
        report="results/{scenario}/report.md", 
    output:
        f"results/{{scenario}}/reports/{config['case_study']}_{{wildcards.scenario}}.tex", 
        f"results/{{scenario}}/reports/{config['case_study']}_{{wildcards.scenario}}.html", 
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