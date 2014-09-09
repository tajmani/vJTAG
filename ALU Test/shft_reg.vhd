library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shft_reg is

	port(
		clk : in std_logic;
		rst : in std_logic;
		input : in std_logic_vector(7 downto 0);
		en : in std_logic;
		output : out std_logic
	);
	
end shft_reg;

architecture SEQ_LOG of shft_reg is

	signal temp : std_logic_vector(7 downto 0);
	
begin

	process(clk, rst)
	begin
	
		if (rst = '1') then
			temp <= (others => '0');
			output <= 
		elsif(rising_edge(clk)) then
			temp <= input;
			if (en = '1') then
				output <= temp(0);
				for i in 0 to 6 loop
					temp(i) <= temp(i+1);
				end loop;
			end if;
		end if;
		
	end process;
	
end SEQ_LOG;
			
				