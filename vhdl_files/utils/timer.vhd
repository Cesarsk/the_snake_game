library ieee;
	use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
entity timer is

   port(
     CLOCK           : in std_logic;
	  RESET           : in std_logic;
	  REFRESH_TICK    : in std_logic;
     TIMER_START     : in std_logic;
     PIXEL_X         : in std_logic_vector(9 downto 0);
	  PIXEL_Y         : in std_logic_vector(9 downto 0);
     TIMER_UP        : out std_logic
   );

end timer;

-- The counters we used count backwards. The logic of a timer is clearly one 
architecture arch of timer is

   signal timer_register, timer_next : unsigned(6 downto 0);

begin
   -- registers
   process (CLOCK, RESET)
   begin
	-- RESET State: we need to initialize every value.
      if RESET = '1' then
         timer_register   <= (others =>'1');

      elsif (CLOCK'event and CLOCK = '1') then
	-- present State logic
         timer_register   <= timer_next;
      end if;

   end process;

   -- next-state logic
   process(TIMER_START, timer_register, REFRESH_TICK)

   begin
      if (TIMER_START = '1') then
         timer_next <= (others=>'1');

			-- it means we reached a tick and we need to decrease the value until we reach 0
      elsif REFRESH_TICK ='1' and timer_register /= 0 then
         timer_next <= timer_register - 1;

      else
         timer_next <= timer_register;
      end if;

   end process;

	-- when we reached 0 we set TIMER_UP to 0. Useful for handling animations.
   TIMER_UP <= '1' when timer_register = 0 else '0';

end arch;