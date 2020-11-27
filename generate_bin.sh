#!/bin/bash

set -e
source vars.sh

mkdir mount_dir
squashfuse $_SQUASH_FS_NAME mount_dir


if [[ ! -z "$ENV_NAME" ]]; then
    TARGET="$TARGET/envs/$ENV_NAME"
fi

FT=$(echo $TARGET | sed 's@^/@@g')
BASE_DIR=$PWD
rm -rf deploy
mkdir deploy
mkdir deploy/bin
cd mount_dir
cd $FT/bin
executables="$(ls -p | grep -v /)"
cd $BASE_DIR


REL_PATH_CMD='DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"'

PRE_COMMAND="source \$DIR/../common.sh"
#_BIND_FLAGS="-B /users:/users  -B /projappl:/projappl -B /scratch:/scratch"
_BIND_FLAGS=$(ls -1 / | awk '!/dev/'  | sed 's/^/\//g'  | awk '{ print $1,$1 }' | sed 's/ /:/g' | sed 's/^/-B /g' | tr '\n' ' ')
_BIND_FLAGS="$_BIND_FLAGS -B \$DIR/../MASK:$MASK_DIR -B \$DIR/../MASK:\$DIR/../bin"
echo "export _BIND_FLAGS=\"$_BIND_FLAGS\"" > deploy/common.sh
echo "export _SQUASH_FS_NAME=$_SQUASH_FS_NAME" >> deploy/common.sh
echo "export _IMG_NAME=\"$_IMG_NAME\"" >> deploy/common.sh
echo "export SINGULARITYENV_PATH=$TARGET/bin:$PATH" >> deploy/common.sh
echo "export SINGULARITYENV_LD_LIBRARY_PATH=$TARGET/lib/:$LD_LIBRARY_PATH" >> deploy/common.sh



if [[ "$WRAPPERS" = true  ]]; then
while IFS= read -r executable; do
    cmd=$(echo "$TARGET//bin/$executable" | sed 's@//*@/@g')
    RUN_CMD="singularity --silent exec \$_BIND_FLAGS --overlay=\$DIR/../\$_SQUASH_FS_NAME \$DIR/../\$_IMG_NAME $cmd \$@"
    echo "#!/bin/bash" > deploy/bin/$executable
    echo "$REL_PATH_CMD" >> deploy/bin/$executable
    echo "$PRE_COMMAND" >> deploy/bin/$executable
    echo $RUN_CMD >> deploy/bin/$executable
    chmod +x deploy/bin/$executable
done <<< "$executables"
fi

executable="_debug_shell"
RUN_CMD="singularity --silent shell \$_BIND_FLAGS --overlay=\$DIR/../\$_SQUASH_FS_NAME \$DIR/../\$_IMG_NAME \$@"
echo "#!/bin/bash" > deploy/bin/$executable
echo "$REL_PATH_CMD" >> deploy/bin/$executable
echo "$PRE_COMMAND" >> deploy/bin/$executable
echo $RUN_CMD >> deploy/bin/$executable
chmod +x deploy/bin/$executable

cp $_IMG_NAME deploy
cp $_SQUASH_FS_NAME deploy
mkdir deploy/MASK
touch deploy/MASK/DIRECTORY_CONTENT_MASKED_IN_CONTAINER
chmod o+r -R deploy
chmod o+x -R deploy/bin

fusermount -u mount_dir
rm -rf mount_dir
