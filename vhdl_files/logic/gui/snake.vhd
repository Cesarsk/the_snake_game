library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library libs;
	use libs.the_snake_game_package.all;
	
entity snake is
	
	port(
		CLOCK			: in std_logic;
		RESTART			: in std_logic_vector(1 downto 0);
		BUTTONS			: in std_logic_vector(3 downto 0);
		PIXEL_X			: in std_logic_vector (9 downto 0);
   		PIXEL_Y			: in std_logic_vector (9 downto 0);
   		ITEM_X			: in unsigned(9 downto 0);
   		ITEM_Y			: in unsigned(9 downto 0);
   		MOVE			: in std_logic;
   		HEAD_X			: out unsigned(9 downto 0);
   		HEAD_Y			: out unsigned(9 downto 0);
   		HEAD_ON_SNAKE	: out std_logic;
   		ITEM_ATE		: out std_logic;
   		ITEM_ON_SNAKE	: out std_logic;
   		SNAKE_ON		: out std_logic;
		SNAKE_RGB		: out std_logic_vector (2 downto 0)
	);

end snake;

architecture arch of snake is
	
	signal head_on									: std_logic;
	signal head_x_register, head_x_next				: unsigned(9 downto 0);
	signal head_y_register, head_y_next				: unsigned(9 downto 0);
	type positon_array is array (0 to LENGTH_MAX) 	of unsigned(9 downto 0);
	signal body_x									: positon_array;
	signal body_y									: positon_array;
	signal body_e									: std_logic_vector(0 to LENGTH_MAX);
	signal body_o1									: std_logic_vector(0 to LENGTH_MAX-1);
	signal body_o2									: std_logic_vector(0 to LENGTH_MAX);
	signal item_on_body_c1 							: std_logic_vector(0 to LENGTH_MAX-1);
	signal item_on_body_c2 							: std_logic_vector(0 to LENGTH_MAX);
	signal snake_hit_body_c1 						: std_logic_vector(3 to LENGTH_MAX-1);
	signal snake_hit_body_c2 						: std_logic_vector(3 to LENGTH_MAX);
	signal direction_register, direction_next		: std_logic_vector(1 downto 0);
	signal item_ate_var								: std_logic;

	begin
		HEAD_X 			<= head_x_register;
		HEAD_Y 			<= head_y_register;
		ITEM_ATE 		<= item_ate_var;
		SNAKE_ON 		<= head_on or body_o1(0);
		SNAKE_RGB 		<= HEAD_COLOR when head_on='1' else
				 			BODY_COLOR when body_o1(0)='1' else
							"000";
						 
	process(CLOCK, RESTART)
		begin
			if CLOCK'event and CLOCK='1' then
				if RESTART(1)='1' or RESTART(0)='1' then
					head_x_register 		<= to_unsigned(320,10);
					head_y_register 		<= to_unsigned(240,10);
				else
					head_x_register 		<= head_x_next;
					head_y_register 		<= head_y_next;
					direction_register 		<= direction_next;
				end if;
			end if;
		end process;
	
	-- show head
	head_on 		<= '1' when (head_x_register < unsigned(PIXEL_X) 
						and unsigned(PIXEL_X) < head_x_register + BLOCK_SIZE) 
						and (head_y_register < unsigned(PIXEL_Y) 
						and unsigned(PIXEL_Y) < head_y_register + BLOCK_SIZE)
						and SNAKE_HEAD_ROM(to_integer(unsigned(PIXEL_Y(3 downto 0)) - head_y_register(3 downto 0)))(to_integer(unsigned(PIXEL_X(3 downto 0)) - head_x_register(3 downto 0)))='1'
						else '0';
	-- item ate 
	item_ate_var 				<= '1' when ITEM_X=head_x_register and ITEM_Y=head_y_register else '0';
	
	-- item on body check
	a0: for i in 0 to LENGTH_MAX generate
		item_on_body_c2(i) 			<= '1' when ITEM_X = body_x(i) and ITEM_Y =  body_y(i) and body_e(i) = '1' 
											else '0';
	end generate;
	
	a1: for i in 0 to LENGTH_MAX-2 generate
		item_on_body_c1(i) 			<= item_on_body_c2(i) or item_on_body_c1(i+1);
	end generate;

	item_on_body_c1(LENGTH_MAX-1) 	<= item_on_body_c2(LENGTH_MAX-1) or item_on_body_c2(LENGTH_MAX);
	ITEM_ON_SNAKE 					<= item_on_body_c1(0);
	
	-- snake hit body 
	b0:for i in 3 to LENGTH_MAX generate
		snake_hit_body_c2(i) <= '1' when head_x_register = body_x(i) and head_y_register = body_y(i) and body_e(i)='1' 
									else '0';
	end generate;
	
	b1:for i in 3 to LENGTH_MAX-2 generate
		snake_hit_body_c1(i) <= snake_hit_body_c2(i) or snake_hit_body_c1(i+1);
	end generate;
	
	snake_hit_body_c1(LENGTH_MAX-1) <= snake_hit_body_c2(LENGTH_MAX-1) or snake_hit_body_c2(LENGTH_MAX);
	HEAD_ON_SNAKE <= snake_hit_body_c1(3);
	
	-- show body
	c0: for i in 0 to LENGTH_MAX generate
		body_o2(i) <= '1' when body_e(i)='1'
							and (body_x(i) < unsigned(PIXEL_X) and unsigned(PIXEL_X) < body_x(i) + BLOCK_SIZE) and (body_y(i) < unsigned(PIXEL_Y) and unsigned(PIXEL_Y) < body_y(i) + BLOCK_SIZE)
							and SNAKE_ROM(to_integer(unsigned(PIXEL_Y(3 downto 0)) - body_y(i)(3 downto 0)))(to_integer(unsigned(PIXEL_X(3 downto 0)) - body_x(i)(3 downto 0)))='1'
							else '0';
	end generate;

	c1: for i in 0 to LENGTH_MAX-2 generate
		body_o1(i) <= body_o2(i) or body_o1(i+1);
	end generate;

	body_o1(LENGTH_MAX-1) <= body_o2(LENGTH_MAX-1) or body_o2(LENGTH_MAX);
	body_e <= (0 to 2 => '1', others => '0' ) when RESTART(1)= '1' else
			  '1' & body_e(0 to LENGTH_MAX-1) when item_ate_var'event and item_ate_var='1';
	
	-- snake control
	direction_next <= 	"00" when BUTTONS="0001" else
						"01" when BUTTONS="0010" else
						"10" when BUTTONS="0100" else
						"11" when BUTTONS="1000" else
						direction_register;
	
	-- snake MOVE
	process(CLOCK,RESTART, head_x_register, head_y_register,direction_register, MOVE)
		variable direction_temp				: std_logic_vector(1 downto 0);
		begin
			if CLOCK'event and CLOCK='1' then
				if RESTART(1) ='1'  then
					head_x_next 	<= to_unsigned(320,10);
					head_y_next 	<= to_unsigned(240,10);
					body_x 			<= (0 to 2 => to_unsigned(320,10), others => (others => '0'));
					body_y 			<= (0 => to_unsigned(256,10), 1 => to_unsigned(272,10),2 => to_unsigned(288,10),others => (others => '0'));
					direction_temp	:="01";
				elsif RESTART(0) ='1' then
					head_x_next 	<= to_unsigned(320,10);
					head_y_next 	<= to_unsigned(240,10);
					body_x 			<= (others => to_unsigned(320,10));
					body_y 			<= (0 => to_unsigned(256,10), 1 => to_unsigned(272,10), others => to_unsigned(288,10));
					direction_temp :="01";
				elsif MOVE='1' then
			-- Positions Check, if you MOVE in a direction you can ONLY MOVE +-90°
				case direction_register is 
					when "00" =>
						if direction_temp/="01" then direction_temp := "00";
						end if;
						
					when "01" =>
						if direction_temp/="00" then direction_temp := "01";
						end if;
						
					when "10" =>
						if direction_temp/="11" then direction_temp := "10";
						end if;
						
					when others =>
						if direction_temp/="10" then direction_temp := "11";
						end if;
				end case;
			
				case direction_temp is
					when "00" =>
						case head_y_register is
					-- TELEPORT FROM DOWN TO UP
					--80 (DOWN BORDER TO UP)
							when "0111010000" =>
								head_y_next <= to_unsigned(80,10);
							-- NO TELEPORT, JUST MOVE NORMALLY
							when others =>
								head_y_next <= head_y_next + BLOCK_SIZE;
						end case;
					when "01" =>
					-- TELEPORT FROM UP TO DOWN
						case head_y_register is
						-- Starting point: Binary is Dec 80
							when "0001010000" =>
								head_y_next <= to_unsigned(MAX_Y-BLOCK_SIZE,10);
							when others =>
								head_y_next <= head_y_next - BLOCK_SIZE;
						end case;
					when "10" =>
					-- TELEPORT FROM LEFT TO RIGHT
						case head_x_register is
							when "0000000000" =>
								head_x_next <= to_unsigned(MAX_X-BLOCK_SIZE,10);
							when others =>
								head_x_next <= head_x_next - BLOCK_SIZE;
						end case;
					when others =>
					-- TELEPORT Snake goes outside the RIGHT Border and appears from the LEFT Border
						case head_x_register is
						-- This Value indicates when the snake disappears
							when "1001110000" =>
								-- This Value indicates where the Snake is gonna appear
								head_x_next <= "0000000000";
							when others =>
								head_x_next <= head_x_next + BLOCK_SIZE;
						end case;
				end case;
				body_x 		<= head_x_register & body_x(0 to LENGTH_MAX-1);
				body_y 		<= head_y_register & body_y(0 to LENGTH_MAX-1);
			end if;
		end if;
	end process;
	
end arch;