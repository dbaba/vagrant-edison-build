#!/usr/bin/env bash

# Edison kernel module building script

SCRIPT_BASE=$(dirname $(readlink -f -- "$0"))
EDISON_SRC=${SCRIPT_BASE}/edison/edison-src
POKY_DIR="${EDISON_SRC}/out/linux64/poky"

BBCONF_REP="FETCHCMD_wget = \"/usr/bin/env wget -t 2 -T 30 -nv --passive-ftp --no-check-certificate\""
BBCONF_REP_WITH="FETCHCMD_wget = \"/usr/bin/env /home/vagrant/fetch_cmd\""

cd ${EDISON_SRC}
cd ./out/linux64
source poky/oe-init-build-env
# moved to ./build implicitly
touch conf/sanity.conf

# Modify FETCHCMD_wget as GNU wget failed to connect POODLE vulnerability fixed servers
if [ ! -f "${POKY_DIR}/meta/conf/bitbake.conf.org" ]; then
  cp -f ${POKY_DIR}/meta/conf/bitbake.conf ${POKY_DIR}/meta/conf/bitbake.conf.org
  echo -e "\033[93mbitbake.conf backup has been created => ${POKY_DIR}/meta/conf/bitbake.conf.org \033[0m"
fi
sed -i -e "s/${BBCONF_REP//\//\\/}/${BBCONF_REP_WITH//\//\\/}/g" ${POKY_DIR}/meta/conf/bitbake.conf

# START BANNER
echo -e "\033[92mStart building at $(date)\033[0m"
time bitbake edison-image
echo -e "\033[92mTerminated building at $(date)\033[0m"

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
