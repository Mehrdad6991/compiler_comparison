#!/bin/sh

set -eu

# author: moritz
# last modified: 2020-04-13


if [ -f collected_compiletime_gcc.txt ]; then
    rm -f collected_compiletime_gcc.txt collected_size_gcc.txt
    rm -f collected_compiletime_llvm.txt collected_size_llvm.txt
fi


COMPILETIME_HEADER='march,opt,run,real,user,sys'

echo "$COMPILETIME_HEADER" > collected_compiletime_gcc.txt
echo "$COMPILETIME_HEADER" > collected_compiletime_llvm.txt

verify_is_compiletime_csv () {
    if [ ! "$COMPILETIME_HEADER" = "$(head -n1 "$1")" ]; then
        echo "ERROR: '$fn' is not in csv format" >&2
        exit 1
    fi
}

for dir in */; do
    dir="${dir%/}"

    fn="$dir/compiletime_gcc.txt"
    echo "collecting data from '$fn'..." >&2
    verify_is_compiletime_csv "$fn"
    awk -v b="$dir" 'NR>1{print b "," $0}' "$fn" >> collected_compiletime_gcc.txt

    fn="$dir/compiletime_llvm.txt"
    echo "collecting data from '$fn'..." >&2
    verify_is_compiletime_csv "$fn"
    awk -v b="$dir" 'NR>1{print b "," $0}' "$fn" >> collected_compiletime_llvm.txt
done

echo "collecting gcc size data..." >&2
find . -regex '\./[^/]*/gcc/\([^/]*\)/\1_.' -exec size '{}' + \
    | awk 'NR == 1 || $1 != "text"' > collected_size_gcc.txt

echo "collecting llvm size data..." >&2
find . -regex '\./[^/]*/llvm/\([^/]*\)/\1_.' -exec size '{}' + \
    | awk 'NR == 1 || $1 != "text"' > collected_size_llvm.txt
