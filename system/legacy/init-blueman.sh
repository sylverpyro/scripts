#!/bin/bash
## Start the applet and wait
blueman-applet &
sleep 3
# Reload the bluetooth module
gksu /sbin/rmmod rtk_btusb 
gksu /sbin/modprobe rtk_btusb
