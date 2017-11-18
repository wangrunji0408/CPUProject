library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 地址模块
-- 每个时钟上升沿时切换地址
-- 1. 若isOffset==true，则 PC+=offset
-- 2. 若isJump==true，则 PC=target
-- 3. 否则 PC+=4
entity PC is
	port (
		rst, clk, stall: in std_logic;
		isOffset, isJump: in std_logic;
		offset, target: in u16;
		pc: out u16
	) ;
end PC;

architecture arch of PC is	
	signal pc0: u16;
begin
	
	process( rst, clk )
	begin
		if rst = '0' then
			pc0 <= x"0000";
		elsif rising_edge(clk) then
			if isOffset = '1' then
				pc0 <= pc0 + offset;
			elsif isJump = '1' then
				pc0 <= target;
			else
				pc0 <= pc0 + 4;
			end if;
		end if;
	end process ;

end arch ; -- arch
