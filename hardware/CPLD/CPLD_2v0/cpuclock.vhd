--===========================================================================
--
--                   HD63C09 Quadrature Clock Generator
--
--===========================================================================
--
--  File name      : cpuclock.vhd
--
--  Entity name    : cpuclock
--
--  Purpose        : Quadrature clock generation for HD63C09E CPU,
--                   and some helpful timing strobes for SRAM and CPLD
--                   access.
--                  
--  Dependencies   : ieee.std_logic_1164
--                   ieee.std_logic_unsigned
--
--  Author         : Tom LeMense
--
--  Email          : tomcircuit@gmail.com
--
--  Web            : 
--
--  Description    : The target ECLK frequency is 3.125 MHz, and the assumed XOSC clock frequency
--                   is 50 MHz. One ECLK cycle is 16 states. During the 16 states, there are some
--                   additional signals required for SRAM control and on-chip peripheral control.
--                   The clock generator outputs the following signals:
--                  
--                   STATE   BIN   ECLK   QCLK  ALAT  CLAT  BUSEN RAMWE IOWE          
--                     0    0000     0      0     0     0     1     0     0           
--                     1    0001     0      0     0     0     1     0     0           
--                     2    0010     0      0     0     0     0     0     0 ***          
--                     3    0011     0      0     0     1     0     0     0           
--                     4    0100     0      1     0     0     0     0     0           
--                     5    0101     0      1     0     0     0     0     0           
--                     6    0110     0      1     0     0     0     0     0           
--                     7    0111     0      1     0     0     0     0     0           
--                     8    1000     1      1     0     0     0     0     0           
--                     9    1001     1      1     1     0     0     0     0           
--                    10    1010     1      1     0     0     0     0     0        
--                    11    1011     1      1     0     0     1     0     0           
--                    12    1100     1      0     0     0     1     0     0           
--                    13    1101     1      0     0     0     1     0     0           
--                    14    1110     1      0     0     0     1     1     0           
--                    15    1111     1      0     0     0     1     1     1           
--
--                   ALAT  : At this time the CPU address, R/W, BS, and BA outputs are 
--                           stable and may be considered by DAT and address decoding logic.
--                           This is also a fine time to update any internal peripheral
--                           output data latches so that they are stable during read
--
--                   CLAT  : At this time the CPU LIC and AVMA outputs are stable and
--                           may be considered for the ongoing cycle. LIC isn't so useful
--                           but AVMA is; when the latched AVMA is high it means that
--                           the CPU will read or write data. The CPU will indicate it
--                           is performing an internal cycle when the latched AVMA is
--                           low. 
--                   
--                   BUSEN : This is when the CPU data bus buffers should be enabled
--                           to connect the CPU data bus to SRAM or CPLD peripherals.
--                           This is also when SRAM CS should be asserted if the current
--                           cycle involves SRAM access (which is known after ALAT).
--                           This is also when SRAM OE should be asserted if the current
--                           cycle is a READ cycle (which is know after ALAT).
--                           (it might be helpful to consider this as a "delayed E" signal)
--                   
--                   RAMWE : This is when the SRAM WE should be asserted if the current             
--                           cycle is an SRAM WRITE cycle (which is known after ALAT).
--                   
--                   IOWE  : This is when the CPLD peripheral write (load) should occur
--                           if the current cycle is CPLD peripheral WRITE cycle (which 
--                           is known after ALAT).
--                   
--                   *** to support 6309 block transfer mode SPI transactions, the clock 
--                   can be held at state 2 while the 'wait2' input is high. 
--
--  License        : This is free and unencumbered software released into the public domain.
--                   
--                   Anyone is free to copy, modify, publish, use, compile, sell, or
--                   distribute this software, either in source code form or as a compiled
--                   binary, for any purpose, commercial or non-commercial, and by any
--                   means.
--
--===========================================================================--
--                              Revision  History                            --
--===========================================================================--
--
-- Version    Date         Author           Changes
--
--  0.1       04-22-2021   Tom LeMense      Initial version
--  0.2       04-23-2021   Tom LeMense      Added CLAT, removed HOLD, added WAIT2

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity cpuclock is
		port(	clk   : in std_logic;		-- 50M oscillator input
                wait2 : in std_logic;       -- pause the clock gen while high
				eclk  : out std_logic;		-- 3.125M E quadrature clock output
				qclk  : out std_logic;		-- 3.125M Q quadrature clock output
                alat  : out std_logic;      -- address, BA, BS, RW latch enable
                clat  : out std_logic;      -- LIC and AVMA latch enable
                busen : out std_logic;      -- data bus enable signal (delayed E)
                memwe : out std_logic;      -- gating signal for CPU writes to external memory
                iowe  : out std_logic       -- gating signal for CPU writes to peripherals
		);
end cpuclock;

architecture behavior of cpuclock is
   signal clock_state : integer range 0 to 15;

begin
   process(clk,wait2)
      variable cnt : integer range 0 to 15;
   begin
      if rising_edge(clk) then
         if (wait2 = '1' and cnt = 2) then
            cnt := 2;
         else
            cnt := cnt + 1;
         end if;
      end if;
      clock_state <= cnt;
   end process;

   eclk <= '1' when (clock_state > 7) else '0';	
   qclk <= '1' when (clock_state > 3 and clock_state < 12) else '0';
   alat <= '1' when (clock_state = 9) else '0';
   clat <= '1' when (clock_state = 3) else '0';   
   busen <= '1' when (clock_state < 2 or clock_state > 10) else '0';
   memwe <= '1' when (clock_state > 13) else '0';
   iowe <= '1' when (clock_state = 15) else '0';

end behavior;		

