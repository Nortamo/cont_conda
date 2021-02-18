## Usage

`cont_conda /path/to/congif.yaml /path/to/install/to`

Will create a wrappend singularity installation based on `config.yaml`.
It is assumed that any required conda environment file and pip requirement file
is in the same directory as the config.

`example_inputs` contains a basic env definition and you can test it with:

```
cont_conda example_inputs/def.yaml /path/to/install
```

The command can be run from anywhere (so you don't have to be in this repository),
but intermediate files are created in the current directory (they are removed when the build is completed.)
Prefer doing this on a local disk as one step is creating a squasfs image. 


## Creating the input

The tool support both explicit and yaml files for the conda env file.
These can be produced with:

```
export CONDA_DEFAULT_ENV=target_env_name

conda env export > env.yaml

conda list --explicit > env.txt
```

