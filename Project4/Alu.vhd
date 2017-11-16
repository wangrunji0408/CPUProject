library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Alu is
	port (
		op: in AluOp;
		a, b: in u16;
		s: out u16;
		flag: out AluFlag
	) ;
end Alu;

architecture arch of Alu is	
begin
	-- example to write flag
	flag <= (others => '0');
	flag.cf <= '1';
end arch ; -- arch
