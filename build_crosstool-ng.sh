#!/bin/bash

## Set up build dir
MDIR="$(pwd)"
BDIR="${MDIR}/build"
mkdir -p "${BDIR}"

## Install the ct-ng installer tool
cd
if [ -d crosstool-ng ]
then
  cd "${BDIR}/crosstool-ng"
  make clean
  git reset --hard HEAD
  git pull
else
  cd "${BDIR}"
  git clone https://github.com/crosstool-ng/crosstool-ng
fi

cd "${BDIR}/crosstool-ng"
./bootstrap
./configure --prefix="${BDIR}/ct-ng"
make -j $(nproc) install

## Set ct-ng tools path
export PATH="${BDIR}/ct-ng/bin":${PATH}

## Build environments
for RPIARCH in armhf aarch64
do
  CDIR="${BDIR}/ctng_rpi_${RPIARCH}"
  mkdir -p "${CDIR}"
  cd "${CDIR}"
  cp "${MDIR}/crosstools-ng/ctng_config_rpi_bullseye_${RPIARCH}" .config
  echo "Building the following:"
  ct-ng show-config
  sleep 1
  ct-ng build
done
