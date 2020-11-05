#!/bin/bash

#################################################################
# define runtime parameters
#################################################################
# the location for transmission config
trans_conf="/etc/transmission-daemon/settings.json"

# vpn working directory 
vpn_dir="~/openvpn"


# vpn command line
# which country you want to connect
country_code="HK"    ## for Cyberhost example

# To avoid vpn login, please include your username & password in openvpn conf in case of openvpn
# vpn_cmd = "sudo openvpn --config ./openvpn.ovpn"
vpn_cmd="sudo cyberghostvpn --torrent --country-code $country_code --connect"
echo "$vpn_cmd" is vpn command

#################################################################
# Step 1: setup vpn
#################################################################

cd $vpn_dir
# tmux new-session -d -s vpn -n vpn 'sudo openvpn --config ./openvpn.ovpn'
tmux new-session -d -s vpn -n vpn $vpn_cmd
echo show if tun0 has been built, please wait up to 60 secs

ps -ef | egrep "tmux .*vpn" | grep -v grep
if [[ $? = "0" ]]
then
  echo wait for tunnel
  i="0"
  while [ $i -lt 60 ]
  do
  	echo i =  $i
  	# find the tun0 vip
  	vpn_ip=$(ip a | egrep "inet.*tun0" | awk '{ print $2 }' | awk -F/ '{ print $1 }')
  	echo show VPN IP = $vpn_ip
  	if ! [[ $vpn_ip = "" ]]
  	then
  		sudo systemctl stop transmission-daemon
  		sudo sed -i.bak "s/.*bind-address-ipv4.*/    \"bind-address-ipv4\": \"$vpn_ip\",/g" $trans_conf
		  echo Now the bind ip is:
		  sudo grep bind-address-ipv4 $trans_conf
		  break
	  else
		  echo please wait
		  sleep 5
		  i=$(( $i + 5 ))
	  fi
  done

  # recheck the tun0 vip
  vpn_ip=$(ip a | egrep "inet.*tun0" | awk '{ print $2 }' | awk -F/ '{ print $1 }')

  if [[ $vpn_ip = "" ]]
  then
	  echo time-out, fail to get vpn!
	  exit 1
  fi

else
  echo ovpn is not working
  exit 2
fi

#################################################################
# Step 2: start vpn monitoring
#################################################################
echo now fork tmux for monitoring VPN
./02-monitor-vpn.sh

#################################################################
# Step 3: start p2p
#################################################################
echo Now you are ready to launch transmission-daemon
sudo systemctl restart transmission-daemon
sudo systemctl status -l transmission-daemon

