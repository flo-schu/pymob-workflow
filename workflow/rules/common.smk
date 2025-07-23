# inspired by: https://github.com/snakemake-workflows/rna-seq-star-deseq2/blob/master/workflow/rules/common.smk
import datetime
import itertools
import pandas as pd
from snakemake.utils import Paramspace, validate

validate(config, schema="../schemas/config.schema.yaml")

# fix the time of the first execution of the script to use
# for timestamped output 
workflow_time = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M")

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
        "results/{scenario}/{target}",
        scenario=config["scenarios"], 
        target=[
            f"{config['pymob_infer']['backend']}_posterior.nc",
            "out.txt",
            "report.md",
            "settings.cfg"
        ]
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
                "results/{scenario}/reports/{case_study}_{scenario}.{ext}",
                scenario=scenario, ext=["tex"], case_study=config['case_study']
            ))
            final_output.append(
                f"results/_reports/{config['case_study']}_{workflow_time}.zip"
            )

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
        "posterior": f"results/{wildcards.scenario}/{config['pymob_infer']['backend']}_posterior.nc",
    }

# Function to generate input paths based on input tuple index
def _get_input_rule_report(wildcards):
    # Access tuple values using the index from your wildcards
    # Construct and return the necessary list/dictionary of input files
    return {
        "config": f"scenarios/{wildcards.scenario}/settings.cfg",
        "report": f"results/{wildcards.scenario}/report.md",
    }

# Function to generate input paths based on input tuple index
def _get_input_rule_report_combination(wildcards):
    # Access tuple values using the index from your wildcards
    # Construct and return the necessary list/dictionary of input files
    return expand(
        f"results/{{s}}/reports/{config['case_study']}_{{s}}.tex", 
        s=config["scenarios"]
    )
