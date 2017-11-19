library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 执行/访存 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity EX_MEM is
	port (
		rst, clk, stall, clear: in std_logic;
		-- EX
		ex_writeReg: in RegPort;		
		ex_isLW, ex_isSW: in std_logic;
		ex_writeMemData: in u16;
		ex_aluOut: in u16;
		-- MEM
		mem_writeReg: out RegPort;		
		mem_isLW, mem_isSW: out std_logic;
		mem_writeMemData: out u16;
		mem_aluOut: out u16
	) ;
end EX_MEM;

architecture arch of EX_MEM is	
begin

	process( rst, clk )
	begin
		if rst = '0' then
			mem_writeReg <= NULL_REGPORT;
			mem_isLW <= '0';
			mem_isSW <= '0';
			mem_writeMemData <= x"0000";
			mem_aluOut <= x"0000";
		elsif rising_edge(clk) then
			if clear = '1' then
				mem_writeReg <= NULL_REGPORT;
				mem_isLW <= '0';
				mem_isSW <= '0';
				mem_writeMemData <= x"0000";
				mem_aluOut <= x"0000";
			elsif stall = '0' then
				mem_writeReg <= ex_writeReg;
				mem_isLW <= ex_isLW;
				mem_isSW <= ex_isSW;
				mem_writeMemData <= ex_writeMemData;
				mem_aluOut <= ex_aluOut;
			end if;
		end if;
	end process ;
	
end arch ; -- arch
