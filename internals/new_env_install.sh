set -e

source vars.sh

rm -rf inst_dir
mkdir inst_dir

_CURR_DIR=$PWD

if [[ $MOUNT_DURING_INSTALL = "True" ]];then
    _BIND_FLAGS=$(ls -1 / | awk '!/dev/' | awk '!/local_scratch/'  | sed 's/^/\//g'  | awk '{ print $1,$1 }' | sed 's/ /:/g' | sed 's/^/-B /g' | tr '\n' ' ')
    test -d /local_scratch/ && export _BIND_FLAGS="$_BIND_FLAGS -B /local_scratch:/local_scratch"
    singularity --silent exec  -B inst_dir:$INSTPATH $_BIND_FLAGS $IMG_NAME bash -c "cd $_CURR_DIR && source _sing_inst_script.sh"     
else
    singularity exec -B $TMPDIR:/tmp -B $_CURR_DIR:$_CURR_DIR -B inst_dir:$INSTPATH $IMG_NAME bash -c "cd $_CURR_DIR && source _sing_inst_script.sh"
fi


rm  _sing_inst_script.sh
mkdir inst_dir/$INSTPATH
cd inst_dir/
shopt -s extglob
mv !($(echo $INSTPATH | cut -f 2 -d "/")) $(echo $INSTPATH | cut -f 2 -d "/")
cd $_CURR_DIR
chmod o+rx -R inst_dir/
mksquashfs inst_dir/ $SQUASH_FS_NAME  -processors 10
