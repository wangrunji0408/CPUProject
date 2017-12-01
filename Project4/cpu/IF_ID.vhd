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

	process( rst, clk )
	begin
		if rst = '0' then
			id_in <= NULL_IF_ID_DATA;
			t <= NULL_IF_ID_DATA;
		elsif rising_edge(clk) then
			case( ctrl ) is
			when CLEAR =>	id_in <= NULL_IF_ID_DATA;
			when PASS =>	id_in <= if_out;
			when STORE =>	t <= id_in;
			when RESTORE =>	id_in <= t;
			when STALL =>	null;
			end case ;
		end if;
	end process ;
end arch ; -- arch
