#!/bin/bash - 
#===============================================================================
#
#          FILE: test_external_connection.sh
# 
#         USAGE: ./test_external_connection.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: sylverpyro (), sylverpyro@gmail.com
#  ORGANIZATION: 
#       CREATED: 01/12/2016 06:19
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

function check_ip () {
	echo "Ip address: `wget --timeout=5 -qO- http://ipecho.net/plain`"
}

function trace_route () {
	if [ $# -eq 0 ]; then
		target="8.8.8.8"
	else
		target="$1"
	fi
	#echo "tracepath -m 8 -n '$target'"
	tracepath -m 8 -n "$target"
}

function test_connectivity () {
	if [ $# -eq 0 ]; then 
		target="8.8.8.8"
	else
		target="$1"
	fi
	#ping -n -c 10 8.8.8.8 | tail -n 2 | grep -c ", 0% packet loss, "
	#echo "ping -n -c 10 '$target' | tail -n2"
 	ping -n -c 10 "$target" | tail -n 2
}

function script_usage () {
	echo "Usage: $0 [-ip | -trace <dest> | -test <dest>]"
}
if [ $# -eq 0 ]; then script_usage; exit; fi

case $1 in
	-ip) check_ip ;;
	-trace) trace_route ;;
	-test)  test_connectivity ;;
	*) script_usage ;;
esac
