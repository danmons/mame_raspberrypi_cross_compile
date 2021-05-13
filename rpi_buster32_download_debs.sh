#!/bin/bash
sudo apt-get clean
sudo apt-get update
mkdir -p ~/armhf/debs
cd ~/armhf/debs
apt-get download -y \
apulse libasound2 libasound2-dev libasyncns0 libbrotli1 libbsd0 libcap2 \
libcom-err2 libdbus-1-3 libdouble-conversion1 libdrm2 libexpat1 libffi6 \
libflac8 libfontconfig1 libfontconfig1-dev libfreetype6 libfreetype6-dev \
libgbm1 libgbm-dev libgcrypt20 libgl1 libgl-dev libgles1 libgles2 libgles2-mesa \
libglew2.1 libglib2.0-0 libglib2.0-dev libglu1-mesa libglvnd0 libglx0 \
libglx-dev libglx-mesa0 libgpg-error0 libgraphite2-3 libgssapi-krb5-2 \
libharfbuzz0b libice6 libicu63 libk5crypto3 libkeyutils1 libkrb5-3 \
libkrb5support0 liblz4-1 liblzma5 libmd0 libogg0 libopus0 libpcre2-16-0 \
libpcre3 libpng16-16 libpulse0 libqt5core5a libqt5gui5 libqt5widgets5 \
libraspberrypi0 libraspberrypi-bin libraspberrypi-dev libsdl1.2debian \
libsdl2-2.0-0 libsdl2-dev libsdl2-ttf-2.0-0 libsdl2-ttf-dev libsdl-image1.2 \
libsdl-mixer1.2 libsdl-ttf2.0-0 libsm6 libsndfile1 libsndio7.0 libsystemd0 \
libtirpc3 libuuid1 libvorbis0a libvorbisenc2 libwayland-client0 \
libwayland-cursor0 libwayland-egl1 libwayland-server0 libwrap0 libx11-6 \
libx11-data libx11-dev libx11-xcb1 libx264-155 libx265-165 libxau6 libxau-dev \
libxaw7 libxcb1 libxcb1-dev libxcb-composite0 libxcb-dri2-0 libxcb-dri3-0 \
libxcb-glx0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-present0 \
libxcb-randr0 libxcb-render0 libxcb-render-util0 libxcb-shape0 libxcb-shm0 \
libxcb-sync1 libxcb-util0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xinput0 \
libxcb-xkb1 libxcb-xv0 libxcomposite1 libxcursor1 libxcursor-dev libxdamage1 \
libxdmcp6 libxdmcp-dev libxext6 libxext-dev libxfconf-0-2 libxfixes3 \
libxfixes-dev libxfont2 libxft2 libxi6 libxi-dev libxinerama1 libxinerama-dev \
libxkbcommon0 libxkbcommon-dev libxkbcommon-x11-0 libxkbfile1 libxklavier16 \
libxml2 libxmu6 libxmuu1 libxpm4 libxrandr2 libxrandr-dev libxrender1 \
libxrender-dev libxres1 libxshmfence1 libxslt1.1 libxss1 libxss-dev libxt6 \
libxtables12 libxt-dev libxtst6 libxv1 libxv-dev libxvidcore4 libxxf86dga1 \
libxxf86vm1 libxxf86vm-dev libxxhash0 libzadc4 libzstd1 qtbase5-dev \
x11proto-dev zlib1g 
