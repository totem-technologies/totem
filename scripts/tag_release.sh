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
TAG=v$RELEASE
if [ $(git tag -l "$TAG") ]; then
    log "Tag $TAG exists. Please update pubspec.yml version."
fi

log "Tagging version $TAG..."
git tag $TAG
git push origin $TAG