# Cross compile MAME for ARM systems like Raspberry Pi on an x86_64 host

## About

The [MAME project](https://github.com/mamedev/mame) now runs quite well on Raspberry 4 and 5 hardware running 64bit Raspberry Pi OS (itself a derivative of Debian) on an ARM CPU.  See benchmarks here:
* https://stickfreaks.com/misc/raspberry-pi-mame-benchmarks

Compiling MAME on a Raspberry Pi 4 or 5, even with the largest 8GB RAM model available, can take a very long time.  The biggest issue being RAM limitations, as running `make -j4` can consume far more than 8GB RAM, causing the Pi to swap and crawl to a halt.  Compiling with `make -j2` works around this, but is slow.  Compiling on a much faster x86_64 machine with lots of RAM is much more convienent.

This project uses [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng) to build cross-compilation environments, and allow easy building of the latest MAME binaries for ARM on a fast x86_64 machine.

## MAME forks supported

This project supports building the following versions of MAME:

* MAME - the main upstream project
  * https://github.com/mamedev/mame
* GroovyMAME - a fork of MAME that also offers
  * low resolution CRT support for arcade CRT monitors
  * SwitchRes - dynamic modeline creator tool to help with creating modelines for old CRTs
  * Groovy_MiSTer - low latency streaming of video from GroovyMAME running on a powerful PC to your MiSTer FPGA device connected to a low resolution CRT
  * https://github.com/antonioginer/GroovyMAME

## Software versions supported

This repo always aims to build the latest stable release of MAME on the latest stable release of Debian Linux . Currently that's Debian 12 Bookworm, released June 2023, with Debian 13 Trixie coming later in 2025. 

Support for older releases of either will come down to what software was provided by those distros, and the build-time and run-time requirements of MAME. 

At time of writing, Debian 11 Bullseye, Debian 12 Bookworm and Debian 13 Trixie environments all build and run the latest stable MAME. 

Debian 10 Buster will only work with up to and including MAME 0.264 (released March 2024).  Versions after this introduced a minimum requirement of SDL 2.0.14 and GCC 10.3, which require substantial manual and unsupported modifications to Debian 10 Buster installs.  Additionally, Debian 10 Buster fell out of direct support from the Debian developers as of September 2022, and out of LTS support by volunteer security developers June 2024.  It is recommended that users upgrade to a more recent distro.  However, the legacy build tools for that system will remain in this repo for the time being, and will likely be removed when Debian 13 Trixie reaches stable release. 

Non-Debian distros will very likely run these builds, as long as their internal software is the same or newer than the Debian versions specified.  For a list of the software versions needed, see [conf/list_ostools.txt](conf/list_ostools.txt). 

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
  * `prepare` : Prepare the crosstool-ng environment
  * `compile` : Compile your chosen MAME version/fork
* `-r` : Debian release to target for compatibility.  Must be one of:
  * `13` or `trixie` , with gcc 14 and glibc 2.41
  * `12` or `bookworm` , with gcc 12 and glibc 2.36
  * `11` or `bullseye` , with gcc 10 and glibc 2.31
  * `10` or `buster` , with gcc 8 and glibc 2.28 (MAME 0.264 or older)
* `-a` : the architecture to target.  Must be one of:
  * `arm`, `armhf` or `arm32` -  32bit ARM with hardfloat/FPU (older ARM processors without a hardware floating point unit are not supported)
  * `arm64` or `aarch64` - 64bit ARM

Optional arguments:

* `-f` : The MAME fork to target. Can be one of:
  * `mame` - default
  * `groovymame`
* `-v` : The version of MAME to target.  Can be one of:
  * `latest` - default
  * A version number, such as `0.123` (note that old versions may not compile correctly, as this script targets the current version always)
* `-c` : The number of CPUs to use for parallel compilation.  Note that compiling MAME is very RAM intensive, and a high CPU count may cause your machine to swap thrash and/or OOM. By default, CPU counts chosen are:
  * 4 GB RAM = 1 CPU
  * 8 GB RAM = 2 CPUs
  * 16 GB RAM = 4 CPUs
  * 32+ GB RAM = all available CPUs (tested on a 96 CPU machine)
* `-h` : Print detailed help. 

## Example usage

To download necessary libraries, prepare the cross compile environments, and compile the latest version of MAME to run on a 64bit Raspberry Pi 3/4/5 or Orange Pi 5B running a very recent Debian or Ubuntu distro, you could run:

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

crosstool-NG can take a while to compile - 30 minutes to an hour per environment.  However this only needs to be done once to create the build environment. For future versions of MAME, you can keep the existing environment.

MAME's compile time depends on how many cores you assign to the compiler. Be warned that this can consume quite a lot of RAM.  It's recommended to install a tool like [htop](https://htop.dev) (`sudo apt install -y htop`) and monitor this as the compile runs.  Watch the `Mem` (Memory/RAM) row, and if the green bar consumes 100%, and the `Swp` (Swap, or on-disk virtual memory swap) begins to grow rapidly, cancel the compile job immediately with Control+C. 

In general, a little over 2GB per core is recommended, although that calculation is not linear due to 4-5 certain compile tasks taking lots of RAM, and many of the others being quite light.  In my experiments a 4 core job needed 10GB of RAM and compiled in about 90 minutes, however a 10 core job ran well on 14GB of RAM and compiled in about 45 minutes.  Results will vary for your exact hardware configuration and CPU type/generation. 

## Windows + WSL2

This project is tested and working on Windows 10/11 running WSL2 and the "Ubuntu-24.04" WSL2 environment (itself a convenient virtual machine environment running within Windows).

By default WSL2 will allow a VM to see all logical processors, however it will cap the VM to 50% of the system's physical memory.  To change this, stop all runnig VMs by running `wsl --shutdown` within `cmd.exe` (not from within a WSL VM).  The navigate to `%UserProfile%` (usually `c:\Users\<username>`) and create/edit the file `.wslconfig`.  Note this file is prefixed by a period ('.') and has no extension.  Within it, add/modify the following section:

```
[wsl2]
memory=14GB
```

I recommend making this number your system RAM minus 2GB (the above example is used on my 16GB RAM laptop). Note the  [Compile speed section](#Compile-speed) section above, and in particular how to monitor your RAM so that you don't swap thrash and kill both your performance and hard disk.

## What version of MAME should I run? 

The latest version of MAME is always the best version of MAME.  There has been a pervasive Internet rumour floating around for years that "older versions of MAME are faster", seemingly stemming from [nearly 20 year old builds where 32bit internal rendering was added](https://aarongiles.com/old/?p=208), which impacted ancient computers and operating systems of the day.  In 2006 the best CPUs you could buy were single-core 32bit AMD and Intel chips ranging from around 1.5GHz up to 3GHz, albeit with the Pentium 4 "Netburst" architecture which was horribly slow.  Today, a current gen Raspberry Pi 5 or Orange Pi 5 is faster, and almost all GPUs on the market now render in full colour ranges internally regardless of what old versions of software request. 

MAME continues to see considerable improvements in speed, accuracy and quality, and running ancient builds is never recommended.  For example, see [here in MAME 0.231 in 2021 where a critical game logic bug in the well known "Contra" arcade version was fixed that dramatically changes gameplay in certain sections](https://www.youtube.com/watch?v=awHTp6hYXcI&t=266s).  MAME 0.245 improved the performance of Cave (famous Japanese shmup developer) games by around 20%. 0.254 greatly improved accuracy of Cave titles even further.  MAME 0.275 added drc / dynarec / Dynamic Recompilation backends for aarch64/arm64 CPUs, which dramatically speeds up emulated hardware like MIPS and SH2 (almost a 300% improvement to games like Street Fighter III: Third Strike when running on 64bit ARM CPUs). You will miss out on all of that if you run old versions of MAME. 

Going backwards to ancient versions of MAME to seek performance improvements rarely works as people expect.  Generally speaking it causes endless heartache trying to find older ROM sets, or people find that older builds introduce bugs that were fixed later on, or their favourite games are missing entirely. 
