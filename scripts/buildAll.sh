#!/usr/bin/env bash

# Echo commands to shell
set -x
# Exit on first failure
set -e

# For all chapters
for d in exercises/*; do
  # if directory (excludes LICENSE file)
  if [ -d $d ]; then
    # enter directory
    pushd $d
    # build
    # if node project
    if [ -f package.json ]; then
      npm install
    fi
    spago build
    # exit directory
    popd
  fi
done
