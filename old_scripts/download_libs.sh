#!/bin/bash

# Set paths
MDIR="$(pwd)"
ADIR="${MDIR}/build/apt"
ACONF="${ADIR}/etc/apt/apt.conf"
LDIR="${MDIR}/build/lib"
SL="${ADIR}/etc/apt/sources.list"

# Get mirror settings
source "${MDIR}/conf/settings.ini"

ACONF="${ADIR}/etc/apt/apt.conf"

# Make the directory tree for APT and dpkg
mkdir -p "${ADIR}/etc/apt/preferences.d"
mkdir -p "${ADIR}/etc/apt/trusted.gpg.d"
mkdir -p "${ADIR}/var/lib/apt/lists/auxfiles"
mkdir -p "${ADIR}/var/lib/apt/lists/partial"
mkdir -p "${ADIR}/var/lib/dpkg"

for RARCH in armhf arm64
do

for DISTRO in buster bullseye
do

  echo "__START__ download of RPi packages for architecture: ${RARCH}"

  # Build apt.conf
  > "${ACONF}"
  echo "Dir \"${ADIR}\";"                    >>"${ACONF}"
  echo "APT::Architecture \"${RARCH}\";"     >>"${ACONF}"
  echo 'APT::Architectures "";'               >>"${ACONF}"
  echo "APT::Architectures:: \"${RARCH}\";"  >>"${ACONF}"

  #cat "${ACONF}"

  # Build sources.list
  > "${SL}"
  echo "deb ${DEBMIRROR} ${DISTRO} main contrib non-free" >>"${SL}"
  echo "deb ${DEBMIRROR} ${DISTRO}-updates main contrib non-free" >>"${SL}"
  echo "deb ${RPIMIRROR} ${DISTRO} main" >>"${SL}"

  # Set dpkg arch
  echo "${RARCH}" > "${ADIR}/var/lib/dpkg/arch"

  # Ensure status file exists
  > "${ADIR}/var/lib/dpkg/status"

  # Prep the lib dir
  mkdir -p "${LDIR}"/${DISTRO}_${RARCH}

  # Find current signing keys
  DEBKEY=$( curl -s "${DEBMIRROR}/pool/main/d/debian-archive-keyring/" | tr '"' '\n' | grep ^debian-archive-keyring_ | grep deb$ | sort -rgb | head -n1 )
  RPIKEY=$( curl -s "${RPIMIRROR}/pool/main/r/raspberrypi-archive-keyring/" | tr '"' '\n' | grep ^raspberrypi-archive-keyring_ | grep deb$ | sort -rgb | head -n1 )

  # Grab gpg keys for mirrors
  cd "${ADIR}"
  wget -c "${DEBMIRROR}/pool/main/d/debian-archive-keyring/${DEBKEY}"
  wget -c "${RPIMIRROR}/pool/main/r/raspberrypi-archive-keyring/${RPIKEY}"
  ls -1d *-archive-keyring_*.deb | while read KEYFILE
  do
    dpkg -x "${KEYFILE}" ./
  done

  # Sync apt mirror info
  apt-get -c="${ACONF}" update

  # Download the packages needed
  cd "${LDIR}"/${DISTRO}_${RARCH}
  apt-get -c="${ACONF}" download -y $( cat "${MDIR}/conf/rpi_packages_${DISTRO}_${RARCH}" | tr '\n' ' ' )

  # Extract libs to build dir
  cd "${LDIR}"/${DISTRO}_${RARCH}
  ls -1d *deb | while read DEBFILE
  do
    echo "Extracting ${RARCH} ${DEBFILE}"
    dpkg -x "${DEBFILE}" ./
  done

  echo "__FINISH__ download of RPi packages for ${DISTRO} ${RARCH}"

done
done

echo "All done"
