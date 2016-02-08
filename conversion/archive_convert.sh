#!/bin/bash - 
#===============================================================================
#
#          FILE: archive_convert.sh
# 
#         USAGE: ./archive_convert.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: sylverpyro (), sylverpyro@gmail.com
#  ORGANIZATION: 
#       CREATED: 12/16/2015 19:06
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ $# -eq 0 ]; then 
	echo "Usage $0 [--remove-original] <non-zip archive>"
	exit
fi

if [ "$1" == '--remove-original' ]; then
	purge="true"
	shift 
else
	purge="false"
fi

infile="$1"
echo "$infile"
if [ ! -f "$1" ]; then echo "Error: Cannot read file $infile"; exit; fi

infile_path="`readlink -f "$infile"`"
echo "$infile_path"
origindir="`dirname "$infile_path"`"
echo "$origindir"
file_name="${infile##*/}"
echo "$file_name"
name_base="${file_name%.*}"
echo "$name_base"

if [ -f "${origindir}/${name_base}.zip" ]; then
	echo "Warning: The target zip file appears to already exist: ${origindir}/${name_base}.zip"
	echo "Skipping any work on this file"
	exit
fi

function closeout () {
	echo "Cleaning up our leftovers"
	cd "$origindir"
	if [ -d "$workdir" ]; then rm -r "$workdir"; fi
}

workdir="`mktemp -d`"
case `file "$infile" --mime-type -b` in
	'application/x-rar') rar x "$infile_path" "$workdir" ;;

	# Note the missing space between -o and 'wordir' is intentional
	'application/x-7z-compressed') 7z x "$infile_path" -o"$workdir" ;;

	*) echo "Error: Unrecognized archive format `file "$infile_path" --mime-type`" ; closeout ; exit ;;
esac

if [ ! $? -eq 0 ]; then
	echo "Error: Non-zero exit code returned from decompression step"
	closeout
	exit
fi

cd "$workdir"
zip -j -r "${origindir}/${name_base}.zip" ./

if [ ! $? -eq 0 ]; then
	echo "Error: non-zero exit code returned from compression step"
	echo "Was trying to run: zip -j -r ${origindir}/${name_base}.zip"
	closeout
	exit
fi

closeout

if [ "$purge" == "true" ]; then 
	rm "$infile_path"
fi
