# Cross compile MAME for Raspberry Pi on an x86_64 host

## About

The [MAME project](https://github.com/mamedev/mame) now runs quite well on Raspberry 4 hardware running 64bit Raspberry Pi OS (itself a derivative of Debian).  See benchmarks here:
* https://stickfreaks.com/misc/raspberry-pi-mame-benchmarks

Compiling MAME on a Raspberry Pi 4, even with the largest 8GB RAM model available, can take a very long time.  The biggest issue being RAM limitations, as running `make -j4` can consume far more than 8GB RAM, causing the Pi to swap and crawl to a halt.  Compiling with `make -j2` works around this, but is slow.  Compiling on a much faster x86_64 machine with lots of RAM is much more convienent.

This project uses [crosstool-NG](https://github.com/crosstool-ng/crosstool-ng) to build 2 cross-compilation environments, and allow easy building of the latest MAME binaries on a fast x86_64 machine.

## MAME forks supported

This project supports building the following versions of MAME:

* MAME - the main upstream project
  * https://github.com/mamedev/mame
* GroovyMAME - a fork of MAME that also offers
  * low resolution CRT support for arcade CRT monitors
  * SwitchRes - dynamic modeline creator tool to help with creating modelines for old CRTs
  * Groovy_MiSTer - low latency streaming of video from GroovyMAME running on a powerful PC to your MiSTer FPGA device connected to a low resolution CRT
  * https://github.com/antonioginer/GroovyMAME

## Installation

* Requires an "APT" based Linux distro, or APT/dpkg tools to exist in the system.
* This is tested and working on Ubuntu 24.04 LTS, but probably works on Debian/Mint/Pop_OS/etc.  Create an issue if you find one that doesn't. 
* You can run this on non-Debian/Ubuntu distros if `apt` and `dpkg` tools are installed.  Tested and working on Arch Linux. 
* Clone the project:
```
sudo apt install -y git
git clone https://github.com/danmons/mame_raspberrypi_cross_compile.git
cd mame_raspberrypi_cross_compile
```
* Install the pre-requisite packages to build crosstool-NG. An example script is provided for APT/dpkg based distros. Similar tools will be needed for other distros:
```
./install_prereqs.sh
```
* The `mame-cross-compile.sh` script contains the phases needed to download libraries, prepare the build system, and compile MAME

## Options

`mame-cross-compile.sh` command line arguments:

Mandatory arguments:

* `-o` : the operation to choose.  Must be one of:
  * `download` : Download libraries and headers to be used during compiling and linking
  * `prepare` : Prepare the Crosstool-NG environment
  * `compile` : Compile your chosen MAME version/fork
* `-r` : Debian release to target for comaptibilit.  Must be one of:
  * `10` or `buster` , with gcc 8 and glibc 2.28 (currently not working, as MAME requires gcc 10.3 minimum)
  * `11` or `bullseye` , with gcc 10 and glibc 2.31
  * `12` or `bookworm` , with gcc 12 and glibc 2.36
* `-a` : the architecture to target.  Must be noe of:
  * `arm`, `armhf` or `arm32` -  32bit ARM with hardfloa (older ARM processors without hardware floating point are not supported)
  * `arm64` or `aarch64` - 64bit ARM

Optional arguments:

* `-f` : The MAME fork to target. Can be one of
  * `mame` - default
  * `groovymame`
* `-v` : The version of MAME to target.  Can be one of:
  * `latest` - default
  * A version number, such as `0.123` (note that old versions may not compile correctly, as this script targets the current version always)
* `-c` : The number of CPUs to use for parallel compilation.  Note that compiling MAME is very RAM intensive, and a high CPU count may cause your machine to swap thrash and/or OOM. By default, CPU counts chose are:
  * 4 GB RAM = 1 CPU
  * 8 GB RAM = 2 CPUs
  * 16 GB RAM = 4 CPUs
  * 32+ GB RAM = all available CPUs (tested on a 96 CPU machine)
* `-h` : Print detailed help. 

## Example usage

To download necessary libraries, prepare the cross compile environments, and compile the latst version of MAME to run on a 64bit Raspberry Pi 3/4/5 or Orange Pi 5B running a very recent Debian or Ubuntu distro, you could run:

```
# Download libraries
./mame-cross-compile.sh -o download -r 12 -a arm64
# Prepare the crosstool-ng environment
./mame-cross-compile.sh -o prepare -r 12 -a arm64
# Compile MAME
./mame-cross-compile.sh -o compile -r 12 -a arm64
```

If all goes well, a file named something like `mame_0.123_debian_12_bookworm_arm64.7z` should appear in the `build/output` folder, and can be decompressed and run on a matching 64bit ARM system and distro. 

## Running MAME

Copy the .7z file over to your RPi (or other ARM board), decompress and run it.  See the official [MAME Documentation](https://docs.mamedev.org/) for further instructions. 

You may need to install some extra packages/libraies on your RPi for this to work.  I recommend:
```
sudo apt install -y libfreetype6 libsdl2-ttf-2.0-0 libsdl2-2.0-0 libqt5widgets5 libqt5gui5 libgl1
```

If you're not interested in compiling these, I build and release them shortly after ever mainline MAME update.  Pre-build versions are here:
* https://stickfreaks.com/mame/

## Compile speed

crosstool-NG can take a while to compile - 30 minutes to an hour per environment (2 environments built, one for 32bit, one for 64bit).  However this only needs to be done once to create the build environment. For future versions of MAME, you can keep the existing environment.

MAME's compile time depends on how many cores you assign to the compiler. Be warned that this can consume quite a lot of RAM.  It's recommended to install a tool like [htop](https://htop.dev) (`sudo apt install -y htop`) and monitor this as the compile runs.  Watch the `Mem` (Memory/RAM) row, and if the green bar consumes 100%, and the `Swp` (Swap, or on-disk virtual memory swap) begins to grow rapidly, cancel the compile job immediately with Control+C. 

In general, a little over 2GB per core is recommended, although that calculation is not linear due to 4-5 certain compile tasks taking lots of RAM, and many of the others being quite light.  In my experiments a 4 core job needed 10GB of RAM and compiled in about 90 minutes, however a 10 core job ran well on 14GB of RAM and compiled in about 45 minutes.  Results will vary for your exact hardware configuration and CPU type/generation. 

## Windows + WSL

This project is tested and working on Windows 10/11 running WSL2 and the "Ubuntu-20.04" WSL environment (itself a convenient virtual machine environment running within Windows).

By default WSL will allow a VM to see all logical processors, however it will cap the VM to 50% of the system's physical memory.  To change this, stop all runnig VMs by running `wsl --shutdown` within `cmd.exe` (not from within a WSL VM).  The navigate to `%UserProfile%` (usually `c:\Users\<username>`) and create/edit the file `.wslconfig`.  Note this file is prefixed by a period ('.') and has no extension.  Within it, add/modify the following section:

```
[wsl2]
memory=14GB
```

I recommend making this number your system RAM minus 2GB (the above example is used on my 16GB RAM laptop). Note the  [Compile speed section](#Compile-speed) section above, and in particular how to monitor your RAM so that you don't swap thrash and kill both your performance and hard disk.
