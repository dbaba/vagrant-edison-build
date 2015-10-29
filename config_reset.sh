#!/usr/bin/env bash

# Resetting all kerlnel config

SCRIPT_BASE=$(dirname $(readlink -f -- "$0"))
EDISON_SRC=${SCRIPT_BASE}/edison/edison-src
pushd ${EDISON_SRC}/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/

CONFIG_FILES="defconfig"

echo -e "\033[92mResetting configuration"
for f in ${CONFIG_FILES}
do
  echo "[${f}]"
  if [ -f "${f}.bak" ]; then
	cp -f ${f}.bak ${f}
  fi
done

echo -e "Done\e[0m"
