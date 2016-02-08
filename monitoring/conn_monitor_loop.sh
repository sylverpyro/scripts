#!/bin/bash - 
#===============================================================================
#
#          FILE: conn_monitor_loop.sh
# 
#         USAGE: ./conn_monitor_loop.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: sylverpyro (), sylverpyro@gmail.com
#  ORGANIZATION: 
#       CREATED: 01/12/2016 06:33
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

testing="/home/sylverpyro/bin/test_external_connection.sh"
log_file="/home/sylverpyro/connection_monitor.log"


while [ "true" == "true" ]; do
	# 0mn
	echo "`date` `$testing -ip`" | tee -a "$log_file"
	echo "       `$testing -trace`" | tee -a "$log_file"
	echo "       `$testing -test`" | tee -a "$log_file"
	# 1mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 2mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 3mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 4mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 5mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 6mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 7mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 8mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 9mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 10mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 11mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 12mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 13mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 14mn
	sleep 60
	echo "`date` `$testing -test`" | tee -a "$log_file"
	# 15mn
	sleep 60
done
