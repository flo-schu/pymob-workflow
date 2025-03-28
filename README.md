# Snakemake workflow: `pymob-workflow`

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/<owner>/<repo>/workflows/Tests/badge.svg?branch=main)](https://github.com/<owner>/<repo>/actions?query=branch%3Amain+workflow%3ATests)


A Snakemake workflow for using pymob for parameter inference and compute follow up analyses of the estimates.


## Usage

### Setup

In your project that uses `pymob` add a directory `workflow` with the contents `Snakefile` and `config.yaml`.

```Snakefile
# Snakefile
from snakemake.utils import min_version
min_version("8.27")

configfile: "workflow/config.yaml"

module pymob_workflow:
    snakefile:
        # here, it is also possible to provide a plain raw URL like "https://github.com/snakemake-workflows/dna-seq-gatk-variant-calling/raw/v2.0.1/workflow/Snakefile"
        # github("flo-schu/pymob-workflow", path="workflow/Snakefile", tag="v0.3.0")
        github("flo-schu/pymob-workflow", path="workflow/Snakefile", branch="main")
    config:
        config

use rule * from pymob_workflow
```

```yaml
# config.yaml
# add the name of the case study here
case_study: NAME_OF_THE_CASE_STUDY

# list all scenarios you want to compute with the workflow
scenarios:
  - SCENARIO_1
  - SCENARIO_2

# decide if you want to compute likelihood landscapes and parameterize
likelihood_landscapes:
  run: False
  n_grid_points: 100
  n_vector_points: 50
  std_dev: 2.0
  conda_env: conda_environment.yaml

# configure pymob infer
pymob_infer:
  cores: 1
  backend: numpyro
  conda_env: conda_environment.yaml
  jax_x64: True

# decide if you want to compile the report generated by pymob to html and tex 
report:
  compile: True
```

Dry run the workflow before executing: `snakemake --dryrun`

You can run snakemake locally `snakemake`
Or run snakemake on a HPC cluster `snakemake --profile hpc` this requires a hpc profile at `.config/snakemake/PROFILENAME/config.yaml` (see below)

Recommended use:
+ if pymob_infer needs to be run, run `snakemake --profile hpc`
+ if the dry_run suggests, that only the report needs to be compiled you can use simply `snakemake`, because compilation with pandoc is a matter of seconds


### Profiles

```yaml
# hpc/config.yaml
# see: https://snakemake.github.io/snakemake-plugin-catalog/plugins/executor/slurm.html
executor: slurm
jobs: 1000
default-resources:
  runtime: 1H
  mem_mb: 16000
  tasks: 1
  cpus_per_task: 1
  slurm_extra: "'--mail-type=fail --mail-user=YOURMAILADDRESS --output=YOUROUTPUTPATH/job-%x-%A.out --error=YOUROUTPUTPATH/job-%x-%A.err'"

# https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#dynamic-resources
# this can be used to dynamically set resources i can write afunction callable(wildcards [, input] [, threads] [, attempt]) (input, threads, and attempt are optional parameters)
#

set-resources:
  pymob_infer:
    runtime: 4H
    mem_mb: threads * 16000
    cpus_per_task: threads

  likelihood_landscapes:
    runtime: 2H
    mem_mb: 16000
```

https://snakemake.github.io/snakemake-plugin-catalog/plugins/executor/slurm.html

threads can be set for use with NUTS, where threads is the number of parallel chains, either by a separate profile or by use of the command line
`snakemake --profile hpc --set-resources pymob_infer:cpus_per_task=8` for 8 parallel chains

⚠ (I'm currently not sure if this works): Alternatively, this can also be specified via the cores attribute of the pymon_infer block in the local workflow/config.yaml


# TODO

* Replace `<owner>` and `<repo>` everywhere in the template (also under .github/workflows) with the correct `<repo>` name and owning user or organization.
* The workflow will occur in the snakemake-workflow-catalog once it has been made public. Then the link under "Usage" will point to the usage instructions if `<owner>` and `<repo>` were correctly set.
