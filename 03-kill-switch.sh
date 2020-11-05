#!/bin/bash

###############################################################################################################################
## This script is inspired by germeuser's vpn-kill-switch from                                                               ##
## https://github.com/germeuser/vpn-kill-switch                                                                              ##
##                                                                                                                           ##
## This script kills the internet connectivity should the VPN connection, once established, drop.                            ##
## To enable networking again using the terminal, use: $ nmcli networking on                                                 ##
##                                                                                                                           ##
## This script relies on the package 'network-manager' to disable the network. ##
## This script does *not* need root permissions (in common system configurations).                                           ##
##                                                                                                                           ##
## This script was written for and tested on Debian 9 Stretch, but should work on most Debian derivates.                     ##
## As the LICENSE file says, this script is distributed under GPLv3.                                                         ##
##                                                                                                                           ##
##############################################################################################################################

#################################################################
# define runtime parameters
#################################################################
INTERFACE="tun0"            ## default tun0 - the vpn interface that will be monitored.
VPN_EXISTS_CHECK="30"       ## default 30   - the time to wait between scans for an active VPN connection
VPN_DROPPED_CHECK="0.25"    ## default 0.25 - the time to wait for the next check whether the VPN interface still exists
P2P_DAEMON="transmission"   ## default transmission, please note pkill will trim process string, so don't use full process name
ECHO="1"                    ## set to "1" if you want/need terminal output. default is on as I monitor it inside tmux session.

#################################################################
# Step: start killer switch
# the script will run in an infinite loop
#################################################################

while :
do
  # first, the script will check if there's a VPN connection to be monitored.
  if ! [[ $(ip addr | grep $INTERFACE) = "" ]]; then
      # if $INTERFACE exists, there is a VPN connection.
      if [[ $ECHO == "1" ]]; then echo "[$(date +%H:%M:%S)]: VPN found; start monitoring."; fi
      # if a VPN connection was detected, it will be watched using an infinite loop.
      while :
      do
          # let's check if the tunnel (tun0) interface is still there...
          if [[ $(ip addr | grep $INTERFACE) = "" ]]; then
            # Oops! the $INTERFACE interface vanished, quickly kill P2P program and notify the user.
	          # I don't want to kill the network in case my linux machine is running inside cloud vps. If network is totally down then I can't login as well.
            # "nmcli networking off" - do not run network off
	          # Instead of kill network, I kill my p2p immediately.
            # start from normal shutdown
            sudo pkill -SIGTERM $P2P_DAEMON
	          # immediately followed by kill
	          sudo pkill -SIGKILL $P2P_DAEMON
	          # try to stop service as well
	          sudo systemctl stop transmission-daemon
            
            # notify user
            if [[ $ECHO == "1" ]]; then echo "[$(date +%H:%M:%S)]: VPN died; terminate p2p."; fi
            ## As the network connection was killed, we can stop looking if the interface still exists
            break
          fi

          # if $INTERFACE is still there... check again after the time specified in $VPN_DROPPED_CHECK passed.
          if [[ $ECHO == "1" ]]; then echo "[$(date +%H:%M:%S)]: VPN is ok."; fi
          sleep $VPN_DROPPED_CHECK
      done
  fi
  
  # if the script reaches this point, there's no VPN connection at the time.
  # the script will wait the time set in $VPN_EXISTS_CHECK for the next check.
  echo "No VPN Initiated. Wait 30 sec to recheck"
  sleep $VPN_EXISTS_CHECK

done