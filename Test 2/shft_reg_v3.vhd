library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shft_reg_v3 is

	port(
		clk : in std_logic;
		rst : in std_logic;
		input : in std_logic_vector(7 downto 0);
		en : in std_logic;
		output : out std_logic
	);
	
end shft_reg_v3;

architecture SEQ_LOG of shft_reg_v2 is

	signal temp : std_logic_vector(7 downto 0);
	
begin

	process(clk, rst)
	
		variable count : natural;
	begin
	
		if (rst = '1') then
			count := 0;
			temp <= (others => '0');
			output <= '0';
		elsif(rising_edge(clk)) then
			if (en = '1') then
				temp <= input;
			end if;
			output <= temp(0);
			temp <= SHIFT_RIGHT(temp,1);
			count := count + 1;
			if (count = 7) then
				output <= temp;
				count := 0;
			end if;
		end if;
		
	end process;
	
end SEQ_LOG;
			
				