library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library libs;
	use libs.the_snake_game_package.all;
	
entity items is

	port(
	 	CLOCK										: in std_logic;
		RESET										: in std_logic;
		PAUSE										: in std_logic;
		ITEM_ON_WALL								: in std_logic;
		ITEM_ON_SNAKE								: in std_logic;
		ITEM_ATE									: in std_logic;
		TIMER2_UP									: in std_logic;
	 	PIXEL_X										: in std_logic_vector (9 downto 0);
    	PIXEL_Y										: in std_logic_vector (9 downto 0);
		LEVEL										: in integer range 1 to 7;
		TIMER2_RESET								: out std_logic;
		TIMER2_START								: out std_logic;    	    
		ITEM_ON										: out std_logic;
    	ITEM_X										: out unsigned(9 downto 0);
    	ITEM_Y										: out unsigned(9 downto 0);
	 	ITEM_TYPE									: out integer range 1 to 7 := 1;
	 	ITEM_RGB									: out std_logic_vector (2 downto 0)
	);

end items;

architecture arch of items is
		
	signal item_x_register							: unsigned(9 downto 0);
	signal item_x_next								: unsigned(9 downto 0);
	signal item_x_new								: unsigned(9 downto 0);
	signal item_y_register							: unsigned(9 downto 0);
	signal item_y_next								: unsigned(9 downto 0);
	signal item_y_new								: unsigned(9 downto 0);
	signal item_type_register						: integer range 1 to 7;
	signal item_type_next							: integer range 1 to 7;
	signal item_type_new							: integer range 1 to 7;	
	
	type state_type is (get_new_item, wait_item_ate);

	signal state_register, state_next 				: state_type;
	
	-- The Old state is saved if nothing happens.
begin

	ITEM_X 			<= item_x_register;
	ITEM_Y 			<= item_y_register;
	ITEM_TYPE 		<= item_type_register;
	
	process(CLOCK, RESET)

	begin
		if CLOCK'event and CLOCK = '1' then

			if RESET = '1' then
				-- Initial Position of Item (off-screen)
				item_x_register 		<= to_unsigned(1000,10);
				item_y_register 		<= to_unsigned(1000,10);
				item_type_register 		<= 1;
				state_register 			<= get_new_item;

			else
				if PAUSE='0' then
					item_x_register 	<= item_x_next;
					item_y_register 	<= item_y_next;
					item_type_register 	<= item_type_next;
					state_register 		<= state_next;
				end if;
			end if;
		end if;

	end process;
	
	-- show item on the stage
	ITEM_ON <= '1' when (item_x_register <= unsigned(PIXEL_X) 
						and unsigned(PIXEL_X) < item_x_register + BLOCK_SIZE) 
						and (item_y_register <= unsigned(PIXEL_Y) 
						and unsigned(PIXEL_Y) < item_y_register + BLOCK_SIZE)
						and ITEM_ROM(item_type_register)(to_integer(unsigned(PIXEL_Y(3 downto 0)) - item_y_register(3 downto 0)))(to_integer(unsigned(PIXEL_X(3 downto 0)) - item_x_register(3 downto 0))) = '1'
					else '0';
	ITEM_RGB <= ITEM_COLOR (item_type_register);

	-- random item to pick
	process(CLOCK)
		-- 16 is a multiplier for the items spawning. I.E. spawn x coordinate: MIN VALUE: 1 * 16 = 16 px MAX VALUE 39 * 16 = 624 px
		variable counter_x 		: integer range 0 to 40; -- 40 * 16 = 640 px
		variable counter_y 		: integer range 0 to 30; -- 30 * 16 = 480 px
		variable counter_z 		: integer range 1 to 31;

	begin
		if CLOCK'event and CLOCK = '1' then
			if counter_x = 39 then
				counter_x := 1;
			else
				counter_x := counter_x + 1;
			end if;

			if counter_y = 28 then
				counter_y := 5;
			else
				counter_y := counter_y + 1;
			end if;
			
			if counter_z = 31 then
				counter_z := 1;
			else
				counter_z := counter_z + 1;
			end if;
			
			if counter_z < 10 then
				item_type_new <= 1;
			elsif counter_z >= 10 and counter_z < 20 then
				item_type_new <= 2;
			elsif counter_z >= 20 and counter_z < 30 then
				item_type_new <= 3;
			else
				item_type_new <= 4;
			end if;
			
			-- Item spawn
			item_x_new <= to_unsigned(counter_x * 16, 10);
			item_y_new <= to_unsigned(counter_y * 16, 10);
		end if;

	end process;
	
	process(item_x_register, item_y_register, state_register, item_type_register, TIMER2_UP, item_x_new, item_y_new, item_type_new, ITEM_ATE,ITEM_ON_WALL, ITEM_ON_SNAKE)
		begin
			item_x_next 			<= item_x_register;
			item_y_next 			<= item_y_register;
			item_type_next 			<= item_type_register;
			state_next  			<= state_register;
			TIMER2_START 			<= '0';
			TIMER2_RESET 			<= '0';
		
		case state_register is
--	Get a new item to put into the stage
			when get_new_item =>
				item_x_next 		<= item_x_new;
				item_y_next 		<= item_y_new;
				item_type_next 		<= item_type_new;
				state_next 			<= wait_item_ate;
				TIMER2_RESET 		<= '1';

				-- starting timer for the item.
				if item_type_new >= 2 then
					TIMER2_START <= '1';
				end if;

			when wait_item_ate =>
--	Check whether some conditions are respected or not
				if ITEM_ATE = '1' or ITEM_ON_WALL = '1' or ITEM_ON_SNAKE = '1' then
					state_next <= get_new_item;
				end if;
--	Check if the timer is over, in that case the item needs to disappear				
				if item_type_register >= 2 and TIMER2_UP = '1' then
					state_next <= get_new_item;
				end if;

		end case;
	end process;
	
end;
