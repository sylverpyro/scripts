#!/bin/bash
BINARGS="--daemon --detach --dbus disabled --pid-file /var/run/xboxdrv.pid"
CTRLARGS="--deadzone 25% --trigger-as-button"

function usage {
	echo "Usage: $0 [1|2|3|4|stop]"
}

function check_running {
	ps -ef | grep 'xboxdrv --daemon' | grep -v grep | wc -l
}
	
if [ ! `lsmod | grep -c xpad` -eq 0 ]; then
	sudo rmmod xpad
fi

if [ $# -eq 0 ]; then
	if [ `check_running` -eq 0 ]; then
		sudo xboxdrv $BINARGS $CTRLARGS
	else
		echo "Error: xbox driver already running. Run $0 stop first"
	fi
elif [ "$1" = "stop" ]; then
	sudo killall xboxdrv 
else
	case $1 in
		1) sudo xboxdrv $BINARGS $CTRLARGS & ;;
		2) sudo xboxdrv $BINARGS $CTRLARGS --next-controller $CTRLARGS & ;;
		3) sudo xboxdrv $BINARGS $CTRLARGS --next-controller $CTRLARGS --next-controller $CTRLARGS & ;;
		4) sudo xboxdrv $BINARGS $CTRLARGS --next-controller $CTRLARGS --next-controller $CTRLARGS --next-controller $CTRLARGS & ;;
		*) usage ;;
	esac
fi
