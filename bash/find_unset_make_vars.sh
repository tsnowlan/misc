#!/bin/bash -e
set -o pipefail

IGNORE_VARS=(
    .VARIABLES
    CI
    HOME
    MAKE
    MAKE_TERMOUT
    MAKEFILE_LIST
)

find_vars() {
    local makefile=$1
    grep -oP '(?<=\$[\[\(])([\w\d_]+)(?=[\)\}])' "$makefile" \
        | sort \
        | uniq -c \
        | awk '{ if ($1 == 1) {print $2}}'
}

narrow_vars() {
    local makefile=$1
    local var_file=$2
    while IFS= read -r vname; do
        if [[ " ${IGNORE_VARS[*]} " != *" $vname "* ]]; then
            if ! grep -w "$vname" "$makefile" | grep -qP "\b$vname *[:\?\+]?="; then
                echo "$vname"
            fi
        fi
    done <"$var_file"
}

if [[ $# -eq 0 ]]; then
    TARGET_FILE=Makefile
else
    TARGET_FILE=$1
fi

if [[ ! -f "$TARGET_FILE" ]]; then
    echo "File not found: $TARGET_FILE"
    exit 1
fi

make_vars=$(mktemp -p "$PWD" tmp_names.XXXXXX)
find_vars "$TARGET_FILE" >"$make_vars"
narrow_vars "$TARGET_FILE" "$make_vars"
rm "$make_vars"
