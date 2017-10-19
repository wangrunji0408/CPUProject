library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestTop is
end TestTop;

architecture arch of TestTop is

	component Top is
		port (
			clk, rst: in std_logic;
			input: in u16;
			fout: out u16
		) ;
	end component;

	procedure press (signal b: out std_logic) is
	begin
		b <= '0'; wait for 100 ns; b <= '1'; wait for 100 ns;
	end procedure;

	procedure test_case (
		info: string;
		signal clk: out std_logic;
		signal input: out u16;
		signal fout: in u16;
		a, b: u16;
		op: u4;
		f: u16
		-- cf, zf, sf, vf: std_logic
		) is
	begin
		input <= a;
		wait for 100 ns;
		press(clk);

		input <= b;
		wait for 100 ns;
		press(clk);

		input <= x"000" & op;
		wait for 100 ns;
		press(clk);

		assert(fout = f) 
			report "Failed case " & info & ". expect=" & toString(f) & " actual=" & toString(fout) 
			severity error;

		press(clk);
	end procedure;

	signal clk, rst: std_logic;
	signal input, fout: u16;

begin

	-- 实例化被测entity
	top0: Top port map (clk, rst, input, fout);

	process
	begin

		clk <= '1'; rst <= '1'; 
		input <= x"0000";
		wait for 100 ns;
		press(rst);

		test_case("ADD", clk, input, fout, x"0002", x"0004", OP_ADD, x"0006");
		test_case("SUB", clk, input, fout, x"0002", x"0004", OP_SUB, x"FFFE");
		test_case("AND", clk, input, fout, x"0003", x"0005", OP_AND, x"0001");
		test_case("OR", clk, input, fout, x"0002", x"0004", OP_OR, x"0006");
		test_case("XOR", clk, input, fout, x"0002", x"0004", OP_XOR, x"0006");
		test_case("NOT", clk, input, fout, x"0002", x"0004", OP_NOT, x"FFFD");
		test_case("SLL", clk, input, fout, x"ABCD", x"0004", OP_SLL, x"BCD0");
		test_case("SRL", clk, input, fout, x"ABCD", x"0004", OP_SRL, x"0ABC");
		test_case("SRA", clk, input, fout, x"FFF8", x"0002", OP_SRA, x"FFFE");
		test_case("ROL", clk, input, fout, x"ABCD", x"0004", OP_ROL, x"BCDA");

		assert(false) report "Test End" severity note;
		wait;
	end process;

end arch ; -- arch
