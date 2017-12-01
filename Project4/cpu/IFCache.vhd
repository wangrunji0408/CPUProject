library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指缓存模块
-- 1.消除结构冲突导致不能取指的问题
--   IF在第一次冲突的下一周期重新取指时，将访存结果add
--   IF检测到不能取指时，首先query缓存，若查询结果有效，则直接使用，否则再请求暂停
--   EX把每次写存操作提交update
-- 2.消除数据冲突导致ID暂停的问题
--   情况：EX Ri<=MEM[addr], ID 读Ri
--   当冲突发生时，Ctrl给MEM信号，MEM将访存结果add，此时IF一定不会add
--   EX每次读操作都query缓存
--   EX把每次写存操作提交update
entity IFCache is
	generic (
		SIZE: natural := 8
	);
	port (
		rst, clk: in std_logic;
		add: in IFCachePort;	-- 新建项，如果已存在则更新
		update: in IFCachePort;	-- 更新项，如果不存在则无视
		query1, query2: in IFCachePort;	-- 查询项，inst字段无效
		result1, result2: out IFCachePort;	-- 查询结果
		cache: buffer CacheData
	) ;
end IFCache;

architecture arch of IFCache is	
	signal count: natural range 0 to 7;
begin

	q : process( query1, query2, cache )
	begin
		result1 <= NULL_IFCACHEPORT;
		result2 <= NULL_IFCACHEPORT;
		if query1.enable = '1' then
			q1 : for i in cache'range loop
				if cache(i).pc = query1.pc then
					result1 <= cache(i);
				end if;
			end loop ; -- qf
		end if;
		if query2.enable = '1' then
			q2 : for i in cache'range loop
				if cache(i).pc = query2.pc then
					result2 <= cache(i);
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
