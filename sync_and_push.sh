#!/bin/bash

set -ev

git config --global user.email "u1test+m-o@canonical.com"
git config --global user.name "Snappy M-O"

git remote add upstream https://github.com/blockstack/blockstack-core.git
git fetch upstream

git rebase upstream/$TRAVIS_BRANCH

git remote add origin-with-token https://${GH_TOKEN}@github.com/elopio/blockstack-core.git
git checkout -b $TRAVIS_BRANCH-sync
git push -f --set-upstream origin-with-token $TRAVIS_BRANCH-sync:$TRAVIS_BRANCH
