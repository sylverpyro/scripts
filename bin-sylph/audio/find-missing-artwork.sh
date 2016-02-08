#!/bin/bash
while read line; do if [ `id3v2 -l "$line" | grep -c APIC` -eq 0 ]; then echo "`dirname "$line"` missing artwork"; fi ; done < <(find ./ -type f)
