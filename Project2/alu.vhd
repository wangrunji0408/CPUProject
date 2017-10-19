library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.Base.all;

entity ALU is
	port (
		op: in u4;
		a: in u16;
		b: in u16;
		s: out u16;
		flag: out std_logic
	) ;
end ALU;

architecture arch of ALU is
	
begin
	calc : process(op)
	begin
		case( op ) is
			when "0000" => s <= a + b;
			when "0001" => s <= a - b;
            when "0010" => s <= a and b;
            when "0011" => s <= a or b;
            when "0100" => s <= a xor b;
            when "0101" => s <= not a;
            when "0110" => s <= to_u16(to_bitvector(conv_std_logic_vector(a ,16)) sll conv_integer(b));
            when "0111" => s <= to_u16(to_bitvector(conv_std_logic_vector(a ,16)) srl conv_integer(b));
            when "1000" => s <= to_u16(to_bitvector(conv_std_logic_vector(a ,16)) sra conv_integer(b));
            when "1001" => s <= to_u16(to_bitvector(conv_std_logic_vector(a ,16)) rol conv_integer(b));
			when others => s <= to_unsigned(0, 16);
		end case ;
	end process ; -- calc

end arch ; -- arch