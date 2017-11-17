library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestALU is
end TestALU;

architecture arch of TestALU is

	component ALU is
		port (
			op: in AluOp;
			a, b: in u16;
			s: out u16
		) ;
	end component;

	-- ALU Signals
	signal op: AluOp;
	signal a, b, s: u16;

	procedure test_case (
		signal op: out AluOp;
		signal a, b: out u16;
		signal s: in u16;
		info: string;
		in_a, in_b: u16;
		in_op: AluOp;		
		std_s: u16
		) is
	begin
		op <= in_op; a <= in_a; b <= in_b;
		wait for 1 ns;
		assert(s = std_s) 
			report "Failed case " & info & ". expect=" & toString(std_s) & " actual=" & toString(s) 
			severity error;
	end procedure;

begin

	alu0: alu port map (op, a, b, s);

	process
	begin
		test_case(op,a,b,s, "ADD", x"0002", x"FFFF", OP_ADD, x"0001");
		test_case(op,a,b,s, "SUB", x"0002", x"0004", OP_SUB, x"FFFE");
		test_case(op,a,b,s, "AND", x"0003", x"0005", OP_AND, x"0001");
		test_case(op,a,b,s, "OR ", x"0002", x"0004", OP_OR, x"0006");
		test_case(op,a,b,s, "XOR", x"0002", x"0004", OP_XOR, x"0006");
		test_case(op,a,b,s, "NOT", x"0002", x"0004", OP_NOT, x"FFFD");
		test_case(op,a,b,s, "SLL", x"ABCD", x"0004", OP_SLL, x"BCD0");
		test_case(op,a,b,s, "SRL", x"ABCD", x"0004", OP_SRL, x"0ABC");
		test_case(op,a,b,s, "SRA", x"FFF8", x"0002", OP_SRA, x"FFFE");
		test_case(op,a,b,s, "ROL", x"ABCD", x"0004", OP_ROL, x"BCDA");

		test_case(op,a,b,s, "LTU1", x"F000", x"0000", OP_LTU, x"0000");
		test_case(op,a,b,s, "LTU2", x"ABCD", x"ABCD", OP_LTU, x"0000");
		test_case(op,a,b,s, "LTU3", x"0000", x"F000", OP_LTU, x"0001");

		test_case(op,a,b,s, "LTS1", x"F000", x"0000", OP_LTS, x"0001");
		test_case(op,a,b,s, "LTS2", x"ABCD", x"ABCD", OP_LTS, x"0000");
		test_case(op,a,b,s, "LTS3", x"0000", x"F000", OP_LTS, x"0000");

		test_case(op,a,b,s, "EQ1 ", x"ABCD", x"ABCD", OP_EQ, x"0000");
		test_case(op,a,b,s, "EQ2 ", x"ABCD", x"0001", OP_EQ, x"0001");

		assert(false) report "Test End" severity note;
		wait;
	end process;

end arch ; -- arch
