library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 译码/取指 中间层
entity ID_IF is
	port (
		rst, clk, stall, clear: in std_logic;
		-- ID
		id_pc: in u16;
		id_branch: in PCBranch;
		-- IF
		if_pc: out u16;
		if_branch: out PCBranch
	) ;
end ID_IF;

architecture arch of ID_IF is	
begin
	process( rst, clk )
	begin
		if rst = '0' then
			if_pc <= x"0000";
			if_branch <= NULL_PCBRANCH;
		elsif rising_edge(clk) then
			if clear = '1' then
				if_pc <= x"0000";
				if_branch <= NULL_PCBRANCH;
			elsif stall = '0' then
				if_pc <= id_pc;
				if_branch <= id_branch;
			end if;
		end if;
	end process ;
end arch ; -- arch
