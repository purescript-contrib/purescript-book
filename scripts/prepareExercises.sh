#! /bin/sh

# This script removes meta information that is not intended for readers of the book
# from the exercises

all=
none=1
removeAnchors=
removeSolutions=

show_help () {
    cat <<EOF >&2
Usage: $0 [anchors] [solutions] [all]

Prepare code in exercises/* for reading. If no option is specified,
`all` is used by default.

OPTIONS
    all         Perform all tasks
    anchors     Remove code anchors to improve readability
    solutions   Remove exercise solutions

EOF
}

for opt in "$@"; do
    # Reset none, since some action was requested
    none=
    case $opt in
        all )
            all=1
            ;;
        help )
            show_help
            exit 0
            ;;
        anchors )
            removeAnchors=1
            ;;
        solutions )
            removeSolutions=1
            ;;
        * )
            show_help
            exit 1
            ;;
    esac
done

if [ x$all != x -o x$none != x ]; then
    # Either 'all' was specified, or default to all actions
    removeAnchors=1
    removeSolutions=1
fi

# Echo commands to shell
set -x
# Exit on first failure
set -e

# All .purs & .js files of chapter exercises.
FILES=$(find exercises \( -name '*.purs' -o -name '*.js' \) -print)

for f in $FILES; do
  # Delete lines starting with an 'ANCHOR' comment
  [ -n $removeAnchors ] && perl -ni -e 'print if !/^\s*(--|\/\/) ANCHOR/' $f

  # Delete lines with a note to delete them
  [ -n $removeSolutions ] && perl -ni -e 'print if !/This line should have been automatically deleted/' $f
done

# Move 'no-peeking' sources out of the compilation path
if [ -n $removeSolutions ]; then
    for d in exercises/chapter*; do
        [ -d "$d/test/no-peeking" ] && mv "$d/test/no-peeking" "$d"
    done
fi
