#!/bin/bash

# force qt5
export QT_SELECT=5
# set paths
export MDIR="$(pwd)"
export MXTARCH=armv8-rpi3-linux-gnueabihf
export MXTOOLS="${HOME}/x-tools/${MXTARCH}"
export MARCHDIR="${MDIR}/build/lib/bullseye_armhf"
export RPIARCH=arm-linux-gnueabihf

source "${MDIR}/conf/settings.ini"

if [ -d "${MARCHDIR}" ]
then
  echo "Found RPiOS32 libraries in ${MARCHDIR}"
else
  echo "ERROR"
  echo "Cannot find ${MARCHDIR}"
  echo "Please run ./download_libs.sh"
  exit 1
fi

if [ -d "${MXTOOLS}" ]
then
  echo "Found Crosstool-NG in ${MXTOOLS}"
else
  echo "ERROR"
  echo "Cannot find Crosstool-NG"
  echo "Please run ./build_crosstool-ng.sh"
  exit 1
fi

echo "Preparing MAME..."

mkdir -p "${MDIR}/build/src"
cd "${MDIR}/build/src"

if [ -d mame ]
then
  echo "Found existing MAME src, updating it..."
  cd "${MDIR}/build/src/mame"
  git clean -df
  make clean
  git reset --hard HEAD
  git checkout master
  git reset --hard HEAD
  git pull
  export MAMEVER=$(git tag | tail -n1)
  git checkout "${MAMEVER}"
else
  echo "No MAME src found, cloning from GitHub..."
  cd "${MDIR}/build/src"
  git clone 'https://github.com/mamedev/mame.git'
  cd mame
  export MAMEVER=$(git tag | tail -n1)
  git checkout "${MAMEVER}"
fi


echo "Building MAME"

cd "${MDIR}/build/src/mame"
make \
 CROSS_BUILD=1 \
 TOOLS=1 \
 NOWERROR=1 \
 PLATFORM=arm \
 CFLAGS+="-I ${MARCHDIR}/usr/include" \
 CFLAGS+="-I ${MARCHDIR}/usr/include/${RPIARCH}" \
 CFLAGS+="-L ${MARCHDIR}/usr/lib" \
 CFLAGS+="-L ${MARCHDIR}/usr/lib/${RPIARCH}" \
 CPPFLAGS+="-I ${MARCHDIR}/usr/include" \
 CPPFLAGS+="-I ${MARCHDIR}/usr/include/${RPIARCH}" \
 CPPFLAGS+="-L ${MARCHDIR}/usr/lib" \
 CPPFLAGS+="-L ${MARCHDIR}/usr/lib/${RPIARCH}" \
 LDFLAGS+="-L ${MARCHDIR}/usr/lib" \
 LDFLAGS+="-L ${MARCHDIR}/usr/lib/${RPIARCH}" \
 ARCHOPTS+="-Wl,-R,${MARCHDIR}/usr/lib" \
 ARCHOPTS+="-Wl,-R,${MARCHDIR}/usr/lib/${RPIARCH}" \
 ARCHOPTS+="-Wl,-R,${MARCHDIR}/lib" \
 ARCHOPTS+="-Wl,-R,${MARCHDIR}/lib/${RPIARCH}" \
 ARCHOPTS+="-Wl,-R,${MARCHDIR}/usr/lib/${RPIARCH}/pulseaudio" \
 ARCHOPTS+="-Wl,-R,${MARCHDIR}/opt/vc/lib" \
 ARCHOPTS+="-Wl,-rpath,${MARCHDIR}/usr/lib" \
 ARCHOPTS+="-Wl,-rpath,${MARCHDIR}/usr/lib/${RPIARCH}" \
 ARCHOPTS+="-Wl,-rpath,${MARCHDIR}/lib" \
 ARCHOPTS+="-Wl,-rpath,${MARCHDIR}/lib/${RPIARCH}" \
 ARCHOPTS+="-Wl,-rpath,${MARCHDIR}/usr/lib/${RPIARCH}/pulseaudio" \
 ARCHOPTS+="-Wl,-rpath,${MARCHDIR}/opt/vc/lib" \
 ARCHOPTS+="-Wl,-rpath-link,${MARCHDIR}/usr/lib" \
 ARCHOPTS+="-Wl,-rpath-link,${MARCHDIR}/usr/lib/${RPIARCH}" \
 ARCHOPTS+="-Wl,-rpath-link,${MARCHDIR}/lib" \
 ARCHOPTS+="-Wl,-rpath-link,${MARCHDIR}/lib/${RPIARCH}" \
 ARCHOPTS+="-Wl,-rpath-link,${MARCHDIR}/usr/lib/${RPIARCH}/pulseaudio" \
 ARCHOPTS+="-Wl,-rpath-link,${MARCHDIR}/opt/vc/lib" \
 TARGETOS=linux \
 NOASM=1 \
 OVERRIDE_CC="ccache ${MXTOOLS}/bin/${MXTARCH}-gcc" \
 OVERRIDE_LD="${MXTOOLS}/bin/${MXTARCH}-ld" \
 OVERRIDE_CXX="ccache ${MXTOOLS}/bin/${MXTARCH}-c++" \
 -j${MAMECOMPILECORES}

echo "Compressing..."
7za a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=128m -ms=on -mmt=on "${MDIR}/build/mame_rpi_${MAMEVER}_armhf.7z" \
 artwork \
 bgfx \
 castool \
 chdman \
 ctrlr \
 docs \
 floptool \
 hash \
 hlsl \
 imgtool \
 ini \
 jedutil \
 keymaps \
 language \
 ldresample \
 ldverify \
 mame \
 nltool \
 nlwav \
 plugins \
 pngcmp \
 regrep \
 romcmp \
 roms \
 samples \
 split \
 srcclean \
 testkeys \
 unidasm \
 web \

