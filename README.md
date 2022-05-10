# Cross compile MAME for Raspberry Pi on an x86_64 host

## About

The [MAME project](https://github.com/mamedev/mame) now runs quite well on Raspberry 4 hardware running 64bit Raspberry Pi OS (itself a derivative of Debian).  See benchmarks here:
* https://stickfreaks.com/misc/raspberry-pi-mame-benchmarks

Compiling MAME on a Raspberry Pi 4, even with the largest 8GB RAM model available, can take a very long time.  The biggest issue being RAM limitations, as running `make -j4` can consume far more than 8GB RAM, causing the Pi to swap and crawl to a halt.  Compiling with `make -j2` works around this, but is slow.  Compiling on a much faster x86_64 machine with lots of RAM is much more convienent.

This project uses [crosstool-NG](https://github.com/crosstool-ng/crosstool-ng) to build 2 cross-compilation environments, and allow easy building of the latest MAME binaries on a fast x86_64 machine.

## Install and use

* Requires an "APT" based distro, or APT/dpkg tools to exist in the system.
* This is tested and working on Ubuntu 20.04 LTS, but probably works on Debian/Mint/Pop_OS/etc.  Create an issue if you find one that doesn't. 
* Clone the project:
```
sudo apt install -y git
git clone https://github.com/danmons/mame_raspberrypi_cross_compile.git
cd mame_raspberrypi_cross_compile
```
* Install the pre-requisite packages to build crosstool-NG:
```
./install_prereqs.sh
```
* Build the crosstool-NG environments (2 will be created - one for RPiOS 32bit armhf, one for RPiOS 64bit arm64/aarch64):
```
./build_crosstool-ng.sh
```
* Edit `conf/settings.ini` to change your Debian/RaspberryPiOS mirrors if you need faster/closer ones.
* Install the RPiOS libraries, headers, includes and other necessary files to build and link MAME:
```
./download_libs.sh
```
* Edit `conf/settings.ini` and change the `MAMECOMPILECORES` varable for the number of parallel MAME compile jobs (see the [Compile speed section](#Compile-speed) below for RAM usage warnings).
* Build MAME for RPiOS 64bit (recommended - see benchmarks in the [About Section](#About)):
```
./build_mame_aarch64.sh
```
* Build MAME for RPiOS 32bit
```
./build_mame_armhf.sh
```

If all goes well, within the `build` directory there will be a 7-Zipped compressed file with MAME and its necessary support files included.  By default these scripts compile the latest stable release of MAME.

## Running MAME

Copy the .7z file over to your RPi, decompress and run it.  See the official [MAME Documentation](https://docs.mamedev.org/) for further instructions. 

You may need to install some extra packages/libraies on your RPi for this to work.  I recommend:
```
sudo apt install -y libfreetype6 libsdl2-ttf-2.0-0 libsdl2-2.0-0 libqt5widgets5 libqt5gui5 libgl1
```

If you're not interested in compiling these, I build and release them shortly after ever mainline MAME update.  Pre-build versions are here:
* https://stickfreaks.com/mame/

## Compile speed

crosstool-NG can take a while to compile - 30 minutes to an hour per environment (2 environments built, one for 32bit, one for 64bit).  However this only needs to be done once to create the build environment. For future versions of MAME, you can keep the existined environment.

MAME's compile time depends on how many cores you assign to the compiler (edit `conf/settings.ini` and change the `MAMECOMPILECORES` value).  Be warned that this can consume quite a lot of RAM.  It's recommended to install a tool like HTOP (`sudo apt install -y htop`) and monitor this as the compile runs.  Watch the `Mem` (Memory/RAM) row, and if the green bar consumes 100%, and the `Swp` (Swap, or on-disk virtual memory swap) begins to grow rapidly, cancel the compile job immediately with Control+C. 

In general, a little over 2GB per core is recommended, although that calculation is not linear due to 4-5 certain compile tasks taking lots of RAM, and many of the others being quite light.  In my experiments a 4 core job needed 10GB of RAM, however an 10 core job ran well on 14GB of RAM.

## Windows + WSL

This project is tested and working on Windows 10/11 running WSL2 and the "Ubuntu-20.04" WSL environment (itself a convenient virtual machine environment running within Windows).

By default WSL will allow a VM to see all logical processors, however it will cap the VM to 50% of the system's physical memory.  To change this, stop all runnig VMs by running `wsl --shutdown` within `cmd.exe` (not from within a WSL VM).  The navigate to `%UserProfile%` (usually `c:\Users\<username>`) and create/edit the file `.wslconfig`.  Note this file is prefixed by a period ('.') and has no extension.  Within it, add/modify the following section:

```
[wsl2]
memory=14GB
```

I recommend making this number your system RAM minus 2GB. Note the  [Compile speed section](#Compile-speed) section above, and in particular how to monitor your RAM so that you don't swap thrash and kill both your performance and hard disk.
