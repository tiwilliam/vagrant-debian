#!/bin/bash

mount /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run

mv /etc/rc.local.bak /etc/rc.local
shutdown -h now
