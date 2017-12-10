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

	io_ram1_addr <= "111" & to_unsigned(pixel_y, 6) & to_unsigned(pixel_x, 7);

	process( rst, clk )
	begin
		if rst = '0' then
			data <= x"0000";
		elsif rising_edge(clk) then
			if io_canread = '1' then
				data <= io_ram1_data;
			end if;
		end if;
	end process ; -- 

end arch ; -- arch
