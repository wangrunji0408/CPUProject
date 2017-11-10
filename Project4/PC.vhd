library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 地址模块
-- 每个时钟上升沿，若branch==true，则输出branchTarget，否则+4输出
entity PC is
	port (
		rst, clk: in std_logic;
		branch: in std_logic;
		branchTarget: in u16;

		pc: out u16
	) ;
end PC;

architecture arch of PC is	
begin

end arch ; -- arch
