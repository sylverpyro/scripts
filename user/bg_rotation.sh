#!/bin/bash
## Rotation interval in seconds
ROTATION_INTERVAL=300
## Rotation Script
ROTATION_SCRIPT="$HOME/bin/rand_bg.sh"

while [ 1 -eq 1 ]; do
#    echo "Rotating Background ... Next rotation in ${ROTATION_INTERVAL} seconds"
    ${ROTATION_SCRIPT}
    sleep ${ROTATION_INTERVAL}
done
