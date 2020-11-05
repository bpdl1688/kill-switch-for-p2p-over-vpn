# Kill Switch for P2P over VPN

## Why this?

VPN is a convenient way to work remotely. However, VPN might not be very reliable, it might break in the middle of your task. When it is broken, your traffic will be redirected to Internet (and reveal your IP) which you might have a concern.

Therefore, kill switch is a mechanism to protect you from traffic re-direction. Many VPN vendors provide Kill Switch function, but many of them ignore Linux platform. This is really insane and unacceptable!

However, Linux is a platform for freedom, why not build your own VPN kill switch? I started to Google-search and was inspired by germeuser's vpn-kill-switch. So I decide to extend and test the function on my p2p host, and .... this is my design (oops, sounds like Will Graham).

## Reference Setup

This script is developed under the following env setup

- VPN: 
  - openvpn 
  - Alternatively, you can use other CLI-based VPN. Here I use Cyberghost VPN CLI for Ubuntu 1804
- P2P: Transmission-daemon
- Other tools: tmux
- OS: Ubuntu 1804 LTS

Up to now, I only test Ubuntu 1804, but it should be easy to post it to other Linux distros.
