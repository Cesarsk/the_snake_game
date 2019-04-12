-- COMMENTS ARE THE SAME AS IN THE TIMER COMPONENT, CHECK TIMER.VHD
library ieee;
	use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
entity timer2 is

   port(
      CLOCK          : in std_logic;
	   TIMER2_RESET   : in std_logic;
	   REFRESH_TICK   : in std_logic;
      TIMER2_START   : in std_logic;
      TIMER2_UP      : out std_logic
   );

end timer2;

architecture arch of timer2 is

   signal timer2_register, timer2_next: unsigned(9 downto 0);
begin
   -- registers
   process (CLOCK, TIMER2_RESET)

   begin
      if TIMER2_RESET = '1' then
         timer2_register <= "1000000000";

      elsif (CLOCK'event and CLOCK = '1') then
         timer2_register <= timer2_next;
      end if;

   end process;

   -- next-state logic
   process(TIMER2_START, timer2_register, REFRESH_TICK)

   begin
      if (TIMER2_START = '1') then
         timer2_next <= "1000000000";

      elsif REFRESH_TICK = '1' and timer2_register /= 0 then
         timer2_next <= timer2_register - 1;

      else
         timer2_next <= timer2_register;
      end if;

   end process;
   TIMER2_UP <= '1' when timer2_register = 0 else '0';

end arch;