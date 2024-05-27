#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

# Create a backup of current repos
cp -a /etc/yum.repos.d /tmp/yum.repos.d

# Install rpmfusion repos
rpm-ostree install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

rpm-ostree install \
  rpmfusion-free-release \
  rpmfusion-nonfree-release \
  --uninstall rpmfusion-free-release-$(rpm -E %fedora)-1.noarch \
  --uninstall rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch

# Configure rpmfusion repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}{,-updates}.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
if [[ "${RPMFUSION_TESTING_ENABLED}" == "true" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi

# Install Nvidia drivers
rpm-ostree install \
  xorg-x11-drv-nvidia-{,cuda-,devel-,kmodsrc-,power-}${NVIDIA_FULL_VERSION} \
  nvidia-container-toolkit nvidia-vaapi-driver \
  /tmp/akmods/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
  /tmp/akmods/rpms/nvidia-addons-*.rpm
