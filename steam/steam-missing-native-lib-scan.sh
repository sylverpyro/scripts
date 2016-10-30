#!/bin/bash - 
#===============================================================================
#
#          FILE: steam-missing-native-lib-scan.sh
# 
#         USAGE: ./steam-missing-native-lib-scan.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 10/21/2016 13:06
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

file ~/.local/share/Steam/ubuntu12_32/* | grep ELF | cut -d: -f1 | LD_LIBRARY_PATH=. xargs ldd | grep 'not found' | sort | uniq | while read missing; do
  echo "$missing : $(pkgfile $missing)"
done

if [ "$(pgrep steam)" != "" ]; then
  for i in $(pgrep steam); do sed '/\.local/!d;s/.*  //g' /proc/$i/maps; done | sort | uniq | awk -F'/' '{print $NF}' | while read missing; do 
    echo "$missing : $(pkgfile $missing)"
  done
fi

