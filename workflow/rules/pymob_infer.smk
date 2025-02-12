rule pymob_infer:
    input:
        unpack(_get_input_rule_pymob_infer)
    output:
        "results/{scenario}/out.txt", 
        "results/{scenario}/log.txt", 
        "results/{scenario}/numpyro_posterior.nc", 
        "results/{scenario}/combined_pps_figure_diclofenac.png", 
        "results/{scenario}/prior_predictive.png", 
        "results/{scenario}/posterior_predictive.png", 
        "results/{scenario}/combined_pps_figure_diuron.png", 
        "results/{scenario}/combined_pps_figure_naproxen.png", 
        "results/{scenario}/pairs_posterior.png", 
        "results/{scenario}/trace.png", 
        "results/{scenario}/svi_loss_curve.png", 
        "results/{scenario}/settings.cfg", 
        "results/{scenario}/probability_model.png", 

    conda: config["pymob_infer"]["conda_env"]

    threads: config["pymob_infer"]["cores"]
    resources:
        mem_mb=lambda wildcards, threads: threads * 4000

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
        echo "Running Workflow for {input.config}" > {output}
        export JAX_ENABLE_X64={params.jax_x64}
        export XLA_FLAGS="--xla_force_host_platform_device_count={params.cores}"

        pymob-infer \
            --case_study={params.case_study} \
            --scenario={wildcards.scenario} \
            --package=.. \
            --n_cores {params.cores} \
            --inference_backend={params.backend}
        """
