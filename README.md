# Cross compile MAME for Raspberry Pi on an x86_64 host

Full guide is here: [https://stickfreaks.com/misc/cross-compile-mame-for-raspberry-pi](https://stickfreaks.com/misc/cross-compile-mame-for-raspberry-pi)

This repo will host the files needed.

Compiling MAME on a Raspberry Pi, even a new Model 4 with 8GB RAM, can be tough.  Compiles can take many hours, and especially when compiling for 64bit can exceed the 8GB RAM of a new RPi4 when using `-j4`, causing either swap thrashing or forcing the user to drop the concurrent compile jobs, slowing things down either way.

Cross compiling allows the user to compile on a much faster x86_64 host, but still produce binaries that work on a Raspberry Pi.
