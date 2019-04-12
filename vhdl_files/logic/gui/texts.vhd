-- Component used to handle texts in the game.
-- Here we need to handle every label that appears in the game creating them using the font rom.

-- The idea of the text generator is simple. When the vga scans each pixel on the screen, we need to check if this is a pixel on the text. Showing the text color when it's true and showing the background color when it's false.
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
library libs;
	use libs.the_snake_game_package.all;

entity texts is
   
   port(
      CLOCK                   : in std_logic;
      STATE                   : in std_logic_vector(7 downto 0);
      PIXEL_X                 : in std_logic_vector(9 downto 0);
      PIXEL_Y                 : in std_logic_vector(9 downto 0);
      BUTTONS                 : in std_logic_vector (3 downto 0);
      DIGIT_0                 : in std_logic_vector(3 downto 0);
      DIGIT_1                 : in std_logic_vector(3 downto 0);
      DIGIT_2                 : in std_logic_vector(3 downto 0);
      DIGIT_3                 : in std_logic_vector(3 downto 0);
      STAGE                   : in std_logic_vector(2 downto 0);
      LEVEL                   : in std_logic_vector(2 downto 0);
      LIVES                   : in std_logic_vector(2 downto 0);
      STAGE_SELECT_OUT        : out integer range 1 to 7;
      TEXT_ON                 : out std_logic_vector(7 downto 0);
      TEXT_RGB                : out std_logic_vector(2 downto 0)
   );

end texts;

architecture arch of texts is

   signal pix_x, pix_y        : unsigned(9 downto 0);
   -- font rom 
   signal rom_address         : std_logic_vector(10 downto 0);
   signal char_address        : std_logic_vector(6 downto 0);
   signal row_address         : std_logic_vector(3 downto 0);
   signal bit_address         : std_logic_vector(2 downto 0);
   signal font_word           : std_logic_vector(0 to 7);
   signal font_bit            : std_logic;
    
   --signature label (SIS. DIGITALI)
   signal row_address_signature_label                       : std_logic_vector(3 downto 0);
   signal bit_address_signature_label                       : std_logic_vector(2 downto 0);
   signal char_address_signature_label                      : std_logic_vector(6 downto 0);
   signal draw_signature_label_on, rd_signature_label_on    : std_logic;
	
	--signature2 label (PROF. FALDELLA)
   signal row_address_signature2_label                      : std_logic_vector(3 downto 0);
   signal bit_address_signature2_label                      : std_logic_vector(2 downto 0);
   signal char_address_signature2_label                     : std_logic_vector(6 downto 0);
   signal draw_signature2_label_on, rd_signature2_label_on  : std_logic;
	
	--signature3 label (CESARANO, CROCE)
   signal row_address_signature3_label                      : std_logic_vector(3 downto 0);
   signal bit_address_signature3_label                      : std_logic_vector(2 downto 0);
   signal char_address_signature3_label                     : std_logic_vector(6 downto 0);
   signal draw_signature3_label_on, rd_signature3_label_on  : std_logic;
	
	--score label
   signal row_address_score_label                           : std_logic_vector(3 downto 0);
   signal bit_address_score_label                           : std_logic_vector(2 downto 0);
   signal char_address_score_label                          : std_logic_vector(6 downto 0);
   signal draw_score_label_on, rd_score_label_on            : std_logic;
   
   -- score digitals
   signal row_address_score                                 : std_logic_vector(3 downto 0);
   signal bit_address_score                                 : std_logic_vector(2 downto 0);
   signal char_address_score                                : std_logic_vector(6 downto 0);
   signal draw_score_on, rd_score_on                        : std_logic;
   
   -- level
   signal row_address_level                                 : std_logic_vector(3 downto 0);
   signal bit_address_level                                 : std_logic_vector(2 downto 0);
   signal char_address_level                                : std_logic_vector(6 downto 0);
   signal draw_level_on, rd_level_on                        : std_logic;
   
   -- level_dig
   signal row_address_level_digit                           : std_logic_vector(3 downto 0);
   signal bit_address_level_digit                           : std_logic_vector(2 downto 0);
   signal char_address_level_digit                          : std_logic_vector(6 downto 0);
   signal draw_level_digit_on, rd_level_digit_on            : std_logic;
   
   -- lives
   signal row_address_lives                                 : std_logic_vector(3 downto 0);
   signal bit_address_lives                                 : std_logic_vector(2 downto 0);
   signal char_address_lives                                : std_logic_vector(6 downto 0);
   signal draw_lives_on, rd_lives_on                        : std_logic;
   
   -- lives_dig
   signal row_address_lives_digit                           : std_logic_vector(3 downto 0);
   signal bit_address_lives_digit                           : std_logic_vector(2 downto 0);
   signal char_address_lives_digit                          : std_logic_vector(6 downto 0);
   signal draw_lives_digit_on, rd_lives_digit_on            : std_logic;
   
   -- stage
   signal row_address_stage                                 : std_logic_vector(3 downto 0);
   signal bit_address_stage                                 : std_logic_vector(2 downto 0);
   signal char_address_stage                                : std_logic_vector(6 downto 0);
   signal draw_stage_on, rd_stage_on                        : std_logic;
   
   -- stageselect1
   signal row_address_stage_select_1                        : std_logic_vector(3 downto 0);
   signal bit_address_stage_select_1                        : std_logic_vector(2 downto 0);
   signal char_address_stage_select_1                       : std_logic_vector(6 downto 0);
   signal draw_stage_select_1_on, rd_stage_select_1_on      : std_logic;
   
   -- stageselect2
   signal row_address_stage_select_2                        : std_logic_vector(3 downto 0);
   signal bit_address_stage_select_2                        : std_logic_vector(2 downto 0);
   signal char_address_stage_select_2                       : std_logic_vector(6 downto 0);
   signal draw_stage_select_2_on, rd_stage_select_2_on      : std_logic;
   
   -- stage_dig
   signal row_address_stage_digit                           : std_logic_vector(3 downto 0);
   signal bit_address_stage_digit                           : std_logic_vector(2 downto 0);
   signal char_address_stage_digit                          : std_logic_vector(6 downto 0);
   signal draw_stage_digit_on, rd_stage_digit_on            : std_logic;
   
   -- stageclear
   signal row_address_stage_clear                           : std_logic_vector(3 downto 0);
   signal bit_address_stage_clear                           : std_logic_vector(2 downto 0);
   signal char_address_stage_clear                          : std_logic_vector(6 downto 0);
   signal draw_stage_clear_on, rd_stage_clear_on            : std_logic;
   
   -- gameover
   signal row_address_game_over                             : std_logic_vector(3 downto 0);
   signal bit_address_game_over                             : std_logic_vector(2 downto 0);
   signal char_address_game_over                            : std_logic_vector(6 downto 0);
   signal draw_game_over_on, rd_game_over_on                : std_logic;
   
   -- stageselect
   signal row_address_stage_select                          : std_logic_vector(3 downto 0);
   signal bit_address_stage_select                          : std_logic_vector(2 downto 0);
   signal char_address_stage_select                         : std_logic_vector(6 downto 0);
   signal draw_stage_select_on, rd_stage_select_on          : std_logic;
   
   -- newgame
   signal row_address_new_game                              : std_logic_vector(3 downto 0);
   signal bit_address_new_game                              : std_logic_vector(2 downto 0);
   signal char_address_new_game                             : std_logic_vector(6 downto 0);
   signal draw_new_game_on, rd_new_game_on                  : std_logic;
   
   -- pause
   signal row_address_pause                                 : std_logic_vector(3 downto 0);
   signal bit_address_pause                                 : std_logic_vector(2 downto 0);
   signal char_address_pause                                : std_logic_vector(6 downto 0);
   signal draw_pause_on, rd_pause_on                        : std_logic;
   
   -- level up
   signal row_address_level_up                              : std_logic_vector(3 downto 0);
   signal bit_address_level_up                              : std_logic_vector(2 downto 0);
   signal char_address_level_up                             : std_logic_vector(6 downto 0);
   signal draw_level_up_on, rd_level_up_on                  : std_logic;
	
	-- bar
	signal bar_on                                            : std_logic;
	signal bar_x                                             : unsigned(9 downto 0);
	signal bar_y                                             : unsigned(9 downto 0);
	signal stage_display                                     : std_logic_vector(2 downto 0);
	signal stage_select_out_temp                             : integer range 1 to 7;

   begin
	-- Stage selecting phase before initializing a new game.
   stage_display  <= std_logic_vector(to_unsigned(stage_select_out_temp,3)) when STATE(6)='1' else STAGE;
   pix_x          <= unsigned(PIXEL_X);
   pix_y          <= unsigned(PIXEL_Y);
   bar_on         <= '1' when (bar_x <= unsigned(PIXEL_X) and unsigned(PIXEL_X) < bar_x + 16) 
							      and (bar_y <= unsigned(PIXEL_Y) and unsigned(PIXEL_Y) < bar_y + 16)
							      and LEVEL_PICKER_ROM(to_integer(unsigned(PIXEL_Y(3 downto 0)) - bar_y(3 downto 0)))(to_integer(unsigned(PIXEL_X(3 downto 0)) - bar_x(3 downto 0)))='1'
					            else '0';
					
	-- X Coordinate: Stage 1: 160 px - Stage 2: 448 px
   bar_x          <= "0010100000" when  BUTTONS(2)='1' and STATE(6)='1' else
			            "0111000000" when  BUTTONS(3)='1' and STATE(6)='1' else
			            bar_x;
			
	-- Y Coordinate: 360 px
	bar_y                   <= "0101101000";
   STAGE_SELECT_OUT        <= stage_select_out_temp;
	-- picking stage according to the x coordinate
   stage_select_out_temp   <= 1 when bar_x="0010100000" else 2;
   
   -- instantiate font rom
   font_unit: entity work.font_rom
      port map(CLOCK=>CLOCK, ADDRESS=>rom_address, DATA=>font_word);
	
	-- font rom interface 
	rom_address             <= char_address & row_address;
   font_bit                <= font_word(to_integer(unsigned(bit_address)));
   
	-- signature label
   draw_signature_label_on     <=
                                 '1' when pix_y(9 downto 5) = 13 and -- 0 -> 31px y
                                 1 <= pix_x(9 downto 4) and pix_x(9 downto 4) < 16
					                  and STATE(7) = '1'
					                  else '0';
   row_address_signature_label <= std_logic_vector(pix_y(4 downto 1));
   bit_address_signature_label <= std_logic_vector(pix_x(3 downto 1));
	
	-- SIS. DIGITALI - PROF. E.FALDELLA - L.CESARANO, A.CROCE
	
	-- S   I   S   .   blank D   I   G   I   T   A   L   I   blank -
	--x53 x49 x53 x2e blank x44 x49 x47 x49 x54 x41 x4c x49 blank x2d
	
   with pix_x(7 downto 4) select
     char_address_signature_label <=
        "1010011" when "0001", -- S x53
        "1001001" when "0010", -- I x49
        "1010011" when "0011", -- S x53
        "0101110" when "0100", -- . X2E
        "0000000" when "0101", -- SPACE
        "1000100" when "0110", -- D X44
		  "1001001" when "0111", -- I x49
        "1000111" when "1000", -- G X47
        "1001001" when "1001", -- I x49
        "1010100" when "1010", -- T x54
        "1000001" when "1011", -- A x41
        "1001100" when "1100", -- L x4c
        "1001001" when "1101", -- I X49
        "0000000" when "1110", -- SPACE
        "0101101" when "1111", -- - x2d
        "0000000" when others;
	
	-- signature2 label
   draw_signature2_label_on <=
      '1' when pix_y(9 downto 5) = 13 and -- 0 -> 31px y
               17<= pix_x(9 downto 4) and pix_x(9 downto 4) < 32
					and STATE(7) = '1'
					else '0';
   row_address_signature2_label <= std_logic_vector(pix_y(4 downto 1));
   bit_address_signature2_label <= std_logic_vector(pix_x(3 downto 1));
	
	-- SIS. DIGITALI - PROF. E.FALDELLA - L.CESARANO, A.CROCE

	--P   R   O   F   .   blank  E   .   F   A   L   D   E   L   L   A   -   blank
	--x50 x52 x4f x46 x2e blank  x45 x2e x46 x41 x4c x44 x45 x4c x4c x41 x2d blank
	
   with pix_x(7 downto 4) select
     char_address_signature2_label <=
        "1010000" when "0001", -- P x50
        "1010010" when "0010", -- R x52
        "1001111" when "0011", -- O x4f
        "1000110" when "0100", -- F X46
        "0101110" when "0101", -- . X2E
        "1000110" when "0110", -- F X46
		  "1000001" when "0111", -- A X41
        "1001100" when "1000", -- L x4c
        "1000100" when "1001", -- D X44
        "1000101" when "1010", -- E x45
        "1001100" when "1011", -- L x4C
        "1001100" when "1100", -- L x4c
        "1000001" when "1101", -- A X41
        "0000000" when others;
	
	-- signature3 label
   draw_signature3_label_on <=
      '1' when pix_y(9 downto 5) = 14 and -- 0 -> 31px y
               17 <= pix_x(9 downto 4) and pix_x(9 downto 4) < 32
					and STATE(7) = '1'
					else '0';
   row_address_signature3_label <= std_logic_vector(pix_y(4 downto 1));
   bit_address_signature3_label <= std_logic_vector(pix_x(3 downto 1));
	
	-- SIS. DIGITALI - PROF. E.FALDELLA - L.CESARANO, A.CROCE

	--C   E   S   A   R   A   N   O    ,   blank   C   R   O   C   E
	--x43 x45 x53 x41 x52 x41 x4e x4f x2c  blank   x43 x52 x4f x43 x46
	
   with pix_x(7 downto 4) select
     char_address_signature3_label <=
        "1000011" when "0001", -- C x43
        "1000101" when "0010", -- E x45
        "1010011" when "0011", -- S X53
        "1000001" when "0100", -- A X41
        "1010010" when "0101", -- R x52
        "1000001" when "0110", -- A X41
		  "1001110" when "0111", -- N x4e
        "1001111" when "1000", -- O X4F
        "0101100" when "1001", -- , X2C
        "0000000" when "1010", -- SPACE
        "1000011" when "1011", -- C x43
        "1010010" when "1100", -- R x52
        "1001111" when "1101", -- O X4f
		  "1000011" when "1110", -- C x43
		  "1000101" when "1111", -- E x45
        "0000000" when others;
	
	-- score label
   draw_score_label_on <=
      '1' when pix_y(9 downto 5) = 0 and -- 0 -> 31px y
               pix_x(9 downto 4) < 11  else
      '0';

   row_address_score_label <= std_logic_vector(pix_y(4 downto 1));
   bit_address_score_label <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
     char_address_score_label <=
        "1010011" when "0001", -- S x53
        "1100011" when "0010", -- c x63
        "1101111" when "0011", -- o x6f
        "1110010" when "0100", -- r x72
        "1100101" when "0101", -- e x65
        "0111010" when "0110", -- : x3a
        "0000000" when others;
    ----------------------------------------------
	-- score digits
   draw_score_on <=
      '1' when pix_y(9 downto 5)= 1 and -- 32->63px y
               2 <= pix_x(9 downto 4) and pix_x(9 downto 4) < 11  else
      '0';
   row_address_score <= std_logic_vector(pix_y(4 downto 1));
   bit_address_score <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
     char_address_score <=
        "011" & DIGIT_3 when "0010",
        "011" & DIGIT_2 when "0011", 
        "011" & DIGIT_1 when "0100",
        "011" & DIGIT_0 when "0101",
        "0000000" when others;
    ----------------------------------------------
	-- lives label
	draw_lives_on <=
      '1' when pix_y(9 downto 5)= 0 and -- 32->63px y
           16 <= pix_x(9 downto 5) and pix_x(9 downto 5) <= 19 else
      '0';
   row_address_lives <= std_logic_vector(pix_y(4 downto 1));
   bit_address_lives <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
     char_address_lives <=
        "1001100" when "0001", -- L x4c
        "1101001" when "0010", -- i x69
        "1110110" when "0011", -- v x76
        "1100101" when "0100", -- e x65
        "1110011" when "0101", -- s x73
        "0111010" when "0110", -- : x3a
        "0000000" when others;
    -------------------------------------------------------
	-- level digits
		draw_level_digit_on <=
		  '0' when pix_y(9 downto 5)= 1 and -- 32->63px y
           17 <= pix_x(9 downto 5) and pix_x(9 downto 5) <= 20 else
		  '0';
	   row_address_level_digit <= std_logic_vector(pix_y(4 downto 1));
	   bit_address_level_digit <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
		 char_address_level_digit <=
			"0110" & LEVEL when "0001",
			"0000000" when others;
    -------------------------------------------------------
	-- level label
    draw_level_on <=
      '0' when pix_y(9 downto 5)= 0 and -- 32->63px y
               8 <= pix_x(9 downto 5) and pix_x(9 downto 5) <= 12 else
      '0';
   row_address_level <= std_logic_vector(pix_y(4 downto 1));
   bit_address_level <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
     char_address_level <=
        "1001100" when "0010", -- L x4c
        "1100101" when "0011", -- e x65
        "1110110" when "0100", -- v x76
        "1100101" when "0101", -- e x65
        "1101100" when "0110", -- l x6c
        "0111010" when "0111", -- : x3a
        "0000000" when others;
    ----------------------------------------------
	-- lives digits
	draw_lives_digit_on <=
      '1' when pix_y(9 downto 5)= 1 and -- 32->63px y
           17 <= pix_x(9 downto 5) and pix_x(9 downto 5) <= 20 else
      '0';
   row_address_lives_digit <= std_logic_vector(pix_y(4 downto 1));
   bit_address_lives_digit <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
     char_address_lives_digit <=
        "0110" & LIVES when "0101",
        "0000000" when others;
   --------------------------------------------------------------
	-- stage label
    draw_stage_on <=
      '1' when pix_y(9 downto 5) = 0 and -- 32->63px y
               8 <= pix_x(9 downto 5) and pix_x(9 downto 5) <= 12 else
      '0';
   row_address_stage <= std_logic_vector(pix_y(4 downto 1));
   bit_address_stage <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
     char_address_stage <=
        "1010011" when "0001", -- S x53
        "1110100" when "0010", -- t x74
        "1100001" when "0011", -- a x61
        "1100111" when "0100", -- g x67
        "1100101" when "0101", -- e x65
        "0111010" when "0110", -- : x3a
        "0000000" when others;
    ----------------------------------------------
	-- stage 1 label
	draw_stage_select_1_on <=
      '1' when pix_y(9 downto 5)= 10 and -- 32->63px y
               1 <= pix_x(9 downto 5) and pix_x(9 downto 5) <= 8 and STATE(6) = '1'
          else '0';
   row_address_stage_select_1 <= std_logic_vector(pix_y(4 downto 1));
   bit_address_stage_select_1 <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
     char_address_stage_select_1 <=
        "1010011" when "0111", -- S x53
        "1110100" when "1000", -- t x74
        "1100001" when "1001", -- a x61
        "1100111" when "1010", -- g x67
        "1100101" when "1011", -- e x65
        "0000000" when "1100",
        "0110001" when "1101", -- 1 x3a
        "0000000" when others;
    -------------------------------------------------
	-- stage 2 label
	draw_stage_select_2_on <=
		  '1' when pix_y(9 downto 5)= 10 and -- 32->63px y
               9 <= pix_x(9 downto 5) and pix_x(9 downto 5) <= 16 and STATE(6) = '1'
			  else '0';
   row_address_stage_select_2 <= std_logic_vector(pix_y(4 downto 1));
	bit_address_stage_select_2 <= std_logic_vector(pix_x(3 downto 1));
   
   with pix_x(7 downto 4) select
		char_address_stage_select_2 <=
         "1010011" when "1001", -- S x53
         "1110100" when "1010", -- t x74
         "1100001" when "1011", -- a x61
         "1100111" when "1100", -- g x67
         "1100101" when "1101", -- e x65
         "0000000" when "1110",
			"0110010" when "1111", -- 2 x3a
			"0000000" when others;
    ----------------------------------------------
	-- stage digits
	draw_stage_digit_on <=
      '1' when pix_y(9 downto 5)= 1 and -- 32->63px y
               8 <= pix_x(9 downto 5) and pix_x(9 downto 5)<= 12 else
      '0';
   row_address_stage_digit <= std_logic_vector(pix_y(4 downto 1));
   bit_address_stage_digit <= std_logic_vector(pix_x(3 downto 1));
   with pix_x(7 downto 4) select
     char_address_stage_digit <=
        "0110" & stage_display when "0101",
        "0000000" when others;    
   --------------------------------------------------------------
	-- new game label
    draw_new_game_on <=
      '1' when pix_y(9 downto 6) = 3 and
           6 <= pix_x(9 downto 5) and pix_x(9 downto 5)<= 17		     
       and STATE(7)='1'
       else '0';
   row_address_new_game <= std_logic_vector(pix_y(5 downto 2));
   bit_address_new_game <= std_logic_vector(pix_x(4 downto 2));
   with pix_x(8 downto 5) select
   char_address_new_game <=
        "1001110" when "0110", -- N x4e
        "1100101" when "0111", -- e x65
        "1110111" when "1000", -- w x77
        "0000000" when "1001", --   
        "1000111" when "1010", -- G x47
        "1100001" when "1011", -- a x61
        "1101101" when "1100", -- m x6d
        "1100101" when "1101", -- e x65 
        "0000000" when others;
       ------------------------------------------
	-- level up label
    draw_level_up_on <=
      '1' when pix_y(9 downto 6)= 3 and
           6 <= pix_x(9 downto 5) and pix_x(9 downto 5)<= 17 
        and STATE(3)='1'
        else '0';
   row_address_level_up <= std_logic_vector(pix_y(5 downto 2));
   bit_address_level_up <= std_logic_vector(pix_x(4 downto 2));
   with pix_x(8 downto 5) select
   char_address_level_up <=
        "1001100" when "0110", -- L x4c
        "1100101" when "0111", -- e x65
        "1110110" when "1000", -- v x76
        "1100101" when "1001", -- e x65
        "1101100" when "1010", -- l x6c
        "0000000" when "1011", --  
        "1110101" when "1100", -- u x75
        "1110000" when "1101", -- p x70 
        "0000000" when others;
    --------------------------------------------------

	-- pause label
    draw_pause_on <=
      '1' when pix_y(9 downto 6)= 3 and
           8 <= pix_x(9 downto 5) and pix_x(9 downto 5)<= 18 
           and STATE(4)='1'
        else '0';
   row_address_pause <= std_logic_vector(pix_y(5 downto 2));
   bit_address_pause <= std_logic_vector(pix_x(4 downto 2));
   with pix_x(8 downto 5) select
   char_address_pause <=
        "1010000" when "1000", -- P x50
        "1100001" when "1001", -- a x61
        "1110101" when "1010", -- u x75
        "1110011" when "1011", -- s x73
        "1100101" when "1100", -- e x65 
        "0000000" when others;
     ---------------------------------------------------------------
	  -- game over label
    draw_game_over_on <=
      '1' when pix_y(9 downto 6)= 3 and
           6 <= pix_x(9 downto 5) and pix_x(9 downto 5)<= 17 
           and STATE(0)='1'
        else '0';
   row_address_game_over <= std_logic_vector(pix_y(5 downto 2));
   bit_address_game_over <= std_logic_vector(pix_x(4 downto 2));
   with pix_x(8 downto 5) select
   char_address_game_over <=
        "1000111" when "0110", -- G x47
        "1100001" when "0111", -- a x61
        "1101101" when "1000", -- m x6d
        "1100101" when "1001", -- e x65
        "0000000" when "1010", --
        "1001111" when "1011", -- O x4f
        "1110110" when "1100", -- v x76
        "1100101" when "1101", -- e x65
        "1110010" when "1110", -- r x72
        "0000000" when others;
   ----------------------------------------------------------
	-- stage clear label
	draw_stage_clear_on <=
      '1' when pix_y(9 downto 6)= 3 and
           7 <= pix_x(9 downto 5) and pix_x(9 downto 5)<= 17 
           and STATE(1)='1'
        else '0';
   row_address_stage_clear <= std_logic_vector(pix_y(5 downto 2));
   bit_address_stage_clear <= std_logic_vector(pix_x(4 downto 2));
   with pix_x(8 downto 5) select
   char_address_stage_clear <=
        "0000000" when "0111", -- 
        "1000011" when "1000", -- S -> C x53 -> x43 
        "1101100" when "1001", -- t -> l x74 -> x6c
        "1100101" when "1010", -- a -> e x61 -> x73
        "1100001" when "1011", -- g -> a x67 -> x61 
        "1110010" when "1100", -- e -> r x73 -> x72
        "0000000" when "1101", -- 
       -- "1110" & stage when "1111",
        "0000000" when others;
    -----------------------------------------------
	 -- select label
	draw_stage_select_on <=
		  '1' when pix_y(9 downto 6)= 3 and
			   7 <= pix_x(9 downto 5) and pix_x(9 downto 5)<= 17 
			   and STATE(6)='1'
			else '0';
	   row_address_stage_select <= std_logic_vector(pix_y(5 downto 2));
	   bit_address_stage_select <= std_logic_vector(pix_x(4 downto 2));
	   with pix_x(8 downto 5) select
	   char_address_stage_select <=
			"1010011" when "0111", -- S x53
			"1100101" when "1000", -- e x65 
			"1101100" when "1001", -- l x6c
			"1100101" when "1010", -- e x65
			"1100011" when "1011", -- c x63 
			"1110100" when "1100", -- t x74 
			"0000000" when others;
    ----------------------------------------------
	 -- The following picks the label (from the font rom) that has to be inserted in the gui.
	char_address <=
				char_address_signature3_label when draw_signature3_label_on='1' else	
				char_address_signature2_label when draw_signature2_label_on='1' else
				char_address_signature_label when draw_signature_label_on='1' else
				char_address_score_label when draw_score_label_on='1' else 
				char_address_score		 when draw_score_on='1' 		else
				char_address_level		 when draw_level_on='1' 		else
				char_address_level_digit   when draw_level_digit_on='1' 	else
				char_address_stage		 when draw_stage_on='1' 		else
				char_address_stage_select_1		 when draw_stage_select_1_on='1' 		else
				char_address_stage_select_2		 when draw_stage_select_2_on='1' 		else
				char_address_stage_digit   when draw_stage_digit_on='1' 	else
				char_address_lives		 when draw_lives_on='1' 		else
				char_address_lives_digit   when draw_lives_digit_on='1' 	else
				char_address_new_game     when draw_new_game_on='1'  	else
				char_address_level_up     when draw_level_up_on='1' 	else
				char_address_pause    	 when draw_pause_on='1' 		else
				char_address_game_over    when draw_game_over_on='1' 	else
				char_address_stage_clear  when draw_stage_clear_on='1' 	else
				char_address_stage_select  when draw_stage_select_on='1' 	else
				"0000000";
	row_address <=
				row_address_signature3_label when draw_signature3_label_on='1' else
				row_address_signature2_label when draw_signature2_label_on='1' else
				row_address_signature_label when draw_signature_label_on='1' else
				row_address_score_label when draw_score_label_on='1' else 
				row_address_score		 when draw_score_on='1' 		else 
				row_address_level		 when draw_level_on='1' 		else
				row_address_level_digit	 when draw_level_digit_on='1' 	else
				row_address_stage		 when draw_stage_on='1' 		else
				row_address_stage_select_1		 when draw_stage_select_1_on='1' 		else
				row_address_stage_select_2		 when draw_stage_select_2_on='1' 		else
				row_address_stage_digit	 when draw_stage_digit_on='1' 	else
				row_address_lives		 when draw_lives_on='1' 		else
				row_address_lives_digit	 when draw_lives_digit_on='1' 	else
				row_address_new_game	 when draw_new_game_on='1' 	else
				row_address_level_up	 when draw_level_up_on='1' 	else
				row_address_pause	     when draw_pause_on='1' 		else
				row_address_game_over	 when draw_game_over_on='1' 	else
				row_address_stage_clear	 when draw_stage_clear_on='1' 	else
				row_address_stage_select	 when draw_stage_select_on='1' 	else
				"0000";
	bit_address <=
				bit_address_signature3_label when draw_signature3_label_on='1' else
				bit_address_signature2_label when draw_signature2_label_on='1' else
				bit_address_signature_label when draw_signature_label_on='1' else
				bit_address_score_label when draw_score_label_on='1' else 
				bit_address_score		 when draw_score_on='1' 		else
				bit_address_level		 when draw_level_on='1' 		else 
				bit_address_level_digit	 when draw_level_digit_on='1' 	else 
				bit_address_stage	 	 when draw_stage_on='1' 		else 
				bit_address_stage_select_1	 	 when draw_stage_select_1_on='1' 		else 
				bit_address_stage_select_2	 	 when draw_stage_select_2_on='1' 		else 
				bit_address_stage_digit	 when draw_stage_digit_on='1' 	else 
				bit_address_lives		 when draw_lives_on='1' 		else
				bit_address_lives_digit	 when draw_lives_digit_on='1' 	else
				bit_address_new_game 	 when draw_new_game_on='1' 	else
				bit_address_level_up 	 when draw_level_up_on='1' 	else
				bit_address_pause 	 	 when draw_pause_on='1' 		else
				bit_address_game_over	 when draw_game_over_on='1' 	else
				bit_address_stage_clear	 when draw_stage_clear_on='1' 	else
				bit_address_stage_select	 when draw_stage_select_on='1' 	else
				"000";
	--------------------------------------------------------	
	-- Conditions when labels need to appear on the screen.
	rd_signature3_label_on <= draw_signature3_label_on and font_bit;
	rd_signature2_label_on <= draw_signature2_label_on and font_bit;
	rd_signature_label_on <= draw_signature_label_on and font_bit;
	rd_score_label_on <= draw_score_label_on  and  font_bit;
	rd_score_on <= draw_score_on  and  font_bit;
	rd_level_on <= draw_level_on  and  font_bit;
	rd_level_digit_on <= draw_level_digit_on  and  font_bit;
	rd_stage_on <= draw_stage_on  and  font_bit;
	rd_stage_select_1_on <= draw_stage_select_1_on  and  font_bit;
	rd_stage_select_2_on <= draw_stage_select_2_on  and  font_bit;
	rd_stage_digit_on <= draw_stage_digit_on  and  font_bit;
	rd_stage_clear_on <= draw_stage_clear_on  and  font_bit;
	rd_stage_select_on <= draw_stage_select_on  and  font_bit;
	rd_lives_on <= draw_lives_on  and  font_bit;
	rd_lives_digit_on <= draw_lives_digit_on  and  font_bit;
	rd_game_over_on <=  draw_game_over_on  and  font_bit;
	rd_new_game_on <= draw_new_game_on  and  font_bit;
	rd_level_up_on <= draw_level_up_on  and  font_bit;
	rd_pause_on <= draw_pause_on  and  font_bit;
	--------------------------------------------------------	
   process(rd_signature3_label_on, rd_signature2_label_on, rd_signature_label_on, rd_score_label_on, rd_score_on, rd_level_on,rd_lives_on , rd_stage_digit_on, rd_stage_on, 
			rd_level_digit_on, rd_lives_digit_on , rd_game_over_on, rd_new_game_on,rd_level_up_on,rd_pause_on, 
			rd_stage_clear_on,rd_stage_select_1_on,rd_stage_select_2_on, rd_stage_select_on, bar_on)
   begin
	-- COLOR SELECT of every label in the game.
		if rd_signature3_label_on = '1' or rd_signature2_label_on = '1' or rd_signature_label_on = '1' or rd_score_label_on = '1' or rd_level_on = '1' or rd_lives_on = '1' or rd_stage_on = '1' then
			TEXT_RGB <= "111";
		elsif rd_score_on = '1' or rd_level_digit_on = '1' or rd_lives_digit_on = '1' or rd_stage_digit_on = '1' then
			TEXT_RGB <= "110";
		elsif rd_new_game_on = '1' then
			TEXT_RGB <= "110";
		elsif (rd_stage_select_on = '1' or rd_stage_select_1_on = '1' or rd_stage_select_2_on = '1' or bar_on = '1') then
			TEXT_RGB <= "110";
		elsif rd_pause_on = '1' then
			TEXT_RGB <= "100";
		elsif rd_level_up_on = '1' then
			TEXT_RGB <= "110";
		elsif rd_stage_clear_on = '1' then
			TEXT_RGB <= "110";
		elsif rd_game_over_on = '1' then
			TEXT_RGB <= "100";
		else
			TEXT_RGB <= "000";
		end if;
   end process;
	
	-- GUI appears in the game
   TEXT_ON <= (rd_signature3_label_on 
   or rd_signature2_label_on 
   or rd_signature_label_on 
   or rd_score_label_on 
   or rd_score_on 
   or rd_level_on 
   or rd_lives_on 
   or rd_level_digit_on 
   or rd_lives_digit_on 
   or rd_stage_on 
   or rd_stage_digit_on)  
   &  rd_new_game_on 
   & (bar_on or rd_stage_select_on 
      or rd_stage_select_1_on 
      or rd_stage_select_2_on) & rd_level_up_on & rd_pause_on & rd_stage_clear_on & rd_game_over_on & '0';
end arch;