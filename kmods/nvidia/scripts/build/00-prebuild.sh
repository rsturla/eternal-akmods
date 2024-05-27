#!/bin/sh

set -oeux pipefail

rpm-ostree install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

rpm-ostree install \
  rpmfusion-free-release \
  rpmfusion-nonfree-release \
  --uninstall rpmfusion-free-release-$(rpm -E %fedora)-1.noarch \
  --uninstall rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch

# If RPMFUSION_TESTING_ENABLED is set to true, enable the RPMFusion testing repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
# if [[ "${RPMFUSION_TESTING_ENABLED}" == "true" ]]; then
#   echo "INFO: Enabling RPMFusion testing repositories"
#   sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
# fi
