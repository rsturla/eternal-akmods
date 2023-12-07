#!/bin/sh

set -oeux pipefail

# Disable repos that are not needed for the build to improve build times
if [[ "${FEDORA_VERSION}" -lt 39 ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular}.repo
else
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
fi

rpm-ostree install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

rpm-ostree install \
  rpmfusion-free-release \
  rpmfusion-nonfree-release \
  --uninstall rpmfusion-free-release-$(rpm -E %fedora)-1.noarch \
  --uninstall rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch

# If RPMFUSION_TESTING_ENABLED is set to true, enable the RPMFusion testing repos
if [[ "${RPMFUSION_TESTING_ENABLED}" == "true" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi

sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/fedora-updates-archive.repo
