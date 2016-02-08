#!/bin/bash

# Install dependencies if needed
if [ ! `grep -c "Ubuntu" /etc/issue` -eq 0 ]; then
	for pkg in zlib1g-dev 
	do
		if [ `dpkg -l | grep -c $pkg` -eq 0 ]; then
			echo "You do not appear to have $pkg installed.  calling sudo apt-get install $pkg"
			sudo apt-get install $pkg
		fi
	done
elif [ ! `grep -c "Arch Linux" /etc/issue` -eq 0 ]; then
	for pkg in zlib
	do
		if [ `pacman -Q | grep -c "^$pkg"` -eq 0 ]; then
			echo "You appear to be missing $pkg.  Running pacman -S $pkg"
			sudo pacman -S "$pkg"
		fi

	done
fi

# Directories
SRC=~/src
LIBRETRO="${SRC}/libretro"
INSTALLPREFIX="/usr/local/lib/libretro"

function build {
## If we are missing any directories, make them now
if [ ! -d "${SRC}" ]; then
	echo "Making ${SRC} directory to compile in"
	mkdir "${SRC}"
fi
if [ ! -d "${LIBRETRO}" ]; then
	echo "Making ${LIBRETRO} directory to compile in"
	mkdir "${LIBRETRO}"
fi
if [ ! -d "$INSTALLPREFIX" ]; then
	echo "Making the install path: $INSTALLPREFIX"
	sudo mkdir "$INSTALLPREFIX"
fi
## Libreto Super Build
## Includes about 20 libretro cores in one go
PROJECT=libretro-super
PROJECTDIR="${LIBRETRO}/${PROJECT}"
echo "Building $PROJECT in $PROJECTDIR"
if [ ! -d "${PROJECTDIR}" ]; then
	cd "${LIBRETRO}"
	echo "Doing initial GIT import"
	git clone git://github.com/libretro/libretro-super.git
fi
cd "${PROJECTDIR}"
echo "Updating libretro-super"
git pull
echo "Fetching updates to libretro cores"
./libretro-fetch.sh
echo "Compiling cores"
./libretro-build.sh
echo "Installing cores"
sudo ./libretro-install.sh "${INSTALLPREFIX}"

#### PCSX rearmed was merged into libretro-super - so we dont need this part anymore.
## pcsx rearmed
## This is technically for ARM platforms, but it works on fast ix86 processesors as well
#PROJECT=libretro-pcsxrearmed
#PROJECTDIR="${LIBRETRO}/pcsx_rearmed"
#echo "Building $PROJECT in $PROJECTDIR"
#if [ ! -d "${PROJECTDIR}" ]; then
#	cd "${LIBRETRO}"
#	echo "Doing initial GIT import"
#	git clone git://github.com/libretro/pcsx_rearmed.git
#fi
#cd "${PROJECTDIR}"
#echo "Updating pcsx_rearmed"
#git pull
#echo "Configuring for build"
#./configure --platform=libretro --sound-drivers=libretro
#echo "Building and installing"
#make && sudo cp -v libretro.so "${INSTALLPREFIX}/libretro-pcsxrearmed.so"

## yabause: Sega Saturn
#PROJECT=yabause
#PROJECTDIR="${LIBRETRO}/${PROJECT}"
#echo "Building $PROJECT in $PROJECTDIR"
#if [ ! -d "${PROJECTDIR}" ]; then
#        cd "${LIBRETRO}"
#        echo "Doing initial GIT import"
#        git clone git://github.com/libretro/yabause.git
#fi
#cd "${PROJECTDIR}"
#echo "Updating yabause-libretro"
#git pull
#echo "Building and installing"
#cd libretro
#make && sudo cp -v ./yabause_libretro.so "${INSTALLPREFIX}/yabause-libretro.so"
}

function usage {
	echo "$0 build"
}

if [ $# -eq 0 ]; 
	then build; 
else
	case $1 in
		'build') build ;; 
		*) usage ;;
	esac
fi
