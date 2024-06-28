#!/usr/bin/env bash

set -oeux pipefail

mkdir -p /rpms
for rpm in $(find /var/cache -name '*.rpm'); do
  echo "Copying $rpm..."
  cp -a $rpm /rpms

  echo "\n$rpm provides..."
  rpm -qp $rpm --provides
  echo "\n$rpm requires..."
  rpm -qp $rpm --requires
done

ls -l /rpms
