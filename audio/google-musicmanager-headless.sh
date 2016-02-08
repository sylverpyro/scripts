#!/bin/bash
# Save as: $HOME/gmm-headless-script.sh
 
export DISPLAY=:2
Xvfb :2 -screen 0 1024x768x16 &
#google-musicmanager -a GMAILUSER -p PASSWORD -s /path/to/music -m SERVERNAME &
google-musicmanager 
x11vnc -display :2 -bg -nopw -listen localhost -xkb
 
# remember to chmod +x this file = make excutable.
# run in terminal: chmod +x $HOME/gmm-headless-script.sh
