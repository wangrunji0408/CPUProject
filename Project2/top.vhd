library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Top is
	port (
		clk, rst: in std_logic;
		input: in u16;
		s: out u16;
		flag: out std_logic
	) ;
end Top;

architecture arch of Top is

	component Controller is
		port (
		  clk, rst: in std_logic;
		  input: in u16;
		  op: out u4;
		  a: out u16;
		  b: out u16
		) ;
	end component;

	component ALU is
		port (
		  op: in u4;
		  a: in u16;
		  b: in u16;
		  s: out u16;
		  flag: out std_logic
		) ;
	end component;

	signal op: u4;
	signal a, b: u16;

begin

	ctl0: Controller port map (clk, rst, input, op, a, b);
	alu0: ALU port map (op, a, b, s, flag);

end arch ; -- arch