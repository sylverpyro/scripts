#!/bin/bash
RETROARCH="/usr/bin/retroarch"
LIBRETRO="/usr/lib/libretro"
SYSTEMPATH=""
GFXCFGS="/usr/local/btsync/retroarch/graphic-configs/"

function usage {
	echo "Usage: $0 PLATFORM ROM"
	echo -e "\t Where PLATFORM is one of:"
	echo -e "\t mame*        - MAME Multiple Arcade Machine Emulator"
	echo -e "\t arcade | fba - Final Burn Alpha (Alternative to MAME)"
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

if [ ! -f "$RETROARCH" ]; then
	echo "Error: retroarch binary not found in path"
	exit
fi

PLATFORM="$1"
ROM="`readlink -f "$2"`"
RUNDIR="`mktemp -d`"
cd "$RUNDIR"
case $PLATFORM in
	"mame")
	mame -rompath `dirname "$ROM"` "$ROM" ;;

	"arcade"|"fba")
	$RETROARCH -L $LIBRETRO/fb_alpha_libretro.so "$ROM" ;;

	"nes"|"nnes"|"fceu")
	#$RETROARCH --appendconfig $GFXCFGS/syn-nes.cfg -L $LIBRETRO/fceumm_libretro.so "$ROM"
	$RETROARCH -L $LIBRETRO/fceumm_libretro.so "$ROM"
	;;

	"ngb"|"gbc"|"gameboy"|"gameboycolor"|"gambatte")
	$RETROARCH -L $LIBRETRO/gambatte_libretro.so "$ROM" ;;

	"snes"|"supernintendo"|"snes9xnext")
	$RETROARCH -L $LIBRETRO/snes9x_next_libretro.so "$ROM" ;;

	"gba"|"gameboyadvanced"|"vba")
	$RETROARCH -L $LIBRETRO/gameboyadvanced "$ROM" ;;

	"n64"|"nintendo64"|"mupen64plus")
	if [ ! -f "`which mupen64plus-zip`" ]; then
		mupen64plus-zip "$ROM" 
	else
		echo "Error: mupen64plus-zip not found in path"
	fi ;;

	"gamecube"|"ngc"|"dolphin")
	if [ ! -f "`which dolphin-emu-zip`" ]; then
		dolphin-emu-zip "$ROM" 
	else
		echo "Error: dolphin-emu-zip not found in path"
	fi ;;

	"genesis"|"segacd"|"gamegear"|"mastersystem"|"genesisplusgx")
	$RETROARCH -L $LIBRETRO/genesis_plus_gx_libretro.so "$ROM" ;;

	"32x"|"sega32x"|"gens-gs")
	gens --fs --quickexit --disable-led "$ROM" ;;

	"saturn"|"segasaturn"|"yabause")
	$RETROARCH -L $LIBRETRO/libretro-yabause.so "$ROM" ;;

	"dreamcast"|"lxdream")
	if [ ! -f "`which lxdream`" ]; then
		lxdream "$ROM" 
	else
		echo "Error: lxdream is not in the path"
	fi ;;

	"psx"|"pcsx")
	#$RETROARCH --appendconfig $GFXCFGS/syn-psx.cfg -L $LIBRETRO/pcsx_rearmed_libretro.so "$ROM" 
	$RETROARCH -L $LIBRETRO/pcsx_rearmed_libretro.so "$ROM" 
	;;
	"ps2"|"pcsx2")
	pcsx2-zip "$ROM" ;;

	*)
		usage ;;
esac
cd
rm -r "$RUNDIR"
