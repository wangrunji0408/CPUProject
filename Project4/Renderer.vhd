library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 渲染模块
entity Renderer is
	port (
		rst, clk: in std_logic;
		vga_x, vga_y: in natural;
		color: out TColor
	) ;
end Renderer;

architecture arch of Renderer is	

	component FontReader is
		port (
			clk: in std_logic;
			id: in natural range 0 to 127;	-- 字符编码
			x, y: in natural range 0 to 15;	-- 坐标
			b: out std_logic				-- 输出字符在坐标下的bit
		);
	end component;
	
	signal r, g, b: u3;
	signal grid_x, grid_y: natural range 0 to 40; -- 40 * 30
	signal char_id: natural range 0 to 127;
	signal char_x, char_y: natural range 0 to 15;
	signal char_zone: boolean;
	signal data: std_logic;
begin
	rom: FontReader port map (clk, char_id, char_x, char_y, data);
	-- Read ROM
	grid_x <= vga_x / 16;  grid_y <= vga_y / 16;
	char_x <= vga_x mod 16;  char_y <= vga_y mod 16;
	char_id <= grid_y * 32 + grid_x;
	char_zone <= grid_x < 32 and grid_y < 4;
	-- Output
	color <= std_logic_vector(r & g & b);
	process( vga_x, vga_y )
	begin
		if char_zone then
			r <= data & data & data;
			g <= data & data & data;
			b <= data & data & data;
		else
			r <= to_u4(vga_x)(2 downto 0);
			g <= to_u4(vga_y)(2 downto 0);
			b <= to_u4(vga_x + vga_y)(2 downto 0);
		end if;
	end process ;
end arch ; -- arch
