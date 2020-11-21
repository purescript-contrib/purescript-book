#!/usr/bin/env bash

# This script removes all code anchors to improve readability

# All .purs files in the exercises directories (excluding hidden files)
ALL_PURS=$(find exercises \( ! -regex '.*/\..*' \) -type f -name '*.purs')

for f in $ALL_PURS; do
  # Delete lines starting with an '-- ANCHOR' comment
  perl -ni -e 'print if !/^\s*-- ANCHOR/' $f
done
