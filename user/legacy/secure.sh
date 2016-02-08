#!/bin/bash

SECURE_FOLDER="/home/sylverpyro/documents/pass"

for file in $(/usr/bin/find $SECURE_FOLDER -type f | /bin/grep -v '\.gpg')
do 
	if [ -e "$file.gpg" ] 
	then
		/usr/bin/shred -u $file
	fi
done
