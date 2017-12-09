library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity Shell is
	port (
		rst, clk: in std_logic;

		kb_write, kb_isBack: in std_logic;
		kb_data: in u8; 
		
		co_write: in std_logic;
		co_data: in u8;

		bufInfo: buffer ShellBufInfo
	) ;
end Shell;

architecture arch of Shell is	
	function add(x: natural) return natural is
	begin if x = 15 then return 0; else return x + 1; end if;
	end function;

	function sub(x: natural) return natural is
	begin if x = 0 then return 15; else return x - 1; end if;
	end function;

	constant NULL_LINE: LineBuf := (others => x"00");

begin

	process( rst, clk )
		variable x, y: natural;
		variable buf: ShellBuf;
		variable data: u8;
		variable isBack: std_logic;
		variable last_kb_write, last_co_write: std_logic;
		variable kb_event, co_event: boolean;
	begin
		bufInfo.x <= x; bufInfo.y <= y; bufInfo.data <= buf;
		if rst = '0' then
			buf := (others => NULL_LINE);
			x := 0; y := 0;
		elsif rising_edge(clk) then
			kb_event := kb_write = '0' and last_kb_write = '1';
			co_event := co_write = '0' and last_co_write = '1';
			
			if kb_event then
				data := kb_data;
				isBack := kb_isBack;
			elsif co_event then
				data := co_data;
				isBack := '0';
			end if;

			if kb_event or co_event then
				if isBack = '1' then
					if x /= 0 then
						x := x - 1;
						buf(y)(x) := x"00";						
					end if;
				else
					buf(y)(x) := data;
					x := x + 1;
					if data = x"0D" or x = 16 then	-- 换行
						x := 0;					
						if y = 15 then
							move0 : for i in 0 to 14 loop
								buf(i) := buf(i+1);
							end loop ; -- move
							buf(15) := NULL_LINE;
						else
							y := y + 1;
						end if;
					end if;
				end if;
			end if;
			
			last_kb_write := kb_write;
			last_co_write := co_write;
		end if;
	end process ; -- 

end arch ; -- arch
