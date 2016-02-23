#!/bin/bash - 
#===============================================================================
#
#          FILE: incomplete_check.sh
# 
#         USAGE: ./incomplete_check.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: sylverpyro (), sylverpyro@gmail.com
#  ORGANIZATION: 
#       CREATED: 02/19/2016 18:38
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

unzip -l "$1"

