oIFS=$IFS; 
IFS=$'\n'; 

for line in `find ./ -maxdepth 1 -type d`
do
	ITEM=${line}
	SUB_FOLDERS=`find "${line}" -type d | wc -l`
#	MP3S=`find "${line}" -type f | grep -i -c \.mp3`
#	NON_MP3S=`find "${line}" -type f | grep -v \.mp3 | grep -v \.m4a | wc -l`
	ITEM_COUNT=`find "${line}" -type f | grep -i -c \.mp3`

	if [ ${ITEM_COUNT} -lt 1 ]; then
#		echo ""
#		echo "-----------------------------"
#		echo "Empty folder: "${line}""
#		echo "With count : ${ITEM_COUNT}"
#		echo "Contents :"
#		ls -R "${line}"
#		echo "-----------------------------"
#		echo ""
		echo "${line}"
	fi
done
#	echo -e "Item=${ITEM} SUBFOLDERS=${SUB_FOLDERS} MP3S=${MP3S} NONMP3S=${NON_MP3S}"


#	for file in `find ./ -type f | grep -v \.jpg | grep -v \.pdf | grep -v \.txt | grep -v -i \.mp3 | grep -v \.avi | grep -v \.gif | grep -v \.jpeg | grep -v -i \.mpg | grep -v -i \.png | grep -v \.rar | grep -v \.zip | grep -v \.rtf | grep -v \.nfo | grep -v \.m3u`
#	do

#		BASE=${file%\.*}

		#Echo out all extensions found
		#echo "${BASE}"

		#if [ -f "${file}" -a ! -f "${BASE}.mp3" ]; then
		#	# Convert anything not already an mp3 to an mp3
		#	/home/sylverpyro/bin/transcode_to_mp3.sh "${file}"
		#fi

		# Check if an mp3 of the file exists (if not already an mp3)
#		if [ -f "${BASE}.mp3" ]; then
#			ls "${file}"
#		fi
#	done

IFS=$oIFS
