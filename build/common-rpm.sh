#!/bin/bash

set -e
set -x

if [ -z "$BRANCH" ]; then
    BRANCH="$VERSION"
fi

mkdir -p /tmp/confluent
cd /tmp/confluent
rm -rf /tmp/confluent/common
git clone /vagrant/repos/common.git
cd common

git checkout -b rpm-$VERSION origin/rpm
git merge --no-edit $BRANCH
make distclean
make rpm
if [ "x$SIGN" == "xyes" ]; then
    rpm --resign *.rpm || rpm --resign *.rpm || rpm --resign *.rpm
fi
cp *.rpm /vagrant/output/
rm -rf /tmp/confluent
