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
		branch: in PCBranch;
		pc: out u16
	) ;
end PC;

architecture arch of PC is	
	signal last_pc, o_pc: u16;
	signal l_branch: PCBranch;
begin
	pc <= o_pc;
	o_pc <= last_pc + l_branch.offset when l_branch.isOffset = '1'else 
			l_branch.target when l_branch.isJump = '1' else 
			last_pc + 1;

process( rst, clk )
begin
	if rst = '0' then
		last_pc <= x"FFFF";
		l_branch <= NULL_PCBRANCH;
	elsif rising_edge(clk) and stall = '0' then
		last_pc <= o_pc;
		l_branch <= branch;
	end if;
end process ;

end arch ; -- arch