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

		-- enable和addr同时也输出到Ctrl模块，以判断寄存器冲突
		reg1_enable, reg2_enable: out std_logic;
		reg1_addr, reg2_addr: out u16;
		reg1_data, reg2_data: in u16;

		------ 输出到PC ------

		isOffset, isJump: out std_logic;
		offset, target: out u16;

		------ 旁路信息输入 ------

		-- 正处于执行/访存阶段的指令，是否要写寄存器
		-- 若是，enable=1，并给出地址和数据
		-- 判断是否是正在读的寄存器，若是，直接输出给EX
		exeWriteReg, memWriteReg: in RegPort;

		------ 输出到MEM ------

		-- 正处于此阶段的指令，是否要写寄存器
		-- 若是，enable=1，并给出地址，数据属性无效
		writeReg: out RegPort;

		-- 正处于此阶段的指令，是否为LW
		-- 若是，在MEM阶段，writeReg.data <= Mem[ALUOut]
		isLW: out std_logic;

		-- 正处于此阶段的指令，是否为SW
		-- 若是，在MEM阶段，Mem[ALUOut] <= writeMemData
		isSW: out std_logic;
		writeMemData: out u16;

		------ 输出到EX ------

		aluInput: out AluInput
	) ;
end ID;

architecture arch of ID is	
begin

end arch ; -- arch
