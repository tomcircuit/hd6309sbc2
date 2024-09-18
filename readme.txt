
This information pertains to the HD6309 Singleboard Computer v2.0

The HD6309 SBC II is a retroputing distraction, motivated by the fun I had designing
and using my first HD6309 SBC project. This time around, I favored 'all mod cons' over
'old skool'. In contrast to the v1.0, this version loses the Zilog SCC and Zilog CIO
devices, expands RAM to 16MB and addressable ROM to 64K. The SD card interface is
retained, as is the more up-to-date I2C realtime clock. The heart of this SBC is an
Altera Cyclone IV FPGA, in which all of the glue logic and peripherals are implemented.
So, with vastly more logic capacity, easy to do UARTs, the SPI master, a more friendly
I2C master, a paged memory mapper, and whatever else springs to mind...  The 
'penalty' for this luxury is that of mixed voltage design - the CPU and clock signals 
are in a 5V domain, everything else is in the 3.3V domain. A 5V DC/DC supplies the
CPU. Four octal transceivers shift the TTL signalling to LV-TTL. Sure, I could have 
put the CPU core in the FPGA, but no CPU just seems a bit like 'cheating'.
LOL, to each their own :-)  The SBC v2 is also physically smaller than its v1.0 
predecessor; measures 100 x 120mm.

I devised a stacking 64-pin connector scheme so that the FPGA board, the CPU board,
and an I/O board can all be used together. I have also spec'd out a 65C816 CPU board,
and a MC68HC000 board.

Firmware wise, I'll keep the rudimentary monitor, NoICE support, and the ROM-resident 
6809 MICROSOFT BASIC interpreter which I implemented on v1.0 (the latter is courtesty 
of Grant Searle). 

More up-to-date information on the SBC can be found on the Hackaday project page:
https://hackaday.io/project/173401-hd6309-singleboard-computer-ii

This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.

HD6309 Singleboard Computer II
Tom LeMense
9/17/2024

tomcircuit@gmail.com
@TomLeMense

		
