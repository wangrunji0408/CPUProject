library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 译码模块
entity ID is
	port (
		------ 从IF输入 ------

		inst: in Inst;
		pc: in u16;

		------ 寄存器接口 ------

		-- 只有.data是in
		reg1, reg2: inout RegPort;

		------ 旁路信息 ------

		-- 正处于执行/访存阶段的指令，是否要写寄存器
		-- 若是，enable=1，并给出地址和数据
		-- 判断是否是正在读的寄存器，若是，直接输出给EX
		exeWriteReg, memWriteReg: in RegPort;

		------ 输出到EX ------

		-- 正处于此阶段的指令，是否要写寄存器
		-- 若是，enable=1，并给出地址，数据属性无效
		writeReg: out RegPort;

		aluInput: out AluInput
	) ;
end ID;

architecture arch of ID is	
begin

end arch ; -- arch
