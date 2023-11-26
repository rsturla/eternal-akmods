#!/bin/sh

set -ouex pipefail

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-{,non}free{,-updates,-updates-testing}.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# If ENABLE_RPMFUSION_TESTING is set to true, disable the RPMFusion testing repos after installing the packages
if [[ "${ENABLE_RPMFUSION_TESTING}" == "true" ]]; then
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi

semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

ln -s /usr/bin/ld.bfd /etc/alternatives/ld
ln -s /etc/alternatives/ld /usr/bin/ld
