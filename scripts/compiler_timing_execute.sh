#!/bin/sh

set -e

for dir in */; do
    # start a subshell, so the "cd" command does not influence the
    # outer environment
    (
        cd "$dir"
        ./gcc.sh
        ./llvm.sh
    )
done
