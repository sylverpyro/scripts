#!/bin/bash

declare -A PACKAGES

## Retroarch package options
PACKAGES[retroarch-latest]="retroarch-git"
PACKAGES[retroarch-stable]="retroarch"

## Arcade platforms
# Arcade is normally going to be FBA (Final Burn Alpha)
PACKAGES[arcade]="libretro-fba-git"
PACKAGES[fba]="libretro-fba-git"
# But MAME is here too if we want to make it explicitly
PACKAGES[mame]="libretro-mame-git"

## Nintendo platforms
# The same package (gambatte) emulates both GB and GBC
PACKAGES[gameBoy]="libretro-gambatte-git"
PACKAGES[gameBoyColor]="libretro-gambatte-git"
PACKAGES[nes]="libretro-fceumm-git"
PACKAGES[n64]="libretro-mupen64plus-git"
PACKAGES[snes]="libretro-snes9x-next-git"
PACKAGES[gameBoyAdvanced]="libretro-vba-next-git"
# alias for Game Boy Advanced
PACKAGES[gba]="libretro-vba-next-git"
# Gamecube, wii, and triforce are all coverd with dolphin-emu
PACKAGES[gamecube]="dolphin-emu"
PACKAGES[wii]="dolphin-emu"
PACKAGES[triforce]="dolphin-emu"

## SEGA platforms
# The same packages (genesis-plus-gx) emulates all old SEGA platforms
PACKAGES[genesis]="libretro-genesis-plus-gx-git"
PACKAGES[masterSystem]="libretro-genesis-plus-gx-git"
PACKAGES[gameGear]="libretro-genesis-plus-gx-git"
PACKAGES[megaDrive]="libretro-genesis-plus-gx-git"
PACKAGES[segaCD]="libretro-genesis-plus-gx-git"
# 32x does not get emulated by genesis-plus-gx, so we need picodrive for that
PACKAGES[32x]="libretro-picodrive-git"
PACKAGES[saturn]="libretro-yabause-git"
PACKAGES[dreamcast]="lxdream-hg"

## Sony platforms
PACKAGES[pcsx]="libretro-pcsx-rearmed-git"
# alias for pcsx
PACKAGES[playStation]="libretro-pcsx-rearmed-git"
PACKAGES[pcsx2]="pcsx2"
PACKAGES[pcsx2-latest]="pcsx2-git"
# This is an experimental, early stage pcsx3 emulator
PACKAGES[pcsx3]="rpcs3-git"

declare -a ALLBUILD=(retroarch-latest gameBoyColor nes n64 snes gba gamecube genesis 32x saturn dreamcast pcsx pcsx2 fba)
#declare -a ALLPOSSIBLE=(retroarch-stable retroarch-latest gameBoyColor nes n64 snes gba gamecube genesis 32x saturn dreamcast pcsx pcsx2 pcsx2-latest pcsx3 fba)

function usage {
    echo "Usage: $0 _platform_"
    echo "Where _platform_ is one of: "
    echo "all - Build everything listed below (except retroarch-stable)"
    for platform in ${ALLBUILD[*]}; do
        echo "  $platform - ${PACKAGES[$platform]}"
    done
    echo "-OR- an explicit platform from below:"
    #for platform in ${ALLPOSSIBLE[*]}; do
    for platform in `echo ${!PACKAGES[@]} | sort`; do
        echo "$platform"
    done

}

if [ ! $# -eq 1 ]; then
    usage
    exit
else
    #if [ "$1" == "all" -o ! `echo "${ALLPOSSIBLE[@]}" | grep -c "$1"` -eq 0 ]
    if [ "$1" == "all" -o ! `echo "${!PACKAGES[@]}" | grep -c "$1"` -eq 0 ]
    then
        build="$1"
        echo "Setting build target to be: $build"
    else
        echo "Error: did not recognize target $1"
        usage
        exit
    fi
fi

case $build in
    all)
        for platform in ${ALLBUILD[*]}; do
            echo "yaourt -S --force --noconfirm ${PACKAGES[$platform]}"
            yaourt -S --force --noconfirm "${PACKAGES[$platform]}"
        done ;;
    *)
        echo "target platform: $build"
        echo "Package: ${PACKAGES[$build]}"
        echo "yaourt -S --force --noconfirm ${PACKAGES[$build]}"
        yaourt -S --force --noconfirm "${PACKAGES[$build]}"
        ;;
esac
