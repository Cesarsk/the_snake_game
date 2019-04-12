-- This file contains the main component of the game. It connects every piece to the main component and starts every module.
library ieee; 
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
entity the_snake_game is
	
	port (
		CLOCK_50			:	in std_logic;
		PS2_DAT				: in std_logic;
		PS2_CLK				:	in std_logic;
		VGA_HS				: out std_logic;
		VGA_VS				: out std_logic;
		VGA_R 				: out std_logic_vector(3 downto 0);
		VGA_G 				: out std_logic_vector(3 downto 0);
		VGA_B 				: out std_logic_vector(3 downto 0);
		LEDG					: out std_logic_vector(7 downto 0);
		LEDR					: out std_logic_vector(2 downto 0);
		HEX0					: out std_logic_vector(6 downto 0);
		HEX1					: out std_logic_vector(6 downto 0);
		HEX2					: out std_logic_vector(6 downto 0);
		HEX3					: out std_logic_vector(6 downto 0)
	);

end the_snake_game;

architecture arch of the_snake_game is
	
	signal rgb, item_rgb, map_rgb, snake_rgb, text_rgb																									: std_logic_vector(2 downto 0);
	signal buttons																																											: std_logic_vector (6 downto 0);
	signal reset, video_on, p_tick, refresh_tick, timer2_start, timer_up, timer_start, timer2_up, pause	: std_logic;
	signal move, level_up, stage_clear, item_on, map_on, item_on_wall																		:	std_logic;
	signal head_on_wall, head_on_snake, item_ate, item_on_snake, snake_on, score_clear, timer2_reset			: std_logic;
	signal restart																																											: std_logic_vector(1 downto 0);
	signal status_indicator, lives																																			: std_logic_vector(2 downto 0);
	signal state_indicator																																							: std_logic_vector(7 downto 0);
	signal pixel_x, pixel_y																																							: std_logic_vector (9 downto 0);
	signal item_x, item_y, head_x, head_y																																: unsigned(9 downto 0);
	signal level, item_type																																							: integer range 1 to 7:=1;
	signal stage_select, stage_select_in																																	: integer range 1 to 7;
	signal digit_0, digit_1, digit_2, digit_3																														: std_logic_vector (3 downto 0);
	signal text_on																																											: std_logic_vector(7 downto 0);

	begin
		reset 				<= buttons(6);
		VGA_R 				<= (others=> rgb(2));
		VGA_G 				<= (others=> rgb(1));
		VGA_B 				<= (others=> rgb(0));
	
		-- LEDR E LEDG are lighted on by the status_indicator signal.
		LEDR 					<= status_indicator;
		LEDG 					<= state_indicator;
	
----------------------PORT MAPPING OF EVERY COMPONENT USED IN THIS PROJECT------------------------------------

--	
--	PS/2 KEYBOARD
--

	ps2kb_u0: entity work.ps2kb
    port map( 
      PS2_CLOCK 				=> PS2_CLK,
     	PS2_DEBOUNCE 			=> PS2_DAT,
      CLOCK 						=> CLOCK_50,
      BUTTONS 					=> buttons
					 );

--	
--	VGA SYNCHRONIZATION
--

	vga_sync_u0: entity work.vga_sync
		port map(
			CLOCK 							=> CLOCK_50,
			RESET 							=> reset,
			HORIZONTAL_SYNC 		=> VGA_HS,
			VERTICAL_SYNC 			=> VGA_VS,
			VIDEO_ON 						=> video_on,
			PIXEL_TICK 					=> p_tick,
			REFRESH_TICK 				=> refresh_tick,
			PIXEL_X 						=> pixel_x,
			PIXEL_Y 						=> pixel_y
		);

--		
--	FINITE STATE MACHINE
--

finite_state_machine_u0: entity work.finite_state_machine
	port map(
		CLOCK 													=> CLOCK_50,
		RESET 													=> reset,
		BUTTONS 												=> buttons,
		HEAD_ON_WALL 										=> head_on_wall,
		HEAD_ON_SNAKE 									=> head_on_snake,
		VIDEO_ON 												=> video_on,
		PIXEL_TICK 											=> p_tick,
		TIMER_UP 												=> timer_up,
		ITEM_ATE 												=> item_ate,
		LEVEL_UP 												=> level_up,
		LEVEL 													=> level,
		STAGE_CLEAR 										=> stage_clear,
		ITEM_ON 												=> item_on,
		ITEM_RGB 												=> item_rgb,
		SNAKE_ON 												=> snake_on,
		SNAKE_RGB 											=> snake_rgb,
		MAP_ON 													=> map_on,
		MAP_RGB 												=> map_rgb,	
		TEXT_ON												 	=> text_on,
		TEXT_RGB 												=> text_rgb,
		TIMER_START 										=> timer_start,
		RESTART													=> restart,
		PAUSE 													=> pause,
		LIVES 													=> lives,
		SCORE_CLEAR 										=> score_clear,
		STATUS_INDICATOR 								=> status_indicator,
		STATE_INDICATOR									=> state_indicator,
		RGB 														=> rgb
	);

--	
--	MAPS
--	

	stages_u0: entity work.stages
		port map(
			STAGE_SELECT_FROM_TEXT 				=> stage_select_in,
			STAGE_SELECT_FROM_LEVEL 			=> stage_select,
			STATE 												=> state_indicator(6),
			PIXEL_X 											=> pixel_x,
  	  PIXEL_Y 											=> pixel_y,
  	  ITEM_X 												=> item_x,
 	   	ITEM_Y 												=> item_y,
  	  HEAD_X 												=> head_x,
  	  HEAD_Y 												=> head_y,
  	  ITEM_ON_WALL 									=> item_on_wall,
  	  HEAD_ON_WALL 									=> head_on_wall,
  	  MAP_ON 												=> map_on,
		 	MAP_RGB 											=> map_rgb
		);

--	
--	ITEMS
--

	items_u0: entity work.items
		port map(
			CLOCK						 			=> CLOCK_50,
			RESET							 		=> restart(0),
			PIXEL_X 							=> pixel_x,
			PIXEL_Y 							=> pixel_y,
			PAUSE								 	=> pause,
			ITEM_X							 	=> item_x,
			ITEM_Y 								=> item_y,
			LEVEL 								=> level,
			TIMER2_RESET 					=> timer2_reset,
			TIMER2_START					=> timer2_start,
			TIMER2_UP							=> timer2_up,
			ITEM_ON_WALL 					=> item_on_wall,
			ITEM_ON_SNAKE 				=> item_on_snake,
			ITEM_ATE 							=> item_ate,
			ITEM_TYPE 						=> item_type,
			ITEM_ON 							=> item_on,
			ITEM_RGB 							=> item_rgb
		);

--	
--	SNAKE
--

	snake_u0: entity work.snake
		port map(
			CLOCK 								=> CLOCK_50,
			RESTART 							=> restart,
			BUTTONS 							=> buttons(3 downto 0),
			PIXEL_X 							=> pixel_x,
			PIXEL_Y 							=> pixel_y,
			ITEM_X 								=> item_x,
			ITEM_Y 								=> item_y,
			MOVE 									=> move,
			HEAD_X 								=> head_x,
			HEAD_Y 								=> head_y,
			HEAD_ON_SNAKE 				=> head_on_snake,
			ITEM_ATE 							=> item_ate,
			ITEM_ON_SNAKE 				=> item_on_snake,
			SNAKE_ON 							=> snake_on,
			SNAKE_RGB 						=> snake_rgb
		);

--		
--	TEXTS
--	

	texts_u0: entity work.texts
		port map(
			CLOCK 						=> CLOCK_50, 
			STATE 						=> state_indicator,
			PIXEL_X 					=> pixel_x,
			PIXEL_Y 					=> pixel_y,
			DIGIT_0 					=> digit_0,
			DIGIT_1 					=> digit_1,
			DIGIT_2 					=> digit_2,
			DIGIT_3 					=> digit_3,
			BUTTONS 					=> buttons(3 downto 0),
			STAGE_SELECT_OUT	=> stage_select_in,
			STAGE 						=> std_logic_vector(to_unsigned(stage_select,3)),
			LEVEL 						=> std_logic_vector(to_unsigned(level,3)),
			LIVES 						=> lives,
			TEXT_ON				 		=> text_on,
			TEXT_RGB 					=> text_rgb
			);

--	
--	SCORE
--

	score_u0: entity work.score
		port map(
			CLOCK 						=> CLOCK_50,
			SCORE_CLEAR 			=> score_clear,
			ITEM_ATE 					=> item_ate,
			ITEM_TYPE 				=> item_type,
			LEVEL 						=> level,
			DIGIT_0						=> digit_0,
			DIGIT_1 					=> digit_1,
			DIGIT_2 					=> digit_2,
			DIGIT_3 					=> digit_3,
			HEX0 							=> HEX0,
			HEX1 							=> HEX1,
			HEX2 							=> HEX2,
			HEX3 							=> HEX3
		);

--	
--	LEVEL
--
	
	level_u0: entity work.level
		port map(
		  CLOCK 						=> CLOCK_50,
		  RESTART 					=> restart,
		  ITEM_ATE				 	=> item_ate,
		  LEVEL_UP 					=> level_up,
		  STAGE_CLEAR 			=> stage_clear,
		  STAGE_SELECT_IN 	=> stage_select_in,
		  STAGE_SELECT_OUT 	=> stage_select,
		  LEVEL 						=> level
		 );
		 
--	   
--	 DIFFICULTY
--

difficulty_u0: entity work.difficulty
	   port map(
		  CLOCK 						=> CLOCK_50,
		  RESET 						=> reset,
		  LEVEL 						=> level,
		  PAUSE 						=> pause,
		  REFRESH_TICK 			=> refresh_tick,
		  MOVE 							=> move
		 );

--	   
--	LIVES
--	

	lives_u0: entity work.lives
	   port map(
		  CLOCK							=> CLOCK_50,
		  RESTART 					=> restart,
		  ITEM_ATE 					=> item_ate,
		  ITEM_TYPE					=> item_type,
		  HIT							 	=> head_on_wall or head_on_snake,
		  LIVES 						=> lives
		 );

--
--	TIMER
--	

	timer_u0: entity work.timer
		port map(
			CLOCK 						=> CLOCK_50,
			RESET 						=> reset,
			PIXEL_X 					=> pixel_x,
			PIXEL_Y 					=> pixel_y,
			REFRESH_TICK 			=> refresh_tick,
			TIMER_START 			=> timer_start,
			TIMER_UP 					=> timer_up
		);

--	   
--	TIMER2
--		
	timer2_u0 :	entity work.timer2
	   port map(
		  CLOCK 						=> CLOCK_50,
		  TIMER2_RESET 			=> timer2_reset,
		  REFRESH_TICK 			=> refresh_tick,
		  TIMER2_START 			=> timer2_start,
		  TIMER2_UP 				=> timer2_up
		 );

end arch;