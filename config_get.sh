#!/usr/bin/env bash

# Listing kerlnel config values

SCRIPT_BASE=$(dirname $(readlink -f -- "$0"))
EDISON_SRC=${SCRIPT_BASE}/edison/edison-src
pushd ${EDISON_SRC}/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/

CONFIG_FILES="defconfig"
CONFIG="$1"

if [ -z ${CONFIG} ];then
  echo -e "\033[91mSet the config name\e[0m"
  exit 1
fi

echo -en "\033[91m"
for f in ${CONFIG_FILES}
do
  echo "[${f}]"
  grep -n "${CONFIG}" ${f}
done
echo -en "\e[0m"
