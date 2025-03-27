# inspired by: https://github.com/snakemake-workflows/rna-seq-star-deseq2/blob/master/workflow/rules/common.smk

import itertools
import pandas as pd
from snakemake.utils import Paramspace, validate

validate(config, schema="../schemas/config.schema.yaml")

def get_combinations(scenario):
    # Load strings from the file using pandas
    inp = f"scenarios/{scenario}/parameters_likelihood_landscape.txt"
    df = pd.read_csv(inp, header=None, names=['params'])

    # Create a list of strings from the DataFrame
    strings = df[~df['params'].str.startswith('#')]['params'].tolist()
    
    # Generate unique pairs
    pairs = list(itertools.combinations(strings, 2))

    # Create a DataFrame from the pairs
    return pd.DataFrame(pairs, columns=['parx', 'pary'])


def get_final_output():
    final_output = expand(
        "results/{scenario}/out.txt",
        scenario=config["scenarios"],
    )

    extra_targets = config["pymob_infer"].get("extra_targets", [])
    if len(extra_targets) > 0:
        final_output.extend(expand(
            "results/{scenario}/{target}",
            scenario=config["scenarios"], target=extra_targets
        ))

    if config["report"]["compile"]:
        for scenario in config["scenarios"]:
            final_output.extend(expand(
                "results/{scenario}/results/{target}",
                scenario=config["scenarios"], target=[
                    f"reports/{config['case_study']}_{scenario}.tex",
                    f"reports/{config['case_study']}_{scenario}.html"
                ]
            ))

    if config["likelihood_landscapes"]["run"]:
        for scenario in config["scenarios"]:
            paramspace = Paramspace(
                dataframe=get_combinations(scenario),
                filename_params=["parx", "pary"],
                filename_sep="__",
                param_sep="~",
            )
            # get all the variables to plot a PCA for
            final_output.extend(
                expand(
                    "results/{scenario}/likelihood_landscapes/{params}.png", 
                    params=paramspace.instance_patterns, scenario=scenario
                )
            )
    return final_output


# Function to generate input paths based on input tuple index
def _get_input_rule_pymob_infer(wildcards):
    # Access tuple values using the index from your wildcards
    # Construct and return the necessary list/dictionary of input files
    return {
        "config": f"scenarios/{wildcards.scenario}/settings.cfg",
    }


# Function to generate input paths based on input tuple index
def _get_input_rule_likelihood_landscapes(wildcards):
    # Access tuple values using the index from your wildcards
    # Construct and return the necessary list/dictionary of input files
    return {
        "config": f"scenarios/{wildcards.scenario}/settings.cfg",
        "posterior": f"results/{wildcards.scenario}/numpyro_posterior.nc",
    }
