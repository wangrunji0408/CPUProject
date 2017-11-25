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
		debug: in CPUDebug
	) ;
end Renderer;

architecture arch of Renderer is	
	
	signal r, g, b: u3;
	signal grid_x, grid_y: natural; -- 80 * 30
	signal char: character;
	signal char_x, char_y: natural;
	signal data: std_logic;

begin
	rom: entity work.FontReader port map (clk, char, char_x, char_y, data);
	-- Read ROM
	grid_x <= vga_x / 8;  grid_y <= vga_y / 16;
	char_x <= vga_x mod 8;  char_y <= vga_y mod 16;
	-- Output
	color <= std_logic_vector(r) & std_logic_vector(g) & std_logic_vector(b);
	process( vga_x, vga_y )
		constant reg_zone_x: natural := 34;
		constant reg_zone_y: natural := 0;
		variable reg_id: natural;
		variable reg_data_str: string(1 to 4);
		variable entity_str: string(1 to 2);
		variable step_str: string(1 to 4);
		variable inst_name: string(1 to 8);

		function inZone (x: natural; x0: natural; x1: natural; y: natural; y0: natural; y1: natural) return boolean is
		begin
			return x >= x0 and x < x1 and y >= y0 and y < y1;
		end function;
	begin
		-- TODO
		-- 支持clk单步调试
		-- 每步显示序号和指令
		
		char <= ' ';
		if inZone(grid_x, 0, 2, grid_y, 0, 1) then
			-- 序号
			step_str := toStr16(to_u16(debug.step));
			char <= step_str(grid_x + 3);
		elsif inZone(grid_x, 0, 2, grid_y, 1, 2) then
			entity_str := "ID";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 24, grid_y, 1, 2) then --len=21
			-- PC & 16位指令 
			char <= show_IF_ID_Data(debug.id_in)(grid_x - 3);
		elsif inZone(grid_x, 25, 31, grid_y, 1, 2) then --len=6
			-- 识别的指令 
			inst_name := showInst(debug.instType);
			char <= inst_name(grid_x - 25 + 1);
		elsif inZone(grid_x, 0, 2, grid_y, 2, 3) then
			entity_str := "EX";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 18, grid_y, 2, 3) then --len=15
			-- EX的输入 
			char <= show_ID_MEM_Data(debug.ex_in)(grid_x - 3);
		elsif inZone(grid_x, 19, 32, grid_y, 2, 3) then --len=13
			-- EX AluInput
			char <= show_AluInput(debug.ex_in_aluInput)(grid_x - 19 + 1);
		elsif inZone(grid_x, 0, 2, grid_y, 3, 4) then
			entity_str := "ME";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 18, grid_y, 3, 4) then --len=15
			-- MEM的输入 
			char <= show_ID_MEM_Data(debug.mem_in)(grid_x - 3);
		elsif inZone(grid_x, 19, 23, grid_y, 3, 4) then --len=4
			-- MEM AluOut
			char <= toStr16(debug.mem_in_aluOut)(grid_x - 19 + 1);
		elsif inZone(grid_x, 0, 2, grid_y, 4, 5) then
			entity_str := "RB";
			char <= entity_str(grid_x + 1);
		elsif inZone(grid_x, 3, 10, grid_y, 4, 5) then --len=7
			-- RB的输入 
			char <= show_RegPort(debug.mem_out)(grid_x - 3 + 1);
		elsif inZone(grid_x, reg_zone_x, reg_zone_x+6, grid_y, reg_zone_y, reg_zone_y+16) then
			-- 寄存器 
			if grid_x = reg_zone_x then
				reg_id := grid_y - reg_zone_y;		
				char <= toHex(to_u4(reg_id));
			elsif grid_x >= reg_zone_x + 2 then
				reg_data_str := toStr16(debug.regs(reg_id));			
				char <= reg_data_str(grid_x - reg_zone_x - 1);				
			end if;
		end if;

		r <= data & data & data;
		g <= data & data & data;
		b <= data & data & data;
	end process ;
end arch ; -- arch
