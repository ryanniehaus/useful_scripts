#!/usr/bin/env bash

RELATIVE_SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})

if [ ! "$RELATIVE_SCRIPT_DIR" == "." ]
then
	SCRIPT_DIR=$(pushd "$RELATIVE_SCRIPT_DIR" > /dev/null && pwd && popd > /dev/null)
	cd "$SCRIPT_DIR"
fi

cygcheck -c -d | grep -vE "^Cygwin Package Information" | grep -vE "^Package" | sed 's|[[:space:]]\+| |g' | cut -f 1 -d " "> packageList.txt
