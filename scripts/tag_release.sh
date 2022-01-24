#!/usr/bin/env bash
set -o errexit
set -o pipefail

log(){
    echo "tag_release.sh: $1"
}

if [[ $(git diff --stat) != '' ]]; then
  log 'Repo is dirty. Please commit first.'
  exit
fi

RELEASE=`grep 'version:' pubspec.yaml | sed 's/version: //'`

if [ $(git tag -l "$version") ]; then
    log "Tag $RELEASE exists. Please update pubspec.yml version."
fi

log "Tagging version $RELEASE..."
git tag $RELEASE
git push --tags