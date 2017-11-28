library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 译码/执行 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity ID_EX is
	port (
		rst, clk: in std_logic;
		ctrl: in MidCtrl;		
		-- ID
		id_writeReg: in RegPort;
		id_isLW, id_isSW: in std_logic;
		id_writeMemData: in u16;
		id_aluInput: in AluInput;
		-- EX
		ex_writeReg: buffer RegPort;		
		ex_isLW, ex_isSW: buffer std_logic;
		ex_writeMemData: buffer u16;
		ex_aluInput: buffer AluInput
	) ;
end ID_EX;

architecture arch of ID_EX is	

	signal t_writeReg: RegPort;		
	signal t_isLW, t_isSW: std_logic;
	signal t_writeMemData: u16;
	signal t_aluInput: AluInput;
begin
	process( rst, clk )
	begin
		if rst = '0' then
			ex_writeReg <= NULL_REGPORT;
			ex_isLW <= '0';
			ex_isSW <= '0';
			ex_writeMemData <= x"0000";
			ex_aluInput <= NULL_ALUINPUT;
			t_writeReg <= NULL_REGPORT;
			t_isLW <= '0';
			t_isSW <= '0';
			t_writeMemData <= x"0000";
			t_aluInput <= NULL_ALUINPUT;
		elsif rising_edge(clk) then
			case( ctrl ) is
				when CLEAR =>	
					ex_writeReg <= NULL_REGPORT;
					ex_isLW <= '0';
					ex_isSW <= '0';
					ex_writeMemData <= x"0000";
					ex_aluInput <= NULL_ALUINPUT;
				when PASS =>
					ex_writeReg <= id_writeReg;
					ex_isLW <= id_isLW;
					ex_isSW <= id_isSW;
					ex_writeMemData <= id_writeMemData;
					ex_aluInput <= id_aluInput;
				when STORE =>
					t_writeReg <= ex_writeReg;
					t_isLW <= ex_isLW;
					t_isSW <= ex_isSW;
					t_writeMemData <= ex_writeMemData;
					t_aluInput <= ex_aluInput;
				when RESTORE =>
					ex_writeReg <= t_writeReg;
					ex_isLW <= t_isLW;
					ex_isSW <= t_isSW;
					ex_writeMemData <= t_writeMemData;
					ex_aluInput <= t_aluInput;
				when STALL =>	null;
			end case ;
		end if;
	end process ;

end arch ; -- arch
