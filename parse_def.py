#!/usr/bin/env python3
import yaml
input_file=sys.argv[1]

yaml_file=open(input_file)
pyf = yaml.load(yaml_file, Loader=yaml.FullLoader)



_SQUASH_FS_NAME=pyf["overlay_name"]
_IMG_NAME=pyf["sing_image"]


_INSTPATH=/CSC_SING_INST
install_root=/CSC_SING_INST
env_root=/CSC_SING_INST/conda/
ENV_NAME=pyf["env_name"]
TARGET=/CSC_SING_INST/conda


ENV_YAML=example.yaml
ENV_EXPLICIT=example.txt
REQUIREMENTS_TXT=requirements.txt
WRAPPERS=true


