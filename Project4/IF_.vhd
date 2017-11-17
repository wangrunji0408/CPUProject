library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指模块
entity IF_ is
	port (
		rst, clk: in std_logic;
		pc: in u16;
		inst: out Inst;
		
		------ RAM2接口 ------
		ram2addr: out u18;
		ram2data: inout u16;
		ram2read, ram2write, ram2enable: out std_logic
	) ;
end IF_;

architecture arch of IF_ is	
begin

end arch ; -- arch
