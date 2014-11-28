#!/bin/bash

read -s -p "Enter password for distcc user (put it somewhere safe!): " PASSWORD

useradd -m distcc
echo "distcc:$PASSWORD" | chpasswd
chsh -s /bin/bash distcc

sudo adduser distcc sudo
su distcc <<EOSU
echo $PASSWORD | sudo -S apt-get update
echo $PASSWORD | sudo -S apt-get install util-linux gnu-fdisk git net-tools git-core subversion autoconf automake python python-dev libgtk2.0-dev binutils-dev ntp libc6-i386 lib32z1 lib32stdc++6 -y

cd ~
svn checkout http://distcc.googlecode.com/svn/trunk/ distcc-read-only
cd ~/distcc-read-only
./autogen.sh
./configure --with-gtk
make
echo $PASSWORD | sudo -S make install

cd ~
git clone https://github.com/raspberrypi/tools.git --depth=1
cd ~/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin
echo $PASSWORD | sudo -S ln -sf arm-linux-gnueabihf-gcc gcc
echo $PASSWORD | sudo -S ln -sf arm-linux-gnueabihf-gcc cc
echo $PASSWORD | sudo -S ln -sf arm-linux-gnueabihf-c++ c++
echo $PASSWORD | sudo -S ln -sf arm-linux-gnueabihf-cpp cpp
echo $PASSWORD | sudo -S ln -sf arm-linux-gnueabihf-g++ g++
EOSU
