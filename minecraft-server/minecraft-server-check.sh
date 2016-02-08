#!/bin/bash
if [ "`sudo /usr/bin/minecraftctl status`" == "minecraft_server.jar is not running." ]; then 
    sudo systemctl restart minecraftd 
    echo "Detected server was not running.  Restart issued."
fi
