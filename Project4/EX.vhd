library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 执行模块
entity EX is
	port (
		------ 从ID读入 ------

		pc: in u16;
		aluInput: in AluInput;
		writeRegIn: in RegPort;

		------ 输出到MEM ------

		-- 经过计算判断，是否真的要写寄存器
		-- 若writeRegIn.enable=1，且经过计算符合条件，则把信息复制过来，并补上data
		writeRegOut: out RegPort
		
	) ;
end EX;

architecture arch of EX is	
begin

end arch ; -- arch
