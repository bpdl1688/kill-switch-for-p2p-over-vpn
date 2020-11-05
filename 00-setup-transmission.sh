#!/bin/bash

# This is a helper script to setup the transmission-daemon and required tools for a sample p2p host (VM or baremetal)
#   VPN: openvpn
#   P2P: transmission-daemon
#   other tools: tmux 
#   OS: Ubuntu 1804

#################################################################
# define runtime parameters
#################################################################
# The url for transmission block list
blocklist="http:\/\/john.bitsurge.net\/public\/biglist.p2p.gz"

# the location for transmission config
trans_conf="/etc/transmission-daemon/settings.json"

#################################################################
# config system
#################################################################

# Allow members of group sudo to execute any command
sudo sed -i.bak "s/.*\%sudo	ALL=(ALL:ALL).*/\%sudo	ALL=(ALL:ALL) NOPASSWD:ALL/g" /etc/sudoers

sudo hostnamectl set-hostname go-transmission
sudo timedatectl set-timezone Asia/Singapore
sudo apt-get update sudo && apt-get upgrade -y 
sudo apt-get autoremove -y

sudo apt install transmission-daemon tmux vim
sudo systemctl stop transmission-daemon
sudo systemctl disable transmission-daemon

# set alias
echo "alias tsm='transmission-remote'" >> ~/.bashrc
sudo sed -i.bak "s/.*\"blocklist-url\".*/    \"blocklist-url\": \"$blocklist\",/g" $trans_conf
sudo sed "s/.*\"rpc-whitelist-enabled\".*/    \"rpc-whitelist-enabled\": false,/g" $trans_conf

# load transmission ip filter
sudo systemctl start transmission-daemon
transmission-remote -n transmission:transmission --blocklist-update

# Tune kernel:
#   - add network transmission buffer
#   - disable ipv6
sudo tee -a /etc/sysctl.conf > /dev/null << EOF
# Setup Network Transmisison Buffer
net.core.rmem_max=4194304 >> /etc/sysctl.conf
net.core.wmem_max=1048576

# disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
EOF

# Reboot
sudo reboot
