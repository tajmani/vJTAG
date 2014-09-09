library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addr_count is
	generic (
	WIDTH_COUNT		: positive := 3);
  port (
   tck    	: in  std_logic;							--from the vJTAG
	rst		: in std_logic;
	std_in	: in std_logic;							--this will tell the counter when to inc	
   output 	: out std_logic
	);
end addr_count;

--this counter will count to 2 and reset and send an enable signal 
--on the 0. This is made so that when sending instructions it will only 
--take every second instruction and send.

architecture count of addr_count is
	
	signal count : std_logic_vector(WIDTH_COUNT-1 downto 0);
	signal t_count : std_logic_vector(WIDTH_COUNT-1 downto 0);
	signal enable : std_logic;
	
begin
	
	process (tck,std_in, rst)
	begin	
		if (rst ='1') then
			output <= '0';
		elsif (tck'event and tck = '1') then
			if(std_in ='1') then
				count <= t_count;	
				output <= enable;		
			end if;	
		end if;
	end process;

	
	process (count, t_count)
	begin	
		t_count <= count;
		if(count = "010" ) then
			t_count <= std_logic_vector(unsigned(count) +1);
		end if;
		if (count = "000")then
			enable <= '1';
		else
			enable <= '0';
		end if;
	end process;
	

end count;	
	