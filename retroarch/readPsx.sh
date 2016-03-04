#!/bin/bash

## Location to save the ISO
remotePath="/Volumes/sylver.local/Desktop/psxGames/"
localPath="/Users/sylverpyro/Desktop/"
## Path to cdrdao
cdrdaoPath="/usr/local/bin"

## Make sure cdrdao is present
while [[ ! -x "$cdrdaoPath/cdrdao" ]]
do 
    echo "cdrdao executable not found or unreadable at:"
    echo "$cdrdaoPath"
    echo "EXITING"
    exit 1
done

## Make sure we can write to the suppiled path
path=$remotePath

if [[ ! -w $path ]]
then
path=$localPath
fi

## Ask for the name to use for the ISO 
echo "Filename of disk: "
read filename

## Move to the location and make a folder for the iso and toc
cd $path
mkdir $filename

## Move into the folder
cd $filename

## Unmount the disk from the system for reading
disktool -u disk1

## Read the disk and make the needed files
exec $cdrdaoPath/cdrdao read-cd --read-raw --datafile $filename.bin --device IODVDServices/1 --driver generic-mmc-raw $filename.toc

exit 0
