#!/bin/bash

# No password for sudo
echo "%sudo ALL = NOPASSWD: ALL" >> /etc/sudoers

# Public SSH key for vagrant user
mkdir /home/vagrant/.ssh
curl -s "https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub" -o /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Install chef
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null
echo "chef chef/chef_server_url string http://127.0.0.1:4000" | debconf-set-selections
apt-get update && apt-get install -y opscode-keyring chef

# Install guest additions on next boot
cp /etc/rc.{local,local.bak} && cp /root/poststrap.sh /etc/rc.local

# Clean up
apt-get -y autoremove
apt-get clean

# Wait for disk
sync
