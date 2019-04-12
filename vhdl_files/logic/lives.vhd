library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity lives is

   port(
	  CLOCK					: in std_logic;
	  HIT					: in std_logic;	  
	  ITEM_ATE				: in std_logic;
	  ITEM_TYPE				: in integer range 1 to 7;	  
	  RESTART				: in std_logic_vector(1 downto 0);
	  LIVES					: out std_logic_vector(2 downto 0)
   );

end lives;

-- This component handles the LIVES of the snake in the game.
architecture arch of lives is

	signal lives_temp		: unsigned(2 downto 0);

begin

	process(CLOCK, RESTART, ITEM_ATE, ITEM_TYPE, HIT)

-- It's a counter that counts from 0 to 3 indicating the number of lives that we want to assign to our snake.
		variable lives_temp	: unsigned(2 downto 0);
		variable counter	: integer range 0 to 3;

	begin

		if CLOCK'event and CLOCK = '1' then
--- If the game is new or has been RESTARTed then we set the lives to 3.
			if RESTART(1) = '1' then
				lives_temp := "011";
				-- Item has been eaten? If it's type 3 then add a life.
			elsif ITEM_ATE = '1' and ITEM_TYPE = 3 then
				if counter = 2 then
					if lives_temp < 7 then
						lives_temp := lives_temp + 1;
					end if;
					counter := 0;
				else
					counter := counter+1;
				end if;

				-- Snake got HIT, we decrease a life.
			elsif HIT = '1' then
				if counter = 2 then
					lives_temp := lives_temp - 1;
					counter := 0;
				else
					counter := counter + 1;
				end if;
			end if;

			LIVES <= std_logic_vector(lives_temp);
		
		end if;
	end process;		
	
end arch;