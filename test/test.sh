#!/bin/bash

if ! vagrant box list | grep ubuntu-precise-32 >/dev/null; then
  vagrant box add ubuntu-precise-32 ../package.box
fi

vagrant up
vagrant ssh
