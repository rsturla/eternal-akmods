#!/bin/sh

set -oeux pipefail

RPMBUILD_DIR="/tmp/nvidia-addons/rpmbuild"
RPMBUILD_SOURCES_DIR="${RPMBUILD_DIR}/SOURCES"
curl -Lo ${RPMBUILD_SOURCES_DIR}/nvidia-container-toolkit.repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
curl -Lo ${RPMBUILD_SOURCES_DIR}/nvidia-container.pp https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp

sed -i "s@gpgcheck=0@gpgcheck=1@" ${RPMBUILD_SOURCES_DIR}/nvidia-container-toolkit.repo

install -D /etc/pki/akmods/certs/public_key.der ${RPMBUILD_SOURCES_DIR}/public_key.der

rpmbuild -ba \
    --define '_topdir /tmp/nvidia-addons/rpmbuild' \
    --define '%_tmppath %{_topdir}/tmp' \
    /tmp/nvidia-addons/nvidia-addons.spec
