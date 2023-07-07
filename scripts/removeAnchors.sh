#!/usr/bin/env bash

# This script removes all code anchors to improve readability

FIND_FILES_PATTERN='\./exercises/chapter[0-9]{1,2}/(src|test)/.*\.(purs|js)'
OS=$(uname)

# Echo commands to shell
set -x
# Exit on first failure
set -e

# All .purs & .js files in the src/ and test/ directories of chapter exercises.
if [[ "$OS" == 'Darwin' ]]; then
    FILES=$(find -E . -regex "${FIND_FILES_PATTERN}" -type f)
else
    FILES=$(find . -regextype posix-extended -regex "${FIND_FILES_PATTERN}" -type f)
fi

for f in $FILES; do
  # Delete lines starting with an 'ANCHOR' comment
  perl -ni -e 'print if !/^\s*(--|\/\/) ANCHOR/' $f
done
