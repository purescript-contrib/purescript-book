#!/usr/bin/env bash

# This script removes all code anchors to improve readability

# Echo commands to shell
set -x
# Exit on first failure
set -e

# All .purs & .js files in the src/ and test/ directories of chapter exercises.
FILES=$(find . -regextype posix-extended -regex '\./exercises/chapter[0-9]{1,2}/(src|test)/.*\.(purs|js)' -type f)

for f in $FILES; do
  # Delete lines starting with an 'ANCHOR' comment
  perl -ni -e 'print if !/^\s*(--|\/\/) ANCHOR/' $f
done
