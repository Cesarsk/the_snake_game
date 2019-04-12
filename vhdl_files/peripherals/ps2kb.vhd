library ieee; 
	use ieee.std_logic_1164.all;

entity ps2kb is

    port ( 
           PS2_CLOCK						: in  std_logic;
           PS2_DEBOUNCE						: in  std_logic;
           CLOCK							: in  std_logic;
           BUTTONS							: out  std_logic_vector  
		   );
		   
end ps2kb;

architecture Behavioral of ps2kb is

	signal ps2rx							: std_logic; -- ps2 received one byte
	signal ps2rxd1							: std_logic_vector(7 downto 0); -- last byte
	signal ps2rxd2							: std_logic_vector(7 downto 0); -- pre last byte
	signal ps2rxd3							: std_logic_vector(7 downto 0); -- pre pre last byte
	signal ps2_temp							: std_logic_vector(7 downto 0); -- temp register for ps2rx
	signal ps2_clock_register				: std_logic_vector (15 downto 0); -- clock debounce shift reg
	signal ps2_clock_debounce				: std_logic; -- filtered ps2 clock
	
	-- Indicates on which bit we are actually working on
	signal ps2rxstate						: integer range 0 to 11;
	
	-- Array for received data (keys pressed and which ones) temp. Its values get pushed to BUTTONS.
	signal buttons_temp						: std_logic_vector (6 downto 0);
	
begin

	process(CLOCK)

	begin
		if (CLOCK'event and CLOCK = '1') then
			-- & concatenation operator. you join 15 elements of ps2register e PS2_CLOCK in ps2_clock_register
			ps2_clock_register <=  ps2_clock_register(14 downto 0) & PS2_CLOCK;
		end if;

	end process;
	
	-- ps2_clock_debounce
	ps2_clock_debounce <= '0' when ps2_clock_register = "1111111111111111" else
			   '1' when ps2_clock_register = "0000000000000000" else
			   ps2_clock_debounce;
	-- PS2 rx
	process (ps2_clock_debounce)

	begin
		if ps2_clock_debounce'event and ps2_clock_debounce = '0' then
			ps2rx <= '0';

			case ps2rxstate is
			-- It's 11 bits for communication (0 - start, 1-8 - data, 9 - parity, 10 - stop). You start from 0 e you increase until you reach the stop bit.
				when 0 => --start bit
					if PS2_DEBOUNCE = '0' then 
						ps2rxstate <= ps2rxstate + 1;
					end if;

				when 9 => --parity bits
					if '1' = (PS2_DEBOUNCE xor ps2_temp(0) xor ps2_temp(1) xor ps2_temp(2) xor ps2_temp(3) xor ps2_temp(4) xor ps2_temp(5) xor ps2_temp(6) xor ps2_temp(7)) then
						ps2rxd3 <= ps2rxd2;
						ps2rxd2 <= ps2rxd1;
						ps2rxd1 <= ps2_temp;
						ps2rx 	<= '1';
					end if;
					ps2rxstate 	<= ps2rxstate+1;

				when 10 => --stop bit
					if PS2_DEBOUNCE = '1' then 
						ps2rxstate 	<= 0;
					end if;

				when others => -- data bits
					ps2_temp 	<= PS2_DEBOUNCE & ps2_temp(7 downto 1);
					ps2rxstate 	<= ps2rxstate + 1;
			end case;
		end if;
		
	end process;
	-- keys: 0-dn, 1-up, 2-left, 3-right, 4-enter, 5-space, 6-esc
	process (ps2rx)

	begin
	if ps2rx'event and ps2rx = '0' then
	
			-- DOWN ARROW BUTTON
			if ps2rxd1 = X"72" and (ps2rxd2 = X"E0" xor ps2rxd3 = X"E0") then
				if ps2rxd2 = X"F0" then
					buttons_temp(0) <= '0';
				else
					buttons_temp(0) <= '1';
				end if;
			end if;
			
			-- UP ARROW BUTTON
			if ps2rxd1 = X"75" and (ps2rxd2 = X"E0" xor ps2rxd3 = X"E0") then
				-- X"F0" IS BREAK CODE: IF THE KEY IS NOT PRESSED, val = 0; OTHERWISE, val = 1.
				if ps2rxd2 = X"F0" then
					buttons_temp(1) <= '0';
				else
					buttons_temp(1) <= '1';
				end if;
			end if;
			
			-- LEFT ARROW BUTTON
			if ps2rxd1 = X"6B" and (ps2rxd2 = X"E0" xor ps2rxd3 = X"E0") then
				if ps2rxd2 = X"F0" then
					buttons_temp(2) <= '0';
				else
					buttons_temp(2) <= '1';
				end if;
			end if;
			
			-- RIGHT ARROW BUTTON
			if ps2rxd1 = X"74" and (ps2rxd2 = X"E0" xor ps2rxd3 = X"E0") then
				if ps2rxd2 = X"F0" then
					buttons_temp(3) <= '0';
				else
					buttons_temp(3) <= '1';
				end if;
			end if;

			-- ENTER BUTTON
			if ps2rxd1 = X"5A" then
				if ps2rxd2 = X"F0" then
					buttons_temp(4) <= '0';
				else
					buttons_temp(4) <= '1';
				end if;
			end if;

			-- SPACE BUTTON
			if ps2rxd1 = X"29" then
				if ps2rxd2 = X"F0" then
					buttons_temp(5) <= '0';
				else
					buttons_temp(5) <= '1';
				end if;
			end if;

			-- ESC BUTTON
			if ps2rxd1 = X"76" then
				if ps2rxd2 = X"F0" then
					buttons_temp(6) <= '0';
				else
					buttons_temp(6) <= '1';
				end if;
			end if;
			
	end if;
	end process;

	BUTTONS <= buttons_temp;

end Behavioral;

