# Debian for Vagrant

Tool for downloading and preseeding the latest versions of Debian.
You can set version *stable*, *testing* or like [0-9].[0-9].[0-9]+ 
Exmaple: 6.0.10 = last squeeze , 7.8.0 = last wheezy
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

## Old and testing releases

You can also build images for squeeze and testing using any of following commands:

    ./vagrant-debian 64 7.8.0

or

    ./vagrant-debian 64 testing

Forked off [tiwilliam/vagrant-debian](https://github.com/tiwilliam/vagrant-debian)
