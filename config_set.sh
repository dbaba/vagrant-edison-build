#!/usr/bin/env bash

# Setting a kerlnel config value

SCRIPT_BASE=$(dirname $(readlink -f -- "$0"))
EDISON_SRC=${SCRIPT_BASE}/edison/edison-src
pushd ${EDISON_SRC}/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/

CONFIG_FILES="defconfig"
CONFIG="$1"
OPTS="$2"

if [ -z "${CONFIG}" ] || [ -z "${OPTS}" ]; then
  echo -en "\033[91m"
  echo "./config_set.sh <CONFIG> [y|m|u]"
  echo "  => y for yes, m for module and u for unset"
  echo "Set the config name and option"
  echo -en "\e[0m"
  exit 1
fi

echo -e "\033[34m==== BEFORE ==="
for f in ${CONFIG_FILES}
do
  echo "[${f}]"
  grep -n "${CONFIG}" ${f}
  if [ ! -f "${f}.bak" ]; then
	cp ${f} ${f}.bak
  fi
done

if [ "$OPTS" == "y" ]; then
  for f in ${CONFIG_FILES}
  do
    grep -l "${CONFIG}=m" ${f} | xargs sed -i "s/${CONFIG}=m/${CONFIG}=y/g" >/dev/null 2>&1
    grep -l "# ${CONFIG} is not set" ${f} | xargs sed -i "s/# ${CONFIG} is not set/${CONFIG}=y/g" >/dev/null 2>&1
  done
elif [ "$OPTS" == "m" ]; then
  for f in ${CONFIG_FILES}
  do
    grep -l "${CONFIG}=y" ${f} | xargs sed -i "s/${CONFIG}=y/${CONFIG}=m/g" >/dev/null 2>&1
    grep -l "# ${CONFIG} is not set" ${f} | xargs sed -i "s/# ${CONFIG} is not set/${CONFIG}=m/g" >/dev/null 2>&1
  done
elif [ "$OPTS" == "u" ]; then
  for f in ${CONFIG_FILES}
  do
    grep -l "${CONFIG}=y" ${f} | xargs sed -i "s/${CONFIG}=y/# ${CONFIG} is not set/g" >/dev/null 2>&1
    grep -l "${CONFIG}=m" ${f} | xargs sed -i "s/${CONFIG}=m/# ${CONFIG} is not set/g" >/dev/null 2>&1
  done
else
  echo -e "\033[91mAbort! Unknon option => [${OPTS}]\e[0m"
  exit 2
fi

echo -e "\033[96m==== AFTER ==="
for f in ${CONFIG_FILES}
do
  echo "[${f}]"
  grep -n "${CONFIG}" ${f}
done
echo -en "\e[0m"
