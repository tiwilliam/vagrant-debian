#!/bin/bash

dd if=/dev/zero of=/swapfile1 bs=1024 count=1024000
mkswap /swapfile1
swapon /swapfile1
echo "/swapfile1  none  swap  sw  0  0" >> /etc/fstab

apt-get install -y linux-headers-$(uname -r)
mount /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run

mv /etc/rc.local.bak /etc/rc.local

# Oldstable
if [ -x /sbin/shudown ]; then
    /sbin/shutdown -h now
fi

# Stable +
if [ -x /bin/systemctl ]; then
    /bin/systemctl poweroff
fi

# Otherwise shutdown the machine manually
