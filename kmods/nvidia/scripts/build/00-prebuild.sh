#!/bin/sh

set -oeux pipefail

# If REPOSITORY_TYPE is set to true, enable the RPMFusion testing repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
if [[ "${REPOSITORY_TYPE}" == "testing" ]]; then
  echo "INFO: Enabling RPMFusion testing repositories"
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi
