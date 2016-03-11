#!/bin/bash - 
#===============================================================================
#
#          FILE: darknet-array-control.sh
# 
#         USAGE: ./darknet-array-control.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: sylverpyro (), sylverpyro@gmail.com
#  ORGANIZATION: 
#       CREATED: 02/17/2016 19:49
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#set -e # Exit immediately on errors

if [ $# -eq 0 ]; then 
	echo "Usage: $0 [-a|--activate|-d|--deactivate]"
elif [ "$1" == "-d" -o "$1" == "--deactivate" ]; then
  # Shut down smbd so it stops using the array
  sudo systemctl stop smbd || { echo "Error: could not stop smbd service"; exit 1; }

  # Unmount the disk
  mount_point="/darknet"
  sudo umount -l "$mount_point" || { echo "Error: could not unmount $mount_point"; exit 1; }

  # Deactivate the logical volume
#  lv_path="/dev/darkray/darknet"
#  sudo lvchange --activate n "$lv_path" || exit "Error: could not deactivate the lv: $lv_path"

  # Deactivate the volume group
  # This will deactivate all of the LVs in the group automatically
  vg="darkray"
  sudo vgchange --activate n "$vg" || { echo "Error: could not deactivate the vg: $vg"; exit 1; }

  # Stop the array
  array="/dev/md/darknet"
  sudo mdadm --stop "$array" || { echo "Error: could not stop array: $array"; exit 1; }

  # Print the all-clear to remove the device
  echo "The $array should be safe to remove now"

elif [ "$1" == "-a" -o "$1" == "--activate" ]; then
  echo "Not implemented yet"
  echo "In the meantime, sudo eject /dev/sd[cd] will cause the disk to re-add instantly and get picked back up"
else
	echo "Usage: $0 [-a|--activate|-d|--deactivate]"
fi
