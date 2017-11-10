library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指/译码 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity IF_ID is
	port (
		rst, clk: in std_logic;
		-- IF
		if_pc: in u16;
		if_inst: in Inst;
		-- ID
		id_pc: in u16;
		id_inst: in Inst
	) ;
end IF_ID;

architecture arch of IF_ID is	
begin

end arch ; -- arch
