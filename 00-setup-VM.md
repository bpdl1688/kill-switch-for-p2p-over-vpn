# Notes for setup VM

## Vagrantfile

This is the sample vagrantfile which I used to build the download host

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu1804"
  config.vm.hostname = "go-transmission"

  # Provider-specific configuration so you can fine-tune.
  # To copy the setup script 00-setup-transmission.sh into VM
  config.vm.synced_folder './', '/vagrant', type: 'rsync'

  config.vm.provider :libvirt do |domain|
    domain.default_prefix = "go-transmission"
    # Define the VM size. 2G/2vCPU is more than enough already.
    domain.memory = 4096
    domain.cpus = 4
    domain.cputopology :sockets => '1', :cores => '2', :threads => '2'
    domain.nested = false
    # This will overwrite box's disk definition if it's bigger than the box definition
    # Generic VM is default 120G
    # domain.machine_virtual_size = 240
  end

end
```

## VM setup and run

- Launch VM

```sh
$ vagrant up
$ vagrant ssh
```

- Prepare VPN

This part is skipped. You will need to prepare your own VPN, either private or commercial. It is up to you.

- Setup

Please upload all the scripts to the vpn_dir folder.

```sh
vagrant@go-transmission:~$ cd ~/openvpn/
vagrant@go-transmission:~/openvpn$ bash ./00-setup-transmission.sh
```

- run

After reboot:

```sh
vagrant@go-transmission:~$ cd ~/openvpn/
vagrant@go-transmission:~/openvpn$ ./01-run-vpn-n-p2p.sh
vagrant@go-transmission:~/openvpn$ tmux ls
monitor: 2 windows (created Thu Nov  5 23:06:43 2020) [80x24]
```
> This is my example based on Cyberghost CLI.
> You will have two tmux sessions if you are based on the native openvpn
