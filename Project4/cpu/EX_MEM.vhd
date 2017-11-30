library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 执行/访存 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity EX_MEM is
	port (
		rst, clk: in std_logic;
		ctrl: in MidCtrl;		
		-- EX
		ex_writeReg: in RegPort;		
		ex_isLW, ex_isSW: in std_logic;
		ex_writeMemData: in u16;
		ex_aluOut: in u16;
		-- MEM
		mem_writeReg: buffer RegPort;		
		mem_isLW, mem_isSW: buffer std_logic;
		mem_writeMemData: buffer u16;
		mem_aluOut: buffer u16
	) ;
end EX_MEM;

architecture arch of EX_MEM is	

	signal t_writeReg: RegPort;		
	signal t_isLW, t_isSW: std_logic;
	signal t_writeMemData: u16;
	signal t_aluOut: u16;
begin

	process( rst, clk )
	begin
		if rst = '0' then
			mem_writeReg <= NULL_REGPORT;
			mem_isLW <= '0';
			mem_isSW <= '0';
			mem_writeMemData <= x"0000";
			mem_aluOut <= x"0000";
			t_writeReg <= NULL_REGPORT;
			t_isLW <= '0';
			t_isSW <= '0';
			t_writeMemData <= x"0000";
			t_aluOut <= x"0000";
		elsif rising_edge(clk) then
			case( ctrl ) is
				when CLEAR =>	
					mem_writeReg <= NULL_REGPORT;
					mem_isLW <= '0';
					mem_isSW <= '0';
					mem_writeMemData <= x"0000";
					mem_aluOut <= x"0000";
				when PASS =>
					mem_writeReg <= ex_writeReg;
					mem_isLW <= ex_isLW;
					mem_isSW <= ex_isSW;
					mem_writeMemData <= ex_writeMemData;
					mem_aluOut <= ex_aluOut;
				when STORE =>
					t_writeReg <= mem_writeReg;
					t_isLW <= mem_isLW;
					t_isSW <= mem_isSW;
					t_writeMemData <= mem_writeMemData;
					t_aluOut <= mem_aluOut;
				when RESTORE =>
					mem_writeReg <= t_writeReg;
					mem_isLW <= t_isLW;
					mem_isSW <= t_isSW;
					mem_writeMemData <= t_writeMemData;
					mem_aluOut <= t_aluOut;
				when STALL =>	null;
			end case ;
		end if;
	end process ;
	
end arch ; -- arch
