library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Base.all;

-- 渲染模块
entity Renderer is
	port (
		rst, clk: in std_logic;
		vga_x, vga_y: in natural;
		color: out TColor;
		d_regs: in RegData
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
	signal grid_x, grid_y: natural; -- 40 * 30
	signal char_id: natural;
	signal char_x, char_y: natural;
	signal data: std_logic;
begin
	rom: FontReader port map (clk, char_id, char_x, char_y, data);
	-- Read ROM
	grid_x <= vga_x / 16;  grid_y <= vga_y / 16;
	char_x <= vga_x mod 16;  char_y <= vga_y mod 16;
	-- Output
	color <= std_logic_vector(r) & std_logic_vector(g) & std_logic_vector(b);
	process( vga_x, vga_y )
		constant reg_zone_x: natural := 34;
		constant reg_zone_y: natural := 0;
		variable reg_zone: boolean;
		variable reg_id: natural;
		variable reg_str: string(1 to 4);
	begin
		-- TODO
		-- 支持clk单步调试
		-- 每步显示序号和指令
		
		reg_zone := grid_x >= reg_zone_x and grid_x < reg_zone_x + 6
				and grid_y >= reg_zone_y and grid_y < reg_zone_y + 16;
		reg_id := grid_y - reg_zone_y;
		reg_str := toStr16(d_regs(reg_id));

		char_id <= 0;
		if reg_zone then
			if grid_x = reg_zone_x then
				char_id <= character'pos( toHex(to_u4(reg_id)) );
			elsif grid_x >= reg_zone_x + 2 then
				char_id <= character'pos( reg_str(grid_x - reg_zone_x - 1) );				
			end if;
		end if;

		r <= data & data & data;
		g <= data & data & data;
		b <= data & data & data;
	end process ;
end arch ; -- arch
