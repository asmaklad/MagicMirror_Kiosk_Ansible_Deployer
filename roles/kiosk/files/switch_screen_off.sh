#!/bin/bash

export DISPLAY=:0.0
export XAUTHORITY=/home/pi/.Xauthority

sudo systemctl disable kiosk.service
sudo systemctl stop kiosk.service

xset s blank
xset s off
xset -dpms

xset dpms force off