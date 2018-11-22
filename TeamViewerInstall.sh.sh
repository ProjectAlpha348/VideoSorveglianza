#!/bin/sh
clear

sudo wget https://download.teamviewer.com/download/linux/teamviewer-host_armhf.deb -O /home/pi/Desktop/teamviewer-host_armhf.deb
echo
sudo dpkg -i /home/pi/Desktop/teamviewer-host_armhf.deb
echo
clear
sudo apt-get -y update
sudo apt-get -f -y install