library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 


entity alu_ns is 
	generic ( 
		WIDTH : positive := 16
	); 
	port ( 
		input1 		: in std_logic_vector(WIDTH-1 downto 0); 
		input2 		: in std_logic_vector(WIDTH-1 downto 0); 
		sel 		: in std_logic_vector(3 downto 0); 
		output 		: out std_logic_vector(WIDTH-1 downto 0); 
		overflow 	: out std_logic 
	); 
end alu_ns;

architecture numeric of alu_ns is

--begin sel constants
	constant c_adder		: std_logic_vector(3 downto 0) := "0000";
	constant c_subtract 	: std_logic_vector(3 downto 0) := "0001";
	constant c_multi		: std_logic_vector(3 downto 0) := "0010";
	constant c_and 			: std_logic_vector(3 downto 0) := "0011";
	constant c_or			: std_logic_vector(3 downto 0) := "0100";
	constant c_xor 			: std_logic_vector(3 downto 0) := "0101";
	constant c_nor 			: std_logic_vector(3 downto 0) := "0110";
	constant c_not 			: std_logic_vector(3 downto 0) := "0111";
	constant c_Lshift 		: std_logic_vector(3 downto 0) := "1000";	--left shift by one bit
	constant c_Rshift 		: std_logic_vector(3 downto 0) := "1001";	--right shift by one bit
	constant c_Hswap 		: std_logic_vector(3 downto 0) := "1010";
	constant c_reverse 		: std_logic_vector(3 downto 0) := "1011";
--end sel constants
begin
	process (input1, input2, sel)
	
	variable v_carry		: std_logic_vector(width downto 0);
	variable v_multi		: unsigned(2*width-1 downto 0);
	variable v_zeros		: unsigned(width-1 downto 0);
	variable v_temp		: unsigned(width-1 downto 0);
	variable v_ones		: std_logic_vector(width-1 downto 0);
	variable v_temp2		: unsigned(width-1 downto 0);
	
	begin
	v_carry := (others=>'0');	--no carry in so set first carry to 0
	overflow <= '0';
	output <= (others=>'0');
	v_zeros  := (others=>'0');
	
		case sel is
			when c_adder =>	
				for i in 0 to WIDTH-1 
				loop
					output(i) <= (input1(i) xor input2(i)) xor v_carry(i);
					v_carry(i+1) := (input1(i) and input2(i)) or (input1(i) and v_carry(i)) or (input2(i) and v_carry(i));
				end loop;
				overflow <= v_carry(WIDTH-1);
				
			when c_subtract =>
				overflow <= '0';
				v_temp := unsigned(input1)-unsigned(input2);
				output <= std_logic_vector(v_temp);
				
			when c_multi =>
				v_multi := unsigned(input1) * unsigned(input2);
				output <= std_logic_vector(v_multi(width-1 downto 0));
				
				if (v_multi(2*WIDTH-1 downto WIDTH) = v_zeros) then
					overflow <= '0';
				else
					overflow <= '1';
				end if;
			
			when c_and =>				
				output <= input1 and input2;
				overflow <= '0';
								
			when c_or =>
				output <= input1 or input2;
				overflow <= '0';
				
			when c_xor =>
				output <= input1 xor input2;
				overflow <= '0';
										
			when c_nor =>
				output <= input1 nor input2;
				overflow <= '0';
							
			when c_not =>
				output <= not input1;
				overflow <= '0';
							
			when c_Lshift =>							
				overflow <= input1(width-1);
				
				output <= std_logic_vector(shift_left(unsigned(input1), 1));
			
			when c_Rshift =>
				output <= std_logic_vector(shift_right(unsigned(input1), 1));
				overflow <= '0';
									
			when c_Hswap =>
				if (width mod 2 = 0) then
					output <= std_logic_vector(rotate_right(unsigned(input1),width/2));
				else
					for i in 0 to width/2
					loop
						output(i) <= input1(width/2+i);
					end loop;
					for i in 0 to width/2-1
					loop	
						output(width/2+i) <= input1(i);
					end loop;
				end if;
				overflow <= '0';
									
			when c_reverse =>
				overflow <= '0';
				
				for i in 0 to width-1
				loop
					output(i) <= input1(width-1-i);
				end loop;
					
			when "1100" =>  			--in lab quiz check if even or odd, if even =1 if odd = 0
				if ((unsigned(input1) mod 2) = 0)then
					output(0) <= '1';
					for i in 1 to width-1
					loop
						output(i) <= '0';
					end loop;
				else
					output <= (others => '0');
				end if;
				overflow <= '0';

			when "1101" =>				--in lab quiz count the number of zeros
				v_temp2 := (others =>'0');
				for i in 0 to width-1
				loop
					if (input1(i) = '0') then
						v_temp2 := v_temp2 + 1;
					end if;
				end loop;
					
				output <= (std_logic_vector(v_temp2));
				
				
			when others => null;	
			
		end case;
	end process;

end numeric;