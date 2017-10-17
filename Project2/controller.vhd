library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Controller is
	port (
		clk, rst: in std_logic;
		input: in u16;
		op: out u4;
		a: out u16;
		b: out u16
	) ;
end Controller;

architecture arch of Controller is

begin

end arch ; -- arch