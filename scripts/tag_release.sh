#!/usr/bin/env bash
set -o errexit
set -o pipefail

log(){
    echo "tag_release.sh: $1"
}

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$BRANCH" != "main" ]]; then
  log 'Please switch to main branch.'
  exit 1
fi

if [[ $(git diff --stat) != '' ]]; then
  log 'Repo is dirty. Please commit first.'
  exit 1
fi

RELEASE=`grep 'version:' pubspec.yaml | sed 's/version: //'`
TAG=v$RELEASE
log "Tagging version $TAG..."
git tag $TAG
git push origin $TAG