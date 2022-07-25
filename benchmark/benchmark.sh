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

# Build binary with all path options
export MBIN="${MAMEDIR}/mame -homepath ${MAMEDIR} -rompath ${MAMEDIR}/roms;${MAMEDIR}/chd -cfg_directory ${MAMEDIR}/cfg -nvram_directory ${MAMEDIR}/nvram"

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
    ${MBIN} -bench 90 "${MROM}" >>"${TDIR}/log/${MROM}.log" 2>&1
    sleep 3
  else
    echo "${MROM}" already has benchmark results in "${TDIR}/log/${MROM}.log"
  fi
done
