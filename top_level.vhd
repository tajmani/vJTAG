library ieee;
use ieee.std_logic_1164.all;

entity top_level is

	port (
		leds : out std_logic_vector(6 downto 0)
	);
	
end top_level;

architecture BHV of top_level is

	signal tck : std_logic;
	signal tdo : std_logic;
	signal tdi : std_logic;
	signal ir_in : std_logic;
	signal v_sdr : std_logic;
	signal udr : std_logic;
	
begin

	U_vJTAG : entity work.vJTAG
	  port map(
		tck => tck,
		tdo => tdo,
		tdi => tdi,
		ir_in(0) => ir_in,
		virtual_state_sdr => v_sdr,
		virtual_state_udr => udr);
		
	U_vJTAG_INTERFACE : entity work.vJTAG_interface
	  port map(
		tck => tck,
		tdi => tdi,
		tdo => tdo,
		ir_in => ir_in,
		v_sdr => v_sdr,
		udr => udr
		leds => leds);
		
end BHV;