#!/bin/bash

DISTCC_USER="distcc"
read -s -p "Enter password for sudo commands: " PASSWORD
read -p "Enter IP address for build executor: " BUILD_IP
read -s -p "Enter password for $DISTCC_USER user on build executor: " DISTCC_PASSWORD

echo $PASSWORD | sudo -S apt-get update
echo $PASSWORD | sudo -S apt-get install sshpass util-linux gnu-fdisk git net-tools git-core subversion autoconf automake python python-dev libgtk2.0-dev binutils-dev ntp -y

libiberty_dir = mktemp -d
cd $libiberty_dir
wget https://toolbox-of-eric.googlecode.com/files/libiberty.tar.gz
tar -xzvf libibterty.tar.gz
cd $libiberty_dir/libiberty
echo $PASSWORD | sudo -S ./configure
echo $PASSWORD | sudo -S make
echo $PASSWORD | sudo -S make install
rm -r $libiberty_dir

distcc_dir = mktemp -d
cd $distcc_dir
svn checkout http://distcc.googlecode.com/svn/trunk/ distcc-read-only
cd $distcc_dir/distcc-read-only
./autogen.sh
./configure --with-gtk
make
echo $PASSWORD | sudo -S make install
rm -r $distcc_dir

echo $PASSWORD | sudo -S ln -s /usr/local/bin/distcc /usr/local/bin/gcc
echo $PASSWORD | sudo -S ln -s /usr/local/bin/distcc /usr/local/bin/cc
echo $PASSWORD | sudo -S ln -s /usr/local/bin/distcc /usr/local/bin/g++
echo $PASSWORD | sudo -S ln -s /usr/local/bin/distcc /usr/local/bin/c++
echo $PASSWORD | sudo -S ln -s /usr/local/bin/distcc /usr/local/bin/cpp

ssh-keygen -t rsa -C distcc_build -f ~/.ssh/id_rsa_distcc_build -q -P ""
sshpass -p $DISTCC_PASSWORD scp ~/.ssh/id_rsa_distcc_build.pub $DISTCC_USER@$BUILD_IP:/home/$DISTCC_USER/.ssh/authorized_keys_distcc_build

echo DISTCC_HOSTS="$DISTCC_USER@$BUILD_IP/16" >> ~/.bash_profile
echo DISTCC_BACKOFF_PERIOD=0 >> ~/.bash_profile
echo DISTCC_IO_TIMEOUT=3000 >> ~/.bash_profile
echo DISTCC_SKIP_LOCAL_RETRY=1 >> ~/.bash_profile
echo PATH=/usr/local/bin:$PATH >> ~/.bash_profile
# can we get this over to the other machine?
echo DISTCC_PATH=/home/$DISTCC_USER/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:/home/$DISTCC_USER/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/arm-linux-gnueabihf/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games >> ~/.bash_profile
