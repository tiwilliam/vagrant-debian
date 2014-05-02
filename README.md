# Debian for Vagrant

This script bundle helps you download, preseed and package Debian for Vagrant.

## Mac OS X Guide

Install [Vagrant](http://www.vagrantup.com/downloads.html) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

    brew install cdrtools libarchive
    brew link libarchive --force
    ./vagrant-debian 64

## Debian Guide

    apt-get install fakeroot bsdtar genisoimage vagrant virtualbox virtualbox-guest-additions-iso
    ./vagrant-debian 64

Forked off [joneskoo/vagrant-debian-squeeze-32](https://github.com/joneskoo/vagrant-debian-squeeze-32)
