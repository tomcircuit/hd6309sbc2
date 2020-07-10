-- I2C Master controller
-- Copyright Enoch Hwang 2008

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY I2C_controller IS
PORT (
	CLK_50_MHz, ResetN: IN STD_LOGIC;
	--RTC/I2C control signals
	SCL: OUT STD_LOGIC;
	SDA: INOUT STD_LOGIC;
	--User interface data signals
	Read_WriteN: IN STD_LOGIC;
	DataIn, AddressIn: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	Ack: OUT STD_LOGIC;
	DataOut: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	StateOut: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	RegisterAddressOut: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END I2C_controller;

ARCHITECTURE FSMD OF I2C_controller IS
	SIGNAL state: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL RegisterAddress: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Data: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SDA01: STD_LOGIC;	-- internal SDA having values of 0 and 1
	
	SIGNAL bitcount: INTEGER RANGE 0 TO 7;
	CONSTANT SlaveAddress_Read: STD_LOGIC_VECTOR(7 DOWNTO 0) := "1101000"&'1';	-- I2C address of the slave + read
	CONSTANT SlaveAddress_Write: STD_LOGIC_VECTOR(7 DOWNTO 0) := "1101000"&'0';	-- I2C address of the slave + write'
	CONSTANT NumberOfRegisters: STD_LOGIC_VECTOR(7 DOWNTO 0) := x"1F";	-- total number of registers in the slave
	
	-- constants for 200kHz clock divider
	CONSTANT max200k: INTEGER := 50000000/(100000*2);	-- to get 100kHz for I2C standard; every 2 cycles = 1 I2C cycle
--	CONSTANT max200k: INTEGER := 50000000/4;	-- for some I2C slaves (Maxim DS1375 RTC) the actual clock speed can be any speed less than the max I2C clock speed
	-- some I2C slaves (Maxim DS3232 RTC) requires a minimum SCL rate, so when this clock is too slow, the slave will reset the I2C interface
	SIGNAL clockticks200k: INTEGER RANGE 0 TO max200k;
	SIGNAL CLK_200k_Hz: STD_LOGIC;
	
BEGIN

	StateOut <= state;
	
	-- SDA line is open drain that is pulled up with a resistor
	-- therefore, to set SDA to a 1 we need to output a Z value
	-- SDA is changed only when SCL is low except for sending the start and stop bits
	-- i.e. SDA is valid at the rising edge of the SCL (clock)
	SDA <= 'Z' WHEN SDA01 = '1' ELSE '0';	-- convert SDA 0/1 to 0/Z

	output: PROCESS(CLK_200k_Hz, ResetN)
	BEGIN
		IF(ResetN = '0') THEN
			-- when idle, both SDA and SCL = 1
			SCL <= '1';
			SDA01 <= '1';
			Ack <= '0';
			DataOut <= "00000000";
			RegisterAddress <= x"FF";
			state <= x"00";
		ELSIF(CLK_200k_Hz'EVENT and CLK_200k_Hz = '1') THEN
			CASE state IS
			WHEN x"00" =>	-- Idle
				-- when idle, both SDA and SCL = 1
				SCL <= '1';		-- SCL = 1
				SDA01 <= '1';	-- SDA = 1
				RegisterAddressOut <= RegisterAddress;
				DataOut <= "00000000";
				state <= x"01";
				
----------------------------------------------------------------				
-- send start condition and slave address
			WHEN x"01" =>	-- Start
				SCL <= '1';		-- SCL stays at 1 while
				SDA01 <= '0';	-- SDA changes from 1 to 0
				bitcount <= 7;	-- starting bit count
				state <= x"02";
			-- send 7-bit slave address followed by R/W' bit, MSB first
			WHEN x"02" =>					
				SCL <= '0';
				SDA01 <= SlaveAddress_Write(bitcount);
				state <= x"03";
			WHEN x"03" =>
				SCL <= '1';
				IF (bitcount - 1) >= 0 THEN
					bitcount <= bitcount - 1;
					state <= x"02";
				ELSE
					bitcount <= 7;
					state <= x"12";
				END IF;
			-- get acknowledgment' from slave
			WHEN x"12" =>
				SCL <= '0';
				SDA01 <= '1';
				state <= x"13";
			WHEN x"13" =>
				SCL <= '1';
				Ack <= SDA;	-- 0 = acknowledge'; error if it is a 1
				IF SDA = '1' THEN
					RegisterAddressOut <= x"13";
					state <= x"EE";	-- acknowledge error
				ELSE
					state <= x"20";	-- send register address
				END IF;

----------------------------------------------------------------
			-- send 8-bit register address to slave
			WHEN x"20" =>
				SCL <= '0';
				SDA01 <= AddressIn(bitcount);	-- register address MSB first
				state <= x"21";	-- continue
			WHEN x"21" =>
				SCL <= '1';
				IF (bitcount - 1) >= 0 THEN
					bitcount <= bitcount - 1;
					state <= x"20";
				ELSE
					bitcount <= 7;
					state <= x"30";
				END IF;
			-- get acknowledgment'
			WHEN x"30" =>
				SCL <= '0';
				SDA01 <= '1';
				state <= x"31";
			WHEN x"31" =>
				SCL <= '1';
				Ack <= SDA;	-- 0 = acknowledge'; error if it is a 1
				RegisterAddress <= AddressIn;
				IF SDA = '1' THEN
					RegisterAddressOut <= x"31";
					state <= x"EE"; -- acknowledge error
				ELSIF Read_WriteN = '0' THEN
					state <= x"40";	-- go do a write
				ELSE
					state <= x"70";	-- send repeated start and then go do a read
				END IF;


----------------------------------------------------------------				
-- going to write data to slave
			-- send 8-bit data to slave
			WHEN x"40" =>
				SCL <= '0';
				SDA01 <= DataIn(bitcount); 	-- Data MSB first
				state <= x"41";
			WHEN x"41" =>
				SCL <= '1';
				IF (bitcount - 1) >= 0 THEN
					bitcount <= bitcount - 1;
					state <= x"40";
				ELSE
					bitcount <= 7;
					state <= x"50";
				END IF;
			-- get acknowledgment'
			WHEN x"50" =>
				SCL <= '0';
				SDA01 <= '1';
				RegisterAddressOut <= AddressIn;
				DataOut <= DataIn;
				state <= x"51";
			WHEN x"51" =>
				SCL <= '1';
				Ack <= SDA;	-- 0 = acknowledge'; error if it is a 1
				IF SDA = '1' THEN
					RegisterAddressOut <= x"51";
					state <= x"EE";
				ELSE	-- send stop
					state <= x"52";
				END IF;
			-- send stop
			-- SDA goes from 0 to 1 while SCL is 1
			WHEN x"52" =>
				SCL <= '0';
				SDA01 <= '0';	-- SDA starts at 0 to prepare for the 0 to 1 transition
				state <= x"53";
			WHEN x"53" =>
				SCL <= '1';		-- SCL goes to 1
				SDA01 <= '0';	-- SDA starts from 0
				state <= x"54";
			WHEN x"54" =>	-- idle state
				SCL <= '1';		-- SCL stays at 1 while
				SDA01 <= '1';	-- SDA goes to 1
				state <= x"54";


----------------------------------------------------------------
----------------------------------------------------------------
-- going to receive data from slave
			-- send repeated start condition to do a read after a write
			-- SDA goes from 1 to 0 while SCL is 1
			WHEN x"70" =>
				SCL <= '0';
				SDA01 <= '1';	-- SDA starts at 1 to prepare for the 1 to 0 transition
				IF SDA = '1' THEN	-- SDA is still a 0 here from acknowledgement
					RegisterAddressOut <= x"70";
					state <= x"EE";	-- acknowledge error
				ELSE
					state <= x"71";	-- continue
				END IF;
			WHEN x"71" =>	-- idle state with both SCL and SDA at 1
				SCL <= '1';		-- SCL goes to 1
				SDA01 <= '1';	-- SDA starts from 1
				state <= x"72";
			WHEN x"72" =>	-- Start
				SCL <= '1';		-- SCL stays at 1 while
				SDA01 <= '0';	-- SDA changes from 1 to 0
				bitcount <= 7;
				state <= x"82";
			-- send 7-bit slave address followed by R/W' bit, MSB first
			-- slave address for RTC chip is 1101000
			WHEN x"82" =>					
				SCL <= '0';
				SDA01 <= SlaveAddress_Read(bitcount);
				state <= x"83";
			WHEN x"83" =>
				SCL <= '1';
				IF (bitcount - 1) >= 0 THEN
					bitcount <= bitcount - 1;
					state <= x"82";
				ELSE
					bitcount <= 7;
					state <= x"92";
				END IF;
			-- get acknowledgment' from slave
			WHEN x"92" =>
				SCL <= '0';
				SDA01 <= '1';
				state <= x"93";
			WHEN x"93" =>
				SCL <= '1';
				Ack <= SDA;	-- 0 = acknowledge'; error if it is a 1
				IF SDA = '1' THEN
					RegisterAddressOut <= x"93";
					state <= x"EE";	-- acknowledge error
				ELSE
					bitcount <= 7;
					state <= x"C0";	-- go to receive data byte
				END IF;


----------------------------------------------------------------
			-- receive bytes from RTC
			WHEN x"C0" =>
				SCL <= '0';
				SDA01 <= '1';
				state <= x"C1";
			WHEN x"C1" =>
				SCL <= '1';
				Data(bitcount) <= SDA;	-- MSB of data read in
				IF (bitcount - 1) >= 0 THEN
					bitcount <= bitcount - 1;
					state <= x"C0";
				ELSE
					bitcount <= 7;
					state <= x"D0";
				END IF;
			-- if more bytes to read then send an acknowledge' (0) signal
			-- if no more bytes to read then send a not acknowledge' (1) signal
			WHEN x"D0" =>
				SCL <= '0';
				IF (RegisterAddress = RegisterAddress) THEN			-- read only one byte
--				IF (RegisterAddress + 1 > NumberOfRegisters) THEN	-- read multi-bytes
					-- read last byte
					SDA01 <= '1';	-- send a not acknowledge' (1) signal
					state <= x"D2";	-- stop reading
				ELSE
					-- read next byte
					RegisterAddress <= RegisterAddress + 1;
					SDA01 <= '0';	-- send an acknowledge' (0) signal
					state <= x"D1";	-- continue to read next byte from slave-transmitter
				END IF;
				RegisterAddressOut <= RegisterAddress;
				DataOut <= Data;
			WHEN x"D1" =>
				SCL <= '1';
				state <= x"C0";

			-----------------------------------------------------------
			-- send a not acknowledge' (1) signal
			WHEN x"D2" =>
				SCL <= '1';
				state <= x"D3";
			-- send stop condition
			-- SDA goes from 0 to 1 while SCL is 1
			WHEN x"D3" =>
				SCL <= '0';
				SDA01 <= '0';	-- SDA starts at 0 to prepare for the 0 to 1 transition
				state <= x"D4";
			WHEN x"D4" =>
				SCL <= '1';		-- SCL goes to 1
				SDA01 <= '0';	-- SDA starts from 0
				state <= x"D5";
			WHEN x"D5" =>
				SCL <= '1';		-- SCL stays at 1 while
				SDA01 <= '1';	-- SDA goes to 1
				state <= x"D5";


-----------------------------------------------------------
			-- error - did not recieve the acknowledge
			WHEN x"EE" =>
				--gets here only if ack is error
				SCL <= '1';
				SDA01 <= '1';
				state <= x"EE";


-----------------------------------------------------------
			-- wait for the I2C to be idle by waiting for the SDA to be high for at least 8 SCL cycles
			WHEN x"F0" =>
				SCL <= '0';
				bitcount <= 7;
				state <= x"F1";
			WHEN x"F1" =>
				SCL <= '1';
				IF SDA = '0' THEN
					bitcount <= 7;
				ELSE
					bitcount <= bitcount - 1;
				END IF;
				state <= x"F2";
			WHEN x"F2" =>
				SCL <= '0';
				IF bitcount = 0 THEN
					state <= x"00";
				ELSE
					state <= x"F1";
				END IF;
				
			WHEN OTHERS => null;
				SCL <= '1';
				SDA01 <= '1';
			END CASE;
		END IF;
	END PROCESS;

	clockdivider200k: PROCESS
	BEGIN
		WAIT UNTIL CLK_50_MHz'EVENT and CLK_50_MHz = '1';
		IF clockticks200k < max200k THEN
			clockticks200k <= clockticks200k + 1;
		ELSE
			clockticks200k <= 0;
		END IF;
		IF clockticks200k < max200k/2 THEN
			CLK_200k_Hz <= '0';
		ELSE
			CLK_200k_Hz <= '1';
		END IF;
	END PROCESS;

END FSMD;
