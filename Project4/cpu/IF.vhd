library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指模块
entity InstFetch is
	port (
		pc: in u16;
		inst: out Inst;
		
		------ 对外接口 ------
		if_addr: out u16;
		if_data: in u16;
		if_canread: in std_logic
	) ;
end InstFetch;

architecture arch of InstFetch is	
begin

	if_addr <= pc;
	inst <= if_data;

end arch ; -- arch
