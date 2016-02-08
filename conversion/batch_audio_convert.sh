#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Specify dry run (-n) or active run (-r)"
elif [ "$1" == "-r" ]; then
	RUN="run"
else
	RUN="dryrun"
fi

# Loop 1 -- Examine all files, and see if each file basename has a corresponding wav file (for full conversion compatablity)
file=""
filename=""
while read file; do 
    # Strip out any folder path pre-pend
	file="$(basename "$file")"
    # strip off the file extention
	filename="${file%.*}"
    # Check if the file name exists with the '.wav' extension.  If it doesn't, make it
	if [ -f "${filename}.wav" ] 
		then echo "${filename}.wav exists, skipping"
	elif [ "$RUN" == "run" ]; then 
		echo "Attempting to create ${filename}.wav from ${file}"
		ffmpeg -strict -2 -i "${file}" "${filename}.wav"
	else
		echo "DryRun: file = $file"
		echo "DryRUn: filename = $filename"
		echo "Would have created ${filename}.wav from ${file}"
	fi
done < <(find ./ -maxdepth 1 -mindepth 1 -type f ! -name \*.wav | sort | uniq)

# Empty out the file variable for safety
file=""
filename=""
wavfile=""
# Loop 2 -- with all the .wav files, make the supplemental files we want/need
while read file; do 
    # Strip out any folder path pre-pend
    wavfile="$(basename "$file")"
    # Strip out the file extension 
    filename="${file%.*}"
	# For each extenson we want
    #for ext in m4a mp3; do ## m4a is broekn in ffmpeg right now
    for ext in mp3; do 
		# Check if the name exists
    	if [ -f "${filename}.${ext}" ]; 
			then echo "${filename}.${ext} exists, skipping"
		# If it does not, make it from the wav file
		elif [ "$RUN" == "run" ]; then
			echo "Attempting to create ${filename}.${ext} from ${wavfile}"
			ffmpeg -strict -2 -i "${wavfile}" "${filename}.${ext}"
		else
			echo "DryRun: wavfile = $wavfile"
			echo "DryRun: filename = $filename"
			echo "Would have created ${filename}.${ext} from ${wavfile}"
		fi
    done
# Only read in WAV files
done < <(find ./ -maxdepth 1 -mindepth 1 -type f -name \*.wav | sort | uniq)
