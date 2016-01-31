#!/usr/bin/env bash

# Provisioning Script for Vagrant box
# This scirpt is expected to be run as root

SOURCE_URL=http://downloadmirror.intel.com/25028/eng/edison-src-ww25.5-15.tgz
LINUX_VERSION_EXTENSION=-poky-edison+
DNS="8.8.8.8"

SCRIPT_BASE=$(dirname $(readlink -f -- "$0"))
DEST_FILE=edison-src.tgz

if [ -n "${DNS}" ]; then
  sh -c "echo nameserver ${DNS} > /etc/resolv.conf"
fi

apt-get update
apt-get install -y build-essential git diffstat gawk chrpath texinfo libtool gcc-multilib curl python wget

mkdir /edison
cd /edison
curl -L -o ${DEST_FILE} ${SOURCE_URL}
tar zxf ${DEST_FILE}
cd edison-src

echo -e "LINUX_VERSION_EXTENSION = \"${LINUX_VERSION_EXTENSION}\"" \
  >> meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/linux-yocto_3.10.bbappend

mv /edison/ /home/vagrant/
cd /home/vagrant/edison/edison-src
mkdir bitbake_download_dir bitbake_sstate_dir
./meta-intel-edison/setup.sh --dl_dir=./bitbake_download_dir --sstate_dir=./bitbake_sstate_dir

cp /vagrant/build.sh /home/vagrant/
cp /vagrant/config_get.sh /home/vagrant/
cp /vagrant/config_set.sh /home/vagrant/
cp /vagrant/fetch_cmd /home/vagrant/

chown -R vagrant:vagrant /home/vagrant/
