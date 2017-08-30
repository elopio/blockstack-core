#!/bin/bash

set -ev

git config --global user.email "u1test+m-o@canonical.com"
git config --global user.name "Snappy M-O"

git remote add upstream https://github.com/blockstack/blockstack-core.git
git fetch upstream

git rebase upstream/$TRAVIS_BRANCH
git checkout -b $TRAVIS_BRANCH-sync

last_committed_tag="$(git describe --tags --abbrev=0)"
last_released_tag="$(snap info blockstack | grep beta | awk '{print $2}')"
if [ "${last_committed_tag}" != "${last_released_tag}" ]; then
  # Patch the snapcraft.yaml to build the latest tag.
  sed -i "0,/source-tag/s/source-tag:.*$/source-tag: '"$last_committed_tag"'/g" snap/snapcraft.yaml
  sed -i "s/^version:.*$/version: '"$last_committed_tag"'/g" snap/snapcraft.yaml
  git add snap/snapcraft.yaml
  git commit -m "Patch snapcraft.yaml to build ${last_committed_tag}"
else
  # Patch back the snapcraft.yaml to build the develop branch.
  sed -i "0,/source-tag/s/source-tag:.*$/source-tag: 'develop'/g" snap/snapcraft.yaml
  sed -i "s/^version:.*$/version: 'develop'/g" snap/snapcraft.yaml
  git add snap/snapcraft.yaml || true
  git commit -m 'Patch back the snapcraft.yaml to continue building the develop branch' || true
fi

git remote add origin-with-token https://${GH_TOKEN}@github.com/elopio/blockstack-core.git
git push -f --set-upstream origin-with-token $TRAVIS_BRANCH-sync:$TRAVIS_BRANCH
