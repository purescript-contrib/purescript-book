#!/usr/bin/env bash

# Run this script from purescript book repo root

# Echo commands to shell
set -x
# Exit on first failure
set -e

# Update package set
pushd scripts
spago upgrade-set
popd

# For all chapters
for d in exercises/*; do
  # if directory (excludes LICENSE file)
  if [ -d $d ]; then
    # copy updated packages.dhall to chapter
    cp scripts/packages.dhall $d/packages.dhall
  fi
done
