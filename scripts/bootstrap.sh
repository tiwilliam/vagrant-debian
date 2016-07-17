#!/bin/bash

# passwordless sudo
echo "%sudo   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# add vagrant user rule
echo "vagrant   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant

# ssh key for vagrant user
mkdir -p /home/vagrant/.ssh
chmod 755 /home/vagrant/.ssh

if [[ -f "/tmp/vagrantkey.pub" ]] ; then
    echo 'Vagrant key found ' >> /home/vagrant/bootstraping.log
    cat /tmp/vagrantkey.pub >> /home/vagrant/.ssh/authorized_keys 
    chmod 640 -v /home/vagrant/.ssh/authorized_keys  >> /home/vagrant/bootstraping.log
    chown -v vagrant:vagrant /home/vagrant/.ssh/authorized_keys  >> /home/vagrant/bootstraping.log
else
    echo 'Vagrant key NOT FOUND "/tmp/custom_apps.sh" ' >> /home/vagrant/bootstraping.log
fi
chown -R vagrant:vagrant /home/vagrant/.ssh

# speed up ssh
echo "UseDNS no" >> /etc/ssh/sshd_config

# remove debian boot error "Driver pcspkr is already registered, aborting..."
echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf

# set timeout 1
sed "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\"\"|" /etc/default/grub > /tmp/grub
sed "s|GRUB_TIMEOUT=[0-9]|GRUB_TIMEOUT=1|" /tmp/grub > /etc/default/grub
update-grub

sudo apt-get -y -qq install linux-headers-$(uname -r) build-essential dkms nfs-common zerofree

if [[ -f "/tmp/custom_apps.sh" ]] ; then 
    echo 'Custom Apps script found' >> /home/vagrant/bootstraping.log
    chmod +x -v /tmp/custom_apps.sh  >> /home/vagrant/bootstraping.log
    sh /tmp/custom_apps.sh >> /home/vagrant/bootstraping.log
else 
    echo 'Custom Apps script NOT found "/tmp/custom_apps.sh" ' >> /home/vagrant/bootstraping.log
fi

if [[ -d "/tmp/VBA" ]] ; then 
  if [[ -f "/tmp/VBA/VBoxLinuxAdditions.run" ]] ;then
    echo "install VBoxLinuxAdditions ..." >> /home/vagrant/bootstraping.log
    chmod +x /tmp/VBA/VBoxLinuxAdditions.run
    sh /tmp/VBA/VBoxLinuxAdditions.run --nox11 >> /home/vagrant/bootstraping.log
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
    echo 'InitZeroFree script found' >> /home/vagrant/bootstraping.log
    cp -v /tmp/initzerofree.sh /initzerofree  >> /home/vagrant/bootstraping.log
    chmod +x /initzerofree
    # replace init script to zerofree hdd
    sed -i "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\" single init=/initzerofree \"|" /etc/default/grub
    update-grub
else
# FillZero free space to aid VM compression
  dd if=/dev/zero of=/EMPTY bs=1M
  rm -f /EMPTY
fi

# Install guest additions on next boot
# in debian 8 systemd dont start rc.local like upstart.d in debian <= 7
# cp /etc/rc.{local,local.bak} && cp /root/poststrap.sh /etc/rc.local

chown -v vagrant:vagrant /home/vagrant/bootstraping.log  >> /home/vagrant/bootstraping.log

# Wait for disk
sync
