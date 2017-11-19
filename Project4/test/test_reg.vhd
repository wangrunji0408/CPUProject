library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestReg is
end TestReg;

architecture arch of TestReg is

	signal clk, rst: std_logic;
	signal write, read1, read2: RegPort;

	type TestCase is record
		write, read1, read2: RegPort;
	end record;
	type TestCases is array (0 to 4) of TestCase;

	constant NULL_INPUT : RegPort := ('0', x"0", x"0000");
	constant cases: TestCases := ( -- 每个test_case对应一个时钟周期
		(     NULL_INPUT     , ('1', x"5", x"0000"), ('1', x"8", x"0000")), -- 任意初始值应该为0	
		(('1', x"0", x"ABCD"),      NULL_INPUT     ,      NULL_INPUT     ), -- 写入0...
		(     NULL_INPUT     , ('1', x"0", x"0000"),      NULL_INPUT     ), -- 写入0应该无效
		(('1', x"1", x"ABCD"), ('1', x"1", x"ABCD"),      NULL_INPUT     ), -- 写入1，应该同时能读出来
		(('1', x"2", x"DCBA"), ('1', x"0", x"0000"), ('1', x"2", x"DCBA"))  -- 写入2，应该同时能读出来
	);

begin

	reg0: entity work.Reg port map (rst, clk, write, read1, read2, read1.data, read2.data);

	process
	begin
		clk <= '0'; wait for 10 ns;
		clk <= '1'; wait for 10 ns;
	end process;

	process
		variable std: TestCase;
	begin
		rst <= '0';	wait for 10 ns;
		rst <= '1';	wait for 8 ns;

		for i in cases'length loop
			std := cases(i);
			write <= std.write;
			read1.enable <= std.read1.enable;
			read1.addr <= std.read1.addr;
			read2.enable <= std.read2.enable;
			read2.addr <= std.read2.addr;
			wait for 10 ns;
	
			assert(read1.enable = '0' or read1.data = std.read1.data) 
				report "Failed at case " & integer'image(i) & ". Read=R" & toString(std.read1.addr) 
						& " Expect=" & toString(std.read1.data) & " Actual=" & toString(read1.data) 
				severity error;
			assert(read2.enable = '0' or read2.data = std.read2.data) 
				report "Failed at case " & integer'image(i) & ". Read=R" & toString(std.read2.addr) 
						& ". Expect=" & toString(std.read2.data) & " Actual=" & toString(read2.data) 
				severity error;
			wait for 10 ns;
		end loop ; -- 

		assert(false) report "Test End" severity error;
		wait;
	end process;

end arch ; -- arch
