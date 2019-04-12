library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity four_digit_counter is

	port(
		CLOCK			: in std_logic;
		RESET			: in std_logic;
		DIGIT_INCREASE	: in std_logic;
		DIGIT_0			: out std_logic_vector (3 downto 0);
		DIGIT_1			: out std_logic_vector (3 downto 0);
		DIGIT_2			: out std_logic_vector (3 downto 0);
		DIGIT_3			: out std_logic_vector (3 downto 0);
		HEX0			: out std_logic_vector(6 downto 0);
		HEX1			: out std_logic_vector(6 downto 0);
		HEX2			: out std_logic_vector(6 downto 0);
		HEX3			: out std_logic_vector(6 downto 0)
	);

end four_digit_counter;

architecture arch of four_digit_counter is

	signal digit_0_register, digit_1_register, digit_2_register, digit_3_register		: unsigned(3 downto 0);
	signal digit_0_next, digit_1_next, digit_2_next, digit_3_next						: unsigned(3 downto 0);

begin
-- 	registers
	process (CLOCK, RESET)
	begin
		-- Init every digit of our counter if RESET = 1
		if (CLOCK'event and CLOCK='1') then
			if RESET='1' then
				digit_0_register <= (others=>'0');
				digit_1_register <= (others=>'0');
				digit_2_register <= (others=>'0');
				digit_3_register <= (others=>'0');
			else -- set the counter's digit to the next digit 
				digit_0_register <= digit_0_next;
				digit_1_register <= digit_1_next;
				digit_2_register <= digit_2_next;
				digit_3_register <= digit_3_next;
			end if;
		end if;
	end process;

	-- next-state logic for the decimal counter
	process(RESET, DIGIT_INCREASE, digit_0_register, digit_1_register, digit_2_register, digit_3_register)
	begin -- If RESET = 1 then we RESET every digit of our counter
		if RESET='1' then
			digit_0_next <= (others=>'0');
			digit_1_next <= (others=>'0');
			digit_2_next <= (others=>'0');
			digit_3_next <= (others=>'0');
		else
		-- This time we set our next-state logic to the value contained on the register
			digit_0_next <= digit_0_register;
			digit_1_next <= digit_1_register;
			digit_2_next <= digit_2_register;
			digit_3_next <= digit_3_register;
		end if;
			
		-- Counting operation, we check the value DIGIT_INCREASE to check if we need to increase our value; if so, we do it being careful to the condition that indicates
		-- that the digit reached 9, in that case we need to increase the digit on the left and put to zero the others.
		if (DIGIT_INCREASE='1') then
			if digit_0_register=9 then
				digit_0_next <= (others=>'0');

				if digit_1_register=9 then
					digit_1_next <= (others=>'0');

					if digit_2_register=9 then
						digit_2_next <= (others=>'0');

						if digit_3_register=9 then
							digit_3_next <= (others=>'0');

						else
							digit_3_next <= digit_3_register + 1;
						end if;

					else
						digit_2_next <= digit_2_register + 1;
					end if;

				else
					digit_1_next <= digit_1_register + 1;
				end if;

			else
				digit_0_next <= digit_0_register + 1;
			end if;
		end if;
	end process;
	
	-- We set the digits of the vector manipulated earlier.
	DIGIT_0 <= std_logic_vector(digit_0_register);
	DIGIT_1 <= std_logic_vector(digit_1_register);
	DIGIT_2 <= std_logic_vector(digit_2_register);
	DIGIT_3 <= std_logic_vector(digit_3_register);
	
	-- Setting the score on the embedded 4 7-segments displays.
	with digit_0_register select
		HEX0 <=
			"1000000" when "0000", --0 
			"1111001" when "0001", --1 
			"0100100" when "0010", --2
			"0110000" when "0011", --3
			"0011001" when "0100", --4 
			"0010010" when "0101", --5 
			"0000010" when "0110", --6
			"1111000" when "0111", --7 
			"0000000" when "1000", --8 
			"0010000" when "1001", --9
			"1111111" when others;
			
	with digit_1_register select
		HEX1 <=
			"1000000" when "0000", --0 
			"1111001" when "0001", --1 
			"0100100" when "0010", --2
			"0110000" when "0011", --3
			"0011001" when "0100", --4 
			"0010010" when "0101", --5 
			"0000010" when "0110", --6
			"1111000" when "0111", --7 
			"0000000" when "1000", --8 
			"0010000" when "1001", --9
			"1111111" when others;
	
	with digit_2_register select
		HEX2 <=
			"1000000" when "0000", --0 
			"1111001" when "0001", --1 
			"0100100" when "0010", --2
			"0110000" when "0011", --3
			"0011001" when "0100", --4 
			"0010010" when "0101", --5 
			"0000010" when "0110", --6
			"1111000" when "0111", --7 
			"0000000" when "1000", --8
			"0010000" when "1001", --9
			"1111111" when others;
	
	with digit_3_register select
		HEX3 <=
			"1000000" when "0000", --0 
			"1111001" when "0001", --1 
			"0100100" when "0010", --2
			"0110000" when "0011", --3
			"0011001" when "0100", --4 
			"0010010" when "0101", --5 
			"0000010" when "0110", --6
			"1111000" when "0111", --7 
			"0000000" when "1000", --8 
			"0010000" when "1001", --9
			"1111111" when others;		

end arch;
