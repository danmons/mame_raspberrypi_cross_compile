#!/bin/bash
cd ~/src/mame
7za a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=128m -ms=on -mmt=on mame.7z \
 mame \
 artwork \
 bgfx \
 ctrlr \
 docs \
 hash \
 hlsl \
 ini \
 keymaps \
 language \
 plugins \
 roms \
 samples \
 web \
