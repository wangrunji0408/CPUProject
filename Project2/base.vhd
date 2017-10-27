library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Base is
	subtype u16 is unsigned(15 downto 0);
	subtype u4 is unsigned(3 downto 0);
	
	function toBitStr (x: unsigned) return string;
	function toString (x: unsigned) return string;
	function to_u4 (x: integer) return u4;
	function to_u16 (x: integer) return u16;
	function DisplayNumber (number: u4) return std_logic_vector;	

	constant OP_ADD: u4 := to_u4(0); 
	constant OP_SUB: u4 := to_u4(1); 
	constant OP_AND: u4 := to_u4(2); 
	constant OP_OR: u4 := to_u4(3); 
	constant OP_XOR: u4 := to_u4(4); 
	constant OP_NOT: u4 := to_u4(5); 
	constant OP_SLL: u4 := to_u4(6); 
	constant OP_SRL: u4 := to_u4(7); 
	constant OP_SRA: u4 := to_u4(8); 
	constant OP_ROL: u4 := to_u4(9); 
end package ;

package body Base is

	function toBitStr (x: unsigned) return string is 
	begin
		return integer'image(to_integer(x));
	end function;

	function toString (x: unsigned) return string is 
	begin
		return integer'image(to_integer(x));
	end function;

	function to_u4 (x: integer) return u4 is 
	begin
		return to_unsigned(x, 4);
	end function;

	function to_u16 (x: integer) return u16 is 
	begin
		return to_unsigned(x, 16);
	end function;

	function DisplayNumber (number: u4)
		return std_logic_vector is -- gfedcba
	begin
		case number is
			when "0000" => return "0111111"; --0;
			when "0001" => return "0000110"; --1;
			when "0010" => return "1011011"; --2;
			when "0011" => return "1001111"; --3;
			when "0100" => return "1100110"; --4;
			when "0101" => return "1101101"; --5;
			when "0110" => return "1111101"; --6;
			when "0111" => return "0001110"; --7;
			when "1000" => return "1111111"; --8;
			when "1001" => return "1101111"; --9;
			when "1010" => return "1111110"; --A;
			when "1011" => return "1110100"; --B;
			when "1100" => return "0111001"; --C;
			when "1101" => return "1010111"; --D;
			when "1110" => return "1111001"; --E;
			when "1111" => return "1111000"; --F;
			when others => return "0000000";
		end case;
	end function;

end package body;
