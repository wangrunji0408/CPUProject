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
		ex_out: in EX_MEM_Data;
		-- MEM
		mem_in: buffer EX_MEM_Data
	) ;
end EX_MEM;

architecture arch of EX_MEM is	
	signal t: EX_MEM_Data;
begin

	process( rst, clk )
	begin
		if rst = '0' then
			mem_in <= NULL_EX_MEM_DATA;
			t <= NULL_EX_MEM_DATA;
		elsif rising_edge(clk) then
			case( ctrl ) is
			when CLEAR =>	mem_in <= NULL_EX_MEM_DATA;
			when PASS =>	mem_in <= ex_out;
			when STORE =>	t <= mem_in;
			when RESTORE =>	mem_in <= t;
			when STALL =>	null;
			end case ;
		end if;
	end process ;
	
end arch ; -- arch
