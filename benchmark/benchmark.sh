#!/bin/bash

usage() {
  echo
  echo "${0} /path/to/gameslist.txt"
  echo
}

if [ -z "${1}" ]
then
  usage
  exit 1
fi

if [ ! -f "${1}" ]
then
  echo
  echo "${1} not found!"
  usage
  exit 1
fi

TDIR=$( dirname "${0}" )

# Source config
source "${TDIR}/config.ini"

# Enable dynamic recompilation for x86 architectures only
# Disable it for everything else, as it's not supported by MAME yet
export MARCH=$(uname -m)
case "${MARCH}" in
x86_64)
  unset NODRC
  ;;
i686)
  unset NODRC
  ;;
i386)
  unset NODRC
  ;;
*)
  export NODRC="-nodrc"
  ;;
esac

# Build binary with all path options
export MBIN="${MAMEDIR}/mame -homepath ${MAMEDIR} -rompath ${MAMEDIR}/roms;${MAMEDIR}/chd -cfg_directory ${MAMEDIR}/cfg -nvram_directory ${MAMEDIR}/nvram ${NODRC}"

# Set the download URL for the NVRAM files
export MURL="https://raw.githubusercontent.com/danmons/mame_raspberrypi_cross_compile/main/benchmark/files"

# Create MAME dirs if missing
mkdir -p ${MAMEDIR}/roms ${MAMEDIR}/chd ${MAMEDIR}/cfg ${MAMEDIR}/nvram 2>/dev/null

# Create output dirs if missing
mkdir -p "${TDIR}/log" 2>/dev/null

# Read the list of ROMs
# Benchmark only the ones with missing results
# To re-benchmark, delete the output log file
cat "${1}" | while read MROM
do
  HASFPS=$(grep ^Average "${TDIR}/log/${MROM}.log" 2>/dev/null)
  if [ -z "${HASFPS}" ]
  then
    echo Benchmarking "${MROM}"
    unset NEEDSNVRAM
    NEEDSNVRAM=$( grep ^"${MROM}"$ "${TDIR}/lists/nvram.txt" )
    if [ -n "${NEEDSNVRAM}" ]
    then
      echo "${MROM} requires NVRAM files to benchmark accurately, downloading them..."
      cd "${MAMEDIR}/nvram"
      aria2c --allow-overwrite=true "${MURL}/nvram/${MROM}.7z"
      7za x -aoa "${MROM}.7z"
      cd -
      cd "${MAMEDIR}/cfg"
      aria2c --allow-overwrite=true "${MURL}/cfg/${MROM}.cfg"
      cd -
    fi
    # Force display out to main Xorg window for benchmarking over SSH
    # Flush disk buffers before and after in case we crash, so we can at least save the logs
    sync
    DISPLAY=:0 ${MBIN} -bench 90 "${MROM}" >>"${TDIR}/log/${MROM}.log" 2>&1
    sync
    sleep 3
  else
    echo "${MROM}" already has benchmark results in "${TDIR}/log/${MROM}.log"
  fi
done
