#!/bin/bash

WHITELIST="/etc/hostsblock/white.list"
BLACKLIST="/etc/hosts.block"
MODE="Unset"
DOMAIN=".invalid"


help () {
    echo "Usage: $0 -w DOMAIN  -- OR -- $0 -d DOMAIN"
    echo " -w : Add domain, as specified to $WHILTELIST"
    echo "       See man hostsblock.conf for the necessary format"
    echo "       If necessary, add ' .dl.dropbox.com' to include a space"
    echo '       In this file, put a space in front of
       a string in order to let through that specific site (without quotations), e.g.
       " www.example.com" will unblock "http://www.example.com" but not
       "http://subdomain.example.com". Leave no space in front of the entry to
       "unblock all subdomains that contain that string, e.g. ".dropbox.com" will let
       through "www.dropbox.com", "dl.www.dropbox.com", "foo.dropbox.com",
       "bar.dropbox.com", etc.
       whitelist="/etc/hostsblock/white.list"'
    echo ""
    echo " -d : Removed domain, from the block list and restart dnsmasq"
    echo "       NOTE: If you do not also -w DOMAIN sepeartely, it will"
    echo "       be blocked again next time hostsblock runs"
}

if [ "$1" == "--help" -o "$1" == "-h" ]; then
    help; exit
elif [ ! $# -eq 2 ]; then
    help; exit
elif [ "$2" == "" ]; then
    help; exit;
else
    DOMAIN="$2"
fi   

case $1 in
    -w) if [ `grep -x -c -F "$DOMAIN" "$WHITELIST"` -eq 0 ]; then
            echo "$DOMAIN" | sudo tee -a "$WHITELIST" >/dev/null
            echo "Next time hostsblock updates, it will whitelist $DOMAIN"
        else
            echo "Error: $DOMAIN appears to already exist in $WHITELIST"
            grep -x -F "$DOMAIN" "$WHITELIST"
        fi
    ;;
    -d) if [ ! `grep -x -c -F "127.0.0.1 $DOMAIN" "$BLACKLIST"` -eq 1 ]; then
            echo "Could not find entry '127.0.0.1 $DOMAIN in $BLACKLIST"
            echo "This is the results of a grep -i -F $DOMAIN $BLACKLIST"
            grep -i -F "$DOMAIN" "$BLACKLIST"
        elif [ `grep -x -c "127.0.0.1 $DOMAIN" "$BLACKLIST"` -eq 1 ]; then
            echo "Removing entry '127.0.0.1 $DOMAIN' from $BLACKLIST"
            sudo sed -i "/^127.0.0.1 ${DOMAIN}$/d" "$BLACKLIST"
            echo "Domain removed from $BLACKLIST"
            echo "Restarting DNS resolver"
            sudo systemctl restart dnsmasq 
        else
            echo "Error: Unexpexted state -- please debug script"
            echo "Inputs were: $@"
            exit
        fi 
    ;;
    *) echo "Error: $1 is not a recognized flag"; help; exit;;
esac
