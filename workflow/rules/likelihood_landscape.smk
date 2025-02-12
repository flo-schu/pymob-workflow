rule likelihood_landscapes:
    input:
        unpack(_get_input_rule_likelihood_landscapes)

    output:
        "results/{scenario}/likelihood_landscapes/parx~{parx}__pary~{pary}.png"

    log: "logs/likelihood_landscapes_{scenario}_{parx}_{pary}.log"

    conda: config["pymob_infer"]["conda_env"]

    params: 
        std_dev=config["likelihood_landscapes"]["std_dev"],
        n_grid_points=config["likelihood_landscapes"]["n_grid_points"],
        n_vector_points=config["likelihood_landscapes"]["n_vector_points"]

    shell: """
        plot-likelihood-landscape \
            --config={input.config} \
            --parx={wildcards.parx} \
            --pary={wildcards.pary} \
            --std_dev={params.std_dev} \
            --n_grid_points={params.n_grid_points} \
            --n_vector_points={params.n_vector_points} \
            --idata_file="numpyro_posterior.nc" \
            --sparse \
            --center-at-posterior-mode
    """
