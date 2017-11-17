library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 译码/执行 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity ID_EX is
	port (
		rst, clk, stall, clear: in std_logic;
		-- ID
		id_writeReg: in RegPort;
		id_isLW, id_isSW: in std_logic;
		id_writeMemData: in u16;
		id_aluInput: in AluInput;
		-- EX
		ex_writeReg: out RegPort;		
		ex_isLW, ex_isSW: out std_logic;
		ex_writeMemData: out u16;
		ex_aluInput: out AluInput
	) ;
end ID_EX;

architecture arch of ID_EX is	
begin

end arch ; -- arch
