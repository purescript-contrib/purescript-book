#!/usr/bin/env bash

# This script automatically resets exercises so they are ready to be solved.
#  - Removes lines with a note to delete them.
#  - Moves the no-peeking directory outside of the compilation path.

# Echo commands to shell
set -x
# Exit on first failure
set -e

# For all chapters
for d in exercises/*; do
  # if directory (excludes LICENSE file)
  if [ -d $d ]; then
    perl -ni -e 'print if !/This line should have been automatically deleted/' $d/test/Main.purs
  fi
  # if there's a no-peeking directory
  if [ -d $d/test/no-peeking ]; then
    mv $d/test/no-peeking $d/no-peeking
  fi
done
