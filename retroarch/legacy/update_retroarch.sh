#!/bin/bash

## Global variables
# Bild Directories
SRC=~/src
RETROARCH="${SRC}/retroarch"
# Install prefix for build
INSTALLPREFIX="/usr/local"
CFGFLAGS="--enable-kms --enable-egl --enable-libxml2"

function usage {
	echo "$0 [options] MODE"
	echo " Where Mode is one of: "
	echo "   stable  - Build the highest numbered tag from git"
	echo "   latest  - Build the latest git commit available"
	echo "   version <version number> - Build the git version with tag {version number}"
	echo "   If no mode is supplied, then \"stable\" is assumed"
	echo " Where options is: "
	echo "   -r      : Rebuild flag - force REBUILD even if we detect this version has already been compiled"
}

function prep_workspace {
	# Before we do anything, get the dependencies
	# Check for and install dependencies
	# See what OS we are running
	if [ ! `grep -c "Ubuntu" /etc/issue` -eq 0 ]; then
		# Install the necessary pkgs
		for pkg in git pkg-config libglew-dev libpulse-dev libfreetype6-dev libavcodec-dev libsdl1.2-dev zlib1g-dev libegl1-mesa-dev libxml2-dev libdrm-dev libgbm-dev
		do
			if [ `dpkg -l | grep -c "^ii  $pkg"` -eq 0 ]; then
				echo "You appear to be missing $pkg.  Running sudo apt-get install $pkg"
				sudo apt-get install $pkg
			fi
		done
	# This is the retroarch section
	elif [ ! `grep -c "Arch Linux" /etc/issue` -eq 0 ]; then
		# Install the necessary pkgs
		for pkg in git pkg-config glew libpulse freetype2 sdl2 zlib mesa libxml2 libdrm 
		do
		if [ `pacman -Q | grep -c "^$pkg"` -eq 0 ]; then
			echo "You appear to be missing $pkg.  Running pacman -S $pkg"
			sudo pacman -S "$pkg"
		fi
		done
	fi

	# Check if we have the source directory
	if [ ! -d "${SRC}" ]; then
		# If we don't, report and make it
	        echo "Making ${SRC} directory to compile in"
	        mkdir "${SRC}"
	fi
	# Check if we have the retroarch src directory
	if [ ! -d "${RETROARCH}" ]; then
		# If not, report and make it
	        echo "Making ${RETROARCH} directory to compile in"
	        mkdir "${RETROARCH}"
	fi
	# Make sure no one has been building in the worksapce
	if [ -d "$RETROARCH/RetroArch" -a -f "$RETROARCH/RetroArch/retroarch" ]; then
		echo "Someone has been building in $RETROARCH/RetroArch"
		echo "Removing the folder and starting a new one"
		rm -rfv "$RETROARCH/RetroArch"
	fi
	# See if there has been an inital git import
	if [ ! -d "${RETROARCH}/RetroArch" ]; then
		# If not, do the initial import
		echo "Doing initial pull of retroarch"
	        cd "${RETROARCH}"
		git clone git://github.com/Themaister/RetroArch.git
	fi

	echo "Preparing workspace directories"
	echo "Updating master repository $RETROARCH/RetroArch"
	# Move to the git clone directory
	cd "${RETROARCH}/RetroArch"
	# Get the latest head from git
	echo "Performing git pull"
	git pull
}

function build () {
	# Change to the build directory
	cd "$RETROARCH/$BUILD"
	# If not in rebuild mode, check if we already have a binary
	if [ "$REBUILD" == "false" -a -f "$RETROARCH/$BUILD/retroarch" ]; then
		echo "Version $BUILD already built.  Using that"
		echo "To force a rebuild specify $0 -r $MODE"
		# If we do see if it's installed
		if [ `diff -q "$RETROARCH/$BUILD/retroarch" "$INSTALLPREFIX/bin/retroarch" > /dev/null 2>&1; echo $?` -eq 0 ]; then
			echo "Version $BUILD is already installed - Skipping Installation"
		# IF it's not installed, install it
		else	
			echo "Installing prebuild version $BUILD"
			sudo make install
		fi
	# If in rebuild mode, or we have no binary, make it from scratch
	else
		# Do a configure
		echo "Configuring $BUILD"
		./configure --prefix="$INSTALLPREFIX" --enable-kms --enable-egl --enable-zlib --enable-pulse
		# Do a make and make install
		echo "Making $BUILD"
		make && sudo make install
	fi
}

function create_version_dir () {
	# First, if we are in rebuild mode
	if [ "$REBUILD" == "true" -a -d "$RETROARCH/$BUILD" ]; then
		echo "Removing old build directory $RETROARCH/$BUILD"
		rm -rfv "$RETROARCH/$BUILD"
	fi
        # See if we have built the latest release
        if [ -d "$RETROARCH/$BUILD" ]; then
		# If we do, skip creating it (again)
                echo "Version $BUILD src directory already available"
        elif [ "$MODE" == "latest" ]; then
		echo "Copying latest GIT head to $BUILD"
		# If in latest mode simply copy the GIT source directory
		cp -r "$RETROARCH/RetroArch" "$RETROARCH/$BUILD"
	else
		echo "Making GIT archive of $BUILD"
                # If not, make an archive of the latest verstion
                git archive --format=tar --prefix="$BUILD"/ "$BUILD" > "$RETROARCH/$BUILD.tar"
                cd "$RETROARCH"
                # Extract the archive and remove the tar file
                tar -xf "$BUILD.tar"
                rm "$RETROARCH/$BUILD.tar"
        fi
}

# See if we need to force a REBUILD
[ "$1" == '-r' ] && { REBUILD="true"; shift; } || REBUILD="false"

# See if we got no args (which is assumed to be "stable")
[ $# -eq 0 ] && MODE="stable" || MODE=$1

# Determine what the build directory is going to be based on the mode
case $MODE in
	'stable') 
		# Do all of the prep work
		prep_workspace
		# Change to the source directory
		cd "$RETROARCH/RetroArch"
		# Find the latest stable tagged version available from git
		BUILD=`git tag | grep -v -E "(-|beta|rc|wip)" | sort | tail -n 1`
		# Setup the version build directory
		create_version_dir
		# Call the build function
		build
	;;
	'version')
		# Do all of the prep work
		prep_workspace
		# Change to the source directory
		cd "$RETROARCH/RetroArch"
		if [ `git tag | grep -x -c "$2"` -eq 1 ]; then
			BUILD="$2"
		else
			echo "Error: No version $2 found in git"
			echo "Available versions: "
			git tag
			exit 1
        	fi
		# Setup the version build directory
		create_version_dir
		# Call the build function
		build
	;;
	'latest')
		# Do all of the prep work
		prep_workspace
		# Change to the source directory
		cd "$RETROARCH/RetroArch"
		# Find when the last commit was added
	        COMMIT=`git log --name-status HEAD^..HEAD | grep ^Date: | awk '{print $2" "$3" "$4" "$5" "$6}'`;
	        # Make that into a timestamp
	        TIMESTAMP=`date +%Y%m%d%H%M --date "$COMMIT"`
	        # Find the version from the retroarch general.h file
	        RA_VER=` grep "define PACKAGE_VERSION " "$RETROARCH/RetroArch/general.h" | tail -n 1 |  awk -F '"' '{print $2}'`
		# String those togeather to get our build version
	        BUILD="${RA_VER}-${TIMESTAMP}"	
		# Setup the version build directory
		# Call the build function
		build
	;;

	*) usage; exit 1;;
esac 

## See what mode we are working in
#case $MODE in 
#	"stable") build_version stable ;;
#	"version"|"ver") build_version $2;;
#	"latest") build_latest ;;
#	*) usage ;;
#esac
