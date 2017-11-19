library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指/译码 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity IF_ID is
	port (
		rst, clk, stall, clear: in std_logic;
		-- IF
		if_pc: in u16;
		if_inst: in Inst;
		-- ID
		id_pc: out u16;
		id_inst: out Inst
	) ;
end IF_ID;

architecture arch of IF_ID is	
begin
	process( rst, clk )
	begin
		if rst = '0' then
			id_pc <= x"0000";
			id_inst <= x"0000";
		elsif rising_edge(clk) then
			if clear = '1' then
				id_pc <= x"0000";
				id_inst <= x"0000";
			elsif stall = '0' then
				id_pc <= if_pc;
				id_inst <= if_inst;
			end if;
		end if;
	end process ;
end arch ; -- arch
