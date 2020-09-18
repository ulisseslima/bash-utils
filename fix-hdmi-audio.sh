#!/bin/bash
# https://askubuntu.com/questions/1230002/hdmi-sound-not-working-after-upgrading-to-20-04

sudo killall pulseaudio; sudo rm -rf ~/.config/pulse/* ; sudo rm -rf ~/.pulse*
