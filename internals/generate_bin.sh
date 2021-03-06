#!/bin/bash

set -e
source vars.sh

mkdir -p mount_dir
squashfuse $SQUASH_FS_NAME mount_dir

ER=$TARGET/envs/$ENV_NAME
FT=$(echo $ER | sed 's@^/@@g')
BASE_DIR=$PWD
rm -rf deploy
mkdir deploy
mkdir deploy/bin
cd mount_dir/$FT/bin
executables="$(ls -p | grep -v /)"
cd $BASE_DIR


REL_PATH_CMD='DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"'

PRE_COMMAND="source \$DIR/../common.sh"

if [[ "$ISOLATE" = "True" ]]; then
    _BIND_FLAGS="-B /users:/users  -B /projappl:/projappl -B /scratch:/scratch"
    if [[ -d "/fmi" ]];then
        _BIND_FLAGS="$_BIND_FLAGS -B /fmi:/fmi"
    fi
else
    _BIND_FLAGS=$(ls -1 / | awk '!/dev/' | awk '!/local_scratch/'  | sed 's/^/\//g'  | awk '{ print $1,$1 }' | sed 's/ /:/g' | sed 's/^/-B /g' | tr '\n' ' ')
    _BIND_FLAGS="$_BIND_FLAGS -B \$DIR/../MASK:\$DIR/../bin"
fi
echo "export BIND_FLAGS=\"$_BIND_FLAGS\"" > deploy/common.sh
echo "export SQUASH_FS_NAME=$SQUASH_FS_NAME" >> deploy/common.sh
echo "export IMG_NAME=\"$IMG_NAME\"" >> deploy/common.sh
echo "export SINGULARITYENV_PATH=$ER/bin:\$PATH" >> deploy/common.sh
echo "export SINGULARITYENV_LD_LIBRARY_PATH=$ER/lib/:\$LD_LIBRARY_PATH" >> deploy/common.sh
echo "test -d /local_scratch/ && export _BIND_FLAGS=\"\$_BIND_FLAGS -B /local_scratch:/local_scratch\"" >> deploy/common.sh

# Dump extra environment variables
cat envs.txt >> deploy/common.sh


if [[ "$WRAPPERS" == "True"  ]]; then
while IFS= read -r executable; do
    if [[ -x "mount_dir/$FT/bin/$executable" ]]; then
        cmd=$(echo "$ER//bin/$executable" | sed 's@//*@/@g')
        RUN_CMD="singularity --silent exec \$_BIND_FLAGS --overlay=\$DIR/../\$SQUASH_FS_NAME \$DIR/../\$IMG_NAME $cmd \"\$@\""
        echo "#!/bin/bash" > deploy/bin/$executable
        echo "$REL_PATH_CMD" >> deploy/bin/$executable
        echo "$PRE_COMMAND" >> deploy/bin/$executable
        echo $RUN_CMD >> deploy/bin/$executable
        chmod +x deploy/bin/$executable
    fi
done <<< "$executables"
fi

executable="_debug_shell"
RUN_CMD="singularity --silent shell \$_BIND_FLAGS --overlay=\$DIR/../\$SQUASH_FS_NAME \$DIR/../\$IMG_NAME \$@"
echo "#!/bin/bash" > deploy/bin/$executable
echo "$REL_PATH_CMD" >> deploy/bin/$executable
echo "$PRE_COMMAND" >> deploy/bin/$executable
echo $RUN_CMD >> deploy/bin/$executable
chmod +x deploy/bin/$executable

executable="_debug_exec"
RUN_CMD="singularity --silent exec \$_BIND_FLAGS --overlay=\$DIR/../\$SQUASH_FS_NAME \$DIR/../\$IMG_NAME \$@"
echo "#!/bin/bash" > deploy/bin/$executable
echo "$REL_PATH_CMD" >> deploy/bin/$executable
echo "$PRE_COMMAND" >> deploy/bin/$executable
echo $RUN_CMD >> deploy/bin/$executable
chmod +x deploy/bin/$executable

cp $IMG_NAME deploy
cp $SQUASH_FS_NAME deploy
mkdir deploy/MASK
touch deploy/MASK/DIRECTORY_CONTENT_MASKED_IN_CONTAINER
chmod o+r -R deploy
chmod o+x -R deploy/bin

fusermount -u mount_dir
rm -rf mount_dir
