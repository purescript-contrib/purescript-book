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
    spago test
    # exit directory
    popd
  fi
done
