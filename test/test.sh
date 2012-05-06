#!/bin/bash

if ! vagrant box list | grep debian-squeeze-32 >/dev/null; then
  vagrant box add debian-squeeze-32 ../package.box
fi

vagrant up
vagrant ssh
