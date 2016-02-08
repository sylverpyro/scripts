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

if [ $# -eq 0 -o "$1" == "-h" ]; then 
	echo "Usage: $0 [-d] [-r] <RomName> [TargetDirectoryPath]"
	echo "  -d        : Enable debugging"
	echo "  -r        : Actually run the 'mv' command on the files"
	echo "  <RomName> : A ROM file that exists"
	echo " [TargetDirectoryPath] : A path to a directory you want to generate 'mv' commands against"
	echo ""
	echo "Function: This script will scan the name of a rom given to try and determine if it falls into"
	echo " the 'good rom' cagegory -- Meaning it is from the US or World region, and is a standard"
	echo " release ROM (i.e. not Alpha/Beta/Proto/Unl ect.)"
	echo " It will then attempt to generate a meaningfull path from that information and generate a 'mv'"
	echo " command that can be used to file the ROM according to the information found in it's name"
	echo " With the '-r' flag, the script will instead attempt to move the ROM automatically, craeting"
	echo " any needed directory structure in the [TargetDirectoryPath] specified"
	exit
fi
#if [ ! -f "$1" ]; then echo "Give me a rom name"; exit; fi

# Check for, and discard, the debug flag
if [ "$1" == '-d' ]; then DEBUG="true"; shift; else DEBUG="false"; fi;
# Check for, and discard the run flag
if [ "$1" == '-r' ]; then RUN="true"; shift; else RUN="false"; fi;
# Check if we have two arguments remaining
#  If we do, then the user want's to use the second arg as the path to a directory to
#  place the ROM in the 'mv' command, so set it.  Otherwise we need to set TARGETDIR to the
#  current directory so we have somewhere to generate the path against
if [ $# -eq 2 ]; then TARGETDIR="`/usr/bin/readlink -f $2`"; else TARGETDIR="`pwd`"; fi;

function decho () { if [ "$DEBUG" == "true" ]; then echo "$1"; fi; }

# External function calls
basename=/usr/bin/basename
cut=/usr/bin/cut
tr=/usr/bin/tr
sed=/usr/bin/sed
grep=/usr/bin/grep
awk=/usr/bin/awk

# String of fields we don't want to see in our 'good roms' path
#  These are usually non-official, hacked, unrelease, or alpha/beta/prototype roms
FILTER_OUT="\[[at].*?\]\|\[[aptobuhf].*\]\|(.*Alt.*)\|(.*Rev.*)\|([Uu]nl)\|(.*[Aa]lpha.*)\|(.*[Bb]eta.*)\|(.*[Pp]roto.*)\|(.*[Dd]emo.*)\|(.*[Kk]iosk.*)\|(.*[Ss]ample.*)\|\[sample\]\|(.*[Pp]romo.*)\|(Rumble Version)\|(SDK Build)\|(Developer Cart)\|(.*[Ss]pecial [Ee]dition.*)\|(.*[Pp]irate.*)\|(.*MDMM.*)\|(.*ACD3.*)\|(.*MDSTEE.*)"

# String of BIOS type names that we want to pre-filter
#  Spaces are important, as is case
BIOS=" bios \| scph \| SCPH \| SCPH-\| BIOS \| Bios\|\[BIOS\]"

decho "Got rom name: $1"
# Find the full file system path to the ROM
PATH=$(readlink -f "$1")
decho "Path: '$PATH'"

# Extract just the name of the file from the full path
FILE=$($basename "$PATH")
decho "File: '$FILE'"

# Grab the extension of the file
EXT="${FILE##*.}"
decho "Ext: '$EXT'"

# Grab the name of the file (the name WITHOUT the extension)
#  This is the one we need to scan usually
NAME="${FILE%.*}"
decho "Name: '$NAME'"

# Now we need to hunt for the region of the game which, due to the inconsistent
#  naming schemes of various ROM dat files, means we need to bruet force the
#  name until we find a contry code (in parenthies) somewhere in the string
# We also need to make sure that the name has all ')(' occurances replaced with ') ('
#  to allow us to parse each field properly
#isafe_name="$(echo "$NAME" | $sed 's#)(#) (#g')"
#decho "Safe Name: $safe_name"

REGION=""
# Before we do anything else, check if we have a BIOS file
#  If we do, set the REGION to BIOS as we want all of these together
if [ ! `echo "$NAME" | $grep -c "$BIOS"` -eq 0 ]; then REGION="bios"; fi

# Parse through all the fileds containted within () in the ROMs name
for field in $(echo "$NAME" | $awk -vRS=")" -vFS="(" '{print $2}'); do
	# Only check the field if we haven't already found a valid region
	if [ "$REGION" == "" ]; then
		decho "Scanning field: $field"
		# Just try to match the field against the know types
		# Order in this is important as the first match is the match that will be used
		#  and some ROMS have multiple Region codes in their name.  So make sure the
		#  region you prefer to detect is higher up than ones you don't prefer to detect
		case $field in
			*US*|*USA*) 			REGION="roms" ;;
			*World*) 				REGION="roms" ;;
			*EU*|*Eu*|*Europe*)		REGION="foreign/Europe" ;;
			*UK*|*"United Kingdom"*)	REGION="foreign/UK" ;;
			*AU*|*Australia*)		REGION="foreign/Australia" ;;
			*CA*|*Canada*)			REGION="foreign/Canada" ;;
			*JP*|*Jp*|*Japan*) 		REGION="foreign/Japan" ;;
			*DE*|*Germany*)			REGION="foreign/Germany" ;;
			*[Ff][Rr]*|*[Ff]rance*)			REGION="foreign/France" ;;
			*CA*|*Canada)			REGION="foreign/Canada" ;;
			*RU*|*Russia)			REGION="foreign/Russia" ;;
			*ES*|*Spain*)			REGION="foreign/Spain" ;;
			*SE*|*Sweden*)			REGION="foreign/Sweden" ;;
			*NL*|*Nl*|*Netherlands*)	REGION="foreign/Netherlands" ;;
			*BR*|*Brazil*)			REGION="foreign/Brazil" ;;
			*DK*|*Denmark*)			REGION="foreign/Denmark" ;;
			*NO*|*Norway*)			REGION="foreign/Norway" ;;
			*IT*|*Italy*)			REGION="foreign/Italy" ;;
			*TW*|*Taiwan*)			REGION="foregin/Taiwan" ;;
			*AS*|*"American Samoa"*)	REGION="foregin/AmericanSamoa" ;;
			*KR*|*Korea*)			REGION="foreign/Korea" ;;
			*CN*|*China*)			REGION="foreign/China" ;;
			*HK*|*"Hong Kong"*)		REGION="foreign/HongKong" ;;
			*PD*)					REGION="foreign/PD" ;;
			*FW*)					REGION="foreign/FW" ;;
		esac
	fi
done
# If we never found a valid region, default it to 'foreign/other'
if [ "$REGION" == "" ]; then REGION="foreign/unknown";	fi

# If the name contains one of our filtered strings (for non-standard roms)
#  then add a -filtered flag to the REGION to differentiate it
if [ ! `echo "$NAME" | $grep -c "$FILTER_OUT"` -eq 0 ]; then
	decho "Found a filter string in the rom's name"
	REGION="$REGION-filtered"
fi
decho "Region: '$REGION'"

# Build up the proposed path to place the ROM
PROPOSEDPATH="${TARGETDIR}/${REGION}/${FILE}"
decho "Proposed Path: $PROPOSEDPATH"

# Check that the proposed path isn't where the rom currently exists
if [ "$PATH" != "$PROPOSEDPATH" ]; then
	# Check if we are supposed to actually move the ROM
    if [ "$RUN" == "true" ]; then
		# If it needs to be moved, and we were asked to move it, then do so
		#  But make sure to make the directory path first (as the region codes can be obscure)
        if [ ! -d "${TARGETDIR}/${REGION}" ]; then /usr/bin/mkdir -p "${TARGETDIR}/${REGION}" || exit; fi;
        /usr/bin/mv -v "$PATH" "$PROPOSEDPATH"
    else
		# If we aren't going to actually move it, just print out where we would have moved it if asked
        echo "Proposed Move: mv -v $PATH -> $PROPOSEDPATH"
    fi
fi
