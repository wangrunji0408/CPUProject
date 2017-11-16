library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 分支预测模块
-- 每个时钟上升沿时
-- TODO
entity Predict is
	port (
		rst, clk: in std_logic;
		-- TODO
		pc: out u16
	) ;
end Predict;

architecture arch of Predict is	
begin

end arch ; -- arch
