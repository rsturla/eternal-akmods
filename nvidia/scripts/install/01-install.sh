#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

rpm-ostree install /tmp/akmods/rpms/nvidia-addons-*.rpm

# Install Nvidia drivers
rpm-ostree install \
  xorg-x11-drv-nvidia-{,cuda-,devel-,kmodsrc-,power-}${NVIDIA_FULL_VERSION} \
  nvidia-container-toolkit nvidia-vaapi-driver \
  /tmp/akmods/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm
