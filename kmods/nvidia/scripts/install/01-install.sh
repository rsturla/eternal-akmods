#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

ARCH=$(uname -m)

rpm-ostree install /tmp/akmods/rpms/nvidia-addons-*.rpm

# Enable nvidia-container-toolkit repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

# Base packages to install
COMMON_PKGS=(
    libnvidia-fbc
    libva-nvidia-driver
    nvidia-driver
    nvidia-modprobe
    nvidia-persistenced
    nvidia-driver-cuda
    nvidia-settings
    nvidia-container-toolkit
    /tmp/akmods/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm
)

# Declare an array for architecture-specific packages
ARCH_PKGS=()

# Add architecture-specific packages based on detected architecture
if [ "$ARCH" = "x86_64" ]; then
    ARCH_PKGS=(
        libnvidia-ml.i686
        mesa-vulkan-drivers.i686
        nvidia-driver-cuda-libs.i686
        nvidia-driver-libs.i686
    )
elif [ "$ARCH" = "aarch64" ]; then
    # No additional packages for aarch64, but you could add some if needed
    ARCH_PKGS=()
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Combine common and architecture-specific packages into a single install command
rpm-ostree install "${COMMON_PKGS[@]}" "${ARCH_PKGS[@]}"

# Copy and update modprobe configuration for Nvidia
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
