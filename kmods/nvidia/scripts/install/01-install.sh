#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

rpm-ostree install /tmp/akmods/rpms/nvidia-addons-*.rpm

# Enable nvidia-container-toolkit repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

# Install Nvidia drivers
rpm-ostree install \
    libnvidia-fbc:*:${NVIDIA_AKMOD_VERSION}.* \
    libnvidia-ml.i686:*:${NVIDIA_AKMOD_VERSION}.* \
    libva-nvidia-driver:*:${NVIDIA_AKMOD_VERSION}.* \
    mesa-vulkan-drivers.i686:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-driver:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-driver-cuda:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-driver-cuda-libs.i686:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-driver-libs.i686:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-modprobe:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-persistenced:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-settings:*:${NVIDIA_AKMOD_VERSION}.* \
    nvidia-container-toolkit:*:${NVIDIA_AKMOD_VERSION}.* \
    /tmp/akmods/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm

cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
