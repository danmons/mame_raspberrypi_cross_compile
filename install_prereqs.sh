#!/bin/bash

echo
echo "Ensure you have both 'deb' and 'deb-src' entries in your"
echo '/etc/apt/sources.list or /etc/apt/sources.list.d/* files'
echo

sleep 3

echo "Syncing APT mirrors..."
sudo apt-get update
echo "Installing build tools..."
sudo apt-get install -y \
 aria2 \
 autoconf \
 automake \
 bison \
 build-essential \
 bzip2 \
 ccache \
 coreutils \
 curl \
 flex \
 g++ \
 gawk \
 gcc \
 git \
 gzip \
 help2man \
 libtool \
 libtool-bin \
 make \
 p7zip \
 p7zip-full \
 rsync \
 texi2html \
 texinfo \
 unzip \
 wget \
 xz-utils \
 zip \
 zstd \


echo "Installing MAME build requirements..."
sudo apt-get build-dep -y mame

if [ "$?" != "0" ]
then
  echo ""
  echo 'If you see errors above, '
  echo 'you are probably missing "deb-src" lines in '
  echo '/etc/apt/sources.list , and '
  echo '/etc/apt/sources.list.d/* files'
  echo ""
  echo 'Add those in by copying all "deb" lines, '
  echo 'replace "deb" with "deb-src" on the newly copied line, '
  echo 'and then re-run this script.'
  echo ""
fi
