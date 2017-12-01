library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestIFCache is
end TestIFCache;

architecture arch of TestIFCache is

	signal clk, rst: std_logic;
	signal add, update, query, result: IFCachePort;

	type TestCase is record
		add, update, query, result: IFCachePort;
	end record;
	type TestCases is array (0 to 2) of TestCase;

	constant cases: TestCases := ( -- 每个test_case对应一个时钟周期
		(('1', x"0003", x"1003"), NULL_IFCACHEPORT, ('1', x"0003", x"0000"), ('1', x"0003", x"1003")), --可加可查
		(('1', x"0004", x"1004"), ('1', x"0002", x"1002"), ('1', x"0002", x"0000"), NULL_IFCACHEPORT), --无效更新
		(('1', x"0005", x"1005"), ('1', x"0003", x"2003"), ('1', x"0003", x"0000"), ('1', x"0003", x"2003")) --有效更新
	);

begin

	cache: entity work.IFCache port map (rst, clk, add, update, query, result);

	process
	begin
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
	end process;

	process
		variable std: TestCase;
	begin
		rst <= '0';	wait for 10 ns;
		rst <= '1';	wait for 8 ns;

		for i in cases'range loop
			std := cases(i);
			add <= std.add;
			update <= std.update;
			query <= std.query;
			wait for 10 ns;
	
			assert(result = std.result) 
				report "Failed at case " & integer'image(i)
				severity error;
			wait for 10 ns;
		end loop ; -- 

		assert(false) report "Test End" severity error;
		wait;
	end process;

end arch ; -- arch
