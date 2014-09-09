library ieee;
use ieee.std_logic_1164.all;

entity addr_top is
  generic (
				WIDTH		: positive := 8);
  
  port (
	tck   : in std_logic;
   rst   : in std_logic;
	udr	: in std_logic;
	std_in : in std_logic;
	v_sdr	: in std_logic;
	input : in std_logic_vector(WIDTH-1 downto 0);
	sel_a	: out std_logic;
	sel_b : out std_logic;
	sel_out : out std_logic);
end addr_top;

architecture STR of addr_top is

	signal addr_en : std_logic;
	signal addr_out : std_logic_vector(WIDTH-1 downto 0);
	
begin

	U_addrreg : entity work.addr_reg
		port map (
			tck => tck,
			rst => rst,
			en	=> addr_en and udr and v_sdr,
			input => input,
			output =>  addr_out
		);
	
	U_addrcount : entity work.addr_count
		port map(
			tck => tck,   		
			rst => rst,
			std_in => std_in,	
			output => addr_en
		);
	
	U_logic : entity work.d_logic
		port map (
			addr_in => addr_out,
			sel_a => sel_a,
			sel_b  => sel_b,
			sel_out => sel_out
		);
	
end STR;