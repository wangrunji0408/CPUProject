library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 取指/译码 中间层
-- 时钟上升沿时，简单地将参数从输入传递到输出
entity IF_ID is
	port (
		rst, clk: in std_logic;
		ctrl: in MidCtrl;		
		-- IF
		if_out: in IF_ID_Data;
		-- ID
		id_in: buffer IF_ID_Data
	) ;
end IF_ID;

architecture arch of IF_ID is	
	signal t: IF_ID_Data;
begin
	id_in.pc <= if_out.pc;
	process( rst, clk )
	begin
		if rst = '0' then
			id_in.inst <= x"0000";
			t.inst <= x"0000";
		elsif rising_edge(clk) then
			case( ctrl ) is
			when CLEAR =>	id_in.inst <= x"0000";
			when PASS =>	id_in.inst <= if_out.inst;
			when STORE =>	t.inst <= id_in.inst;
			when RESTORE =>	id_in.inst <= t.inst;
			when STALL =>	null;
			end case ;
		end if;
	end process ;
end arch ; -- arch
