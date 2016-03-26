#!/usr/bin/env bash

RELATIVE_SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})

if [ ! "$RELATIVE_SCRIPT_DIR" == "." ]
then
	SCRIPT_DIR=$(pushd "$RELATIVE_SCRIPT_DIR" > /dev/null && pwd && popd > /dev/null)
	cd "$SCRIPT_DIR"
fi

echo $(cat packageList.txt) | sed 's|[[:space:]]\+|,|g' > myPackagesVariable.txt

