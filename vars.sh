#!/bin/bash

_SQUASH_FS_NAME=python_geo.sqfs
_IMG_NAME=centos_base.sif


#TARGET=/appl/soft/bio/bioconda/miniconda3/

# Installation paths and env names are arbitrary 
# Just don't use a top level folder which exists on the host
# As our tactic for maximum compatibility is to mount everything
_INSTPATH=/CSC_SING_INST
ENV_NAME=E1
TARGET=$_INSTPATH/conda

# Name of file to install environment from 
SPEC_FILE=geoconda38-spec.txt
# If the installation also exists elsewhere on the host
# Mask it inside the container to avoid issues.
MASK_DIR=/appl/soft/geo/conda/
# Generate wrappers for executables 
WRAPPERS=true
# Mount host file system during installation phase
MOUNT_DURING_INSTALL=false


# Define environment variables here which should be added to the 
# Launch script
# These could also be part of a module?

export _EXTRA_ENV_PYTHONPATH="$TARGET/envs/$ENV_NAME/share/qgis/python:\$PYTHONPATH"
export _EXTRA_ENV_PYTHONPATH="$TARGET/envs/$ENV_NAME/share/qgis/python/plugins:$_EXTRA_ENV_PYTHONPATH"
export _EXTRA_ENV_GDAL_DATA="$TARGET/envs/$ENV_NAME/share/gdal"
export _EXTRA_ENV_PROJ_LIB="$TARGET/envs/$ENV_NAME/share/proj"
export _EXTRA_ENV_CPL_ZIP_ENCODING="UTF-8"
export _EXTRA_ENV_UDUNITS2_XML_PATH="$TARGET/envs/$ENV_NAME/share/udunits/udunits2.xml"
export _EXTRA_ENV_PDAL_DRIVER_PATH="$TARGET/envs/$ENV_NAME/lib"


