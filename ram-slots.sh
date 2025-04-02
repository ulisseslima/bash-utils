#!/bin/bash
# ram slots details

echo 'General'
sudo dmidecode -t 16 | grep -P 'Maximum|Devices'

sudo dmidecode -t memory | grep -P 'Memory Device|Size|Factor|Type|Memory Speed|Locator' | grep -vP 'Bank|Detail'
