--===========================================================================
--
--                   HD63C09 SBC II "phase 0" address decoder
--
--===========================================================================
--
--  File name      : decode_ph0.vhd
--
--  Entity name    : decode
--
--  Purpose        : Implements a trivial address decoding required by the
--                   "phase 0" HD6309 SBC II testboard.
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
--  Description    : "RAM" at $0000...$03FF
--                   "ROM" at $FC00...$FFFF
--                   "IO" at $E000
--                   "BTN" at $E001
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
--  0.1       04-22-2021   Tom LeMense      Initial version

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity decode is
	port(   reset : in std_logic;		-- global reset (active high)
			addr : in std_logic_vector(15 downto 0);  -- CPU address bus
            busen : in std_logic;       -- bus enable signal
			romsel : out std_logic;		-- ROM select
			ramsel : out std_logic;		-- RAM select
			iosel : out std_logic	    -- IO select
		);
end decode;

architecture behavioral of decode is
begin
   ramsel <= '1' when (reset = '0' and busen = '1' and addr(15 downto 10) = "000000") else '0';
   romsel <= '1' when (reset = '0' and busen = '1' and addr(15 downto 10) = "111111") else '0';
   iosel <= '1' when (reset = '0' and busen = '1' and addr(15 downto 8) = "11100000") else '0';
end behavioral;		



