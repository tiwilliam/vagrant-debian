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

## Debian Guide

    apt-get install fakeroot p7zip-full genisoimage vagrant virtualbox virtualbox-guest-additions-iso
    ./vagrant-debian 64

## Build *current* release

    ./vagrant-debian 64

## Old and testing releases

You can also build images for squeeze and testing using any of following commands:

    ./vagrant-debian 64 7.8.0

or

    ./vagrant-debian 64 testing

## Configuration

You can set VagrantKey options in `vagrant-debian` file :

    VBOX_KEY="${FOLDER_BASE}/vagrantkey"

You can set headless or gui mode. 
if you set 1. you can see build process in virtualbox window.
if set 0 - headless mode.

    VBOX_GUI=1 

Also you can add your pkgs to auto install. Change `scripts/custom_apps.sh` file
    

Forked off:
* [joneskoo/vagrant-debian-squeeze-32](https://github.com/joneskoo/vagrant-debian-squeeze-32)
* [tiwilliam/vagrant-debian](https://github.com/tiwilliam/vagrant-debian)