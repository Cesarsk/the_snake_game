library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity finite_state_machine is
	
	port(
		CLOCK				: in std_logic;
		RESET				: in std_logic;
	
		-- keys: 0-dn, 1-up, 2-left, 3-right, 4-enter, 5-space, 6-esc
		BUTTONS				: in std_logic_vector (6 downto 0);
		TIMER_UP			: in std_logic;
		HEAD_ON_WALL		: in std_logic;
		HEAD_ON_SNAKE		: in std_logic;
		VIDEO_ON			: in std_logic;
		PIXEL_TICK			: in std_logic;
		ITEM_ATE			: in std_logic;
		LEVEL_UP			: in std_logic;
		STAGE_CLEAR			: in std_logic;
		LEVEL				: in integer range 0 to 7;
		ITEM_ON				: in std_logic;
		ITEM_RGB			: in std_logic_vector (2 downto 0);
		MAP_ON				: in std_logic;
		MAP_RGB				: in std_logic_vector (2 downto 0);
		SNAKE_ON			: in std_logic;
		SNAKE_RGB			: in std_logic_vector (2 downto 0);
		TEXT_ON				: in std_logic_vector(7 downto 0);
		TEXT_RGB			: in std_logic_vector(2 downto 0);
		TIMER_START			: out std_logic;
		RESTART 			: out std_logic_vector(1 downto 0);
		PAUSE				: out std_logic;
		SCORE_CLEAR			: out std_logic;
		LIVES				: in std_logic_vector(2 downto 0);
		STATUS_INDICATOR	: out std_logic_vector(2 downto 0);
		STATE_INDICATOR 	: out std_logic_vector(7 downto 0);
		RGB					: out std_logic_vector (2 downto 0)
	);

end finite_state_machine;

architecture arch of finite_state_machine is
	
	type state_type 										is (new_game, stage_select, playing, paused, new_life, levelup, stageclear, game_over);
	signal state_register, state_next						: state_type;
	signal button_up, button_down, button_left				: std_logic;
	signal button_right, button_space, button_enter, hit	: std_logic;
	signal pause_var										: std_logic;
	signal status_indicator_var								: std_logic_vector(2 downto 0);
	signal state_indicator_var								: std_logic_vector(7 downto 0);
	signal restart_var										: std_logic_vector(1 downto 0);
	signal rgb_register, rgb_next							: std_logic_vector(2 downto 0);

	begin
	-- Assignment between BUTTONS and std_logic dedicated to them. BUTTONS are taken from the ps/2 component.
	button_down 	<= BUTTONS(0);
	button_up 		<= BUTTONS(1);
	button_left	   	<= BUTTONS(2);
	button_right	<= BUTTONS(3);
	button_enter	<= BUTTONS(4);
	button_space	<= BUTTONS(5);
	RGB 			<= rgb_register;
	
	-- std_logic that indicates if the snake has hit the wall / body
	hit 			<= HEAD_ON_SNAKE or HEAD_ON_WALL;
	
	-- Sync State
	process(CLOCK, RESET)
		begin
			if CLOCK'event and CLOCK='1' then
				if RESET='1' then
				-- If we push the RESET state a new_game is generated with the init of every var.
					state_register 		<= new_game;
				else
					STATE_INDICATOR 	<= state_indicator_var;
					STATUS_INDICATOR 	<= status_indicator_var;
					PAUSE 				<= pause_var;
					RESTART 			<= restart_var;
					state_register 		<= state_next;
					if PIXEL_TICK='1' then
						rgb_register <= rgb_next;
					end if;
				end if;
			end if;
	end process;
	
	-- next state 
	process(state_register,button_up, button_down, button_left, button_right, button_space, button_enter,TIMER_UP,hit,LEVEL_UP,STAGE_CLEAR,LIVES)
	begin
		state_next <= state_register;
		-- Mapping keys with actions
		case state_register is
			when new_game =>
			-- If new_game and you press space you go into the selection stage state
				if button_space='1' then 
					state_next <= stage_select;
				end if;
			-- If in selection state and press enter you play the selected stage
			when stage_select =>
				if button_enter='1' then
					state_next <= playing;
				end if;
			-- If you're playing and you press space the game pauses
			when playing =>
				if button_space='1' then
					state_next <= paused;
			-- If you get hit the new life state gets triggered
				elsif hit='1' then
					state_next <= new_life;
			-- If the stage gets cleared the stageclear gets triggered
				elsif STAGE_CLEAR='1' then
					state_next <= stageclear;
				elsif LEVEL_UP='1' then
			-- If level up is high we need to change level
					state_next <= levelup;
				end if;
			-- If game is paused we can resume it pressing any button.
			when paused =>
				if button_up='1' or button_down='1' or button_left='1' or button_right='1' then
					state_next <= playing;
				end if;
			-- If level_up is high then we need to play the next level if the timer is up
			when levelup =>
				if TIMER_UP='1' then
					state_next <= playing;
				end if;
			-- If we lose every life we trigger the game over state
			when new_life =>
				if LIVES = "000" then
					state_next <= game_over;
				-- then we need to press one of the keys to move again our snake
				elsif button_up='1' or button_down='1' or button_left='1' or button_right='1' then
					state_next <= playing;
				end if;
				-- new life state if we lose a life
			when stageclear =>
				if button_enter='1' then
					state_next <= new_life;
				end if;
				-- game_over state if we press enter we start a new game. 
			when game_over =>
				if button_enter='1' then
					state_next <= new_game;
				end if;
		end case;
	end process;
	
	-- output: encoder like. This status is also indicated on the GREEN LED OF THE BOARD 
	state_indicator_var 	<=	"10000000" when state_register=new_game else
					 			"01000000" when state_register=stage_select else
					 			"00100000" when state_register=playing else
					 			"00010000" when state_register=paused else
							 	"00001000" when state_register=levelup else
							 	"00000100" when state_register=new_life else
								"00000010" when state_register=stageclear else
								"00000001" when state_register=game_over else
								"00000000";
	-- This is indicated on the board using the RED LEDS
	status_indicator_var 	<= pause_var & restart_var;
	pause_var 				<= '0' when state_register=playing or state_register=levelup else '1';
	restart_var(1) 			<= '1' when state_register=new_game or state_register=stage_select else '0';
	restart_var(0) 			<= '1' when state_register=new_game or state_register=new_life or state_register=stageclear else '0';
	
	-- Start the timer every time LEVEL_UP
	TIMER_START 			<= '1' when LEVEL_UP='1' else '0';
	
	-- Clear the score if a new game starts
	SCORE_CLEAR 			<= '1' when state_register=new_game else '0';
	
	-- RGB
	process(state_register,VIDEO_ON, ITEM_ON, MAP_ON,ITEM_RGB, MAP_RGB, SNAKE_ON, SNAKE_RGB,TEXT_ON, TEXT_RGB)
		variable rgb_next_tmp	: std_logic_vector(2 downto 0);
		begin
		if VIDEO_ON='0' then
			rgb_next_tmp := "000";
			-- TEXT that is enabled to be displayed in the area
		elsif (TEXT_ON(7)='1') or
				(state_register=new_game 		and TEXT_ON(6)='1') or 
				(state_register=stage_select 	and TEXT_ON(5)='1') or 
				(state_register=levelup 		and TEXT_ON(4)='1') or 
				(state_register=paused 			and TEXT_ON(3)='1') or
				(state_register=stageclear 		and TEXT_ON(2)='1') or
				(state_register=game_over 		and TEXT_ON(1)='1') then
				rgb_next_tmp := TEXT_RGB;	
			-- Giving color to the Item
		elsif ITEM_ON='1' then
			rgb_next_tmp := ITEM_RGB;
			-- Giving color to the map
		elsif MAP_ON='1' then
			rgb_next_tmp := MAP_RGB;
			-- Giving color to the snake
		elsif SNAKE_ON='1' then
			rgb_next_tmp := SNAKE_RGB;
		else
		-- BACKGROUND COLOR
			rgb_next_tmp := "001";
		end if;
		rgb_next <= rgb_next_tmp;
	end process;
	
end arch;
