#!/bin/bash
while read line; do echo "Contents of $line: "; ls "$line"; ans="y"; read -p "Keep $line ? [Y/n]" ans </dev/tty ; if [ "$ans" = "n" ]; then mv -v "$line" "../cut/"; fi; echo ""; done < <(ls -d [aA]*)
