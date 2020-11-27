
# Warning
**Issue with OOM killer not working for singularity + filesystem mounts under investigation
Use carefully in production** 

# V2 Instructions

1. Build the container somwhere `build_container.sh`
    - Example definition file in `centos_base.def`
    - copy the container to the base of this repository 
    - set the correct name in `vars.sh`

2. Generate spec file for target installation
    - `export CONDA_DEFAULT_ENV=target_env_name` 
    - `conda list --explicit > target_name-spec.txt`  

3. Define mandatory variables in `vars.sh` and add optional environment variables.

4. Create installation with `new_env_install.sh` 

5. Generate a deploy folder which contains all the needed components `generate_bin.sh`
    - By default The script will generate executable wrappers for everything in `path_to_target/bin`
    - You also disable this and can create your own wrapper
6. Move the deploy folder where you want it and set the `PATH` variable to the bin folder



# V1 instructions

## Package existing installation

1. Build the container somwhere `build_container.sh`
    - Example definition file in `centos_base.def`
    - copy the container to the base of this repository 
    - set the correct name in `vars.sh`
2. Create the squashfs `copy_and_squash.sh`
    - Define target and squashfs name in `vars.sh`
    - Initial copy to build directory might take quite a while.
3. Generate a deploy folder which contains all the needed components `generate_bin.sh`
    - By default The script will generate executable wrappers for everything in `path_to_target/bin`
    - You also disable this and can create your own wrapper
4. Move the deploy folder where you want it and set the `PATH` variable to the bin folder


Example wrapper file named `my_command` which could be placed in `deploy/bin`

```bash
source ../common.sh 
singularity exec $_BIND_FLAGS --overlay=../$_SQUASH_FS_NAME ../$_IMG_NAME my_command $@`
```

`chmod +x my_command` to make it executable.

### Note

By default the application tree `/appl` is not mounted. If the target environment
depends on other software installations in `/appl` and is also originally installed under
`/appl`, mount the dependencies and `/appl/spack`. Don't mount `/appl` as bind mounts
mask the `--overlay` mount. The singularity images might need changes to work for software environments with more complicated dependencies. 

## Package new installation
  
1. Build the container somewhere `build_container.sh`
    - Example definition file in `centos_base.def`
    - copy the container to the base of this repository 
    - set the correct name in `vars.sh`
2. Create the squashfs with `new_env_install.sh` 
    - Set container installation path (arbitrary)
    - Set the target to the folder containing the `bin` folder
    - Define installed packages in `new_env_install.sh`
    - Or use singularity shell to install manually

Steps **3** and **4** are the same as when packaging existing installation.
