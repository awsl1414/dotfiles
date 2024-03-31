#!bin/bash

controlfile="$3.aria2"
rm $3 -rf
echo "removed $3"
rm $controlfile
echo "removed $controlfile"
