#!/bin/bash
SRC="$HOME/src"
TMPSRC="/tmp/$USER-libretro-super-src"
# Set the temp directory for GCC to use
TMPDIR="/tmp"
# The libretro super directory location
SUPERDIR="$SRC/libretro-super"
# The libretro-super libretro-fetch.sh script location
SUPERFETCH="$SUPERDIR/libretro-fetch.sh"
# The libretro-super libretro-build.sh script location
SUPERBUILD="$SUPERDIR/libretro-build.sh"
TMP_SUPERBUILD="$TMPSRC/libretro-build.sh"
# The libretro-super libretor-install.sh script location
SUPERINSTALL="$SUPERDIR/libretro-install.sh"
TMP_SUPERINSTALL="$TMPSRC/libretro-install.sh"
# The retroarch build script
RARCHBUILD="$SUPERDIR/retroarch-build.sh"
TMP_RARCHBUILD="$TMPSRC/retroarch-build.sh"
# The target install directory
INSTALLDIR="/usr/local/lib/libretro"
# List of implementations to build
BUILDS="
libretro-snes9x-next,build_libretro_snes9x_next
libretro-genesis-plus-gx,build_libretro_genesis_plus_gx 
libretro-fb-alpha,build_libretro_fb_alpha 
libretro-vba-next,build_libretro_vba_next 
libretro-fceu,build_libretro_fceu 
libretro-gambatte,build_libretro_gambatte 
libretro-desmume,build_libretro_desmume 
libretro-pcsx-rearmed,build_libretro_pcsx_rearmed 
libretro-mupen64plus,build_libretro_mupen64 
libretro-ffmpeg,build_libretro_ffmpeg 
libretro-picodrive,build_libretro_picodrive
"

function die {
	echo "$1"
	echo "Cleaning out $TMPSRC"
	test -d "$TMPSRC" && rm -rf "$TMPSRC"
	exit
}

# run if user hits control-c
control_c()
{
        echo -en "\nCaught Ctrl-c: Exiting now\n"
        die
}
 
# trap keyboard interrupt (control-c)
trap control_c SIGINT

# Make the source dir
test -d "$SRC" || mkdir "$SRC"
# Pull down libretro-super to source the rest of the script from
if [ -d "$SUPERDIR" ]; then
	cd "$SUPERDIR"
	git pull
else
	git clone git://github.com/libretro/libretro-super.git "$SUPERDIR"
fi

# Move to libretro-super dir
cd "$SUPERDIR"
# Fetch and update all of the libretro-super sub-projects
$SUPERFETCH

# Make the temp source directory and copy libretro-super into it
test -d "$TMPSRC" || mkdir "$TMPSRC"
echo "Copying libretro-super files to $TMPSRC"
find "$SUPERDIR" -maxdepth 1 -type f -exec cp -rf '{}' "$TMPSRC" \;
cp -rf "$SUPERDIR/dist" "$TMPSRC"
# Change to the TMPSRC directory for the rest of the script
cd "$TMPSRC"
# Start running through the builds
for pair in $BUILDS
do
	DIR="`cut -d ',' -f 1 <<< "$pair"`"
	BUILDCMD="`cut -d ',' -f 2 <<< "$pair"`"
	# Copy the library directory to the tmp build directory
	echo "Copying $SUPERDIR/$DIR -> $TMPSRC/$DIR to build"
	cp -rf "$SUPERDIR/$DIR" "$TMPSRC/$DIR"
	# Call the build command for this build pair
	echo "Running $TMP_SUPERBUILD $BUILDCMD"
	$TMP_SUPERBUILD $BUILDCMD
	# Make sure the install directory exists
	test -f "$INSTALLDIR" && die "Error: $INSTALLDIR currently exists as a file"
	test -d "$INSTALLDIR" || sudo mkdir "$INSTALLDIR"
	# Install the built library
	echo "Running sudo $TMP_SUPERINSTALL $INSTALLDIR"
	sudo $TMP_SUPERINSTALL "$INSTALLDIR"
	# Clean out the directory in TMP to make space for the next one
	echo "Cleaning out $TMPSRC/$DIR"
	rm -rf "$TMPSRC/$DIR"
done

# Handle the retroarch build seperately (it's not part of the build script yet)
echo "Copying $SUPERDIR/retroarch -> $TMPSRC/retroarch to build"
cp -rf "$SUPERDIR/retroarch" "$TMPSRC/retroarch"
# Call the retroarch build script
$TMP_RARCHBUILD
# Enter the temp retroarch directory so we can install it 
cd "$TMPSRC/retroarch"
# Install the retroarch script
sudo make install
# leave the tmp directory
cd
# Remove the tmp directory to make space again
rm -rfv "$TMPSRC"
# Say we are done
echo "Done"
