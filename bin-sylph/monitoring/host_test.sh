#!/bin/bash
HOST=10.20.3.1
echo "Will monitor $HOST"
STARTDAY=`date +%Y%m%d`
echo "Starting on $STARTDAY"
CURRENTDAY=$STARTDAY
RUNDAYS=7
ENDDAY=`date +%Y%m%d -d "$STARTDAY +$RUNDAYS days"`
echo "Ending on $ENDDAY"
INTERVAL=10
echo "Every $INTERVAL seconds"
PINGCOUNT=3
PINGINTERVAL=.2
echo "With $PINGCOUNT pings at $PINGINTERVAL second intervals"
# Set the log file
LOG=/home/sylverpyro/$HOST-up-$CURRENTDAY.log
echo "Record the results in $LOG"
touch "$LOG"
# Set the e-mail recipients
EMAIL=mike.s.benson@gmail.com
echo "Send e-mail alerts to $EMAIL"

# Loop until we reach the end date
while [ "`date +%Y%m%d`" -lt "$ENDDAY" ]; do
	# Check if we have changed to a new date
	if [ "`date +%Y%m%d`" -gt "$CURRENTDAY" ]; then 
		# If we have, set the new current date
		CURRENTDAY=`date +%Y%m%d`
		echo "Detected date rollover to $CURRENTDAY"
		# Look and see if we have any "Down" notes in yesterday's log
		if [ ! `grep -c -E "^(Down|Recovered)" $LOG` -eq 0 ]; then
			# If we do, summerize them and e-mail them
			echo "Email the following:"
			grep -E "^(Down|Recovered)" $LOG | mail -s "Outage summery for $HOST on $CURRENTDAY" "$EMAIL"
		fi
		# Rotate the log file
		LOG=/home/sylverpyro/$HOST-up-$CURRENTDAY.log
		echo "Log file rotated to $LOG"
		touch "$LOG"
	fi
	# Now check if the host is online
	if [ ! `ping -c $PINGCOUNT -i $PINGINTERVAL "$HOST" | awk '/---/,0' | grep -c "$PINGCOUNT received"` -eq 1 ]; then 
		# If it's not, log the date and that it's down
		echo "Down -- `date`" >> $LOG
	# If the host is not offline, it's online
	else 
		# Check if the last log line we wrote was that the host was down
		if [ `tail -n 1 $LOG | grep -c ^Down` -eq 1 ]; then
			# If so, the host just recovered from being down, so send an e-mail that we flapped
			echo "Sending e-mail alert"
			echo "$HOST just recovered from an outage" | mail -s "RECOVERY - $HOST just recovered form an outage" "$EMAIL"
			# Log that the host recovered
			echo "Recovered -- `date`" >> $LOG
		fi
		# Log the date and that it's Up
		echo "Up -- `date`" >> $LOG
	fi
	# Sleep for the specified interval and do it all again
	sleep "$INTERVAL"
done
