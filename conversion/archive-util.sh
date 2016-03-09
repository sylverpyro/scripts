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
set -e # exit on errors

if [ $# -eq 0 ]; then 
	echo "Usage: $0 <target file or directory>"
	exit
fi

if [ "$1" == '--remove-original' ]; then
	purge="true"
	shift 
else
	purge="false"
fi

if [ -f "$1" ]; then 
  mode="file"
  # While we are here, grab the file name
  file="$(basename "$1")"
  # And the file name without the extension (needed to build the archive later)
  name="${file%.*}"
elif [ -d "$1" ]; then
  mode="dir"
  # Basename can then extract the name we need to use for this
  name="$(basename "$1")"
else
  echo "Error: Cannot read file $infile"
  exit
fi

# Determining the path is the same regardless of file or directory
path="`readlink -f "$1"`"
# Same with the 'origin' directory
origindir="`dirname "$path"`"

if [ -f "$origindir/$name.zip" ]; then
	echo "Skipping: Target zip file already exists: $origindir/$name.zip"
	exit
fi

function closeout () {
	#echo "Cleaning up our leftovers"
	cd "$origindir"
	if [ -d "$workdir" ]; then rm -r "$workdir"; fi
}
# Flag we set for a non-archive, non-directory target since we don't want
#  to take all the time to move it all the way to the work directory just to 
#  compress and copy it back later
inplace="false"

# We need to set this to empty so we can detect later if we had to make
# a work directory (so we can clean it up after ourselves)
workdir=""

# If the target is a file
if [ "$mode" == "file" ]; then

  case `file "$path" --mime-type -b` in
    # for rar archives
	  'application/x-rar') 
      workdir="`mktemp -d`"
      #workdir=/tmp/testing
      rar x "$path" "$workdir" 
      #echo "Testing: Want to 'rar x $path $workdir'"
      ;;

    # For 7z archives
    # Note the missing space between -o and 'wordir' is intentional
	  'application/x-7z-compressed') 
      workdir="`mktemp -d`"
      #workdir="/tmp/testing"
      7z x "$path" -o"$workdir"
      #echo "Testing: Want to '7z x $path -o$workdir'" 
      ;;

    # If it's a zip archive, we just skip doing anything at all
    'application/zip') 
      #echo "Target is already a zip archive, nothing to do"; 
      exit ;;

	  #*) echo "Error: Unrecognized archive format `file "$infile_path" --mime-type`" ; closeout ; exit ;;
    # If this is neigher a 7z or rar archive (or zip archive) then we don't need to do a decompress
    # but we need to set a flag to indicate we need to do in in-place compress
    *) inplace="true" ;;
  esac
else
  # If our target is a directory, we can just set the work directory path to the path of the target
  #  directory as we are going to try and compress it anyway
  # We do this to save ourselves from having to use a different invocation of zip later
  workdir="$path" 
fi

if [ "$inplace" == "true" ]; then
  echo "Creating: $origindir/$name.zip from $path"
  zip -j "$origindir/$name.zip" "$path"
  #echo "Testing: Want to 'zip $origindir/$name.zip $path'"
else
  echo "Creating: $origindir/$name.zip from $workdir"
  zip -j -r "$origindir/$name.zip" "$workdir"/*
  #echo "Testing: Want to 'zip -j -r $origindir/$name.zip $workdir/*'"
fi

# Cleanup our decompress work
if [ "$mode" == "file" -a "$workdir" != "" ]; then
  rm -r "$workdir"
  #echo "Testing: Want to cleanup the workdir"
fi

if [ "$purge" == "true" ]; then 
  #rm "$path"
  echo "Testing: Want to purge the input file: $path"
fi
