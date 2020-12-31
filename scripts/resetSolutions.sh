#!/usr/bin/env bash

# This script automatically resets exercises so they are ready to be solved.
#  - Removes lines with a note to delete them.
#  - Moves the no-peeking directory outside of the compilation path.

# For all chapters
for d in exercises/*; do
  # if directory (excludes LICENSE file)
  if [ -d $d ]; then
    perl -ni -e 'print if !/Note to reader: Delete this line/' $d/test/Main.purs
  fi
  # if there's a no-peeking directory
  if [ -d $d/test/no-peeking ]; then
    mv $d/test/no-peeking $d/no-peeking
  fi
done
