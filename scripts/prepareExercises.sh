#!/usr/bin/env bash

# This script removes meta information that is not intended for readers of the book

# Echo commands to shell
set -x
# Exit on first failure
set -e

# For all chapters
for d in exercises/chapter*; do
  # All .purs & .js files of chapter exercises
  FILES=$(find $d/src $d/test -name '*.purs' -o -name '*.js')

  for f in $FILES; do
    # Delete lines starting with an 'ANCHOR' comment
    perl -ni -e 'print if !/^\s*(--|\/\/) ANCHOR/' $f

    # Delete lines with a note to delete them
    perl -ni -e 'print if !/This line should have been automatically deleted/' $f
  done

  # If there's a no-peeking directory
  if [ -d $d/test/no-peeking ]; then
    # Move 'no-peeking' sources out of the compilation path
    mv $d/test/no-peeking $d
  fi
done
