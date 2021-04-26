--===========================================================================
--
--                   HD63C09 SBC II Seven Segement Driver
--
--===========================================================================
--
--  File name      : seven_seg.vhd
--
--  Entity name    : seven_seg
--
--  Purpose        : Implements a CPU-accessible hexadecimal LED display
--                   on the QMTECH mainboard
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
--  Description    : 
--
--  License        : This is free and unencumbered software released into the public domain.
--                   
--                   Anyone is free to copy, modify, publish, use, compile, sell, or
--                   distribute this software, either in source code form or as a compiled
--                   binary, for any purpose, commercial or non-commercial, and by any
--                   means.
--                   
--                   For more information, please refer to <http://unlicense.org/>
--
--===========================================================================--
--                              Revision  History                            --
--===========================================================================--
--
-- Version    Date         Author           Changes
--
--  0.1       04-23-2021   Tom LeMense      Initial version

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity seven_seg is
	port(   reset : in std_logic;		-- global reset (active high)
            clk : in std_logic;         -- 50 MHz master clock 
            wr : in std_logic;          -- register write enable
            data_i : in std_logic_vector(7 downto 0);   -- input data from CPU
            data_q : out std_logic_vector(7 downto 0);  -- output data to CPU
            digit_h : out std_logic;   -- digit anode drivers
				digit_l : out std_logic;
            segment : out std_logic_vector(7 downto 0)  -- segmenet cathode drivers
		);
end seven_seg;

architecture behavioral of seven_seg is
   signal mux : std_logic;                              -- which digit to display
   signal encode : std_logic_vector(3 downto 0);        -- nybble value to encode
   signal segs : std_logic_vector(6 downto 0);          -- encoded segment output
	signal store : std_logic_vector(7 downto 0);         -- hold register for stored value
begin
   
   -- create the 'digit' signal for multiplexed display on order of 50Hz
   process(clk)
      variable cnt : integer range 0 to 500000;
   begin
      if reset = '1' then
         cnt := 0;
      elsif rising_edge(clk) then
         if cnt = 500000 then
            cnt := 0;
            mux <= not mux;
         else
            cnt := cnt + 1;
         end if;
      end if;
   end process;
   
   -- a sismple read-write register to store value to display in hex
   process(clk,wr,data_i)
	begin
      if reset = '1' then
         store <= x"00";
      elsif rising_edge(clk) then
         if wr = '1' then
            store <= data_i;
         end if;
		end if;
   end process;

   data_q <= store;	
	
   -- route the appropriate nybble to the hex encoder
   encode <= store(7 downto 4) when mux = '1' else store(3 downto 0);
   
   -- drive the segement lines based upon value of 'encoder'
   process(encode)
   begin
      case encode is  -- .gfedcba
      when x"1" => segs <= "1111001"; 
      when x"2" => segs <= "0100100"; 
      when x"3" => segs <= "0110000"; 
      when x"4" => segs <= "0011001"; 
      when x"5" => segs <= "0010010"; 
      when x"6" => segs <= "0000010"; 
      when x"7" => segs <= "1111000"; 
      when x"8" => segs <= "0000000"; 
      when x"9" => segs <= "0010000"; 
      when x"A" => segs <= "0001000"; 
      when x"B" => segs <= "0000011"; 
      when x"C" => segs <= "1000110"; 
      when x"D" => segs <= "0100001"; 
      when x"E" => segs <= "0000110"; 
      when x"F" => segs <= "0001110"; 
      when others => segs <= "1000000"; 
      end case;
   end process;

   -- drive the digit lines based upon value of 'mux'
   digit_h <= mux;
   digit_l <= not mux;   
   
   -- drive the segment lines based upon value of 'segs'
   segment(6 downto 0) <= segs;
   segment(7) <= '1';
   
end behavioral;