#!/bin/sh

set -oeux pipefail

# Disable repos that are not needed for the build to improve build times
if [[ "${FEDORA_VERSION}" -lt 39 ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular}.repo
else
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo
fi

rpm-ostree install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

rpm-ostree install \
  rpmfusion-free-release \
  rpmfusion-nonfree-release \
  --uninstall rpmfusion-free-release-$(rpm -E %fedora)-1.noarch \
  --uninstall rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch

# If ENABLE_RPMFUSION_TESTING is set to true, enable the RPMFusion testing repos
if [[ "${ENABLE_RPMFUSION_TESTING}" == "true" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo

  # Replace ENABLE_RPMFUSION_TESTING=false with ENABLE_RPMFUSION_TESTING=true in the /tmp/scripts/nvidia-install.sh file so it can
  # be used in the images that implement this
  sed -i 's@ENABLE_RPMFUSION_TESTING=false@ENABLE_RPMFUSION_TESTING=true@g' /tmp/scripts/nvidia-install.sh
fi
