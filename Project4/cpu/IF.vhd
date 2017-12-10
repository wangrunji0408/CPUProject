library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指模块
entity InstFetch is
	port (
		new_pc: in u16;
		branch: in PCBranch;
		isRefetch: in std_logic;
		pc: out u16;
		inst: out Inst;
		stallReq: out std_logic;
		
		------ 对外接口 ------
		if_addr: out u16;
		if_data: in u16;
		if_canread: in std_logic;

		cache_add: out IFCachePort;
		cache_query: out IFCachePort;
		cache_result: in IFCachePort
	) ;
end InstFetch;

architecture arch of InstFetch is	
	signal pc0: u16;
begin
	pc0 <= branch.target when branch.enable = '1' else new_pc;
	pc <= pc0 + 1;
	if_addr <= pc0;
	inst <= if_data when if_canread = '1' else cache_result.inst;

	cache_add <= ('1', pc0, if_data) when isRefetch = '1' and if_canread = '1' else NULL_IFCACHEPORT;
	cache_query <= ('1', pc0, x"0000") when if_canread = '0' else NULL_IFCACHEPORT;
	stallReq <= '1' when if_canread = '0' and cache_result.enable = '0' else '0';

end arch ; -- arch
