#!/bin/sh

set -oeux pipefail

# Modularity repositories are not available on Fedora 39 and above, so don't try to disable them
if [[ "${FEDORA_VERSION}" == "rawhide" ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular,updates-testing-archive}.repo
elif [[ "${FEDORA_VERSION}" -lt 39 ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular,updates-testing-modular}.repo
else
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive,updates-testing-archive}.repo
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
