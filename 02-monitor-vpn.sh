#!/bin/bash

#################################################################
# define runtime parameters
#################################################################
# vpn working directory
vpn_dir="$HOME/openvpn"

#################################################################
# Step 1: start vpn monitor
#################################################################

cd $vpn_dir
tmux has-session -t 'monitor'
if [ $? -eq 1 ]; then
  echo -n "Starting vpn monitor... "
  tmux new-session -d -s monitor -n kill-switch 'sudo ./03-kill-switch.sh'
  tmux new-window -d -t monitor -n logging 'sudo journalctl -u transmission-daemon -f'
  echo "[DONE]"
else
    echo "monitor already running."
fi
