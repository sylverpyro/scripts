#!/bin/bash

usage () {
	echo "$0 <folder>"
}

# If we get no arguments, complain and exit
if [ $# -eq 0 ];
then 
	usage
    exit 0
else
	case "$1" in
    # Print help if asked
    -h)
		usage
		exit 0
		;;
	*)
        # Make sure the directory exists first
		if [ -d "$1" ]; then
			DIR="${1}"
        # If not bail
		else
			echo "Cannot find directory $1"
			exit 0
		fi
		;;
	esac
fi

# Now that we know the directory exists,
#   list all of the US Roms in the specified directory
#   excluding all proto, rev, beta, and alpha games
find "${DIR}" -mount -mindepth 1 -type f | \
    grep -v -i -E "\((Beta|Alt|Rev .*|Alpha|Arcade|v.*)\)" | \
    grep -E "\((.*US.*|.*USA.*|.*World*.)\)" | \
    sort
