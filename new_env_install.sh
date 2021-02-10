set -e
source vars.sh

rm -rf inst_dir
mkdir inst_dir

CURR_DIR=$PWD
DOLL=$

cat <<EOF > _sing_inst_script.sh
set -e
cp $ENV_YAML $_INSTPATH
cd $_INSTPATH
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh --output Miniconda_inst.sh
bash Miniconda_inst.sh -b -p $TARGET
eval "${DOLL}($TARGET/bin/conda shell.bash hook)"
$PRE_INSTALL
conda env create --name $ENV_NAME -f $ENV_YAML
conda activate $ENV_NAME
$POST_INSTALL
rm Miniconda_inst.sh
EOF

if [[ $MOUNT_DURING_INSTALL = "true" ]];then
    _BIND_FLAGS=$(ls -1 / | awk '!/dev/' | awk '!/local_scratch/'  | sed 's/^/\//g'  | awk '{ print $1,$1 }' | sed 's/ /:/g' | sed 's/^/-B /g' | tr '\n' ' ')
    test -d /local_scratch/ && export _BIND_FLAGS="$_BIND_FLAGS -B /local_scratch:/local_scratch"
    singularity --silent exec  -B inst_dir:$_INSTPATH $_BIND_FLAGS $_IMG_NAME bash -c "cd $CURR_DIR && source _sing_inst_script.sh"     
else
    singularity exec --contain -B $TMPDIR:/tmp -B $CURR_DIR:$CURR_DIR -B inst_dir:$_INSTPATH $_IMG_NAME bash -c "cd $CURR_DIR && source _sing_inst_script.sh"
fi


rm  _sing_inst_script.sh
rm inst_dir/Miniconda_inst.sh
mkdir inst_dir/$_INSTPATH
cd inst_dir/
shopt -s extglob
mv !($(echo $_INSTPATH | cut -f 2 -d "/")) $(echo $_INSTPATH | cut -f 2 -d "/")
cd $CURR_DIR
chmod o+rx -R inst_dir/
mksquashfs inst_dir/ $_SQUASH_FS_NAME  -processors 10
