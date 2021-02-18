## Usage

`cont_conda /path/to/congif.yaml /path/to/install/to`

Will create a wrappend singularity installation based on `config.yaml`.
It is assumed that any required conda environment file and pip requirement file
is in the same directory as the config.

`example_inputs` contains a basic env definition and you can test it with:

```
cont_conda example_inputs/def.yaml /path/to/install
```

## Creating the input

The tool support both explicit and yaml files for the conda env file.
These can be produced with:

```
export CONDA_DEFAULT_ENV=target_env_name

conda env export > env.yaml

conda list --explicit > env.txt
```

