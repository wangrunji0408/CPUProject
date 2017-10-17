library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
			when others => s <= to_unsigned(0, 16);
		end case ;
	end process ; -- calc

end arch ; -- arch