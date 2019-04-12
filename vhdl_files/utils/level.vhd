library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity level is

   port(
      CLOCK								: in  std_logic;
	  RESTART							: in  std_logic_vector(1 downto 0);
	  ITEM_ATE							: in  std_logic;
	  LEVEL_UP							: out std_logic;
	  STAGE_CLEAR						: out std_logic;
	  STAGE_SELECT_IN					: in  integer range 1 to 7;
	  STAGE_SELECT_OUT					: out integer range 1 to 7;
	  LEVEL								: out integer range 1 to 7
   );

end level;

architecture arch of level is

begin
	process(CLOCK, RESTART, ITEM_ATE, STAGE_SELECT_IN)
		variable level_up_temp			: std_logic;
		variable stage_clear_temp		: std_logic;
		variable stage_select_tmp		: integer range 1 to 7;
		variable level_temp				: integer range 1 to 7 := 1;
		variable counter_next_level 	: integer range 0 to 40 := 0;
	begin
		if CLOCK'event and CLOCK='1' then
			level_up_temp 			:= '0';
			stage_clear_temp 		:= '0';

			if RESTART(1) = '1' then
				level_temp := 1;
				stage_select_tmp := STAGE_SELECT_IN;
				counter_next_level := 0;
			
				elsif RESTART(0) = '1' then
				counter_next_level := 0;
			
				elsif ITEM_ATE = '1' then
				
					if counter_next_level = 2 * level_temp then
					level_temp := level_temp + 1;
					
					if level_temp = 6 then
						if stage_select_tmp < 2 then
							stage_select_tmp := stage_select_tmp + 1;
						end if;
						stage_clear_temp := '1';
						level_temp := 1;
					end if;

					level_up_temp := '1';
					counter_next_level 	:= 0;

						else
						counter_next_level := counter_next_level + 1;
						end if;

					end if;
		LEVEL 				<= level_temp;
		LEVEL_UP 			<= level_up_temp;
		STAGE_CLEAR 		<= stage_clear_temp;
		STAGE_SELECT_OUT 	<= stage_select_tmp;
		end if;
	end process;

end arch;