#!/bin/bash

_SQUASH_FS_NAME=example.sqfs
_IMG_NAME=centos_base.sif


_INSTPATH=/CSC_SING_INST
ENV_NAME=EXAMPLE_ENV
TARGET=$_INSTPATH/conda

# Name of file to install environment from 
ENV_YAML=example.yaml


# Explicit file does not list dependencies 
ENV_EXPLICIT=example.txt
REQUIREMENTS_TXT=requirements.txt


# If the installation also exists elsewhere on the host
# Mask it inside the container to avoid issues.
# MASK_DIR=/appl/soft/geo/conda/

# Generate wrappers for executables 
WRAPPERS=true
# Mount host file system during installation phase
# Only valid if isolate is false
MOUNT_DURING_INSTALL=false

# If true, only /scratch /projappl /users will be mounted
ISOLATE=false

# Run before conda install
PRE_INSTALL=""
# Run after conda install
POST_INSTALL=""

# Define environment variables here which should be added to the 
# Launch script
# These could also be part of a module?

########## End of input 

if [[ "$ISOLATE" -q "true"  ]];
    MOUNT_DURING_INSTALL="false"
fi

if [  ! -z "$ENV_YAML" ] && [ ! -z "$ENV_EXPLICIT"] ;then
    echo "Can't set both explicit and yaml input file"
    exit 1
fi
if [ ! -z "$ENV_EXPLICIT"  ] && [ -z "$REQUIREMENTS_TXT" ];then
    echo "Warning to requirements.txt set when using explicit environment"
fi
