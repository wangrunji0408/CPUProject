library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Alu is
	port (
		op: in AluOp;
		a, b: in u16;
		s: out u16
	) ;
end Alu;

architecture arch of Alu is	
begin

	s <= x"0000";
	
end arch ; -- arch
