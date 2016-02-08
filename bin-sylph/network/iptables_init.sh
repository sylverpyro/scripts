#! /bin/sh
### BEGIN INIT INFO
# Provides:          iptables
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Iptables init script
# Description:       Script to stop and start the system filewall
### END INIT INFO

# Author: sylverpyro <sylverpyro@gmail.com>

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="iptables"
NAME=iptables
SCRIPTNAME=/etc/init.d/$NAME


# Exit if the package is not installed
CONFIG="/etc/iptables/iptables.conf"
#[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started

	# Check if the executable exists
	[ -x "/sbin/iptables-restore" ] || exit 0

        echo -n "Starting firewall: "

        /sbin/iptables-restore < ${CONFIG}

        if [ $? -eq 0 ]; then
                echo "[  OK  ]"
		return 0
        else
                echo "[FAILED]"
		return 1
        fi
#	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null || return 1
#	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_ARGS || return 2
}

#
# Function that stops the daemon/service
#
do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred

        # Check if the executable exists
        [ -x "/sbin/iptables" ] || exit 0

        echo -n "Stopping firewall: "

        /sbin/iptables -F

        if [ $? -eq 0 ]; then
                echo "[  OK  ]"
		return 0
        else
                echo "[FAILED]"
		return 1
        fi

	#start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
	#RETVAL="$?"
	#[ "$RETVAL" = 2 ] && return 2
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
#       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
        /sbin/iptables -L -v -n
       ;;
  restart|force-reload)
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
	  	# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
