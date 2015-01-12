#!/bin/bash

set -e
set -x

# Get a fresh copy of the repository. Unlike most of our other packaging
# scripts, this one requires two repositories since the packaging scripts are
# not kept with the open source code.
mkdir -p /tmp/confluent
cd /tmp/confluent

for SCALA_VERSION in $SCALA_VERSIONS; do
    # We redo this for every version since Debian package building requires a
    # completely clean source directory
    rm -rf /tmp/confluent/kafka-packaging
    git clone /vagrant/repos/kafka-packaging.git
    pushd kafka-packaging
    git fetch --tags /vagrant/repos/kafka.git

    git checkout -b debian-$VERSION origin/debian
    cat debian/control.in | sed "s@##SCALAVERSION##@${SCALA_VERSION}@g" > debian/control
    git add debian/control
    git commit -m "Add control file."
    git merge $VERSION

    git-buildpackage -us -uc --git-debian-branch=debian-$VERSION --git-upstream-tag=$VERSION --git-verbose
    popd
done

# Debian packaging dumps packages one level up. We try to save all the build
# output, including orig tarballs
cp kafka_*.build kafka_*.changes kafka_*.tar.gz kafka_*.dsc kafka-*.deb /vagrant/output/