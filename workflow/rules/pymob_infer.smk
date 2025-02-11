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

    params:
        case_study=config["case_study"]

    log: "logs/pymob_infer_{scenario}.log"
    # TODO: Integrate multistart SVI and multichain nuts
    # TODO: Integrate datalad :) unlock, compute save. Write the last commit 
    # id into the commit message for reproducibility.
    shell: """
        echo "Running Workflow for {input.config}" > {output}
        pymob-infer \
            --case_study={params.case_study} \
            --scenario={wildcards.scenario} \
            --package=.. \
            --n_cores 1 \
            --inference_backend=numpyro
        """
