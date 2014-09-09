library ieee;
use ieee.std_logic_1164.all;

entity top_level is

	port(
		rst : in std_logic;
		alu_sel : in std_logic_vector(3 downto 0);
		ov_flag : out std_logic;
		led_hi : out std_logic_vector(6 downto 0);
		led_lo : out std_logic_vector(6 downto 0)
	);

end top_level;

architecture BHV of top_level is
	
	signal tck : std_logic;
	signal tdo : std_logic;
	signal tdi : std_logic;
	signal ir_in : std_logic_vector(7 downto 0);
	signal v_sdr : std_logic;
	signal udr : std_logic;
	signal sel_a : std_logic;
	signal sel_b : std_logic;
	signal sel_out : std_logic;
	signal reg_a_out : std_logic_vector(7 downto 0);
	signal reg_b_out : std_logic_vector(7 downto 0);
	signal alu_output : std_logic_vector(7 downto 0);
	signal leds_in : std_logic_vector(7 downto 0);
	
begin

	U_vJTAG : entity work.vJTAG
	  port map(
		tck => tck,
		tdo => tdo,
		tdi => tdi,
		ir_out => "00000000",
		ir_in => ir_in,
		virtual_state_sdr => v_sdr,
		virtual_state_udr => udr);
	
	U_ADDR_TOP : entity work.addr_top
	  port map(
		tck => tck,
		rst => rst,
		udr => udr,
		std_in => udr,
		v_sdr => v_sdr,
		input => ir_in,
		sel_a => sel_a,
		sel_b => sel_b,
		sel_out => sel_out);
		
	U_ALU_NS : entity work.alu_ns
	  generic map( 
		positive => 8)
	  port map( 
		input1 => reg_a_out,
		input2 => reg_b_out,
		sel    => alu_sel,
		output => alu_output,
		overflow => ov_flag);
		
	U_LED_HI : entity work.decoder7seg
	  port map(
		input => leds_in(7 downto 4),
		output => led_hi);
		
	U_LED_LO : entity work.decoder7seg
	  port map(
		input => leds_in(3 downto 0),
		output => led_lo);
		
	U_A_REG : entity work.reg_gen
	  port map(
		clk => tck,
		rst => rst,
		en  => sel_a,
		input => ir_in,
		output => reg_a_out);
		
	U_B_REG : entity work.reg_gen
	  port map(
		clk => tck,
		rst => rst,
		en  => sel_b,
		input => ir_in,
		output => reg_b_out);
		
	U_OUT_REG : entity work.reg_gen
	  port map(
		clk => tck,
		rst => rst,
		en  => sel_out,
		input => alu_output,
		output => leds_in);

end decoder7seg;
		
	
		
	