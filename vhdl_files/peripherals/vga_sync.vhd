library ieee;
	use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
library libs;
   use libs.the_snake_game_package.all;
   
entity vga_sync is

   port(
      CLOCK                   : in std_logic;
      RESET                   : in std_logic;
      HORIZONTAL_SYNC         : out std_logic;
      VERTICAL_SYNC           : out std_logic;
      VIDEO_ON                : out std_logic;
      PIXEL_TICK              : out std_logic;
      REFRESH_TICK            : out std_logic;
      PIXEL_X                 : out std_logic_vector (9 downto 0);
      PIXEL_Y                 : out std_logic_vector (9 downto 0)
    );

end vga_sync;

architecture arch of vga_sync is

   -- mod-2 counter
   signal mod2_register, mod2_next                                : std_logic;

   -- sync counters
   signal vertical_counter_register, vertical_counter_next        : unsigned(9 downto 0);
   signal horizontal_counter_register, horizontal_counter_next    : unsigned(9 downto 0);

   -- output buffer
   signal vertical_sync_register, horizontal_sync_register        : std_logic;
   signal vertical_sync_next, horizontal_sync_next                : std_logic;

   -- status signal
   signal horizontal_end, vertical_end, p_tick                    : std_logic;

begin
   -- registers
   process (CLOCK, RESET)

   begin

      if RESET = '1' then
         mod2_register                    <= '0';
         vertical_counter_register        <= (others => '0');
         horizontal_counter_register      <= (others => '0');
         vertical_sync_register           <= '0';
         horizontal_sync_register         <= '0';

      elsif (CLOCK'event and CLOCK = '1') then
         mod2_register                    <= mod2_next;
         vertical_counter_register        <= vertical_counter_next;
         horizontal_counter_register      <= horizontal_counter_next;
         vertical_sync_register           <= vertical_sync_next;
         horizontal_sync_register         <= horizontal_sync_next;
      end if;

   end process;

   -- mod-2 circuit to generate 25 MHz enable tick
   mod2_next <= not mod2_register;

   -- 25 MHz pixel tick
   p_tick <= '1' when mod2_register = '1' else '0';

   -- status
   horizontal_end <=  -- end of horizontal counter
      '1' when horizontal_counter_register=(HORIZONTAL_DISPLAY+HORIZONTAL_FRONT_PORCH+HORIZONTAL_BACK_PORCH+HORIZONTAL_RETRACE-1) else '0';  --799

   vertical_end <=  -- end of vertical counter
      '1' when vertical_counter_register=(VERTICAL_DISPLAY + VERTICAL_FRONT_PORCH + VERTICAL_BACK_PORCH + VERTICAL_RETRACE - 1) else '0';    --524      

   -- mod-800 horizontal sync counter
   process (horizontal_counter_register, horizontal_end, p_tick)

   begin
      if p_tick = '1' then  -- 25 MHz tick
         if horizontal_end='1' then horizontal_counter_next <= (others=>'0');
         else
            horizontal_counter_next <= horizontal_counter_register + 1;
         end if;
      else
         horizontal_counter_next    <= horizontal_counter_register;
      end if;

   end process;
   -- mod-525 vertical sync counter
   process (vertical_counter_register, horizontal_end, vertical_end, p_tick)

   begin
      if p_tick = '1' and horizontal_end = '1' then
         if (vertical_end = '1') then vertical_counter_next <= (others => '0');

         else
            vertical_counter_next <= vertical_counter_register + 1;
         end if;

         else
         vertical_counter_next <= vertical_counter_register;
      end if;

   end process;

   -- horizontal and vertical sync, buffered to avoid glitch
   horizontal_sync_next <= '1' when (horizontal_counter_register >= (HORIZONTAL_DISPLAY + HORIZONTAL_FRONT_PORCH))                   --656
           and (horizontal_counter_register <= (HORIZONTAL_DISPLAY + HORIZONTAL_FRONT_PORCH + HORIZONTAL_RETRACE - 1)) else '0';         --751

   vertical_sync_next <= '1' when (vertical_counter_register >= (VERTICAL_DISPLAY + VERTICAL_FRONT_PORCH))                           --490
           and (vertical_counter_register <= (VERTICAL_DISPLAY + VERTICAL_FRONT_PORCH + VERTICAL_RETRACE - 1)) else '0';                 --491
      
   -- video on/off
   VIDEO_ON <= '1' when (horizontal_counter_register < HORIZONTAL_DISPLAY) and (vertical_counter_register < VERTICAL_DISPLAY) else '0';

   -- output signal
   HORIZONTAL_SYNC      <= horizontal_sync_register;
   VERTICAL_SYNC        <= vertical_sync_register;
   PIXEL_X              <= std_logic_vector(horizontal_counter_register);
   PIXEL_Y              <= std_logic_vector(vertical_counter_register);
   PIXEL_TICK           <= p_tick;
   REFRESH_TICK         <= '1' when horizontal_counter_register = "0000000000" and vertical_counter_register = "0000000000" else '0';

end arch;
