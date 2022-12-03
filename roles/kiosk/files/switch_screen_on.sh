#!/bin/bash

export DISPLAY=:0.0
export XAUTHORITY=/home/pi/.Xauthority

xset s noblank
xset s off
xset -dpms

xset dpms force on

sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service
