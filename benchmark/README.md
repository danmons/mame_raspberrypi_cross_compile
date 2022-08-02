# MAME Benchmarking on Raspberry Pi

## About

These are scripts I use to periodically benchmark MAME on Raspberry Pi (and maybe other SBC hardware in the future).  Write ups are here:
* https://stickfreaks.com/misc/raspberry-pi-mame-benchmarks

These should work on any POSIX system - you shoult be able to run them on any Linux or macOS system as well (not tested - submit an issue if they don't). 

There are three lists provided.  The first is copied from John IV, MAMEUI author, who has been consistently benchmarking MAME over various releases and hardware for a long time, and has an excellent collection of modern and historic results and data here:
* http://www.mameui.info/Bench.htm

The second is the BYOAC Forums "All Killer, No Filler" list of games, which I've trimmed a little to remove some of the games that are just not possible on RPi3 and RPi4 era hardware, but hopefully still demonstrates some of the games that most people are interested in running. (If you have one you'd like added, submit an issue and I'll throw it in). 
* http://forum.arcadecontrols.com/index.php?topic=149708.0

The third is a much smaller list of "classic" games for RPi2 era hardware.  This hardware is grossly underpowered compared to RPi3 and RPi4 era hardware, and as such not only takes a long time ot benchmark, but just isn't realistic for a great amount of modern titles.  As such, a more sensible list of older titles has been chosen to demonstrate what does and does not work on that older platform. These can also then be run on RPi3 and RPi4 hardware to demonstrate the generational improvements of the platform. 

## Interpreting the results

MAME includes an internal benchmark, accessed by the `-bench` command line argument, along with a number of game-time seconds to run (90 is chosen to give a game enough time to loop through a demo a few times, and also to match up with John IV's initial benchmarks to allow "apples to apples" comparisons).  This runs a game with no video or sound output (these are calculated internally, but not sent to video/audio hardware in the system).  This is done purely as a CPU benchmark to isolate all hardware limits. 

What this means is that real world maximum framerates can be less than the benchmarks provided.  For example, at time of writing, the Rasbperry Pi struggles to draw more than about 120 frames per second of ANYTHING, due to internal hardware and bandwidth limits.  So a game may well run several times faster than this with no graphical output, but be bottlenecked by the RPi's video hardware.  THIS IS NOT A PROBLEM. All this means is that the minimum framerate for a given game can be achieved, and in real world scenarios the game will run fine.

Because of the huge diversity of games and harware MAME emulates, the benchmark is expressed as a percentage. For example, "200%" for the game `sf2` means it runs at an average speed of twice the native 59.637405Hz, or 119.27481 frames per second.  Conversely "200%" for game `mk` means twice the native 54.70684Hz, or 109.41368 frames per second. Despite the nearly 10 frames per second difference, both games score "200%".  

This is an average, with high and low frame rates not produced.  As such, it's recommended by me (and I don't speak on behalf of MAMEdev nor anyone else) to aim for around 200% as a minimum number to guarantee that a title runs with minimal frame drops on a given hardware system.  This compensates enough for peaks and troughs in the frame average, as well as leaving some CPU overhead for audio/video/input/etc. 

Playing games with less than 200% scores may (although is not guaranteed to) require frameskipping in order to maintain game pace, or without frame skipping cause stuttering. That will depend highly on the individual game, and is recommended only as general guidance. 

## NVRAM and game configuration overwrite warning:

Several of the games require an emulated system's NVRAM to be pre-populated (otherwise games tend to boot in "first boot" mode, and give a false benchmark reading).  These are listed in `lists/nvram.txt`. For the handful of titles that do require this, the binary NVRAM cache is provided in this repo, and overwrites the files in the `cfg` and `nvram` folders.  If you have existing NVRAM/cfg files that you want to keep, please back these up first.

## Running the benchmarks for yourself

This is tested and working on Raspberry Pi OS Buster for RPi2 hardware, and Bullseye for RPi3 and RPi4 hardware.  Other distros may work but are untested.  Ensure you have a working desktop and GUI (MAME requires Xorg and SDL even when benchmarking without graphics). Make the directory `$HOME/games/mame`, download a copy of the MAME binary, which you can get from here:
* https://stickfreaks.com/mame/

And put it in that folder.  Run `./install_prereqs.sh` to install the pre-requisite packages required (including p7zip to decompress the MAME build linked above)

When ready, run the benchmark script with a list you'd like to benchmark.  For example:
```
./benchmark.sh lists/gameslist_johniv.txt
```

These scripts assume: 
* The MAME homepath is `$HOME/games/mame`
* The MAME binary exists in the folder `$HOME/games/mame` and is called `mame` (can be a symlink if required). 
* MAME ROMs can be found in `$HOME/games/mame/roms`
* MAME CHDs can be found in `$HOME/games/mame/chd`
* Game NVRAM contents can be found in `$HOME/games/mame/chd`
* Game configuration settings can be found in `$HOME/games/mame/cfg`

You can modify this by editing the MAME_DIR value in `config.ini`.

From there, the script runs through the given attempting to benchmark each game.  If an existing benchmark output is found in the `log` directory with an Average FPS score, the game is skipped.  To rebenchmark, simply delete the output file and re-run the script.

## Creating CSV output

Once all benchmarks are complete, run the create_csv script with your list of choice as an argument, for example:
```
./create_csv.sh lists/gameslist_johniv.txt
```

This will create a `results.csv` in the `results` folder (renaming an existing CSV file if it exists), which you can then open up in any spreadsheet tool you like. 
