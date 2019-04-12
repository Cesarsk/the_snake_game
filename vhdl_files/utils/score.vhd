library ieee;
	use ieee.std_logic_1164.all;

-- This module is useful for handling the score of the game.
entity score is

	port(
		CLOCK					: in std_logic;
		SCORE_CLEAR				: in std_logic;
		ITEM_ATE				: in std_logic;
		ITEM_TYPE				: in integer range 1 to 7;
		LEVEL					: in integer range 1 to 7;
		DIGIT_0					: out std_logic_vector (3 downto 0);
		DIGIT_1					: out std_logic_vector (3 downto 0);
		DIGIT_2					: out std_logic_vector (3 downto 0);
		DIGIT_3					: out std_logic_vector (3 downto 0);
		HEX0					: out std_logic_vector(6 downto 0);
		HEX1					: out std_logic_vector(6 downto 0);
		HEX2					: out std_logic_vector(6 downto 0);
		HEX3					: out std_logic_vector(6 downto 0)
		);

end score;

architecture arch of score is
	signal digit_increase		: std_logic;

begin
	four_digit_counter_u0: entity work.four_digit_counter

	   port map(
			CLOCK 				=> CLOCK,
			RESET 				=> SCORE_CLEAR,
			DIGIT_INCREASE 		=> digit_increase,
			DIGIT_0 			=> DIGIT_0,
			DIGIT_1 			=> DIGIT_1,
			DIGIT_2 			=> DIGIT_2,
			DIGIT_3 			=> DIGIT_3,
			HEX0 				=> HEX0,
			HEX1 				=> HEX1,
			HEX2 				=> HEX2,
			HEX3 				=> HEX3
		);
	
	-- We need to check here if the snake ate the item; if so, we need to flag the var ADD. If the flag ADD = 1 we increase a counter by 1 unless counter reached LEVEL + ITEM_TYPE (which means we started a new LEVEL). In that case, we set add and counter to 0 again. The operation starts over again. 
	process(CLOCK, LEVEL, ITEM_ATE, ITEM_TYPE)

		variable add		: std_logic;
		variable counter 	: integer range 0 to 63;

	   begin
			if CLOCK'event and CLOCK='1' then
				if ITEM_ATE = '1' then
					add := '1';
				end if;
				
				if add = '1' then
					if counter = LEVEL + ITEM_TYPE then
						add := '0';
						counter := 0;
					else
						counter := counter + 1;
					end if;
				end if;
				-- This is the value that goes as input in 4_digit_counter to handle the score represented by 4 digits (counter 9999)
				digit_increase <= add;
			end if;
	   end process;

end arch;
