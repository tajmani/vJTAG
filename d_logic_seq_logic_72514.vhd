library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity d_logic is
	
	port (
		tck : in std_logic;
		rst : in std_logic;
		addr_in : in std_logic_vector(7 downto 0);
		sel_a : out std_logic;
		sel_b : out std_logic;
		sel_out : out std_logic;
		sel_sr : out std_logic
	);
	
end d_logic;

-- architecture SEQ_LOGIC of d_logic is
-- begin

	-- process(addr_in)
	-- begin
		
		-- sel_a <= '0';
		-- sel_b <= '0';
		-- sel_out <= '0';
		-- case addr_in is
			-- when "00000001" =>
				-- sel_a <= '1';
			
			-- when "00000010" =>
				-- sel_b <= '1';
				
			-- when "00000011" =>
				-- sel_out <= '1';
				
			-- when "00000100" =>
				-- sel_sr <= '1';
				
			-- when others => null;
				
		-- end case;
		
	-- end process;

-- end SEQ_LOGIC;

architecture SEQ_LOGIC of d_logic is

	signal temp_addr_in : std_logic_vector(7 downto 0);
	
begin

	process(tck, rst)
	begin
		
		if (rst = '1') then
			sel_a <= '0';
			sel_b <= '0';
			sel_out <= '0';
			sel_sr <= '0';
			temp_addr_in <= (others => '0');
		elsif (rising_edge(tck)) then
			temp_addr_in <= addr_in;
			case addr_in is
				when "00000001" =>
					sel_a <= '1';
					
				when "00000010" =>
					sel_b <= '1';
						
				when "00000011" =>
					sel_out <= '1';
						
				when "00000100" =>
					sel_sr <= '1';
						
				when others => null;
						
			end case;
		
		end if;
		
	end process;

end SEQ_LOGIC;
		