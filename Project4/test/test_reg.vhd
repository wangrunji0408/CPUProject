library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity TestReg is
end TestReg;

architecture arch of TestReg is

	component Reg is
		port (
			clk, rst: in std_logic;
			write: in RegPort;
			read1, read2: in RegPort;
			read1_dataout, read2_dataout: out u16
		) ;
	end component;

	signal clk, rst: std_logic;
	signal write, read1, read2: RegPort;

	procedure test_case (
		signal write, read1, read2: inout RegPort;
		in_write, std_read1, std_read2: RegPort
		) is
	begin
		write <= in_write;
		read1.enable <= std_read1.enable;
		read1.addr <= std_read1.addr;
		read2.enable <= std_read2.enable;
		read2.addr <= std_read2.addr;
		wait for 10 ns;

		assert(read1.enable = '0' or read1.data = std_read1.data) 
			report "Failed when read register " & toString(read1.addr) 
					& ". Expect=" & toString(std_read1.data) & " Actual=" & toString(read1.data) 
			severity error;
		assert(read2.enable = '0' or read2.data = std_read2.data) 
			report "Failed when read register " & toString(read2.addr) 
					& ". Expect=" & toString(std_read2.data) & " Actual=" & toString(read2.data) 
			severity error;
		wait for 10 ns;
	end procedure;

begin

	reg0: Reg port map (clk, rst, write, read1, read2, read1.data, read2.data);

	process
	begin
		clk <= '0'; wait for 10 ns;
		clk <= '1'; wait for 10 ns;
	end process;

	process
		constant NULL_INPUT: RegPort := ('0', x"0", x"0000");
	begin
		rst <= '0';	wait for 10 ns;
		rst <= '1';	wait for 8 ns;

		-- 每个test_case对应一个时钟周期
		-- 						..., write, read1, read2
		test_case(write,read1,read2, NULL_INPUT, ('1', x"5", x"0000"), ('1', x"8", x"0000")); -- 任意初始值应该为0		
		test_case(write,read1,read2, ('1', x"0", x"ABCD"), NULL_INPUT, NULL_INPUT); -- 写入0...
		test_case(write,read1,read2, NULL_INPUT, ('1', x"0", x"0000"), NULL_INPUT); -- 写入0应该无效
		test_case(write,read1,read2, ('1', x"1", x"ABCD"), ('1', x"1", x"ABCD"), NULL_INPUT); -- 写入1，应该同时能读出来
		test_case(write,read1,read2, ('1', x"2", x"DCBA"), ('1', x"0", x"0000"), ('1', x"2", x"DCBA")); -- 写入2，应该同时能读出来

		assert(false) report "Test End" severity error;
		wait;
	end process;

end arch ; -- arch
