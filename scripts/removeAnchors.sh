#!/usr/bin/env bash

# This script removes all code anchors to improve readability

# Echo commands to shell
set -x
# Exit on first failure
set -e

# All .purs & .js files in the src/ and test/ directories of chapter exercises.
FIND_FILES_PATTERN='\./exercises/chapter[0-9]{1,2}/(src|test)/.*\.(purs|js)'

EXTENDED_REGEX_FLAGS="-regextype posix-extended"
# BSD find has different flags for extended regex
if [[ $(uname) == 'FreeBSD' || $(uname) == 'Darwin' ]]; then
    EXTENDED_REGEX_FLAGS='-E'
fi
FILES=$(find . -type f $EXTENDED_REGEX_FLAGS -regex $FIND_FILES_PATTERN)

for f in $FILES; do
  # Delete lines starting with an 'ANCHOR' comment
  perl -ni -e 'print if !/^\s*(--|\/\/) ANCHOR/' $f
done
