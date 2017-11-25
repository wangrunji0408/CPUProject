library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 译码/执行 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity ID_EX is
	port (
		rst, clk, stall, clear: in std_logic;
		-- ID
		id_writeReg: in RegPort;
		id_isLW, id_isSW: in std_logic;
		id_writeMemData: in u16;
		id_aluInput: in AluInput;
		-- EX
		ex_writeReg: out RegPort;		
		ex_isLW, ex_isSW: out std_logic;
		ex_writeMemData: out u16;
		ex_aluInput: out AluInput
	) ;
end ID_EX;

architecture arch of ID_EX is	
begin
	process( rst, clk )
	begin
		if rst = '0' then
			ex_writeReg <= NULL_REGPORT;
			ex_isLW <= '0';
			ex_isSW <= '0';
			ex_writeMemData <= x"0000";
			ex_aluInput <= NULL_ALUINPUT;
		elsif rising_edge(clk) then
			if clear = '1' then
				ex_writeReg <= NULL_REGPORT;
				ex_isLW <= '0';
				ex_isSW <= '0';
				ex_writeMemData <= x"0000";
				ex_aluInput <= NULL_ALUINPUT;
			elsif stall = '0' then
				ex_writeReg <= id_writeReg;
				ex_isLW <= id_isLW;
				ex_isSW <= id_isSW;
				ex_writeMemData <= id_writeMemData;
				ex_aluInput <= id_aluInput;
			end if;
		end if;
	end process ;

end arch ; -- arch
