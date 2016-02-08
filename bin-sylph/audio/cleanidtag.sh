#!/bin/bash
usage () {
	echo "${0} <target file>"
	echo "The target file will have it's id3v1 tag converted to id3v2 and deleted"
}

if [ ! $# -eq 1 ]; then
	usage
	exit
fi

if [ -f "${1}" ]; then
	TARGET="${1}"
else
	echo "Error: Cannot read file ${1}"
fi

id3v2 -C "${TARGET}"
id3v2 -s "${TARGET}"
id3v2 -l "${TARGET}"
