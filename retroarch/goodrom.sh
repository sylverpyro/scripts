#!/bin/bash
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

function script_help () {
  echo "Usage: $0 [-d] [-r] <RomName> [TargetDirectoryPath]"
  echo "  -d        : Enable debugging"
  echo "  -q        : Supress 'Rom is in ideal location' messages"
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
}
if [ $# -eq 0 ]; then
    script_help; exit
elif [ "$1" == "-h" ]; then 
    script_help; exit
fi
#if [ ! -f "$1" ]; then echo "Give me a rom name"; exit; fi

DEBUG="false"
RUN="false"
QUIET="false"

while [[ "$1" == -[drq] ]]; do
  case "$1" in
    # Check for, and discard, the debug flag
    -d) DEBUG="true"; shift;;
    # Check for, and discard the run flag
    -r) RUN="true"; shift;;
    # Check for, and discard, the quiet flag
    -q) QUIET="true"; shift;;
  esac
done
# Check if we have two arguments remaining
#  If we do, then the user want's to use the second arg as the path to a directory to
#  place the ROM in the 'mv' command, so set it.  Otherwise we need to set TARGETDIR to the
#  current directory so we have somewhere to generate the path against
if [ $# -eq 2 ]; then TARGETDIR="`/usr/bin/readlink -f "$2"`"; else TARGETDIR="`pwd`"; fi;

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
FILTER_OUT="\[not .*\]\|\[saved game\]\|\[.*hack.*]\|\[m\]\|\[m .*\]\|\[manual\]\|\[m3\]\|\[cr.*\]\|\[[at].*?\]\|\[[aptobuhf].*\]\|(.*Alt.*)\|(.*Rev.*)\|([Uu]nl)\|(.*[Aa]lpha.*)\|(.*[Bb]eta.*)\|(.*[Pp]roto.*)\|(.*[Dd]emo.*)\|(.*[Kk]iosk.*)\|(.*[Ss]ample.*)\|\[sample\]\|(.*[Pp]romo.*)\|(Rumble Version)\|(SDK Build)\|(Developer Cart)\|(.*[Ss]pecial [Ee]dition.*)\|(.*[Pp]irate.*)\|(.*MDMM.*)\|(.*ACD3.*)\|(.*MDSTEE.*)"

# String of BIOS type names that we want to pre-filter
#  Spaces are important, as is case
BIOS=" bios \| scph \| SCPH \| SCPH-\| BIOS \| Bios\|\[BIOS\]"

decho "Got rom name: $1"
# Find the full file system path to the ROM
PATH=$(readlink -f "$1")
decho "Path: '$PATH'"

if [ ! `echo "$PATH" | $grep -c '/colissions/'` -eq 0 ]; then
  test "$QUIET" == "false" && echo "Detected '$PATH' is in a 'colissions' path (part of the path contains that folder).  Skipping ROM"
  exit
fi

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
if [ ! `echo "$NAME" | $grep -c "$BIOS"` -eq 0 ]; then 
  REGION="bios"
  decho "Region detected as BIOS"
fi

# Parse through all the fileds containted within () in the ROMs name
for field in $(echo "$NAME" | $awk -vRS=")" -vFS="(" '{print $2}'); do
  # Only check the field if we haven't already found a valid region
  if [ "$REGION" == "" ]; then
    decho "Scanning field: $field"
    # Just try to match the field against the know types
    # Order in this is important as the first match is the match that will be used
    #  and some ROMS have multiple Region codes in their name.  So make sure the
    #  region you prefer to detect is higher up than ones you don't prefer to detect
    # Sometimes checking TOSEC region codes can help: http://www.tosecdev.org/tosec-naming-convention
    case $field in
      *US*|*USA*)                 REGION="roms" ;;
      *World*)                    REGION="roms" ;;
      En|en|en-*)                 REGION="roms" ;;
      *EU*|*Eu*|[Ee]u|*Europe*)   REGION="foreign/Europe" ;;
      *UK*|[Uu]k|*gb*|gb|*"United Kingdom"*) REGION="foreign/UK" ;;
      *AU*|[Aa]u|*Australia*)     REGION="foreign/Australia" ;;
      *CA*|[Cc]a|*Canada*)        REGION="foreign/Canada" ;;
      *JP*|*Jp*|[Jj]p|*Japan*)    REGION="foreign/Japan" ;;
      *DE*|[Dd]e|*Germany*)       REGION="foreign/Germany" ;;
      *F[Rr]*|[Ff]r|*[Ff]rance*)  REGION="foreign/France" ;;
      *RU*|[Rr]u|*Russia)            REGION="foreign/Russia" ;;
      *ES*|[Ee]s|*Spain*)            REGION="foreign/Spain" ;;
      *SE*|[Ss]e|*Sweden*)           REGION="foreign/Sweden" ;;
      *NL*|*Nl*|[Nn]l|*Netherlands*) REGION="foreign/Netherlands" ;;
      *BR*|[Bb]r|*Brazil*)           REGION="foreign/Brazil" ;;
      *DK*|[Dd]k|*Denmark*)          REGION="foreign/Denmark" ;;
      *NO*|[Nn]o|*Norway*)           REGION="foreign/Norway" ;;
      *IT*|[Ii]t|*Italy*)            REGION="foreign/Italy" ;;
      *TW*|[Tt]w|*Taiwan*)           REGION="foreign/Taiwan" ;;
      *AS*|[Aa]s|*"American Samoa"*) REGION="foreign/AmericanSamoa" ;;
      *KR*|[Kk]r|*Korea*)            REGION="foreign/Korea" ;;
      *CN*|[Cc]n|*China*)            REGION="foreign/China" ;;
      *HK*|[Hh]k|*"Hong Kong"*)      REGION="foreign/HongKong" ;;
      *HU*|[Hh]u|*Hungary*)          REGION="foreign/Hungary" ;;
      *SK*|[Ds]k|*Slovakia*)         REGION="foreign/Slovakia" ;;
      *CS*|[Cc]s|Serbia)             REGION="foreign/Serbia" ;;
      *PT*|[Pp]s|Portugal)           REGION="foreign/Portugal" ;;
      *SL*|[Ss]l|"Sierra Leone")     REGION="foreign/SierraLeone" ;;
      *SV*|[Ss]v|"El Salvador")      REGION="foreign/ElSalvador" ;;
      *SR*|[Ss]r|Suriname)           REGION="foreign/Suriname" ;;
      *DO*|[Dd]o|"Dominican Republic") REGION="foreign/Dominican Republic" ;;
      "Finland")                  REGION="foreign/Finland" ;;
      *SQ*|[Ss]q)                 REGION="foreign/SQ" ;;
      *DA*|[Dd]a)                 REGION="foreign/DA" ;;
      *PD*|[Pp]d)                 REGION="foreign/PD" ;;
      *FW*|[Ff]w)                 REGION="foreign/FW" ;;
      *Asia*)                     REGION="foreign/Asia" ;;
      *PAL*)                      REGION="foreign/PAL" ;;
    esac
  fi
done
# If we never found a valid region, default it to 'foreign/other'
if [ "$REGION" == "" ]; then 
    REGION="foreign/unknown"
    decho "Region not detected, set to $REGION"
fi

# If the name contains one of our filtered strings (for non-standard roms)
#  then add a -filtered flag to the REGION to differentiate it
if [ ! `echo "$NAME" | $grep -c "$FILTER_OUT"` -eq 0 ]; then
  decho "Found a filter string in the rom's name"
  REGION="$REGION-filtered"
else
    decho "Region: '$REGION'"
fi

# Build up the proposed path to place the ROM
PROPOSEDPATH="${TARGETDIR}/${REGION}/${FILE}"
decho "Proposed Path: $PROPOSEDPATH"

# Check that the proposed path isn't where the rom currently exists
if [ "$PATH" != "$PROPOSEDPATH" ]; then
  # Check if there is already a file at this location
  # If there is, we need to collect it in a 'colissions' folder
  #  and add a colision number indicator
  colission_count=0
  while [ -f "$PROPOSEDPATH" ]; do
    #echo "$PROPOSEDPATH already exists"
    #echo "colission: $PATH"
    let 'colission_count+=1'
    REGION="colissions"
    PROPOSEDPATH="$TARGETDIR/$REGION/${FILE}.$colission_count"
  done
  # Check if we are supposed to actually move the ROM
  if [ "$RUN" == "true" ]; then
  # If it needs to be moved, and we were asked to move it, then do so
  #  But make sure to make the directory path first (as the region codes can be obscure)
      if [ ! -d "${TARGETDIR}/${REGION}" ]; then /usr/bin/mkdir -p "${TARGETDIR}/${REGION}" || exit; fi;
      /usr/bin/mv -n -v "$PATH" "$PROPOSEDPATH"
  else
  # If we aren't going to actually move it, just print out where we would have moved it if asked
      echo "Proposed Move: mv -n -v $PATH -> $PROPOSEDPATH"
  fi
elif [ "$QUIET" == "false" ]; then
    echo "Rom is already in it's ideal location: $PATH"
fi
