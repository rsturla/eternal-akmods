#!/bin/sh

set -ouex pipefail
source /var/cache/akmods/nvidia-vars

# Modularity repositories are not available on Fedora 39 and above, so don't try to disable them
if [[ "${FEDORA_VERSION}" == "rawhide" ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular,updates-testing-archive}.repo
elif [[ "${FEDORA_VERSION}" -lt 39 ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular,updates-testing-modular}.repo
else
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive,updates-testing-archive}.repo
fi

# If RPMFUSION_TESTING_ENABLED is set to true, enable the RPMFusion testing repos
if [[ "${RPMFUSION_TESTING_ENABLED}" == "true" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi

install -D /tmp/nvidia-addons/rpmbuild/SOURCES/nvidia-container-toolkit.repo \
  /etc/yum.repos.d/nvidia-container-toolkit.repo

rpm-ostree install \
  xorg-x11-drv-${NVIDIA_PACKAGE_NAME}-{,cuda-,devel-,kmodsrc-,power-}${NVIDIA_FULL_VERSION} \
  nvidia-container-toolkit nvidia-vaapi-driver \
  /var/cache/akmods/${NVIDIA_PACKAGE_NAME}/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
  /tmp/nvidia-addons/rpmbuild/RPMS/noarch/nvidia-addons-*.rpm
