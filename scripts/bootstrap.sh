#!/bin/bash

# passwordless sudo
echo "%sudo   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# add vagrant user rule
echo "vagrant   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant

# ssh key for vagrant user
mkdir -p /home/vagrant/.ssh/authorized_keys.d
cp -f /tmp/vagrantkey /home/vagrant/.ssh/authorized_keys.d/ 
chmod 755 /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh/authorized_keys.d
chmod 600 /home/vagrant/.ssh/authorized_keys.d/vagrantkey

chown -R vagrant:vagrant /home/vagrant/.ssh

# speed up ssh
echo "UseDNS no" >> /etc/ssh/sshd_config

# remove debian boot error "Driver pcspkr is already registered, aborting..."
echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf

# display all while boot
sed "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\"\"|" /etc/default/grub > /tmp/grub
sed "s|GRUB_TIMEOUT=[0-9]|GRUB_TIMEOUT=1|" /tmp/grub > /etc/default/grub
update-grub

sudo apt-get -y -qq install linux-headers-$(uname -r) build-essential dkms nfs-common zerofree
sudo apt-get -y -qq install vim-nox ranger mc bash-completion aptitude

if [[ -d "/tmp/VBA" ]] ; then 
  if [[ -f "/tmp/VBA/VBoxLinuxAdditions.run" ]] ;then
    echo "install VBoxLinuxAdditions ..."
    chmod +x /tmp/VBA/VBoxLinuxAdditions.run
    sh /tmp/VBA/VBoxLinuxAdditions.run --nox11
  fi
  rm -rvf /tmp/VBA
fi

# clean up
apt-get autoremove --yes
apt-get clean

#agressive clean
rm -Rf /var/lib/apt/*
rm -Rf /var/log/installer

rm -Rf /var/log/*.gz
rm -Rf /var/log/*.1
rm -Rf /var/log/*.0 
## clear all log data
for logfile in /var/log/*.log ; do
  echo '' > $logfile
done

find /var/cache -type f -exec rm -rf {} \;

if [[ -f "/tmp/initzerofree.sh" ]] ; then 
    echo 'InitZeroFree script found'
    cp -v /tmp/initzerofree.sh /initzerofree
    chmod +x /initzerofree
    # replace init script to zerofree hdd
    sed -i "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\" single init=/initzerofree \"|" /etc/default/grub
    update-grub
else
# FillZero free space to aid VM compression
  dd if=/dev/zero of=/EMPTY bs=1M
  rm -f /EMPTY
fi

# Install ohai gem until CHEF-3778 is fixed
gem install ohai
gem install chef

# Install guest additions on next boot
# in debian 8 systemd dont start rc.local like upstart.d in debian <= 7
# cp /etc/rc.{local,local.bak} && cp /root/poststrap.sh /etc/rc.local

# Wait for disk
sync
