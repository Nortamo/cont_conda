# Instructions

1. Build the container somwhere `build_container.sh`
    - Example definition file in `centos_base.def`
    - copy the container to the base of this repository 
    - set the correct name in `vars.sh`
2. Create the squashfs `copy_and_squash.sh`
    - Define target and squashfs name in `vars.sh`
    - Initial copy to build directory might take quite a while.
3. Generate a deploy folder which contains all the needed components `generate_bin.sh`
    - By default The script will generate executable wrappers for everything in `path_to_target/bin`
    - Remove them after generation or comment out the loop in `generate_bin.sh` if not relevant.
    - Then you can create your own wrapper
4. Move the deploy folder where you want it and set the `PATH` variable to the bin folder


Example wrapper file named `my_command` which could be placed in `deploy/bin`

```bash
source ../common.sh 
singularity exec $_BIND_FLAGS --overlay=../$_SQUASH_FS_NAME ../$_IMG_NAME my_command $@`
```

`chmod +x my_command` to make it executable.
