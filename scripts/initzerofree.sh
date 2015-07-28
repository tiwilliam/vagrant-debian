#!/bin/bash
init 1
echo ' === [ zerofree /dev/sda1 ] === '
mount -n -o remount,ro /dev/sda1 /
zerofree -v /dev/sda1
mount -n -o remount,rw /dev/sda1 /
sync
sed -i "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\"\"|g" /etc/default/grub
update-grub

rm -f /initzerofree

## try correct shutdown ..
# run scripts from init 0
find /etc/rc0.d -type l | sort | xargs -I {} -n 1 /bin/bash {} stop

exit 0
