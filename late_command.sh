#!/bin/bash

# passwordless sudo
echo "%sudo   ALL=NOPASSWD: ALL" >> /etc/sudoers

# public ssh key for vagrant user
mkdir /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys "https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"
chmod 755 /home/vagrant/.ssh
chmod 644 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# speed up ssh
echo "UseDNS no" >> /etc/ssh/sshd_config

# Install Rubygems from source
rg_ver=1.8.24
wget -O /tmp/rubygems-${rg_ver}.tgz \
  "http://production.cf.rubygems.org/rubygems/rubygems-${rg_ver}.tgz"
(cd /tmp && tar zxf rubygems-${rg_ver}.tgz && \
  cd rubygems-${rg_ver} && ruby setup.rb --no-format-executable)
rm -rf /tmp/rubygems-${rg_ver} /tmp/rubygems-${rg_ver}.zip

# get chef
gem install chef --no-rdoc --no-ri

# display login promt after boot
sed "s/quiet splash//" /etc/default/grub > /tmp/grub
mv /tmp/grub /etc/default/grub
update-grub

# disable the cdrom path from the apt soruces.list automatically
sed -i 's/^deb cdrom/# DISABLED deb/' /etc/apt/sources.list

# clean up
apt-get -y autoremove
apt-get clean
sync
dd if=/dev/zero of=/zero bs=1M
rm -f /zero
