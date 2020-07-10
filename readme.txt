
This information pertains to the HD6309 Singleboard Computer v2.0

The HD6309 SBC II is a retroputing distraction, motivated by the fun I had designing
and using my first HD6309 SBC project. This time around, I favored 'all mod cons' over
'old skool'. In contrast to the v1.0, this version loses the Zilog SCC and Zilog CIO
devices, expands RAM to 256KB and addressable ROM to 64K. The SD card interface is
retained, as is the more up-to-date I2C realtime clock. The heart of this SBC is an
Altera MAX10 CPLD, in which all of the glue logic and peripherals are implemented.
The MAX10 I chose has 4K Logic Elements (LE) which is equivalent to approx 3000 
Macrocells (MC). For reference, the v1.0 SBC has a 128 MC device. So, with approx
25x more logic capacity, I can implement two UARTs, the SPI master, a more friendly
I2C master, a paged memory mapper, and whatever else springs to mind...  The 
'penalty' for this luxury is that of mixed voltage design - the CPU, RAM and FLASH 
are all in a 5V domain, whereas the CPLD, oscillator, SD card, and USB bridge chip 
are in a 3.3V domain. So, along with a 3.3V LDO, four octal transceivers are present 
to shift the TTL signalling to LV-TTL. Sure, I could have gone for a larger CPLD
or FPGA and put the CPU core in there, but no CPU just seems a bit like 'cheating'.
LOL, to each their own :-)  The SBC v2 is also physically smaller than its v1.0 
predecessor; measures 100 x 120mm.

A long-term goal is to make a companion card that mates with the stacking 'expansion 
port' connector and provides up to 2MB of memory, some sort of video display, and 
a keyboard interface.

Firmware wise, I'll keep the rudimentary monitor, NoICE support, and the ROM-resident 
6809 MICROSOFT BASIC interpreter which I implemented on v1.0 (the latter is courtesty 
of Grant Searle). 

More up-to-date information on the SBC can be found on the Hackaday project page:
https://hackaday.io/project/173401-hd6309-singleboard-computer-ii

This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.

HD6309 Singleboard Computer II
Tom LeMense
7/10/2020

tomcircuit@gmail.com
@TomLeMense

		
