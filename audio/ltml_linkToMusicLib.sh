#!/bin/bash

# Define where the target music library is located
#MUSIC_LIB="/home/sylverpyro/media/music/music_library"
MUSIC_LIB="/darknet/music/sylverpyro-library"

# Define the source library
SOURCE_LIB="/darknet/music/library"

# Define a help function
usage () {
	echo "$0 <target>"
	echo "This command will create a simlink in ${MUSIC_LIB} to the specified file or folder"
}

# If we got no arguments, give some help
if [ ! $# -eq 1 ]; then
	usage
	exit
fi

# If it's a directory
if [ -d "${1}" ]; then
	# Set the target from the argument
	TARGET=`readlink -f "${1}"`
	# Make sure we are only 1 layer below the SOURCE_LIB
        #  as we are not going to get into the nightmare of multiple sub-link layers
        if [ "`dirname "$TARGET"`" != "$SOURCE_LIB" ]; then
                echo "Error: cannot work on directories more than 1 layer below $SOURCE_LIB"
                exit
        fi
	DEST="$MUSIC_LIB"
	# See if we previously had created a sub-set container for this album
	if [ -d "$DEST/$TARGET" -a ! -L "$DEST/$TARGET" ]; then
		# if we did, delete it so we can re-link it
		echo "DEBUG MODE: Would perform: rm -r $DEST/$TARGET"
	fi
# If it's a file
elif [ -f "$1" ]; then
	#echo "DEBUG MODE: Detected a file: $1"
	TARGET=`readlink -f "$1"`
	#echo "DEBUG MODE: TARGET written as: $TARGET"
	SOURCE_DIR=`dirname "$TARGET"`
	#echo "DEBUG MODE: SOURCE_DIR written as: $SOURCE_DIR"
	# Make sure we are only 1 layer below the SOURCE_LIB
	#  as we are not going to get into the nightmare of multiple sub-link layers
	if [ "`dirname "$SOURCE_DIR"`" != "$SOURCE_LIB" ]; then
		echo "Error: cannot work on directories more than 1 layer below $SOURCE_LIB"
		exit
	fi
	DEST="${MUSIC_LIB}${SOURCE_DIR#$SOURCE_LIB}/"
	#echo "DEBUG MODE: DEST written as: $DEST"
	# Check if the destination already exists as a link
	if [ -L "$DEST" ]; then
		# If it does complain and quit now
		echo "$DEST already exists as a link"
		ls -al "$DEST"
		echo "Cannot sub-link a file"
		exit
	# See if the destination directory exists
	elif [ ! -d "$DEST" ]; then
		# If it doesn't, make it now
		#echo "DEBUG MODE: Would perform: mkdir $DEST"
		mkdir "$DEST"
	fi
# If we cannot read the file or directory, complain and exit
else
	echo "Error: Cannot read ${1}"
	exit
fi

#Link the target to the destination
# See if the directory is already linked 
if [ -L "$DEST/$TARGET" ]; then
	# If it is, show the link
	echo "Error: Link to $TARGET already exists"
	ls -al "$DEST/$TARGET"
	# Exit now as we cannot do anything useful
else
	ln -s "$TARGET" "$DEST"
fi
#echo "DEGUB MODE: Would perform: ln -s ${TARGET} ${DEST}"
