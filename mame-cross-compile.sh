#!/bin/bash

## Source settings
cd "$(dirname ${0})" || exit 1
source conf/settings.ini

## Source help screens
source "${DIR_FUNC}/help_long"
source "${DIR_FUNC}/help_short"

if [ -z "${1}" ]
then
  help_long
  exit 1
fi

while getopts "o:r:a:v:f:c:h" OPT
do
  case ${OPT} in
    h)
      help_long ; exit 1 ;;
    o)
      case ${OPTARG} in
        prepare) OPERATION=${OPTARG} ;;
        download) OPERATION=${OPTARG} ;;
        compile) OPERATION=${OPTARG} ;;
        *) echo "Invalid operation: -o ${OPTARG}" ; help_short ; exit 1 ;;
      esac
      ;;
    r)
      case ${OPTARG} in
        10)
          DEBVER=10
          DEBREL=buster
          ;;
        buster)
          DEBVER=10
          DEBREL=buster
          ;;
        11)
          DEBVER=11
          DEBREL=bullseye
          ;;
        bullseye)
          DEBVER=11
          DEBREL=bullseye
          ;;
        12)
          DEBVER=12
          DEBREL=bookworm
          ;;
        bookworm)
          DEBVER=12
          DEBREL=bookworm
          ;;
        *)
          echo "Invalid Debian release: -r ${OPTARG}"
          help_short
          exit 1
          ;;
      esac
      ;;
    a)
      case ${OPTARG} in
        arm)     APTARCH=armhf ; LINARCH=arm-linux-gnueabihf ;;
        armhf)   APTARCH=armhf ; LINARCH=arm-linux-gnueabihf ;;
        arm32)   APTARCH=armhf ; LINARCH=arm-linux-gnueabihf ;;
        arm64)   APTARCH=arm64 ; LINARCH=aarch64-linux-gnu ;;
        aarch64) APTARCH=arm64 ; LINARCH=aarch64-linux-gnu ;;
        *) echo "Invalid architecture: -a ${OPTARG}" ; help_short ; exit 1 ;;
      esac
      ;;
    v)
      case ${OPTARG} in
        *) MAMEVER=${OPTARG} ;;
      esac
      ;;
    f)
      case ${OPTARG} in
        mame) MAMEFORK=${OPTARG} ; GIT="https://github.com/mamedev/mame.git" ;;
        groovymame) MAMEFORK=${OPTARG} ; GIT="https://github.com/antonioginer/GroovyMAME.git" ;;
        *) echo "Invalid fork: -f ${OPTARG}" ; help_short ; exit 1 ;;
      esac
      ;;
    c)
      case ${OPTARG} in
        *) CPUS=${OPTARG} ;;
      esac
      ;;
  esac
done

if [ -z "${OPERATION}" ]
then
  echo "Please specify operation type via -o"
  help_short
  exit 1
fi

if [ -z "${DEBVER}" ]
then
  echo "Please specify Debian release via -r"
  help_short
  exit 1
fi

if [ -z "${DEBREL}" ]
then
  echo "Please specify Debian release via -r"
  help_short
  exit 1
fi

if [ -z "${APTARCH}" ]
then
  echo "Please specify architecture via -a"
  help_short
  exit 1
fi

if [ -z "${MAMEVER}" ]
then
  MAMEVER=latest
elif [[ "${MAMEVER}" =~ ^[0-9]\.[0-9]{3}$ ]]
then
  GITVER="$(echo ${MAMEVER} | tr -d '\.')"
else
  echo "Invalid MAME version string: -v ${MAMEVER}"
  help_short
  exit 1
fi

if [ -z "${CPUS}" ]
then
  source functions/cpu_ram_ratio
  cpu_ram_ratio
elif ! [[ "${CPUS}" =~ ^[0-9]+$ ]]
then
  echo "Invalid number of CPUs: -c ${CPUS}"
  help_short
  exit 1
fi

if [ -z "${MAMEFORK}" ]
then
  MAMEFORK=mame
  GIT="https://github.com/mamedev/mame.git"
fi

## Compatibility note:
## Debian 10 buster   requires ctng 1.25.0
## Debian 11 bullseye requires ctng 1.25.0
## Debian 12 bookworm requires ctng 1.26.0
if [ "$DEBVER" == "10" ]
then
  CTNGVER="1.25.0"
elif [ "$DEBVER" == "11" ]
then
  CTNGVER="1.25.0"
elif [ "$DEBVER" == "12" ]
then
  CTNGVER="1.26.0"
fi

DSTR="debian_${DEBVER}_${DEBREL}_${APTARCH}"

source "${DIR_FUNC}/${OPERATION}"

#echo ${OPERATION} ${DEBVER} ${DEBREL} ${APTARCH} ${MAMEFORK} ${MAMEVER} ${CPUS}

mkdir -p "${DIR_BUILD}/log"

${OPERATION} 2>&1 | tee "${DIR_BUILD}/log/${OPERATION}_${DSTR}.log"
