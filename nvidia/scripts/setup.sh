#!/bin/sh

set -oeux pipefail

# Create array of RPMFusion repositories to enable - e.g. rpmfusion-free-release, rpmfusion-nonfree-release, rpmfusion-nonfree-updates-testing
RPMFUSION_REPOSITORIES=(
  free-release
  nonfree-release
  nonfree-updates-testing
)

# Disable repos that are not needed for the build to improve build times
if [[ "${FEDORA_VERSION}" -lt 39 ]]; then
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular}.repo
else
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo
fi

# If RPMFUSION_REPOSITORIES contains free-release, enable the free RPMFusion repository
if [[ "${RPMFUSION_REPOSITORIES[*]}" =~ "free-release" ]]; then
  rpm-ostree install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
  rpm-ostree install rpmfusion-free-release --uninstall rpmfusion-free-release-$(rpm -E %fedora)-1.noarch
fi

# If RPMFUSION_REPOSITORIES contains nonfree-release, enable the nonfree RPMFusion repository
if [[ "${RPMFUSION_REPOSITORIES[*]}" =~ "nonfree-release" ]]; then
  rpm-ostree install "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
  rpm-ostree install rpmfusion-nonfree-release --uninstall rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch
fi

# If RPMFUSION_REPOSITORIES contains nonfree-updates-testing, enable the nonfree RPMFusion updates-testing repository
if [[ "${RPMFUSION_REPOSITORIES[*]}" =~ "nonfree-updates-testing" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi
