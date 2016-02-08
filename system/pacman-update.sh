#!/bin/bash
help_msg () {
	echo "Usage: $0 [all|mirrors|keys|pacman|aur|cleanup]"
	echo "With no arguments, we will run a normal update of the mirrors, keys, and aur"
    echo "Modes will NOT auto cleanup after themselves -- that must be run manually"
    echo "'pacman' and 'aur' imply 'mirrors' and 'keys'"
}

update_mirrors () {
#	sudo reflector --verbose --country 'United States' -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
	## NOTES: blacklisted mirror.ancl.hawaii.edu for not responding properly 20131019
	sudo /usr/bin/reflector --verbose --country 'United States' -l 200 -n 10 -p http --sort rate --cache-timeout 1 -x mirror.ancl.hawaii.edu -x mirrors.advancedhosters.com --save /etc/pacman.d/mirrorlist
}
update_keys () {
    sudo pacman-key --refresh-keys
}

update_pacman () {
	sudo pacman -Syyu
}

update_aur () {
	yaourt -Syyau --noconfirm
	if [ $? -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

cleanup () {
	sudo pacman -Sc --noconfirm
	sudo pacman -Rs --noconfirm $(pacman -Qtdq)
	yaourt -Sc --noconfirm
	yaourt -Rs --noconfirm $(yaourt -Qtdq)
}

orphan-detect () {
    tmp=${TMPDIR-/tmp}/pacman-disowned-$UID-$$
    db=$tmp/db
    fs=$tmp/fs

    mkdir "$tmp"
    trap 'rm -rf "$tmp"' EXIT

    pacman -Qlq | sort -u > "$db"

    find /etc /opt /usr ! -name lost+found \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

    comm -23 "$fs" "$db"
}

if [ $# -eq 0 ]; then
	MODE='default'
else
	MODE="$1"
fi

case $MODE in
	help|-h|--help) help_msg; exit;;
	mirrors) update_mirrors ;;
    keys) update_keys ;;
	pacman) update_mirrors; update_keys; update_pacman;;
	aur) update_mirrors; update_keys; update_aur;;
    default)
        echo "Updating public mirror list"
        update_mirrors
        #echo "Updating pacman keyring"
        #update_keys
        echo "Running AUR update"
        update_aur 
		if [ $? -eq 0 ]; then
			echo "Detected upgrade ran successfully.  Cleaning up"
			cleanup
		else
			echo "Detected upgrade encountered errors.  Skipping cleanup"
		fi
        ;;
	cleanup) cleanup;;
    orphan-detect|orphan) orphan-detect;;
	#all) /home/sylverpyro/bin/build-8723au-driver.sh update all; update_mirrors; update_pacman; update_aur; cleanup;;
	all) 
        echo "Updating public mirror list"
        update_mirrors
        echo "Updating pacman keyring"
        update_keys
        echo "Runing pacman update" 
        update_pacman
        echo "Running AUR update"
        update_aur 
        #echo "Cleaning up after ourselves"
        #cleanup
        echo "Remember to cleanup after verifying all processes ran correctly"
        ;;
	*) echo "Error: so such mode"; help_msg;;
esac	
