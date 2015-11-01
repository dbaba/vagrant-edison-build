#!/usr/bin/env bash

# Edison kernel module building script

SCRIPT_BASE=$(dirname $(readlink -f -- "$0"))
EDISON_SRC=${SCRIPT_BASE}/edison/edison-src

pushd ${EDISON_SRC}
cd ./out/linux64
source poky/oe-init-build-env
# moved to ./build implicitly
touch conf/sanity.conf
echo -e "\033[92mStart building at $(date)\033[0m"
time bitbake edison-image
echo -e "\033[92mTerminated building at $(date)\033[0m"
popd

ROOTFS=`ls ./tmp/deploy/images/edison/edison-image-edison.ext4`
RET=$?
if [ "${RET}" != "0" ]; then
  echo -e "\033[91mThe rootfs is missing. You should have build errors.\033[0m"
  exit 1
fi

if [ -d /mnt/edison ]; then
  sudo umount /mnt/edison >/dev/null 2>&1
else
  sudo mkdir -p /mnt/edison
fi
sudo mount -o loop ${ROOTFS} /mnt/edison

cd /mnt/edison/
echo -en "\033[93m"
echo "Done. You're now able to explore the rootfs from here! => $(pwd)"
echo "Copy files to /vagrant, and you can get them from the host machine without SCP."
echo -en "\033[0m"
