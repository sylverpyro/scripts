#!/bin/bash
#yaourt -S libretro-super-git
SRCDIR="$HOME/src"
if [ ! -d "$SRCDIR" ]; then
	mkdir "$SRCDIR"
fi
BUILDDIR="$SRCDIR/libretro-super"
if [ ! -d "$BUILDDIR" ]; then
	mkdir "$BUILDDIR"
fi
cd "$BUILDDIR"
git clone git://github.com/libretro/libretro-super.git
cd libretro-super
sh libretro-fetch.sh
sh libretro-build.sh
INSTALL_PATH=/usr/lib/libretro/
if [ ! -d "$INSTALL_PATH" ]; then
	mkdir "$INSTALL_PATH"
fi
sudo sh libretro-install.sh "$INSTALL_PATH"
