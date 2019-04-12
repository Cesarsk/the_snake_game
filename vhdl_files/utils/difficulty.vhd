library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
entity difficulty is

   port(
     	CLOCK			: in std_logic;
	  	RESET			: in std_logic;
	  	PAUSE			: in std_logic;
		REFRESH_TICK	: in std_logic;
		LEVEL			: in integer range 1 to 7;
	  	MOVE			: out std_logic
   );

end difficulty;

architecture arch of difficulty is

begin
	process(CLOCK, RESET, REFRESH_TICK, LEVEL, PAUSE)
	-- This process works as a counter. The higher is the value and the higher is the speed of the snake.
	-- Let's take a look at the counter.
		variable move_temp	: std_logic;
		variable counter 	: integer range 0 to 63;

	begin
		if CLOCK'event and CLOCK='1' then
			move_temp 		:= '0';
			-- RESET State, if it's one we RESET every value of the counter.
			if RESET='1' then
				counter		:= 0;
				move_temp	:='0';
			-- Else if we're in game we need to check the refresh_tick; if it's 1 we and the counter reached 10 it means the snake needs to MOVE faster.
			-- Else, we increase the counter until the previous condition is respected.
				elsif PAUSE = '0' then
					if REFRESH_TICK = '1' then
						if counter = 10 then
							move_temp 	:= '1';
							counter		:= 0;
						else
							counter		:= counter+1;
						end if;
					end if;
				end if;
			-- Assigning tmp to MOVE
			MOVE <= move_temp;
		end if;

	end process;
end arch;					