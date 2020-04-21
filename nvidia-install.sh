#!/bin/bash
# NOTA: a forma mais fácil de instalar é pelo additional drivers (que pode estar um pouco atrasado)
# a outra forma é ir pro terminal com ctrl alt f3
# systemctl isolate multi-user.target
# modprobe -r nvidia-drm
# sudo /home/Downliads/NVIDIA*
# depois da instalação:
# systemctl start graphical.target
# NOTA: nunca instalei dessa forma

if [ ! -n "$1" ]; then
	echo "first arg must be the driver version"
	echo "check on https://www.nvidia.com/object/unix.html"
	exit 1
fi

sudo apt update && sudo apt -y upgrade
sudo apt install nvidia-$1
