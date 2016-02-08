#!/bin/bash
if [ "`whoami`" != "root" ]; then
	echo "Error: Cannot run as non-root user"
	exit 0
else
	# Download the black-hole file
	#echo "Pulling down latest http://winhelp2002.mvps.org/hosts.txt"
	#wget http://winhelp2002.mvps.org/hosts.txt -O /tmp/dns_blackhole.txt
	# Convert the file to UNIX formatting
	## This is now done with tr -d $'\r'
	#fromdos /tmp/dns_blackhole.txt
	# Remove the illeagle lines and ^M character that DNSmasq doesnt need and install the file
	#echo "Reformating hosts file and installing at /etc/dnsmasq.d/dns_blackhole.txt"
	#grep -v '^#\|^$\|localhost' /tmp/dns_blackhole.txt | awk '{if ($2 != "") print "address=/"$2"/127.0.0.1"}' | tr -d $'\r' > /etc/dnsmasq.d/dns_blackhole.txt
	echo "Updating the dns_blackhole /etc/dnsmasq.d/dns_blackhole.txt with the latest http://winhelp2002.mvps.org/hosts.txt"
	wget --quiet http://winhelp2002.mvps.org/hosts.txt -O - | grep -v '^#\|^$\|localhost' | awk '{if ($2 != "") print "address=/"$2"/127.0.0.1"}' | tr -d $'\r' > /etc/dnsmasq.d/dns_blackhole.txt
	# Reload the DNSmasq service
	echo "Restarting dnsmasq to read the file"
	systemctl restart dnsmasq
	# Remove the temp file
	#echo "Removing temp file"
	#rm -v /tmp/dns_blackhole.txt
fi
