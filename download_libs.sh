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
  echo "deb ${DEBMIRROR} bullseye main contrib non-free" >>"${SL}"
  echo "deb ${DEBMIRROR} bullseye-updates main contrib non-free" >>"${SL}"
  echo "deb ${RPIMIRROR} bullseye main" >>"${SL}"

  # Set dpkg arch
  echo "${RARCH}" > "${ADIR}/var/lib/dpkg/arch"

  # Ensure status file exists
  > "${ADIR}/var/lib/dpkg/status"

  # Prep the lib dir
  mkdir -p "${LDIR}"/${RARCH}

  # Grab gpg keys for mirros
  cd "${ADIR}"
  wget -c "${DEBMIRROR}/pool/main/d/debian-archive-keyring/debian-archive-keyring_2021.1.1_all.deb"
  wget -c "${RPIMIRROR}/pool/main/r/raspberrypi-archive-keyring/raspberrypi-archive-keyring_2021.1.1+rpt1_all.deb"
  dpkg -x "debian-archive-keyring_2021.1.1_all.deb" ./
  dpkg -x "raspberrypi-archive-keyring_2021.1.1+rpt1_all.deb" ./

  # Sync apt mirror info
  apt-get -c="${ACONF}" update

  # Download the packages needed
  cd "${LDIR}"/${RARCH}
  apt-get -c="${ACONF}" download -y $( cat "${MDIR}/conf/rpi_packages_bullseye_${RARCH}" | tr '\n' ' ' )

  # Extract libs to build dir
  cd "${LDIR}"/${RARCH}
  ls -1d *deb | while read DEBFILE
  do
    echo "Extracting ${RARCH} ${DEBFILE}"
    dpkg -x "${DEBFILE}" ./
  done

  echo "__FINISH__ download of RPi packages for architecture: ${RARCH}"

done

echo "All done"
