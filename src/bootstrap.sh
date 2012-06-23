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
gem install chef --no-rdoc --no-ri

# Install VirtualBox Additions
mount /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run
umount /media/cdrom

# Clean up
apt-get -y autoremove
apt-get clean

# Wait for disk
sync
