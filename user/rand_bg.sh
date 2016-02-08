#!/bin/bash

WALLPAPERS="$HOME/media/wallpapers/"

function usage {
	echo "For a random background image: $0"
	echo "To background the script and rotate every X seconds: $0 X"
}

function new_wallpaper {
DIR="$WALLPAPERS"

COUNT=`find ${DIR} -type f | wc -l`

let SELECT=RANDOM%COUNT

if [ ${SELECT} -eq 0 ]; then
	let SELECT=SELECT+1
fi

PAPER=`find ${DIR} -type f | head -n ${SELECT} | tail -n 1`

feh --bg-center "${PAPER}"
}

if [ $# -eq 1 ]; then
	while [ -d "$WALLPAPERS" ]; do
		new_wallpaper;
		sleep $1
	done
else
	new_wallpaper;
fi
