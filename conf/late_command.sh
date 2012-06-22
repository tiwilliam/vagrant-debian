#!/bin/bash

# No password for sudo
echo "%sudo ALL = NOPASSWD: ALL" >> /etc/sudoers

# Public SSH key for vagrant user
mkdir /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys "https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Install chef
gem install chef --no-rdoc --no-ri

# Clean up
apt-get -y autoremove
apt-get clean

# Wait for disk
sync
