#!/bin/bash

BACKUPDIR="/srv/minecraft/backup"
MINBACKUPS=24

if [ `ls "$BACKUPDIR" | wc -l` -gt $MINBACKUPS ]; then
    ls -rt "$BACKUPDIR" | head -n -$MINBACKUPS | while read file
        do sudo rm "$BACKUPDIR/$file"
    done
fi
