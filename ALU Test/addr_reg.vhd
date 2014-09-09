library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addr_reg is
  generic (
    WIDTH : positive := 8);
  port (
    tck    : in  std_logic;
    rst    : in  std_logic;
    en		: in std_logic;
    input   : in  std_logic_vector(WIDTH-1 downto 0);
    output : out std_logic_vector(WIDTH-1 downto 0));
end addr_reg;

architecture BHV_EN of addr_reg is

begin
	process (tck, rst)
	begin
		if (rst ='1') then
			output <= (others => '0');
		elsif (tck'event and tck = '1') then
			if (en = '1') then
				output <= input;
			end if;
		end if;
	end process;
end BHV_EN;