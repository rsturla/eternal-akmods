#!/bin/sh

set -ouex pipefail

# Modularity repositories are not available on Fedora 39 and above, so don't try to disable them
if [[ "${FEDORA_VERSION}" -lt 39 ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular}.repo
else
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo
fi

# If ENABLE_RPMFUSION_TESTING is set to true, enable the RPMFusion testing repos
if [[ "${ENABLE_RPMFUSION_TESTING}" == "true" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi

install -D /tmp/nvidia-addons/rpmbuild/SOURCES/nvidia-container-toolkit.repo \
  /etc/yum.repos.d/nvidia-container-toolkit.repo

source /var/cache/akmods/nvidia-vars

rpm-ostree install \
  xorg-x11-drv-${NVIDIA_PACKAGE_NAME}-{,cuda-,devel-,kmodsrc-,power-}${NVIDIA_FULL_VERSION} \
  nvidia-container-toolkit nvidia-vaapi-driver \
  /var/cache/akmods/${NVIDIA_PACKAGE_NAME}/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
  /tmp/nvidia-addons/rpmbuild/RPMS/noarch/nvidia-addons-*.rpm
