Usage
-----
This is what it takes to create your own Vagrant box from the Debian netinstall
ISO image:

    make [32 | 64]

Dependencies: **VirtualBox, cdrtools, bsdtar, vagrant, fakeroot (Linux only)**

**Note!** Mac OS X Lion seems to have a broken libarchive, unable to unpack ISO
files. We use brew's version:

    brew install libarchive

Webofmars notes:
---------------

Forked off https://github.com/tq-cgu/vagrant-debian.git

New stuff:

- allow the use of genisoimage for debian
- corrected the path of bsdtar

William's notes
---------------

Forked off https://github.com/joneskoo/vagrant-debian-squeeze-32

New stuff:

- Bumped to wheezy
- 64- and 32-bit support
- Depend on bsdtar since GNU tar can't extract ISO
- Check against servers MD5 sum
- Made it easier to upgrade in future
- Makefile build system
- Major cleanup

Joonas' notes
-------------

Forked off https://github.com/cal/vagrant-ubuntu-precise-64

Made it:

- build a 32 bit Debian stable instead of Ubuntu.
- zero the image before exporting a package (requires a lot of disk space)

Ben's notes
-----------

Forked Carl's repo, and it sort of worked out of the box. Tweaked
office 12.04 release:

 - Downloading 12.04 final release. (Today as of this writing)
 - Checking MD5 to make sure it is the right version
 - Added a few more checks for external dependencies, mkisofs
 - Removed wget, and used curl to reduce dependencies
 - Added more output to see what is going on
 - Still designed to work on Mac OS X :)
    ... though it should work for Linux systems too (maybe w/ a bit of porting)

Carl's original README
----------------------

Decided I wanted to learn how to make a vagrant base box.

Let's target Precise Pangolin since it should be releasing soon, I said.

Let's automate everything, I said.

Let's do it all on my macbook, I said.

Woo.
