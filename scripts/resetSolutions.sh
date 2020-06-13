#!/usr/bin/env bash

# This script automatically resets exercises so they are ready to be solved.
# It just removes lines with a note to delete them.

# For all chapters
for d in exercises/*; do
  # if directory (excludes LICENSE file)
  if [ -d $d ]; then
    sed -i '/Note to reader: Delete this line/d' $d/test/Main.purs
  fi
done
