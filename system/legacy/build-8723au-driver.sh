#!/bin/bash

## Define some variables and locations
SRC="$HOME/src"
WIFI="8723au"
BT="rtk_btusb"
WIFISRC="$SRC/$WIFI"
BTSRC="$SRC/$BT"
FORCEBUILD="false"
TMPBUILD="`mktemp -d`"
WIFIBUILD="$TMPBUILD/$WIFI"
BTBUILD="$TMPBUILD/$BT"

function usage {
    echo "$0 [force] [mode] [module]"
    echo "Options:"
    echo "       force - Builds and install the module even if they are already detected"
	echo "Modes:"
    echo "       update - Just updates the source code to build from"
	echo "       build  - Builds the modules if they are not detected and installs them"
    echo "       update-build - Updates the source code and builds the modules"
    echo "Modules:"
    echo "       wifi - WiFi module: 8723au"
    echo "       buletooth - Bluetooth module: rtk_btusb"
    echo "       all - Both wifi and bluetooth modules"
}

function notify {
if [ "$ROOTMETHOD" == "gksu" ]; then
	notify-send "$1" -i "$2" -t 3000
else
	echo "$1"
fi
}		

function die {
	# Remove the temp directory
	test -d "$TMPBUILD" && rm -rfv $TMPBUILD
	# Exit now
	exit
}

# run if user hits control-c
control_c()
{
	echo -en "\nCaught Ctrl-c: Exiting now\n"
	die
}
 
# trap keyboard interrupt (control-c)
trap control_c SIGINT

function update-wifi {
    # Make the source directory if none exists
    test -d "$SRC" || mkdir "$SRC"
    
    # Get the wifi driver if it doesn't exist yet, otherwise just update it
    if [ -d "$WIFISRC" ]; then
    	notify "Status: Updating $WIFISRC" emblem-web
    	cd "$WIFISRC"
    	make clean
    	git pull 
    else
    	notify "Status: Doing initial clone for $WIFISRC" emblem-web
    	git clone https://github.com/lwfinger/rtl8723au.git "$WIFISRC"
    fi

}

function build-wifi {
    # First see if we have some headers to work with
    if [ ! -d "/usr/lib/modules/`uname -r`/build" ]; then
    	# Send a notification to the user
    	notify "Error: No kernel headers installed for `uname -r`" emblem-important
    	notify "Error: Cannot build 8732au WiFi or Bluetooth modules" emblem-important
    	die
    fi

    # See if the module needs to be built or we are forcing a build
    if [ $FORCEBUILD == "true" -o `lsmod | grep -c 8723au` -eq 0 ]; then
    	
        # Tell the user we are going to build the wireless driver
    	notify "Status: Rebuilding 8723au Wireless Driver" emblem-generic
    	
        # Clean the module out if it's there
    	$ROOTMETHOD /sbin/rmmod 8723au
    	
        # Clone the source directory to TMP
    	#cp -rfv "$WIFISRC" "$TMPBUILD"
    	rsync -ruav --exclude=".*" "$WIFISRC" "$TMPBUILD"
    	
        # Head to the source directory
    	cd "$WIFIBUILD"
    	
        # Clean out any previous makes
    	make clean
    	
        # make the module
    	make
    	
        # Verify we made the module
    	if [ ! $? -eq 0 ]; then
    		# If not yell and panic
    		notify "Error: 8723au WiFi driver compilation failed!" emblem-important
    	else
    		# Otherwise install the module
    		$ROOTMETHOD /usr/bin/make install
    		$ROOTMETHOD /sbin/modprobe 8723au
    		# And tell the user the driver is ready to use
    		notify "Success: 8723au WiFi driver rebuilt and installed" emblem-default
    	fi

    # If the modules already exists
    else
        # tell the user they are already there
    	notify "Status: 8723au Wifi driver installed properly" emblem-default
    fi
}

function update-bluetooth {
    # Make the source directory if none exists
    test -d "$SRC" || mkdir "$SRC"

    # Get the bluetooth driver if it doesn't exist yet, otherwise just update it
    if [ -d "$BTSRC" ]; then
    	notify "Status: Updating $BTSRC" emblem-web
    	cd "$BTSRC"
    	make clean
    	git pull 
    else
    	notify "Status: Doing inital clone for $BTSRC" emblem-web
    	git clone https://github.com/lwfinger/rtl8723au_bt.git "$BTSRC"
    fi
}


function build-bluetooth {
    # First see if we have some headers to work with
    if [ ! -d "/usr/lib/modules/`uname -r`/build" ]; then
    	# Send a notification to the user
    	notify "Error: No kernel headers installed for `uname -r`" emblem-important
    	notify "Error: Cannot build 8732au WiFi or Bluetooth modules" emblem-important
    	die
    fi

    # See if the module needs to be built or we are forcing a build
    if [ $FORCEBUILD == "true" -o `lsmod | grep -c rtk_btusb` -eq 0 ]; then

    	# Tell the user we are going to build the Bluetooth driver
    	notify "Status: Rebuilding the rtk_btusb Bluetooth Driver" emblem-generic

        # Clean out any existing module
    	$ROOTMETHOD /sbin/rmmod rtk_btusb
    	
        # Clone the bluetooth source directory to TMP
    	#cp -rfv "$BTSRC" "$TMPBUILD"
    	rsync -ruav --exclude=".*" "$BTSRC" "$TMPBUILD"
    	
        # Head the the Bluetooth source directory
    	cd "$BTBUILD"
    	
        # Clean up any residual makes
    	make clean
    	
        # Make the dirver
    	make
    	
        # Check if the build succeeded
    	if [ ! $? -eq 0 ]; then
    		# If not, scream and shout
    		notify "Error: rtk_btusb Bluetooth Driver compilation failed" emblem-important
    	else
    		# Otherwise install the driver
    		$ROOTMETHOD /usr/bin/make install
    		$ROOTMETHOD /sbin/modprobe rtk_btusb
    		# Tell the user the driver is ready for use
    		notify "Success: rtk_btusb Bluetooth driver rebuilt and installed" emblem-default
    	fi 

    # Cleanup the TMPBUILD directory
	rm -rfv "$TMPBUILD"

    # If the modules already exists
    else
        # tell the user they are already there
    	notify "Status: rtk_btusb Bluetooth driver installed properly" emblem-default
    fi
}

# If we don't get any modes, complain and exit
if [ $# -eq 0 ]; then
	usage
    die
fi

# Figure out if we need to run in iteractive sudo mode
if [ ! `tty -s; echo $?` -eq 0 -o "$2" == '-g' ]; then
	ROOTMETHOD="gksu"
else	
	ROOTMETHOD="sudo"
fi

# See if we are force building
if [ "$1" == "force" ]; then 
    FORCEBUILD="true"
    shift
fi

# See what mode we are in
case "$1-$2" in
    'update-all' ) 
        update-wifi
        update-bluetooth ;;
    'update-wifi' ) 
        update-wifi ;;
    'update-bluetooth') 
        update-bluetooth ;;
    'build-all' )
        build-wifi
        build-bluetooth ;;
    'build-wifi' )
        build-wifi ;;
    'build-bluetooth' )
        build-bluetooth ;;
    'update-build-wifi' )
        update-wifi
        build-wifi ;;
    'update-build-bluetooth' )
        update-bluetooth
        build-bluetooth ;;
    'update-build-all' )
        update-wifi
        build-wifi
        update-bluetooth
        build-bluetooth ;;
	* ) echo "Got mode: $1-$2" 
        usage ;;
esac
