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

# Create output dirs if missing
mkdir -p "${TDIR}/results" 2>/dev/null

# Check all results exist
while read -r MROM
do
  MEXIST=$( grep ^Average "${TDIR}/log/${MROM}.log" 2>/dev/null )
  if [ -z "${MEXIST}" ]
  then
    echo "Results missing"
    echo "Please re-run ${TDIR}/benchmark.sh ${1}"
    exit 1
  fi
done < "${1}"

echo "Renaming old results.csv if it exists..."
mv -vf "${TDIR}/results/results.csv" "${TDIR}/results/results_$(date --iso-8601=s).csv" 2>/dev/null

echo 'ROM,Percentage' > "${TDIR}/results/results.csv"

# Build CSV file
cat "${1}" | while read MROM
do
  FPS=$( grep ^Average "${TDIR}/log/${MROM}.log" | awk '{print $3}' | tr -d '%' )
  echo "${MROM},${FPS}" >> "${TDIR}/results/results.csv"
done
  
echo "Results output to ${TDIR}/results/results.csv"
