library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 定义空entity
entity TestALU is
end TestALU;

architecture arch of TestALU is

	-- 引入实体（一般是直接复制entity，改名component）
	component ALU is
		port (
		  op: in u4;
		  a: in u16;
		  b: in u16;
		  s: out u16;
		  cf, zf, sf, vf: out std_logic
		) ;
	end component;

	-- ALU Signals
	signal op: u4;
	signal a, b, s: u16;
	signal cf, zf, sf, vf: std_logic;

begin

	-- 实例化被测entity
	alu0: alu port map (op, a, b, s, cf, zf, sf, vf);

	process
	begin
		-- 一个测例
		op <= OP_SLL;
		a <= to_u16(3);
		b <= to_u16(2);
		wait for 10 ns; -- 这里随便等待一段时间，只要不是0
		assert(s = 12) 
			report "Failed: SLL s=" & toString(s) severity error;

		op <= OP_SUB;
		a <= to_u16(2);
		b <= to_u16(4);
		wait for 10 ns;
		assert(s = x"FFFE") 
			report "Failed: SUB s=" & toString(s) severity error;
		assert(zf = '0') 
			report "Failed: SUB ZF" severity error;

		-- 最后一句，会输出"Test End"，一定要有wait否则模拟不会结束
		assert(false) report "Test End" severity note;
		wait;
	end process;

end arch ; -- arch
