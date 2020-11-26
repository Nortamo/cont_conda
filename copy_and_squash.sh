# Do this in $TMPDIR not on lustre/network fs

set -e
source vars.sh
BASE_DIR=$PWD

mkdir build_dir
cd build_dir
FT=$(echo $TARGET | sed 's@^/@@g')
mkdir -p $FT
cd $FT
rsync -Pr --exclude envs --links $TARGET/* .
cd $BASE_DIR
chmod o+rx -R build_dir/
mksquashfs build_dir/ $_SQUASH_FS_NAME  -processors 10
