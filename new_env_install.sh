set -e
source vars.sh

rm -rf inst_dir
mkdir inst_dir

CURR_DIR=$PWD
DOLL=$
cat <<EOF > _sing_inst_script.sh
cd $_INSTPATH
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh --output Miniconda_inst.sh
bash Miniconda_inst.sh -b -p $TARGET
eval "${DOLL}($TARGET/bin/conda shell.bash hook)"
conda install -y numpy
EOF

singularity exec --contain -B $TMPDIR:/tmp -B $CURR_DIR:$CURR_DIR -B inst_dir:$_INSTPATH $_IMG_NAME bash -c "cd $CURR_DIR && source _sing_inst_script.sh"

rm  _sing_inst_script.sh
rm inst_dir/Miniconda_inst.sh
mkdir inst_dir/$_INSTPATH
cd inst_dir/
shopt -s extglob
mv !($(echo $_INSTPATH | cut -f 2 -d "/")) $(echo $_INSTPATH | cut -f 2 -d "/")
cd $CURR_DIR
chmod o+rx -R inst_dir/
mksquashfs inst_dir/ $_SQUASH_FS_NAME  -processors 10
