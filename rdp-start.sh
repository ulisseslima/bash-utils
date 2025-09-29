#!/bin/bash

#sudo apt update && sudo apt install xrdp -y
sudo service xrdp start
sudo ufw allow 3389
sudo ufw status
