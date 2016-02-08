#!/bin/bash
## Emulators		##
# Nintendo 64
EMU_N64="mupen64plus"
# Dreamcast
EMU_DREAMCAST="lxdream"
# Gamecube
EMU_GAMECUBE="dolphin-emu"
# EMU_MAME	
EMU_MAME="sdlmame"
# Sony Playstation 2
EMU_PS2="pcsx2"
# Retroarch
EMU_RETROARCH="retroarch"
## Libretro Cores for retroarch
## Libretro library location
LIBRETRO="/usr/lib/libretro"
# Arcade
#CORE_ARCADE="$LIBRETRO/fb_alpha_libretro.so"
CORE_ARCADE="$LIBRETRO/libretro-fba.so"
# Nintendo (NES)
#CORE_NES="$LIBRETRO/fceumm_libretro.so"
CORE_NES="$LIBRETRO/libretro-fceu.so"
# Nintendo Gameboy/Gameboy Color (GB/GBC)
#CORE_GAMEBOY="$LIBRETRO/gambatte_libretro.so"
CORE_GAMEBOY="$LIBRETRO/libretro-gambatte.so"
# Nintendo Gameboy Advanced (GBA)
#CORE_GBA="$LIBRETRO/vba_next_libretro.so"
CORE_GBA="$LIBRETRO/libretro-vba.so"
# Nintendo Super Nintendo (SNES)
#CORE_SNES="$LIBRETRO/snes9x_next_libretro.so"
CORE_SNES="$LIBRETRO/libretro-snes9x-next.so"
# Sega Genesis/Master System/GameGear/CD
#CORE_GENESIS="$LIBRETRO/genesis_plus_gx_libretro.so"
CORE_GENESIS="$LIBRETRO/libretro-genplus.so"
# SEGA 32X
#CORE_32X="$LIBRETRO/picodrive_libretro.so"
CORE_32X="$LIBRETRO/libretro-picodrive.so"
# SEGA Saturn
#CORE_SATURN="$LIBRETRO/libretro-yabause.so"
CORE_SATURN="$LIBRETRO/libretro-yabause.so"
# Sony Playstation
#CORE_PSX="$LIBRETRO/pcsx_rearmed_libretro.so"
CORE_PSX="$LIBRETRO/libretro-pcsx_rearmed.so"

# Cleanup function (in case of errors)
die()
{
	# Print the error
	echo "Error: $1"
	# Make sure we are not in the RUNDIR
	cd
	# Remove the temp directory
	test -d "$RUNDIR" && rm -r "$RUNDIR"
	# Exit immediately
	exit 1
}

# Usage Function
function usage {
	echo "Usage: $0 PLATFORM ROM"
	echo -e "\t Where PLATFORM is one of:"
	echo -e "\t mame*        - EMU_MAME Multiple Arcade Machine Emulator"
	echo -e "\t arcade | fba - Final Burn Alpha (Alternative to EMU_MAME)"
	echo -e "\t nes          - Nintendo Entertainment System"
	echo -e "\t ngb          - Nintendo GameBoy or GameBoy Color"
	echo -e "\t snes         - Super Nintendo Entertainment System"
	echo -e "\t gba          - Nintendo GameBoy Advanced"
	echo -e "\t n64          - Nintendo 64"
	echo -e "\t gamecube*    - Nintendo GameCube"
	echo -e "\t genesis      - SEGA Genesis"
	echo -e "\t segacd       - SEGA CD"
	echo -e "\t gamegear     - SEGA GameGear"
	echo -e "\t mastersystem - SEGA Master System"
	echo -e "\t 32x          - SEGA 32X"
	echo -e "\t saturn       - SEGA Saturn"
	echo -e "\t dreamcast*   - SEGA Dreamcast"
	echo -e "\t psx          - SONY Playstation"
	echo -e "\t ps2*         - SONY Playstation 2"
	echo -e "\t * - Denotes platform not supported by retroarch"
}

# Function for copying (and decompressing) ROMs to local /tmp folder
#  This is in case we are loading a ROM from a nework location that may be laggy
#  Instead of relying on a ROM that could vanish with the network, we just make a local copy
make_tmp_rom()
{
	# Set file from the argument
	COMP_FILE="$1"
	echo "Extracting $COMP_FILE"
	echo "Please be patient ..."

	# Figure out what decompression system we need to use
	case "${COMP_FILE}" in
	*.zip )
		which unzip >/dev/null 2>&1 || die "Cannot find command unzip to extract $ROM"
		unzip "${COMP_FILE}" -d "${RUNDIR}" || die "Extraction of $ROM failed"
		;;
	*.7z )
		which 7z >/dev/null 2>&1 || die "Cannot find command 7z to extract $ROM"
		7z x "${COMP_FILE}" -o"${RUNDIR}" || die "Extraction of $ROM failed"
		;;
	*.rar )
		which unrar >/dev/null 2>&1 || die "Cannot find unrar to extract $ROM"
		unrar x "${COMP_FILE}" "${RUNDIR}" || die "Extraction of $ROM failed"
		;;
	# If the ROM is not compressed, just copy it to the RUNDIR
	* )
		cp "$ROM" "$RUNDIR"
		;;
	esac

	# Set the ROM to be the largest non-directory in the RUNDIR
	ROM="${RUNDIR}/`ls -Sp \"${RUNDIR}\" | grep -v /$ | head -n1`"
	if [ -z "${ROM}" ]; then
		# If nothing is found, die (this probably should never happen)
	        die "Cannot find any files in root of archive"
	fi
	
	echo "Rom to be loaded: $ROM"
}

verify_core() {
	if [ ! -f "$1" ]; then
		die "Could not find libretro core $1 for $PLATFORM"
	fi
}

# Function to check that we have a file we can use
verify_bin() {
	if [ ! "`which "$1" 2>/dev/null`" ]; then 
		die "Could not find binary $1 for $PLATFORM"
	fi
}

## Start actually doing something useful ##

if [ ! $# -eq 2 ]; then
	usage
	die "Wrong number of arguments"
fi

# Get our arguments
PLATFORM="$1"
ROM="`readlink -f "$2"`"
# Make sure we can actually read the ROM file
if [ "$PLATFORM" != "check" -a ! -r "$ROM" ]; then
	die "Cannot read file $ROM"
fi

# Make a temp director to run out of and (if necessary) make_tmp_rom the ROM into
RUNDIR="`mktemp -d`"

# Move to the run directory (this is for containing any junk files produced by retroarch)
cd "$RUNDIR"

# Select the requested platform
# Verify the necessary emulator is available (and core if retroarch)
# Decompress the ROM if the emulator needs it
# Launch the emulator
case $PLATFORM in
	"mame")
	verify_bin "$EMU_MAME"
	"$EMU_MAME" -rompath `dirname "$ROM"` "$ROM" ;; 

	"arcade"|"fba")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_ARCADE"
	"$EMU_RETROARCH" -L "$CORE_ARCADE" "$ROM" ;;

	"nes"|"nnes"|"fceu")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_NES"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_NES" "$ROM" ;;

	"ngb"|"gbc"|"gameboy"|"gameboycolor"|"gambatte")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_GAMEBOY"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_GAMEBOY" "$ROM" ;;

	"snes"|"supernintendo"|"snes9xnext")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_SNES"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_SNES" "$ROM" ;;

	"gba"|"gameboyadvanced"|"vba")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_GBA"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_GBA" "$ROM" ;;

	"n64"|"nintendo64"|"mupen64plus")
	verify_bin "$EMU_N64"
	make_tmp_rom "$ROM"
	"$EMU_N64" --fullscreen --resolution 960x720 "$ROM"
	#$EMU_RETROARCH -L $LIBRETRO/mupen64plus_libretro.so "$ROM"
	;;

	"gamecube"|"ngc"|"dolphin")
	verify_bin "$EMU_GAMECUBE"
	make_tmp_rom "$ROM"
	"$EMU_GAMECUBE" "$ROM"
	;;

	"genesis"|"segacd"|"gamegear"|"mastersystem"|"genesisplusgx")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_GENESIS"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_GENESIS" "$ROM" 
	;;

	"32x"|"sega32x")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_32X"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_32X" "$ROM" ;;
	## gens --fs --quickexit --disable-led "$ROM" ;;

	"saturn"|"segasaturn"|"yabause")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_SATURN"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_SATURN" "$ROM" ;;

	"dreamcast"|"lxdream")
	verify_bin "$EMU_DREAMCAST"
	make_tmp_rom "$ROM"
	"$EMU_DREAMCAST" "$ROM" ;;

	"psx"|"pcsx")
	verify_bin "$EMU_RETROARCH"
	verify_core "$CORE_PSX"
	make_tmp_rom "$ROM"
	"$EMU_RETROARCH" -L "$CORE_PSX" "$ROM" 
	;;

	"ps2"|"pcsx2")
	verify_bin "$EMU_PS2"
	make_tmp_rom "$ROM"
	"$EMU_PS2" "$ROM"
	;;

	# Verify all emulators and cores are in-tact
	"check")
	# Check for the configured emulators
	echo "Checking for configured emulators:"
	set | grep "^EMU_" | while read emu;
	do 
		target="`echo "$emu" | cut -f2 -d"="`"
		test -r "`which "$target" 2>/dev/null`" && echo "$emu is OK : `which "$target"`" || echo "$emu is MISSING"
	done
	# Check for the configured libretro cores
	echo "Checking for configured libretro cores"
	set | grep "^CORE_" | while read core; 
	do 
		test -r "`echo "$core" | cut -f2 -d"="`" && echo "$core is OK" || echo "$core is MISSING"
	done
	;;
	*) usage ;;
esac

# Return to the user's home (so we can remove the RUNDIR)
cd

# Remove the temp running dir
rm -r "$RUNDIR"

# Check if there are any hanging references to the ROM file
## Print out the processes in case we kill something imporant the user didn't want killed 
##  We are going to kill it anyway, but at least the user sees what we killed
lsof | grep "$ROM"

# Find what processes still have a reference open to the ROM file
lsof | grep "$ROM" | awk '{print $2}' | while read proc
do 
	# If we find any, kill the process
	kill $proc
done
