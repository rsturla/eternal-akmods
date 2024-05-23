#!/usr/bin/env bash

set -oeux pipefail

# All RPMs must be copied to /rpms
for rpm in $(find /var/cache/rpms -name '*.rpm'); do
  cp -a $rpm /rpms
done

ls -l /rpms
