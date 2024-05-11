#!/bin/sh

set -ouex pipefail
source /var/cache/akmods/nvidia-vars

# Create a backup of current repos
cp -a /etc/yum.repos.d /tmp/yum.repos.d

# Modularity repositories are not available on Fedora 39 and above, so don't try to disable them
if [[ "${FEDORA_VERSION}" -lt 39 ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular}.repo
else
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo
fi

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
  /var/cache/akmods/nvidia/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
  /tmp/nvidia-addons/rpmbuild/RPMS/noarch/nvidia-addons-*.rpm
