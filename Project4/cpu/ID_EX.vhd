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
		id_out: in ID_EX_Data;
		-- EX
		ex_in: buffer ID_EX_Data
	) ;
end ID_EX;

architecture arch of ID_EX is	
	signal t: ID_EX_Data;
begin
	process( rst, clk )
	begin
		if rst = '0' then
			ex_in <= NULL_ID_EX_DATA;
			t <= NULL_ID_EX_DATA;
		elsif rising_edge(clk) then
			case( ctrl ) is
			when CLEAR =>	ex_in <= NULL_ID_EX_DATA;
			when PASS =>	ex_in <= id_out;
			when STORE =>	t <= ex_in;
			when RESTORE =>	ex_in <= t;
			when STALL =>	null;
			end case ;
		end if;
	end process ;

end arch ; -- arch
