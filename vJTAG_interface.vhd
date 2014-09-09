library ieee;
use ieee.std_logic_1164.all;

entity vJTAG_interface is

	generic ( 
		WIDTH : positive := 7
	);
	
	port (
		tck : in std_logic;
		tdi : in std_logic;
		aclr : in std_logic;
		ir_in : in std_logic;
		v_sdr : in std_logic;
		udr : in std_logic;
		leds : out std_logic_vector(WIDTH-1 downto 0);
		tdo : out std_logic
	);
	
end vJTAG_interface;

architecture SEQ_LOGIC of vJTAG_interface is
	
	signal DR0_bypass_reg : std_logic;
	signal DR1 : std_logic_vector(WIDTH-1 downto 0);
	signal select_DR0 : std_logic;
	signal select_DR1 : std_logic;
	
begin

	select_DR0 <= not ir_in;
	select_DR1 <= ir_in;

	process(aclr, tck)
	begin
	
		if (aclr = '1') then
			DR0_bypass_reg <= '1';
			DR1 <= (others => '0');
		elsif (rising_edge(tck)) then
			DR0_bypass_reg <= tdi;
			if (v_sdr = '1') then
				if (select_DR1 = '1') then
					DR1 <= tdi & DR1(6 downto 1);
				end if;
			end if;
		end if;
		
	end process;
	
	process (tck, tdi, aclr, ir_in, v_sdr, select_DR1, DR1, DR0_bypass_reg, udr)
	begin
	
		if (select_DR1 = '1') then
			tdo <= DR1(0);
		else
			tdo <= DR0_bypass_reg;
		end if;
		
		if (udr = '1') then
			LEDs <= DR1;
		end if;
		
	end process;
	
end SEQ_LOGIC;
		