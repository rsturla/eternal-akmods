#!/usr/bin/env bash

set -oeux pipefail

mkdir -p /rpms
for rpm in $(find /var/cache -name '*.rpm'); do
  cp -a $rpm /rpms
done

ls -l /rpms
