#!/bin/bash
if [ -z $PS1 ]; then
        ROOTMETHOD="gksu"
else    
        ROOTMETHOD="sudo"
fi

function usage {
	echo "$0 [pair|start|stop]"
}

function pair {
	blueman-applet &
	sleep 1
	$ROOTMETHOD /sbin/rmmod rtk_btusb 
	$ROOTMETHOD sudo /sbin/modprobe rtk_btusb
	$ROOTMETHOD systemctl start sixad
	/usr/bin/qtsixa &
}

function start {
	blueman-applet &
	sleep 1
	$ROOTMETHOD /sbin/rmmod rtk_btusb 
	$ROOTMETHOD sudo /sbin/modprobe rtk_btusb
	$ROOTMETHOD systemctl start sixad
}

function stop {
	$ROOTMETHOD systemctl stop sixad
}

if [ $# -eq 0 ]; then
	usage
	exit
fi

case $1 in
	start) start;;
	stop) stop;;
	pair) pair;;
	*) usage;;
esac
