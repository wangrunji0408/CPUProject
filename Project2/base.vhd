library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Base is
	subtype u16 is unsigned(15 downto 0);
	subtype u4 is unsigned(3 downto 0);
	
	function toString (x: u16) return string;
	function to_u4 (x: integer) return u4;
	function to_u16 (x: integer) return u16;

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

	function toString (x: u16) return string is 
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

end package body;
