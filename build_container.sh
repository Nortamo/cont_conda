# The default container images does not contain anything extra
# Requires root, so probably not possible to build on target
# system
sudo singularity build centos_base.sif centos_base.def
