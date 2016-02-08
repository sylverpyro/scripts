#!/bin/bash
help_msg () {
	echo "Usage: $0 [all|mirrors|pacman|aur]"
	echo "With no arguments, 'aur' is assumed"
}

update_mirrors () {
#	sudo reflector --verbose --country 'United States' -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
	## NOTES: blacklisted mirror.ancl.hawaii.edu for not responding properly 20131019
	sudo /usr/bin/reflector --verbose --country 'United States' -l 200 -n 10 -p http --sort rate --cache-timeout 1 -x mirror.ancl.hawaii.edu -x mirrors.advancedhosters.com --save /etc/pacman.d/mirrorlist
}

update_pacman () {
	sudo pacman -Syyu
}

update_aur () {
	yaourt -Syyau --noconfirm
}

clean () {
	sudo pacman -Sc --noconfirm
	sudo pacman -Rs --noconfirm $(pacman -Qtdq)
	yaourt -Sc --noconfirm
	yaourt -Rs --noconfirm $(yaourt -Qtdq)
}

if [ $# -eq 0 ]; then
	MODE='aur'
else
	MODE="$1"
fi

case $MODE in
	help|-h|--help) help_msg; exit;;
	mirrors) update_mirrors ;;
	pacman) update_mirrors; update_pacman; clean ;;
	aur) update_mirrors; update_aur; clean;;
	clean|cleanup) clean ;;
	all) update_mirrors; update_pacman; update_aur; clean;;
	*) echo "Error: so such mode"; help_msg;;
esac	
