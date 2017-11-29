library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指模块
entity InstFetch is
	port (
		new_pc: in u16;
		branch: in PCBranch;
		pc: out u16;
		inst: out Inst;
		
		------ 对外接口 ------
		if_addr: out u16;
		if_data: in u16;
		if_canread: in std_logic
	) ;
end InstFetch;

architecture arch of InstFetch is	
	signal pc0: u16;
begin
	pc0 <= branch.target when branch.enable = '1' else new_pc;
	pc <= pc0 + 1;
	if_addr <= pc0;
	inst <= if_data;

end arch ; -- arch
