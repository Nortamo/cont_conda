#!/usr/bin/env python3
import yaml
import sys
input_file=sys.argv[1]

yaml_file=open(input_file)
pyf = yaml.load(yaml_file, Loader=yaml.FullLoader)



SQUASH_FS_NAME=pyf["overlay_name"]
IMG_NAME=pyf["sing_image"]
INSTPATH="/CSC_SING_INST"
install_root=INSTPATH
ENV_NAME=pyf["env_name"]
TARGET=install_root+"/conda/"
env_root=install_root+"/conda/envs/"+ENV_NAME


ENV_FILE=pyf["env_file"]
REQUIREMENTS_TXT=pyf["pip_installs"]
WRAPPERS=pyf["wrappers"]
CV=pyf["conda_version"]
PRE_INSTALL=pyf["pre_install"]
POST_INSTALL=pyf["post_install"]
if REQUIREMENTS_TXT != None:
    POST_INSTALL=["pip install -r {}".format(REQUIREMENTS_TXT)]+POST_INSTALL
    
EC=""
FF="--file"
if ENV_FILE.split(".")[1] == "yaml":
    EC="env"
    FF="-f"

with open('_sing_inst_script.sh',"w") as fp:
    fp.write("""
export install_root={install_root}
export env_root={env_root}
set -e
cp {ENV_FILE} {INSTPATH}
cp {REQUIREMENTS_TXT} {INSTPATH}
cd {INSTPATH}
curl https://repo.anaconda.com/miniconda/Miniconda3-{CV}-Linux-x86_64.sh --output Miniconda_inst.sh
bash Miniconda_inst.sh -b -p {TARGET}
eval "$({TARGET}/bin/conda shell.bash hook)"
{PRE_INSTALL}
conda {EC} create --name {ENV_NAME} {FF} {ENV_FILE}
conda activate {ENV_NAME}
{POST_INSTALL}
cd {TARGET}
rm -rf $(ls | sed 's/envs//g' | tr '\\n' ' ')
""".format(EC=EC,POST_INSTALL="\n".join(POST_INSTALL),PRE_INSTALL="\n".join(PRE_INSTALL),INSTPATH=INSTPATH,ENV_NAME=ENV_NAME,TARGET=TARGET,ENV_FILE=ENV_FILE,REQUIREMENTS_TXT=REQUIREMENTS_TXT, CV=CV,env_root=env_root,install_root =install_root,FF=FF)
    )

ISOLATE=pyf["isolate"]
MOUNT_DURING_INSTALL=pyf["mount_during_install"]
if ISOLATE:
    MOUN_DURING_INSTALL=False

# vars.sh
with open('vars.sh','w') as fp:
    fp.write("""
SQUASH_FS_NAME={SQUASH_FS_NAME}
IMG_NAME={IMG_NAME}
INSTPATH={INSTPATH}
TARGET={TARGET}
ENV_NAME={ENV_NAME}
MOUNT_DURING_INSTALL={MOUNT_DURING_INSTALL}
ISOLATE={ISOLATE}
WRAPPERS={WRAPPERS}
""".format(WRAPPERS=WRAPPERS,INSTPATH=INSTPATH,SQUASH_FS_NAME=SQUASH_FS_NAME,IMG_NAME=IMG_NAME,TARGET=TARGET,ENV_NAME=ENV_NAME,MOUNT_DURING_INSTALL=MOUNT_DURING_INSTALL,ISOLATE=ISOLATE)
    )

with open('envs.txt','w') as fp:
    fp.write("env_root={}\n".format(env_root))
    fp.write("install_root={}\n".format(install_root))
    for e in pyf["extra_envs"]:
        if e["type"] == "set":
            fp.write('export {}="{}"\n'.format(e["name"],e["value"]))
        elif e["type"] == "append":
            fp.write('export {}="${}:{}"\n'.format(e["name"],e["name"],e["value"]))
        else:
            fp.write('export {}="{}:${}"\n'.format(e["name"],e["value"],e["name"]))

