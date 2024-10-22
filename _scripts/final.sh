#!/usr/bin/env bash

set -oeux pipefail

mkdir -p /rpms
for rpm in $(find /var/cache/rpms -name '*.rpm'); do
  echo "Copying $rpm..."
  cp -a $rpm /rpms
done

kernel_version=$(uname -r)

sed -i -e 's/args = \["rpmbuild", "-bb"\]/args = \["rpmbuild", "-bb", "--buildroot", "#{build_path}\/BUILD"\]/g' /usr/local/share/gems/gems/fpm-*/lib/fpm/package/rpm.rb;

for rpm in $(find /rpms -type f -name \*.rpm); do
  basename="$(basename ${rpm})"
  name="${basename%%-6*}"

  if [[ "$basename" == *"$kernel_version"* ]]; then
    echo "Processing $rpm with kernel version $kernel_version..."
    fpm --verbose -s rpm -t rpm -p ${rpm} -f --name ${name} ${rpm};
  else
    echo "Skipping $rpm as it does not contain kernel version $kernel_version..."
  fi
done

ls -l /rpms
