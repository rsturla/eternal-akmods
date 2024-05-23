#!/bin/sh

set -ouex pipefail
source /info/nvidia-vars

# Create a backup of current repos
cp -a /etc/yum.repos.d /tmp/yum.repos.d

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}{,-updates}.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
if [[ "${RPMFUSION_TESTING_ENABLED}" == "true" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi

install -D /tmp/nvidia-addons/rpmbuild/SOURCES/nvidia-container-toolkit.repo \
  /etc/yum.repos.d/nvidia-container-toolkit.repo

rpm-ostree install \
  xorg-x11-drv-nvidia-{,cuda-,devel-,kmodsrc-,power-}${NVIDIA_FULL_VERSION} \
  nvidia-container-toolkit nvidia-vaapi-driver \
  /rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
  /rpms/nvidia-addons-*.rpm
