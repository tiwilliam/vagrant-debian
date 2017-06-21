# Debian for Vagrant

Tool for downloading and preseeding the latest versions of Debian.
You can set version to *stable*, *testing* or a specific version like *6.0.10*.
It will download the network installer, install Debian using a preseed
config, install guest additions and export it to the Vagrant box format.

## Mac OS X Guide

Install [Vagrant](http://www.vagrantup.com/downloads.html) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

    brew install fakeroot dvdrtools p7zip
    ./vagrant-debian 64

## Debian Stretch Guide

Follow the [Virtualbox Debian wiki page](https://wiki.debian.org/VirtualBox).

    apt-get install fakeroot p7zip-full genisoimage vagrant virtualbox-5.1
    ./vagrant-debian 64

## Debian Jessie Guide

    apt-get install fakeroot p7zip-full genisoimage vagrant virtualbox virtualbox-guest-additions-iso
    ./vagrant-debian 64

## Arch Guide

    pacman -S base-devel p7zip cdrkit vagrant virtualbox virtualbox-guest-iso
    ./vagrant-debian 64

## Old and testing releases

You can also build images for squeeze and testing using any of following commands:

    ./vagrant-debian 64 7.8.0

or

    ./vagrant-debian 64 testing

Forked off [joneskoo/vagrant-debian-squeeze-32](https://github.com/joneskoo/vagrant-debian-squeeze-32)
