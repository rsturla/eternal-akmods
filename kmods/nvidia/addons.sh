#!/usr/bin/env bash

set -oeux pipefail

NVIDIA_MAJOR_VERSION=${1}

RELEASE="$(rpm -E '%fedora.%_arch')"
echo NVIDIA_MAJOR_VERSION=${NVIDIA_MAJOR_VERSION}

cd /tmp

SOURCES_DIR="/tmp/nvidia-addons/rpmbuild/SOURCES"
mkdir -p ${SOURCES_DIR}
curl -Lo ${SOURCES_DIR}/nvidia-container-toolkit.repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
curl -Lo ${SOURCES_DIR}/nvidia-container.pp https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp

cp ./kmods/nvidia/nvidia-addons.spec /tmp/nvidia-addons/nvidia-addons.spec
cp ./kmods/nvidia/files/usr/lib/systemd/system/eternal-nvctk-cdi.service ${SOURCES_DIR}/eternal-nvctk-cdi.service
cp ./kmods/nvidia/files/usr/lib/systemd/system-preset/01-eternal-nvctk-cdi.preset ${SOURCES_DIR}/01-eternal-nvctk-cdi.preset
cp ./certs/public_key.der ${SOURCES_DIR}/public_key.der

rpmbuild -ba \
    --define '_topdir /tmp/nvidia-addons/rpmbuild' \
    --define '%_tmppath %{_topdir}/tmp' \
    /tmp/nvidia-addons/nvidia-addons.spec

rpm -ql /tmp/nvidia-addons/rpmbuild/RPMS/*/*.rpm
