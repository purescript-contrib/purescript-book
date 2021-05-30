#!/usr/bin/env bash

# This script removes all code anchors to improve readability

# All .purs files in the exercises directories (excluding hidden files)
ALL_PURS=$(find exercises \( ! -regex '.*/\..*' \) -type f -name '*.purs')

for f in $ALL_PURS; do
  # Delete lines starting with an '-- ANCHOR' comment
  perl -ni -e 'print if !/^\s*-- ANCHOR/' $f
done

# All .js files in the exercises directories (excluding hidden files and output/)
ALL_JS=$(find exercises \( ! -regex '.*/\..*' \) \( ! -regex '.*/output/.*' \) -type f -name '*.js')

for f in $ALL_JS; do
  # Delete lines starting with an '// ANCHOR' comment
  perl -ni -e 'print if !/^\s*\/\/ ANCHOR/' $f
done
