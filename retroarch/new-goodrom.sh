#!/bin/bash - 
#===============================================================================
#
#          FILE: new-goodrom.sh
# 
#         USAGE: ./new-goodrom.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 11/25/2015 22:13
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ $# -eq 0 ]; then echo "Give me a rom name"; exit; fi;
#if [ ! -f "$1" ]; then echo "Give me a rom name"; exit; fi

if [ "$1" == '-r' ]; then RUN="true"; shift; else RUN="false"; fi;
if [ $# -eq 2 ]; then TARGETDIR="`/usr/bin/readlink -f $2`"; else TARGETDIR="`pwd`"; fi;

DEBUG="false"

function decho () { if [ "$DEBUG" == "true" ]; then echo "$1"; fi; }

basename=/usr/bin/basename
cut=/usr/bin/cut
tr=/usr/bin/tr

FILTER_OUT="(.*Alt.*)\|(.*Rev.*)\|(Unl)\|(.*Alpha.*)\|(.*Beta.*)\|(.*Proto.*)\|(.*Demo.*)\|(.*Kiosk.*)\|(.*Sample.*)\|\[b\]\|(.*Promo.*)\|(Rumble Version)\|(SDK Build)\|(Developer Cart)\|(.*Special Edition.*)\|(.*Pirate.*)\|(.*MDMM.*)\|(.*ACD3.*)\|(.*MDSTEE.*)"
TARGETS="USA\|World"

decho "Got rom name: $1"
PATH=$(readlink -f "$1")
decho "Path: '$PATH'"
FILE=$($basename "$PATH")
decho "File: '$FILE'"
EXT="${FILE##*.}"
decho "Ext: '$EXT'"
NAME="${FILE%.*}"
decho "Name: '$NAME'"
REGION="$(echo "$NAME" | $cut -d '(' -f 2 | $tr -d ') ')"
if [ ! `echo "$NAME" | /usr/bin/grep -c "$FILTER_OUT"` -eq 0 ]; 
    then REGION="filtered"; 
elif [ ! `echo "$REGION" | /usr/bin/grep -c "$TARGETS"` -eq 0 ]; 
    then REGION="roms";
else
    REGION="foreign/${REGION}"
fi;
decho "Region: '$REGION'"

PROPOSEDPATH="${TARGETDIR}/${REGION}/${FILE}"
decho "Proposed Path: $PROPOSEDPATH"

if [ "$PATH" != "$PROPOSEDPATH" ]; then
    if [ "$RUN" == "true" ]; then
        if [ ! -d "${TARGETDIR}/${REGION}" ]; then /usr/bin/mkdir -p "${TARGETDIR}/${REGION}" || exit; fi;
        /usr/bin/mv -v "$PATH" "$PROPOSEDPATH"
    else
        echo "Proposed Move: mv -v $PATH -> $PROPOSEDPATH"
    fi
fi

