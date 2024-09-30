#!bin/bash

controlfile="$3.aria2"
rm $controlfile
echo "[$(date -Iseconds)] removed $controlfile" >> ~/.aria2/log-after-complete.log
