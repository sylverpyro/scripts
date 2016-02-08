#!/bin/bash
INSTALL_PATH="/usr/local"
# Before we do anything, get the dependencies

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
# This is the Arch Linux section
elif [ ! `grep -c "Arch Linux" /etc/issue` -eq 0 ]; then
        # Install the necessary pkgs
        for pkg in git pkg-config glew libpulse freetype2 sdl2 zlib mesa libxml2 libdrm zlib ffmpeg nvidia-cg-toolkit
        do
        if [ `pacman -Q | grep -c "^$pkg"` -eq 0 ]; then
                echo "You appear to be missing $pkg.  Running pacman -S $pkg"
                sudo pacman -S "$pkg"
        fi
        done
fi

# Make the source directory
test ! -d "$HOME/src" && mkdir "$HOME/src"
#test ! -d "$HOME/src/libretro-super" && mkdir $HOME/src/libretro-super
test ! -d "$HOME/src/libretro-super/.git" && git clone git://github.com/libretro/libretro-super.git "$HOME/src/"
# Go to the build dir
cd "$HOME/src/libretro-super"
# Grab the latest version of the super builder
git pull
# Have the builder fetch the projects
sh libretro-fetch.sh
# Build the projects
sh libretro-build.sh
# Make the install path
test ! -d "$INSTALL_PATH/lib/libretro" && sudo mkdir "$INSTALL_PATH/lib/libretro"
# Install the projects in the install path
sudo sh libretro-install.sh "$INSTALL_PATH/lib/libretro"
# Build and install retroarch it's self
sh retroarch-build.sh && (cd retroarch && sudo make install)
