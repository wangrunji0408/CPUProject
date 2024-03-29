library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 译码/取指 中间层
entity ID_IF is
	port (
		rst, clk: in std_logic;
		ctrl: in MidCtrl;
		-- ID
		id_out: in IF_Data;
		-- IF
		if_in: buffer IF_Data
	) ;
end ID_IF;

architecture arch of ID_IF is	
	signal t: IF_Data;
begin
	process( rst, clk )
	begin
		if rst = '0' then
			if_in <= NULL_IF_DATA;
			t <= NULL_IF_DATA;
		elsif rising_edge(clk) then
			case( ctrl ) is
			when CLEAR => 	if_in <= NULL_IF_DATA;
			when PASS =>	if_in <= id_out;
			when STORE =>	t <= if_in;
			when RESTORE =>	if_in <= t;
			when STALL =>	null;
			end case ;
			if_in.isRefetch <= id_out.isRefetch;
		end if;
	end process ;
end arch ; -- arch
