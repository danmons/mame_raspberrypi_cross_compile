#!/bin/bash

## crosstool-ng doesn't like LD_LIBRARY_PATH set
unset LD_LIBRARY_PATH

## Set up build dir
MDIR="$(pwd)"
BDIR="${MDIR}/build"
mkdir -p "${BDIR}"

## Install the ct-ng installer tool
cd "${BDIR}"
if [ -d crosstool-ng ]
then
  cd "${BDIR}/crosstool-ng"
  make clean
  git checkout master
  git reset --hard HEAD
  git pull
else
  cd "${BDIR}"
  git clone https://github.com/crosstool-ng/crosstool-ng
fi

cd "${BDIR}/crosstool-ng"
# force release 1.25.0 for compatibility with Debian 11 Bullseye hosts
git checkout crosstool-ng-1.25.0
./bootstrap
./configure --prefix="${BDIR}/ct-ng"
make -j $(nproc) install

## Set ct-ng tools path
export PATH="${BDIR}/ct-ng/bin":${PATH}

## Build bullseye 32/64bit environments
for RPIARCH in armhf aarch64
do
  CDIR="${BDIR}/ctng_rpi_${RPIARCH}"
  mkdir -p "${CDIR}"
  cd "${CDIR}"
  cp "${MDIR}/crosstool-ng/ctng_config_rpi_bullseye_${RPIARCH}" .config
  echo "Building the following:"
  ct-ng show-config
  sleep 1
  ct-ng build
done

## Build Buster 32bit only
CDIR="${BDIR}/ctng_rpi2_buster_armhf"
mkdir -p "${CDIR}"
cd "${CDIR}"
cp "${MDIR}/crosstool-ng/ctng_config_rpi2b_buster_armhf" .config
echo "Building the following:"
ct-ng show-config
sleep 1
ct-ng build
