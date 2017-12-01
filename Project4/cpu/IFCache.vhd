library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指缓存模块
--   意在消除结构冲突导致不能取指的问题
-- 
entity IFCache is
	generic (
		SIZE: natural := 8
	);
	port (
		rst, clk: in std_logic;
		add: in IFCachePort;
		update: in IFCachePort;
		query: in IFCachePort;
		result: out IFCachePort
	) ;
end IFCache;

architecture arch of IFCache is	
	type CacheData is array (0 to SIZE-1) of IFCachePort;
	signal cache: CacheData;
	signal count: natural range 0 to SIZE-1;
begin

	q : process( query, cache )
	begin
		result <= NULL_IFCACHEPORT;
		if query.enable = '1' then
			qf : for i in cache'range loop
				if cache(i).pc = query.pc then
					result <= cache(i);
				end if;
			end loop ; -- qf
		end if;
	end process ; -- q

	process( rst, clk )
		variable exist: boolean;
	begin
		if rst = '0' then
			cache <= (others => NULL_IFCACHEPORT);
			count <= 0;
		elsif rising_edge(clk) then
			if add.enable = '1' then
				exist := false;
				qa: for i in cache'range loop
					if cache(i).pc = add.pc then
						cache(i) <= add;
						exist := true;
					end if;
				end loop ;
				if not exist then
					cache(count) <= add;
					count <= count + 1;
				end if;
			end if;
			if update.enable = '1' then
				qu: for i in cache'range loop
					if cache(i).pc = update.pc then
						cache(i) <= update;
					end if;
				end loop ;
			end if;
		end if;
	end process ;

end arch ; -- arch
