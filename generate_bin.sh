#!/bin/bash

set -e
source vars.sh

mkdir mount_dir
squashfuse $_SQUASH_FS_NAME mount_dir


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
_BIND_FLAGS="-B /users:/users  -B /projappl:/projappl -B /scratch:/scratch"
echo "export _BIND_FLAGS=\"$_BIND_FLAGS\"" > deploy/common.sh
echo "export _SQUASH_FS_NAME=$_SQUASH_FS_NAME" >> deploy/common.sh
echo "export _IMG_NAME=\"$_IMG_NAME\"" >> deploy/common.sh

if [[ "$WRAPPERS" = true  ]]; then
while IFS= read -r executable; do
    cmd=$(echo "$TARGET//bin/$executable" | sed 's@//*@/@g')
    RUN_CMD="singularity exec \$_BIND_FLAGS --overlay=\$DIR/../\$_SQUASH_FS_NAME \$DIR/../\$_IMG_NAME $cmd \$@"
    echo "#!/bin/bash" > deploy/bin/$executable
    echo "$REL_PATH_CMD" >> deploy/bin/$executable
    echo "$PRE_COMMAND" >> deploy/bin/$executable
    echo $RUN_CMD >> deploy/bin/$executable
    chmod +x deploy/bin/$executable
done <<< "$executables"
fi

cp $_IMG_NAME deploy
cp $_SQUASH_FS_NAME deploy
chmod o+rx -R deploy

fusermount -u mount_dir
rm -rf mount_dir
