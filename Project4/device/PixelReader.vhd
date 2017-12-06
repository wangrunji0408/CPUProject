library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

entity PixelReader is
	generic (
		MAX_X: natural := 80;
		MAX_Y: natural := 60
	);
	port (
		rst, clk: in std_logic;
		-- 对Renderer接口
		pixel_x, pixel_y: in natural;
		data: out u16;
		-- 对IOCtrl接口
		io_ram1_addr: out u16;
		io_ram1_data: in u16;
		io_canread: in std_logic -- 当MEM操作RAM1时不可读
	) ;
end PixelReader;

architecture arch of PixelReader is
begin

	process( rst, clk )
		variable next_x, next_y: natural;
		variable last_x, last_y: natural;
		variable next_data: u16;
	begin
		if rst = '0' then
			data <= x"0000";
			next_data := x"0000";
			io_ram1_addr <= x"FFFF";
			last_x := 0; last_y := 0;
		elsif rising_edge(clk) then
			if pixel_x /= last_x or pixel_y /= last_y then
				data <= next_data;
			end if;
			next_x := pixel_x + 1;
			next_y := pixel_y;
			if next_x = MAX_X then 
				next_x := 0; 
				next_y := next_y + 1;
			end if;
			if next_y = MAX_Y then
				next_y := 0;
			end if;
			io_ram1_addr <= "111" & to_unsigned(next_y, 6) & to_unsigned(next_x, 7);
			if io_canread = '1' then
				next_data := io_ram1_data;
			end if;
			last_x := pixel_x;
			last_y := pixel_y;
		end if;
	end process ; -- 

end arch ; -- arch
