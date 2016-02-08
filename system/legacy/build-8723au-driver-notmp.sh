#!/bin/bash
SRC="/home/sylverpyro/src"
WIFISRC="$SRC/8723au"
BTSRC="$SRC/rtk_btusb"
FORCEBUILD="false"

# Figure out if we need to run in iteractive sudo mode
if [ -z $PS1 ]; then
	ROOTMETHOD="gksu"
elif [ $# -gt 1 -a $2 == '-g' ]; then
	ROOTMETHOD="gksu"
else	
	ROOTMETHOD="sudo"
fi

function update {
	if [ ! -d "$SRC" ]; then
		echo "making source directory $SRC"
		mkdir "$SRC"
	fi
	if [ ! -d "$WIFISRC" ]; then
		echo "Doing initial pull of the Wifi Driver to $WIFISRC"
		git clone https://github.com/lwfinger/rtl8723au.git "$WIFISRC"
	else
		cd "$BTSRC" 
		echo "Cleaning out the old builds (so they don't conflict with the new pull)"
		make clean
		echo "Updating Wifi Driver src from git"
		git pull
	fi
	if [ ! -d "$BTSRC" ]; then
		echo "Doing initial pull of the Bluetooth Driver to $BTSRC"
		git clone https://github.com/lwfinger/rtl8723au_bt.git "$BTSRC"
	else
		cd "$BTSRC"
		echo "Cleaning out the old builds (so they don't conflict with the new pull)"
		make clean
		echo "Updating Wifi Driver src from git"
		git pull
	fi
}

function build {
	# First see if we have some headers to work with
	if [ ! -d "/usr/lib/modules/`uname -r`/build" ]; then
		notify-send "Error: No kernel headers installed for `uname -r`" "Cannot build 8723au WiFi or BlueTooth Modules" -i error -t 10000
		exit
	fi
	# First see if we have a source directory
	if [ ! -d "$WIFISRC" ]; then
		# If not, do a pull now (hopefully we are online)
		update
	fi
	# See if the module needs to be built or we are forcing a build
	if [ $FORCEBUILD == "true" -o `lsmod | grep -c 8723au` -eq 0 ]; then
		# Tell the user we are going to build the wireless driver
		notify-send "Rebuilding 8723au Wireless Driver" -i nm-device-wireless -t 2000
		#xmessage -center -timeout 5 "Rebuilding kernel driver for wireless now - you should be online shortly" &
		# Clean the module out if it's there
		$ROOTMETHOD /sbin/rmmod 8723au
		# Head to the source directory
		cd "$WIFISRC"
		# Clean out any previous makes
		make clean
		# make the module
		make
		# Verify we made the module
		if [ ! $? -eq 0 ]; then
			# If not yell and panic
			notify-send "ERROR!!!! 8723au Driver compilation failed!" -u critical -i error
		else
			# Otherwise install the module
			$ROOTMETHOD /usr/bin/make install
			$ROOTMETHOD /sbin/modprobe 8723au
			# And tell the user the driver is ready to use
			notify-send "8723au Wireless Driver rebuilt and installed" -i nm-device-wireless -t 2000
			#xmessage -center -timeout 5 "Wirless dirver has been rebuilt and installed.  Building the Bluetooth driver now" &
		fi
		# Tell the user we are going to build the Bluetooth driver
		notify-send "Rebuilding the 8723au Bluetooth Driver" -i nm-device-wireless -t 2000
		# Clean out any existing module
		$ROOTMETHOD /sbin/rmmod rtk_btusb
		# Head the the Bluetooth source directory
		cd "$BTSRC"
		# Clean up any residual makes
		make clean
		# Make the dirver
		make
		# Check if the build succeeded
		if [ ! $? -eq 0 ]; then
			# If not, scream and shout
			notify-send "ERROR!!! 8723au Bluetooth Driver compilation failed!" -i error -u critical
		else
			# Otherwise install the driver
			$ROOTMETHOD /usr/bin/make install
			$ROOTMETHOD /sbin/modprobe rtk_btusb
			# Tell the user the driver is ready for use
			notify-send "Complete" "8723au Bluetooth Driver rebuilt and installed" -i nm-device-wireless -t 2000
			#xmessage -center -timeout 5 "Bluetooth driver has been rebuilt and installed." &
		fi 
	#else
	#	notify-send "8723au Wifi and Bluetooth drivers already installed" -i nm-device-wireless -t 2000
	fi
}

function usage {
	echo "$0 mode [option]"
	echo "Modes: update - Just updates the source code to build from"
	echo "       build  - Builds the modules if they are not detected and installs them"
	echo "       force  - Builds and installs the modules even if the are detected"
	echo "Options: -g : Graphical mode - request sudo access via gksu"
}

if [ $# -eq 0 ]; then
	usage
	exit
fi

case $1 in 
	'update') update ;;
	'build') build ;;
	'force')
		FORCEBUILD="true"
		build
	;;
	*) usage ;;
esac
