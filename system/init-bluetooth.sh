#!/bin/bash
HCI0=`rfkill list | grep "hci0: Bluetooth" | awk -F: '{print $1}'`
sudo rfkill unblock $HCI0
sudo hciconfig hci0 up
