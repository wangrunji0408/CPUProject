library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指模块
entity InstFetch is
	port (
		last_pc: in u16;		
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
	pc0 <= 	last_pc + branch.offset when branch.isOffset = '1'else 
			branch.target when branch.isJump = '1' else 
			last_pc + 1;
	pc <= pc0;	
	if_addr <= pc0;
	inst <= if_data;

end arch ; -- arch
