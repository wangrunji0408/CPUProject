library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 执行/访存 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity EX_MEM is
	port (
		rst, clk, stall, clear: in std_logic;
		-- EX
		ex_writeReg: in RegPort;		
		ex_isLW, ex_isSW: in std_logic;
		ex_writeMemData: in u16;
		ex_aluOut: in u16;
		-- MEM
		mem_writeReg: out RegPort;		
		mem_isLW, mem_isSW: out std_logic;
		mem_writeMemData: out u16;
		mem_aluOut: out u16
	) ;
end EX_MEM;

architecture arch of EX_MEM is	
begin

end arch ; -- arch
